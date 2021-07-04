#include <set>

extern "C" {int debrt_protect_indirect(long long);}
extern "C" {int debrt_protect_ics_end(std::set<long long> *);}



std::set<long long> cached_fp_addrs;


extern "C" {
__attribute__((always_inline))
int ics_map_indirect_call(long long fp_addr)
{
    if(cached_fp_addrs.find(fp_addr) == cached_fp_addrs.end()){
        debrt_protect_indirect(fp_addr);
        cached_fp_addrs.insert(fp_addr);
    }
    return 0;
}
}

extern "C" {
__attribute__((always_inline))
int ics_unmap_indirect_calls(long long notused)
{
    debrt_protect_ics_end(&cached_fp_addrs);
    cached_fp_addrs.clear();
    return 0;
}
}
