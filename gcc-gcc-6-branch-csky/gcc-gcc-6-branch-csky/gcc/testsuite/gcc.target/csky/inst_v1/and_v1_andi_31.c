/* { dg-do compile } */
/*  {  dg-skip-if  "test is specific to the instruction v1"  { csky-*-* }  { "-march=*" }  { "-march=ck\[56\]*"  }  }  */

/* { dg-final { scan-assembler "\tandi\t.*\[^\n\]*, 31" } }*/

int and(int a)
{
	return a & 0x1f;
}