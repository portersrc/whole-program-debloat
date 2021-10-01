#!/usr/bin/env python3
import os
import sys
import subprocess



# Algorithm:
# Two passes through the debrt-mapped-rx-pages.out files.
# On the first pass, create a binary for each individual page, if it doesn't
# yet exist.
# On the second pass, each line will be its own merged set of pages. Merge
# those binaries with cat. (Use cat but make sure the binary sizes afterwards
# make sense, e.g. a 2-page binary should be 4096 * 2 B.) Again, only
# create the merged binaries if they don't yet exist. Ensure we sort the pages
# of a line beforehand to help with this.
# And that's it for this tool.
# The next tool will be a shell script that copies
# the merged page bins into rop-benchmark orig folder and builds their vuln
# version.
# And the final tool will scan rx-pages again and launch the rop tool for each
# line (i.e. for each page group)


if len(sys.argv) == 2:
    benchmarks = [
        sys.argv[1]
    ]
else:
    benchmarks = [
        'bzip2',
        'chown',
        'date',
        'grep',
        'gzip',
        'mkdir',
        'rm',
        'sort',
        'tar',
        'uniq',
    ]


BASE_FOLDER = '/home/rudy/wo/whole-program-debloat/src/gadget-chains'
INPUT_PATH = BASE_FOLDER + '/input'
OUTPUT_PATH = BASE_FOLDER + '/output'
MAPPED_PAGES_FILE_PREFIX = 'debrt-mapped-rx-pages'
BMARK_SUFFIX = 'wpd_custlink_ics_nostatic'

def get_text_offset(benchmark):
    cmd = "objdump -h {}/{}/{}_{} | grep .text".format(INPUT_PATH, benchmark, benchmark, BMARK_SUFFIX)
    result = subprocess.getoutput(cmd)
    offset = int(result.split()[3], 16)
    return offset


def make_individual_bin_for_page(page_idx, benchmark, text_offset):
    #print('dd if: {}/{}/{}_{}'.format(INPUT_PATH, benchmark, benchmark, BMARK_SUFFIX))
    #print('dd of: {}/{}/{}_{}.bin'.format(OUTPUT_PATH, benchmark, benchmark, page_idx))
    cmd = "dd if={}/{}/{}_{} of={}/{}/{}_{}.bin skip={} count=4096 iflag=skip_bytes,count_bytes".format(INPUT_PATH, benchmark, benchmark, BMARK_SUFFIX, OUTPUT_PATH, benchmark, benchmark, page_idx, text_offset)
    rc = subprocess.call(cmd, shell=True)
    assert rc == 0


def make_page_group_bin_for_page_group(page_indices, benchmark, page_group_id):
    bins = ''
    for page_idx in page_indices:
        bins += '{}/{}/{}_{}.bin '.format(OUTPUT_PATH, benchmark, benchmark, page_idx)
    cmd = 'cat {} >> {}/{}/{}_pg_{}.bin'.format(bins, OUTPUT_PATH, benchmark, benchmark, page_group_id)
    #print(cmd)
    rc = subprocess.call(cmd, shell=True)
    assert rc == 0


def main():

    for benchmark in benchmarks:

        # A "page group" is just a line in the debrt-mapped-rx-pages.out file. 
        # We assign an ID for each unique line we find in the different
        # mapped-rx files.
        page_groups = {} # map of page group ID -> its page indices
        page_group_counter = 0 # counter for assigning a unique ID for each "pg"

        text_offset = get_text_offset(benchmark)
        rx_pages_files = ['{}/{}/{}'.format(INPUT_PATH, benchmark, x)
                          for x in os.listdir(INPUT_PATH+'/'+benchmark)
                            if x.startswith(MAPPED_PAGES_FILE_PREFIX)]
        already_done_pages = set()
        already_done_page_groups = set()

        # Read all of the debrt-mapped-rx-pages.out, and create individual
        # bin files for each unique page we encountered across all our inputs
        for rx_pages_file in rx_pages_files:
            with open(rx_pages_file) as f:
                for line in f:
                    page_indices = line.strip().split()
                    for page_idx in page_indices:
                        if page_idx not in already_done_pages:
                            make_individual_bin_for_page(page_idx, benchmark, text_offset)
                            already_done_pages.add(page_idx)

        # Read all of the debrt-mapped-rx-pages.out again, but this time
        # create individual bin files for each unique "page group" (a line from
        # debrt-mapped-rx-pages.out)
        for rx_pages_file in rx_pages_files:
            with open(rx_pages_file) as f:
                for line in f:
                    page_indices = line.strip().split()
                    page_indices.sort()
                    page_group_key = ' '.join(page_indices)
                    if page_group_key not in already_done_page_groups:
                        make_page_group_bin_for_page_group(page_indices, benchmark, page_group_counter)
                        already_done_page_groups.add(page_group_key)
                        page_groups[page_group_counter] = page_group_key
                        page_group_counter += 1

        # "Page group ID" is a new ID-concept we've introduced. So here we
        # write to file the ID-to-group mapping. Eventually it's the binaries
        # of page groups (i.e. the *_pg_*.bin files) that get checked by the
        # ROP tool. So it will be useful to know which pages were part of the
        # group.
        with open('{}/{}/{}_page_groups'.format(OUTPUT_PATH, benchmark, benchmark), 'w') as f:
            for page_group_id, page_group in sorted(page_groups.items()):
                f.write('{}: {}\n'.format(page_group_id, page_group))



main()
