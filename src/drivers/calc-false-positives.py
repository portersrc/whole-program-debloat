#!/usr/bin/env python3



func_id_to_pages = {}
page_to_func_ids = {}
all_percent_usage_pages = []
all_percent_usage_functions = []


def dump_func_id_to_pages():
    for func_id in func_id_to_pages:
        print('{}:'.format(func_id), end='')
        for page in func_id_to_pages[func_id]:
            print(' {}'.format(page), end='')
        print()


def dump_page_to_func_ids():
    for page in page_to_func_ids:
        print('{}:'.format(page), end='')
        for func_id in page_to_func_ids[page]:
            print(' {}'.format(func_id), end='')
        print()


def calculate_percent_usage(trace_func_ids, pages):
    pages_executed = set()
    pages_mapped = set(pages)
    for func_id in trace_func_ids:
        pages_executed |= func_id_to_pages[func_id]
    percent_usage_pages = len(pages & pages_executed) / len(pages)

    functions_executed = set(trace_func_ids)
    functions_mapped = set()
    for page in pages:
        functions_mapped |= page_to_func_ids[page]
    percent_usage_functions = len(functions_mapped & functions_executed) / len(functions_mapped)

    all_percent_usage_pages.append(percent_usage_pages)
    all_percent_usage_functions.append(percent_usage_functions)


with open('wpd_func_id_to_pages.txt') as f:
    for line in f:
        line = line.strip()
        line_vec = line.split()
        func_id = int(line_vec[0][:-1]) # chop off semicolon
        pages = line_vec[1:]

        func_id_to_pages[func_id] = set()
        for page_str in pages:
            page = int(page_str)
            func_id_to_pages[func_id].add(page)
            if page not in page_to_func_ids:
                page_to_func_ids[page] = set()
            page_to_func_ids[page].add(func_id)


with open('debrt-mapped-rx-pages.out') as f:
    pages_prev = None
    pages_prev_prev = None
    USE_NEXT_TRACE = False
    for line in f:
        line = line.strip()
        if line[0] == 'T':
            trace_func_ids = [int(x) for x in line.split()[1:]]
            if USE_NEXT_TRACE:
                pp = set(pages_prev_prev)
                p = set(pages_prev)
                p - pp
                calculate_percent_usage(trace_func_ids, p - pp)
        else:
            pages = [int(x) for x in line.split()]
            if pages_prev is not None and len(pages) > len(pages_prev):
                USE_NEXT_TRACE = True
            else:
                USE_NEXT_TRACE = False
            pages_prev_prev = pages_prev
            pages_prev = pages


#dump_func_id_to_pages()
#dump_page_to_func_ids()
print('percent-usage-pages:     {}'.format(sum(all_percent_usage_pages)/len(all_percent_usage_pages)))
print('percent-usage-functions: {}'.format(sum(all_percent_usage_functions)/len(all_percent_usage_functions)))
