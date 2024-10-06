#!/usr/bin/env python3
import sys

dt_header_filename = sys.argv[1] # e.g. nab/debrt_decision_tree.h
max_depths = []
with open(dt_header_filename) as f:
    print(dt_header_filename)
    d = -1
    init = 0
    for line in f:
        if "case" in line:
            if d >= 0:
                max_depths.append(d)
                d = -1
            else:
                init += 1
        if "return" in line:
            tmp = line.count('\t')
            if tmp > d:
                d = tmp
        if "default" in line:
            assert d != -1
            max_depths.append(d)
            break
    assert init == 1
print('max-depth-of-all-DTs: {}'.format(max([x-1 for x in max_depths])))
print('number-of-DTs: {}'.format(len(max_depths)))
print('max-depths-of-DTs:')
print([x-1 for x in max_depths])
print('max depth count 1s: {}'.format(max_depths.count(2)))
print()
