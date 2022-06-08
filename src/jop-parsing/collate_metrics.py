#!/usr/bin/env python3
import sys
import json


# Should be exactly the number of files.
# IDs start at 0, so this is also equal to max ID - 1
#NUM_PG_FILES = 142
NUM_PG_FILES = 119


avg_metrics = {}
avg_metrics_count = {}
min_metrics = {}
max_metrics = {}

MAX_JOP_DEPTH = 20 # XXX should match MAX_JOP_DEPTH in jrp_aux
avg_depth_metrics = [0] * MAX_JOP_DEPTH
avg_depth_metrics_count = 0
min_depth_metrics = [sys.maxsize] * MAX_JOP_DEPTH
max_depth_metrics = [-1] * MAX_JOP_DEPTH


def read_metrics(json_file):
    with open(json_file) as f:
        data = json.load(f)
    return data


def dump_metrics(metrics):
    for key in sorted(metrics):
        print('{} {}'.format(key, metrics[key]))

def dump_all_metrics():
    for key in sorted(min_metrics):
        print('{} {} {} {}'.format(key, min_metrics[key], max_metrics[key], avg_metrics[key]))
    print('depth:')
    for i, d in enumerate(min_depth_metrics):
        print('{} {} {} {}'.format(i, min_depth_metrics[i], max_depth_metrics[i], avg_depth_metrics[i]))


# TODO: uh, better way to do this?
def init_if_needed(key, avg_metrics, min_metrics, max_metrics):
    if key not in avg_metrics:
        avg_metrics[key] = 0
    if key not in min_metrics:
        min_metrics[key] = 0
    if key not in max_metrics:
        max_metrics[key] = 0


def read_nginx_metrics():
    global avg_depth_metrics_count
    
    METRICS_FOLDER = 'nginx-parsed-metrics-output'

    for x in range(NUM_PG_FILES):
        print('Reading metrics for nginx page group {}'.format(x))
        base_filename = 'nginx_pg_{}'.format(x)
        metrics_filename = METRICS_FOLDER + '/' + base_filename + '_metrics.json'
        metrics = read_metrics(metrics_filename)
        #print(metrics)
        
        saw_depth = False
        for key, val in metrics.items():
            if key == 'depth':
                saw_depth = True
                for i, d in enumerate(metrics['depth']):
                    avg_depth_metrics[i] = avg_depth_metrics[i] + d
                    min_depth_metrics[i] = d if d < min_depth_metrics[i] else min_depth_metrics[i]
                    max_depth_metrics[i] = d if d > max_depth_metrics[i] else max_depth_metrics[i]
                avg_depth_metrics_count += 1
            else:
                avg_metrics[key] = avg_metrics.get(key, 0) + val
                avg_metrics_count[key] = avg_metrics_count.get(key, 0) + 1
                min_metrics[key] = val if val < min_metrics.get(key, sys.maxsize) else min_metrics[key]
                max_metrics[key] = val if val > max_metrics.get(key, -1) else max_metrics[key]
        assert saw_depth

    for key in avg_metrics:
        avg_metrics[key] = avg_metrics[key] / avg_metrics_count[key]
    for i, d in enumerate(avg_depth_metrics):
        avg_depth_metrics[i] = avg_depth_metrics[i] / avg_depth_metrics_count
    assert avg_depth_metrics_count == NUM_PG_FILES 




def collate():
    #print('min metrics')
    #dump_metrics(min_metrics)
    
    #print('max metrics')
    #dump_metrics(max_metrics)

    #print('avg metrics')
    #dump_metrics(avg_metrics)
    dump_all_metrics()

    

def main():
    read_nginx_metrics()
    collate()


main()