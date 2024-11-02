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

all: base_ls wpd wpd_custlink wpd_ics wpd_custlink_ics
base_ls: $(LIBBITCODES) $(BZIP)
	llvm-link $(LIBBITCODES) $(BZIP) -o bzip2_linked.bc
	opt \
	  --function-sections \
      -O3 \
      -loop-simplify \
      < bzip2_linked.bc \
      > bzip2_baseline_ls_opt.bc
	llc  \
	  --function-sections \
      bzip2_baseline_ls_opt.bc \
      -relocation-model=pic \
      -o bzip2_opt.s
	g++ \
	  -no-pie \
	  -ffunction-sections \
	  -Wl,--verbose \
      bzip2_opt.s \
      -o bzip2 \
      -lm -lrt -lpcre

wpd: $(LIBBITCODES) $(BZIP)
	llvm-link $(LIBBITCODES) $(BZIP) -o bzip2_linked.bc
	opt \
	  --function-sections \
      -O3 \
      -loop-simplify \
      < bzip2_linked.bc \
      > bzip2_baseline_ls_opt.bc
	opt \
	  --function-sections \
      -load libWholeProgramDebloat.so \
      -WholeProgramDebloat \
      < bzip2_baseline_ls_opt.bc \
      > bzip2_wpd_opt.bc
	llc  \
	  --function-sections \
      bzip2_wpd_opt.bc \
      -relocation-model=pic \
      -o bzip2_wpd_opt.s
	g++ \
	  -no-pie \
	  -ffunction-sections \
	  -Wl,--verbose \
      bzip2_wpd_opt.s \
      -o bzip2_wpd \
      -ldebloat_rt -lm -lrt -lpcre > linker.lds
	readelf -s --wide bzip2_wpd > readelf-wpd.out
	readelf --sections bzip2_wpd > readelf-sections-wpd.out
	cp wpd_disjoint_sets.txt wpd_disjoint_sets.txt
	cp wpd_encompassed_funcs.txt wpd_encompassed_funcs.txt
	cp wpd_static_reachability.txt wpd_static_reachability.txt
	cp wpd_loop_static_reachability.txt wpd_loop_static_reachability.txt
	cp wpd_loop_to_func.txt wpd_loop_to_func.txt
	cp wpd_static_reachability.txt wpd_static_reachability.txt
	cp wpd_loop_static_reachability.txt wpd_loop_static_reachability.txt
	cp wpd_stats.txt wpd_stats.txt
	cp wpd_func_name_to_id.txt wpd_func_name_to_id.txt
	cp wpd_func_name_has_addr_taken.txt wpd_func_name_has_addr_taken.txt
	python3 linker-wpd.py .

wpd_custlink: bzip2_wpd_opt.s
	g++ \
	  -no-pie \
      -ffunction-sections \
      -c bzip2_wpd_opt.s \
      -o bzip2_wpd_custlink_opt.o
	g++ \
	  -no-pie \
	  -ffunction-sections \
      -T wpd-linker-script.lds \
      bzip2_wpd_custlink_opt.o \
      -o bzip2_wpd_custlink \
      -ldebloat_rt -lm -lrt -lpcre
	readelf -s --wide bzip2_wpd_custlink > readelf-wpd-custlink.out
	readelf --sections bzip2_wpd_custlink > readelf-sections-wpd-custlink.out

wpd_ics: $(LIBBITCODES) $(BZIP)
	llvm-link $(LIBBITCODES) $(BZIP) ics.ll -o bzip2_linked_ics.bc
	opt \
	  --function-sections \
	    -O3 \
	    -loop-simplify \
	    < bzip2_linked_ics.bc \
	    > bzip2_baseline_ics_opt.bc
	opt \
	  --function-sections \
      -load libWholeProgramDebloat.so \
      -WholeProgramDebloat \
      --enable-indirect-call-sinking=true \
      < bzip2_baseline_ics_opt.bc \
      > bzip2_wpd_ics_opt.bc
	# disassemble so we can do a hacky fix to the ics symbols
	llvm-dis bzip2_wpd_ics_opt.bc
	sed -i \
      's/declare extern_weak i32 @ics_map_indirect_call.2(i64)//w sed_changes_0.txt' \
      bzip2_wpd_ics_opt.ll
	sed -i \
      's/declare extern_weak i32 @ics_wrapper_debrt_protect_loop_end.3(i32)//w sed_changes_1.txt' \
      bzip2_wpd_ics_opt.ll
	sed -i \
      's/ics_map_indirect_call.2/ics_map_indirect_call/w sed_changes_2.txt' \
      bzip2_wpd_ics_opt.ll
	sed -i \
      's/ics_wrapper_debrt_protect_loop_end.3/ics_wrapper_debrt_protect_loop_end/w sed_changes_3.txt' \
      bzip2_wpd_ics_opt.ll
	sed -i \
      's/debrt_protect_indirect.1/debrt_protect_indirect/w sed_changes_5.txt' \
      bzip2_wpd_ics_opt.ll
	sed -i \
      's/declare i32 @debrt_protect_indirect(i64)$$//w sed_changes_4.txt' \
      bzip2_wpd_ics_opt.ll
	# now ingest the modified .ll file and run always-inline on it.
	opt \
	 --function-sections \
     -always-inline \
     < bzip2_wpd_ics_opt.ll \
     > bzip2_wpd_ics_opt.bc
	llc  \
	  --function-sections \
      bzip2_wpd_ics_opt.bc \
      -relocation-model=pic \
      -o bzip2_wpd_ics_opt.s
	g++ \
	  -ffunction-sections \
	  -Wl,--verbose \
      bzip2_wpd_ics_opt.s \
      -o bzip2_wpd_ics \
      -ldebloat_rt -lm -lrt > linker.lds
	readelf -s --wide bzip2_wpd_ics > readelf.out
	readelf --sections bzip2_wpd_ics > readelf-sections.out
	cp readelf.out readelf-ics.out
	cp readelf-sections.out readelf-sections-ics.out
	cp wpd_disjoint_sets.txt wpd_disjoint_sets_ics.txt
	cp wpd_encompassed_funcs.txt wpd_encompassed_funcs_ics.txt
	cp wpd_static_reachability.txt wpd_static_reachability_ics.txt
	cp wpd_loop_static_reachability.txt wpd_loop_static_reachability_ics.txt
	cp wpd_loop_to_func.txt wpd_loop_to_func_ics.txt
	cp wpd_static_reachability.txt wpd_static_reachability_ics.txt
	cp wpd_loop_static_reachability.txt wpd_loop_static_reachability_ics.txt
	cp wpd_stats.txt wpd_stats_ics.txt
	python3 linker-wpd.py .

wpd_custlink_ics: bzip2_wpd_ics_opt.s
	g++ \
      -ffunction-sections \
      -c bzip2_wpd_ics_opt.s \
      -o bzip2_wpd_custlink_ics_opt.o
	g++ \
	  -ffunction-sections \
      -T wpd-linker-script.lds \
      bzip2_wpd_custlink_ics_opt.o \
      -o bzip2_wpd_custlink_ics \
      -ldebloat_rt -lm -lrt
	readelf -s --wide bzip2_wpd_custlink_ics > readelf.out
	readelf --sections bzip2_wpd_custlink_ics > readelf-sections.out
	cp readelf.out readelf-custlink-ics.out
	cp readelf-sections.out readelf-sections-custlink-ics.out

artd_opt: $(LIBBITCODES) $(BZIP)
	llvm-link $(LIBBITCODES) $(BZIP) ics.ll -o bzip2_ics_linked.bc
	opt \
      --function-sections \
      -O3 \
      -loop-simplify \
      < bzip2_ics_linked.bc \
      > bzip2_ics_opt.bc
artd_pass_profile:
	opt \
      --function-sections \
      -load libAdvancedRuntimeDebloat.so \
      -AdvancedRuntimeDebloat \
      --artd-build=profile \
      < bzip2_ics_opt.bc \
      > bzip2_artd.bc
artd_pass_test_predict:
	opt \
      --function-sections \
      -load libAdvancedRuntimeDebloat.so \
      -AdvancedRuntimeDebloat \
      --artd-build=test_predict \
      < bzip2_ics_opt.bc \
      > bzip2_artd.bc
artd_pass_release:
	opt \
      --function-sections \
      -load libAdvancedRuntimeDebloat.so \
      -AdvancedRuntimeDebloat \
      --artd-build=release \
      < bzip2_ics_opt.bc \
      > bzip2_artd.bc
artd_ics_inline:
	# disassemble before inlining
	llvm-dis bzip2_artd.bc -o bzip2_artd-preinline.ll
	# inline
	opt \
      --function-sections \
      -always-inline \
      < bzip2_artd-preinline.ll \
      > bzip2_artd.bc
	# disassemble after inlining
	llvm-dis bzip2_artd.bc -o bzip2_artd-postinline.ll
artd_assemble:
	llc  \
      --function-sections \
      bzip2_artd.bc \
      -relocation-model=pic \
      -o bzip2_artd.s
	# Produce a default linker script.
	# FIXME Is there an easier way to do this than building the entire binary here?
	g++ \
      -ffunction-sections \
      -Wl,--verbose \
      bzip2_artd.s \
      -o bzip2_artd_tmp \
      -ldebloat_rt -lm -lrt > linker.lds
	rm bzip2_artd_tmp
	# Create a custom linker script
	python3 linker.py .
	g++ \
      -ffunction-sections \
      -c bzip2_artd.s \
      -o bzip2_artd.o
artd_bin_profile:
	g++ \
      -ffunction-sections \
      -T artd-linker-script.lds \
      bzip2_artd.o \
      -o bzip2_artd_profile \
      -ldebloat_rt -lm -lrt
artd_bin_test_predict:
	g++ \
      -ffunction-sections \
      -T artd-linker-script.lds \
      bzip2_artd.o \
      -o bzip2_artd_test_predict \
      -ldebloat_rt -lm -lrt
artd_bin_release:
	g++ \
      -ffunction-sections \
      -T artd-linker-script.lds \
      bzip2_artd.o \
      -o bzip2_artd_release \
      -ldebloat_rt -lm -lrt
# Note: these aren't complete, but it's fine for now.
artd_profile: artd_pass_profile artd_ics_inline artd_assemble artd_bin_profile
artd_test_predict: artd_pass_test_predict artd_ics_inline artd_assemble artd_bin_test_predict
artd_release: artd_pass_release artd_ics_inline artd_assemble artd_bin_release
artd_pass_datalog:
	opt \
      --function-sections \
      -load libAdvancedRuntimeDebloat.so \
      -AdvancedRuntimeDebloat \
      --artd-build=datalog \
      < bzip2_ics_opt.bc \
      > bzip2_datalog.bc

%.o: %.c 
	$(CC) $(HEADERS) $(CFLAGS) $< -o $@

%.bc: %.c
	$(CC) $(HEADERS) $(CFLAGSL) $< -o $@


libbz2.a: $(LIB)
	rm -f libbz2.a
	$(AR) cq libbz2.a $(LIB)

clean: 
	rm -f lib/*.o lib/glthread/*.bc lib/glthread/*.o lib/*.bc src/*.bc src/*.o
