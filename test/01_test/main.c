#include <stdio.h>

void D(void)
{
    printf("D\n");
}

void C(void)
{
    printf("C\n");
    int i;
    for(i = 0; i < 3; i++){
        D();
    }
}

void B(void)
{
    printf("B\n");
    int i;
    for(i = 0; i < 2; i++){
        C();
    }
}
void A(void)
{
    printf("A\n");
    C();
}

int main(void)
{
    A();
    B();
    return 0;
}
