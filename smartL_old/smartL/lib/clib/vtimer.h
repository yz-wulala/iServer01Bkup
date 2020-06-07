/*
 * timer.h -- The interface functions and Mcros for SMART
 *
 * Copyright (C) 2008  Hangzhou C-SKY Microsystems Co., Ltd
 */

static int get_vtimer()
{
  int *TIMER_ADDR;
  TIMER_ADDR = 0xE0013000;
  volatile unsigned int   LoadCount;
  LoadCount = *TIMER_ADDR;
  return LoadCount;
}

void sim_end()
{
  int *END_ADDR;
  END_ADDR = 0x6000FFF8;
  unsigned int END_DATA;
  END_DATA= 0xffff0000;
  *END_ADDR = END_DATA;
}
