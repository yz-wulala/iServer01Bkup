/* { dg-do compile } */
/* { dg-final { scan-assembler "\tcmpnei\t.*\[^\n\]*, 1\n\t" } }*/

int mov(int a,int b, int c)
{
	if(a == 1)
		a = b;
	else
		a = c;
	return a;
}