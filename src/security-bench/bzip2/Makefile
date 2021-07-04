VERSION = 2.19
VERSADD = 
VPATH=. $(RESDIR)

# To assist in cross-compiling
CC=clang
AR=ar
RANLIB=ranlib
LDFLAGS= -Wl,-s $(VERSADD)
  
CFLAGS = -D_FILE_OFFSET_BITS=64 -fPIC -O3 -ffunction-sections -g -c
CFLAGSL = -D_FILE_OFFSET_BITS=64 -O3 -ffunction-sections -emit-llvm -S
HEADERS = -I.
LIBS = 


LIB= blocksort.o  \
      huffman.o    \
      crctable.o   \
      randtable.o  \
      compress.o   \
      decompress.o \
      bzlib.o

LIBBITCODES=blocksort.bc  \
      huffman.bc    \
      crctable.bc   \
      randtable.bc  \
      compress.bc   \
      decompress.bc \
      bzlib.bc

BZIP= bzip2.bc

BZIPR= bzip2recover.bc

.SUFFIXES:
.SUFFIXES: .c .o .bc

all: base_ls_nostatic wpd_nostatic wpd_custlink_nostatic 
# bzip2recover_ls_nostatic bzip2recover_nostatic bzip2recover_custlink_nostatic
# bzip2_ls_static bzip2_static bzip2_custlink_static bzip2recover_ls_static bzip2recover_static bzip2recover_custlink_static
# bzip2_ls_static: libbz2.a $(BZIP)
# 	llvm-link $(BZIP) -o bzip2_linked_static.bc
# 	opt \
# 	  --function-sections \
#       -O3 \
#       -loop-simplify \
#       < bzip2_linked_static.bc \
#       > bzip2_baseline_ls_opt_static.bc
# 	llc  \
# 	  --function-sections \
#       bzip2_baseline_ls_opt_static.bc \
#       -relocation-model=pic \
#       -o bzip2_opt_static.s
# 	g++ \
# 	  -no-pie \
# 	  -ffunction-sections \
# 	  -Wl,--verbose \
#       bzip2_opt_static.s \
#       -o bzip2_static \
#       -lm -lrt -Llib -lgreputils > linker.lds
# 	cp linker.lds linker_static.lds

# bzip2_static: libbz2.a $(BZIP)
# 	llvm-link $(BZIP) -o bzip2_linked_static.bc
# 	opt \
# 	  --function-sections \
#       -O3 \
#       -loop-simplify \
#       < bzip2_linked_static.bc \
#       > bzip2_baseline_ls_opt_static.bc
# 	opt \
# 	  --function-sections \
#       -load libWholeProgramDebloat.so \
#       -WholeProgramDebloat \
#       < bzip2_baseline_ls_opt_static.bc \
#       > bzip2_wpd_opt_static.bc
# 	llc  \
# 	  --function-sections \
#       bzip2_wpd_opt_static.bc \
#       -relocation-model=pic \
#       -o bzip2_wpd_opt_static.s
# 	g++ \
# 	  -no-pie \
# 	  -ffunction-sections \
# 	  -Wl,--verbose \
#       bzip2_wpd_opt_static.s \
#       -o bzip2_wpd_static \
#       -ldebloat_rt -lm -lrt -Llib -lgreputil > linker.lds
# 	readelf -s --wide bzip2_wpd_static > readelf-wpd-static.out
# 	readelf --sections bzip2_wpd_static > readelf-sections-wpd-static.out
# 	cp wpd_disjoint_sets.txt wpd_disjoint_sets_static.txt
# 	cp wpd_encompassed_funcs.txt wpd_encompassed_funcs_static.txt
# 	cp wpd_static_reachability.txt wpd_static_reachability_static.txt
# 	cp wpd_loop_static_reachability.txt wpd_loop_static_reachability_static.txt
# 	cp wpd_loop_to_func.txt wpd_loop_to_func_static.txt
# 	cp wpd_static_reachability.txt wpd_static_reachability_static.txt
# 	cp wpd_loop_static_reachability.txt wpd_loop_static_reachability_static.txt
# 	cp wpd_stats.txt wpd_stats_static.txt
# 	cp wpd_func_name_to_id.txt wpd_func_name_to_id_static.txt
# 	cp wpd_func_name_has_addr_taken.txt wpd_func_name_has_addr_taken_static.txt
# 	python3 linker.py .

# bzip2_custlink_static: libbz2.a bzip2_wpd_opt_static.s
# 	g++ \
# 	  -no-pie \
#       -ffunction-sections \
#       -c bzip2_wpd_opt_static.s \
#       -o bzip2_wpd_custlink_opt_static.o
# 	g++ \
# 	  -no-pie \
# 	  -ffunction-sections \
#       -T wpd-linker-script.lds \
#       bzip2_wpd_custlink_opt_static.o \
#       -o bzip2_wpd_custlink_static \
#       -ldebloat_rt -lm -lrt -Llib -lgreputil
# 	readelf -s --wide bzip2_wpd_custlink_static > readelf-wpd-custlink-static.out
# 	readelf --sections bzip2_wpd_custlink_static > readelf-sections-wpd-custlink-static.out

base_ls_nostatic: $(LIBBITCODES) $(BZIP)
	llvm-link $(LIBBITCODES) $(BZIP) -o bzip2_linked_nostatic.bc
	opt \
	  --function-sections \
      -O3 \
      -loop-simplify \
      < bzip2_linked_nostatic.bc \
      > bzip2_baseline_ls_opt_nostatic.bc
	llc  \
	  --function-sections \
      bzip2_baseline_ls_opt_nostatic.bc \
      -relocation-model=pic \
      -o bzip2_opt_nostatic.s
	g++ \
	  -no-pie \
	  -ffunction-sections \
	  -Wl,--verbose \
      bzip2_opt_nostatic.s \
      -o bzip2_nostatic \
      -lm -lrt -lpcre > linker.lds
	readelf -s --wide bzip2_nostatic > readelf-nostatic.out
	readelf --sections bzip2_nostatic > readelf-sections-nostatic.out
	cp linker.lds linker_nostatic.lds

wpd_nostatic: $(LIBBITCODES) $(BZIP)
	# llvm-link $(LIBBITCODES) $(BZIP) -o bzip2_linked_nostatic.bc
	# opt \
	#   --function-sections \
  #     -O3 \
  #     -loop-simplify \
  #     < bzip2_linked_nostatic.bc \
  #     > bzip2_baseline_ls_opt_nostatic.bc
	opt \
	  --function-sections \
      -load libWholeProgramDebloat.so \
      -WholeProgramDebloat \
      < bzip2_baseline_ls_opt_nostatic.bc \
      > bzip2_wpd_opt_nostatic.bc
	llc  \
	  --function-sections \
      bzip2_wpd_opt_nostatic.bc \
      -relocation-model=pic \
      -o bzip2_wpd_opt_nostatic.s
	g++ \
	  -no-pie \
	  -ffunction-sections \
	  -Wl,--verbose \
      bzip2_wpd_opt_nostatic.s \
      -o bzip2_wpd_nostatic \
      -ldebloat_rt -lm -lrt -lpcre > linker.lds
	readelf -s --wide bzip2_wpd_nostatic > readelf-wpd-nostatic.out
	readelf --sections bzip2_wpd_nostatic > readelf-sections-wpd-nostatic.out
	cp wpd_disjoint_sets.txt wpd_disjoint_sets_nostatic.txt
	cp wpd_encompassed_funcs.txt wpd_encompassed_funcs_nostatic.txt
	cp wpd_static_reachability.txt wpd_static_reachability_nostatic.txt
	cp wpd_loop_static_reachability.txt wpd_loop_static_reachability_nostatic.txt
	cp wpd_loop_to_func.txt wpd_loop_to_func_nostatic.txt
	cp wpd_static_reachability.txt wpd_static_reachability_nostatic.txt
	cp wpd_loop_static_reachability.txt wpd_loop_static_reachability_nostatic.txt
	cp wpd_stats.txt wpd_stats_nostatic.txt
	cp wpd_func_name_to_id.txt wpd_func_name_to_id_nostatic.txt
	cp wpd_func_name_has_addr_taken.txt wpd_func_name_has_addr_taken_nostatic.txt
	python3 linker.py .

wpd_custlink_nostatic: bzip2_wpd_opt_nostatic.s
	g++ \
	  -no-pie \
      -ffunction-sections \
      -c bzip2_wpd_opt_nostatic.s \
      -o bzip2_wpd_custlink_opt_nostatic.o
	g++ \
	  -no-pie \
	  -ffunction-sections \
      -T wpd-linker-script.lds \
      bzip2_wpd_custlink_opt_nostatic.o \
      -o bzip2_wpd_custlink_nostatic \
      -ldebloat_rt -lm -lrt -lpcre
	readelf -s --wide bzip2_wpd_custlink_nostatic > readelf-wpd-custlink-nostatic.out
	readelf --sections bzip2_wpd_custlink_nostatic > readelf-sections-wpd-custlink-nostatic.out

%.o: %.c 
	$(CC) $(HEADERS) $(CFLAGS) $< -o $@

%.bc: %.c
	$(CC) $(HEADERS) $(CFLAGSL) $< -o $@


libbz2.a: $(LIB)
	rm -f libbz2.a
	$(AR) cq libbz2.a $(LIB)

clean: 
	rm -f lib/*.o lib/glthread/*.bc lib/glthread/*.o lib/*.bc src/*.bc src/*.o