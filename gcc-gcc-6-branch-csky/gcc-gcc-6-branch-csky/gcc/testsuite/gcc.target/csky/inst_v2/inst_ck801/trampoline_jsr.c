/* { dg-do compile } */

void func(int (*param)(int));

void outer(int x, int z)
{
  int nested(int y)
    {
      return x + y + z;
    }
  func(nested);
}

/* { dg-final { scan-assembler "push\tr4, lr\n\tlrw\tl3, \\\[\.Lstatic_chain\\\]\n\tlrw\tr4, \\\[.Lfunc_address\\\]\n\tnop\n\tjsr\tr4\n\tpush\tr4, lr" } } */