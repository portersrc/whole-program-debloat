#include <stdio.h>
#include <stdarg.h>
#include <stdlib.h>
#include <errno.h>                                                              
#include <assert.h>
#include <string.h>
#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include <vector>
#include <set>
#include <queue>
#include "debrt_decision_tree.h"

using namespace std;









// XXX this could be read in? It varies based on the benchmark. we have
// an assert in case this is violated. Could double size or fix properly
// if that happens
const int MAX_NUM_FEATURES = 64;

const int CALLSITE_ID_IDX    = 0;
const int CALLED_FUNC_ID_IDX = 1;

const char *DEFAULT_OUTPUT_FILENAME = "debrt.out";
FILE *fp_out;


vector<set<int> > func_sets;
set<int> *pred_set_p;
int next_prediction_func_set_id;
int num_mispredictions;
int total_predictions;


int  _debrt_init(void);
void _debrt_destroy(void);





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
    static int lib_initialized = 0;
    int i;
    va_list ap;
    int feature_buf[MAX_NUM_FEATURES];
    int function_were_about_to_call;

    // argc count includes itself, I think. So if argc is 5, it means we'll
    // need a feature buffer size of 4 or larger.
    assert((argc-1) <= MAX_NUM_FEATURES);

    // initialize library
    if(!lib_initialized){
        _debrt_init(); // ignore return
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
        next_prediction_func_set_id = debrt_decision_tree(feature_buf);
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
    next_prediction_func_set_id = debrt_decision_tree(feature_buf);
    pred_set_p = &func_sets[next_prediction_func_set_id];

    return 0;
}
}

/*extern "C" {
int debrt_monitor(int argc, ...)
{
    static int lib_initialized = 0;
    int i;
    va_list ap;
    int feature_buf[MAX_NUM_FEATURES];
    int function_were_about_to_call;

    // argc count includes itself, I think. So if argc is 5, it means we'll
    // need a feature buffer size of 4 or larger.
    assert((argc-1) <= MAX_NUM_FEATURES);

    // initialize library
    if(!lib_initialized){
        _debrt_init(); // ignore return
        lib_initialized = 1;
        // Get a new prediction
        next_prediction_func_set_id = debrt_decision_tree(feature_buf);
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
    next_prediction_func_set_id = debrt_decision_tree(feature_buf);
    pred_set_p = &func_sets[next_prediction_func_set_id];

    return 0;
}*/


// Read the all func set IDs and their corresponding func IDs into an array
// of sets called "func_sets". func_sets is indexed by the func set ID. Each
// element is a set of integers, which are the function IDs of that func set.
//
// Example input file (which is created by parse_debprof_out.py)
//   predicted_func_set_id called_func_id1,called_func_id2,...
//   0 -1292216545,-1292216556,-1292216557,
//   1 -1292216556,-1292216557,
//   2 -1292216544,-1292216556,-1292216557,
void read_func_sets(void)
{
    int i;
    int k;
    string line;
    ifstream ifs;
    vector<string> elems;
    int func_set_id;

    ifs.open("debprof-func-set-ids-to-funcs.out");
    if(!ifs.is_open()) {
        perror("Error open");
        exit(EXIT_FAILURE);
    }

    // Construct "func_sets". It's indexed by func set ID. Each element is a
    // a set of function ID.
    i = 0;
    getline(ifs, line); // parse out the header
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
}


int _debrt_init(void)
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
        fprintf(stderr, "debrt_init failed to open %s (errno: %d)\n",
                        output_filename, e);
        return e;
    }

    read_func_sets();

    atexit(_debrt_destroy);

    return 0;
}


void _debrt_destroy(void)
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
        fprintf(stderr, "debrt_destroy failed to close output file " \
                        "(errno: %d)\n", e);
    }
}
