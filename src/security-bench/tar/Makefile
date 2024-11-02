VERSION = 2.19
VERSADD = 
VPATH=. $(RESDIR)

# To assist in cross-compiling
CC=clang
AR=ar
RANLIB=ranlib
LDFLAGS= -Wl,-s $(VERSADD)
  
CFLAGS = -fPIC -O3 -ffunction-sections -g -c
CFLAGSL = -O3 -ffunction-sections -emit-llvm -S
HEADERS = -I. -Ilib -Ilib/glthread -Isrc
LIBS = 


LIB= #Fill with object files of LIBBITCODES libcoreutils.a

LIBBITCODES=lib/prepargs.bc \
lib/argmatch.bc \
lib/backupfile.bc \
lib/addext.bc \
lib/dirname.bc \
lib/basename.bc \
lib/stripslash.bc \
lib/exclude.bc \
lib/exitfail.bc \
lib/full-write.bc \
lib/getdate.bc \
lib/getopt.bc \
lib/getopt1.bc \
lib/gettime.bc \
lib/hash.bc \
lib/human.bc \
lib/modechange.bc \
lib/quote.bc \
lib/quotearg.bc \
lib/safe-read.bc \
lib/safe-write.bc \
lib/save-cwd.bc \
lib/savedir.bc \
lib/xmalloc.bc \
lib/xstrdup.bc \
lib/xgetcwd.bc \
lib/xstrtol.bc \
lib/xstrtoul.bc \
lib/xstrtoumax.bc \
lib/mktime.bc 

BITCODES= src/buffer.bc \
src/compare.bc \
src/create.bc \
src/delete.bc \
src/extract.bc \
src/xheader.bc \
src/incremen.bc \
src/list.bc \
src/mangle.bc \
src/misc.bc \
src/names.bc \
src/rtapelib.bc \
src/sparse.bc \
src/system.bc \
src/tar.bc \
src/update.bc \
src/utf8.bc

.SUFFIXES:
.SUFFIXES: .c .o .bc

all: base_ls wpd wpd_custlink

base_ls: $(LIBBITCODES) $(BITCODES)
	python3 tar_symbol_duplicate.py
	llvm-link $(LIBBITCODES) $(BITCODES) -o tar_linked.bc
	opt \
	  --function-sections \
      -O3 \
      -loop-simplify \
      < tar_linked.bc \
      > tar_baseline_ls_opt.bc
	llc  \
	  --function-sections \
      tar_baseline_ls_opt.bc \
      -relocation-model=pic \
      -o tar_opt.s
	g++ \
	  -no-pie \
	  -ffunction-sections \
	  -Wl,--verbose \
      tar_opt.s \
      -o tar \
      -lm -lrt -lpcre

wpd: $(LIBBITCODES) $(BITCODES)
	python3 tar_symbol_duplicate.py
	# llvm-link $(LIBBITCODES) $(BITCODES) -o tar_linked.bc
	# opt \
	#   --function-sections \
  #     -O3 \
  #     -loop-simplify \
  #     < tar_linked.bc \
  #     > tar_baseline_ls_opt.bc
	opt \
	  --function-sections \
      -load libWholeProgramDebloat.so \
      -WholeProgramDebloat \
      < tar_baseline_ls_opt.bc \
      > tar_wpd_opt.bc
	llc  \
	  --function-sections \
      tar_wpd_opt.bc \
      -relocation-model=pic \
      -o tar_wpd_opt.s
	g++ \
	  -no-pie \
	  -ffunction-sections \
	  -Wl,--verbose \
      tar_wpd_opt.s \
      -o tar_wpd \
      -ldebloat_rt -lm -lrt -lpcre > linker.lds
	readelf -s --wide tar_wpd > readelf-wpd.out
	readelf --sections tar_wpd > readelf-sections-wpd.out
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
	python3 linker.py .

wpd_custlink: tar_wpd_opt.s
	g++ \
	  -no-pie \
      -ffunction-sections \
      -c tar_wpd_opt.s \
      -o tar_wpd_custlink_opt.o
	g++ \
	  -no-pie \
	  -ffunction-sections \
      -T wpd-linker-script.lds \
      tar_wpd_custlink_opt.o \
      -o tar_wpd_custlink \
      -ldebloat_rt -lm -lrt -lpcre
	readelf -s --wide tar_wpd_custlink > readelf-wpd-custlink.out
	readelf --sections tar_wpd_custlink > readelf-sections-wpd-custlink.out

wpd_ics: $(LIBBITCODES) $(BITCODES)
	python3 tar_symbol_duplicate.py
	llvm-link $(LIBBITCODES) $(BITCODES) ics.ll -o tar_linked.bc
	opt \
	  --function-sections \
	    -O3 \
	    -loop-simplify \
	    < tar_linked.bc \
	    > tar_baseline_ls_opt.bc
	opt \
	  --function-sections \
      -load libWholeProgramDebloat.so \
      -WholeProgramDebloat \
      --enable-indirect-call-sinking=true \
      < tar_baseline_ls_opt.bc \
      > tar_wpd_ics_opt.bc
	# disassemble so we can do a hacky fix to the ics symbols
	llvm-dis tar_wpd_ics_opt.bc
	sed -i \
      's/declare extern_weak i32 @ics_map_indirect_call.2(i64)//w sed_changes_0.txt' \
      tar_wpd_ics_opt.ll
	sed -i \
      's/declare extern_weak i32 @ics_wrapper_debrt_protect_loop_end.3(i32)//w sed_changes_1.txt' \
      tar_wpd_ics_opt.ll
	sed -i \
      's/ics_map_indirect_call.2/ics_map_indirect_call/w sed_changes_2.txt' \
      tar_wpd_ics_opt.ll
	sed -i \
      's/ics_wrapper_debrt_protect_loop_end.3/ics_wrapper_debrt_protect_loop_end/w sed_changes_3.txt' \
      tar_wpd_ics_opt.ll
	sed -i \
      's/debrt_protect_indirect.1/debrt_protect_indirect/w sed_changes_5.txt' \
      tar_wpd_ics_opt.ll
	sed -i \
      's/declare i32 @debrt_protect_indirect(i64)$$//w sed_changes_4.txt' \
      tar_wpd_ics_opt.ll
	# now ingest the modified .ll file and run always-inline on it.
	opt \
	 --function-sections \
     -always-inline \
     < tar_wpd_ics_opt.ll \
     > tar_wpd_ics_opt.bc
	llc  \
	  --function-sections \
      tar_wpd_ics_opt.bc \
      -relocation-model=pic \
      -o tar_wpd_ics_opt.s
	g++ \
	  -ffunction-sections \
	  -Wl,--verbose \
      tar_wpd_ics_opt.s \
      -o tar_wpd_ics \
      -ldebloat_rt -lm -lrt > linker.lds
	readelf -s --wide tar_wpd_ics > readelf.out
	readelf --sections tar_wpd_ics > readelf-sections.out
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

wpd_custlink_ics: tar_wpd_ics_opt.s
	g++ \
      -ffunction-sections \
      -c tar_wpd_ics_opt.s \
      -o tar_wpd_custlink_ics_opt.o
	g++ \
	  -ffunction-sections \
      -T wpd-linker-script.lds \
      tar_wpd_custlink_ics_opt.o \
      -o tar_wpd_custlink_ics \
      -ldebloat_rt -lm -lrt
	readelf -s --wide tar_wpd_custlink_ics > readelf.out
	readelf --sections tar_wpd_custlink_ics > readelf-sections.out
	cp readelf.out readelf-custlink-ics.out
	cp readelf-sections.out readelf-sections-custlink-ics.out


artd_opt: $(LIBBITCODES) $(BITCODES)
	python3 tar_symbol_duplicate.py
	llvm-link $(LIBBITCODES) $(BITCODES) ics.ll -o tar_ics_linked.bc
	opt \
      --function-sections \
      -O3 \
      -loop-simplify \
      < tar_ics_linked.bc \
      > tar_ics_opt.bc
artd_pass_profile:
	opt \
      --function-sections \
      -load libAdvancedRuntimeDebloat.so \
      -AdvancedRuntimeDebloat \
      --artd-build=profile \
      < tar_ics_opt.bc \
      > tar_artd.bc
artd_pass_test_predict:
	opt \
      --function-sections \
      -load libAdvancedRuntimeDebloat.so \
      -AdvancedRuntimeDebloat \
      --artd-build=test_predict \
      < tar_ics_opt.bc \
      > tar_artd.bc
artd_pass_release:
	opt \
      --function-sections \
      -load libAdvancedRuntimeDebloat.so \
      -AdvancedRuntimeDebloat \
      --artd-build=release \
      < tar_ics_opt.bc \
      > tar_artd.bc
artd_ics_inline:
	# disassemble before inlining
	llvm-dis tar_artd.bc -o tar_artd-preinline.ll
	# inline
	opt \
      --function-sections \
      -always-inline \
      < tar_artd-preinline.ll \
      > tar_artd.bc
	# disassemble after inlining
	llvm-dis tar_artd.bc -o tar_artd-postinline.ll
artd_assemble:
	llc  \
      --function-sections \
      tar_artd.bc \
      -relocation-model=pic \
      -o tar_artd.s
	# Produce a default linker script.
	# FIXME Is there an easier way to do this than building the entire binary here?
	g++ \
      -ffunction-sections \
      -Wl,--verbose \
      tar_artd.s \
      -o tar_artd_tmp \
      -ldebloat_rt -lm -lrt > linker.lds
	rm tar_artd_tmp
	# Create a custom linker script
	python3 linker.py .
	g++ \
      -ffunction-sections \
      -c tar_artd.s \
      -o tar_artd.o
artd_bin_profile:
	g++ \
      -ffunction-sections \
      -T artd-linker-script.lds \
      tar_artd.o \
      -o tar_artd_profile \
      -ldebloat_rt -lm -lrt
artd_bin_test_predict:
	g++ \
      -ffunction-sections \
      -T artd-linker-script.lds \
      tar_artd.o \
      -o tar_artd_test_predict \
      -ldebloat_rt -lm -lrt
artd_bin_release:
	g++ \
      -ffunction-sections \
      -T artd-linker-script.lds \
      tar_artd.o \
      -o tar_artd_release \
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
      < tar_ics_opt.bc \
      > tar_datalog.bc

%.o: %.c 
	$(CC) $(HEADERS) $(CFLAGS) -c $< -o $@


lib/%.bc: lib/%.c
	$(CC) -DHAVE_CONFIG_H -I. -Ilib -Ilib/glthread -g -fPIC -O3 -ffunction-sections -emit-llvm -S $< -o $@

src/%.bc: src/%.c
	$(CC) -DHAVE_CONFIG_H -I. -Isrc -Ilib -Ilib/glthread -fPIC -O3 -ffunction-sections -emit-llvm -S $< -o $@

lib/libcoreutils.a: $(LIB)
	rm -f lib/libcoreutils.a
	$(AR) cq lib/libcoreutils.a $(LIB)

clean: 
	rm -f lib/*.o lib/glthread/*.bc lib/glthread/*.o lib/*.bc src/*.bc src/*.o
