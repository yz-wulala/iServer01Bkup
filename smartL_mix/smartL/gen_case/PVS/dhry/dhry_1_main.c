/*
 ****************************************************************************
 *
 *                   "DHRYSTONE" Benchmark Program
 *                   -----------------------------
 *                                                                            
 *  Version:    C, Version 2.1
 *                                                                            
 *  File:       dhry_1.c (part 2 of 3)
 *
 *  Date:       May 25, 1988
 *
 *  Author:     Reinhold P. Weicker
 *
 ****************************************************************************
 */
// CSKYCPU    : 801 802 803 804
// HWCFIG     : 
//if you want use virtual counter of CSKY, Open the macro below
#define VCUNT_SIM

#include "dhry.h"
#include "timer.h"
#include "config.h"

#ifdef VCUNT_SIM
 #include "vtimer.h"
 int vtimer_start;
 int vtimer_end;
 int vcycles;
 float dmips;
#endif 
/* Global Variables: */

#ifdef __uClinux__
/* For uClinux or Linux OS */
Rec_Pointer     Ptr_Glob,
                Next_Ptr_Glob;
#else    /* #ifdef __uClinux__ */
/* For no OS */
Rec_Type        g_Glob,
                g_Next_Glob;
Rec_Pointer     Ptr_Glob= &g_Glob,
                Next_Ptr_Glob = &g_Next_Glob;
#endif   /* #ifdef __uClinux__  */

int             Int_Glob;
Boolean         Bool_Glob;
char            Ch_1_Glob,
                Ch_2_Glob;
int             Arr_1_Glob [50];
int             Arr_2_Glob [50] [50];

int Loop_Num=0;

#ifdef __uClinux__
extern char     *malloc ();
#endif

Enumeration     Func_1 ();
  /* forward declaration necessary since Enumeration may not simply be int */

#ifndef REG
        Boolean Reg = false;
#define REG
        /* REG becomes defined as empty */
        /* i.e. no register variables   */
#else
        Boolean Reg = true;
#endif

/* variables for time measurement: */

#ifdef __uClinux__
/* For uClinux or Linux OS */
#ifdef TIMES
struct tms      time_info;
#ifndef NO_PROTOTYPES
extern  int     times ();
                /* see library function "times" */
#endif
#define Too_Small_Time 120
                /* Measurements should last at least about 2 seconds */
#endif
#ifdef TIME
#ifndef NO_PROTOTYPES
extern long     time();
                /* see library function "time"  */
#endif
#define Too_Small_Time 2
                /* Measurements should last at least 2 seconds */
#endif

#else  /* #ifdef __uClinux__ */
/* For no OS */
#define Too_Small_Time 2
#endif /* #ifdef __uClinux__ */

unsigned long   Begin_Time,
                End_Time,
                User_Time;

#ifdef __uClinux__
float           Microseconds,
                Dhrystones_Per_Second;
#else   /* #ifdef __uClinux__ */
long            Microseconds,
                Dhrystones_Per_Second,
                Vax_Mips;
#endif  /* #ifdef __uClinux__ */

/* end of variables for time measurement */

//------------------------------------------------
// setup uart
//------------------------------------------------
#include "datatype.h"
#include "uart.h"
#include "stdio.h"

t_ck_uart_device uart0 = {0xFFFF};
//------------------------------------------------

void main () 
/*****/

  /* main program, corresponds to procedures        */
  /* Main and Proc_0 in the Ada version             */
{
  //--------------------------------------------------------
  // setup uart
  //--------------------------------------------------------
  t_ck_uart_cfig   uart_cfig;

  uart_cfig.baudrate = BAUD;       // any integer value is allowed
  uart_cfig.parity = PARITY_NONE;     // PARITY_NONE / PARITY_ODD / PARITY_EVEN
  uart_cfig.stopbit = STOPBIT_1;      // STOPBIT_1 / STOPBIT_2
  uart_cfig.wordsize = WORDSIZE_8;    // from WORDSIZE_5 to WORDSIZE_8
  uart_cfig.txmode = ENABLE;          // ENABLE or DISABLE

  // open UART device with id = 0 (UART0)
  ck_uart_open(&uart0, 0);

  // initialize uart using uart_cfig structure
  ck_uart_init(&uart0, &uart_cfig);
  //--------------------------------------------------------
        One_Fifty       Int_1_Loc;
  REG   One_Fifty       Int_2_Loc;
        One_Fifty       Int_3_Loc;
  REG   char            Ch_Index;
        Enumeration     Enum_Loc;
        Str_30          Str_1_Loc;
        Str_30          Str_2_Loc;
  REG   int             Run_Index;
  REG   int             Number_Of_Runs;

  /* Initializations */

#ifdef __uClinux__
  Next_Ptr_Glob = (Rec_Pointer) malloc (sizeof (Rec_Type));
  Ptr_Glob = (Rec_Pointer) malloc (sizeof (Rec_Type));
#endif

  Ptr_Glob->Ptr_Comp                    = Next_Ptr_Glob;
  Ptr_Glob->Discr                       = Ident_1;
  Ptr_Glob->variant.var_1.Enum_Comp     = Ident_3;
  Ptr_Glob->variant.var_1.Int_Comp      = 40;
  strcpy (Ptr_Glob->variant.var_1.Str_Comp, 
          "DHRYSTONE PROGRAM, SOME STRING");
  strcpy (Str_1_Loc, "DHRYSTONE PROGRAM, 1'ST STRING");

  Arr_2_Glob [8][7] = 10;
        /* Was missing in published program. Without this statement,    */
        /* Arr_2_Glob [8][7] would have an undefined value.             */
        /* Warning: With 16-Bit processors and Number_Of_Runs > 32000,  */
        /* overflow may occur for this array element.                   */

  printf ("\n");
  printf ("Dhrystone Benchmark, Version 2.1 (Language: C)\n");
  if (Reg)
  {
    printf ("Program compiled with 'register' attribute\n");
  }
  else
  {
    printf ("Program compiled without 'register' attribute\n");
  }

#ifdef __uClinux__
  printf ("Please give the number of runs through the benchmark: ");
  fflush (stdout);
  {
    int n;
    scanf ("%d", &n);
    Number_Of_Runs = n;
  }
  printf ("\n");
#else
    Number_Of_Runs = 50;
#endif

  printf ("Execution starts, %d runs through Dhrystone\n", Number_Of_Runs);
  ck_intc_init();
  Timer_Interrupt_Init();
  /***************/
  /* Start timer */
  /***************/

#ifdef __uClinux__ 
  /* For uClinux or Linux OS */
#ifdef TIMES
  times (&time_info);
  Begin_Time = (long) time_info.tms_utime;
#endif
#ifdef TIME
  Begin_Time = time ( (long *) 0);
#endif
#else /* #ifdef __uClinux__ */
  /* For no OS */
  End_Time = start_timer (0);
#endif /* #ifdef __uClinux__ */

#ifdef VCUNT_SIM
  vtimer_start= get_vtimer();
#endif 
  for (Run_Index = 1; Run_Index <= Number_Of_Runs; ++Run_Index)
  { 
    Proc_5();
    Proc_4();
      /* Ch_1_Glob == 'A', Ch_2_Glob == 'B', Bool_Glob == true */
    Int_1_Loc = 2;
    Int_2_Loc = 3;
    strcpy (Str_2_Loc, "DHRYSTONE PROGRAM, 2'ND STRING");
    Enum_Loc = Ident_2;
    Bool_Glob = ! Func_2 (Str_1_Loc, Str_2_Loc);
      /* Bool_Glob == 1 */
    while (Int_1_Loc < Int_2_Loc)  /* loop body executed once */
    {
      Int_3_Loc = 5 * Int_1_Loc - Int_2_Loc;
        /* Int_3_Loc == 7 */
      Proc_7 (Int_1_Loc, Int_2_Loc, &Int_3_Loc);
        /* Int_3_Loc == 7 */
      Int_1_Loc += 1;
    } /* while */
      /* Int_1_Loc == 3, Int_2_Loc == 3, Int_3_Loc == 7 */
    Proc_8 (Arr_1_Glob, Arr_2_Glob, Int_1_Loc, Int_3_Loc);
      /* Int_Glob == 5 */
    Proc_1 (Ptr_Glob);
    for (Ch_Index = 'A'; Ch_Index <= Ch_2_Glob; ++Ch_Index)
                             /* loop body executed twice */
    {
      if (Enum_Loc == Func_1 (Ch_Index, 'C'))
          /* then, not executed */
        {
        Proc_6 (Ident_1, &Enum_Loc);
        strcpy (Str_2_Loc, "DHRYSTONE PROGRAM, 3'RD STRING");
        Int_2_Loc = Run_Index;
        Int_Glob = Run_Index;
        }
    }
      /* Int_1_Loc == 3, Int_2_Loc == 3, Int_3_Loc == 7 */
    Int_2_Loc = Int_2_Loc * Int_1_Loc;
    Int_1_Loc = Int_2_Loc / Int_3_Loc;
    Int_2_Loc = 7 * (Int_2_Loc - Int_3_Loc) - Int_1_Loc;
      /* Int_1_Loc == 1, Int_2_Loc == 13, Int_3_Loc == 7 */
    Proc_2 (&Int_1_Loc);
      /* Int_1_Loc == 5 */
  } /* loop "for Run_Index" */
#ifdef VCUNT_SIM
  vtimer_end= get_vtimer(); 
  vcycles = vtimer_end - vtimer_start;
//  printf ("\n %d  %d   %d  \n",vtimer_start,vtimer_end,vcycles);
  vcycles = vcycles/Number_Of_Runs;
  dmips = 569/(float)vcycles;
  printf ("\nVCUNT_SIM: dhrystone is %f dmips/MHz\n",dmips);
  sim_end();
#else
  /**************/
  /* Stop timer */
  /**************/

#ifdef __uClinux__ 
#ifdef TIMES
  times (&time_info);
  End_Time = (long) time_info.tms_utime;
#endif
#ifdef TIME
  End_Time = time ( (long *) 0);
#endif
#else  /* #ifdef __uClinux__ */
  Begin_Time = get_timer (0);
#endif /* #ifdef __uClinux__ */
  stop_timer(0); 
  printf ("Execution ends\n");
#if 1
  printf ("\n");
  printf ("Final values of the variables used in the benchmark:\n");
  printf ("\n");
  printf ("Int_Glob:            %d\n", Int_Glob);
  printf ("        should be:   %d\n", 5);
  printf ("Bool_Glob:           %d\n", Bool_Glob);
  printf ("        should be:   %d\n", 1);
  printf ("Ch_1_Glob:           %c\n", Ch_1_Glob);
  printf ("        should be:   %c\n", 'A');
  printf ("Ch_2_Glob:           %c\n", Ch_2_Glob);
  printf ("        should be:   %c\n", 'B');
  printf ("Arr_1_Glob[8]:       %d\n", Arr_1_Glob[8]);
  printf ("        should be:   %d\n", 7);
  printf ("Arr_2_Glob[8][7]:    %d\n", Arr_2_Glob[8][7]);
  printf ("        should be:   Number_Of_Runs + 10\n");
  printf ("Ptr_Glob->\n");
  printf ("  Ptr_Comp:          %d\n", (int) Ptr_Glob->Ptr_Comp);
  printf ("        should be:   (implementation-dependent)\n");
  printf ("  Discr:             %d\n", Ptr_Glob->Discr);
  printf ("        should be:   %d\n", 0);
  printf ("  Enum_Comp:         %d\n", Ptr_Glob->variant.var_1.Enum_Comp);
  printf ("        should be:   %d\n", 2);
  printf ("  Int_Comp:          %d\n", Ptr_Glob->variant.var_1.Int_Comp);
  printf ("        should be:   %d\n", 17);
  printf ("  Str_Comp:          %s\n", Ptr_Glob->variant.var_1.Str_Comp);
  printf ("        should be:   DHRYSTONE PROGRAM, SOME STRING\n");
  printf ("Next_Ptr_Glob->\n");
  printf ("  Ptr_Comp:          %d\n", (int) Next_Ptr_Glob->Ptr_Comp);
  printf ("        should be:   (implementation-dependent), same as above\n");
  printf ("  Discr:             %d\n", Next_Ptr_Glob->Discr);
  printf ("        should be:   %d\n", 0);
  printf ("  Enum_Comp:         %d\n", Next_Ptr_Glob->variant.var_1.Enum_Comp);
  printf ("        should be:   %d\n", 1);
  printf ("  Int_Comp:          %d\n", Next_Ptr_Glob->variant.var_1.Int_Comp);
  printf ("        should be:   %d\n", 18);
  printf ("  Str_Comp:          %s\n",
                                Next_Ptr_Glob->variant.var_1.Str_Comp);
  printf ("        should be:   DHRYSTONE PROGRAM, SOME STRING\n");
  printf ("Int_1_Loc:           %d\n", Int_1_Loc);
  printf ("        should be:   %d\n", 5);
  printf ("Int_2_Loc:           %d\n", Int_2_Loc);
  printf ("        should be:   %d\n", 13);
  printf ("Int_3_Loc:           %d\n", Int_3_Loc);
  printf ("        should be:   %d\n", 7);
  printf ("Enum_Loc:            %d\n", Enum_Loc);
  printf ("        should be:   %d\n", 1);
  printf ("Str_1_Loc:           %s\n", Str_1_Loc);
  printf ("        should be:   DHRYSTONE PROGRAM, 1'ST STRING\n");
  printf ("Str_2_Loc:           %s\n", Str_2_Loc);
  printf ("        should be:   DHRYSTONE PROGRAM, 2'ND STRING\n");
  printf ("\n");
#endif
  User_Time = Loop_Num * TIMER_PERIOD + End_Time - Begin_Time;

#ifndef __uClinux__
  printf ("Elapse time(APB cycles): %d\n", User_Time);  
  User_Time = User_Time / (APB_FREQ / 1000);
#endif

  printf ("Elapse time(ms): %d\n", User_Time);  
  if (User_Time < Too_Small_Time)
  {
    printf ("Measured time too small to obtain meaningful results\n");
    printf ("Please increase number of runs\n");
    printf ("\n");
  }
  else
  {
#ifdef __uClinux__
    /* For uClinux or Linux OS */
  #ifdef TIME
    Microseconds = (float) User_Time * Mic_secs_Per_Second 
                        / (float) Number_Of_Runs;
    Dhrystones_Per_Second = (float) Number_Of_Runs / (float) User_Time;
  #else
    Microseconds = (float) User_Time * Mic_secs_Per_Second 
                        / ((float) HZ * ((float) Number_Of_Runs));
    Dhrystones_Per_Second = ((float) HZ * (float) Number_Of_Runs)
                        / (float) User_Time;
  #endif
    printf ("Microseconds for one run through Dhrystone: ");
    printf ("%6.1f \n", Microseconds);
    printf ("Dhrystones per Second:                      ");
    printf ("%6.1f \n", Dhrystones_Per_Second);
    printf ("VAX MIPS rating = %6.1f \n",Dhrystones_Per_Second / 1757.0);
#else   /* #ifdef __uClinux__ */

    /* For no OS */
    Microseconds = User_Time * (Mic_secs_Per_Second / Number_Of_Runs) / 1000 ;
    Dhrystones_Per_Second =  Number_Of_Runs / User_Time * 1000;
    Vax_Mips = Dhrystones_Per_Second / 1757;
    printf ("Microseconds Dhrystone: %d\n", Microseconds);  
    printf ("Dhrystones per Second:  %d\n", Dhrystones_Per_Second);
    printf ("VAX MIPS rating =       %d  @ %d MHZ\n",
            Vax_Mips, SYS_FREQ / 1000000);
#endif  /* #ifdef __uClinux__ */
    printf ("\n");
  }

#ifdef __uClinux__ 
  exit(0);
#endif

  while (ck_uart_status(&uart0));

#endif 
}


Proc_1 (Ptr_Val_Par)
/******************/

REG Rec_Pointer Ptr_Val_Par;
    /* executed once */
{
  REG Rec_Pointer Next_Record = Ptr_Val_Par->Ptr_Comp;  
                                        /* == Ptr_Glob_Next */
  /* Local variable, initialized with Ptr_Val_Par->Ptr_Comp,    */
  /* corresponds to "rename" in Ada, "with" in Pascal           */
  
  structassign (*Ptr_Val_Par->Ptr_Comp, *Ptr_Glob); 
  Ptr_Val_Par->variant.var_1.Int_Comp = 5;
  Next_Record->variant.var_1.Int_Comp 
        = Ptr_Val_Par->variant.var_1.Int_Comp;
  Next_Record->Ptr_Comp = Ptr_Val_Par->Ptr_Comp;
  Proc_3 (&Next_Record->Ptr_Comp);
    /* Ptr_Val_Par->Ptr_Comp->Ptr_Comp 
                        == Ptr_Glob->Ptr_Comp */
  if (Next_Record->Discr == Ident_1)
    /* then, executed */
  {
    Next_Record->variant.var_1.Int_Comp = 6;
    Proc_6 (Ptr_Val_Par->variant.var_1.Enum_Comp, 
           &Next_Record->variant.var_1.Enum_Comp);
    Next_Record->Ptr_Comp = Ptr_Glob->Ptr_Comp;
    Proc_7 (Next_Record->variant.var_1.Int_Comp, 10, 
           &Next_Record->variant.var_1.Int_Comp);
  }
  else /* not executed */
    structassign (*Ptr_Val_Par, *Ptr_Val_Par->Ptr_Comp);
} /* Proc_1 */


Proc_2 (Int_Par_Ref)
/******************/
    /* executed once */
    /* *Int_Par_Ref == 1, becomes 4 */

One_Fifty   *Int_Par_Ref;
{
  One_Fifty  Int_Loc;  
  Enumeration   Enum_Loc;

  Int_Loc = *Int_Par_Ref + 10;
  do /* executed once */
    if (Ch_1_Glob == 'A')
      /* then, executed */
    {
      Int_Loc -= 1;
      *Int_Par_Ref = Int_Loc - Int_Glob;
      Enum_Loc = Ident_1;
    } /* if */
  while (Enum_Loc != Ident_1); /* true */
} /* Proc_2 */


Proc_3 (Ptr_Ref_Par)
/******************/
    /* executed once */
    /* Ptr_Ref_Par becomes Ptr_Glob */

Rec_Pointer *Ptr_Ref_Par;

{
  if (Ptr_Glob != Null)
    /* then, executed */
    *Ptr_Ref_Par = Ptr_Glob->Ptr_Comp;
  Proc_7 (10, Int_Glob, &Ptr_Glob->variant.var_1.Int_Comp);
} /* Proc_3 */


Proc_4 () /* without parameters */
/*******/
    /* executed once */
{
  Boolean Bool_Loc;

  Bool_Loc = Ch_1_Glob == 'A';
  Bool_Glob = Bool_Loc | Bool_Glob;
  Ch_2_Glob = 'B';
} /* Proc_4 */


Proc_5 () /* without parameters */
/*******/
    /* executed once */
{
  Ch_1_Glob = 'A';
  Bool_Glob = false;
} /* Proc_5 */


        /* Procedure for the assignment of structures,          */
        /* if the C compiler doesn't support this feature       */


#ifdef  NOSTRUCTASSIGN
memcpy (d, s, l)
register char   *d;
register char   *s;
register int    l;
{
        while (l--) *d++ = *s++;
}
#endif


