#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include <assert.h>

// Set the buffer size here.
// addresses are 8 bytes (long long)
//#define MAX_CACHED_FP_ADDRS_SZ 64 // 64 * 8 = 512 B buffer
#define MAX_CACHED_FP_ADDRS_SZ (1<<20) // 8 MB

extern "C" {int debrt_protect_indirect(long long);}
extern "C" {int debrt_protect_loop_end(int);}
extern "C" {int debrt_profile_indirect_print_args(long long *);}

long long cached_fp_addrs[MAX_CACHED_FP_ADDRS_SZ] = {0};
long long cached_fp_addrs_idx = 0;

// This is a bit of a hack for passing the indirect call's arguments to
// debrt_protect_indirect. We're just going to unpack the var args here inside
// this wrapper and then push them into this static space.
// XXX Element 0 of the stack is the number of args to follow it.
#define INDIRECT_CALL_STATIC_VARARG_STATIC_SZ 512
long long indirect_call_static_vararg_stack[INDIRECT_CALL_STATIC_VARARG_STATIC_SZ] = {0L};

// Arguments that get passed:
// Element 0: argc (number of args to follow, >=2)
// Element 1: function pointer target address
// Element 2: deck ID
// Element 3: function pointer arg 0 (optional)
// Element 4: function pointer arg 1 (optional)
// Element m: function pointer arg n (optional)
extern "C" {
__attribute__((always_inline))
//int ics_map_indirect_call(long long fp_addr)
int ics_map_indirect_call(long long argc, ...)
{
    long long x;
    int i;
    va_list ap;
    long long fp_addr;

    va_start(ap, argc);
    fp_addr = va_arg(ap, long long);


    x = fp_addr;
    x = (x ^ (x >> 30)) * (0xbf58476d1ce4e5b9LL);
    x = (x ^ (x >> 27)) * (0x94d049bb133111ebLL);
    x = (x ^ (x >> 31)) % MAX_CACHED_FP_ADDRS_SZ;
    if(cached_fp_addrs[x] == fp_addr){
        va_end(ap);
        return 0;
    }

    // We should always pass at least the func ptr target addr and
    // the deck ID, so argc should always be >= 2.
    // FIXME... yeah dont assert here in a real version of this.
    assert(argc >= 2);

    // Make sure we have enough buffer space.
    // We need enough space to hold all the arguments,
    // which would be:
    //   argc-1 <= INDIRECT_CALL_STATIC_VARARG_STATIC_SZ
    // because we don't put the functoin pointer address in there.
    // FIXME... yeah dont assert here in a real version of this.
    assert((argc-1) <= INDIRECT_CALL_STATIC_VARARG_STATIC_SZ);

    // Element 0 of this vararg_stack will hold the number of elements to
    // follow. It's equivalent to argc minus 1, b/c we're not putting
    // the function pointer target address in here.
    indirect_call_static_vararg_stack[0] = argc-1;

    // Start at i = 1, because we've already "popped" fp_addr from the valist.
    // Note that on this first iteration, va_arg is going to return to us
    // the deck ID, and it will go into i=1 for our vararg_stack (as desired).
    for(i = 1; i < argc; i++){
        indirect_call_static_vararg_stack[i] = va_arg(ap, long long);
    }
    va_end(ap);

    debrt_profile_indirect_print_args(indirect_call_static_vararg_stack);
    // XXX no need to "reset" or do anything with vararg_stack between calls.
    // Whenever we invoke ics_map_indirect_call() again with a non-cached
    // function pointer, we will set element 0 to the proper count again and
    // update its elements.

    // XXX This check could be optimized out. We could move the definition of
    // cached-fp-addrs to the debrt library and make it responsibe for all
    // writes. debrt-protect-indirect only returns non-zero during that
    // start-up edge case where we throw a WARNING.
    if(debrt_protect_indirect(fp_addr) == 0){
        cached_fp_addrs[x] = fp_addr;
    }
    return 0;
}
}

extern "C" {
__attribute__((always_inline))
int ics_wrapper_debrt_protect_loop_end(int loop_id)
{
    debrt_protect_loop_end(loop_id);
    memset(cached_fp_addrs, 0, sizeof(long long) * MAX_CACHED_FP_ADDRS_SZ);
    return 0;
}
}
