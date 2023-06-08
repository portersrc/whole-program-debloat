//
//
// This is a hacky way to check the runtime size of the ensue relations
// in memory. We read the ensue relations into a map of sets. Then we just
// leave the program in a sleepy infinite loop and print its pid.
// In another terminal, check the memory by doing something like:
//   $ cd /proc/<pid>
//   $ cat status | grep Vm
// Not 100% clear which Vm field to use, but explanations abound, e.g.
//   https://ewx.livejournal.com/579283.html
//
// At the end of the data, though, the idea is:
//   Use the "VmData" field.
//   Run this program:
//     ./a.out no
//   This runs it without reading ensue data.
//   Use the points above to go into the /proc/<pid> and get VmData.
//   At the time of this writing, VmData without reading ensue is:
//     VmData:      224 kB
//   Rerun this program:
//     ./a.out yes
//   Capture the VmData as before (cat /proc/<pid>/status and look at VmData).
//   The difference between the VmData sizes is the size of the ensue structure in memory.
//
//
// Assumption: In this folder, symlink the artd-datalog-ensue.out file to
// check, e.g.
//   $ rm -f artd-datalog-ensue.out
//   $ ln -s /home/rudy/wo/spec/spec2017/benchspec/CPU/520.omnetpp_r/build/build_peak_mytest-m64.0000/artd-datalog-ensue.out
//
//

#include <stdio.h>
#include <unistd.h>
#include <assert.h>
#include <string.h>

#include <iostream>
#include <string>
#include <sstream>
#include <fstream>
#include <vector>
#include <map>
#include <set>




using namespace std;


map<int, set<int> > ensue;


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

void _read_ensue(void)
{
    int i;
    int k;
    string line;
    ifstream ifs;
    vector<string> elems;
    int func_set_id;

    ifs.open("artd-datalog-ensue.out");
    if(!ifs.is_open()) {
        fprintf(stderr, "ERROR: Failed to open artd-datalog-ensue.out.\n");
        exit(EXIT_FAILURE);
    }

    i = 0;
    getline(ifs, line); // parse out the header

    while(getline(ifs, line)){
        // callsite_a: chop off "ensue("
        // callsite_b: chop of prefix  " " and suffix  ")."

        elems = split(line, ',');
        int callsite_a = atoi(elems[0].substr(6).c_str());
        int callsite_b = atoi(elems[1].substr(1, elems[1].length()-3).c_str());

        //cout << callsite_a << " " << callsite_b << "\n";
        assert(ensue[callsite_a].find(callsite_b) == ensue[callsite_a].end());
        ensue[callsite_a].insert(callsite_b);
        ensue[callsite_a].insert(callsite_b);

    }

    ifs.close();
}

void err_and_exit(void)
{
    fprintf(stderr, "\nERROR: Incorrect args. Pass \"yes\" or \"no\" to read or not read ensue.\n\n");
    exit(1);
}

int parse_args(int argc, char **argv)
{
    if(argc != 2){
        err_and_exit();
    }
    if(0 == strncmp("yes", argv[1], 3)){
        return 1;
    }else if(0 == strncmp("no", argv[1], 3)){
        return 0;
    }
    err_and_exit();
    return -1;
}

int main(int argc, char *argv[])
{
    int yes_read_ensue = parse_args(argc, argv);
    if(yes_read_ensue){
        printf("\nReading ensue relations from ./artd-data-log-ensue.out\n\n");
        _read_ensue();
    }else{
        printf("\nNot reading any ensue relations\n\n");
    }

    while(1){
        printf("my pid is: %d\n", getpid());
        sleep(3);
    }
    return 0;
}

