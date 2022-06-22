#!/usr/bin/env python3
import os
import sys
import subprocess



# Algorithm:
# Two passes through the debrt-mapped-rx-pages.out files.
# On the first pass, create a copy of the original binary for each unique 
# page group.
# On the second pass, for each unique page group, zero out pages that aren't
# part of the page group.
# And that's it for this tool.
# The next tool will be a shell script that copies
# the modified bins into rop-benchmark orig folder and builds their vuln
# version.
# And the final tool will scan rx-pages again and launch the rop tool for each
# line (i.e. for each page group)


if len(sys.argv) == 2:
    benchmarks = [
        sys.argv[1]
    ]
else:
    benchmarks = [
        'nginx',
    ]

BASE_FOLDER = '/home/rudy/wo/whole-program-debloat/src/gadget-chains'
INPUT_PATH = BASE_FOLDER + '/input'
OUTPUT_PATH = BASE_FOLDER + '/output'
MAPPED_PAGES_FILENAME = 'debrt-mapped-rx-pages_3_wpd_cl_ics.out'
BMARK_SUFFIX = 'wpd_custlink_ics'


def get_text_offset(benchmark):
    cmd = "objdump -h {}/{}/{}/{}_{} | grep .text".format(INPUT_PATH, benchmark, benchmark, benchmark, BMARK_SUFFIX)
    result = subprocess.getoutput(cmd)
    offset = int(result.split()[5], 16)
    return offset


def get_text_size(benchmark):
    cmd = "objdump -h {}/{}/{}/{}_{} | grep .text".format(INPUT_PATH, benchmark, benchmark, benchmark, BMARK_SUFFIX)
    result = subprocess.getoutput(cmd)
    size = int(result.split()[2], 16)
    return size


def cp_orig_bin_to_start_page_group_bin(benchmark, page_group_id):
    cmd = 'cp {}/{}/{}/{}_{} {}/{}/{}/{}_pg_{}.bin'.format(INPUT_PATH, benchmark, benchmark, benchmark, BMARK_SUFFIX, OUTPUT_PATH, benchmark, benchmark, benchmark, page_group_id)
    # XXX skipping binary copy command b/c it is already done and script is under development
    #rc = subprocess.call(cmd, shell=True)
    #assert rc == 0


def zero_out_file_part(benchmark, page_group_id, offset, size):
    # ./zofp file offset size
    cmd = "./zero_out_file_part/zofp {}/{}/{}/{}_pg_{}.bin {} {}".format(OUTPUT_PATH, benchmark, benchmark, benchmark, page_group_id, offset, size)
    rc = subprocess.call(cmd, shell=True)
    assert rc == 0


def main():

    for benchmark in benchmarks:

        # A "page group" is just a line in the debrt-mapped-rx-pages.out file. 
        # We assign an ID for each unique line we find in the different
        # mapped-rx files.
        page_group_id_to_group = {} # map of page group ID -> its page indices
        page_group_to_id = {} # map of page group -> ID
        page_group_counter = 0 # counter for assigning a unique ID for each "pg"

        text_offset = get_text_offset(benchmark)
        text_size   = get_text_size(benchmark)
        rx_pages_files = ['{}/{}/{}/{}'.format(INPUT_PATH, benchmark, benchmark, MAPPED_PAGES_FILENAME)]
        already_copied_page_groups = set()
        already_done_page_groups = set()
        #print('text_offset: {}'.format(text_offset))
        #print('text_size:   {}'.format(text_size))

        # Read all of the debrt-mapped-rx-pages.out, and create individual
        # page group bin files for each unique page group we encounter across
        # all our inputs. These are just copies of the original bin for now.
        # We will change them in the next step.
        for rx_pages_file in rx_pages_files:
            with open(rx_pages_file) as f:
                for line in f:
                    page_indices = line.strip().split()
                    page_indices.sort()
                    page_group = ' '.join(page_indices)
                    if page_group not in already_copied_page_groups:
                        cp_orig_bin_to_start_page_group_bin(benchmark, page_group_counter)
                        already_copied_page_groups.add(page_group)
                        page_group_id_to_group[page_group_counter] = page_group
                        page_group_to_id[page_group] = page_group_counter
                        page_group_counter += 1

        # Read all of the debrt-mapped-rx-pages.out again, but this time,
        # when we come across an 
        # zero out every page that is not part of the "page group" (a line from
        # debrt-mapped-rx-pages.out)
        for rx_pages_file in rx_pages_files:
            with open(rx_pages_file) as f:
                for line in f:
                    page_indices = line.strip().split()
                    page_indices.sort()

                    page_group = ' '.join(page_indices)
                    if page_group not in already_done_page_groups:

                        already_done_page_groups.add(page_group)
                        page_indices_set = set(map(int, page_indices))
                        page_group_id = page_group_to_id[page_group]
                        print('Working on page_group_id: {}'.format(page_group_id))
                        #print('  {}'.format(page_group))

                        offset_to_zero = text_offset
                        text_end = text_offset + text_size
                        page_idx = 0
                        size_to_zero = 0

                        while (offset_to_zero + size_to_zero) < text_end:
                            if page_idx in page_indices_set:
                                if size_to_zero == 0:
                                    page_idx += 1
                                    offset_to_zero += 4096
                                    continue
                                if offset_to_zero + size_to_zero > text_end:
                                    size_to_zero = text_end - offset_to_zero
                                assert size_to_zero >= 0 # could fail if somehow text-offset + size is messed up
                                #print(page_idx)
                                zero_out_file_part(benchmark, page_group_id, offset_to_zero, size_to_zero)
                                offset_to_zero += size_to_zero
                                offset_to_zero += 4096
                                page_idx += 1
                                size_to_zero = 0
                            else:
                                size_to_zero += 4096
                                page_idx += 1
                        if size_to_zero > 0:
                            size_to_zero = text_end - offset_to_zero
                            zero_out_file_part(benchmark, page_group_id, offset_to_zero, size_to_zero)


        # "Page group ID" is a new ID-concept we've introduced. So here we
        # write to file the ID-to-group mapping. Eventually it's the binaries
        # of page groups (i.e. the *_pg_*.bin files) that get checked by the
        # ROP tool. So it will be useful to know which pages were part of the
        # group.
        with open('{}/{}/{}/{}_page_groups'.format(OUTPUT_PATH, benchmark, benchmark, benchmark), 'w') as f:
            for page_group_id, page_group in sorted(page_group_id_to_group.items()):
                f.write('{}: {}\n'.format(page_group_id, page_group))




main()
