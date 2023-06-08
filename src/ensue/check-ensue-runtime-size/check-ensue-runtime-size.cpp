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
//   Grab the "VmData" field, say, and then rebuild and rerun the program
//   without _read_ensue(), and do record the "VmData" field again. The
//   difference is the size of the ensue data structure.
//
//

#include <stdio.h>
#include <unistd.h>
#include <assert.h>

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


int main(void)
{
    _read_ensue();
    while(1){
        printf("my pid is: %d\n", getpid());
        sleep(3);
    }
    return 0;
}

