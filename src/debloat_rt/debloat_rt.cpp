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





using namespace std;

#define DEBRT_DEBUG

#define CGPredict


#ifdef DEBRT_DEBUG
#define DEBRT_PRINTF(...) \
    do{ \
        printf(__VA_ARGS__); \
    }while(0)
#else
#define DEBRT_PRINTF(...)
#endif


#define PAGE_SIZE 0x1000
#define RX_PERM   (PROT_READ | PROT_EXEC)
#define NO_PERM   (PROT_NONE)
#define RO_PERM   (PROT_READ)


int lib_initialized = 0;


// XXX this could be read in? It varies based on the benchmark. we have
// an assert in case this is violated. Could double size or fix properly
// if that happens
const int MAX_NUM_FEATURES = 64;

const int CALLSITE_ID_IDX    = 0;
const int CALLED_FUNC_ID_IDX = 1;

const char *DEFAULT_OUTPUT_FILENAME = "debrt.out";
FILE *fp_out;

int total_mapped_pages = 0; // FIXME ? probably doesn't take into account main
                            // or pointed-to funcs that are left always-on.
                            // could help me get a quick measurement of security

vector<set<int> > func_sets;
set<int> *pred_set_p;
int next_prediction_func_set_id;
int num_mispredictions;
int total_predictions;
stack<set<int> *> pred_set_stack;


int  _debrt_monitor_init(void);
void _debrt_monitor_destroy(void);
void _init_page_to_count(void);

int  _debrt_protect_init(int);
void _debrt_protect_destroy(void);
void _debrt_protect_all_pages(void);
void _debrt_protect_no_pages(void); // for debugging

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
// The .text section's offset address from the base address, and its size.
// Gotten from readelf --section output.
long long text_offset = 0;
long long text_size   = 0;


map<string, int> func_name_to_id;
map<int, string> func_id_to_name; // convenience
map<string, long long> func_name_to_offset;
map<int, pair<long long, long> > func_id_to_addr_and_size;
set<string> ptd_to_funcs;
set<int> ptd_to_func_ids;

map<int, vector<long long> > func_id_to_pages;
map<long long, int> page_to_count;




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




void _dump_func_name_to_id()
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

void _dump_func_id_to_addr_and_size(void)
{
    DEBRT_PRINTF("%s\n", __FUNCTION__);
    int func_id;
    long long addr;
    long size;
    for(auto it = func_id_to_addr_and_size.begin(); it != func_id_to_addr_and_size.end(); it++){
        func_id = it->first;
        //pair<long long, long> addr_and_size = it->second;
        addr = it->second.first;
        size = it->second.second;
        //DEBRT_PRINTF("%d: 0x%llx %ld\n", func_id, addr_and_size[0], addr_and_size[1]);
        //DEBRT_PRINTF("%d:\n", func_id);
        DEBRT_PRINTF("%d (%s): 0x%llx %ld\n", func_id, func_id_to_name[func_id].c_str(), addr, size);
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

    if(mprotect(aligned_addr_base, size_to_remap, perm) == -1){
        DEBRT_PRINTF("mprotect error\n");
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

void update_page_counts(int func_id, int addend)
{
    int i;
    long long addr;
    vector<long long> &pages = func_id_to_pages[func_id];

    //
    // FIXME
    // FIXME
    // FIXME: revisit this. do as blocks, rather than
    // as individual pages.
    //

    DEBRT_PRINTF("%s\n", __FUNCTION__);
    DEBRT_PRINTF("pages.size(): %lu\n", pages.size());
    for(i = 0; i < pages.size(); i++){
        addr = pages[i];
        page_to_count[addr] += addend;
        assert(page_to_count[addr] >= 0);
        if((page_to_count[addr] == 1) && (addend == 1)){
            DEBRT_PRINTF("went from 0 to 1, remap RX\n");
            _remap_permissions(addr, 1, RX_PERM);
            total_mapped_pages += 1;
            DEBRT_PRINTF("done RX\n");
        }else if(page_to_count[addr] == 0){
            assert(addend == -1);
            DEBRT_PRINTF("went from 1 to 0, remap RO\n");
            // FIXME: This is a hacky fix for PLT. linker script or some
            // other solution needs to put .text at a page boundary (and
            // not in the same page as part of the plt.
            if( addr < ((executable_addr_base + text_offset + 0x1000) & ~(0x1000-1)) ){
                DEBRT_PRINTF("addr is beneath executable addr base or part of " \
                             "first page. possibly part of .plt. ignoring " \
                             "mapping RO\n");
            }else if( addr >= ((executable_addr_base + text_offset + text_size) & ~(0x1000-1)) ){
                DEBRT_PRINTF("addr is above text end or part of last page. " \
                             "possibly part of .fini. ignoring mapping RO\n");
            }else{
                if(ptd_to_func_ids.find(func_id) != ptd_to_func_ids.end()){
                    DEBRT_PRINTF("NOT UNMAPPING page for func id %d (%s) b/c " \
                                 "it is pointed to\n",
                                 func_id,
                                 func_id_to_name[func_id].c_str());
                }else{
                    _remap_permissions(addr, 1, RO_PERM);
                    total_mapped_pages -= 1;
                }
            }
            DEBRT_PRINTF("done RO\n");
        }
    }
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
    pair<long long, long> addr_and_size = func_id_to_addr_and_size[func_id];
    assert(return_addr >= executable_addr_base + addr_and_size.first);
    assert(return_addr  < executable_addr_base + addr_and_size.first + addr_and_size.second);
}




// The runtime is executing. It hits a function call. Before it calls it,
// though, it must call this instrumented function. We pass this monitoring
// function the same args that we used in the profiling runs.
// We're doing two things here:
// 1) We check that the function we are about to call is in the
//    set of functions that we predicted the last time we made a function call.
//    If not, we raise an alarm.
// 2) We predict a new set of upcoming functions, which we'll check against
//    at the next function call.
//
extern "C" {
int debrt_monitor_orig(int argc, ...)
{
    int i;
    va_list ap;
    int feature_buf[MAX_NUM_FEATURES];
    int function_were_about_to_call;

    // argc count includes itself, I think. So if argc is 5, it means we'll
    // need a feature buffer size of 4 or larger.
    assert((argc-1) <= MAX_NUM_FEATURES);

    // initialize library
    if(!lib_initialized){
        _debrt_monitor_init(); // ignore return
        lib_initialized = 1;
        // FIXME BEGIN copy-pasted code...
        // XXX can we avoid this memset?
        memset(feature_buf, 0, MAX_NUM_FEATURES * sizeof(int));

        // gather features into a buffer
        va_start(ap, argc);
        for(i = 0; i < argc; i++){
            feature_buf[i] = va_arg(ap, int);
        }
        va_end(ap);
        // FIXME END copy-pasted code...
        // Get a new prediction
        //next_prediction_func_set_id = debrt_decision_tree(feature_buf);
        next_prediction_func_set_id = 6 + debrt_decision_tree(feature_buf);
        pred_set_p = &func_sets[next_prediction_func_set_id];
        return 0;
    }
    
    // XXX can we avoid this memset?
    memset(feature_buf, 0, MAX_NUM_FEATURES * sizeof(int));

    // gather features into a buffer
    va_start(ap, argc);
    for(i = 0; i < argc; i++){
        feature_buf[i] = va_arg(ap, int);
    }
    va_end(ap);


    // Check if the function we're about to call (which is also in our feature
    // buffer) is in our predicted set
    function_were_about_to_call = feature_buf[CALLED_FUNC_ID_IDX];
    //fprintf(fp_out, "%d,%d,%d\n", next_prediction_func_set_id,
    //                           feature_buf[CALLSITE_ID_IDX],
    //                           function_were_about_to_call);
    if(pred_set_p->find(function_were_about_to_call) == pred_set_p->end()){
        num_mispredictions++;
    }
    total_predictions++;

    // Get a new prediction
    //next_prediction_func_set_id = debrt_decision_tree(feature_buf);
    next_prediction_func_set_id = 6 + debrt_decision_tree(feature_buf);
    pred_set_p = &func_sets[next_prediction_func_set_id];

    return 0;
}
}



//
// General idea behind this approach:
// We're going to use just the callsite IDs to make a prediction. We assume
// the original instrumentation is still passing all of the function args
// as before, but we just ignore them. We pull out just the callsite ID.
// We're using the last ~5 callsite IDs to determine what the next
// functions will be. Thus, our features are now an ordered list of the
// last 5 functions. In order to avoid an std queue and converting it
// to an int[] on every function call, we just keep a "feature_buf_big" that
// can hold much more history. We keep an index into it called "fb_idx" that
// lets us insert new functions at the "front", and then decrement. When
// we pass the feature_buf_big to the DT, we don't need to pass a size or
// anything, b/c it should only be indexing up to 5 elements from it.
//
extern "C" {
int debrt_monitor(int argc, ...)
{
    static int buf_elems = 0;
    int i;
    va_list ap;
    int callsite_were_about_to_call;
    int function_were_about_to_call;

    // argc count includes itself, I think. So if argc is 5, it means we'll
    // need a feature buffer size of 4 or larger.
    assert((argc-1) <= MAX_NUM_FEATURES);

    // initialize library
    if(!lib_initialized){
        _debrt_monitor_init(); // ignore return
        lib_initialized = 1;
    }

    // prime the buffer
    if(buf_elems < 5){
        // pull out just the callsite ID (which is the 0th element)
        va_start(ap, argc);
        callsite_were_about_to_call = va_arg(ap, int);
        function_were_about_to_call = va_arg(ap, int);
        va_end(ap);
        //feature_buf_big[fb_idx + buf_elems] = callsite_were_about_to_call;
        feature_buf_big[fb_idx + buf_elems] = function_were_about_to_call;
        buf_elems++;

        // once buf is primed, get our first prediction.
        if(buf_elems == 5){
            // Get a new prediction
            next_prediction_func_set_id = debrt_decision_tree(&feature_buf_big[fb_idx]);
            //next_prediction_func_set_id = 4 + debrt_decision_tree(&feature_buf_big[fb_idx]);
            pred_set_p = &func_sets[next_prediction_func_set_id];
        }
        return 0;
    }

    // ... execution reaches here when the lib is initialized and the buffer
    // is primed

    fb_idx--;

    // "reset" feature-buf-big.
    // Move the fb_idx back to its starting position. Copy elements that we
    // need up to the top
    if(fb_idx < 0){
        fb_idx = FP_IDX_BASE;
        memcpy(&feature_buf_big[fb_idx+1], &feature_buf_big[0], sizeof(int)*(NUM_FEATURE_ELEMS-1));
    }

    // pull out the callsite ID (which we use for predicting) and the function
    // we're about to call (which is what we predicted as part of our last
    // predicted set)
    va_start(ap, argc);
    callsite_were_about_to_call = va_arg(ap, int);
    function_were_about_to_call = va_arg(ap, int);
    va_end(ap);
    //feature_buf_big[fb_idx] = callsite_were_about_to_call;
    feature_buf_big[fb_idx] = function_were_about_to_call;

    // Check if the function we're about to call is in our predicted set
    //if(pred_set_p->find(callsite_were_about_to_call) == pred_set_p->end()){
    if(pred_set_p->find(function_were_about_to_call) == pred_set_p->end()){
        num_mispredictions++;
    }
    total_predictions++;

    // Get a new prediction
    next_prediction_func_set_id = debrt_decision_tree(&feature_buf_big[fb_idx]);
    //next_prediction_func_set_id = 4 + debrt_decision_tree(&feature_buf_big[fb_idx]);
    pred_set_p = &func_sets[next_prediction_func_set_id];

    // log what features we send to the DT and what prediction we get back.
    // the predictions might not exactly match training data, but the
    // features should match it exactly.
    //fprintf(fp_out, "%d", next_prediction_func_set_id);
    //for(i = 0; i < NUM_FEATURE_ELEMS; i++){
    //    fprintf(fp_out, ",%d", feature_buf_big[fb_idx+i]);
    //}
    //fprintf(fp_out, "\n");

    return 0;
}
}

extern "C" {
int debrt_protect_sequence(int argc, ...)
{
    static int buf_elems = 0;
    static int first_prediction = 1;
    int i;
    va_list ap;
    int callsite_were_about_to_call;
    int function_were_about_to_call;

    // argc count includes itself, I think. So if argc is 5, it means we'll
    // need a feature buffer size of 4 or larger.
    assert((argc-1) <= MAX_NUM_FEATURES);

    // initialize library
    if(!lib_initialized){
        _debrt_protect_init(1/*read-func-sets*/); // ignore return
        lib_initialized = 1;
    }

    // prime the buffer
    if(buf_elems < 5){
        // pull out just the callsite ID (which is the 0th element)
        va_start(ap, argc);
        callsite_were_about_to_call = va_arg(ap, int);
        function_were_about_to_call = va_arg(ap, int);
        va_end(ap);
        //feature_buf_big[fb_idx + buf_elems] = callsite_were_about_to_call;
        feature_buf_big[fb_idx + buf_elems] = function_were_about_to_call;
        buf_elems++;

        // once buf is primed, get our first prediction.
        if(buf_elems == 5){
            // Get a new prediction
            next_prediction_func_set_id = debrt_decision_tree(&feature_buf_big[fb_idx]);
            //next_prediction_func_set_id = 4 + debrt_decision_tree(&feature_buf_big[fb_idx]);
            pred_set_p = &func_sets[next_prediction_func_set_id];
        }
        return 0;
    }

    // ... execution reaches here when the lib is initialized and the buffer
    // is primed


    // XXX We'll want to reinstate this. But compiler support and debrt code
    // needs to be written first
    if(first_prediction){
        first_prediction = 0;
        //_debrt_protect_all_pages();
        //_init_page_to_count();
        DEBRT_PRINTF("HIT AFTER ALL-PAGES\n");
        DEBRT_PRINTF("built-in return: %p\n", __builtin_return_address(0));
        // ensure the initial page that we can from is mapped RX
        _remap_permissions((long long)__builtin_return_address(0), 1, RX_PERM);
    }


    fb_idx--;

    // "reset" feature-buf-big.
    // Move the fb_idx back to its starting position. Copy elements that we
    // need up to the top
    if(fb_idx < 0){
        fb_idx = FP_IDX_BASE;
        memcpy(&feature_buf_big[fb_idx+1], &feature_buf_big[0], sizeof(int)*(NUM_FEATURE_ELEMS-1));
    }

    // pull out the callsite ID (which we use for predicting) and the function
    // we're about to call (which is what we predicted as part of our last
    // predicted set)
    va_start(ap, argc);
    callsite_were_about_to_call = va_arg(ap, int);
    function_were_about_to_call = va_arg(ap, int);
    va_end(ap);
    //feature_buf_big[fb_idx] = callsite_were_about_to_call;
    feature_buf_big[fb_idx] = function_were_about_to_call;

    //DEBRT_PRINTF("callsite_were_about_to_call: %d\n", callsite_were_about_to_call);
    DEBRT_PRINTF("function_were_about_to_call: %d\n", function_were_about_to_call);

    // Check if the function we're about to call is in our predicted set
    //if(pred_set_p->find(callsite_were_about_to_call) == pred_set_p->end()){
    if(pred_set_p->find(function_were_about_to_call) == pred_set_p->end()){
        DEBRT_PRINTF("got mispredict\n");
        num_mispredictions++;
    }
    total_predictions++;

    DEBRT_PRINTF("about to update mapped pages\n");
    _update_mapped_pages(function_were_about_to_call);

    // Get a new prediction
    next_prediction_func_set_id = debrt_decision_tree(&feature_buf_big[fb_idx]);
    //next_prediction_func_set_id = 4 + debrt_decision_tree(&feature_buf_big[fb_idx]);
    pred_set_p = &func_sets[next_prediction_func_set_id];
    DEBRT_PRINTF("got next prediction func set id: %d\n", next_prediction_func_set_id);

    // log what features we send to the DT and what prediction we get back.
    // the predictions might not exactly match training data, but the
    // features should match it exactly.
    //fprintf(fp_out, "%d", next_prediction_func_set_id);
    //for(i = 0; i < NUM_FEATURE_ELEMS; i++){
    //    fprintf(fp_out, ",%d", feature_buf_big[fb_idx+i]);
    //}
    //fprintf(fp_out, "\n");

    return 0;
}
}





extern "C" {
int debrt_cgmonitor(int argc, ...)
{
    int i;
    va_list ap;
    int func_id;
    int feature_buf[MAX_NUM_FEATURES];


    // argc count includes itself, I think. So if argc is 5, it means we'll
    // need a feature buffer size of 4 or larger.
    assert((argc-1) <= MAX_NUM_FEATURES);

    // initialize library
    if(!lib_initialized){
        _debrt_monitor_init(); // ignore return
    }

    // XXX can we avoid this memset?
    memset(feature_buf, 0, MAX_NUM_FEATURES * sizeof(int));

    // gather features into a buffer
    va_start(ap, argc);
    for(i = 0; i < argc; i++){
        feature_buf[i] = va_arg(ap, int);
    }
    va_end(ap);
    func_id = feature_buf[0];

    DEBRT_PRINTF("func_id: %d\n", func_id);

    if(lib_initialized){
        pred_set_p = pred_set_stack.top();
        // Check if the function we just entered is in our predicted set
        if(pred_set_p->find(func_id) == pred_set_p->end()){
            DEBRT_PRINTF("got mispredict\n");
            num_mispredictions++;
        }
        total_predictions++;
    }else{
        lib_initialized = 1;
    }

    // Get a new prediction
    next_prediction_func_set_id = debrt_decision_tree(feature_buf);
    pred_set_p = &func_sets[next_prediction_func_set_id];
    DEBRT_PRINTF("got next prediction func set id: %d\n", next_prediction_func_set_id);

    pred_set_stack.push(pred_set_p);

    return 0;
}
}


extern "C" {
int debrt_cgreturn(long long func_addr)
{
    // TODO: May be able to use debrt-return() as a helper function when
    // we add runtime behavior.
    //debrt_return(func_addr);

    pred_set_stack.pop();

    return 0;
}
}


extern "C" {
int debrt_return(long long func_addr)
{
    long long aligned_func_addr;
    //DEBRT_PRINTF("%s: 0x%llx\n", __FUNCTION__, func_addr);
    //DEBRT_PRINTF("debrt-return func addr: 0x%llx\n", func_addr);
    //_remap_permissions(func_addr, 1, RX_PERM);

    aligned_func_addr = func_addr & ~(PAGE_SIZE-1);
    if(page_to_count[aligned_func_addr] == 0){
        DEBRT_PRINTF("  mapping\n");
        page_to_count[aligned_func_addr] = 1;
        _remap_permissions(func_addr, 1, RX_PERM);
        // FIXME: these will get mapped RX, but they aren't tracked as
        // part of the prediction calls, so they won't get unmapped
    }else{
        //DEBRT_PRINTF("  0x%llx %d\n", aligned_func_addr, page_to_count[aligned_func_addr]);
    }

    return 0;
}
}

extern "C" {
int debrt_protect_loop(int argc, ...)
{
    DEBRT_PRINTF("%s\n", __FUNCTION__);
    return 0;
}
}

extern "C" {
int debrt_protect_loop_end(int argc, ...)
{
    DEBRT_PRINTF("%s\n", __FUNCTION__);
    return 0;
}
}


// Read the all func set IDs and their corresponding func IDs into an array
// of sets called "func_sets". func_sets is indexed by the func set ID. Each
// element is a set of integers, which are the function IDs of that func set.
//
// Example input file (which is created by parse_debprof_out.py)
//   predicted_func_set_id called_func_id1,called_func_id2,...
//   0 -1292216545,-1292216556,-1292216557,
//   1 -1292216556,-1292216557,
//   2 -1292216544,-1292216556,-1292216557,
void _read_func_sets(void)
{
    int i;
    int k;
    string line;
    ifstream ifs;
    vector<string> elems;
    int func_set_id;

#ifdef CGPredict
    ifs.open("cgpprof-func-set-ids-to-funcs.out");
#else
    ifs.open("debprof-func-set-ids-to-funcs.out");
#endif
    if(!ifs.is_open()) {
        perror("Error open");
        exit(EXIT_FAILURE);
    }

    // Construct "func_sets". It's indexed by func set ID. Each element is a
    // a set of function ID.
    i = 0;
    getline(ifs, line); // parse out the header

#ifdef CGPredict
    i++;
    func_sets.push_back(set<int>());
#endif
    while(getline(ifs, line)){
        vector<string> func_ids_str;
        vector<int> func_ids;
        elems = split(line, ' ');
        func_set_id = atoi(elems[0].c_str());
        assert(func_set_id == i);
        func_ids_str = split(elems[1], ',');
        for(k = 0; k < func_ids_str.size(); k++){
            func_ids.push_back(atoi(func_ids_str[k].c_str()));
        }
        set<int> func_id_set(func_ids.begin(), func_ids.end());
        func_sets.push_back(func_id_set);
        i++;
    }

    ifs.close();
}


void _read_nm(void)
{
    int k;
    string line;
    ifstream ifs;
    vector<string> elems;

    ifs.open("nm.out");
    if(!ifs.is_open()){
        perror("Error opening nm file");
        exit(EXIT_FAILURE);
    }

    while(getline(ifs, line)){
        vector<string> line_vec;
        elems = split(line, ' ');
        if(elems.size() == 3){
            //for(k = 0; k < elems.size(); k++){
            //    cout << elems[k] << " ";
            //}
            //cout << endl;
            long long offset;
            string func_name;
            offset = strtoll(elems[0].c_str(), NULL, 16);
            func_name = elems[2];
            func_name_to_offset[func_name] = offset;
        }
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
                func_size = strtol(token.c_str(), NULL, 10);

            // func name
            }else if(which_token == RELF_NAME){
                func_name = token;
                // check that the name is part of whatever we got in nm.
                if(func_name_to_id.find(func_name) != func_name_to_id.end()){
                    int func_id = func_name_to_id[func_name];
                    func_id_to_addr_and_size[func_id] = make_pair(func_addr, func_size);
                    vector<long long> pages;
                    long long first_page;
                    long long last_page;
                    long long p;
                    first_page = (executable_addr_base + func_addr) & ~(PAGE_SIZE-1);
                    last_page  = (executable_addr_base + func_addr + func_size) & ~(PAGE_SIZE-1);
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
        if(elems.size() >= 2 && (elems[1].compare(".text") == 0)){
            text_offset = stoll(elems[3], 0, 16);
            getline(ifs, line);
            elems = split_nonempty(line, ' ');
            text_size = stoll(elems[0], 0, 16);
            DEBRT_PRINTF("text_offset is: 0x%llx\n", text_offset);
            DEBRT_PRINTF("text_size is:   0x%llx\n", text_size);
            break;
        }
    }
    ifs.close();
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
        num_spaces = 0;
        long long addr_base;
        long long addr_end;
        char *binary_name;
        char *c = line;
        state = GET_BASE_ADDR;
        while(*c){
            if(state == GET_BASE_ADDR && *c == '-'){
                //printf("state was GET_BASE_ADDR\n");
                *c = '\0';
                addr_base = strtoll(line, NULL, 16);
                c++;
                addr_end = strtoll(c, NULL, 16);
                state++;
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
                        goto gdb_workaround;
                    }
                }
            }
            c++;
        }
    }
gdb_workaround:
    //DEBRT_PRINTF("num exec lines: %d\n", num_executable_binary_lines);
    //cout << "2 my pid is " << getpid() << endl;
    //cout << "2 getenv is " << getenv("_") << endl;
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

    ifs.open("wpd_func_name_to_id.txt");
    if(!ifs.is_open()){
        perror("Error openening wpd-func-name-to-id file");
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

    ifs.open("wpd_func_ptrs.txt");
    if(!ifs.is_open()){
        perror("Error openening wpd-func-name-to-id file");
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



int _debrt_monitor_init(void)
{
    int e;
    const char *output_filename;

    output_filename = getenv("DEBRT_OUT");
    if(!output_filename){
        output_filename = DEFAULT_OUTPUT_FILENAME;
    }
    fp_out = fopen(output_filename, "w");
    if(!fp_out){
        e = errno;
        fprintf(stderr, "_debrt_monitor_init failed to open %s (errno: %d)\n",
                        output_filename, e);
        return e;
    }

    _read_func_sets();

    atexit(_debrt_monitor_destroy);

    return 0;
}



void _debrt_monitor_destroy(void)
{
    int e;
    int rc;
    fprintf(fp_out, "num_mispredictions: %d\n", num_mispredictions);
    fprintf(fp_out, "total_predictions:  %d\n", total_predictions);

    //fprintf(fp_out, "\nfunc_sets:\n");
    //int i;
    //for(i = 0; i < func_sets.size(); i++){
    //    fprintf(fp_out, "%d ", i);
    //    for(set<int>::iterator it = func_sets[i].begin();
    //        it != func_sets[i].end();
    //        it++){
    //          fprintf(fp_out, "%d,", *it);
    //    }
    //    fprintf(fp_out, "\n");
    //}

    rc = fclose(fp_out);
    if(rc == EOF){
        e = errno;
        fprintf(stderr, "_debrt_monitor_destroy failed to close output file " \
                        "(errno: %d)\n", e);
    }
}


void _debrt_protect_all_pages(void)
{
    DEBRT_PRINTF("PROTECTING ALL PAGES\n");
    // FIXME ? not tested, dont trust this code yet
    long long text_start = executable_addr_base + text_offset;
    long long text_end   = text_start + text_size;
    long long text_start_aligned = text_start & ~(0x1000-1);
    long long text_end_aligned   = text_end   & ~(0x1000-1);
    if(text_start_aligned == text_end_aligned){
        // probably need to remove this assert. It means the text section is
        // so small that we can't zero out any pages.
        assert(0 && "text start and end are equal. test case is too small for a page-based technique\n");
    }
    // FIXME we assume text was never aligned to begin with, but we should check.
    // We go up by 1 page, b/c o/w we'd mark shit that's not in .text when marking the starting page.
    // ... do similarly for the end
    text_start_aligned += 0x1000;
    text_end_aligned   -= 0x1000;
    assert(text_start_aligned < text_end_aligned && "text start and end are too close (maybe just 2 diffrent pages... test case is too small for a page-based technique\n");
    if(mprotect((void *)text_start_aligned, text_end_aligned - text_start_aligned, RO_PERM) == -1){
        DEBRT_PRINTF("mprotect error\n");
        assert(0 && "mprotect error");
    }
    DEBRT_PRINTF("  mprotect succeeded\n");
}
void _debrt_protect_no_pages(void)
{
    long long size;
    size = executable_addr_end - executable_addr_base;
    size = size - 1; // XXX avoids mapping the end page itself, which causes segfault
    _remap_permissions(executable_addr_base, size, RX_PERM);
}

void _debrt_map_ptd_to_funcs(void)
{
    DEBRT_PRINTF("mapping RX any pages of ptd-to funcs\n");
    for(auto func_id : ptd_to_func_ids){
        update_page_counts(func_id, 1);
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


int _debrt_protect_init(int please_read_func_sets)
{
    int e;
    const char *output_filename;

    output_filename = getenv("DEBRT_OUT");
    if(!output_filename){
        output_filename = DEFAULT_OUTPUT_FILENAME;
    }
    fp_out = fopen(output_filename, "w");
    if(!fp_out){
        e = errno;
        fprintf(stderr, "_debrt_monitor_init failed to open %s (errno: %d)\n",
                        output_filename, e);
        return e;
    }

    if(please_read_func_sets){
        _read_func_sets();
    }


    _set_addr_of_main_mapping();
    DEBRT_PRINTF("executable_addr_base: 0x%llx\n", executable_addr_base);
    DEBRT_PRINTF("executable_addr_end:  0x%llx\n", executable_addr_end);
    _read_func_name_to_id();
    //_dump_func_name_to_id();
    _read_func_ptrs(); // XXX has to happen after read-func-name-to-id
    _read_nm();
    _read_readelf();
    _read_readelf_sections();

    _dump_func_id_to_pages();
    _dump_func_id_to_addr_and_size();

    _init_page_to_count();

    atexit(_debrt_protect_destroy);

    _debrt_protect_all_pages();
    _debrt_map_ptd_to_funcs();

    return 0;
}

void _debrt_protect_destroy(void)
{
    int e;
    int rc;
    fprintf(fp_out, "num_mispredictions: %d\n", num_mispredictions);
    fprintf(fp_out, "total_predictions:  %d\n", total_predictions);

    rc = fclose(fp_out);
    if(rc == EOF){
        e = errno;
        fprintf(stderr, "_debrt_monitor_destroy failed to close output file " \
                        "(errno: %d)\n", e);
    }
}





extern "C" {
int debrt_protect(int argc, ...)
{
    int i;
    va_list ap;
    int func_id;
    DEBRT_PRINTF("%s\n", __FUNCTION__);

    // initialize library
    if(!lib_initialized){
        _debrt_protect_init(0 /*dont read func sets*/); // ignore return
        lib_initialized = 1;
    }

    va_start(ap, argc);
    for(i = 0; i < argc; i++){
        func_id = va_arg(ap, int);
        DEBRT_PRINTF("INC page count for func_id %d\n", func_id);
        update_page_counts(func_id, 1);
    }
    va_end(ap);

    // if this is the first protect call, we need to make sure the caller's page
    // is still executable.
    if(lib_initialized == 1){
        DEBRT_PRINTF("ensuring first protect caller is still RX\n");
        long long return_addr = (long long) __builtin_return_address(0);
        _assert_return_addr_in_main(return_addr);
        update_page_counts(func_name_to_id["main"], 1);
        lib_initialized = 2;
    }

    return 0;
}
}


extern "C" {
int debrt_protect_end(int argc, ...)
{
    int i;
    va_list ap;
    int func_id;
    DEBRT_PRINTF("%s\n", __FUNCTION__);

    assert(lib_initialized && "ERROR: debrt-protect-end hit before debrt-protect\n");

    va_start(ap, argc);
    for(i = 0; i < argc; i++){
        func_id = va_arg(ap, int);
        DEBRT_PRINTF("DEC page count for func_id %d\n", func_id);
        update_page_counts(func_id, -1);
    }
    va_end(ap);

    return 0;
}
}

