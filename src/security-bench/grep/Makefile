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

LIBBITCODES=lib/argmatch.bc \
lib/binary-io.bc \
lib/bitrotate.bc \
lib/c-ctype.bc \
lib/c-strcasecmp.bc \
lib/c-strncasecmp.bc \
lib/cloexec.bc \
lib/close-stream.bc \
lib/closeout.bc \
lib/cycle-check.bc \
lib/opendir-safer.bc \
lib/dirname-lgpl.bc \
lib/basename-lgpl.bc \
lib/stripslash.bc \
lib/exclude.bc \
lib/exitfail.bc \
lib/creat-safer.bc \
lib/open-safer.bc \
lib/fd-hook.bc \
lib/filenamecat-lgpl.bc \
lib/hash.bc \
lib/i-ring.bc \
lib/localcharset.bc \
lib/glthread/lock.bc \
lib/malloca.bc \
lib/mbchar.bc \
lib/mbiter.bc \
lib/mbscasecmp.bc \
lib/mbslen.bc \
lib/mbsstr.bc \
lib/mbuiter.bc \
lib/memchr2.bc \
lib/openat-die.bc \
lib/openat-safer.bc \
lib/progname.bc \
lib/propername.bc \
lib/quotearg.bc \
lib/safe-read.bc \
lib/save-cwd.bc \
lib/striconv.bc \
lib/strnlen1.bc \
lib/glthread/threadlib.bc \
lib/trim.bc \
lib/unistd.bc \
lib/dup-safer.bc \
lib/fd-safer.bc \
lib/pipe-safer.bc \
lib/unistr/u8-mbtoucr.bc \
lib/unistr/u8-uctomb.bc \
lib/unistr/u8-uctomb-aux.bc \
lib/uniwidth/width.bc \
lib/version-etc.bc \
lib/version-etc-fsf.bc \
lib/wctype-h.bc \
lib/xmalloc.bc \
lib/xalloc-die.bc \
lib/xstriconv.bc \
lib/xstrtoimax.bc \
lib/xstrtol.bc \
lib/xstrtoul.bc \
lib/xstrtol-error.bc \
lib/colorize.bc \
lib/chdir-long.bc \
lib/fcntl.bc \
lib/fts.bc \
lib/openat-proc.bc 

BITCODES= src/grep.bc \
src/searchutils.bc \
src/dfa.bc \
src/dfasearch.bc \
src/kwset.bc \
src/kwsearch.bc \
src/pcresearch.bc


.SUFFIXES:
.SUFFIXES: .c .o .bc

all: base_ls wpd wpd_custlink

base_ls: $(LIBBITCODES) $(BITCODES)
	llvm-link $(LIBBITCODES) $(BITCODES) -o grep_linked.bc
	opt \
	  --function-sections \
      -O3 \
      -loop-simplify \
      < grep_linked.bc \
      > grep_baseline_ls_opt.bc
	llc  \
	  --function-sections \
      grep_baseline_ls_opt.bc \
      -relocation-model=pic \
      -o grep_opt.s
	g++ \
	  -no-pie \
	  -ffunction-sections \
	  -Wl,--verbose \
      grep_opt.s \
      -o grep \
      -lm -lrt -lpcre

wpd: $(LIBBITCODES) $(BITCODES)
	# llvm-link $(LIBBITCODES) $(BITCODES) -o grep_linked.bc
	# opt \
	#   --function-sections \
  #     -O3 \
  #     -loop-simplify \
  #     < grep_linked.bc \
  #     > grep_baseline_ls_opt.bc
	opt \
	  --function-sections \
      -load libWholeProgramDebloat.so \
      -WholeProgramDebloat \
      < grep_baseline_ls_opt.bc \
      > grep_wpd_opt.bc
	llc  \
	  --function-sections \
      grep_wpd_opt.bc \
      -relocation-model=pic \
      -o grep_wpd_opt.s
	g++ \
	  -no-pie \
	  -ffunction-sections \
	  -Wl,--verbose \
      grep_wpd_opt.s \
      -o grep_wpd \
      -ldebloat_rt -lm -lrt -lpcre > linker.lds
	readelf -s --wide grep_wpd > readelf-wpd.out
	readelf --sections grep_wpd > readelf-sections-wpd.out
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

wpd_custlink: grep_wpd_opt.s
	g++ \
	  -no-pie \
      -ffunction-sections \
      -c grep_wpd_opt.s \
      -o grep_wpd_custlink_opt.o
	g++ \
	  -no-pie \
	  -ffunction-sections \
      -T wpd-linker-script.lds \
      grep_wpd_custlink_opt.o \
      -o grep_wpd_custlink \
      -ldebloat_rt -lm -lrt -lpcre
	readelf -s --wide grep_wpd_custlink > readelf-wpd-custlink.out
	readelf --sections grep_wpd_custlink > readelf-sections-wpd-custlink.out

wpd_ics: $(LIBBITCODES) $(BITCODES)
	llvm-link $(LIBBITCODES) $(BITCODES) ics.ll -o grep_linked.bc
	opt \
	  --function-sections \
	    -O3 \
	    -loop-simplify \
	    < grep_linked.bc \
	    > grep_baseline_ls_opt.bc
	opt \
	  --function-sections \
      -load libWholeProgramDebloat.so \
      -WholeProgramDebloat \
      --enable-indirect-call-sinking=true \
      < grep_baseline_ls_opt.bc \
      > grep_wpd_ics_opt.bc
	# disassemble so we can do a hacky fix to the ics symbols
	llvm-dis grep_wpd_ics_opt.bc
	sed -i \
      's/declare extern_weak i32 @ics_map_indirect_call.2(i64)//w sed_changes_0.txt' \
      grep_wpd_ics_opt.ll
	sed -i \
      's/declare extern_weak i32 @ics_wrapper_debrt_protect_loop_end.3(i32)//w sed_changes_1.txt' \
      grep_wpd_ics_opt.ll
	sed -i \
      's/ics_map_indirect_call.2/ics_map_indirect_call/w sed_changes_2.txt' \
      grep_wpd_ics_opt.ll
	sed -i \
      's/ics_wrapper_debrt_protect_loop_end.3/ics_wrapper_debrt_protect_loop_end/w sed_changes_3.txt' \
      grep_wpd_ics_opt.ll
	sed -i \
      's/debrt_protect_indirect.1/debrt_protect_indirect/w sed_changes_5.txt' \
      grep_wpd_ics_opt.ll
	sed -i \
      's/declare i32 @debrt_protect_indirect(i64)$$//w sed_changes_4.txt' \
      grep_wpd_ics_opt.ll
	# now ingest the modified .ll file and run always-inline on it.
	opt \
	 --function-sections \
     -always-inline \
     < grep_wpd_ics_opt.ll \
     > grep_wpd_ics_opt.bc
	llc  \
	  --function-sections \
      grep_wpd_ics_opt.bc \
      -relocation-model=pic \
      -o grep_wpd_ics_opt.s
	g++ \
	  -ffunction-sections \
	  -Wl,--verbose \
      grep_wpd_ics_opt.s \
      -o grep_wpd_ics \
      -ldebloat_rt -lm -lrt -lpcre > linker.lds
	readelf -s --wide grep_wpd_ics > readelf.out
	readelf --sections grep_wpd_ics > readelf-sections.out
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

wpd_custlink_ics: grep_wpd_ics_opt.s
	g++ \
      -ffunction-sections \
      -c grep_wpd_ics_opt.s \
      -o grep_wpd_custlink_ics_opt.o
	g++ \
	  -ffunction-sections \
      -T wpd-linker-script.lds \
      grep_wpd_custlink_ics_opt.o \
      -o grep_wpd_custlink_ics \
      -ldebloat_rt -lm -lrt -lpcre
	readelf -s --wide grep_wpd_custlink_ics > readelf.out
	readelf --sections grep_wpd_custlink_ics > readelf-sections.out
	cp readelf.out readelf-custlink-ics.out
	cp readelf-sections.out readelf-sections-custlink-ics.out

artd_opt: $(LIBBITCODES) $(BITCODES)
	llvm-link $(LIBBITCODES) $(BITCODES) ics.ll -o grep_ics_linked.bc
	opt \
      --function-sections \
      -O3 \
      -loop-simplify \
      < grep_ics_linked.bc \
      > grep_ics_opt.bc
artd_pass_profile:
	opt \
      --function-sections \
      -load libAdvancedRuntimeDebloat.so \
      -AdvancedRuntimeDebloat \
      --artd-build=profile \
      < grep_ics_opt.bc \
      > grep_artd.bc
artd_pass_test_predict:
	opt \
      --function-sections \
      -load libAdvancedRuntimeDebloat.so \
      -AdvancedRuntimeDebloat \
      --artd-build=test_predict \
      < grep_ics_opt.bc \
      > grep_artd.bc
artd_pass_release:
	opt \
      --function-sections \
      -load libAdvancedRuntimeDebloat.so \
      -AdvancedRuntimeDebloat \
      --artd-build=release \
      < grep_ics_opt.bc \
      > grep_artd.bc
artd_ics_inline:
	# disassemble before inlining
	llvm-dis grep_artd.bc -o grep_artd-preinline.ll
	# inline
	opt \
      --function-sections \
      -always-inline \
      < grep_artd-preinline.ll \
      > grep_artd.bc
	# disassemble after inlining
	llvm-dis grep_artd.bc -o grep_artd-postinline.ll
artd_assemble:
	llc  \
      --function-sections \
      grep_artd.bc \
      -relocation-model=pic \
      -o grep_artd.s
	# Produce a default linker script.
	# FIXME Is there an easier way to do this than building the entire binary here?
	g++ \
      -ffunction-sections \
      -Wl,--verbose \
      grep_artd.s \
      -o grep_artd_tmp \
      -ldebloat_rt -lm -lrt -lpcre > linker.lds
	rm grep_artd_tmp
	# Create a custom linker script
	python3 linker.py .
	g++ \
      -ffunction-sections \
      -c grep_artd.s \
      -o grep_artd.o
artd_bin_profile:
	g++ \
      -ffunction-sections \
      -T artd-linker-script.lds \
      grep_artd.o \
      -o grep_artd_profile \
      -ldebloat_rt -lm -lrt -lpcre
artd_bin_test_predict:
	g++ \
      -ffunction-sections \
      -T artd-linker-script.lds \
      grep_artd.o \
      -o grep_artd_test_predict \
      -ldebloat_rt -lm -lrt -lpcre
artd_bin_release:
	g++ \
      -ffunction-sections \
      -T artd-linker-script.lds \
      grep_artd.o \
      -o grep_artd_release \
      -ldebloat_rt -lm -lrt -lpcre
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
      < grep_ics_opt.bc \
      > grep_datalog.bc

%.o: %.c 
	$(CC) $(HEADERS) $(CFLAGS) -c $< -o $@

lib/%.bc: lib/%.c
	$(CC) -DHAVE_CONFIG_H -I. -Ilib -Ilib/glthread -Ilib/unistr -Ilib/uniwidth -g -fPIC -O3 -ffunction-sections -emit-llvm -S $< -o $@

src/%.bc: src/%.c
	$(CC) -DHAVE_CONFIG_H -I. -Isrc -Ilib -Ilib/glthread -fPIC -O3 -ffunction-sections -emit-llvm -S $< -o $@

lib/libcoreutils.a: $(LIB)
	rm -f lib/libcoreutils.a
	$(AR) cq lib/libcoreutils.a $(LIB)

clean: 
	rm -f lib/*.o lib/glthread/*.bc lib/glthread/*.o lib/*.bc src/*.bc src/*.o
