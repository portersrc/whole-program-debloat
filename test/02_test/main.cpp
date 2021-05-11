#include <stdio.h>
#include <vector>

using namespace std;

int foo(void)
{
    printf("inside foo\n");
    vector<int> v;
    v.push_back(1);
    v.push_back(2);
    v.push_back(3);
    printf("v:\n");
    for(auto i : v){
        printf("  %d\n", i);
    }
    return 0;
}

int main(void)
{
    printf("Hello world\n");
    foo();
    return 0;
}
