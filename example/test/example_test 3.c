#include <assert.h>

int main(){
    assert(1 && "This test should be successful, but doesn't compile")
    return 0;
}