#include <stdio.h>
#include <stdlib.h>

void B(char *s, int two, int three);


//void (*Z)(char *, int, int) = B;
typedef void (*some_func_ptr_t)(char *, int, int);
some_func_ptr_t Z = B;

void E(char *s, int eight, int nine)
{
    printf("E\n");
    printf("  %s , %d %d\n", s, eight, nine);
    int i;
    for(i = 0; i < 2; i++){
        printf("  E loop iteration %d\n", i);
    }
}

void D(char *s, int two, int three)
{
    printf("D\n");
    printf("  %s , %d %d\n", s, two, three);
    int i;
    for(i = 0; i < 2; i++){
        printf("  D loop iteration %d\n", i);
    }
}

void C(char *s, int four, int five, int six)
{
    printf("C\n");
    printf("  %s , %d %d %d\n", s, four, five, six);
    B("str arg to B (from C)", 22, 33);
}

void B(char *s, int two, int three)
{
    printf("B\n");
    printf("  %s , %d %d\n", s, two, three);
    static int init_B = 0;
    static int static_rand_val = 0;

    if(init_B == 0){
        init_B = 1;
        static_rand_val = rand();
    }
    //printf("static rand val in B: %d\n", static_rand_val);

    if(static_rand_val % 2){
        E("str arg to E", 8, 9);
    }else{
        int i;
        for(i = 0; i < 2; i++){
            printf("  B loop iteration %d\n", i);
        }
    }
}

void A(char *s, int one, int two, int three, int four)
{
    printf("A\n");
    printf("  %s , %d %d %d %d\n", s, one, two, three, four);

    int rand_val = rand();

    if(rand_val % 2){
        printf("  %s\n", s);
        printf("  %d\n", one);
        int i;
        for(i = 0; i < 2; i++){
            //B("str arg to B", 2, 3);
            Z("some func ptr invocation", 4, 2);
        }
        C("str arg to C", 4, 5, 6);
    }else{
        D("str arg to D", 2, 3);
    }
}
void A3(char *s, int one, int two, int three, int four)
{
    printf("A3\n");
    printf("  %s , %d %d %d %d\n", s, one, two, three, four);
    int i;
    for(i = 0; i < 2; i++){
        B("str arg to B", 2, 3);
        //Z("some func ptr invocation", 4, 2);
    }
    C("str arg to C", 4, 5, 6);
}
void A5(char *s, int one, int two, int three, int four)
{
    printf("A5\n");
    printf("  %s , %d %d %d %d\n", s, one, two, three, four);
    int i;
    for(i = 0; i < 1; i++){
        //B("str arg to B", 2, 3);
        Z("some func ptr invocation", 4, 2);
    }
}



int test_0(void)
{
    printf("hello world\n");
    return 0;
}
int test_1(void)
{
    D("str arg to D", 22, 33);
    return 0;
}
int test_2(void)
{
    B("str arg to B", 22, 33);
    return 0;
}
int test_3(void)
{
    A3("str arg to A", 11, 101, 102, 105);
    return 0;
}
int test_4(void)
{
    Z("str arg to B (invoked via Z)", 22, 33);
    return 0;
}
int test_5(void)
{
    A5("str arg to A", 11, 101, 102, 105);
    return 0;
}
int test_9(void)
{
    A("str arg to A", 11, 101, 102, 105);
    return 0;
}




int main(void)
{
    //test_0();
    //test_1();
    //test_2();
    //test_3();
    //test_4();
    //test_5();
    test_9();
    return 0;
}
