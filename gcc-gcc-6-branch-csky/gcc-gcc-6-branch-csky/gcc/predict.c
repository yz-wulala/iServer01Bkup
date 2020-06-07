/* Branch prediction routines for the GNU compiler.
   Copyright (C) 2000-2016 Free Software Foundation, Inc.

This file is part of GCC.

GCC is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free
Software Foundation; either version 3, or (at your option) any later
version.

GCC is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
for more details.

You should have received a copy of the GNU General Public License
along with GCC; see the file COPYING3.  If not see
<http://www.gnu.org/licenses/>.  */

/* References:

   [1] "Branch Prediction for Free"
       Ball and Larus; PLDI '93.
   [2] "Static Branch Frequency and Program Profile Analysis"
       Wu and Larus; MICRO-27.
   [3] "Corpus-based Static Branch Prediction"
       Calder, Grunwald, Lindsay, Martin, Mozer, and Zorn; PLDI '95.  */


#include "config.h"
#include "system.h"
#include "coretypes.h"
#include "backend.h"
#include "rtl.h"
#include "tree.h"
#include "gimple.h"
#include "cfghooks.h"
#include "tree-pass.h"
#include "ssa.h"
#include "emit-rtl.h"
#include "cgraph.h"
#include "coverage.h"
#include "diagnostic-core.h"
#include "gimple-predict.h"
#include "fold-const.h"
#include "calls.h"
#include "cfganal.h"
#include "profile.h"
#include "sreal.h"
#include "params.h"
#include "cfgloop.h"
#include "gimple-iterator.h"
#include "tree-cfg.h"
#include "tree-ssa-loop-niter.h"
#include "tree-ssa-loop.h"
#include "tree-scalar-evolution.h"

/* real constants: 0, 1, 1-1/REG_BR_PROB_BASE, REG_BR_PROB_BASE,
		   1/REG_BR_PROB_BASE, 0.5, BB_FREQ_MAX.  */
static sreal real_almost_one, real_br_prob_base,
	     real_inv_br_prob_base, real_one_half, real_bb_freq_max;

static void combine_predictions_for_insn (rtx_insn *, basic_block);
static void dump_prediction (FILE *, enum br_predictor, int, basic_block, int);
static void predict_paths_leading_to (basic_block, enum br_predictor, enum prediction);
static void predict_paths_leading_to_edge (edge, enum br_predictor, enum prediction);
static bool can_predict_insn_p (const rtx_insn *);

/* Information we hold about each branch predictor.
   Filled using information from predict.def.  */

struct predictor_info
{
  const char *const name;	/* Name used in the debugging dumps.  */
  const int hitrate;		/* Expected hitrate used by
				   predict_insn_def call.  */
  const int flags;
};

/* Use given predictor without Dempster-Shaffer theory if it matches
   using first_match heuristics.  */
#define PRED_FLAG_FIRST_MATCH 1

/* Recompute hitrate in percent to our representation.  */

#define HITRATE(VAL) ((int) ((VAL) * REG_BR_PROB_BASE + 50) / 100)

#define DEF_PREDICTOR(ENUM, NAME, HITRATE, FLAGS) {NAME, HITRATE, FLAGS},
static const struct predictor_info predictor_info[]= {
#include "predict.def"

  /* Upper bound on predictors.  */
  {NULL, 0, 0}
};
#undef DEF_PREDICTOR

/* Return TRUE if frequency FREQ is considered to be hot.  */

static inline bool
maybe_hot_frequency_p (struct function *fun, int freq)
{
  struct cgraph_node *node = cgraph_node::get (fun->decl);
  if (!profile_info
      || !opt_for_fn (fun->decl, flag_branch_probabilities))
    {
      if (node->frequency == NODE_FREQUENCY_UNLIKELY_EXECUTED)
        return false;
      if (node->frequency == NODE_FREQUENCY_HOT)
        return true;
    }
  if (profile_status_for_fn (fun) == PROFILE_ABSENT)
    return true;
  if (node->frequency == NODE_FREQUENCY_EXECUTED_ONCE
      && freq < (ENTRY_BLOCK_PTR_FOR_FN (fun)->frequency * 2 / 3))
    return false;
  if (PARAM_VALUE (HOT_BB_FREQUENCY_FRACTION) == 0)
    return false;
  if (freq < (ENTRY_BLOCK_PTR_FOR_FN (fun)->frequency
	      / PARAM_VALUE (HOT_BB_FREQUENCY_FRACTION)))
    return false;
  return true;
}

static gcov_type min_count = -1;

/* Determine the threshold for hot BB counts.  */

gcov_type
get_hot_bb_threshold ()
{
  gcov_working_set_t *ws;
  if (min_count == -1)
    {
      ws = find_working_set (PARAM_VALUE (HOT_BB_COUNT_WS_PERMILLE));
      gcc_assert (ws);
      min_count = ws->min_counter;
    }
  return min_count;
}

/* Set the threshold for hot BB counts.  */

void
set_hot_bb_threshold (gcov_type min)
{
  min_count = min;
}

/* Return TRUE if frequency FREQ is considered to be hot.  */

bool
maybe_hot_count_p (struct function *fun, gcov_type count)
{
  if (fun && profile_status_for_fn (fun) != PROFILE_READ)
    return true;
  /* Code executed at most once is not hot.  */
  if (profile_info->runs >= count)
    return false;
  return (count >= get_hot_bb_threshold ());
}

/* Return true in case BB can be CPU intensive and should be optimized
   for maximal performance.  */

bool
maybe_hot_bb_p (struct function *fun, const_basic_block bb)
{
  gcc_checking_assert (fun);
  if (profile_status_for_fn (fun) == PROFILE_READ)
    return maybe_hot_count_p (fun, bb->count);
  return maybe_hot_frequency_p (fun, bb->frequency);
}

/* Return true in case BB can be CPU intensive and should be optimized
   for maximal performance.  */

bool
maybe_hot_edge_p (edge e)
{
  if (profile_status_for_fn (cfun) == PROFILE_READ)
    return maybe_hot_count_p (cfun, e->count);
  return maybe_hot_frequency_p (cfun, EDGE_FREQUENCY (e));
}

/* Return true if profile COUNT and FREQUENCY, or function FUN static
   node frequency reflects never being executed.  */
   
static bool
probably_never_executed (struct function *fun,
                         gcov_type count, int frequency)
{
  gcc_checking_assert (fun);
  if (profile_status_for_fn (fun) == PROFILE_READ)
    {
      int unlikely_count_fraction = PARAM_VALUE (UNLIKELY_BB_COUNT_FRACTION);
      if (count * unlikely_count_fraction >= profile_info->runs)
	return false;
      if (!frequency)
	return true;
      if (!ENTRY_BLOCK_PTR_FOR_FN (fun)->frequency)
	return false;
      if (ENTRY_BLOCK_PTR_FOR_FN (fun)->count)
	{
          gcov_type computed_count;
          /* Check for possibility of overflow, in which case entry bb count
             is large enough to do the division first without losing much
             precision.  */
	  if (ENTRY_BLOCK_PTR_FOR_FN (fun)->count < REG_BR_PROB_BASE *
	      REG_BR_PROB_BASE)
            {
              gcov_type scaled_count
		  = frequency * ENTRY_BLOCK_PTR_FOR_FN (fun)->count *
	     unlikely_count_fraction;
	      computed_count = RDIV (scaled_count,
				     ENTRY_BLOCK_PTR_FOR_FN (fun)->frequency);
            }
          else
            {
	      computed_count = RDIV (ENTRY_BLOCK_PTR_FOR_FN (fun)->count,
				     ENTRY_BLOCK_PTR_FOR_FN (fun)->frequency);
              computed_count *= frequency * unlikely_count_fraction;
            }
          if (computed_count >= profile_info->runs)
            return false;
	}
      return true;
    }
  if ((!profile_info || !(opt_for_fn (fun->decl, flag_branch_probabilities)))
      && (cgraph_node::get (fun->decl)->frequency
	  == NODE_FREQUENCY_UNLIKELY_EXECUTED))
    return true;
  return false;
}


/* Return true in case BB is probably never executed.  */

bool
probably_never_executed_bb_p (struct function *fun, const_basic_block bb)
{
  return probably_never_executed (fun, bb->count, bb->frequency);
}


/* Return true in case edge E is probably never executed.  */

bool
probably_never_executed_edge_p (struct function *fun, edge e)
{
  return probably_never_executed (fun, e->count, EDGE_FREQUENCY (e));
}

/* Return true when current function should always be optimized for size.  */

bool
optimize_function_for_size_p (struct function *fun)
{
  if (!fun || !fun->decl)
    return optimize_size;
  cgraph_node *n = cgraph_node::get (fun->decl);
  return n && n->optimize_for_size_p ();
}

/* Return true when current function should always be optimized for speed.  */

bool
optimize_function_for_speed_p (struct function *fun)
{
  return !optimize_function_for_size_p (fun);
}

/* Return the optimization type that should be used for the function FUN.  */

optimization_type
function_optimization_type (struct function *fun)
{
  return (optimize_function_for_speed_p (fun)
	  ? OPTIMIZE_FOR_SPEED
	  : OPTIMIZE_FOR_SIZE);
}

/* Return TRUE when BB should be optimized for size.  */

bool
optimize_bb_for_size_p (const_basic_block bb)
{
  return (optimize_function_for_size_p (cfun)
	  || (bb && !maybe_hot_bb_p (cfun, bb)));
}

/* Return TRUE when BB should be optimized for speed.  */

bool
optimize_bb_for_speed_p (const_basic_block bb)
{
  return !optimize_bb_for_size_p (bb);
}

/* Return the optimization type that should be used for block BB.  */

optimization_type
bb_optimization_type (const_basic_block bb)
{
  return (optimize_bb_for_speed_p (bb)
	  ? OPTIMIZE_FOR_SPEED
	  : OPTIMIZE_FOR_SIZE);
}

/* Return TRUE when BB should be optimized for size.  */

bool
optimize_edge_for_size_p (edge e)
{
  return optimize_function_for_size_p (cfun) || !maybe_hot_edge_p (e);
}

/* Return TRUE when BB should be optimized for speed.  */

bool
optimize_edge_for_speed_p (edge e)
{
  return !optimize_edge_for_size_p (e);
}

/* Return TRUE when BB should be optimized for size.  */

bool
optimize_insn_for_size_p (void)
{
  return optimize_function_for_size_p (cfun) || !crtl->maybe_hot_insn_p;
}

/* Return TRUE when BB should be optimized for speed.  */

bool
optimize_insn_for_speed_p (void)
{
  return !optimize_insn_for_size_p ();
}

/* Return TRUE when LOOP should be optimized for size.  */

bool
optimize_loop_for_size_p (struct loop *loop)
{
  return optimize_bb_for_size_p (loop->header);
}

/* Return TRUE when LOOP should be optimized for speed.  */

bool
optimize_loop_for_speed_p (struct loop *loop)
{
  return optimize_bb_for_speed_p (loop->header);
}

/* Return TRUE when LOOP nest should be optimized for speed.  */

bool
optimize_loop_nest_for_speed_p (struct loop *loop)
{
  struct loop *l = loop;
  if (optimize_loop_for_speed_p (loop))
    return true;
  l = loop->inner;
  while (l && l != loop)
    {
      if (optimize_loop_for_speed_p (l))
        return true;
      if (l->inner)
        l = l->inner;
      else if (l->next)
        l = l->next;
      else
        {
	  while (l != loop && !l->next)
	    l = loop_outer (l);
	  if (l != loop)
	    l = l->next;
	}
    }
  return false;
}

/* Return TRUE when LOOP nest should be optimized for size.  */

bool
optimize_loop_nest_for_size_p (struct loop *loop)
{
  return !optimize_loop_nest_for_speed_p (loop);
}

/* Return true when edge E is likely to be well predictable by branch
   predictor.  */

bool
predictable_edge_p (edge e)
{
  if (profile_status_for_fn (cfun) == PROFILE_ABSENT)
    return false;
  if ((e->probability
       <= PARAM_VALUE (PARAM_PREDICTABLE_BRANCH_OUTCOME) * REG_BR_PROB_BASE / 100)
      || (REG_BR_PROB_BASE - e->probability
          <= PARAM_VALUE (PARAM_PREDICTABLE_BRANCH_OUTCOME) * REG_BR_PROB_BASE / 100))
    return true;
  return false;
}


/* Set RTL expansion for BB profile.  */

void
rtl_profile_for_bb (basic_block bb)
{
  crtl->maybe_hot_insn_p = maybe_hot_bb_p (cfun, bb);
}

/* Set RTL expansion for edge profile.  */

void
rtl_profile_for_edge (edge e)
{
  crtl->maybe_hot_insn_p = maybe_hot_edge_p (e);
}

/* Set RTL expansion to default mode (i.e. when profile info is not known).  */
void
default_rtl_profile (void)
{
  crtl->maybe_hot_insn_p = true;
}

/* Return true if the one of outgoing edges is already predicted by
   PREDICTOR.  */

bool
rtl_predicted_by_p (const_basic_block bb, enum br_predictor predictor)
{
  rtx note;
  if (!INSN_P (BB_END (bb)))
    return false;
  for (note = REG_NOTES (BB_END (bb)); note; note = XEXP (note, 1))
    if (REG_NOTE_KIND (note) == REG_BR_PRED
	&& INTVAL (XEXP (XEXP (note, 0), 0)) == (int)predictor)
      return true;
  return false;
}

/*  Structure representing predictions in tree level. */

struct edge_prediction {
    struct edge_prediction *ep_next;
    edge ep_edge;
    enum br_predictor ep_predictor;
    int ep_probability;
};

/* This map contains for a basic block the list of predictions for the
   outgoing edges.  */

static hash_map<const_basic_block, edge_prediction *> *bb_predictions;

/* Return true if the one of outgoing edges is already predicted by
   PREDICTOR.  */

bool
gimple_predicted_by_p (const_basic_block bb, enum br_predictor predictor)
{
  struct edge_prediction *i;
  edge_prediction **preds = bb_predictions->get (bb);

  if (!preds)
    return false;

  for (i = *preds; i; i = i->ep_next)
    if (i->ep_predictor == predictor)
      return true;
  return false;
}

/* Return true when the probability of edge is reliable.

   The profile guessing code is good at predicting branch outcome (ie.
   taken/not taken), that is predicted right slightly over 75% of time.
   It is however notoriously poor on predicting the probability itself.
   In general the profile appear a lot flatter (with probabilities closer
   to 50%) than the reality so it is bad idea to use it to drive optimization
   such as those disabling dynamic branch prediction for well predictable
   branches.

   There are two exceptions - edges leading to noreturn edges and edges
   predicted by number of iterations heuristics are predicted well.  This macro
   should be able to distinguish those, but at the moment it simply check for
   noreturn heuristic that is only one giving probability over 99% or bellow
   1%.  In future we might want to propagate reliability information across the
   CFG if we find this information useful on multiple places.   */
static bool
probability_reliable_p (int prob)
{
  return (profile_status_for_fn (cfun) == PROFILE_READ
	  || (profile_status_for_fn (cfun) == PROFILE_GUESSED
	      && (prob <= HITRATE (1) || prob >= HITRATE (99))));
}

/* Same predicate as above, working on edges.  */
bool
edge_probability_reliable_p (const_edge e)
{
  return probability_reliable_p (e->probability);
}

/* Same predicate as edge_probability_reliable_p, working on notes.  */
bool
br_prob_note_reliable_p (const_rtx note)
{
  gcc_assert (REG_NOTE_KIND (note) == REG_BR_PROB);
  return probability_reliable_p (XINT (note, 0));
}

static void
predict_insn (rtx_insn *insn, enum br_predictor predictor, int probability)
{
  gcc_assert (any_condjump_p (insn));
  if (!flag_guess_branch_prob)
    return;

  add_reg_note (insn, REG_BR_PRED,
		gen_rtx_CONCAT (VOIDmode,
				GEN_INT ((int) predictor),
				GEN_INT ((int) probability)));
}

/* Predict insn by given predictor.  */

void
predict_insn_def (rtx_insn *insn, enum br_predictor predictor,
		  enum prediction taken)
{
   int probability = predictor_info[(int) predictor].hitrate;

   if (taken != TAKEN)
     probability = REG_BR_PROB_BASE - probability;

   predict_insn (insn, predictor, probability);
}

/* Predict edge E with given probability if possible.  */

void
rtl_predict_edge (edge e, enum br_predictor predictor, int probability)
{
  rtx_insn *last_insn;
  last_insn = BB_END (e->src);

  /* We can store the branch prediction information only about
     conditional jumps.  */
  if (!any_condjump_p (last_insn))
    return;

  /* We always store probability of branching.  */
  if (e->flags & EDGE_FALLTHRU)
    probability = REG_BR_PROB_BASE - probability;

  predict_insn (last_insn, predictor, probability);
}

/* Predict edge E with the given PROBABILITY.  */
void
gimple_predict_edge (edge e, enum br_predictor predictor, int probability)
{
  gcc_assert (profile_status_for_fn (cfun) != PROFILE_GUESSED);
  if ((e->src != ENTRY_BLOCK_PTR_FOR_FN (cfun) && EDGE_COUNT (e->src->succs) >
       1)
      && flag_guess_branch_prob && optimize)
    {
      struct edge_prediction *i = XNEW (struct edge_prediction);
      edge_prediction *&preds = bb_predictions->get_or_insert (e->src);

      i->ep_next = preds;
      preds = i;
      i->ep_probability = probability;
      i->ep_predictor = predictor;
      i->ep_edge = e;
    }
}

/* Remove all predictions on given basic block that are attached
   to edge E.  */
void
remove_predictions_associated_with_edge (edge e)
{
  if (!bb_predictions)
    return;

  edge_prediction **preds = bb_predictions->get (e->src);

  if (preds)
    {
      struct edge_prediction **prediction = preds;
      struct edge_prediction *next;

      while (*prediction)
	{
	  if ((*prediction)->ep_edge == e)
	    {
	      next = (*prediction)->ep_next;
	      free (*prediction);
	      *prediction = next;
	    }
	  else
	    prediction = &((*prediction)->ep_next);
	}
    }
}

/* Clears the list of predictions stored for BB.  */

static void
clear_bb_predictions (basic_block bb)
{
  edge_prediction **preds = bb_predictions->get (bb);
  struct edge_prediction *pred, *next;

  if (!preds)
    return;

  for (pred = *preds; pred; pred = next)
    {
      next = pred->ep_next;
      free (pred);
    }
  *preds = NULL;
}

/* Return true when we can store prediction on insn INSN.
   At the moment we represent predictions only on conditional
   jumps, not at computed jump or other complicated cases.  */
static bool
can_predict_insn_p (const rtx_insn *insn)
{
  return (JUMP_P (insn)
	  && any_condjump_p (insn)
	  && EDGE_COUNT (BLOCK_FOR_INSN (insn)->succs) >= 2);
}

/* Predict edge E by given predictor if possible.  */

void
predict_edge_def (edge e, enum br_predictor predictor,
		  enum prediction taken)
{
   int probability = predictor_info[(int) predictor].hitrate;

   if (taken != TAKEN)
     probability = REG_BR_PROB_BASE - probability;

   predict_edge (e, predictor, probability);
}

/* Invert all branch predictions or probability notes in the INSN.  This needs
   to be done each time we invert the condition used by the jump.  */

void
invert_br_probabilities (rtx insn)
{
  rtx note;

  for (note = REG_NOTES (insn); note; note = XEXP (note, 1))
    if (REG_NOTE_KIND (note) == REG_BR_PROB)
      XINT (note, 0) = REG_BR_PROB_BASE - XINT (note, 0);
    else if (REG_NOTE_KIND (note) == REG_BR_PRED)
      XEXP (XEXP (note, 0), 1)
	= GEN_INT (REG_BR_PROB_BASE - INTVAL (XEXP (XEXP (note, 0), 1)));
}

/* Dump information about the branch prediction to the output file.  */

static void
dump_prediction (FILE *file, enum br_predictor predictor, int probability,
		 basic_block bb, int used)
{
  edge e;
  edge_iterator ei;

  if (!file)
    return;

  FOR_EACH_EDGE (e, ei, bb->succs)
    if (! (e->flags & EDGE_FALLTHRU))
      break;

  fprintf (file, "  %s heuristics%s: %.1f%%",
	   predictor_info[predictor].name,
	   used ? "" : " (ignored)", probability * 100.0 / REG_BR_PROB_BASE);

  if (bb->count)
    {
      fprintf (file, "  exec %" PRId64, bb->count);
      if (e)
	{
	  fprintf (file, " hit %" PRId64, e->count);
	  fprintf (file, " (%.1f%%)", e->count * 100.0 / bb->count);
	}
    }

  fprintf (file, "\n");
}

/* We can not predict the probabilities of outgoing edges of bb.  Set them
   evenly and hope for the best.  */
static void
set_even_probabilities (basic_block bb)
{
  int nedges = 0;
  edge e;
  edge_iterator ei;

  FOR_EACH_EDGE (e, ei, bb->succs)
    if (!(e->flags & (EDGE_EH | EDGE_FAKE)))
      nedges ++;
  FOR_EACH_EDGE (e, ei, bb->succs)
    if (!(e->flags & (EDGE_EH | EDGE_FAKE)))
      e->probability = (REG_BR_PROB_BASE + nedges / 2) / nedges;
    else
      e->probability = 0;
}

/* Combine all REG_BR_PRED notes into single probability and attach REG_BR_PROB
   note if not already present.  Remove now useless REG_BR_PRED notes.  */

static void
combine_predictions_for_insn (rtx_insn *insn, basic_block bb)
{
  rtx prob_note;
  rtx *pnote;
  rtx note;
  int best_probability = PROB_EVEN;
  enum br_predictor best_predictor = END_PREDICTORS;
  int combined_probability = REG_BR_PROB_BASE / 2;
  int d;
  bool first_match = false;
  bool found = false;

  if (!can_predict_insn_p (insn))
    {
      set_even_probabilities (bb);
      return;
    }

  prob_note = find_reg_note (insn, REG_BR_PROB, 0);
  pnote = &REG_NOTES (insn);
  if (dump_file)
    fprintf (dump_file, "Predictions for insn %i bb %i\n", INSN_UID (insn),
	     bb->index);

  /* We implement "first match" heuristics and use probability guessed
     by predictor with smallest index.  */
  for (note = REG_NOTES (insn); note; note = XEXP (note, 1))
    if (REG_NOTE_KIND (note) == REG_BR_PRED)
      {
	enum br_predictor predictor = ((enum br_predictor)
				       INTVAL (XEXP (XEXP (note, 0), 0)));
	int probability = INTVAL (XEXP (XEXP (note, 0), 1));

	found = true;
	if (best_predictor > predictor)
	  best_probability = probability, best_predictor = predictor;

	d = (combined_probability * probability
	     + (REG_BR_PROB_BASE - combined_probability)
	     * (REG_BR_PROB_BASE - probability));

	/* Use FP math to avoid overflows of 32bit integers.  */
	if (d == 0)
	  /* If one probability is 0% and one 100%, avoid division by zero.  */
	  combined_probability = REG_BR_PROB_BASE / 2;
	else
	  combined_probability = (((double) combined_probability) * probability
				  * REG_BR_PROB_BASE / d + 0.5);
      }

  /* Decide which heuristic to use.  In case we didn't match anything,
     use no_prediction heuristic, in case we did match, use either
     first match or Dempster-Shaffer theory depending on the flags.  */

  if (predictor_info [best_predictor].flags & PRED_FLAG_FIRST_MATCH)
    first_match = true;

  if (!found)
    dump_prediction (dump_file, PRED_NO_PREDICTION,
		     combined_probability, bb, true);
  else
    {
      dump_prediction (dump_file, PRED_DS_THEORY, combined_probability,
		       bb, !first_match);
      dump_prediction (dump_file, PRED_FIRST_MATCH, best_probability,
		       bb, first_match);
    }

  if (first_match)
    combined_probability = best_probability;
  dump_prediction (dump_file, PRED_COMBINED, combined_probability, bb, true);

  while (*pnote)
    {
      if (REG_NOTE_KIND (*pnote) == REG_BR_PRED)
	{
	  enum br_predictor predictor = ((enum br_predictor)
					 INTVAL (XEXP (XEXP (*pnote, 0), 0)));
	  int probability = INTVAL (XEXP (XEXP (*pnote, 0), 1));

	  dump_prediction (dump_file, predictor, probability, bb,
			   !first_match || best_predictor == predictor);
	  *pnote = XEXP (*pnote, 1);
	}
      else
	pnote = &XEXP (*pnote, 1);
    }

  if (!prob_note)
    {
      add_int_reg_note (insn, REG_BR_PROB, combined_probability);

      /* Save the prediction into CFG in case we are seeing non-degenerated
	 conditional jump.  */
      if (!single_succ_p (bb))
	{
	  BRANCH_EDGE (bb)->probability = combined_probability;
	  FALLTHRU_EDGE (bb)->probability
	    = REG_BR_PROB_BASE - combined_probability;
	}
    }
  else if (!single_succ_p (bb))
    {
      int prob = XINT (prob_note, 0);

      BRANCH_EDGE (bb)->probability = prob;
      FALLTHRU_EDGE (bb)->probability = REG_BR_PROB_BASE - prob;
    }
  else
    single_succ_edge (bb)->probability = REG_BR_PROB_BASE;
}

/* Combine predictions into single probability and store them into CFG.
   Remove now useless prediction entries.  */

static void
combine_predictions_for_bb (basic_block bb)
{
  int best_probability = PROB_EVEN;
  enum br_predictor best_predictor = END_PREDICTORS;
  int combined_probability = REG_BR_PROB_BASE / 2;
  int d;
  bool first_match = false;
  bool found = false;
  struct edge_prediction *pred;
  int nedges = 0;
  edge e, first = NULL, second = NULL;
  edge_iterator ei;

  FOR_EACH_EDGE (e, ei, bb->succs)
    if (!(e->flags & (EDGE_EH | EDGE_FAKE)))
      {
	nedges ++;
	if (first && !second)
	  second = e;
	if (!first)
	  first = e;
      }

  /* When there is no successor or only one choice, prediction is easy.

     We are lazy for now and predict only basic blocks with two outgoing
     edges.  It is possible to predict generic case too, but we have to
     ignore first match heuristics and do more involved combining.  Implement
     this later.  */
  if (nedges != 2)
    {
      if (!bb->count)
	set_even_probabilities (bb);
      clear_bb_predictions (bb);
      if (dump_file)
	fprintf (dump_file, "%i edges in bb %i predicted to even probabilities\n",
		 nedges, bb->index);
      return;
    }

  if (dump_file)
    fprintf (dump_file, "Predictions for bb %i\n", bb->index);

  edge_prediction **preds = bb_predictions->get (bb);
  if (preds)
    {
      /* We implement "first match" heuristics and use probability guessed
	 by predictor with smallest index.  */
      for (pred = *preds; pred; pred = pred->ep_next)
	{
	  enum br_predictor predictor = pred->ep_predictor;
	  int probability = pred->ep_probability;

	  if (pred->ep_edge != first)
	    probability = REG_BR_PROB_BASE - probability;

	  found = true;
	  /* First match heuristics would be widly confused if we predicted
	     both directions.  */
	  if (best_predictor > predictor)
	    {
              struct edge_prediction *pred2;
	      int prob = probability;

	      for (pred2 = (struct edge_prediction *) *preds;
		   pred2; pred2 = pred2->ep_next)
	       if (pred2 != pred && pred2->ep_predictor == pred->ep_predictor)
	         {
	           int probability2 = pred->ep_probability;

		   if (pred2->ep_edge != first)
		     probability2 = REG_BR_PROB_BASE - probability2;

		   if ((probability < REG_BR_PROB_BASE / 2) !=
		       (probability2 < REG_BR_PROB_BASE / 2))
		     break;

		   /* If the same predictor later gave better result, go for it! */
		   if ((probability >= REG_BR_PROB_BASE / 2 && (probability2 > probability))
		       || (probability <= REG_BR_PROB_BASE / 2 && (probability2 < probability)))
		     prob = probability2;
		 }
	      if (!pred2)
	        best_probability = prob, best_predictor = predictor;
	    }

	  d = (combined_probability * probability
	       + (REG_BR_PROB_BASE - combined_probability)
	       * (REG_BR_PROB_BASE - probability));

	  /* Use FP math to avoid overflows of 32bit integers.  */
	  if (d == 0)
	    /* If one probability is 0% and one 100%, avoid division by zero.  */
	    combined_probability = REG_BR_PROB_BASE / 2;
	  else
	    combined_probability = (((double) combined_probability)
				    * probability
		    		    * REG_BR_PROB_BASE / d + 0.5);
	}
    }

  /* Decide which heuristic to use.  In case we didn't match anything,
     use no_prediction heuristic, in case we did match, use either
     first match or Dempster-Shaffer theory depending on the flags.  */

  if (predictor_info [best_predictor].flags & PRED_FLAG_FIRST_MATCH)
    first_match = true;

  if (!found)
    dump_prediction (dump_file, PRED_NO_PREDICTION, combined_probability, bb, true);
  else
    {
      dump_prediction (dump_file, PRED_DS_THEORY, combined_probability, bb,
		       !first_match);
      dump_prediction (dump_file, PRED_FIRST_MATCH, best_probability, bb,
		       first_match);
    }

  if (first_match)
    combined_probability = best_probability;
  dump_prediction (dump_file, PRED_COMBINED, combined_probability, bb, true);

  if (preds)
    {
      for (pred = (struct edge_prediction *) *preds; pred; pred = pred->ep_next)
	{
	  enum br_predictor predictor = pred->ep_predictor;
	  int probability = pred->ep_probability;

	  if (pred->ep_edge != EDGE_SUCC (bb, 0))
	    probability = REG_BR_PROB_BASE - probability;
	  dump_prediction (dump_file, predictor, probability, bb,
			   !first_match || best_predictor == predictor);
	}
    }
  clear_bb_predictions (bb);

  if (!bb->count)
    {
      first->probability = combined_probability;
      second->probability = REG_BR_PROB_BASE - combined_probability;
    }
}

/* Check if T1 and T2 satisfy the IV_COMPARE condition.
   Return the SSA_NAME if the condition satisfies, NULL otherwise.

   T1 and T2 should be one of the following cases:
     1. T1 is SSA_NAME, T2 is NULL
     2. T1 is SSA_NAME, T2 is INTEGER_CST between [-4, 4]
     3. T2 is SSA_NAME, T1 is INTEGER_CST between [-4, 4]  */

static tree
strips_small_constant (tree t1, tree t2)
{
  tree ret = NULL;
  int value = 0;

  if (!t1)
    return NULL;
  else if (TREE_CODE (t1) == SSA_NAME)
    ret = t1;
  else if (tree_fits_shwi_p (t1))
    value = tree_to_shwi (t1);
  else
    return NULL;

  if (!t2)
    return ret;
  else if (tree_fits_shwi_p (t2))
    value = tree_to_shwi (t2);
  else if (TREE_CODE (t2) == SSA_NAME)
    {
      if (ret)
        return NULL;
      else
        ret = t2;
    }

  if (value <= 4 && value >= -4)
    return ret;
  else
    return NULL;
}

/* Return the SSA_NAME in T or T's operands.
   Return NULL if SSA_NAME cannot be found.  */

static tree
get_base_value (tree t)
{
  if (TREE_CODE (t) == SSA_NAME)
    return t;

  if (!BINARY_CLASS_P (t))
    return NULL;

  switch (TREE_OPERAND_LENGTH (t))
    {
    case 1:
      return strips_small_constant (TREE_OPERAND (t, 0), NULL);
    case 2:
      return strips_small_constant (TREE_OPERAND (t, 0),
				    TREE_OPERAND (t, 1));
    default:
      return NULL;
    }
}

/* Check the compare STMT in LOOP. If it compares an induction
   variable to a loop invariant, return true, and save
   LOOP_INVARIANT, COMPARE_CODE and LOOP_STEP.
   Otherwise return false and set LOOP_INVAIANT to NULL.  */

static bool
is_comparison_with_loop_invariant_p (gcond *stmt, struct loop *loop,
				     tree *loop_invariant,
				     enum tree_code *compare_code,
				     tree *loop_step,
				     tree *loop_iv_base)
{
  tree op0, op1, bound, base;
  affine_iv iv0, iv1;
  enum tree_code code;
  tree step;

  code = gimple_cond_code (stmt);
  *loop_invariant = NULL;

  switch (code)
    {
    case GT_EXPR:
    case GE_EXPR:
    case NE_EXPR:
    case LT_EXPR:
    case LE_EXPR:
    case EQ_EXPR:
      break;

    default:
      return false;
    }

  op0 = gimple_cond_lhs (stmt);
  op1 = gimple_cond_rhs (stmt);

  if ((TREE_CODE (op0) != SSA_NAME && TREE_CODE (op0) != INTEGER_CST) 
       || (TREE_CODE (op1) != SSA_NAME && TREE_CODE (op1) != INTEGER_CST))
    return false;
  if (!simple_iv (loop, loop_containing_stmt (stmt), op0, &iv0, true))
    return false;
  if (!simple_iv (loop, loop_containing_stmt (stmt), op1, &iv1, true))
    return false;
  if (TREE_CODE (iv0.step) != INTEGER_CST
      || TREE_CODE (iv1.step) != INTEGER_CST)
    return false;
  if ((integer_zerop (iv0.step) && integer_zerop (iv1.step))
      || (!integer_zerop (iv0.step) && !integer_zerop (iv1.step)))
    return false;

  if (integer_zerop (iv0.step))
    {
      if (code != NE_EXPR && code != EQ_EXPR)
	code = invert_tree_comparison (code, false);
      bound = iv0.base;
      base = iv1.base;
      if (tree_fits_shwi_p (iv1.step))
	step = iv1.step;
      else
	return false;
    }
  else
    {
      bound = iv1.base;
      base = iv0.base;
      if (tree_fits_shwi_p (iv0.step))
	step = iv0.step;
      else
	return false;
    }

  if (TREE_CODE (bound) != INTEGER_CST)
    bound = get_base_value (bound);
  if (!bound)
    return false;
  if (TREE_CODE (base) != INTEGER_CST)
    base = get_base_value (base);
  if (!base)
    return false;

  *loop_invariant = bound;
  *compare_code = code;
  *loop_step = step;
  *loop_iv_base = base;
  return true;
}

/* Compare two SSA_NAMEs: returns TRUE if T1 and T2 are value coherent.  */

static bool
expr_coherent_p (tree t1, tree t2)
{
  gimple *stmt;
  tree ssa_name_1 = NULL;
  tree ssa_name_2 = NULL;

  gcc_assert (TREE_CODE (t1) == SSA_NAME || TREE_CODE (t1) == INTEGER_CST);
  gcc_assert (TREE_CODE (t2) == SSA_NAME || TREE_CODE (t2) == INTEGER_CST);

  if (t1 == t2)
    return true;

  if (TREE_CODE (t1) == INTEGER_CST && TREE_CODE (t2) == INTEGER_CST)
    return true;
  if (TREE_CODE (t1) == INTEGER_CST || TREE_CODE (t2) == INTEGER_CST)
    return false;

  /* Check to see if t1 is expressed/defined with t2.  */
  stmt = SSA_NAME_DEF_STMT (t1);
  gcc_assert (stmt != NULL);
  if (is_gimple_assign (stmt))
    {
      ssa_name_1 = SINGLE_SSA_TREE_OPERAND (stmt, SSA_OP_USE);
      if (ssa_name_1 && ssa_name_1 == t2)
	return true;
    }

  /* Check to see if t2 is expressed/defined with t1.  */
  stmt = SSA_NAME_DEF_STMT (t2);
  gcc_assert (stmt != NULL);
  if (is_gimple_assign (stmt))
    {
      ssa_name_2 = SINGLE_SSA_TREE_OPERAND (stmt, SSA_OP_USE);
      if (ssa_name_2 && ssa_name_2 == t1)
	return true;
    }

  /* Compare if t1 and t2's def_stmts are identical.  */
  if (ssa_name_2 != NULL && ssa_name_1 == ssa_name_2)
    return true;
  else
    return false;
}

/* Predict branch probability of BB when BB contains a branch that compares
   an induction variable in LOOP with LOOP_IV_BASE_VAR to LOOP_BOUND_VAR. The
   loop exit is compared using LOOP_BOUND_CODE, with step of LOOP_BOUND_STEP.

   E.g.
     for (int i = 0; i < bound; i++) {
       if (i < bound - 2)
	 computation_1();
       else
	 computation_2();
     }

  In this loop, we will predict the branch inside the loop to be taken.  */

static void
predict_iv_comparison (struct loop *loop, basic_block bb,
		       tree loop_bound_var,
		       tree loop_iv_base_var,
		       enum tree_code loop_bound_code,
		       int loop_bound_step)
{
  gimple *stmt;
  tree compare_var, compare_base;
  enum tree_code compare_code;
  tree compare_step_var;
  edge then_edge;
  edge_iterator ei;

  if (predicted_by_p (bb, PRED_LOOP_ITERATIONS_GUESSED)
      || predicted_by_p (bb, PRED_LOOP_ITERATIONS)
      || predicted_by_p (bb, PRED_LOOP_EXIT))
    return;

  stmt = last_stmt (bb);
  if (!stmt || gimple_code (stmt) != GIMPLE_COND)
    return;
  if (!is_comparison_with_loop_invariant_p (as_a <gcond *> (stmt),
					    loop, &compare_var,
					    &compare_code,
					    &compare_step_var,
					    &compare_base))
    return;

  /* Find the taken edge.  */
  FOR_EACH_EDGE (then_edge, ei, bb->succs)
    if (then_edge->flags & EDGE_TRUE_VALUE)
      break;

  /* When comparing an IV to a loop invariant, NE is more likely to be
     taken while EQ is more likely to be not-taken.  */
  if (compare_code == NE_EXPR)
    {
      predict_edge_def (then_edge, PRED_LOOP_IV_COMPARE_GUESS, TAKEN);
      return;
    }
  else if (compare_code == EQ_EXPR)
    {
      predict_edge_def (then_edge, PRED_LOOP_IV_COMPARE_GUESS, NOT_TAKEN);
      return;
    }

  if (!expr_coherent_p (loop_iv_base_var, compare_base))
    return;

  /* If loop bound, base and compare bound are all constants, we can
     calculate the probability directly.  */
  if (tree_fits_shwi_p (loop_bound_var)
      && tree_fits_shwi_p (compare_var)
      && tree_fits_shwi_p (compare_base))
    {
      int probability;
      bool overflow, overall_overflow = false;
      widest_int compare_count, tem;

      /* (loop_bound - base) / compare_step */
      tem = wi::sub (wi::to_widest (loop_bound_var),
		     wi::to_widest (compare_base), SIGNED, &overflow);
      overall_overflow |= overflow;
      widest_int loop_count = wi::div_trunc (tem,
					     wi::to_widest (compare_step_var),
					     SIGNED, &overflow);
      overall_overflow |= overflow;

      if (!wi::neg_p (wi::to_widest (compare_step_var))
          ^ (compare_code == LT_EXPR || compare_code == LE_EXPR))
	{
	  /* (loop_bound - compare_bound) / compare_step */
	  tem = wi::sub (wi::to_widest (loop_bound_var),
			 wi::to_widest (compare_var), SIGNED, &overflow);
	  overall_overflow |= overflow;
	  compare_count = wi::div_trunc (tem, wi::to_widest (compare_step_var),
					 SIGNED, &overflow);
	  overall_overflow |= overflow;
	}
      else
        {
	  /* (compare_bound - base) / compare_step */
	  tem = wi::sub (wi::to_widest (compare_var),
			 wi::to_widest (compare_base), SIGNED, &overflow);
	  overall_overflow |= overflow;
          compare_count = wi::div_trunc (tem, wi::to_widest (compare_step_var),
					 SIGNED, &overflow);
	  overall_overflow |= overflow;
	}
      if (compare_code == LE_EXPR || compare_code == GE_EXPR)
	++compare_count;
      if (loop_bound_code == LE_EXPR || loop_bound_code == GE_EXPR)
	++loop_count;
      if (wi::neg_p (compare_count))
        compare_count = 0;
      if (wi::neg_p (loop_count))
        loop_count = 0;
      if (loop_count == 0)
	probability = 0;
      else if (wi::cmps (compare_count, loop_count) == 1)
	probability = REG_BR_PROB_BASE;
      else
        {
	  tem = compare_count * REG_BR_PROB_BASE;
	  tem = wi::udiv_trunc (tem, loop_count);
	  probability = tem.to_uhwi ();
	}

      if (!overall_overflow)
        predict_edge (then_edge, PRED_LOOP_IV_COMPARE, probability);

      return;
    }

  if (expr_coherent_p (loop_bound_var, compare_var))
    {
      if ((loop_bound_code == LT_EXPR || loop_bound_code == LE_EXPR)
	  && (compare_code == LT_EXPR || compare_code == LE_EXPR))
	predict_edge_def (then_edge, PRED_LOOP_IV_COMPARE_GUESS, TAKEN);
      else if ((loop_bound_code == GT_EXPR || loop_bound_code == GE_EXPR)
	       && (compare_code == GT_EXPR || compare_code == GE_EXPR))
	predict_edge_def (then_edge, PRED_LOOP_IV_COMPARE_GUESS, TAKEN);
      else if (loop_bound_code == NE_EXPR)
	{
	  /* If the loop backedge condition is "(i != bound)", we do
	     the comparison based on the step of IV:
	     * step < 0 : backedge condition is like (i > bound)
	     * step > 0 : backedge condition is like (i < bound)  */
	  gcc_assert (loop_bound_step != 0);
	  if (loop_bound_step > 0
	      && (compare_code == LT_EXPR
		  || compare_code == LE_EXPR))
	    predict_edge_def (then_edge, PRED_LOOP_IV_COMPARE_GUESS, TAKEN);
	  else if (loop_bound_step < 0
		   && (compare_code == GT_EXPR
		       || compare_code == GE_EXPR))
	    predict_edge_def (then_edge, PRED_LOOP_IV_COMPARE_GUESS, TAKEN);
	  else
	    predict_edge_def (then_edge, PRED_LOOP_IV_COMPARE_GUESS, NOT_TAKEN);
	}
      else
	/* The branch is predicted not-taken if loop_bound_code is
	   opposite with compare_code.  */
	predict_edge_def (then_edge, PRED_LOOP_IV_COMPARE_GUESS, NOT_TAKEN);
    }
  else if (expr_coherent_p (loop_iv_base_var, compare_var))
    {
      /* For cases like:
	   for (i = s; i < h; i++)
	     if (i > s + 2) ....
	 The branch should be predicted taken.  */
      if (loop_bound_step > 0
	  && (compare_code == GT_EXPR || compare_code == GE_EXPR))
	predict_edge_def (then_edge, PRED_LOOP_IV_COMPARE_GUESS, TAKEN);
      else if (loop_bound_step < 0
	       && (compare_code == LT_EXPR || compare_code == LE_EXPR))
	predict_edge_def (then_edge, PRED_LOOP_IV_COMPARE_GUESS, TAKEN);
      else
	predict_edge_def (then_edge, PRED_LOOP_IV_COMPARE_GUESS, NOT_TAKEN);
    }
}

/* Predict for extra loop exits that will lead to EXIT_EDGE. The extra loop
   exits are resulted from short-circuit conditions that will generate an
   if_tmp. E.g.:

   if (foo() || global > 10)
     break;

   This will be translated into:

   BB3:
     loop header...
   BB4:
     if foo() goto BB6 else goto BB5
   BB5:
     if global > 10 goto BB6 else goto BB7
   BB6:
     goto BB7
   BB7:
     iftmp = (PHI 0(BB5), 1(BB6))
     if iftmp == 1 goto BB8 else goto BB3
   BB8:
     outside of the loop...

   The edge BB7->BB8 is loop exit because BB8 is outside of the loop.
   From the dataflow, we can infer that BB4->BB6 and BB5->BB6 are also loop
   exits. This function takes BB7->BB8 as input, and finds out the extra loop
   exits to predict them using PRED_LOOP_EXIT.  */

static void
predict_extra_loop_exits (edge exit_edge)
{
  unsigned i;
  bool check_value_one;
  gimple *lhs_def_stmt;
  gphi *phi_stmt;
  tree cmp_rhs, cmp_lhs;
  gimple *last;
  gcond *cmp_stmt;

  last = last_stmt (exit_edge->src);
  if (!last)
    return;
  cmp_stmt = dyn_cast <gcond *> (last);
  if (!cmp_stmt)
    return;

  cmp_rhs = gimple_cond_rhs (cmp_stmt);
  cmp_lhs = gimple_cond_lhs (cmp_stmt);
  if (!TREE_CONSTANT (cmp_rhs)
      || !(integer_zerop (cmp_rhs) || integer_onep (cmp_rhs)))
    return;
  if (TREE_CODE (cmp_lhs) != SSA_NAME)
    return;

  /* If check_value_one is true, only the phi_args with value '1' will lead
     to loop exit. Otherwise, only the phi_args with value '0' will lead to
     loop exit.  */
  check_value_one = (((integer_onep (cmp_rhs))
		    ^ (gimple_cond_code (cmp_stmt) == EQ_EXPR))
		    ^ ((exit_edge->flags & EDGE_TRUE_VALUE) != 0));

  lhs_def_stmt = SSA_NAME_DEF_STMT (cmp_lhs);
  if (!lhs_def_stmt)
    return;

  phi_stmt = dyn_cast <gphi *> (lhs_def_stmt);
  if (!phi_stmt)
    return;

  for (i = 0; i < gimple_phi_num_args (phi_stmt); i++)
    {
      edge e1;
      edge_iterator ei;
      tree val = gimple_phi_arg_def (phi_stmt, i);
      edge e = gimple_phi_arg_edge (phi_stmt, i);

      if (!TREE_CONSTANT (val) || !(integer_zerop (val) || integer_onep (val)))
	continue;
      if ((check_value_one ^ integer_onep (val)) == 1)
	continue;
      if (EDGE_COUNT (e->src->succs) != 1)
	{
	  predict_paths_leading_to_edge (e, PRED_LOOP_EXIT, NOT_TAKEN);
	  continue;
	}

      FOR_EACH_EDGE (e1, ei, e->src->preds)
	predict_paths_leading_to_edge (e1, PRED_LOOP_EXIT, NOT_TAKEN);
    }
}

/* Predict edge probabilities by exploiting loop structure.  */

static void
predict_loops (void)
{
  struct loop *loop;

  /* Try to predict out blocks in a loop that are not part of a
     natural loop.  */
  FOR_EACH_LOOP (loop, 0)
    {
      basic_block bb, *bbs;
      unsigned j, n_exits;
      vec<edge> exits;
      struct tree_niter_desc niter_desc;
      edge ex;
      struct nb_iter_bound *nb_iter;
      enum tree_code loop_bound_code = ERROR_MARK;
      tree loop_bound_step = NULL;
      tree loop_bound_var = NULL;
      tree loop_iv_base = NULL;
      gcond *stmt = NULL;

      exits = get_loop_exit_edges (loop);
      n_exits = exits.length ();
      if (!n_exits)
	{
          exits.release ();
	  continue;
	}

      FOR_EACH_VEC_ELT (exits, j, ex)
	{
	  tree niter = NULL;
	  HOST_WIDE_INT nitercst;
	  int max = PARAM_VALUE (PARAM_MAX_PREDICTED_ITERATIONS);
	  int probability;
	  enum br_predictor predictor;

	  predict_extra_loop_exits (ex);

	  if (number_of_iterations_exit (loop, ex, &niter_desc, false, false))
	    niter = niter_desc.niter;
	  if (!niter || TREE_CODE (niter_desc.niter) != INTEGER_CST)
	    niter = loop_niter_by_eval (loop, ex);

	  if (TREE_CODE (niter) == INTEGER_CST)
	    {
	      if (tree_fits_uhwi_p (niter)
		  && max
		  && compare_tree_int (niter, max - 1) == -1)
		nitercst = tree_to_uhwi (niter) + 1;
	      else
		nitercst = max;
	      predictor = PRED_LOOP_ITERATIONS;
	    }
	  /* If we have just one exit and we can derive some information about
	     the number of iterations of the loop from the statements inside
	     the loop, use it to predict this exit.  */
	  else if (n_exits == 1)
	    {
	      nitercst = estimated_stmt_executions_int (loop);
	      if (nitercst < 0)
		continue;
	      if (nitercst > max)
		nitercst = max;

	      predictor = PRED_LOOP_ITERATIONS_GUESSED;
	    }
	  else
	    continue;

	  /* If the prediction for number of iterations is zero, do not
	     predict the exit edges.  */
	  if (nitercst == 0)
	    continue;

	  probability = ((REG_BR_PROB_BASE + nitercst / 2) / nitercst);
	  predict_edge (ex, predictor, probability);
	}
      exits.release ();

      /* Find information about loop bound variables.  */
      for (nb_iter = loop->bounds; nb_iter;
	   nb_iter = nb_iter->next)
	if (nb_iter->stmt
	    && gimple_code (nb_iter->stmt) == GIMPLE_COND)
	  {
	    stmt = as_a <gcond *> (nb_iter->stmt);
	    break;
	  }
      if (!stmt && last_stmt (loop->header)
	  && gimple_code (last_stmt (loop->header)) == GIMPLE_COND)
	stmt = as_a <gcond *> (last_stmt (loop->header));
      if (stmt)
	is_comparison_with_loop_invariant_p (stmt, loop,
					     &loop_bound_var,
					     &loop_bound_code,
					     &loop_bound_step,
					     &loop_iv_base);

      bbs = get_loop_body (loop);

      for (j = 0; j < loop->num_nodes; j++)
	{
	  int header_found = 0;
	  edge e;
	  edge_iterator ei;

	  bb = bbs[j];

	  /* Bypass loop heuristics on continue statement.  These
	     statements construct loops via "non-loop" constructs
	     in the source language and are better to be handled
	     separately.  */
	  if (predicted_by_p (bb, PRED_CONTINUE))
	    continue;

	  /* Loop branch heuristics - predict an edge back to a
	     loop's head as taken.  */
	  if (bb == loop->latch)
	    {
	      e = find_edge (loop->latch, loop->header);
	      if (e)
		{
		  header_found = 1;
		  predict_edge_def (e, PRED_LOOP_BRANCH, TAKEN);
		}
	    }

	  /* Loop exit heuristics - predict an edge exiting the loop if the
	     conditional has no loop header successors as not taken.  */
	  if (!header_found
	      /* If we already used more reliable loop exit predictors, do not
		 bother with PRED_LOOP_EXIT.  */
	      && !predicted_by_p (bb, PRED_LOOP_ITERATIONS_GUESSED)
	      && !predicted_by_p (bb, PRED_LOOP_ITERATIONS))
	    {
	      /* For loop with many exits we don't want to predict all exits
	         with the pretty large probability, because if all exits are
		 considered in row, the loop would be predicted to iterate
		 almost never.  The code to divide probability by number of
		 exits is very rough.  It should compute the number of exits
		 taken in each patch through function (not the overall number
		 of exits that might be a lot higher for loops with wide switch
		 statements in them) and compute n-th square root.

		 We limit the minimal probability by 2% to avoid
		 EDGE_PROBABILITY_RELIABLE from trusting the branch prediction
		 as this was causing regression in perl benchmark containing such
		 a wide loop.  */

	      int probability = ((REG_BR_PROB_BASE
		                  - predictor_info [(int) PRED_LOOP_EXIT].hitrate)
				 / n_exits);
	      if (probability < HITRATE (2))
		probability = HITRATE (2);
	      FOR_EACH_EDGE (e, ei, bb->succs)
		if (e->dest->index < NUM_FIXED_BLOCKS
		    || !flow_bb_inside_loop_p (loop, e->dest))
		  predict_edge (e, PRED_LOOP_EXIT, probability);
	    }
	  if (loop_bound_var)
	    predict_iv_comparison (loop, bb, loop_bound_var, loop_iv_base,
				   loop_bound_code,
				   tree_to_shwi (loop_bound_step));
	}

      /* Free basic blocks from get_loop_body.  */
      free (bbs);
    }
}

/* Attempt to predict probabilities of BB outgoing edges using local
   properties.  */
static void
bb_estimate_probability_locally (basic_block bb)
{
  rtx_insn *last_insn = BB_END (bb);
  rtx cond;

  if (! can_predict_insn_p (last_insn))
    return;
  cond = get_condition (last_insn, NULL, false, false);
  if (! cond)
    return;

  /* Try "pointer heuristic."
     A comparison ptr == 0 is predicted as false.
     Similarly, a comparison ptr1 == ptr2 is predicted as false.  */
  if (COMPARISON_P (cond)
      && ((REG_P (XEXP (cond, 0)) && REG_POINTER (XEXP (cond, 0)))
	  || (REG_P (XEXP (cond, 1)) && REG_POINTER (XEXP (cond, 1)))))
    {
      if (GET_CODE (cond) == EQ)
	predict_insn_def (last_insn, PRED_POINTER, NOT_TAKEN);
      else if (GET_CODE (cond) == NE)
	predict_insn_def (last_insn, PRED_POINTER, TAKEN);
    }
  else

  /* Try "opcode heuristic."
     EQ tests are usually false and NE tests are usually true. Also,
     most quantities are positive, so we can make the appropriate guesses
     about signed comparisons against zero.  */
    switch (GET_CODE (cond))
      {
      case CONST_INT:
	/* Unconditional branch.  */
	predict_insn_def (last_insn, PRED_UNCONDITIONAL,
			  cond == const0_rtx ? NOT_TAKEN : TAKEN);
	break;

      case EQ:
      case UNEQ:
	/* Floating point comparisons appears to behave in a very
	   unpredictable way because of special role of = tests in
	   FP code.  */
	if (FLOAT_MODE_P (GET_MODE (XEXP (cond, 0))))
	  ;
	/* Comparisons with 0 are often used for booleans and there is
	   nothing useful to predict about them.  */
	else if (XEXP (cond, 1) == const0_rtx
		 || XEXP (cond, 0) == const0_rtx)
	  ;
	else
	  predict_insn_def (last_insn, PRED_OPCODE_NONEQUAL, NOT_TAKEN);
	break;

      case NE:
      case LTGT:
	/* Floating point comparisons appears to behave in a very
	   unpredictable way because of special role of = tests in
	   FP code.  */
	if (FLOAT_MODE_P (GET_MODE (XEXP (cond, 0))))
	  ;
	/* Comparisons with 0 are often used for booleans and there is
	   nothing useful to predict about them.  */
	else if (XEXP (cond, 1) == const0_rtx
		 || XEXP (cond, 0) == const0_rtx)
	  ;
	else
	  predict_insn_def (last_insn, PRED_OPCODE_NONEQUAL, TAKEN);
	break;

      case ORDERED:
	predict_insn_def (last_insn, PRED_FPOPCODE, TAKEN);
	break;

      case UNORDERED:
	predict_insn_def (last_insn, PRED_FPOPCODE, NOT_TAKEN);
	break;

      case LE:
      case LT:
	if (XEXP (cond, 1) == const0_rtx || XEXP (cond, 1) == const1_rtx
	    || XEXP (cond, 1) == constm1_rtx)
	  predict_insn_def (last_insn, PRED_OPCODE_POSITIVE, NOT_TAKEN);
	break;

      case GE:
      case GT:
	if (XEXP (cond, 1) == const0_rtx || XEXP (cond, 1) == const1_rtx
	    || XEXP (cond, 1) == constm1_rtx)
	  predict_insn_def (last_insn, PRED_OPCODE_POSITIVE, TAKEN);
	break;

      default:
	break;
      }
}

/* Set edge->probability for each successor edge of BB.  */
void
guess_outgoing_edge_probabilities (basic_block bb)
{
  bb_estimate_probability_locally (bb);
  combine_predictions_for_insn (BB_END (bb), bb);
}

static tree expr_expected_value (tree, bitmap, enum br_predictor *predictor);

/* Helper function for expr_expected_value.  */

static tree
expr_expected_value_1 (tree type, tree op0, enum tree_code code,
		       tree op1, bitmap visited, enum br_predictor *predictor)
{
  gimple *def;

  if (predictor)
    *predictor = PRED_UNCONDITIONAL;

  if (get_gimple_rhs_class (code) == GIMPLE_SINGLE_RHS)
    {
      if (TREE_CONSTANT (op0))
	return op0;

      if (code != SSA_NAME)
	return NULL_TREE;

      def = SSA_NAME_DEF_STMT (op0);

      /* If we were already here, break the infinite cycle.  */
      if (!bitmap_set_bit (visited, SSA_NAME_VERSION (op0)))
	return NULL;

      if (gimple_code (def) == GIMPLE_PHI)
	{
	  /* All the arguments of the PHI node must have the same constant
	     length.  */
	  int i, n = gimple_phi_num_args (def);
	  tree val = NULL, new_val;

	  for (i = 0; i < n; i++)
	    {
	      tree arg = PHI_ARG_DEF (def, i);
	      enum br_predictor predictor2;

	      /* If this PHI has itself as an argument, we cannot
		 determine the string length of this argument.  However,
		 if we can find an expected constant value for the other
		 PHI args then we can still be sure that this is
		 likely a constant.  So be optimistic and just
		 continue with the next argument.  */
	      if (arg == PHI_RESULT (def))
		continue;

	      new_val = expr_expected_value (arg, visited, &predictor2);

	      /* It is difficult to combine value predictors.  Simply assume
		 that later predictor is weaker and take its prediction.  */
	      if (predictor && *predictor < predictor2)
		*predictor = predictor2;
	      if (!new_val)
		return NULL;
	      if (!val)
		val = new_val;
	      else if (!operand_equal_p (val, new_val, false))
		return NULL;
	    }
	  return val;
	}
      if (is_gimple_assign (def))
	{
	  if (gimple_assign_lhs (def) != op0)
	    return NULL;

	  return expr_expected_value_1 (TREE_TYPE (gimple_assign_lhs (def)),
					gimple_assign_rhs1 (def),
					gimple_assign_rhs_code (def),
					gimple_assign_rhs2 (def),
					visited, predictor);
	}

      if (is_gimple_call (def))
	{
	  tree decl = gimple_call_fndecl (def);
	  if (!decl)
	    {
	      if (gimple_call_internal_p (def)
		  && gimple_call_internal_fn (def) == IFN_BUILTIN_EXPECT)
		{
		  gcc_assert (gimple_call_num_args (def) == 3);
		  tree val = gimple_call_arg (def, 0);
		  if (TREE_CONSTANT (val))
		    return val;
		  if (predictor)
		    {
		      tree val2 = gimple_call_arg (def, 2);
		      gcc_assert (TREE_CODE (val2) == INTEGER_CST
				  && tree_fits_uhwi_p (val2)
				  && tree_to_uhwi (val2) < END_PREDICTORS);
		      *predictor = (enum br_predictor) tree_to_uhwi (val2);
		    }
		  return gimple_call_arg (def, 1);
		}
	      return NULL;
	    }
	  if (DECL_BUILT_IN_CLASS (decl) == BUILT_IN_NORMAL)
	    switch (DECL_FUNCTION_CODE (decl))
	      {
	      case BUILT_IN_EXPECT:
		{
		  tree val;
		  if (gimple_call_num_args (def) != 2)
		    return NULL;
		  val = gimple_call_arg (def, 0);
		  if (TREE_CONSTANT (val))
		    return val;
		  if (predictor)
		    *predictor = PRED_BUILTIN_EXPECT;
		  return gimple_call_arg (def, 1);
		}

	      case BUILT_IN_SYNC_BOOL_COMPARE_AND_SWAP_N:
	      case BUILT_IN_SYNC_BOOL_COMPARE_AND_SWAP_1:
	      case BUILT_IN_SYNC_BOOL_COMPARE_AND_SWAP_2:
	      case BUILT_IN_SYNC_BOOL_COMPARE_AND_SWAP_4:
	      case BUILT_IN_SYNC_BOOL_COMPARE_AND_SWAP_8:
	      case BUILT_IN_SYNC_BOOL_COMPARE_AND_SWAP_16:
	      case BUILT_IN_ATOMIC_COMPARE_EXCHANGE:
	      case BUILT_IN_ATOMIC_COMPARE_EXCHANGE_N:
	      case BUILT_IN_ATOMIC_COMPARE_EXCHANGE_1:
	      case BUILT_IN_ATOMIC_COMPARE_EXCHANGE_2:
	      case BUILT_IN_ATOMIC_COMPARE_EXCHANGE_4:
	      case BUILT_IN_ATOMIC_COMPARE_EXCHANGE_8:
	      case BUILT_IN_ATOMIC_COMPARE_EXCHANGE_16:
		/* Assume that any given atomic operation has low contention,
		   and thus the compare-and-swap operation succeeds.  */
		if (predictor)
		  *predictor = PRED_COMPARE_AND_SWAP;
		return boolean_true_node;
	      default:
		break;
	    }
	}

      return NULL;
    }

  if (get_gimple_rhs_class (code) == GIMPLE_BINARY_RHS)
    {
      tree res;
      enum br_predictor predictor2;
      op0 = expr_expected_value (op0, visited, predictor);
      if (!op0)
	return NULL;
      op1 = expr_expected_value (op1, visited, &predictor2);
      if (predictor && *predictor < predictor2)
	*predictor = predictor2;
      if (!op1)
	return NULL;
      res = fold_build2 (code, type, op0, op1);
      if (TREE_CONSTANT (res))
	return res;
      return NULL;
    }
  if (get_gimple_rhs_class (code) == GIMPLE_UNARY_RHS)
    {
      tree res;
      op0 = expr_expected_value (op0, visited, predictor);
      if (!op0)
	return NULL;
      res = fold_build1 (code, type, op0);
      if (TREE_CONSTANT (res))
	return res;
      return NULL;
    }
  return NULL;
}

/* Return constant EXPR will likely have at execution time, NULL if unknown.
   The function is used by builtin_expect branch predictor so the evidence
   must come from this construct and additional possible constant folding.

   We may want to implement more involved value guess (such as value range
   propagation based prediction), but such tricks shall go to new
   implementation.  */

static tree
expr_expected_value (tree expr, bitmap visited,
		     enum br_predictor *predictor)
{
  enum tree_code code;
  tree op0, op1;

  if (TREE_CONSTANT (expr))
    {
      if (predictor)
	*predictor = PRED_UNCONDITIONAL;
      return expr;
    }

  extract_ops_from_tree (expr, &code, &op0, &op1);
  return expr_expected_value_1 (TREE_TYPE (expr),
				op0, code, op1, visited, predictor);
}

/* Predict using opcode of the last statement in basic block.  */
static void
tree_predict_by_opcode (basic_block bb)
{
  gimple *stmt = last_stmt (bb);
  edge then_edge;
  tree op0, op1;
  tree type;
  tree val;
  enum tree_code cmp;
  bitmap visited;
  edge_iterator ei;
  enum br_predictor predictor;

  if (!stmt || gimple_code (stmt) != GIMPLE_COND)
    return;
  FOR_EACH_EDGE (then_edge, ei, bb->succs)
    if (then_edge->flags & EDGE_TRUE_VALUE)
      break;
  op0 = gimple_cond_lhs (stmt);
  op1 = gimple_cond_rhs (stmt);
  cmp = gimple_cond_code (stmt);
  type = TREE_TYPE (op0);
  visited = BITMAP_ALLOC (NULL);
  val = expr_expected_value_1 (boolean_type_node, op0, cmp, op1, visited,
			       &predictor);
  BITMAP_FREE (visited);
  if (val && TREE_CODE (val) == INTEGER_CST)
    {
      if (predictor == PRED_BUILTIN_EXPECT)
	{
	  int percent = PARAM_VALUE (BUILTIN_EXPECT_PROBABILITY);

	  gcc_assert (percent >= 0 && percent <= 100);
	  if (integer_zerop (val))
	    percent = 100 - percent;
	  predict_edge (then_edge, PRED_BUILTIN_EXPECT, HITRATE (percent));
	}
      else
	predict_edge (then_edge, predictor,
		      integer_zerop (val) ? NOT_TAKEN : TAKEN);
    }
  /* Try "pointer heuristic."
     A comparison ptr == 0 is predicted as false.
     Similarly, a comparison ptr1 == ptr2 is predicted as false.  */
  if (POINTER_TYPE_P (type))
    {
      if (cmp == EQ_EXPR)
	predict_edge_def (then_edge, PRED_TREE_POINTER, NOT_TAKEN);
      else if (cmp == NE_EXPR)
	predict_edge_def (then_edge, PRED_TREE_POINTER, TAKEN);
    }
  else

  /* Try "opcode heuristic."
     EQ tests are usually false and NE tests are usually true. Also,
     most quantities are positive, so we can make the appropriate guesses
     about signed comparisons against zero.  */
    switch (cmp)
      {
      case EQ_EXPR:
      case UNEQ_EXPR:
	/* Floating point comparisons appears to behave in a very
	   unpredictable way because of special role of = tests in
	   FP code.  */
	if (FLOAT_TYPE_P (type))
	  ;
	/* Comparisons with 0 are often used for booleans and there is
	   nothing useful to predict about them.  */
	else if (integer_zerop (op0) || integer_zerop (op1))
	  ;
	else
	  predict_edge_def (then_edge, PRED_TREE_OPCODE_NONEQUAL, NOT_TAKEN);
	break;

      case NE_EXPR:
      case LTGT_EXPR:
	/* Floating point comparisons appears to behave in a very
	   unpredictable way because of special role of = tests in
	   FP code.  */
	if (FLOAT_TYPE_P (type))
	  ;
	/* Comparisons with 0 are often used for booleans and there is
	   nothing useful to predict about them.  */
	else if (integer_zerop (op0)
		 || integer_zerop (op1))
	  ;
	else
	  predict_edge_def (then_edge, PRED_TREE_OPCODE_NONEQUAL, TAKEN);
	break;

      case ORDERED_EXPR:
	predict_edge_def (then_edge, PRED_TREE_FPOPCODE, TAKEN);
	break;

      case UNORDERED_EXPR:
	predict_edge_def (then_edge, PRED_TREE_FPOPCODE, NOT_TAKEN);
	break;

      case LE_EXPR:
      case LT_EXPR:
	if (integer_zerop (op1)
	    || integer_onep (op1)
	    || integer_all_onesp (op1)
	    || real_zerop (op1)
	    || real_onep (op1)
	    || real_minus_onep (op1))
	  predict_edge_def (then_edge, PRED_TREE_OPCODE_POSITIVE, NOT_TAKEN);
	break;

      case GE_EXPR:
      case GT_EXPR:
	if (integer_zerop (op1)
	    || integer_onep (op1)
	    || integer_all_onesp (op1)
	    || real_zerop (op1)
	    || real_onep (op1)
	    || real_minus_onep (op1))
	  predict_edge_def (then_edge, PRED_TREE_OPCODE_POSITIVE, TAKEN);
	break;

      default:
	break;
      }
}

/* Try to guess whether the value of return means error code.  */

static enum br_predictor
return_prediction (tree val, enum prediction *prediction)
{
  /* VOID.  */
  if (!val)
    return PRED_NO_PREDICTION;
  /* Different heuristics for pointers and scalars.  */
  if (POINTER_TYPE_P (TREE_TYPE (val)))
    {
      /* NULL is usually not returned.  */
      if (integer_zerop (val))
	{
	  *prediction = NOT_TAKEN;
	  return PRED_NULL_RETURN;
	}
    }
  else if (INTEGRAL_TYPE_P (TREE_TYPE (val)))
    {
      /* Negative return values are often used to indicate
         errors.  */
      if (TREE_CODE (val) == INTEGER_CST
	  && tree_int_cst_sgn (val) < 0)
	{
	  *prediction = NOT_TAKEN;
	  return PRED_NEGATIVE_RETURN;
	}
      /* Constant return values seems to be commonly taken.
         Zero/one often represent booleans so exclude them from the
	 heuristics.  */
      if (TREE_CONSTANT (val)
	  && (!integer_zerop (val) && !integer_onep (val)))
	{
	  *prediction = TAKEN;
	  return PRED_CONST_RETURN;
	}
    }
  return PRED_NO_PREDICTION;
}

/* Find the basic block with return expression and look up for possible
   return value trying to apply RETURN_PREDICTION heuristics.  */
static void
apply_return_prediction (void)
{
  greturn *return_stmt = NULL;
  tree return_val;
  edge e;
  gphi *phi;
  int phi_num_args, i;
  enum br_predictor pred;
  enum prediction direction;
  edge_iterator ei;

  FOR_EACH_EDGE (e, ei, EXIT_BLOCK_PTR_FOR_FN (cfun)->preds)
    {
      gimple *last = last_stmt (e->src);
      if (last
	  && gimple_code (last) == GIMPLE_RETURN)
	{
	  return_stmt = as_a <greturn *> (last);
	  break;
	}
    }
  if (!e)
    return;
  return_val = gimple_return_retval (return_stmt);
  if (!return_val)
    return;
  if (TREE_CODE (return_val) != SSA_NAME
      || !SSA_NAME_DEF_STMT (return_val)
      || gimple_code (SSA_NAME_DEF_STMT (return_val)) != GIMPLE_PHI)
    return;
  phi = as_a <gphi *> (SSA_NAME_DEF_STMT (return_val));
  phi_num_args = gimple_phi_num_args (phi);
  pred = return_prediction (PHI_ARG_DEF (phi, 0), &direction);

  /* Avoid the degenerate case where all return values form the function
     belongs to same category (ie they are all positive constants)
     so we can hardly say something about them.  */
  for (i = 1; i < phi_num_args; i++)
    if (pred != return_prediction (PHI_ARG_DEF (phi, i), &direction))
      break;
  if (i != phi_num_args)
    for (i = 0; i < phi_num_args; i++)
      {
	pred = return_prediction (PHI_ARG_DEF (phi, i), &direction);
	if (pred != PRED_NO_PREDICTION)
	  predict_paths_leading_to_edge (gimple_phi_arg_edge (phi, i), pred,
				         direction);
      }
}

/* Look for basic block that contains unlikely to happen events
   (such as noreturn calls) and mark all paths leading to execution
   of this basic blocks as unlikely.  */

static void
tree_bb_level_predictions (void)
{
  basic_block bb;
  bool has_return_edges = false;
  edge e;
  edge_iterator ei;

  FOR_EACH_EDGE (e, ei, EXIT_BLOCK_PTR_FOR_FN (cfun)->preds)
    if (!(e->flags & (EDGE_ABNORMAL | EDGE_FAKE | EDGE_EH)))
      {
        has_return_edges = true;
	break;
      }

  apply_return_prediction ();

  FOR_EACH_BB_FN (bb, cfun)
    {
      gimple_stmt_iterator gsi;

      for (gsi = gsi_start_bb (bb); !gsi_end_p (gsi); gsi_next (&gsi))
	{
	  gimple *stmt = gsi_stmt (gsi);
	  tree decl;

	  if (is_gimple_call (stmt))
	    {
	      if ((gimple_call_flags (stmt) & ECF_NORETURN)
	          && has_return_edges)
		predict_paths_leading_to (bb, PRED_NORETURN,
					  NOT_TAKEN);
	      decl = gimple_call_fndecl (stmt);
	      if (decl
		  && lookup_attribute ("cold",
				       DECL_ATTRIBUTES (decl)))
		predict_paths_leading_to (bb, PRED_COLD_FUNCTION,
					  NOT_TAKEN);
	    }
	  else if (gimple_code (stmt) == GIMPLE_PREDICT)
	    {
	      predict_paths_leading_to (bb, gimple_predict_predictor (stmt),
					gimple_predict_outcome (stmt));
	      /* Keep GIMPLE_PREDICT around so early inlining will propagate
	         hints to callers.  */
	    }
	}
    }
}

/* Callback for hash_map::traverse, asserts that the pointer map is
   empty.  */

bool
assert_is_empty (const_basic_block const &, edge_prediction *const &value,
		 void *)
{
  gcc_assert (!value);
  return false;
}

/* Predict branch probabilities and estimate profile for basic block BB.  */

static void
tree_estimate_probability_bb (basic_block bb)
{
  edge e;
  edge_iterator ei;
  gimple *last;

  FOR_EACH_EDGE (e, ei, bb->succs)
    {
      /* Predict edges to user labels with attributes.  */
      if (e->dest != EXIT_BLOCK_PTR_FOR_FN (cfun))
	{
	  gimple_stmt_iterator gi;
	  for (gi = gsi_start_bb (e->dest); !gsi_end_p (gi); gsi_next (&gi))
	    {
	      glabel *label_stmt = dyn_cast <glabel *> (gsi_stmt (gi));
	      tree decl;

	      if (!label_stmt)
		break;
	      decl = gimple_label_label (label_stmt);
	      if (DECL_ARTIFICIAL (decl))
		continue;

	      /* Finally, we have a user-defined label.  */
	      if (lookup_attribute ("cold", DECL_ATTRIBUTES (decl)))
		predict_edge_def (e, PRED_COLD_LABEL, NOT_TAKEN);
	      else if (lookup_attribute ("hot", DECL_ATTRIBUTES (decl)))
		predict_edge_def (e, PRED_HOT_LABEL, TAKEN);
	    }
	}

      /* Predict early returns to be probable, as we've already taken
	 care for error returns and other cases are often used for
	 fast paths through function.

	 Since we've already removed the return statements, we are
	 looking for CFG like:

	 if (conditional)
	 {
	 ..
	 goto return_block
	 }
	 some other blocks
	 return_block:
	 return_stmt.  */
      if (e->dest != bb->next_bb
	  && e->dest != EXIT_BLOCK_PTR_FOR_FN (cfun)
	  && single_succ_p (e->dest)
	  && single_succ_edge (e->dest)->dest == EXIT_BLOCK_PTR_FOR_FN (cfun)
	  && (last = last_stmt (e->dest)) != NULL
	  && gimple_code (last) == GIMPLE_RETURN)
	{
	  edge e1;
	  edge_iterator ei1;

	  if (single_succ_p (bb))
	    {
	      FOR_EACH_EDGE (e1, ei1, bb->preds)
		if (!predicted_by_p (e1->src, PRED_NULL_RETURN)
		    && !predicted_by_p (e1->src, PRED_CONST_RETURN)
		    && !predicted_by_p (e1->src, PRED_NEGATIVE_RETURN))
		  predict_edge_def (e1, PRED_TREE_EARLY_RETURN, NOT_TAKEN);
	    }
	  else
	    if (!predicted_by_p (e->src, PRED_NULL_RETURN)
		&& !predicted_by_p (e->src, PRED_CONST_RETURN)
		&& !predicted_by_p (e->src, PRED_NEGATIVE_RETURN))
	      predict_edge_def (e, PRED_TREE_EARLY_RETURN, NOT_TAKEN);
	}

      /* Look for block we are guarding (ie we dominate it,
	 but it doesn't postdominate us).  */
      if (e->dest != EXIT_BLOCK_PTR_FOR_FN (cfun) && e->dest != bb
	  && dominated_by_p (CDI_DOMINATORS, e->dest, e->src)
	  && !dominated_by_p (CDI_POST_DOMINATORS, e->src, e->dest))
	{
	  gimple_stmt_iterator bi;

	  /* The call heuristic claims that a guarded function call
	     is improbable.  This is because such calls are often used
	     to signal exceptional situations such as printing error
	     messages.  */
	  for (bi = gsi_start_bb (e->dest); !gsi_end_p (bi);
	       gsi_next (&bi))
	    {
	      gimple *stmt = gsi_stmt (bi);
	      if (is_gimple_call (stmt)
		  /* Constant and pure calls are hardly used to signalize
		     something exceptional.  */
		  && gimple_has_side_effects (stmt))
		{
		  predict_edge_def (e, PRED_CALL, NOT_TAKEN);
		  break;
		}
	    }
	}
    }
  tree_predict_by_opcode (bb);
}

/* Predict branch probabilities and estimate profile of the tree CFG.
   This function can be called from the loop optimizers to recompute
   the profile information.  */

void
tree_estimate_probability (void)
{
  basic_block bb;

  add_noreturn_fake_exit_edges ();
  connect_infinite_loops_to_exit ();
  /* We use loop_niter_by_eval, which requires that the loops have
     preheaders.  */
  create_preheaders (CP_SIMPLE_PREHEADERS);
  calculate_dominance_info (CDI_POST_DOMINATORS);

  bb_predictions = new hash_map<const_basic_block, edge_prediction *>;
  tree_bb_level_predictions ();
  record_loop_exits ();

  if (number_of_loops (cfun) > 1)
    predict_loops ();

  FOR_EACH_BB_FN (bb, cfun)
    tree_estimate_probability_bb (bb);

  FOR_EACH_BB_FN (bb, cfun)
    combine_predictions_for_bb (bb);

  if (flag_checking)
    bb_predictions->traverse<void *, assert_is_empty> (NULL);

  delete bb_predictions;
  bb_predictions = NULL;

  estimate_bb_frequencies (false);
  free_dominance_info (CDI_POST_DOMINATORS);
  remove_fake_exit_edges ();
}

/* Predict edges to successors of CUR whose sources are not postdominated by
   BB by PRED and recurse to all postdominators.  */

static void
predict_paths_for_bb (basic_block cur, basic_block bb,
		      enum br_predictor pred,
		      enum prediction taken,
		      bitmap visited)
{
  edge e;
  edge_iterator ei;
  basic_block son;

  /* We are looking for all edges forming edge cut induced by
     set of all blocks postdominated by BB.  */
  FOR_EACH_EDGE (e, ei, cur->preds)
    if (e->src->index >= NUM_FIXED_BLOCKS
	&& !dominated_by_p (CDI_POST_DOMINATORS, e->src, bb))
    {
      edge e2;
      edge_iterator ei2;
      bool found = false;

      /* Ignore fake edges and eh, we predict them as not taken anyway.  */
      if (e->flags & (EDGE_EH | EDGE_FAKE))
	continue;
      gcc_assert (bb == cur || dominated_by_p (CDI_POST_DOMINATORS, cur, bb));

      /* See if there is an edge from e->src that is not abnormal
	 and does not lead to BB.  */
      FOR_EACH_EDGE (e2, ei2, e->src->succs)
	if (e2 != e
	    && !(e2->flags & (EDGE_EH | EDGE_FAKE))
	    && !dominated_by_p (CDI_POST_DOMINATORS, e2->dest, bb))
	  {
	    found = true;
	    break;
	  }

      /* If there is non-abnormal path leaving e->src, predict edge
	 using predictor.  Otherwise we need to look for paths
	 leading to e->src.

	 The second may lead to infinite loop in the case we are predicitng
	 regions that are only reachable by abnormal edges.  We simply
	 prevent visiting given BB twice.  */
      if (found)
        predict_edge_def (e, pred, taken);
      else if (bitmap_set_bit (visited, e->src->index))
	predict_paths_for_bb (e->src, e->src, pred, taken, visited);
    }
  for (son = first_dom_son (CDI_POST_DOMINATORS, cur);
       son;
       son = next_dom_son (CDI_POST_DOMINATORS, son))
    predict_paths_for_bb (son, bb, pred, taken, visited);
}

/* Sets branch probabilities according to PREDiction and
   FLAGS.  */

static void
predict_paths_leading_to (basic_block bb, enum br_predictor pred,
			  enum prediction taken)
{
  bitmap visited = BITMAP_ALLOC (NULL);
  predict_paths_for_bb (bb, bb, pred, taken, visited);
  BITMAP_FREE (visited);
}

/* Like predict_paths_leading_to but take edge instead of basic block.  */

static void
predict_paths_leading_to_edge (edge e, enum br_predictor pred,
			       enum prediction taken)
{
  bool has_nonloop_edge = false;
  edge_iterator ei;
  edge e2;

  basic_block bb = e->src;
  FOR_EACH_EDGE (e2, ei, bb->succs)
    if (e2->dest != e->src && e2->dest != e->dest
	&& !(e->flags & (EDGE_EH | EDGE_FAKE))
	&& !dominated_by_p (CDI_POST_DOMINATORS, e->src, e2->dest))
      {
	has_nonloop_edge = true;
	break;
      }
  if (!has_nonloop_edge)
    {
      bitmap visited = BITMAP_ALLOC (NULL);
      predict_paths_for_bb (bb, bb, pred, taken, visited);
      BITMAP_FREE (visited);
    }
  else
    predict_edge_def (e, pred, taken);
}

/* This is used to carry information about basic blocks.  It is
   attached to the AUX field of the standard CFG block.  */

struct block_info
{
  /* Estimated frequency of execution of basic_block.  */
  sreal frequency;

  /* To keep queue of basic blocks to process.  */
  basic_block next;

  /* Number of predecessors we need to visit first.  */
  int npredecessors;
};

/* Similar information for edges.  */
struct edge_prob_info
{
  /* In case edge is a loopback edge, the probability edge will be reached
     in case header is.  Estimated number of iterations of the loop can be
     then computed as 1 / (1 - back_edge_prob).  */
  sreal back_edge_prob;
  /* True if the edge is a loopback edge in the natural loop.  */
  unsigned int back_edge:1;
};

#define BLOCK_INFO(B)	((block_info *) (B)->aux)
#undef EDGE_INFO
#define EDGE_INFO(E)	((edge_prob_info *) (E)->aux)

/* Helper function for estimate_bb_frequencies.
   Propagate the frequencies in blocks marked in
   TOVISIT, starting in HEAD.  */

static void
propagate_freq (basic_block head, bitmap tovisit)
{
  basic_block bb;
  basic_block last;
  unsigned i;
  edge e;
  basic_block nextbb;
  bitmap_iterator bi;

  /* For each basic block we need to visit count number of his predecessors
     we need to visit first.  */
  EXECUTE_IF_SET_IN_BITMAP (tovisit, 0, i, bi)
    {
      edge_iterator ei;
      int count = 0;

      bb = BASIC_BLOCK_FOR_FN (cfun, i);

      FOR_EACH_EDGE (e, ei, bb->preds)
	{
	  bool visit = bitmap_bit_p (tovisit, e->src->index);

	  if (visit && !(e->flags & EDGE_DFS_BACK))
	    count++;
	  else if (visit && dump_file && !EDGE_INFO (e)->back_edge)
	    fprintf (dump_file,
		     "Irreducible region hit, ignoring edge to %i->%i\n",
		     e->src->index, bb->index);
	}
      BLOCK_INFO (bb)->npredecessors = count;
      /* When function never returns, we will never process exit block.  */
      if (!count && bb == EXIT_BLOCK_PTR_FOR_FN (cfun))
	bb->count = bb->frequency = 0;
    }

  BLOCK_INFO (head)->frequency = 1;
  last = head;
  for (bb = head; bb; bb = nextbb)
    {
      edge_iterator ei;
      sreal cyclic_probability = 0;
      sreal frequency = 0;

      nextbb = BLOCK_INFO (bb)->next;
      BLOCK_INFO (bb)->next = NULL;

      /* Compute frequency of basic block.  */
      if (bb != head)
	{
	  if (flag_checking)
	    FOR_EACH_EDGE (e, ei, bb->preds)
	      gcc_assert (!bitmap_bit_p (tovisit, e->src->index)
			  || (e->flags & EDGE_DFS_BACK));

	  FOR_EACH_EDGE (e, ei, bb->preds)
	    if (EDGE_INFO (e)->back_edge)
	      {
		cyclic_probability += EDGE_INFO (e)->back_edge_prob;
	      }
	    else if (!(e->flags & EDGE_DFS_BACK))
	      {
		/*  frequency += (e->probability
				  * BLOCK_INFO (e->src)->frequency /
				  REG_BR_PROB_BASE);  */

		sreal tmp = e->probability;
		tmp *= BLOCK_INFO (e->src)->frequency;
		tmp *= real_inv_br_prob_base;
		frequency += tmp;
	      }

	  if (cyclic_probability == 0)
	    {
	      BLOCK_INFO (bb)->frequency = frequency;
	    }
	  else
	    {
	      if (cyclic_probability > real_almost_one)
		cyclic_probability = real_almost_one;

	      /* BLOCK_INFO (bb)->frequency = frequency
					      / (1 - cyclic_probability) */

	      cyclic_probability = sreal (1) - cyclic_probability;
	      BLOCK_INFO (bb)->frequency = frequency / cyclic_probability;
	    }
	}

      bitmap_clear_bit (tovisit, bb->index);

      e = find_edge (bb, head);
      if (e)
	{
	  /* EDGE_INFO (e)->back_edge_prob
	     = ((e->probability * BLOCK_INFO (bb)->frequency)
	     / REG_BR_PROB_BASE); */

	  sreal tmp = e->probability;
	  tmp *= BLOCK_INFO (bb)->frequency;
	  EDGE_INFO (e)->back_edge_prob = tmp * real_inv_br_prob_base;
	}

      /* Propagate to successor blocks.  */
      FOR_EACH_EDGE (e, ei, bb->succs)
	if (!(e->flags & EDGE_DFS_BACK)
	    && BLOCK_INFO (e->dest)->npredecessors)
	  {
	    BLOCK_INFO (e->dest)->npredecessors--;
	    if (!BLOCK_INFO (e->dest)->npredecessors)
	      {
		if (!nextbb)
		  nextbb = e->dest;
		else
		  BLOCK_INFO (last)->next = e->dest;

		last = e->dest;
	      }
	  }
    }
}

/* Estimate frequencies in loops at same nest level.  */

static void
estimate_loops_at_level (struct loop *first_loop)
{
  struct loop *loop;

  for (loop = first_loop; loop; loop = loop->next)
    {
      edge e;
      basic_block *bbs;
      unsigned i;
      bitmap tovisit = BITMAP_ALLOC (NULL);

      estimate_loops_at_level (loop->inner);

      /* Find current loop back edge and mark it.  */
      e = loop_latch_edge (loop);
      EDGE_INFO (e)->back_edge = 1;

      bbs = get_loop_body (loop);
      for (i = 0; i < loop->num_nodes; i++)
	bitmap_set_bit (tovisit, bbs[i]->index);
      free (bbs);
      propagate_freq (loop->header, tovisit);
      BITMAP_FREE (tovisit);
    }
}

/* Propagates frequencies through structure of loops.  */

static void
estimate_loops (void)
{
  bitmap tovisit = BITMAP_ALLOC (NULL);
  basic_block bb;

  /* Start by estimating the frequencies in the loops.  */
  if (number_of_loops (cfun) > 1)
    estimate_loops_at_level (current_loops->tree_root->inner);

  /* Now propagate the frequencies through all the blocks.  */
  FOR_ALL_BB_FN (bb, cfun)
    {
      bitmap_set_bit (tovisit, bb->index);
    }
  propagate_freq (ENTRY_BLOCK_PTR_FOR_FN (cfun), tovisit);
  BITMAP_FREE (tovisit);
}

/* Drop the profile for NODE to guessed, and update its frequency based on
   whether it is expected to be hot given the CALL_COUNT.  */

static void
drop_profile (struct cgraph_node *node, gcov_type call_count)
{
  struct function *fn = DECL_STRUCT_FUNCTION (node->decl);
  /* In the case where this was called by another function with a
     dropped profile, call_count will be 0. Since there are no
     non-zero call counts to this function, we don't know for sure
     whether it is hot, and therefore it will be marked normal below.  */
  bool hot = maybe_hot_count_p (NULL, call_count);

  if (dump_file)
    fprintf (dump_file,
             "Dropping 0 profile for %s/%i. %s based on calls.\n",
             node->name (), node->order,
             hot ? "Function is hot" : "Function is normal");
  /* We only expect to miss profiles for functions that are reached
     via non-zero call edges in cases where the function may have
     been linked from another module or library (COMDATs and extern
     templates). See the comments below for handle_missing_profiles.
     Also, only warn in cases where the missing counts exceed the
     number of training runs. In certain cases with an execv followed
     by a no-return call the profile for the no-return call is not
     dumped and there can be a mismatch.  */
  if (!DECL_COMDAT (node->decl) && !DECL_EXTERNAL (node->decl)
      && call_count > profile_info->runs)
    {
      if (flag_profile_correction)
        {
          if (dump_file)
            fprintf (dump_file,
                     "Missing counts for called function %s/%i\n",
                     node->name (), node->order);
        }
      else
        warning (0, "Missing counts for called function %s/%i",
                 node->name (), node->order);
    }

  profile_status_for_fn (fn)
      = (flag_guess_branch_prob ? PROFILE_GUESSED : PROFILE_ABSENT);
  node->frequency
      = hot ? NODE_FREQUENCY_HOT : NODE_FREQUENCY_NORMAL;
}

/* In the case of COMDAT routines, multiple object files will contain the same
   function and the linker will select one for the binary. In that case
   all the other copies from the profile instrument binary will be missing
   profile counts. Look for cases where this happened, due to non-zero
   call counts going to 0-count functions, and drop the profile to guessed
   so that we can use the estimated probabilities and avoid optimizing only
   for size.
   
   The other case where the profile may be missing is when the routine
   is not going to be emitted to the object file, e.g. for "extern template"
   class methods. Those will be marked DECL_EXTERNAL. Emit a warning in
   all other cases of non-zero calls to 0-count functions.  */

void
handle_missing_profiles (void)
{
  struct cgraph_node *node;
  int unlikely_count_fraction = PARAM_VALUE (UNLIKELY_BB_COUNT_FRACTION);
  vec<struct cgraph_node *> worklist;
  worklist.create (64);

  /* See if 0 count function has non-0 count callers.  In this case we
     lost some profile.  Drop its function profile to PROFILE_GUESSED.  */
  FOR_EACH_DEFINED_FUNCTION (node)
    {
      struct cgraph_edge *e;
      gcov_type call_count = 0;
      gcov_type max_tp_first_run = 0;
      struct function *fn = DECL_STRUCT_FUNCTION (node->decl);

      if (node->count)
        continue;
      for (e = node->callers; e; e = e->next_caller)
      {
        call_count += e->count;

	if (e->caller->tp_first_run > max_tp_first_run)
	  max_tp_first_run = e->caller->tp_first_run;
      }

      /* If time profile is missing, let assign the maximum that comes from
	 caller functions.  */
      if (!node->tp_first_run && max_tp_first_run)
	node->tp_first_run = max_tp_first_run + 1;

      if (call_count
          && fn && fn->cfg
          && (call_count * unlikely_count_fraction >= profile_info->runs))
        {
          drop_profile (node, call_count);
          worklist.safe_push (node);
        }
    }

  /* Propagate the profile dropping to other 0-count COMDATs that are
     potentially called by COMDATs we already dropped the profile on.  */
  while (worklist.length () > 0)
    {
      struct cgraph_edge *e;

      node = worklist.pop ();
      for (e = node->callees; e; e = e->next_caller)
        {
          struct cgraph_node *callee = e->callee;
          struct function *fn = DECL_STRUCT_FUNCTION (callee->decl);

          if (callee->count > 0)
            continue;
          if (DECL_COMDAT (callee->decl) && fn && fn->cfg
              && profile_status_for_fn (fn) == PROFILE_READ)
            {
              drop_profile (node, 0);
              worklist.safe_push (callee);
            }
        }
    }
  worklist.release ();
}

/* Convert counts measured by profile driven feedback to frequencies.
   Return nonzero iff there was any nonzero execution count.  */

int
counts_to_freqs (void)
{
  gcov_type count_max, true_count_max = 0;
  basic_block bb;

  /* Don't overwrite the estimated frequencies when the profile for
     the function is missing.  We may drop this function PROFILE_GUESSED
     later in drop_profile ().  */
  if (!flag_auto_profile && !ENTRY_BLOCK_PTR_FOR_FN (cfun)->count)
    return 0;

  FOR_BB_BETWEEN (bb, ENTRY_BLOCK_PTR_FOR_FN (cfun), NULL, next_bb)
    true_count_max = MAX (bb->count, true_count_max);

  count_max = MAX (true_count_max, 1);
  FOR_BB_BETWEEN (bb, ENTRY_BLOCK_PTR_FOR_FN (cfun), NULL, next_bb)
    bb->frequency = (bb->count * BB_FREQ_MAX + count_max / 2) / count_max;

  return true_count_max;
}

/* Return true if function is likely to be expensive, so there is no point to
   optimize performance of prologue, epilogue or do inlining at the expense
   of code size growth.  THRESHOLD is the limit of number of instructions
   function can execute at average to be still considered not expensive.  */

bool
expensive_function_p (int threshold)
{
  unsigned int sum = 0;
  basic_block bb;
  unsigned int limit;

  /* We can not compute accurately for large thresholds due to scaled
     frequencies.  */
  gcc_assert (threshold <= BB_FREQ_MAX);

  /* Frequencies are out of range.  This either means that function contains
     internal loop executing more than BB_FREQ_MAX times or profile feedback
     is available and function has not been executed at all.  */
  if (ENTRY_BLOCK_PTR_FOR_FN (cfun)->frequency == 0)
    return true;

  /* Maximally BB_FREQ_MAX^2 so overflow won't happen.  */
  limit = ENTRY_BLOCK_PTR_FOR_FN (cfun)->frequency * threshold;
  FOR_EACH_BB_FN (bb, cfun)
    {
      rtx_insn *insn;

      FOR_BB_INSNS (bb, insn)
	if (active_insn_p (insn))
	  {
	    sum += bb->frequency;
	    if (sum > limit)
	      return true;
	}
    }

  return false;
}

/* Estimate and propagate basic block frequencies using the given branch
   probabilities.  If FORCE is true, the frequencies are used to estimate
   the counts even when there are already non-zero profile counts.  */

void
estimate_bb_frequencies (bool force)
{
  basic_block bb;
  sreal freq_max;

  if (force || profile_status_for_fn (cfun) != PROFILE_READ || !counts_to_freqs ())
    {
      static int real_values_initialized = 0;

      if (!real_values_initialized)
        {
	  real_values_initialized = 1;
	  real_br_prob_base = REG_BR_PROB_BASE;
	  real_bb_freq_max = BB_FREQ_MAX;
	  real_one_half = sreal (1, -1);
	  real_inv_br_prob_base = sreal (1) / real_br_prob_base;
	  real_almost_one = sreal (1) - real_inv_br_prob_base;
	}

      mark_dfs_back_edges ();

      single_succ_edge (ENTRY_BLOCK_PTR_FOR_FN (cfun))->probability =
	 REG_BR_PROB_BASE;

      /* Set up block info for each basic block.  */
      alloc_aux_for_blocks (sizeof (block_info));
      alloc_aux_for_edges (sizeof (edge_prob_info));
      FOR_BB_BETWEEN (bb, ENTRY_BLOCK_PTR_FOR_FN (cfun), NULL, next_bb)
	{
	  edge e;
	  edge_iterator ei;

	  FOR_EACH_EDGE (e, ei, bb->succs)
	    {
	      EDGE_INFO (e)->back_edge_prob = e->probability;
	      EDGE_INFO (e)->back_edge_prob *= real_inv_br_prob_base;
	    }
	}

      /* First compute frequencies locally for each loop from innermost
         to outermost to examine frequencies for back edges.  */
      estimate_loops ();

      freq_max = 0;
      FOR_EACH_BB_FN (bb, cfun)
	if (freq_max < BLOCK_INFO (bb)->frequency)
	  freq_max = BLOCK_INFO (bb)->frequency;

      freq_max = real_bb_freq_max / freq_max;
      FOR_BB_BETWEEN (bb, ENTRY_BLOCK_PTR_FOR_FN (cfun), NULL, next_bb)
	{
	  sreal tmp = BLOCK_INFO (bb)->frequency * freq_max + real_one_half;
	  bb->frequency = tmp.to_int ();
	}

      free_aux_for_blocks ();
      free_aux_for_edges ();
    }
  compute_function_frequency ();
}

/* Decide whether function is hot, cold or unlikely executed.  */
void
compute_function_frequency (void)
{
  basic_block bb;
  struct cgraph_node *node = cgraph_node::get (current_function_decl);

  if (DECL_STATIC_CONSTRUCTOR (current_function_decl)
      || MAIN_NAME_P (DECL_NAME (current_function_decl)))
    node->only_called_at_startup = true;
  if (DECL_STATIC_DESTRUCTOR (current_function_decl))
    node->only_called_at_exit = true;

  if (profile_status_for_fn (cfun) != PROFILE_READ)
    {
      int flags = flags_from_decl_or_type (current_function_decl);
      if (lookup_attribute ("cold", DECL_ATTRIBUTES (current_function_decl))
	  != NULL)
        node->frequency = NODE_FREQUENCY_UNLIKELY_EXECUTED;
      else if (lookup_attribute ("hot", DECL_ATTRIBUTES (current_function_decl))
	       != NULL)
        node->frequency = NODE_FREQUENCY_HOT;
      else if (flags & ECF_NORETURN)
        node->frequency = NODE_FREQUENCY_EXECUTED_ONCE;
      else if (MAIN_NAME_P (DECL_NAME (current_function_decl)))
        node->frequency = NODE_FREQUENCY_EXECUTED_ONCE;
      else if (DECL_STATIC_CONSTRUCTOR (current_function_decl)
	       || DECL_STATIC_DESTRUCTOR (current_function_decl))
        node->frequency = NODE_FREQUENCY_EXECUTED_ONCE;
      return;
    }

  /* Only first time try to drop function into unlikely executed.
     After inlining the roundoff errors may confuse us.
     Ipa-profile pass will drop functions only called from unlikely
     functions to unlikely and that is most of what we care about.  */
  if (!cfun->after_inlining)
    node->frequency = NODE_FREQUENCY_UNLIKELY_EXECUTED;
  FOR_EACH_BB_FN (bb, cfun)
    {
      if (maybe_hot_bb_p (cfun, bb))
	{
	  node->frequency = NODE_FREQUENCY_HOT;
	  return;
	}
      if (!probably_never_executed_bb_p (cfun, bb))
	node->frequency = NODE_FREQUENCY_NORMAL;
    }
}

/* Build PREDICT_EXPR.  */
tree
build_predict_expr (enum br_predictor predictor, enum prediction taken)
{
  tree t = build1 (PREDICT_EXPR, void_type_node,
		   build_int_cst (integer_type_node, predictor));
  SET_PREDICT_EXPR_OUTCOME (t, taken);
  return t;
}

const char *
predictor_name (enum br_predictor predictor)
{
  return predictor_info[predictor].name;
}

/* Predict branch probabilities and estimate profile of the tree CFG. */

namespace {

const pass_data pass_data_profile =
{
  GIMPLE_PASS, /* type */
  "profile_estimate", /* name */
  OPTGROUP_NONE, /* optinfo_flags */
  TV_BRANCH_PROB, /* tv_id */
  PROP_cfg, /* properties_required */
  0, /* properties_provided */
  0, /* properties_destroyed */
  0, /* todo_flags_start */
  0, /* todo_flags_finish */
};

class pass_profile : public gimple_opt_pass
{
public:
  pass_profile (gcc::context *ctxt)
    : gimple_opt_pass (pass_data_profile, ctxt)
  {}

  /* opt_pass methods: */
  virtual bool gate (function *) { return flag_guess_branch_prob; }
  virtual unsigned int execute (function *);

}; // class pass_profile

unsigned int
pass_profile::execute (function *fun)
{
  unsigned nb_loops;

  if (profile_status_for_fn (cfun) == PROFILE_GUESSED)
    return 0;

  loop_optimizer_init (LOOPS_NORMAL);
  if (dump_file && (dump_flags & TDF_DETAILS))
    flow_loops_dump (dump_file, NULL, 0);

  mark_irreducible_loops ();

  nb_loops = number_of_loops (fun);
  if (nb_loops > 1)
    scev_initialize ();

  tree_estimate_probability ();

  if (nb_loops > 1)
    scev_finalize ();

  loop_optimizer_finalize ();
  if (dump_file && (dump_flags & TDF_DETAILS))
    gimple_dump_cfg (dump_file, dump_flags);
 if (profile_status_for_fn (fun) == PROFILE_ABSENT)
    profile_status_for_fn (fun) = PROFILE_GUESSED;
  return 0;
}

} // anon namespace

gimple_opt_pass *
make_pass_profile (gcc::context *ctxt)
{
  return new pass_profile (ctxt);
}

namespace {

const pass_data pass_data_strip_predict_hints =
{
  GIMPLE_PASS, /* type */
  "*strip_predict_hints", /* name */
  OPTGROUP_NONE, /* optinfo_flags */
  TV_BRANCH_PROB, /* tv_id */
  PROP_cfg, /* properties_required */
  0, /* properties_provided */
  0, /* properties_destroyed */
  0, /* todo_flags_start */
  0, /* todo_flags_finish */
};

class pass_strip_predict_hints : public gimple_opt_pass
{
public:
  pass_strip_predict_hints (gcc::context *ctxt)
    : gimple_opt_pass (pass_data_strip_predict_hints, ctxt)
  {}

  /* opt_pass methods: */
  opt_pass * clone () { return new pass_strip_predict_hints (m_ctxt); }
  virtual unsigned int execute (function *);

}; // class pass_strip_predict_hints

/* Get rid of all builtin_expect calls and GIMPLE_PREDICT statements
   we no longer need.  */
unsigned int
pass_strip_predict_hints::execute (function *fun)
{
  basic_block bb;
  gimple *ass_stmt;
  tree var;

  FOR_EACH_BB_FN (bb, fun)
    {
      gimple_stmt_iterator bi;
      for (bi = gsi_start_bb (bb); !gsi_end_p (bi);)
	{
	  gimple *stmt = gsi_stmt (bi);

	  if (gimple_code (stmt) == GIMPLE_PREDICT)
	    {
	      gsi_remove (&bi, true);
	      continue;
	    }
	  else if (is_gimple_call (stmt))
	    {
	      tree fndecl = gimple_call_fndecl (stmt);

	      if ((fndecl
		   && DECL_BUILT_IN_CLASS (fndecl) == BUILT_IN_NORMAL
		   && DECL_FUNCTION_CODE (fndecl) == BUILT_IN_EXPECT
		   && gimple_call_num_args (stmt) == 2)
		  || (gimple_call_internal_p (stmt)
		      && gimple_call_internal_fn (stmt) == IFN_BUILTIN_EXPECT))
		{
		  var = gimple_call_lhs (stmt);
		  if (var)
		    {
		      ass_stmt
			= gimple_build_assign (var, gimple_call_arg (stmt, 0));
		      gsi_replace (&bi, ass_stmt, true);
		    }
		  else
		    {
		      gsi_remove (&bi, true);
		      continue;
		    }
		}
	    }
	  gsi_next (&bi);
	}
    }
  return 0;
}

} // anon namespace

gimple_opt_pass *
make_pass_strip_predict_hints (gcc::context *ctxt)
{
  return new pass_strip_predict_hints (ctxt);
}

/* Rebuild function frequencies.  Passes are in general expected to
   maintain profile by hand, however in some cases this is not possible:
   for example when inlining several functions with loops freuqencies might run
   out of scale and thus needs to be recomputed.  */

void
rebuild_frequencies (void)
{
  timevar_push (TV_REBUILD_FREQUENCIES);

  /* When the max bb count in the function is small, there is a higher
     chance that there were truncation errors in the integer scaling
     of counts by inlining and other optimizations. This could lead
     to incorrect classification of code as being cold when it isn't.
     In that case, force the estimation of bb counts/frequencies from the
     branch probabilities, rather than computing frequencies from counts,
     which may also lead to frequencies incorrectly reduced to 0. There
     is less precision in the probabilities, so we only do this for small
     max counts.  */
  gcov_type count_max = 0;
  basic_block bb;
  FOR_BB_BETWEEN (bb, ENTRY_BLOCK_PTR_FOR_FN (cfun), NULL, next_bb)
    count_max = MAX (bb->count, count_max);

  if (profile_status_for_fn (cfun) == PROFILE_GUESSED
      || (!flag_auto_profile && profile_status_for_fn (cfun) == PROFILE_READ
	  && count_max < REG_BR_PROB_BASE/10))
    {
      loop_optimizer_init (0);
      add_noreturn_fake_exit_edges ();
      mark_irreducible_loops ();
      connect_infinite_loops_to_exit ();
      estimate_bb_frequencies (true);
      remove_fake_exit_edges ();
      loop_optimizer_finalize ();
    }
  else if (profile_status_for_fn (cfun) == PROFILE_READ)
    counts_to_freqs ();
  else
    gcc_unreachable ();
  timevar_pop (TV_REBUILD_FREQUENCIES);
}