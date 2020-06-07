/* { dg-do compile } */
/*  {  dg-skip-if  "test is specific to ck803/ck807/ck810"  { csky-*-* }  { "*" }  {"-march=ck803" "-march=ck807" "-march=ck810" }  }  */
/* { dg-options "-O1" } */

int func(int a,int b,int x,int y,int z)
{
  if (a == b)
    {
      x=x+y;
      z=x&y;
    }
  else
    {
      y=y-x;
      z=x^y;
    }
 return z;
}

/* { dg-final { scan-assembler "sce\t" } }*/
/* { dg-final { scan-assembler "addu" } }*/
/* { dg-final { scan-assembler "and" } }*/
/* { dg-final { scan-assembler "subu" } }*/
/* { dg-final { scan-assembler "xor" } }*/