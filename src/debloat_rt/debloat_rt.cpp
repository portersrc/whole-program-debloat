#include <stdio.h>
#include <stdarg.h>
#include <stdlib.h>
#include <errno.h>                                                              
#include <assert.h>
#include <string.h>
#include <unistd.h>
#include <sys/mman.h>

#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include <vector>
#include <set>
#include <queue>
#include <map>
#include <stack>

#include "debrt_decision_tree.h"
//int debrt_decision_tree(const int *feature_vector) { return 0; }




using namespace std;

//#define DEBRT_DEBUG
// Adding DEBUG2 as a quick debug hack that doens't flood stdout
//#define DEBRT_DEBUG2
//#define DEBRT_ABSOLUTE_ELF_ADDRS



// to enable, set env var DEBRT_ENABLE_STATS=1
int ENV_DEBRT_ENABLE_STATS = 0;
// to enable, set env var DEBRT_ENABLE_STACK_CLEANING=1
int ENV_DEBRT_ENABLE_STACK_CLEANING = 0;
// to enable, set env var DEBRT_ENABLE_INDIRECT_CALL_SINKING=1
//int ENV_DEBRT_ENABLE_INDIRECT_CALL_SINKING = 0;
// to enable, set env var DEBRT_ENABLE_BASIC_INDIRECT_CALL_STATIC_ANALYSIS=1
int ENV_DEBRT_ENABLE_BASIC_INDIRECT_CALL_STATIC_ANALYSIS = 0;

// to enable, set env var DEBRT_ENABLE_PROFILING=1
// Will dump features and trace function calls
int ENV_DEBRT_ENABLE_PROFILING = 0;

// To enable, set env var DEBRT_ENABLE_TEST_PREDICTION=1
int ENV_DEBRT_ENABLE_TEST_PREDICTION = 0;

// To enable, set env var DEBRT_ENABLE_RELEASE=1
int ENV_DEBRT_ENABLE_RELEASE = 0;

#define DEBRT_INDIRECT_CALL_SINKING 1




#ifdef DEBRT_DEBUG
#define DEBRT_PRINTF(...) \
    do{ \
        printf(__VA_ARGS__); \
    }while(0)
#else
#define DEBRT_PRINTF(...)
#endif

#ifdef DEBRT_DEBUG2
#define DEBRT_PRINTF2(...) \
    do{ \
        printf(__VA_ARGS__); \
    }while(0)
#else
#define DEBRT_PRINTF2(...)
#endif


#define _WARN_RETURN_IF_NOT_INITIALIZED() \
    if(!lib_initialized){ \
        fprintf(stderr, "WARNING: debrt-protect called before lib was initialized. " \
                        "Ignoring debrt-protect call. (This may be OK if this " \
                        "happens at start-up due to an instrumented C++ " \
                        "constructor before main.)\n"); \
        return 1; \
    }


#define PAGE_SIZE 0x1000
#define RX_PERM   (PROT_READ | PROT_EXEC)
#define NO_PERM   (PROT_NONE)
#define RO_PERM   (PROT_READ)


int lib_initialized = 0;
int lib_destroyed = 0;


// XXX this could be read in? It varies based on the benchmark. we have
// an assert in case this is violated. Could double size or fix properly
// if that happens
const int MAX_NUM_FEATURES = 64;

const int CALLSITE_ID_IDX    = 0;
const int CALLED_FUNC_ID_IDX = 1;

const char *DEFAULT_OUTPUT_FILENAME = "debrt.out";
const char *DEBRT_MAPPED_PAGES_FILENAME = "debrt-mapped-rx-pages.out";
FILE *fp_out;
FILE *fp_mapped_pages;

// total number of text pages that can be protected
long long max_protected_text_pages;

int stats_total_mapped_pages = 0;
int start_had_to_align = 0;
int end_had_to_align = 0;

const char *PROFILE_CSV_COLUMNS = "deck_id," \
                                  "arg1," \
                                  "arg2," \
                                  "arg3," \
                                  "...";
//const char *PROFILE_OUTPUT_FILENAME = "debrt-profile.out";
//FILE *fp_profile_out;

//map<int, int> DEBUG_mispredict_func_ids;
//set<int> DEBUG_mispredict_func_ids_novel;
//set<int> DEBUG_mispredict_func_ids_novel_2;
//int DEBUG_last_func_set_id = -1;
//vector<int> DEBUG_predicted_func_set_ids;


vector<set<int> > func_sets;
vector<set<int> > complement_sets;
//set<int> *pred_set_p;
//set<int> *pred_set_complement_p;
vector<set<int> *> pred_sets;
vector<set<int> *> pred_set_complements;
unsigned long long num_func_calls = 0; // XXX only counts func calls if pred-sets.size > 0
unsigned long long num_func_calls_wrap = 0;
unsigned long long num_mispredictions = 0;
int pred_set_initialized = 0;
int rectification_happened = 0;
int default_prediction_flag = 0;

// A vector, indexed by function IDs.
// An element is 1 if the function ID should trigger rectification, i.e.
// the complement of the predicted set should be mapped. Else, it's 0.
int *debrt_rectification_flags;


// deprecated prediction stuff
//vector<set<int> > func_sets;
set<int> *pred_set_p_old;
int next_prediction_func_set_id;
//int num_mispredictions;
int total_predictions;
stack<set<int> *> pred_set_stack;
vector<int> single_stack;
set<int> ics_set;



void _init_page_to_count(void);

void _debrt_protect_destroy(void);
void _debrt_protect_all_pages(int perm);

void _remap_permissions(long long addr, long long size, int perm);


#define NUM_FEATURE_ELEMS 5
#define NUM_FEATURE_BUF_BIG_ELEMS (NUM_FEATURE_ELEMS * 100)
#define FP_IDX_BASE (NUM_FEATURE_BUF_BIG_ELEMS - NUM_FEATURE_ELEMS - 1)
int feature_buf_big[NUM_FEATURE_BUF_BIG_ELEMS];
int fb_idx = FP_IDX_BASE;


// The base and end addresses of our executable.
// Gotten from /proc/<pid>/maps.
long long executable_addr_base = 0;
long long executable_addr_end  = 0;

// The first page-aligned text address
long long text_start_aligned = 0;
// Somewhat of a misnomer, but it's the inverse of text_start_aligned.
// It's the last page-aligned text address, but importantly, the page
// also contains only .text (and doesn't collide with another section.)
long long text_end_aligned = 0;

// The .text section's offset address from the base address, and its size.
// Gotten from readelf --section output.
long long text_offset = 0;
long long text_size   = 0;


map<int, string>                 func_id_to_name; // convenience
map<int, pair<long long, long> > func_id_to_rel_addr_and_size;
map<int, set<int> >              func_id_to_reachable_funcs;
map<int, vector<long long> >     func_id_to_pages;
map<int, long long>              func_id_to_addr;

map<int, set<int> >              loop_id_to_reachable_funcs;
map<int, set<int> >              sink_id_to_funcs;

map<long long, set<int> >        func_addr_to_reachable_funcs;
map<long long, int>              func_addr_to_id;

map<string, int>       func_name_to_id;

set<int> encompassed_funcs;

set<string> ptd_to_funcs;
set<int>    ptd_to_func_ids;

map<long long, int> page_to_count;

vector<set<int> *> recorded_funcs_stack;


int *stats_hist;
unsigned long long ics_set_short_circuit_count = 0;


template<typename Out>
void split(const string &s, char delim, Out result)
{
    stringstream ss(s);
    string item;
    while(getline(ss, item, delim)){
        *(result++) = item;
    }
}
vector<string> split(const string &s, char delim)
{
    vector<string> elems;
    split(s, delim, back_inserter(elems));
    return elems;
}

// don't insert elements that are empty (so for example split(' ') on
// "a     b" will do the expected thing and return on ['a', 'b'])
template<typename Out>
void split_nonempty(const string &s, char delim, Out result)
{
    stringstream ss(s);
    string item;
    while(getline(ss, item, delim)){
        if(!item.empty()){
            *(result++) = item;
        }
    }
}
vector<string> split_nonempty(const string &s, char delim)
{
    vector<string> elems;
    split_nonempty(s, delim, back_inserter(elems));
    return elems;
}



static inline
void _stats_update_hist(void)
{
    if(ENV_DEBRT_ENABLE_STATS){
        // dynamically sized, so this assert should never hit
        assert(stats_total_mapped_pages <= max_protected_text_pages + 1);
        stats_hist[stats_total_mapped_pages]++;
    }
}




void _dump_func_name_to_id(void)
{
    for(map<string, int>::iterator it = func_name_to_id.begin(); it != func_name_to_id.end(); it++){
        cout << it->first << " " << it->second << endl;
    }
}

void _dump_func_id_to_pages(void)
{
    DEBRT_PRINTF("%s\n", __FUNCTION__);
    int i;
    int func_id;
    long long page;
    for(map<int, vector<long long> >::iterator it = func_id_to_pages.begin(); it != func_id_to_pages.end(); it++){
        func_id = it->first;
        auto pages    = it->second;
        for(i = 0; i < pages.size(); i++){
            DEBRT_PRINTF("%d: 0x%llx\n", func_id, pages[i]);
        }
    }
}

void _write_func_id_to_pages(void)
{
    FILE *fp_fitp;
    int i;
    int func_id;
    long long page;
    fp_fitp = fopen("artd_func_id_to_pages.txt", "w");
    for(map<int, vector<long long> >::iterator it = func_id_to_pages.begin(); it != func_id_to_pages.end(); it++){
        func_id = it->first;
        auto pages = it->second;
        fprintf(fp_fitp, "%d:", func_id);
        for(i = 0; i < pages.size(); i++){
            fprintf(fp_fitp, " %lld", (pages[i] - text_start_aligned) >> 12);
        }
        fprintf(fp_fitp, "\n");
    }
    fclose(fp_fitp);
}

void _dump_func_id_to_addr_and_size(void)
{
    DEBRT_PRINTF("%s\n", __FUNCTION__);
    int func_id;
    long long addr;
    long size;
    for(auto it = func_id_to_rel_addr_and_size.begin(); it != func_id_to_rel_addr_and_size.end(); it++){
        func_id = it->first;
        //pair<long long, long> addr_and_size = it->second;
        addr = it->second.first;
        size = it->second.second;
        //DEBRT_PRINTF("%d: 0x%llx %ld\n", func_id, addr_and_size[0], addr_and_size[1]);
        //DEBRT_PRINTF("%d:\n", func_id);
        DEBRT_PRINTF("%d (%s): 0x%llx %ld (0x%llx - 0x%llx)\n",
                     func_id,
                     func_id_to_name[func_id].c_str(),
                     addr,
                     size,
                     executable_addr_base + addr,
                     executable_addr_base + addr + size);
    }
}

void _dump_loop_static_reachability(void)
{
    int loop_id;
    DEBRT_PRINTF("%s\n", __FUNCTION__);
    for(auto p : loop_id_to_reachable_funcs){
        loop_id = p.first;
        DEBRT_PRINTF("%d: ", loop_id);
        for(auto reachable_func : p.second){
            DEBRT_PRINTF("%d ", reachable_func);
        }
        DEBRT_PRINTF("\n");
    }
}

void _dump_encompassed_funcs(void)
{
    DEBRT_PRINTF("%s\n", __FUNCTION__);
    for(auto func_id : encompassed_funcs){
        DEBRT_PRINTF("%d, ", func_id);
    }
    DEBRT_PRINTF("\n");
}

void _dump_sinks(void)
{
    int sink_id;
    DEBRT_PRINTF("%s\n", __FUNCTION__);
    for(auto p : sink_id_to_funcs){
        sink_id = p.first;
        DEBRT_PRINTF("%d: ", sink_id);
        for(auto func : p.second){
            DEBRT_PRINTF("%d ", func);
        }
        DEBRT_PRINTF("\n");
    }
}



void _remap_permissions(long long addr, long long size, int perm)
{
    char *aligned_addr_base;
    char *aligned_addr_end;
    int size_to_remap;


    aligned_addr_base = (char *) ((addr) & ~(PAGE_SIZE - 1));
    aligned_addr_end  = (char *) ((addr+size) & ~(PAGE_SIZE - 1));
    size_to_remap = PAGE_SIZE + (aligned_addr_end - aligned_addr_base);

    DEBRT_PRINTF("remap_permissions():\n");
    DEBRT_PRINTF("  aligned_addr_base: %p\n", aligned_addr_base);
    DEBRT_PRINTF("  aligned_addr_end:  %p\n", aligned_addr_end);
    DEBRT_PRINTF("  size_to_remap:     0x%x\n", size_to_remap);
    DEBRT_PRINTF("  permissions:       ");
    switch(perm){
    case RX_PERM: DEBRT_PRINTF("RX_PERM\n"); break;
    case RO_PERM: DEBRT_PRINTF("RO_PERM\n"); break;
    case NO_PERM: DEBRT_PRINTF("NO_PERM\n"); break;
    default: assert(0); break;
    }

    //perm = RX_PERM; // FIXME DEBUG ONLY
    //perm = RX_PERM; // FIXME DEBUG ONLY
    //perm = RX_PERM; // FIXME DEBUG ONLY
    //perm = RX_PERM; // FIXME DEBUG ONLY
    //perm = RX_PERM; // FIXME DEBUG ONLY
    //perm = RX_PERM; // FIXME DEBUG ONLY
    if(mprotect(aligned_addr_base, size_to_remap, perm) == -1){
        int e = errno;
        DEBRT_PRINTF("mprotect error (%d): %s\n", e, strerror(e));
        assert(0 && "mprotect error");
    }
    DEBRT_PRINTF("  mprotect succeeded\n");
}


#define NUM_MAPPED_FUNC_NODES 5
struct mapped_func_node_t{
    mapped_func_node_t(int func_id = 0,
                       vector<long long> *pages = NULL,
                       mapped_func_node_t *next = NULL,
                       mapped_func_node_t *prev = NULL) :
        func_id(func_id), pages(pages), next(next), prev(prev) {}
    int func_id;
    vector<long long> *pages;
    mapped_func_node_t *next;
    mapped_func_node_t *prev;
};

mapped_func_node_t *mapped_funcs_head;
mapped_func_node_t *mapped_funcs_tail;

mapped_func_node_t mapped_funcs_mem[NUM_MAPPED_FUNC_NODES+1];
mapped_func_node_t *mapped_funcs_free_mem = mapped_funcs_mem;

map<int, mapped_func_node_t *> func_id_to_mapped_func_node;

int num_elems_mapped_funcs = 0;


// enqueue at the tail
void add_node_to_tail(mapped_func_node_t *n)
{
    DEBRT_PRINTF("%s\n", __FUNCTION__);
    if(num_elems_mapped_funcs == 0){
        mapped_funcs_head = n;
        mapped_funcs_tail = n;
        n->prev = NULL;
        n->next = NULL;
        return;
    }
    mapped_funcs_tail->next = n;
    n->prev = mapped_funcs_tail;
    n->next = NULL;
    mapped_funcs_tail = n;
    DEBRT_PRINTF("%s: mapped funcs tail is %d\n", __FUNCTION__, mapped_funcs_tail->func_id);
}
mapped_func_node_t *enq(int func_id)
{
    DEBRT_PRINTF("%s\n", __FUNCTION__);
    mapped_func_node_t *n = mapped_funcs_free_mem;
    n->func_id = func_id;
    n->pages = &func_id_to_pages[func_id];
    add_node_to_tail(n);
    return n;
}

// dequeue from the head
mapped_func_node_t *deq(void)
{
    DEBRT_PRINTF("%s\n", __FUNCTION__);
    if(num_elems_mapped_funcs < NUM_MAPPED_FUNC_NODES){
        // XXX Assumption: We enqueue first, then dequeue
        num_elems_mapped_funcs++;
        mapped_funcs_free_mem = &mapped_funcs_mem[num_elems_mapped_funcs];
        return NULL;
    }
    mapped_funcs_free_mem = mapped_funcs_head;
    mapped_funcs_head = mapped_funcs_head->next;
    mapped_funcs_head->prev = NULL;
    return mapped_funcs_free_mem;
}

static inline
void _write_mapped_pages_to_file(int yes_stats_got_updated,
                                 bool is_grow,
                                 const string deck_type)
{
    long long page;
    int count;
    if(ENV_DEBRT_ENABLE_STATS){
        if(lib_destroyed){
            fprintf(stderr, "WARNING: tried to write-mapped-pages-to-file " \
              "after already calling destroy for library. Could be 'normal' " \
              "behavior if application's exit-handlers (like for deconstructors) " \
              "are still firing off. (Long-term profiling/stats fix: handle " \
              "these teardown cases more carefully.)\n");
            return;
        }
        if(is_grow){
            fprintf(fp_mapped_pages, "page-grow-%s ", deck_type.c_str());
        }else{
            fprintf(fp_mapped_pages, "page-shrink-%s ", deck_type.c_str());
        }
        if(yes_stats_got_updated){
            _stats_update_hist();
            for(auto p2c : page_to_count){
                page  = p2c.first;
                count = p2c.second;
                if(count > 0){
                    fprintf(fp_mapped_pages, "%lld ", (page - text_start_aligned) >> 12);
                }
            }
            fprintf(fp_mapped_pages, "\n");
        }else{
            fprintf(fp_mapped_pages, "X\n");
        }
    }
}

int update_page_counts(int func_id, int addend)
{
    static int debug_i = 0;
    int i;
    long long addr;
    //if(func_id_to_pages.find(func_id) == func_id_to_pages.end()){
    //    DEBRT_PRINTF("func id not in func-id-to-pages\n");
    //    *(int*)0 = 0;
    //}
    vector<long long> &pages = func_id_to_pages[func_id];
    int yes_stats_got_updated = 0;

    //
    // FIXME
    // FIXME
    // FIXME: revisit this. do as blocks, rather than
    // as individual pages.
    //

    DEBRT_PRINTF("%s\n", __FUNCTION__);
    DEBRT_PRINTF("update_page_counts func_id is %d\n", func_id);
    DEBRT_PRINTF("addend is %d\n", addend);
    DEBRT_PRINTF("pages.size(): %lu\n", pages.size());
    for(i = 0; i < pages.size(); i++){
        addr = pages[i];
        DEBRT_PRINTF("updating addr 0x%llx\n", addr);
        //if(page_to_count.find(addr) == page_to_count.end()){
        //    DEBRT_PRINTF("addr not in page-to-count\n");
        //    *(int*)0 = 0;
        //}
        //if(addr == 0x555555593000){
        //    debug_i++;
        //    DEBRT_PRINTF("seeing EXACT addr (%d)\n", debug_i);
        //}

        DEBRT_PRINTF("page_to_count[%lld] old: %d\n", addr, page_to_count[addr]);
        page_to_count[addr] += addend;
        DEBRT_PRINTF("page_to_count[%lld] new: %d\n", addr, page_to_count[addr]);

        if(page_to_count[addr] < 0){
            fprintf(stdout, "page_to_count[addr] < 0. exiting. " \
                            "addr(0x%llx) func_id(%d)\n", addr, func_id);
            exit(1);
        }
        if((page_to_count[addr] == 1) && (addend == 1)){
            DEBRT_PRINTF("went from 0 to 1, remap RX\n");
            _remap_permissions(addr, 1, RX_PERM);
            DEBRT_PRINTF("done RX\n");

            if(DEBRT_INDIRECT_CALL_SINKING
            || ENV_DEBRT_ENABLE_BASIC_INDIRECT_CALL_STATIC_ANALYSIS){
                if( (addr >= text_start_aligned)
                &&  (addr <=  text_end_aligned))
                {
                    stats_total_mapped_pages += 1;
                    yes_stats_got_updated = 1;
                }
            }else{
                if( (addr >= text_start_aligned)
                &&  (addr <=  text_end_aligned)
                &&  (ptd_to_func_ids.find(func_id) == ptd_to_func_ids.end()))
                {
                    stats_total_mapped_pages += 1;
                    yes_stats_got_updated = 1;
                }
            }

        }else if(page_to_count[addr] == 0){
            assert(addend == -1);
            DEBRT_PRINTF("went from 1 to 0, remap RO\n");
            // FIXME: This is a hacky fix for PLT. linker script or some
            // other solution needs to put .text at a page boundary (and
            // not in the same page as part of the plt.
            if(addr < text_start_aligned){
                DEBRT_PRINTF("addr is beneath executable addr base or part of " \
                             "first page. possibly part of .plt. ignoring " \
                             "mapping RO\n");
            }else if(addr > text_end_aligned){
                DEBRT_PRINTF("addr is above text end or part of last page. " \
                             "possibly part of .fini. ignoring mapping RO\n");
            }else{
                if(DEBRT_INDIRECT_CALL_SINKING
                || ENV_DEBRT_ENABLE_BASIC_INDIRECT_CALL_STATIC_ANALYSIS){
                    _remap_permissions(addr, 1, RO_PERM);
                    //_remap_permissions(addr, 1, RX_PERM);
                    stats_total_mapped_pages -= 1;
                    yes_stats_got_updated = 1;
                }else{
                    if(ptd_to_func_ids.find(func_id) != ptd_to_func_ids.end()){
                        DEBRT_PRINTF("NOT UNMAPPING page for func id %d (%s) b/c " \
                                     "it is pointed to\n",
                                     func_id,
                                     func_id_to_name[func_id].c_str());
                    }else{
                        _remap_permissions(addr, 1, RO_PERM);
                        //_remap_permissions(addr, 1, RX_PERM);
                        stats_total_mapped_pages -= 1;
                        yes_stats_got_updated = 1;
                    }
                }
            }
            DEBRT_PRINTF("done RO\n");
        }
    }
    return yes_stats_got_updated;
}

void _map_new_func_id(int func_id)
{
    mapped_func_node_t *new_node;
    mapped_func_node_t *old_node;

    DEBRT_PRINTF("%s\n", __FUNCTION__);
    update_page_counts(func_id, 1);
    new_node = enq(func_id);
    func_id_to_mapped_func_node[func_id] = new_node;
    assert(func_id_to_mapped_func_node.find(func_id)
           != func_id_to_mapped_func_node.end());
    old_node = deq();
    if(old_node){
        DEBRT_PRINTF("old node func id: %d\n", old_node->func_id);
        func_id_to_mapped_func_node.erase(old_node->func_id);
        update_page_counts(old_node->func_id, -1);
    }
}

void _update_node_age(mapped_func_node_t *n)
{
    DEBRT_PRINTF("%s\n", __FUNCTION__);
    if(n == mapped_funcs_tail){
        DEBRT_PRINTF("%s: n is tail\n", __FUNCTION__);
        // already at the end, which is the "youngest" position
        return;
    }

    if(n == mapped_funcs_head){
        DEBRT_PRINTF("%s: n is head\n", __FUNCTION__);
        mapped_funcs_head = mapped_funcs_head->next;
        mapped_funcs_head->prev = NULL;
    }else{
        // cut the node from the list
        DEBRT_PRINTF("%s: n is in the middle of the list\n", __FUNCTION__);
        n->prev->next = n->next;
        n->next->prev = n->prev;
    }

    add_node_to_tail(n);
}

void _update_mapped_pages(int func_id)
{
    long long first_page;
    long long last_page;
    long long size;
    DEBRT_PRINTF("%s\n", __FUNCTION__);

    if(func_id_to_pages.find(func_id) == func_id_to_pages.end()){
        DEBRT_PRINTF("ERROR: seeing func id not in my map: %d\n", func_id);
        return;
    }

    auto n = func_id_to_mapped_func_node.find(func_id);
    if(n == func_id_to_mapped_func_node.end()){
        _map_new_func_id(func_id);
    }else{
        _update_node_age(n->second);
    }
}

void _assert_return_addr_in_main(long long return_addr)
{
    int func_id;
    assert(func_name_to_id.find("main") != func_name_to_id.end());
    func_id = func_name_to_id["main"];
    DEBRT_PRINTF("return_addr of first debrt-protect call 0x%llx\n", return_addr);
    pair<long long, long> addr_and_size = func_id_to_rel_addr_and_size[func_id];
    assert(return_addr >= executable_addr_base + addr_and_size.first);
    assert(return_addr  < executable_addr_base + addr_and_size.first + addr_and_size.second);
}


// Read the all func set IDs and their corresponding func IDs into an array
// of sets called "func_sets". func_sets is indexed by the func set ID. Each
// element is a set of integers, which are the function IDs of that func set.
//
// Example file (which is created by parse_artd_profile_log.py):
//   predicted_func_set_id,called_func_id1,called_func_id2,...
//   0,114
//   1,92
//   2,98
//   3,16,22,67
void _read_func_sets(void)
{
    int i;
    int k;
    string line;
    ifstream ifs;
    vector<string> elems;
    int func_set_id;

    ifs.open("func-set-id-to-funcs.out");
    if(!ifs.is_open()) {
        fprintf(stderr, "ERROR: Failed to open func-set-id-to-funcs.out.\n");
        exit(EXIT_FAILURE);
    }

    // Construct "func_sets". It's indexed by func set ID. Each element is a
    // a set of function ID.
    i = 0;
    getline(ifs, line); // parse out the header

    while(getline(ifs, line)){
        vector<int> func_ids;
        elems = split(line, ',');
        func_set_id = atoi(elems[0].c_str());
        assert(func_set_id == i);
        for(k = 1; k < elems.size(); k++){
            func_ids.push_back(atoi(elems[k].c_str()));
        }
        set<int> func_id_set(func_ids.begin(), func_ids.end());
        func_sets.push_back(func_id_set);
        complement_sets.push_back(set<int>());
        i++;
    }

    ifs.close();
}

// ASSUMPTION: _read_func_sets is called first. It initializes complement_sets
// with empty sets.
void _read_complement_sets(void)
{
    int i;
    int k;
    string line;
    ifstream ifs;
    vector<string> elems;
    int func_set_id;

    printf("reading complement sets\n");

    ifs.open("func-set-id-to-complements.out");
    if(!ifs.is_open()) {
        fprintf(stderr, "ERROR: Failed to open func-set-id-to-funcs.out.\n");
        exit(EXIT_FAILURE);
    }

    // Construct "complement_sets". It's indexed by func set ID. Each element is a
    // a set of function ID.
    i = 0;
    getline(ifs, line); // parse out the header

    while(getline(ifs, line)){
        vector<int> func_ids;
        elems = split(line, ',');
        func_set_id = atoi(elems[0].c_str());
        assert(func_set_id == i);
        //for(k = 1; k < elems.size(); k++){
        //    func_ids.push_back(atoi(elems[k].c_str()));
        //}
        //set<int> func_id_set(func_ids.begin(), func_ids.end());
        //complement_sets.push_back(func_id_set);
        for(k = 1; k < elems.size(); k++){
            complement_sets[i].insert(atoi(elems[k].c_str()));
        }
        i++;
    }

    ifs.close();
}




void _read_readelf(void)
{
    //vector<string> elems;
    int k;
    string line;
    ifstream ifs;
    int token_start;
    int token_end;
    int token_count;
    string token;

    enum READELF_COLS {
        RELF_NUM = 0,
        RELF_VALUE,
        RELF_SIZE,
        RELF_TYPE,
        RELF_BIND,
        RELF_VIS,
        RELF_NDX,
        RELF_NAME
    };
    int idx;
    int which_token;
    string func_name;
    long long func_addr;
    long func_size;

    ifs.open("readelf.out");
    if(!ifs.is_open()){
        perror("Error opening readelf file");
        exit(EXIT_FAILURE);
    }

    while(getline(ifs, line)){

        token_count = 0;
        idx = 0;
        while(idx < line.size() && line.at(idx) != '\n'){
            //DEBRT_PRINTF("%c", line.at(idx));
            //idx++;
            while(idx < line.size() && line.at(idx) == ' '){
                idx++;
            }
            token_start = idx;
            while(idx < line.size() && line.at(idx) != ' ' && line[idx] != '\n'){
                idx++;
            }
            token_end = idx;
            token = line.substr(token_start, token_end - token_start);

            which_token = token_count;

            // func addr
            if(which_token == RELF_VALUE){
                func_addr = strtoll(token.c_str(), NULL, 16);

            }else if(which_token == RELF_SIZE){
                // infer base by passing "0". almost always 10 but ive seen 16
                // in at least one perlbench function
                func_size = strtol(token.c_str(), NULL, 0);

            // func name
            }else if(which_token == RELF_NAME){
                func_name = token;
                // check that the name is part of whatever we got in nm.
                if(func_name_to_id.find(func_name) != func_name_to_id.end()){
                    int func_id = func_name_to_id[func_name];
                    func_id_to_rel_addr_and_size[func_id] = make_pair(func_addr, func_size);
#ifdef DEBRT_ABSOLUTE_ELF_ADDRS
                    func_addr_to_id[func_addr] = func_id;
                    func_id_to_addr[func_id] = func_addr;
#else
                    func_addr_to_id[executable_addr_base + func_addr] = func_id;
                    func_id_to_addr[func_id] = executable_addr_base + func_addr;
#endif
                    vector<long long> pages;
                    long long first_page;
                    long long last_page;
                    long long p;
#ifdef DEBRT_ABSOLUTE_ELF_ADDRS
                    first_page = (func_addr) & ~(PAGE_SIZE-1);
                    last_page  = (func_addr + func_size) & ~(PAGE_SIZE-1);
#else
                    first_page = (executable_addr_base + func_addr) & ~(PAGE_SIZE-1);
                    last_page  = (executable_addr_base + func_addr + func_size) & ~(PAGE_SIZE-1);
#endif
                    for(p = first_page; p <= last_page; p += 0x1000){
                        pages.push_back(p);
                    }
                    func_id_to_pages[func_id] = pages;
                }
                //cout << func_name <<  " " << func_addr << " " << func_size << endl;
            }
            token_count++;
        }
        //cout << endl;
    }
    ifs.close();
}


void _read_readelf_sections(void)
{
    DEBRT_PRINTF("%s\n", __FUNCTION__);
    ifstream ifs;
    string line;
    vector<string> elems;
    ifs.open("readelf-sections.out");
    if(!ifs.is_open()){
        perror("Error openening readelf-sections file");
        exit(EXIT_FAILURE);
    }
    while(getline(ifs, line)){
        elems = split_nonempty(line, ' ');
        int text_offset_idx = 0;
        if(elems.size() >= 2 && elems[1].compare(".text") == 0){
            text_offset_idx = 3;
        }else if(elems.size() >= 3 && elems[2].compare(".text") == 0){
            text_offset_idx = 5;
        }
        if(text_offset_idx){
            text_offset = stoll(elems[text_offset_idx], 0, 16);
            getline(ifs, line);
            elems = split_nonempty(line, ' ');
            text_size = stoll(elems[0], 0, 16);
            DEBRT_PRINTF("text_offset is: 0x%llx\n", text_offset);
            DEBRT_PRINTF("text_size is:   0x%llx\n", text_size);
            break;
        }
    }
    ifs.close();
    if(text_size == 0 || text_offset == 0){
        fprintf(stderr, "ERROR: text size and offset should be non-zero\n");
        exit(1);
    }
}


// We need to parse the /proc/<pid>/maps file to answer the following question:
//   What's the base address of the instruction code of the binary?
//
// Each line of the file holds a memory mapping.
// Parse 3 pieces of information on each line:
//   What's the base address of the mapping?
//   Is the mapping executable?
//   Is the mapping of our binary (or is it just some other shared object)?
//
// If it's executable and if it's our binary, then we've found the mapping
// we care about, and the answer to our question is just the base address
// for that line.
// Notice that we still check every line to make sure there is only one
// line with our binary that is executable. If we find more than one of these
// lines, it means our assumptions were wrong, and we assert.
// If that happens, I need to look more closely. I'll need to figure out how to
// determine all such mappings and how to handle them for the purpose of finding
// each page in memory for every function in the binary.
void _set_addr_of_main_mapping(void)
{
    #define MAPPING_FILENAME_SZ 128
    #define MAPPING_LINE_SZ 512
    FILE *fp;
    char mapping_filename[MAPPING_FILENAME_SZ];
    char line[MAPPING_LINE_SZ];
    int num_spaces;

    DEBRT_PRINTF("%s with pid %d\n", __FUNCTION__, getpid());
    snprintf(mapping_filename, MAPPING_FILENAME_SZ, "/proc/%d/maps", getpid());
    fp = fopen(mapping_filename, "r");

    enum STATES {
        GET_BASE_ADDR = 0,
        GET_IS_EXECUTABLE,
        GET_BINARY_NAME,
        COMPLETE
    };
    int state;

    state = GET_BASE_ADDR;

    int num_executable_binary_lines;
    num_executable_binary_lines = 0;
    while(fgets(line, MAPPING_LINE_SZ, fp)){
        //DEBRT_PRINTF("%s", line);

        // TODO: Should have used sscanf originally when I wrote this code;
        // I grabbed this sscanf example off SO or somewhere and massaged it.
        // I believe it works but this function should be rewritten completely
        // and something like this should be used.
        //long long start;
        //long long end;
        //char flags[32];
        //unsigned long long file_offset;
        //unsigned int dev_major;
        //unsigned int dev_minor;
        //unsigned long long inode;
        //char binname[256];
        //sscanf(line,"%llx-%llx %31s %llx %x:%x %llu %s", &start, &end, flags, &file_offset, &dev_major, &dev_minor, &inode, binname);
        //DEBRT_PRINTF("start: %llx\n", start);
        //DEBRT_PRINTF("end: %llx\n", end);
        //DEBRT_PRINTF("first line is %s", line);

        num_spaces = 0;
        long long addr_base;
        long long addr_end;
        char *binary_name;
        char *c = line;
        state = GET_BASE_ADDR;
        //vector<string> elems = split_nonempty(line, ' ');
        //cout << "last elem: " << elems[5] << endl;
        //goto workaround;
        while(*c){
            if(state == GET_BASE_ADDR && *c == '-'){
                //printf("state was GET_BASE_ADDR\n");
                *c = '\0';
                addr_base = strtoll(line, NULL, 16);
                c++;
                addr_end = strtoll(c, NULL, 16);
                state++;
                // FIXME super hacky now.. looks like executable is
                // always that first line. So just grab it and ignore all
                // the rest. this entire function needs to be rewritten.
                DEBRT_PRINTF("super hacky workaround\n");
                DEBRT_PRINTF("line is: %s\n", line);
                DEBRT_PRINTF("addr_base: 0x%llx\n", addr_base);
                DEBRT_PRINTF("addr_end:  0x%llx\n", addr_end);
                num_executable_binary_lines++;
                executable_addr_base = addr_base;
                executable_addr_end  = addr_end;
                goto workaround;
                continue;
            }
            if(state == GET_IS_EXECUTABLE && *c == ' '){
                //printf("state was GET_IS_EXECUTABLE\n");
                num_spaces++;
                c++;
                //printf("c[0,1,2,3] is %c%c%c%c\n", c[0],c[1],c[2],c[3]);
                if(c[2] == 'x'){
                    //printf("found executable\n");
                    state++;
                    c += 4;
                    continue;
                }
                break;
            }
            if(state == GET_BINARY_NAME && *c == ' '){
                //printf("state was GET_BINARY_NAME\n");
                num_spaces++;
                if(num_spaces == 5){
                    while(*c == ' '){
                        c++;
                    }
                    binary_name = c;
                    while(*c != '\n'){
                        c++;
                    }
                    *c = '\0';
                    c++;
                    state++;
                    if(strstr(binary_name, getenv("_")+2) != NULL){
                        num_executable_binary_lines++;
                        executable_addr_base = addr_base;
                        executable_addr_end  = addr_end;
                        DEBRT_PRINTF("healthy workaround\n");
                        goto workaround;
                    }
                    // XXX hacky fix. Seems that this complicated parsing code
                    // wasn't necessary , b/c the executable section seems to
                    // always be the first line. If that assumption is wrong,
                    // the above code will still work, though, and this GDB
                    // workaround here is broken... which is bad but better
                    // than the opposite.
                    if(strstr("/usr/bin/gdb", getenv("_"))){
                        num_executable_binary_lines++;
                        executable_addr_base = addr_base;
                        executable_addr_end  = addr_end;
                        DEBRT_PRINTF("gdb workaround\n");
                        goto gdb_workaround;
                    }
                    //if(strstr("valgrind", getenv("_"))){
                    //    DEBRT_PRINTF("valgrind workaround\n");
                    //    num_executable_binary_lines++;
                    //    executable_addr_base = addr_base;
                    //    executable_addr_end  = addr_end;
                    //    goto gdb_workaround;
                    //}
                }
            }
            c++;
        }
    }
workaround:
gdb_workaround:
    //DEBRT_PRINTF("num exec lines: %d\n", num_executable_binary_lines);
    //cout << "2 my pid is " << getpid() << endl;
    //cout << "2 getenv is " << getenv("_") << endl;
    //cout << "2 check maps file: /proc/" << getpid() << "/maps" << endl;
    //while(1){
    //    sleep(10);
    //}
    assert(num_executable_binary_lines == 1);


    fclose(fp);

    assert(executable_addr_base);
    assert(executable_addr_end);
}

void _read_func_name_to_id(void)
{
    string line;
    ifstream ifs;
    vector<string> elems;

    ifs.open("artd_func_name_to_id.txt");
    if(!ifs.is_open()){
        perror("Error openening artd-func-name-to-id file");
        exit(EXIT_FAILURE);
    }

    while(getline(ifs, line)){
        elems = split(line, ' ');
        assert(elems.size() == 2);
        func_name_to_id[elems[0]] = atoi(elems[1].c_str());
        func_id_to_name[atoi(elems[1].c_str())] = elems[0];
    }
    ifs.close();
}

void _read_func_ptrs(void)
{
    string line;
    ifstream ifs;
    vector<string> elems;

    ifs.open("artd_func_name_has_addr_taken.txt");
    if(!ifs.is_open()){
        perror("Error openening artd-func-name-has-addr-taken file");
        exit(EXIT_FAILURE);
    }

    while(getline(ifs, line)){
        ptd_to_funcs.insert(line);
        assert(func_name_to_id.find(line) != func_name_to_id.end());
        ptd_to_func_ids.insert(func_name_to_id[line]);
    }
    ifs.close();

    for(auto ptf : ptd_to_funcs) {
        DEBRT_PRINTF("pointed to func: %s\n", ptf.c_str());
    }
}

void _read_static_reachability(void)
{
    DEBRT_PRINTF("reading static reachability\n");
    // read the function ID -> statically reachable functions
    string line;
    ifstream ifs;
    vector<string> elems;
    vector<string> elems_reachable;
    int func_id;
    int reachable_func_id;
    long long addr;

    ifs.open("artd_static_reachability.txt");
    if(!ifs.is_open()){
        perror("Error opening artd_static_reachability.txt file");
        exit(EXIT_FAILURE);
    }

    while(getline(ifs, line)){
        elems = split(line, ' ');
        func_id = atoi(elems[0].c_str());
        addr = func_id_to_addr[func_id];
        if(elems.size() == 1){
            continue;
        }
        elems_reachable = split(elems[1], ','); // seems to correclty ignore trailing comma
        //printf("elems_reachable.size()==%lu ", elems_reachable.size());
        //printf("  %d: ", func_id);
        for(auto f : elems_reachable){
            if(f == ""){
                continue;
            }
            reachable_func_id = atoi(f.c_str());
            // note: two different sets in memory
            func_id_to_reachable_funcs[func_id].insert(reachable_func_id);
            func_addr_to_reachable_funcs[addr].insert(reachable_func_id);
            //printf("%d,", atoi(f.c_str()));
        }
        //printf("\n");
    }
    ifs.close();

}
void _read_encompassed_funcs(void)
{
    DEBRT_PRINTF("reading encompassed funcs\n");
    string line;
    ifstream ifs;
    vector<string> elems;
    vector<string> elems_reachable;
    int func_id;
    int reachable_func_id;
    long long addr;

    ifs.open("artd_encompassed_funcs.txt");
    if(!ifs.is_open()){
        perror("Error opening artd_encompassed_funcs.txt file");
        exit(EXIT_FAILURE);
    }
    while(getline(ifs, line)){
        elems = split(line, ' ');
        assert(elems.size() == 2);
        func_id = atoi(elems[0].c_str());
        encompassed_funcs.insert(func_id);
        // elems[1] is func name for convenience. can ignore.
    }
    ifs.close();

}

void _read_loop_static_reachability(int sink_is_enabled)
{
    DEBRT_PRINTF("reading loop static reachability\n");
    string line;
    ifstream ifs;
    vector<string> elems;
    vector<string> elems_reachable;
    int func_id;
    int reachable_func_id;

    if(sink_is_enabled){
        ifs.open("artd_loop_static_reachability_sinkenabled.txt");
    }else{
        ifs.open("artd_loop_static_reachability.txt");
    }
    if(!ifs.is_open()){
        if(sink_is_enabled){
            perror("Error opening artd_loop_static_reachability_sinkenabled.txt file");
        }else{
            perror("Error opening artd_loop_static_reachability.txt file");
        }
        exit(EXIT_FAILURE);
    }

    while(getline(ifs, line)){
        elems = split(line, ' ');
        func_id = atoi(elems[0].c_str());
        if(elems.size() == 1){
            continue;
        }
        elems_reachable = split(elems[1], ','); // seems to correclty ignore trailing comma
        //printf("elems_reachable.size()==%lu ", elems_reachable.size());
        //printf("  %d: ", func_id);
        for(auto f : elems_reachable){
            if(f == ""){
                continue;
            }
            reachable_func_id = atoi(f.c_str());
            loop_id_to_reachable_funcs[func_id].insert(reachable_func_id);
            //printf("%d,", atoi(f.c_str()));
        }
        //printf("\n");
    }
    ifs.close();

}

void _read_sinks(void)
{
    DEBRT_PRINTF("reading sinks\n");
    string line;
    ifstream ifs;
    vector<string> elems;
    vector<string> elems_reachable;
    int sink_id;
    int func_id;

    ifs.open("artd_sinks.txt");
    if(!ifs.is_open()){
        perror("Error opening artd_sinks.txt file");
        exit(EXIT_FAILURE);
    }

    while(getline(ifs, line)){
        elems = split(line, ' ');
        sink_id = atoi(elems[0].c_str());
        if(elems.size() == 1){
            continue;
        }
        elems_reachable = split(elems[1], ','); // seems to correclty ignore trailing comma
        //printf("elems_reachable.size()==%lu ", elems_reachable.size());
        //printf("  %d: ", sink_id);
        for(auto f : elems_reachable){
            if(f == ""){
                continue;
            }
            func_id = atoi(f.c_str());
            sink_id_to_funcs[sink_id].insert(func_id);
            //printf("%d,", atoi(f.c_str()));
        }
        //printf("\n");
    }
    ifs.close();

}


void _debrt_protect_all_pages(int perm)
{
    DEBRT_PRINTF("PROTECTING ALL PAGES\n");
    //perm = RX_PERM; // FIXME DEBUG ONLY
    //perm = RX_PERM; // FIXME DEBUG ONLY
    //perm = RX_PERM; // FIXME DEBUG ONLY
    //perm = RX_PERM; // FIXME DEBUG ONLY
    //perm = RX_PERM; // FIXME DEBUG ONLY
    //perm = RX_PERM; // FIXME DEBUG ONLY
    long long text_start = executable_addr_base + text_offset;
    long long text_end   = text_start + text_size;
    text_start_aligned = text_start & ~(0x1000-1);
    text_end_aligned   = text_end   & ~(0x1000-1);
    if(text_start_aligned >= text_end_aligned){
        // Aligned .text start should never be above end
        assert(text_start_aligned == text_end_aligned);
        // ...but they can be equal if it's a small .text section.
        // Print warning to stdout for now, but continue.
        // Any remapping attempts to RO are handled elsewhere and
        // should have a similar treatment (i.e. never map RO any pages
        // at the boundaries).
        printf("WARNING: text start and end are equal. " \
               "Program is too small for a page-based technique.\n");
        return;
    }
    // Check if text_start was already aligned. If it wasn't we need to bump
    // our starting (aligned) page. We go up by 1 page, b/c o/w we'd mark shit
    // that's not in .text when marking the starting page.... do similarly
    // for the end
    if(text_start & (0x1000-1)){ // if not orignially aligned
        text_start_aligned += 0x1000; // bump the starting (aligned) page by 1
        start_had_to_align = 1;
    }
    if(text_end & (0x1000-1)){
        text_end_aligned   -= 0x1000;
        end_had_to_align = 1;
    }
    DEBRT_PRINTF("text_start_aligned: 0x%llx\n", text_start_aligned);
    DEBRT_PRINTF("text_end_aligned: 0x%llx\n", text_end_aligned);
    // FIXME: Should be text_end_aligned - text_start_aligned + 0x1000, i think
    int rc = mprotect((void *)text_start_aligned, text_end_aligned - text_start_aligned, perm);
    if(rc == -1){
        int e = errno;
        DEBRT_PRINTF("mprotect error (%d): %s\n", e, strerror(e));
        assert(0 && "mprotect error");
    }
    DEBRT_PRINTF("  mprotect succeeded\n");
    DEBRT_PRINTF("text_start_aligned: 0x%llx\n", text_start_aligned);
    DEBRT_PRINTF("text_end_aligned: 0x%llx\n", text_end_aligned);
    max_protected_text_pages = (text_end_aligned - text_start_aligned + 0x1000) / PAGE_SIZE;
    DEBRT_PRINTF("PROTECTED TEXT SEGMENT SIZE (BYTES_HEX, BYTES_DECIMAL, " \
                 "NUM_PAGES): 0x%llx %lld %lld\n",
                 text_end_aligned - text_start_aligned + 0x1000,
                 text_end_aligned - text_start_aligned + 0x1000,
                 max_protected_text_pages);
    fprintf(fp_out,
                 "PROTECTED TEXT SEGMENT SIZE (BYTES_HEX, BYTES_DECIMAL, " \
                 "NUM_PAGES): 0x%llx %lld %lld\n",
                 text_end_aligned - text_start_aligned + 0x1000,
                 text_end_aligned - text_start_aligned + 0x1000,
                 max_protected_text_pages);

    if(ENV_DEBRT_ENABLE_STATS){
        // kind of a hack. this func gets called at both start-up and teardown.
        // just initialize on start-up
        if(stats_hist == NULL){
            // + 1 because our 0th index represents 0 mapped pages
            stats_hist = (int *) calloc(max_protected_text_pages + 1, sizeof(int));
        }
    }
}

void _debrt_map_ptd_to_funcs(void)
{
    DEBRT_PRINTF("mapping RX any pages of ptd-to funcs\n");
    for(auto func_id : ptd_to_func_ids){
        update_page_counts(func_id, 1);
        for(auto reachable_func_id : func_id_to_reachable_funcs[func_id]){
            update_page_counts(reachable_func_id, 1);
        }
    }
}

void _init_page_to_count(void)
{
    int i;
    int func_id;
    long long page;
    for(map<int, vector<long long> >::iterator it = func_id_to_pages.begin();
      it != func_id_to_pages.end();
      it++){
        func_id = it->first;
        vector<long long> &pages = it->second;
        for(i = 0; i < pages.size(); i++){
            page = pages[i];
            if(page_to_count.find(page) == page_to_count.end()){
                page_to_count[page] = 0;
            }
        }
    }
}




void _debrt_protect_destroy(void)
{
    int e;
    int rc;
    int i;

    if(lib_destroyed){
        return;
    }
    lib_destroyed = 1;

    _debrt_protect_all_pages(RX_PERM);

    //fprintf(fp_out, "DEBUG_mispredict_func_ids:\n");
    //for(auto func_id_count : DEBUG_mispredict_func_ids){
    //    int func_id = func_id_count.first;
    //    int count = func_id_count.second;
    //    fprintf(fp_out, "  %d: %d\n", func_id, count);
    //}
    //fprintf(fp_out, "\n");

    //fprintf(fp_out, "DEBUG_mispredict_func_ids_novel:\n");
    //for(auto x : DEBUG_mispredict_func_ids_novel){
    //    fprintf(fp_out, "  %d,", x);
    //}
    //fprintf(fp_out, "\n");

    //fprintf(fp_out, "DEBUG_mispredict_func_ids_novel_2 (size: %lu):\n",
    //   DEBUG_mispredict_func_ids_novel_2.size());
    //for(auto x : DEBUG_mispredict_func_ids_novel_2){
    //    fprintf(fp_out, "  %d,", x);
    //}
    //fprintf(fp_out, "\n");

    //fprintf(fp_out, "total_predictions:  %d\n", total_predictions);
    fprintf(fp_out, "num_mispredictions:    %llu\n", num_mispredictions);
    fprintf(fp_out, "num_func_calls:        %llu\n", num_func_calls);
    fprintf(fp_out, "num_func_calls_wrap:   %llu\n", num_func_calls_wrap);
    if(num_func_calls_wrap){
        fprintf(fp_out, "WARNING: trace count wrapped. Need to adjust num_func_calls accordingly (64-bit unsigned counter) and should probably add support for num_mispredictions_wrap, as well.\n");
    }
    fprintf(fp_out, "ics_set_short_circuit_count: %llu\n", ics_set_short_circuit_count);

    if(ENV_DEBRT_ENABLE_STATS){
        fprintf(fp_out, "hist: ");
        for(i = 0; i < max_protected_text_pages+1; i++){
            fprintf(fp_out, "%d ", stats_hist[i]);
        }
        fprintf(fp_out, "\n");
        free(stats_hist);
    }

    // max_protected_text_pages doesn't include the first and/or last page,
    // if those pages collided with another section (for now). If there
    // are only a handful of pages in the program, these  unprotected pages
    // could be significant. For large programs, it's not as important.
    // FIXME: we want to align the first page anyway and have the last
    // text page not collide with the next section; so this should go away
    // eventually.
    fprintf(fp_out, "Unprotected pages lost at start and/or end due to " \
                    "alignment: %d\n", start_had_to_align + end_had_to_align);

    rc = fclose(fp_out);
    if(rc == EOF){
        e = errno;
        fprintf(stderr, "_debrt_protect_destroy failed to close output file " \
                        "(errno: %d)\n", e);
    }

    rc = fclose(fp_mapped_pages);
    if(rc == EOF){
        e = errno;
        fprintf(stderr, "_debrt_protect_destroy failed to close mapped pages " \
                        "output file (errno: %d)\n", e);
    }
}







int _profile_init(void)
{
    //int e;
    //const char *output_filename;

    //output_filename = getenv("DEBRT_PROFILE_OUT");
    //if(!output_filename){
    //    output_filename = PROFILE_OUTPUT_FILENAME;
    //}
    //fp_profile_out = fopen(output_filename, "w");
    //if(!fp_profile_out){
    //    e = errno;
    //    fprintf(stderr, "_profile_init failed to open %s (errno: %d)\n",
    //                    output_filename, e);
    //    return e;
    //}
    //fprintf(fp_profile_out, "%s\n", PROFILE_CSV_COLUMNS);

    //fprintf(fp_mapped_pages, "%s\n", PROFILE_CSV_COLUMNS);

    return 0;
}

extern "C" {
int debrt_init(int main_func_id, int sink_is_enabled)
{
    int e;
    const char *output_filename;
    DEBRT_PRINTF("%s\n", __FUNCTION__);
    DEBRT_PRINTF("main_func_id: %d\n", main_func_id);
    DEBRT_PRINTF("sink_is_enabled: %d\n", sink_is_enabled);

    // FIXME should test these env vars are the string "1". Otherwise if
    // someone passes "0", these if-checks evaluate to true, which isn't what
    // we want.
    if(getenv("DEBRT_ENABLE_STATS")){
        ENV_DEBRT_ENABLE_STATS = 1;
    }
    if(getenv("DEBRT_ENABLE_STACK_CLEANING")){
        ENV_DEBRT_ENABLE_STACK_CLEANING = 1;
    }
    //if(getenv("DEBRT_ENABLE_INDIRECT_CALL_SINKING")){
    //    ENV_DEBRT_ENABLE_INDIRECT_CALL_SINKING = 1;
    //}
    if(getenv("DEBRT_ENABLE_BASIC_INDIRECT_CALL_STATIC_ANALYSIS")){
        ENV_DEBRT_ENABLE_BASIC_INDIRECT_CALL_STATIC_ANALYSIS = 1;
    }
    if(getenv("DEBRT_ENABLE_PROFILING")){
        ENV_DEBRT_ENABLE_PROFILING = 1;
    }
    if(getenv("DEBRT_ENABLE_TEST_PREDICTION")){
        ENV_DEBRT_ENABLE_TEST_PREDICTION = 1;
    }
    if(getenv("DEBRT_ENABLE_RELEASE")){
        ENV_DEBRT_ENABLE_RELEASE = 1;
    }
    DEBRT_PRINTF("ENV_DEBRT_ENABLE_RELEASE: %d\n", ENV_DEBRT_ENABLE_RELEASE);
    DEBRT_PRINTF("ENV_DEBRT_ENABLE_TEST_PREDICTION: %d\n", ENV_DEBRT_ENABLE_TEST_PREDICTION);
    DEBRT_PRINTF("ENV_DEBRT_ENABLE_STATS: %d\n", ENV_DEBRT_ENABLE_STATS);
    DEBRT_PRINTF("ENV_DEBRT_ENABLE_STACK_CLEANING: %d\n", ENV_DEBRT_ENABLE_STACK_CLEANING);
    //DEBRT_PRINTF("ENV_DEBRT_ENABLE_INDIRECT_CALL_SINKING: %d\n", ENV_DEBRT_ENABLE_INDIRECT_CALL_SINKING);
    DEBRT_PRINTF("ENV_DEBRT_ENABLE_BASIC_INDIRECT_CALL_STATIC_ANALYSIS: %d\n", ENV_DEBRT_ENABLE_BASIC_INDIRECT_CALL_STATIC_ANALYSIS);
    output_filename = getenv("DEBRT_OUT");
    if(!output_filename){
        output_filename = DEFAULT_OUTPUT_FILENAME;
    }
    fp_out = fopen(output_filename, "w");
    if(!fp_out){
        e = errno;
        fprintf(stderr, "debrt_init failed to open %s (errno: %d)\n",
                        output_filename, e);
        return e;
    }
    fp_mapped_pages = fopen(DEBRT_MAPPED_PAGES_FILENAME, "w");
    if(!fp_mapped_pages){
        e = errno;
        fprintf(stderr, "debrt_init failed to open %s (errno: %d)\n",
                        DEBRT_MAPPED_PAGES_FILENAME, e);
        return e;
    }

    _set_addr_of_main_mapping();
    DEBRT_PRINTF("executable_addr_base: 0x%llx\n", executable_addr_base);
    DEBRT_PRINTF("executable_addr_end:  0x%llx\n", executable_addr_end);

    // XXX read func-name-to-id before the other steps
    _read_func_name_to_id();
    //_dump_func_name_to_id();

    _read_func_ptrs();
    _read_readelf();
    _read_readelf_sections();
    _read_static_reachability();
    _read_loop_static_reachability(sink_is_enabled);
    _read_encompassed_funcs();
    _read_sinks();
    if(ENV_DEBRT_ENABLE_TEST_PREDICTION){
        _read_func_sets();
    }
    if(ENV_DEBRT_ENABLE_RELEASE){
        _read_func_sets(); // also initializes complement_set with empty sets.
        _read_complement_sets();
        debrt_rectification_flags = (int *) malloc(sizeof(int) * func_id_to_name.size());
    }


    _dump_func_id_to_pages();
    _dump_func_id_to_addr_and_size();
    _dump_loop_static_reachability();
    _dump_encompassed_funcs();
    _dump_sinks();

    _init_page_to_count();

    // XXX Originally replaced atexit() by calling debrt_destroy(), which is
    // instrumented by the pass at the end of the application's main(). This
    // was a hack b/c omnetpp seems to install exit handlers that run
    // before ours.  According to atexit man page, the handlers run in reverse
    // order that they're registered. Nevertheless, I was still
    // seeing issues in other places, so I've added atexit() back in, hoping to
    // catch more cases.
    atexit(_debrt_protect_destroy);

    DEBRT_PRINTF("&func_name_to_id: 0x%p\n", &func_name_to_id);
    DEBRT_PRINTF("&func_name_to_id['main']: %p\n", &func_name_to_id["main"]);
    _debrt_protect_all_pages(RO_PERM);
    if( (DEBRT_INDIRECT_CALL_SINKING == 0)
    &&  (ENV_DEBRT_ENABLE_BASIC_INDIRECT_CALL_STATIC_ANALYSIS == 0) ){
        _debrt_map_ptd_to_funcs();
    }


    // if this is the first protect call, we need to make sure the caller's
    // page and main are still executable.
    DEBRT_PRINTF("ensuring first protect caller is still RX\n");
    DEBRT_PRINTF("main_func_id: %d\n", main_func_id);
    assert(main_func_id == func_name_to_id["main"]);
    int rv;
    rv = update_page_counts(main_func_id, 1);
    _write_mapped_pages_to_file(rv, true, "init");
    //if(ENV_DEBRT_ENABLE_PROFILING){
    //    // minor point: For this init case, we do this after
    //    // write-mapped-pages-to-file b/c we want the fact that we executed main to
    //    // be in the next write-mapped-pages-to-file output.
    //    int debrt_profile_trace(int);
    //    debrt_profile_trace(main_func_id);
    //}

    if(ENV_DEBRT_ENABLE_PROFILING){
        _profile_init();
    }

    lib_initialized = 1;


    return 0;
}
}

extern "C" {
int debrt_destroy(int notused)
{
    _debrt_protect_destroy();
    if(ENV_DEBRT_ENABLE_PROFILING){
        _write_func_id_to_pages();
    }
    return 0;
}
}

extern "C" {
int debrt_profile_update_recorded_funcs(int new_pop_popanddump)
{
    DEBRT_PRINTF("%s\n", __FUNCTION__);
    _WARN_RETURN_IF_NOT_INITIALIZED();
    set<int> *recorded_funcs;

    if(lib_destroyed){
        fprintf(stderr, "WARNING: tried to update-recorded-funcs " \
          "after already calling destroy for library. Could be 'normal' " \
          "behavior if application's exit-handlers (like for deconstructors) " \
          "are still firing off. (Long-term profiling/stats fix: handle " \
          "these teardown cases more carefully.)\n");
        return 0; // FIXME one day these return values should matter
    }

    if(!ENV_DEBRT_ENABLE_PROFILING){
        assert(0 && "Dump-and-pop recorded funcs should only be instrumented " \
                    "and invoked when DEBRT_ENABLE_PROFILING is set.");
    }

    if( (new_pop_popanddump < 0) || (new_pop_popanddump > 2) ){
        assert(0 && "ERROR: unexpected value for new_pop_popanddump (should be 0, 1, or 2)");
    }

    if(new_pop_popanddump == 0){
        DEBRT_PRINTF("recorded_funcs_stack is adding new set\n");
        recorded_funcs_stack.push_back(new set<int>());
    }else{
        if(recorded_funcs_stack.size() > 0){
            DEBRT_PRINTF("recorded_funcs_stack is peeking at back\n");
            recorded_funcs = recorded_funcs_stack.back();

            if(new_pop_popanddump == 2){
                DEBRT_PRINTF("recorded_funcs_stack back element is being written to file\n");
                DEBRT_PRINTF2("recorded-funcs-stack size: %lu\n", recorded_funcs_stack.size());
                fprintf(fp_mapped_pages, "recorded-func-ids ");
                for(int func_id : (*recorded_funcs)){
                    fprintf(fp_mapped_pages, "%d ", func_id);
                }
                fprintf(fp_mapped_pages, "\n");
            }

            DEBRT_PRINTF("recorded_funcs_stack is popping and deleting back\n");
            recorded_funcs_stack.pop_back();
            delete recorded_funcs;
        }else{
            fprintf(stderr, "WARNING: tried to pop (or pop-and-dump), but " \
                            "recorded_funcs_stack is empty\n");
        }
    }

    return 0;
}
}

static inline
int _protect_single(int callee_func_id, const string deck_type)
{
    int rv = 0;
    int boomer;
    DEBRT_PRINTF("INC page count for func_id %d\n", callee_func_id);
    rv += update_page_counts(callee_func_id, 1);
    if(ENV_DEBRT_ENABLE_STACK_CLEANING){
        single_stack.push_back(callee_func_id);
        if(single_stack.size() > 2){
            // -1: last element
            // -2: we've already pushed; can't unmap caller (we'd crash);
            //     unmap caller's caller
            boomer = single_stack[single_stack.size()-1-2];
            rv += update_page_counts(boomer, -1);
        }
    }
    _write_mapped_pages_to_file(rv, true, deck_type);
    return 0;
}

static inline
int _protect_single_end(int callee_func_id, const string deck_type)
{
    int rv = 0;
    int boomer;
    DEBRT_PRINTF("DEC page count for func_id %d\n", callee_func_id);
    rv += update_page_counts(callee_func_id, -1);
    if(ENV_DEBRT_ENABLE_STACK_CLEANING){
        single_stack.pop_back();
        if(single_stack.size() > 1){
            // -1: last element
            // -1: we've already popped; map caller's caller
            boomer = single_stack[single_stack.size()-1-1];
            rv += update_page_counts(boomer, 1);
        }
    }
    _write_mapped_pages_to_file(rv, false, deck_type);
    return 0;
}

extern "C" {
int debrt_protect_single(int callee_func_id)
{
    DEBRT_PRINTF("%s\n", __FUNCTION__);
    _WARN_RETURN_IF_NOT_INITIALIZED();
    return _protect_single(callee_func_id, "single");
}
}


extern "C" {
int debrt_protect_single_end(int callee_func_id)
{
    DEBRT_PRINTF("%s\n", __FUNCTION__);
    _WARN_RETURN_IF_NOT_INITIALIZED();
    return _protect_single_end(callee_func_id, "single");
}
}


static inline
int _protect_reachable(int callee_func_id,
                       int addend,
                       const string deck_type)
{
    int rv = 0;
    DEBRT_PRINTF("callee_func_id: %d\n", callee_func_id);
    //assert(!ENV_DEBRT_ENABLE_RELEASE);
    rv += update_page_counts(callee_func_id, addend);
    for(int reachable_func : func_id_to_reachable_funcs[callee_func_id]){
        rv += update_page_counts(reachable_func, addend);
    }
    if(ENV_DEBRT_ENABLE_PROFILING){
        if(addend == 1){
            DEBRT_PRINTF("recorded_funcs_stack (_protect_reachable) is pushing new set\n");
            debrt_profile_update_recorded_funcs(0/*new set*/);
        }else{
            DEBRT_PRINTF("recorded_funcs_stack (_protect_reachable) will pop and dump\n");
            debrt_profile_update_recorded_funcs(2/*pop and_dump*/);
        }
    }
    _write_mapped_pages_to_file(rv, addend == 1, deck_type);
    DEBRT_PRINTF("leaving _protect_reachable\n");
    return 0;
}
extern "C" {
int debrt_protect_reachable(int callee_func_id)
{
    DEBRT_PRINTF("%s\n", __FUNCTION__);
    _WARN_RETURN_IF_NOT_INITIALIZED();
    return _protect_reachable(callee_func_id, 1, "reachable");
}
}
extern "C" {
int debrt_protect_reachable_end(int callee_func_id)
{
    int rv;
    DEBRT_PRINTF("%s\n", __FUNCTION__);
    _WARN_RETURN_IF_NOT_INITIALIZED();

    if(ENV_DEBRT_ENABLE_RELEASE && !default_prediction_flag){
        DEBRT_PRINTF("case: release build and default_prediction_flag not set\n");
        rv = 0;
        // Unmap predicted set
        DEBRT_PRINTF("Unmapping predicted set\n");
        for(set<int> *pred_set_p_tmp : pred_sets){
            for(int pred_func_id : (*pred_set_p_tmp)){
                rv += update_page_counts(pred_func_id, -1);
            }
        }
        if(rectification_happened){
            DEBRT_PRINTF("Rectification happened\n");
            // Case: we're tearing down a reachable deck, and we
            // also had to deal with rectification while servicing that deck.
            // reset the rectification-happened flag, and unmap all the
            // complement functions.
            rectification_happened = 0;
            DEBRT_PRINTF("Unmapping complement set\n");
            for(set<int> *complement_set_p_tmp : pred_set_complements){
                for(int complement_func_id : (*complement_set_p_tmp)){
                    rv += update_page_counts(complement_func_id, -1);
                }
            }
        }
        pred_sets.clear();
        pred_set_complements.clear();
    }else{
        DEBRT_PRINTF("case: not release build, or default_prediction_flag is set\n");
        default_prediction_flag = 0;
        // need to clear pred sets for TEST_PREDICTION, but should be fine to
        // do always, even for RELEASE, which shouldn't have any element
        // in the stack along this else branch anyway.
        pred_sets.clear();
        //DEBUG_predicted_func_set_ids.clear();
        rv = _protect_reachable(callee_func_id, -1, "reachable");
    }

    return rv;
}
}


static inline
int _protect_loop_reachable(int loop_id, int addend)
{
    int rv = 0;
    DEBRT_PRINTF("loop id: %d\n", loop_id);
    //assert(!ENV_DEBRT_ENABLE_RELEASE);
    for(int reachable_func : loop_id_to_reachable_funcs[loop_id]){
        rv += update_page_counts(reachable_func, addend);
    }
    if(ENV_DEBRT_ENABLE_PROFILING){
        if(addend == 1){
            DEBRT_PRINTF("recorded_funcs_stack (_protect_loop_reachable) is pushing new set\n");
            debrt_profile_update_recorded_funcs(0/*new set*/);
        }else{
            DEBRT_PRINTF("recorded_funcs_stack (_protect_loop_reachable) will pop and dump\n");
            debrt_profile_update_recorded_funcs(2/*pop and_dump*/);
        }
    }
    _write_mapped_pages_to_file(rv, addend == 1, "loop");
    return 0;
}
extern "C" {
int debrt_protect_loop(int loop_id)
{
    DEBRT_PRINTF("%s\n", __FUNCTION__);
    _WARN_RETURN_IF_NOT_INITIALIZED();
    _protect_loop_reachable(loop_id, 1);
    return 0;
}
}

extern "C" {
int debrt_protect_loop_end(int loop_id)
{
    int rv;

    DEBRT_PRINTF("%s\n", __FUNCTION__);
    _WARN_RETURN_IF_NOT_INITIALIZED();

    // Note: For artd release builds, this ics code isn't applicable. The "ics" stuff
    // that's happening for release builds relates to predictions inside of
    // loops (and growing those prediction sets). See pred_sets as a starting
    // point for how this is handled.
    if(ENV_DEBRT_ENABLE_RELEASE && !default_prediction_flag){
        rv = 0;
        // Map predicted set
        for(set<int> *pred_set_p_tmp : pred_sets){
            for(int pred_func_id : (*pred_set_p_tmp)){
                rv += update_page_counts(pred_func_id, -1);
            }
        }
        if(rectification_happened){
            // Case: we're tearing down a loop deck, and we
            // also had to deal with rectification while servicing that deck.
            // reset the rectification-happened flag, and unmap all the
            // complement functions.
            rectification_happened = 0;
            for(set<int> *complement_set_p_tmp : pred_set_complements){
                for(int complement_func_id : (*complement_set_p_tmp)){
                    rv += update_page_counts(complement_func_id, -1);
                }
            }
        }
        ics_set.clear();
        pred_sets.clear();
        pred_set_complements.clear();
    }else{
        // Hijack the loop-end call to turn off any functions that were enabled
        // inside of a loop due to ICS. Note that ics-set will always have a size
        // of 0 when ICS is disabled, so checking that it's enabled doesn't really
        // matter here.
        for(int func_id : ics_set){
            if(encompassed_funcs.find(func_id) != encompassed_funcs.end()){
                // Don't use _protect_reachable. We don't want its logging.
                // Just call update_page_counts as needed here.
                // _protect_reachable now does this pop/dump stuff, which we don't
                // want when fixing up ics-related pages. It also writes the
                // updated pages to the log. But all of this will be done (as
                // desired) at the end of this function when it calls
                // _protect_loop_reachable().
                DEBRT_PRINTF("ics_set func_id: %d\n", func_id);
                update_page_counts(func_id, -1); // dropping return value
                for(int reachable_func : func_id_to_reachable_funcs[func_id]){
                    update_page_counts(reachable_func, -1); // dropping return value
                }
            }else{
                _protect_single_end(func_id, "single-loop"); // ignoring return value
            }
        }
        ics_set.clear();
        default_prediction_flag = 0;
        // need to clear pred sets for TEST_PREDICTION, but should be fine to
        // do always, even for RELEASE, which shouldn't have any element
        // in the stack along this else branch anyway.
        pred_sets.clear();
        //DEBUG_predicted_func_set_ids.clear();
        rv = _protect_loop_reachable(loop_id, -1);
    }

    return rv;
}
}





extern "C" {
int debrt_protect_indirect(long long callee_addr)
{
    DEBRT_PRINTF("%s\n", __FUNCTION__);
    _WARN_RETURN_IF_NOT_INITIALIZED();
    DEBRT_PRINTF("callee_addr is: 0x%llx\n", callee_addr);
    if(func_addr_to_id.find(callee_addr) == func_addr_to_id.end()){
        // This could be a valid case. Example: A top-level function is
        // instrumented at an indirect callsite, and at runtime, this resolves
        // to a library address. In that case, we can safely ignore. We warn
        // just in case we need to review later.
        DEBRT_PRINTF("WARNING: callee_addr not found.\n");
        return 0;
    }
    int func_id = func_addr_to_id[callee_addr];
    DEBRT_PRINTF("func_id is: %d\n", func_id);

    //
    //
    // Hijack the protect-indirect call for indirect call sinking (i.e.
    // instrumented indirect calls inside of loops).
    // Checking that ICS is enabled probably makes no difference here.
    // Also, for normal protect-indirect calls (not inside loops), this code
    // should never short-circuit below (i.e. should never return 0 early).
    // The reason is because ics_set should never have the func-id, and even
    // though it unnecessarily inserts it into the set, protect-indirect-end
    // now clears the set regardless. So this is a little unnecessary overhead
    // in those cases, but the code is shared and simpler.

    // This short-circuit is kind of a hack. The inlined C code is a fast
    // hash and mod. It's a cheap set that can't handle collision. Thus, it
    // might invoke protect-indirect unnecessarily, and we
    // don't want to update a page count for a function multiple times in a
    // loop if it's already been seen. So here we have this proper stl set that
    // we can short-circuit: If we have already seen this func-id within this
    // loop (i.e. within this ics-set), just return early.
    if(ics_set.find(func_id) != ics_set.end()){
        ics_set_short_circuit_count++;
        return 0;
    }
    // We reach this point if this is a new indirectly called func-id within
    // some loop. Insert it into our set so we can clear it at loop exit.
    // (As pointed out, this code is shared, so we also do this on any normal
    // indirect call outside of a loop; in that case, it's cleared by
    // protect-indirect-end.)
    ics_set.insert(func_id);
    //
    //


    if(encompassed_funcs.find(func_id) != encompassed_funcs.end()){
        // encompassed function
        return _protect_reachable(func_id, 1, "reachable-indirect");
    }
    // top-level function
    return _protect_single(func_id, "single-indirect");
}
}


static inline
int _protect_indirect_end(long long callee_addr)
{
    if(func_addr_to_id.find(callee_addr) == func_addr_to_id.end()){
        // See debrt_protect_indirect() for why this is OK.
        DEBRT_PRINTF("WARNING: callee_addr not found.\n");
        return 0;
    }
    int func_id = func_addr_to_id[callee_addr];
    DEBRT_PRINTF("func_id is: %d\n", func_id);
    ics_set.clear();
    if(encompassed_funcs.find(func_id) != encompassed_funcs.end()){
        // encompassed function
        return _protect_reachable(func_id, -1, "reachable-indirect");
    }
    // top-level function
    return _protect_single_end(func_id, "single-indirect");
}

extern "C" {
int debrt_protect_indirect_end(long long callee_addr)
{
    DEBRT_PRINTF("%s\n", __FUNCTION__);
    _WARN_RETURN_IF_NOT_INITIALIZED();
    DEBRT_PRINTF("end callee_addr is: 0x%llx\n", callee_addr);
    return _protect_indirect_end(callee_addr);
}
}


static inline
int _protect_sink(int sink_id, int addend)
{
    int rv = 0;
    DEBRT_PRINTF("sink id: %d\n", sink_id);
    for(int func : sink_id_to_funcs[sink_id]){
        rv += update_page_counts(func, addend);
    }
    _write_mapped_pages_to_file(rv, addend == 1, "sink-DEPRECATED");
    return 0;
}
extern "C" {
int debrt_protect_sink(int sink_id)
{
    DEBRT_PRINTF("%s\n", __FUNCTION__);
    _WARN_RETURN_IF_NOT_INITIALIZED();
    _protect_sink(sink_id, 1);
    return 0;
}
}
extern "C" {
int debrt_protect_sink_end(int sink_id)
{
    DEBRT_PRINTF("%s\n", __FUNCTION__);
    _WARN_RETURN_IF_NOT_INITIALIZED();
    _protect_sink(sink_id, -1);
}
}


//
// Receives a variable number of arguments:
// argc: Number of args to follow.
// Function or loop ID (positive for functions, negative for loops)
// Deck ID
// deck arg1 (optional)
// deck arg2 (optional)
// ...
// deck argn (optional)
// 
//
// The output of this function starts with:
//   profile <func_or_loop_id> <deck_id>
// These are always guaranteed to be there. Then:
//   [deck argument 1] [deck argument 2] ...
// These arguments are optional. Note that argc holds the number of
// arguments for the variadic function call itself. It will always hold at
// least the function/loop ID and deck ID. That is, it will always be >= 2;
// if there are 0 arguments to the deck, then argc=2; if there is 1 argument to
// the deck, then argc=3; and so on.
//
extern "C" {
int debrt_profile_print_args(int argc, ...)
{
    DEBRT_PRINTF("%s\n", __FUNCTION__);
    _WARN_RETURN_IF_NOT_INITIALIZED();
    int i;
    va_list ap;
    if(ENV_DEBRT_ENABLE_PROFILING){

        va_start(ap, argc);

        fprintf(fp_mapped_pages, "profile %d", va_arg(ap, int));
        for(i = 1; i < argc; i++){
            fprintf(fp_mapped_pages, " %d", va_arg(ap, int));
        }
        fprintf(fp_mapped_pages, "\n");

        va_end(ap);
    }
    return 0;
}
}
extern "C" {
int debrt_profile_trace(int func_id)
{
    DEBRT_PRINTF("%s for func_id: %d\n", __FUNCTION__, func_id);
    _WARN_RETURN_IF_NOT_INITIALIZED();
    if(recorded_funcs_stack.size() > 0){
        DEBRT_PRINTF("recorded_funcs_stack (debrt_profile_trace) is inserting func id %d in the back set\n", func_id);
        recorded_funcs_stack.back()->insert(func_id);
    }else{
        // XXX This is perfectly fine if we're not inside of any encompassed
        // function. The log is here just to be verbose. We only need to trace
        // inside of encompased functions that need profiling for training.
        DEBRT_PRINTF("recorded_funcs_stack (debrt_profile_trace) is size 0. Not tracing func ID %d.\n", func_id);
    }
    return 0;
}
}
extern "C" {
int debrt_profile_indirect_print_args(long long argc, ...)
{
    DEBRT_PRINTF("%s\n", __FUNCTION__);
    _WARN_RETURN_IF_NOT_INITIALIZED();
    int i;
    va_list ap;
    if(ENV_DEBRT_ENABLE_PROFILING){

        va_start(ap, argc);

        long long fp_addr = va_arg(ap, long long);
        if(func_addr_to_id.find(fp_addr) == func_addr_to_id.end()){
            // See debrt_protect_indirect() for how this can happen.
            // With respect to profiling specifically and the ramifications,
            // it's fine to ignore. If you don't ignore it, then you end up
            // training on these features, which lead to empty pred sets.
            // And if you ignore it, you just don't have such training data.
            // But regardless, the release binary is going to ignore such
            // a call with this exact same check, because it will have nothing
            // to map RX when there is an indirect call to library code.
            DEBRT_PRINTF("WARNING: profile-indirect-print-args' fp_addr not found.\n");
            return 0;
        }
        int func_id = func_addr_to_id[fp_addr];

        fprintf(fp_mapped_pages, "profile-indirect");
        fprintf(fp_mapped_pages, " %d", func_id);
        for(i = 1; i < argc; i++){
            fprintf(fp_mapped_pages, " %lld", va_arg(ap, long long));
        }
        fprintf(fp_mapped_pages, "\n");

        va_end(ap);


    }
    return 0;
}
}
//
// Very similar to debrt_profile_print_args. The main difference is that
// we call this from the ics-indirect code, which prepares a buffer that
// we receive here. The buffer argument is called varargs. Its layout is:
// element 0: the number of args to follow
// element 1: fp-addr
// element 2: the deck ID
// element 3: argument 1 to the indirect call, if any
// element 4: argument 2 to the indirect call, if any
// element m: argument n to the indirect call, if any
//
// The output to the log is of the form:
//   profile-indirect func_id deck_id arg1 arg2 ... argn
//
extern "C" {
int debrt_profile_indirect_print_args_ics(long long *varargs)
{
    DEBRT_PRINTF("%s\n", __FUNCTION__);
    _WARN_RETURN_IF_NOT_INITIALIZED();
    int i;
    long long num_args;
    if(ENV_DEBRT_ENABLE_PROFILING){
        if(lib_destroyed){
            fprintf(stderr, "WARNING: tried to indirect-print-args-ics " \
              "after already calling destroy for library. Could be 'normal' " \
              "behavior if application's exit-handlers (like for deconstructors) " \
              "are still firing off. (Long-term profiling/stats fix: handle " \
              "these teardown cases more carefully.)\n");
            return 0; // FIXME one day these return values should matter
        }
        num_args = varargs[0];
        long long fp_addr  = varargs[1];
        if(func_addr_to_id.find(fp_addr) == func_addr_to_id.end()){
            // See debrt_protect_indirect() for how this can happen.
            // With respect to profiling specifically and the ramifications,
            // it's fine to ignore. If you don't ignore it, then you end up
            // training on these features, which lead to empty pred sets.
            // And if you ignore it, you just don't have such training data.
            // But regardless, the release binary is going to ignore such
            // a call with this exact same check, because it will have nothing
            // to map RX when there is an indirect call to library code.
            DEBRT_PRINTF("WARNING: profile-indirect-print-args-ics' fp_addr not found.\n");
            return 0;
        }
        int func_id = func_addr_to_id[fp_addr];
        fprintf(fp_mapped_pages, "profile-indirect");
        fprintf(fp_mapped_pages, " %d", func_id);
        for(i = 1; i < num_args; i++){
            // FIXME this print and the normal print-args function are using
            // int and dropping information.
            fprintf(fp_mapped_pages, " %d", (int) varargs[i+1]);
        }
        fprintf(fp_mapped_pages, "\n");
    }
    return 0;
}
}

// Trace every function call
extern "C" {
int debrt_test_predict_trace(int func_id)
{
    int i;
    int func_is_in_a_pred_set;
    set<int> *pred_set_p;
    DEBRT_PRINTF("%s\n", __FUNCTION__);
    _WARN_RETURN_IF_NOT_INITIALIZED();
    if( (pred_set_initialized) && (pred_sets.size() > 0) ){
        // Increment our counter for dynamic function calls
        num_func_calls++;
        if(num_func_calls == 0){
            num_func_calls_wrap++;
        }

        // Check for misprediction.
        // cporter notes from 2023.04.14 describe what accuracy means in this
        // current approach. Can/should change depending on what we want
        // to measure later.
        func_is_in_a_pred_set = 0;
        for(i = 0; i < pred_sets.size(); i++){
            pred_set_p = pred_sets[i];
            if(pred_set_p->find(func_id) != pred_set_p->end()){
                func_is_in_a_pred_set = 1;
                break;
            }
        }
        if(!func_is_in_a_pred_set){
            num_mispredictions++;
            //if(DEBUG_mispredict_func_ids.find(func_id) == DEBUG_mispredict_func_ids.end()){
            //    DEBUG_mispredict_func_ids[func_id] = 0;
            //}
            //DEBUG_mispredict_func_ids[func_id] += 1;
            //if(func_id == 33){
            //    //DEBUG_mispredict_func_ids_novel.insert(pred_sets.size());
            //    DEBUG_mispredict_func_ids_novel.insert(DEBUG_last_func_set_id);
            //    assert(DEBUG_predicted_func_set_ids.size() == 3);
            //    for(i = 0; i < DEBUG_predicted_func_set_ids.size(); i++){
            //        DEBUG_mispredict_func_ids_novel_2.insert(DEBUG_predicted_func_set_ids[i]);
            //    }
            //}
        }
    }
    return 0;
}
}

// Issue a prediction
extern "C" {
int debrt_test_predict_predict(int argc, ...)
{
    DEBRT_PRINTF("%s\n", __FUNCTION__);
    _WARN_RETURN_IF_NOT_INITIALIZED();
    int i;
    int func_set_id;
    va_list ap;
    int feature_buf[MAX_NUM_FEATURES];
    set<int> *pred_set_p;

    // XXX can we avoid this memset?
    memset(feature_buf, 0, MAX_NUM_FEATURES * sizeof(int));

    // gather features into a buffer
    va_start(ap, argc);
    for(i = 0; i < argc; i++){
        feature_buf[i] = va_arg(ap, int);
    }
    va_end(ap);

    // Get a new prediction
    func_set_id = debrt_decision_tree(feature_buf);
    //printf("pred_set_p before: %p\n", pred_set_p);
    pred_set_p = &func_sets[func_set_id];
    //DEBUG_last_func_set_id = func_set_id;
    //if(DEBUG_last_func_set_id == 8){
    //    DEBUG_mispredict_func_ids_novel_2.insert(feature_buf[1]);
    //}
    //printf("pred_set_p after:  %p\n", pred_set_p);
    //printf("pred_set_p:  %p\n", pred_set_p);
    pred_sets.push_back(pred_set_p);
    //DEBUG_predicted_func_set_ids.push_back(func_set_id);
    pred_set_initialized = 1;

    return 0;
}
}

// Issue a prediction for an indirect call (which is not from ics).
extern "C" {
int debrt_test_predict_indirect_predict(long long argc, ...)
{
    DEBRT_PRINTF("%s\n", __FUNCTION__);
    _WARN_RETURN_IF_NOT_INITIALIZED();
    int i;
    int func_set_id;
    va_list ap;
    int feature_buf[MAX_NUM_FEATURES];
    set<int> *pred_set_p;

    // XXX can we avoid this memset?
    memset(feature_buf, 0, MAX_NUM_FEATURES * sizeof(int));

    // gather features into a buffer
    va_start(ap, argc);
    long long fp_addr = va_arg(ap, long long);

    if(func_addr_to_id.find(fp_addr) == func_addr_to_id.end()){
        // See debrt_protect_indirect() for how this can happen.
        // Should be fine to ignore
        DEBRT_PRINTF("WARNING: test-predict-indirect-predict' fp_addr not found.\n");
        return 0;
    }
    int func_id = func_addr_to_id[fp_addr];

    feature_buf[0] = func_id;

    for(i = 1; i < argc; i++){
        feature_buf[i] = (int) va_arg(ap, long long);
    }
    va_end(ap);

    // Get a new prediction
    func_set_id = debrt_decision_tree(feature_buf);
    //printf("pred_set_p before: %p\n", pred_set_p);
    pred_set_p = &func_sets[func_set_id];
    //printf("pred_set_p after:  %p\n", pred_set_p);
    //printf("pred_set_p:  %p\n", pred_set_p);
    pred_sets.push_back(pred_set_p);
    //DEBUG_predicted_func_set_ids.push_back(func_set_id);
    pred_set_initialized = 1;

    return 0;
}
}

// Issue a prediction from ics.
// One critical point is that because it comes from ics, it needs to grow the
// predicted set (not replace it).
extern "C" {
int debrt_test_predict_indirect_predict_ics(long long *varargs)
{
    DEBRT_PRINTF("%s\n", __FUNCTION__);
    _WARN_RETURN_IF_NOT_INITIALIZED();

    int feature_buf[MAX_NUM_FEATURES];
    int i;
    int func_set_id;
    long long num_args;
    long long fp_addr;
    set<int> *pred_set_p;

    // XXX can we avoid this memset?
    memset(feature_buf, 0, MAX_NUM_FEATURES * sizeof(int));

    num_args = varargs[0];
    fp_addr = varargs[1];

    if(func_addr_to_id.find(fp_addr) == func_addr_to_id.end()){
        // See debrt_profile_indirect_print_args() for details on this case.
        DEBRT_PRINTF("WARNING: test-predict-indirect-predict-ics fp_addr not found.\n");
        return 0;
    }
    int func_id = func_addr_to_id[fp_addr];

    // gather features into a buffer
    //for(i = 1; i < num_args; i++){
    //    // FIXME see profile print args functions (normal and ics) which
    //    // also cast to int and drop info.
    //    feature_buf[i-1] = (int) varargs[i+1];
    //}
    feature_buf[0] = func_id;
    for(i = 1; i < num_args; i++){
        // FIXME see profile print args functions (normal and ics) which
        // also cast to int and drop info.
        feature_buf[i] = (int) varargs[i+1];
    }

    // Get a new prediction
    func_set_id = debrt_decision_tree(feature_buf);
    //printf("pred_set_p before: %p\n", pred_set_p);
    pred_set_p = &func_sets[func_set_id];
    //printf("pred_set_p after:  %p\n", pred_set_p);
    pred_sets.push_back(pred_set_p);
    //DEBUG_predicted_func_set_ids.push_back(func_set_id);
    pred_set_initialized = 1;

    return 0;
}
}


extern "C" {
int debrt_release_rectify(int func_id)
{
    int rv = 0;
    DEBRT_PRINTF("%s\n", __FUNCTION__);
    _WARN_RETURN_IF_NOT_INITIALIZED();

    // Map the complement set
    for(set<int> *pred_set_complement_p_tmp : pred_set_complements){
        for(int complement_func_id : (*pred_set_complement_p_tmp)){
            rv += update_page_counts(complement_func_id, 1);
        }
    }

    // Mark debrt_rectification_flags as 0
    // XXX memset is okay, even in the context of rectification w/in the loops.
    // (In fact, the flag below, rectification_happened, addresses this.)
    memset(debrt_rectification_flags, 0, sizeof(int) * func_id_to_name.size());

    // Flag the fact that we had to use rectification for the current deck.
    // It will get reset to 0 when the deck completes (a protect-end call)
    rectification_happened = 1;

    return 0;
}
}


static inline
int _release_predict(int *feature_buf)
{
    int rv = 0;
    int func_set_id;
    int func_or_loop_id;
    set<int> *pred_set_p;
    set<int> *pred_set_complement_p;

    func_or_loop_id = feature_buf[0];

    // Get a new prediction
    func_set_id = debrt_decision_tree(feature_buf);
    if(func_set_id == -1){
        default_prediction_flag = 1;
        // No prediction available: map everything.
        if(func_or_loop_id >= 0){
            // Case: We're mapping for a function call (reachable subdeck)
            // Map the whole reachable deck as active
            return _protect_reachable(func_or_loop_id, 1, "notused");
        }else{
            // Case: We're mapping for a loop (loop subdeck)
            // Map the whole loop deck as active
            func_or_loop_id = (func_or_loop_id * -1) -1;
            return _protect_loop_reachable(func_or_loop_id, 1);
        }
    }

    //printf("pred_set_p before: %p\n", pred_set_p);
    pred_set_p = &func_sets[func_set_id];
    pred_set_complement_p = &complement_sets[func_set_id];
    //printf("pred_set_p after:  %p\n", pred_set_p);
    //printf("pred_set_p:  %p\n", pred_set_p);

    assert(ENV_DEBRT_ENABLE_RELEASE);

    pred_sets.push_back(pred_set_p);
    pred_set_complements.push_back(pred_set_complement_p);


    // Map predicted set
    for(int pred_func_id : (*pred_set_p)){
        rv += update_page_counts(pred_func_id, 1);
    }

    // Update rectification flags
    //printf("complement_sets size: %lu\n", complement_sets.size());
    //printf("checking for func_set_id: %d\n", func_set_id);
    set<int> &complements = complement_sets[func_set_id];
    //printf("complements size: %lu\n", complements.size());
    for(int complement_func_id : complements){
        debrt_rectification_flags[complement_func_id] = 1;
    }

    // If this is a func_id (not a loop_id) and this function isn't in our pred
    // set, then we actually mispredicted the deck root, as well, so we
    // will just trigger rectify here for now.
    if((func_or_loop_id >= 0)
       && (pred_set_p->find(func_or_loop_id) == pred_set_p->end())){
        // FIXME maybe replace this warning with some metric/counter.
        DEBRT_PRINTF("WARNING: deck root wasnt part of the prediction. " \
                     "Triggering debrt_release_rectify immediately.\n");
        return debrt_release_rectify(func_or_loop_id);
    }

    return rv;
}


// This function does the following:
// 1. Extracts the args
// 2. Makes the prediction
// 3. If upcoming function is not part of the predicted set,
//      Throws warning and adds it to the predicted set
// 4. Maps the predicted set
// 5. Marks the rectification flags
extern "C" {
int debrt_release_predict(int argc, ...)
{
    DEBRT_PRINTF("%s\n", __FUNCTION__);
    _WARN_RETURN_IF_NOT_INITIALIZED();
    int i;
    va_list ap;
    int feature_buf[MAX_NUM_FEATURES];

    // XXX can we avoid this memset?
    memset(feature_buf, 0, MAX_NUM_FEATURES * sizeof(int));

    // gather features into a buffer
    va_start(ap, argc);
    for(i = 0; i < argc; i++){
        feature_buf[i] = va_arg(ap, int);
    }
    va_end(ap);

    return _release_predict(feature_buf);
}
}


extern "C" {
int debrt_release_indirect_predict(long long argc, ...)
{
    DEBRT_PRINTF("%s\n", __FUNCTION__);
    _WARN_RETURN_IF_NOT_INITIALIZED();

    int i;
    int feature_buf[MAX_NUM_FEATURES];
    long long fp_addr;
    va_list ap;

    // XXX can we avoid this memset?
    memset(feature_buf, 0, MAX_NUM_FEATURES * sizeof(int));


    // gather features into a buffer
    va_start(ap, argc);
    fp_addr = va_arg(ap, long long);

    if(func_addr_to_id.find(fp_addr) == func_addr_to_id.end()){
        // See debrt_protect_indirect() for how this can happen.
        // Should be fine to ignore
        DEBRT_PRINTF("WARNING: release-indirect-predict fp_addr not found.\n");
        return 0;
    }
    int func_id = func_addr_to_id[fp_addr];

    feature_buf[0] = func_id;

    for(i = 1; i < argc; i++){
        feature_buf[i] = (int) va_arg(ap, long long);
    }
    va_end(ap);

    return _release_predict(feature_buf);
}
}



// Issue a prediction from ics.
// One critical point is that because it comes from ics, it needs to grow the
// predicted set (not replace it).
extern "C" {
int debrt_release_indirect_predict_ics(long long *varargs)
{
    DEBRT_PRINTF("%s\n", __FUNCTION__);
    _WARN_RETURN_IF_NOT_INITIALIZED();

    int feature_buf[MAX_NUM_FEATURES];
    int i;
    int func_set_id;
    long long num_args;
    long long fp_addr;

    // XXX can we avoid this memset?
    memset(feature_buf, 0, MAX_NUM_FEATURES * sizeof(int));

    num_args = varargs[0];
    fp_addr = varargs[1];

    if(func_addr_to_id.find(fp_addr) == func_addr_to_id.end()){
        // See debrt_profile_indirect_print_args() for details on this case.
        DEBRT_PRINTF("WARNING: release-indirect-predict-ics fp_addr not found.\n");
        return 0;
    }
    int func_id = func_addr_to_id[fp_addr];

    // gather features into a buffer
    feature_buf[0] = func_id;
    for(i = 1; i < num_args; i++){
        // FIXME see profile print args functions (normal and ics) which
        // also cast to int and drop info.
        feature_buf[i] = (int) varargs[i+1];
    }

    return _release_predict(feature_buf);
}
}
