#include <stdio.h>

typedef int (*foo_fpt)(void);

int foo_three(void)
{
    printf("%s\n", __FUNCTION__);
    return 3;
}

int foo_two(void)
{
    printf("%s\n", __FUNCTION__);
    return 2;
}

int foo_one(void)
{
    printf("%s\n", __FUNCTION__);
    return 1;
}

int main(void)
{
    void *arr[3];
    printf("Hello world\n");
    printf("The value of foo_two is: %p\n", foo_two);

    //foo_fpt arr[3];
    //arr[0] = foo_one;
    arr[1] = foo_two;
    //arr[2] = foo_three;
    foo_one();
    ((int (*)(void))(arr[1]))();
    //foo_two();
    //foo_three();
    return 0;
}
