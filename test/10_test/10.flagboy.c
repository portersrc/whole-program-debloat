#include <stdio.h>
#include <stdlib.h>






// define hack to keep using this test file for datalog + other tests
// like linker script updates
//#define DATALOG_TESTING






#ifndef DATALOG_TESTING

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

void a(int x)
{
    printf("original x: %d\n", x);
    if(x){
        printf("x is true\n");
    }else{
        printf("x is false\n");
    }
    x = x << 1 ;
    printf("updated x: %d\n", x);
}

int foo(int x)
{
    return x*2;
}
int bar(int x)
{
    return x*3;
}
void b(int x)
{
    printf("start x value: %d\n", x);
    x += 10;
    x = foo(x);
    x += 20;
    x = bar(x);
    x += 30;
    printf("final x value: %d\n", x);
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
int test_10(void)
{
    //a(1);
    b(1);
    return 0;
}










#else

// Meant to match listing 4.1 in the proposal
//void B(void){} void C(void){} void D(void){} void E(void){}
//void A(void)
//{
//    C();
//}
//int listing_4_1(void)
//{
//    if(rand()%2){
//        A();
//    }else{
//        B();
//    }
//    D();
//    E();
//}

void B(void){} void C(void){} void D(void){} void E(void){}
void A(void)
{
    C();
}
void loop_1(void)
{
    int i = 0;
    while(i < 3){
        A();
        i++;
    }
    if(rand()%2){
        A();
    }else{
        B();
    }
    D();
    E();
}
void loop_2(void)
{
    int i = 0;
    while(i < 3){
        A();
        i++;
    }
    D();
    E();
}
void loop_3(void)
{
    int i = 0;
    while(i < 3){
        A();
        i++;
    }
    D();
}
void loop_4(void)
{
    int i = 0;
    E();
    D();
    if(rand()%2){
        A();
    }else{
        B();
    }
    while(i < 3){
        A();
        i++;
    }
}
void loop_5(void)
{
    int i = 0;
    E();
    D();
    while(i < 3){
        A();
        i++;
    }
    if(rand()%2){
        A();
    }else{
        B();
    }
}
void if_1(void)
{
    int i = 0;
    if(i){
        A();
    }
    B();
}
void if_2(void)
{
    int i = 0;
    if(i){
        A();
    }
    if(i+1){
        B();
    }
    if(i+2){
        C();
    }
    D();
}
#endif

int main(void)
{
    //test_0();
    //test_1();
    //test_2();
    //test_3();
    //test_4();
    //test_5();
    test_9();
    //test_10();
    //listing_4_1();
    //loop_1();
    //loop_2();
    //loop_3();
    //if_1();
    return 0;
}
