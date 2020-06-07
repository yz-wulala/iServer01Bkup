#include "stdio.h"

int main (void)
{

//Section 1: Hello World!
  printf("\nHello Friend!\n");
  printf("Welcome to C-SKY World!\n");

//Section 2: Embeded ASM in C 
  int a;
  int b;
  int c;
  a=1;
  b=2;
  c=0;
  printf("\na is %d!\n",a);
  printf("b is %d!\n",b);
  printf("c is %d!\n",c);

asm(
    "mov  r0,%[a]\n"
    "mov  r1,%[b]\n"
    "label_add:"
    "add  %[c],r0,r1\n"
    :[c]"=r"(c)
    :[a]"r"(a),[b]"r"(b)
    :"r0","r1"
    );


  printf("after ASM c is changed to %d!\n",c);

  return 0;
}

