VERSION = 2.19
VERSADD = 
VPATH=. $(RESDIR)

# To assist in cross-compiling
CC=clang
AR=ar
RANLIB=ranlib
LDFLAGS= -Wl,-s $(VERSADD)
  
CFLAGS = -D_FILE_OFFSET_BITS=64 -fPIC -O3 -ffunction-sections -g -c
CFLAGSL = -D_FILE_OFFSET_BITS=64 -fPIC -O3 -ffunction-sections -emit-llvm -S
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

all: base_ls_nostatic wpd_nostatic wpd_custlink_nostatic wpd_ics_nostatic wpd_custlink_ics_nostatic
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
      -lm -lrt -lpcre

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

wpd_ics_nostatic: $(LIBBITCODES) $(BZIP)
	llvm-link $(LIBBITCODES) $(BZIP) ics.ll -o bzip2_linked_nostatic.bc
	opt \
	  --function-sections \
	    -O3 \
	    -loop-simplify \
	    < bzip2_linked_nostatic.bc \
	    > bzip2_baseline_ls_opt_nostatic.bc
	opt \
	  --function-sections \
      -load libWholeProgramDebloat.so \
      -WholeProgramDebloat \
      --enable-indirect-call-sinking=true \
      < bzip2_baseline_ls_opt_nostatic.bc \
      > bzip2_wpd_ics_opt_nostatic.bc
	# disassemble so we can do a hacky fix to the ics symbols
	llvm-dis bzip2_wpd_ics_opt_nostatic.bc
	sed -i \
      's/declare extern_weak i32 @ics_map_indirect_call.2(i64)//w sed_changes_0.txt' \
      bzip2_wpd_ics_opt_nostatic.ll
	sed -i \
      's/declare extern_weak i32 @ics_wrapper_debrt_protect_loop_end.3(i32)//w sed_changes_1.txt' \
      bzip2_wpd_ics_opt_nostatic.ll
	sed -i \
      's/ics_map_indirect_call.2/ics_map_indirect_call/w sed_changes_2.txt' \
      bzip2_wpd_ics_opt_nostatic.ll
	sed -i \
      's/ics_wrapper_debrt_protect_loop_end.3/ics_wrapper_debrt_protect_loop_end/w sed_changes_3.txt' \
      bzip2_wpd_ics_opt_nostatic.ll
	sed -i \
      's/debrt_protect_indirect.1/debrt_protect_indirect/w sed_changes_5.txt' \
      bzip2_wpd_ics_opt_nostatic.ll
	sed -i \
      's/declare i32 @debrt_protect_indirect(i64)$$//w sed_changes_4.txt' \
      bzip2_wpd_ics_opt_nostatic.ll
	# now ingest the modified .ll file and run always-inline on it.
	opt \
	 --function-sections \
     -always-inline \
     < bzip2_wpd_ics_opt_nostatic.ll \
     > bzip2_wpd_ics_opt_nostatic.bc
	llc  \
	  --function-sections \
      bzip2_wpd_ics_opt_nostatic.bc \
      -relocation-model=pic \
      -o bzip2_wpd_ics_opt_nostatic.s
	g++ \
	  -ffunction-sections \
	  -Wl,--verbose \
      bzip2_wpd_ics_opt_nostatic.s \
      -o bzip2_wpd_ics_nostatic \
      -ldebloat_rt -lm -lrt > linker.lds
	readelf -s --wide bzip2_wpd_ics_nostatic > readelf.out
	readelf --sections bzip2_wpd_ics_nostatic > readelf-sections.out
	cp readelf.out readelf-ics-nostatic.out
	cp readelf-sections.out readelf-sections-ics-nostatic.out
	cp wpd_disjoint_sets.txt wpd_disjoint_sets_ics_nostatic.txt
	cp wpd_encompassed_funcs.txt wpd_encompassed_funcs_ics_nostatic.txt
	cp wpd_static_reachability.txt wpd_static_reachability_ics_nostatic.txt
	cp wpd_loop_static_reachability.txt wpd_loop_static_reachability_ics_nostatic.txt
	cp wpd_loop_to_func.txt wpd_loop_to_func_ics_nostatic.txt
	cp wpd_static_reachability.txt wpd_static_reachability_ics_nostatic.txt
	cp wpd_loop_static_reachability.txt wpd_loop_static_reachability_ics_nostatic.txt
	cp wpd_stats.txt wpd_stats_ics_nostatic.txt

wpd_custlink_ics_nostatic: bzip2_wpd_ics_opt_nostatic.s
	g++ \
      -ffunction-sections \
      -c bzip2_wpd_ics_opt_nostatic.s \
      -o bzip2_wpd_custlink_ics_opt_nostatic.o
	g++ \
	  -ffunction-sections \
      -T wpd-linker-script.lds \
      bzip2_wpd_custlink_ics_opt_nostatic.o \
      -o bzip2_wpd_custlink_ics_nostatic \
      -ldebloat_rt -lm -lrt
	readelf -s --wide bzip2_wpd_custlink_ics_nostatic > readelf.out
	readelf --sections bzip2_wpd_custlink_ics_nostatic > readelf-sections.out
	cp readelf.out readelf-custlink-ics-nostatic.out
	cp readelf-sections.out readelf-sections-custlink-ics-nostatic.out

%.o: %.c 
	$(CC) $(HEADERS) $(CFLAGS) $< -o $@

%.bc: %.c
	$(CC) $(HEADERS) $(CFLAGSL) $< -o $@


libbz2.a: $(LIB)
	rm -f libbz2.a
	$(AR) cq libbz2.a $(LIB)

clean: 
	rm -f lib/*.o lib/glthread/*.bc lib/glthread/*.o lib/*.bc src/*.bc src/*.o
