#!/usr/bin/env python3
import sys
import json


avg_metrics = {}
avg_metrics_count = {}
min_metrics = {}
max_metrics = {}


def read_metrics(json_file):
    with open(json_file) as f:
        data = json.load(f)
    return data


def dump_metrics(metrics):
    for key in sorted(metrics):
        print('{} {}'.format(key, metrics[key]))


# TODO: uh, better way to do this?
def init_if_needed(key, avg_metrics, min_metrics, max_metrics):
    if key not in avg_metrics:
        avg_metrics[key] = 0
    if key not in min_metrics:
        min_metrics[key] = 0
    if key not in max_metrics:
        max_metrics[key] = 0


def read_nginx_metrics():
    
    METRICS_FOLDER = 'nginx-parsed-metrics-output'

    for x in range(142):
        print('Reading metrics for nginx page group {}'.format(x))
        base_filename = 'nginx_pg_{}'.format(x)
        metrics_filename = METRICS_FOLDER + '/' + base_filename + '_metrics.json'
        metrics = read_metrics(metrics_filename)
        #print(metrics)
        
        for key, val in metrics.items():
            avg_metrics[key] = avg_metrics.get(key, 0) + val
            avg_metrics_count[key] = avg_metrics_count.get(key, 0) + 1
            min_metrics[key] = val if val < min_metrics.get(key, sys.maxsize) else min_metrics[key]
            max_metrics[key] = val if val > max_metrics.get(key, -1) else max_metrics[key]

    for key in avg_metrics:
        avg_metrics[key] = avg_metrics[key] / avg_metrics_count[key]




def collate():
    print('avg metrics')
    dump_metrics(avg_metrics)

    print('min metrics')
    dump_metrics(min_metrics)
    
    print('max metrics')
    dump_metrics(max_metrics)

    

def main():
    read_nginx_metrics()
    collate()


main()