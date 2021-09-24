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

all: base_ls_nostatic wpd_nostatic wpd_custlink_nostatic
#base_ls_static wpd_static wpd_custlink_static
# base_ls_static: lib/libcoreutils.a $(BITCODES)
# 	llvm-link $(BITCODES) -o grep_linked_static.bc
# 	opt \
# 	  --function-sections \
#       -O3 \
#       -loop-simplify \
#       < grep_linked_static.bc \
#       > grep_baseline_ls_opt_static.bc
# 	llc  \
# 	  --function-sections \
#       grep_baseline_ls_opt_static.bc \
#       -relocation-model=pic \
#       -o grep_opt_static.s
# 	g++ \
# 	  -no-pie \
# 	  -ffunction-sections \
# 	  -Wl,--verbose \
#       grep_opt_static.s \
#       -o grep_static \
#       -lm -lrt -Llib -lgreputils > linker.lds
# 	readelf -s --wide grep_static > readelf-static.out
# 	readelf --sections grep_static > readelf-sections-static.out
# 	cp linker.lds linker_static.lds

# wpd_static: lib/libcoreutils.a $(BITCODES)
# 	llvm-link $(BITCODES) -o grep_linked_static.bc
# 	opt \
# 	  --function-sections \
#       -O3 \
#       -loop-simplify \
#       < grep_linked_static.bc \
#       > grep_baseline_ls_opt_static.bc
# 	opt \
# 	  --function-sections \
#       -load libWholeProgramDebloat.so \
#       -WholeProgramDebloat \
#       < grep_baseline_ls_opt_static.bc \
#       > grep_wpd_opt_static.bc
# 	llc  \
# 	  --function-sections \
#       grep_wpd_opt_static.bc \
#       -relocation-model=pic \
#       -o grep_wpd_opt_static.s
# 	g++ \
# 	  -no-pie \
# 	  -ffunction-sections \
# 	  -Wl,--verbose \
#       grep_wpd_opt_static.s \
#       -o grep_wpd_static \
#       -ldebloat_rt -lm -lrt -Llib -lgreputil > linker.lds
# 	readelf -s --wide grep_wpd_static > readelf-wpd-static.out
# 	readelf --sections grep_wpd_static > readelf-sections-wpd-static.out
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

# wpd_custlink_static: lib/libcoreutils.a grep_wpd_opt_static.s
# 	g++ \
# 	  -no-pie \
#       -ffunction-sections \
#       -c grep_wpd_opt_static.s \
#       -o grep_wpd_custlink_opt_static.o
# 	g++ \
# 	  -no-pie \
# 	  -ffunction-sections \
#       -T wpd-linker-script.lds \
#       grep_wpd_custlink_opt_static.o \
#       -o grep_wpd_custlink_static \
#       -ldebloat_rt -lm -lrt -Llib -lgreputil
# 	readelf -s --wide grep_wpd_custlink_static > readelf-wpd-custlink-static.out
# 	readelf --sections grep_wpd_custlink_static > readelf-sections-wpd-custlink-static.out

base_ls_nostatic: $(LIBBITCODES) $(BITCODES)
	llvm-link $(LIBBITCODES) $(BITCODES) -o grep_linked_nostatic.bc
	opt \
	  --function-sections \
      -O3 \
      -loop-simplify \
      < grep_linked_nostatic.bc \
      > grep_baseline_ls_opt_nostatic.bc
	llc  \
	  --function-sections \
      grep_baseline_ls_opt_nostatic.bc \
      -relocation-model=pic \
      -o grep_opt_nostatic.s
	g++ \
	  -no-pie \
	  -ffunction-sections \
	  -Wl,--verbose \
      grep_opt_nostatic.s \
      -o grep_nostatic \
      -lm -lrt -lpcre

wpd_nostatic: $(LIBBITCODES) $(BITCODES)
	# llvm-link $(LIBBITCODES) $(BITCODES) -o grep_linked_nostatic.bc
	# opt \
	#   --function-sections \
  #     -O3 \
  #     -loop-simplify \
  #     < grep_linked_nostatic.bc \
  #     > grep_baseline_ls_opt_nostatic.bc
	opt \
	  --function-sections \
      -load libWholeProgramDebloat.so \
      -WholeProgramDebloat \
      < grep_baseline_ls_opt_nostatic.bc \
      > grep_wpd_opt_nostatic.bc
	llc  \
	  --function-sections \
      grep_wpd_opt_nostatic.bc \
      -relocation-model=pic \
      -o grep_wpd_opt_nostatic.s
	g++ \
	  -no-pie \
	  -ffunction-sections \
	  -Wl,--verbose \
      grep_wpd_opt_nostatic.s \
      -o grep_wpd_nostatic \
      -ldebloat_rt -lm -lrt -lpcre > linker.lds
	readelf -s --wide grep_wpd_nostatic > readelf-wpd-nostatic.out
	readelf --sections grep_wpd_nostatic > readelf-sections-wpd-nostatic.out
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

wpd_custlink_nostatic: grep_wpd_opt_nostatic.s
	g++ \
	  -no-pie \
      -ffunction-sections \
      -c grep_wpd_opt_nostatic.s \
      -o grep_wpd_custlink_opt_nostatic.o
	g++ \
	  -no-pie \
	  -ffunction-sections \
      -T wpd-linker-script.lds \
      grep_wpd_custlink_opt_nostatic.o \
      -o grep_wpd_custlink_nostatic \
      -ldebloat_rt -lm -lrt -lpcre
	readelf -s --wide grep_wpd_custlink_nostatic > readelf-wpd-custlink-nostatic.out
	readelf --sections grep_wpd_custlink_nostatic > readelf-sections-wpd-custlink-nostatic.out

wpd_ics_nostatic: $(LIBBITCODES) $(BITCODES)
	llvm-link $(LIBBITCODES) $(BITCODES) ics.ll -o grep_linked_nostatic.bc
	opt \
	  --function-sections \
	    -O3 \
	    -loop-simplify \
	    < grep_linked_nostatic.bc \
	    > grep_baseline_ls_opt_nostatic.bc
	opt \
	  --function-sections \
      -load libWholeProgramDebloat.so \
      -WholeProgramDebloat \
      --enable-indirect-call-sinking=true \
      < grep_baseline_ls_opt_nostatic.bc \
      > grep_wpd_ics_opt_nostatic.bc
	# disassemble so we can do a hacky fix to the ics symbols
	llvm-dis grep_wpd_ics_opt_nostatic.bc
	sed -i \
      's/declare extern_weak i32 @ics_map_indirect_call.2(i64)//w sed_changes_0.txt' \
      grep_wpd_ics_opt_nostatic.ll
	sed -i \
      's/declare extern_weak i32 @ics_wrapper_debrt_protect_loop_end.3(i32)//w sed_changes_1.txt' \
      grep_wpd_ics_opt_nostatic.ll
	sed -i \
      's/ics_map_indirect_call.2/ics_map_indirect_call/w sed_changes_2.txt' \
      grep_wpd_ics_opt_nostatic.ll
	sed -i \
      's/ics_wrapper_debrt_protect_loop_end.3/ics_wrapper_debrt_protect_loop_end/w sed_changes_3.txt' \
      grep_wpd_ics_opt_nostatic.ll
	sed -i \
      's/debrt_protect_indirect.1/debrt_protect_indirect/w sed_changes_5.txt' \
      grep_wpd_ics_opt_nostatic.ll
	sed -i \
      's/declare i32 @debrt_protect_indirect(i64)$$//w sed_changes_4.txt' \
      grep_wpd_ics_opt_nostatic.ll
	# now ingest the modified .ll file and run always-inline on it.
	opt \
	 --function-sections \
     -always-inline \
     < grep_wpd_ics_opt_nostatic.ll \
     > grep_wpd_ics_opt_nostatic.bc
	llc  \
	  --function-sections \
      grep_wpd_ics_opt_nostatic.bc \
      -relocation-model=pic \
      -o grep_wpd_ics_opt_nostatic.s
	g++ \
	  -ffunction-sections \
	  -Wl,--verbose \
      grep_wpd_ics_opt_nostatic.s \
      -o grep_wpd_ics_nostatic \
      -ldebloat_rt -lm -lrt -lpcre > linker.lds
	readelf -s --wide grep_wpd_ics_nostatic > readelf.out
	readelf --sections grep_wpd_ics_nostatic > readelf-sections.out
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

wpd_custlink_ics_nostatic: grep_wpd_ics_opt_nostatic.s
	g++ \
      -ffunction-sections \
      -c grep_wpd_ics_opt_nostatic.s \
      -o grep_wpd_custlink_ics_opt_nostatic.o
	g++ \
	  -ffunction-sections \
      -T wpd-linker-script.lds \
      grep_wpd_custlink_ics_opt_nostatic.o \
      -o grep_wpd_custlink_ics_nostatic \
      -ldebloat_rt -lm -lrt -lpcre
	readelf -s --wide grep_wpd_custlink_ics_nostatic > readelf.out
	readelf --sections grep_wpd_custlink_ics_nostatic > readelf-sections.out
	cp readelf.out readelf-custlink-ics-nostatic.out
	cp readelf-sections.out readelf-sections-custlink-ics-nostatic.out

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
