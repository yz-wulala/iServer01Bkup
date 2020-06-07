/* { dg-do compile } */
/*  {  dg-skip-if  "test is specific to the instruction v2"  { csky-*-* }  { "-march=*" }  { "-march=ck8*"  }  }  */
/* { dg-options " -O2" } */
/* { dg-final { scan-assembler "\[ |\t\]andni\[ |\t\]" } } */


int and(int a)
{
	return a & 0xfffff000;
}