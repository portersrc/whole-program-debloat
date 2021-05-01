#include <stdio.h>

void E(void)
{
    printf("E\n");
}
void D(void)
{
    E();
}
void C(void)
{
    D();
}
void B(void)
{
    int i;
    for(i = 0; i < 2; i++){
        C();
    }
}

void G(void)
{
    printf("G\n");
}

void F(void)
{
    int i;
    for(i = 0; i < 2; i++)
    {
        G();
    }
    
}
void A(void)
{
    int i;
    for(i = 0; i < 2; i++){
        B();
    }
    F();
}

int main(void)
{
    A();
    return 0;
}
