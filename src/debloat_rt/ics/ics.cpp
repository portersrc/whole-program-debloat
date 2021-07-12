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


#define MAX_CACHED_FP_ADDRS_SZ 16
#include <stdlib.h>

extern "C" {int debrt_protect_indirect(long long);}

long long cached_fp_addrs[MAX_CACHED_FP_ADDRS_SZ];
long long cached_fp_addrs_idx = 0;

extern "C" {
__attribute__((always_inline))
int ics_map_indirect_call(long long fp_addr)
{
    int i;
    for(i = 0; i < cached_fp_addrs_idx; i++){
        if(cached_fp_addrs[i] == fp_addr){
            return 0;
        }
    }
    debrt_protect_indirect(fp_addr);
    cached_fp_addrs[cached_fp_addrs_idx] = fp_addr;
    cached_fp_addrs_idx = (cached_fp_addrs_idx + 1) % MAX_CACHED_FP_ADDRS_SZ;
    return 0;
}
}

    //x = (x ^ (x >> 30)) * UINT64_C(0xbf58476d1ce4e5b9);
    //x = (x ^ (x >> 27)) * UINT64_C(0x94d049bb133111eb);
    //x = x ^ (x >> 31);
