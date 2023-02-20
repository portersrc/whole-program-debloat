#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include <assert.h>


// Set the buffer size here.
// addresses are 8 bytes (long long)
// the recorded flags are 8 bytes (long long)
#define MAX_CACHED_FP_ADDRS_SZ (1<<20) // 1 * 16B = 16MB

extern "C" {int debrt_protect_indirect(long long);}
extern "C" {int debrt_protect_loop_end(int);}
extern "C" {int debrt_profile_indirect_print_args(long long *);}
extern "C" {int debrt_profile_update_recorded_funcs(int);}


typedef struct{
    long long fp_addr;  // a function pointer address
    long long recorded; // currently a flag.. could be a hash of profile-args in the future
}fp_addr_recorded_t;


fp_addr_recorded_t cached_fp_addrs[MAX_CACHED_FP_ADDRS_SZ] = {0};
long long cached_fp_addrs_idx = 0;

#define HASH_ADDR(a) \
    a = (a ^ (a >> 30)) * (0xbf58476d1ce4e5b9LL); \
    a = (a ^ (a >> 27)) * (0x94d049bb133111ebLL); \
    a = (a ^ (a >> 31)) % MAX_CACHED_FP_ADDRS_SZ;


// This is a bit of a hack for passing the indirect call's arguments to
// debrt_protect_indirect. We're just going to unpack the var args here inside
// this wrapper and then push them into this static space.
// XXX Element 0 of the stack is the number of args to follow it.
#define INDIRECT_CALL_STATIC_VARARG_STATIC_SZ 512
long long indirect_call_static_vararg_stack[INDIRECT_CALL_STATIC_VARARG_STATIC_SZ] = {0L};






//
//
//
// ICS static support -- XXX worked for wpd but haven't retested for artd
//
//
//

extern "C" {
__attribute__((always_inline))
int ics_static_map_indirect_call(long long fp_addr)
{
    long long x;
    x = fp_addr;
    x = (x ^ (x >> 30)) * (0xbf58476d1ce4e5b9LL);
    x = (x ^ (x >> 27)) * (0x94d049bb133111ebLL);
    x = (x ^ (x >> 31)) % MAX_CACHED_FP_ADDRS_SZ;
    if(cached_fp_addrs[x].fp_addr == fp_addr){
        return 0;
    }
    // XXX This check could be optimized out. We could move the definition of
    // cached-fp-addrs to the debrt library and make it responsibe for all
    // writes. debrt-protect-indirect only returns non-zero during that
    // start-up edge case where we throw a WARNING.
    if(debrt_protect_indirect(fp_addr) == 0){
        cached_fp_addrs[x].fp_addr = fp_addr;
    }
    return 0;
}
}

extern "C" {
__attribute__((always_inline))
int ics_static_wrapper_debrt_protect_loop_end(int loop_id)
{
    debrt_protect_loop_end(loop_id);
    memset(cached_fp_addrs, 0, sizeof(fp_addr_recorded_t) * MAX_CACHED_FP_ADDRS_SZ);
    return 0;
}
}











//
//
//
// ICS profile support
//
//
//



// Arguments that get passed:
// Element 0: argc (number of args to follow, >=2)
// Element 1: function pointer target address
// Element 2: deck ID
// Element 3: function pointer arg 0 (optional)
// Element 4: function pointer arg 1 (optional)
// Element m: function pointer arg n (optional)
extern "C" {
__attribute__((always_inline))
int ics_profile_map_indirect_call(long long argc, ...)
{
    long long x;
    int i;
    va_list ap;
    long long fp_addr;
    //printf("ics_map_indirect_call\n");

    va_start(ap, argc);
    fp_addr = va_arg(ap, long long);

    //printf("ics_map_indirect_call: fp_addr is 0x%llx\n", fp_addr);

    x = fp_addr;
    HASH_ADDR(x);

    //printf("ics_map_indirect_call: hashed value is %lld\n", x);

    //printf("ics_map_indirect_call: checking for cache hit or free spot\n");
    // Linear scan
    // Not expected to ever iterate more than once or twice
    // Stop if we've hit an uninitialized spot (i.e. fp_addr == 0),
    long long x_start = x;
    while(cached_fp_addrs[x].fp_addr != 0){
        if(cached_fp_addrs[x].fp_addr == fp_addr){
            // found the cached address
            //printf("ics_map_indirect_call: found cached address\n");
            va_end(ap);
            //printf("ics_map_indirect_call: adding a new recorded_funcs set\n");
            debrt_profile_update_recorded_funcs(0 /*new set*/);
            return 0;
        }
        x = (x+1) & MAX_CACHED_FP_ADDRS_SZ;
        if(x == x_start){
            // hashmap is full
            // Not expected for our purposes.
            // We won't handle this case for now b/c it messes up our output.
            // FIXME... dont assert in a real version of this.
            assert(0 && "TODO implement dynamic hashmap support");
        }
        //printf("ics_map_indirect_call: iterating\n");
    }

    // ...if execution reaches here, then linear scan found a free spot.
    // x holds the idx you want (i.e. of this free spot in the cache)

    // We should always pass at least the func ptr target addr and
    // the deck ID, so argc should always be >= 2.
    // FIXME... dont assert in a real version of this.
    assert(argc >= 2);

    // Make sure we have enough buffer space.
    // We need enough space to hold all the arguments,
    // which would be:
    //   argc <= INDIRECT_CALL_STATIC_VARARG_STATIC_SZ
    // FIXME... dont assert here in a real version of this.
    assert(argc <= INDIRECT_CALL_STATIC_VARARG_STATIC_SZ);

    // Element 0 of this vararg_stack will hold the number of elements to
    // follow. It's equivalent to argc.
    indirect_call_static_vararg_stack[0] = argc;
    // push the fp-addr in first.
    indirect_call_static_vararg_stack[1] = fp_addr;

    // Start at i = 1, because we've already "popped" fp_addr from the valist.
    // Note that on this first iteration, va_arg is going to return to us
    // the deck ID, and it will go into idx 2 for our vararg_stack (as desired).
    for(i = 1; i < argc; i++){
        indirect_call_static_vararg_stack[i+1] = va_arg(ap, long long);
    }
    va_end(ap);

    // This indirect call was unseen. So we're going to print the features.
    // TODO maybe we don't even invoke this in release version (check
    //   env variable for this info).
    //printf("ics_map_indirect_call: invoking indirect-print-args\n");
    debrt_profile_indirect_print_args(indirect_call_static_vararg_stack);
    // XXX no need to "reset" or do anything with vararg_stack between calls.
    // Whenever we invoke ics_map_indirect_call() again with a non-cached
    // function pointer, we will set element 0 to the proper count again and
    // update its elements.

    // XXX This check could be optimized out. We could move the definition of
    // cached-fp-addrs to the debrt library and make it responsibe for all
    // writes. debrt-protect-indirect only returns non-zero during that
    // start-up edge case where we throw a WARNING.
    //printf("ics_map_indirect_call: invoking protect-indirect\n");
    if(debrt_protect_indirect(fp_addr) == 0){
        //printf("ics_map_indirect_call: setting the cache\n");
        cached_fp_addrs[x].fp_addr = fp_addr;
        cached_fp_addrs[x].recorded = 0;
    }
    return 0;
}
}


// TODO unhandled edge case where an indirect call results in an SCC
//   loop
//     ics_foo()
//       ics_foo()
// This is all fine in terms of debloating. In terms of log output and
// training, it is a little weird.
// The second invocation of ics_foo() will get a cache hit in
// ics_map_indirect_call(). But you'll end up with some weird scenario for
// output. You'll get profiling/feature output from the first call to ics_foo()
// (ics_map_indirect_call()), but you'll get the trace output when the second
// one returns (due to ics_end_indirect_call()). We can live with that for
// now. It could break the parser but this seems rare and could be handled
// later.
extern "C" {
__attribute__((always_inline))
int ics_profile_end_indirect_call(long long fp_addr)
{
    long long x;
    //printf("ics_end_indirect_call for fp_addr: 0x%llx\n", fp_addr);

    x = fp_addr;
    HASH_ADDR(x);
    //printf("ics_map_indirect_call: hashed value is %lld\n", x);

    //printf("ics_end_indirect_call: checking for cached hit\n");
    // Linear scan
    // Not expected to ever iterate more than once or twice
    // Stop if we've hit an uninitialized spot (i.e. fp_addr == 0),
    long long x_start = x;
    while(cached_fp_addrs[x].fp_addr != 0){
        if(cached_fp_addrs[x].fp_addr == fp_addr){
            //printf("ics_end_indirect_call: found cached fp-addr\n");
            // found the cached address
            if(cached_fp_addrs[x].recorded == 0){
                //printf("ics_end_indirect_call: found the cached address. need to pop and dump\n");
                debrt_profile_update_recorded_funcs(2 /*pop and dump*/);
                // Update recorded to 1. We don't need to dump again.
                cached_fp_addrs[x].recorded = 1;
            }else{
                //printf("ics_end_indirect_call: found the cached address. just need to pop\n");
                // We have already recorded this ics value within the loop.
                // We still need to pop any recorded functions in the debloat
                // runtime.
                debrt_profile_update_recorded_funcs(1 /*pop*/);
            }

            return 0;
        }
        x = (x+1) & MAX_CACHED_FP_ADDRS_SZ;
        if(x == x_start){
            // hashmap is full
            // Not expected for our purposes.
            // We won't handle this case for now b/c it messes up our output.
            // FIXME... dont assert in a real version of this.
            assert(0 && "TODO implement dynamic hashmap support");
        }
    }

    // ...Execution reaches here if we scanned for the cached fp_addr but
    // didn't find it (and instead hit fp_addr == 0). Unexpected behavior.
    //assert(0 && "ERROR: Unexpected behavior. ics-end could not find the " \
    //            "cached fp-addr. Is there some mismatched instrumentation or " \
    //            "unexpected/unhandled control flow in the application?");
    printf("Unexpected behavior, safe to ignore at start-up: " \
           "ics-end could not find the " \
           "cached fp-addr. Is there some mismatched instrumentation or " \
           "unexpected/unhandled control flow in the application?\n");
    return 1;
}
}

extern "C" {
__attribute__((always_inline))
int ics_profile_wrapper_debrt_protect_loop_end(int loop_id)
{
    debrt_protect_loop_end(loop_id);
    memset(cached_fp_addrs, 0, sizeof(fp_addr_recorded_t) * MAX_CACHED_FP_ADDRS_SZ);
    return 0;
}
}



