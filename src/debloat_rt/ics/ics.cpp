//#include <set>
//
//extern "C" {int debrt_protect_indirect(long long);}
//extern "C" {int debrt_protect_ics_end(std::set<long long> *);}
//
//
//
//std::set<long long> cached_fp_addrs;
//
//
//extern "C" {
//__attribute__((always_inline))
//int ics_map_indirect_call(long long fp_addr)
//{
//    if(cached_fp_addrs.find(fp_addr) == cached_fp_addrs.end()){
//        debrt_protect_indirect(fp_addr);
//        cached_fp_addrs.insert(fp_addr);
//    }
//    return 0;
//}
//}
//
//extern "C" {
//__attribute__((always_inline))
//int ics_unmap_indirect_calls(long long notused)
//{
//    debrt_protect_ics_end(&cached_fp_addrs);
//    cached_fp_addrs.clear();
//    return 0;
//}
//}


#include <stdlib.h>
#include <string.h>

// Set the buffer size here.
// addresses are 8 bytes (long long)
//#define MAX_CACHED_FP_ADDRS_SZ 64 // 64 * 8 = 512 B buffer
#define MAX_CACHED_FP_ADDRS_SZ (1<<20) // 8 MB

extern "C" {int debrt_protect_indirect(long long);}
extern "C" {int debrt_protect_loop_end(int);}

long long cached_fp_addrs[MAX_CACHED_FP_ADDRS_SZ] = {0};
long long cached_fp_addrs_idx = 0;

extern "C" {
__attribute__((always_inline))
int ics_map_indirect_call(long long fp_addr)
{
    long long x;
    x = fp_addr;
    x = (x ^ (x >> 30)) * (0xbf58476d1ce4e5b9LL);
    x = (x ^ (x >> 27)) * (0x94d049bb133111ebLL);
    x = (x ^ (x >> 31)) % MAX_CACHED_FP_ADDRS_SZ;
    if(cached_fp_addrs[x] == fp_addr){
        return 0;
    }
    debrt_protect_indirect(fp_addr);
    cached_fp_addrs[x] = fp_addr;
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
