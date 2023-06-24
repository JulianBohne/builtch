#include <stdio.h>
#include <assert.h>

#ifdef TESTING
// This will basically turn off printf when testing 
#define printf(...)
#endif

int main(){
    printf("This text should not be visible while testing. Can you figure out where this is set?\n");
    assert(1 && "This test is successful");
    return 0;
}