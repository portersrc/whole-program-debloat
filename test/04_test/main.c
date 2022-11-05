#include <stdio.h>

void B(char *s, int two, int three);




void C(char *s, int four, int five, int six)
{
    printf("Args to C are:\n");
    printf("  %s\n", s);
    printf("  %d\n", four);
    printf("  %d\n", five);
    printf("  %d\n", six);
    B("str arg to B (from C)", 22, 33);
}

void B(char *s, int two, int three)
{
    printf("B\n");
    int i;
    for(i = 0; i < 2; i++){
        printf("  B loop iteration %d\n", i);
    }
}

void A(char *s, int one, int two, int three, four)
{
    printf("Args to A are:\n");
    printf("  %s\n", s);
    printf("  %d\n", one);
    int i;
    for(i = 0; i < 2; i++){
        B("str arg to B", 2, 3);
    }
    C("str arg to C", 4, 5, 6);
}

int main(void)
{
    A("str arg to A", 11, 101, 102, 105);
    return 0;
}
