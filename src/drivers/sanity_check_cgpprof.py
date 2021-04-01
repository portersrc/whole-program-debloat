#!/usr/bin/env python3
import sys

bugs = []
count_map = {}

class ALine:
    def __init__(self, line_num, line, comment=''):
        self.line_num = line_num
        self.line     = line
        self.comment  = comment


with open('train-cgpprof.out') as f:
    i = 1
    for line in f:
        line = line.strip()
        if 'FUNC_START' in line or 'FUNC_END' in line:
            line_vec = line.split()
            assert(len(line_vec) == 2)
            func_id = int(line_vec[1])

            if 'FUNC_START' in line:
                if func_id not in count_map:
                    count_map[func_id] = 0
                count_map[func_id] += 1
            else:
                if func_id not in count_map:
                    bugs.append(ALine(i, line, '-- func-end before start'))
                else:
                    count_map[func_id] -= 1
            if count_map[func_id] < 0:
                    bugs.append(ALine(i, line, '-- func-id count dropped below 0'))
        
        else:
            bugs.append(ALine(i, line, '-- neither func-start nor end'))

        i += 1


print()
print('Size of bugs: {}'.format(len(bugs)))
for b in bugs:
    print('{} {} {}'.format(b.line_num, b.line, b.comment))
print()

print('count_map dump: {}'.format(count_map))
print
print('Size of count_map: {}'.format(len(count_map)))
print('Nonzero counts (func_id -> count):')
for func_id, count in count_map.items():
    if count != 0:
        print('  {} -> {}'.format(func_id, count))
print
