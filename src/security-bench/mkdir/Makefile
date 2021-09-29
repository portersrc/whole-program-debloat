VERSION = 5.2.1
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

LIBBITCODES=lib/acl.bc \
lib/getdate.bc \
lib/posixtm.bc \
lib/posixver.bc \
lib/strftime.bc \
lib/getopt.bc \
lib/getopt1.bc \
lib/hash.bc \
lib/hash-pjw.bc \
lib/addext.bc \
lib/argmatch.bc \
lib/backupfile.bc \
lib/basename.bc \
lib/c-strtod.bc \
lib/canon-host.bc \
lib/cloexec.bc \
lib/closeout.bc \
lib/cycle-check.bc \
lib/diacrit.bc \
lib/dirname.bc \
lib/dup-safer.bc \
lib/exclude.bc \
lib/exitfail.bc \
lib/filemode.bc \
lib/file-type.bc \
lib/fopen-safer.bc \
lib/fts.bc \
lib/full-read.bc \
lib/full-write.bc \
lib/gettime.bc \
lib/getugroups.bc \
lib/hard-locale.bc \
lib/human.bc \
lib/idcache.bc \
lib/isdir.bc \
lib/imaxtostr.bc \
lib/linebuffer.bc \
lib/localcharset.bc \
lib/long-options.bc \
lib/makepath.bc \
lib/mbswidth.bc \
lib/md5.bc \
lib/memcasecmp.bc \
lib/memcoll.bc \
lib/modechange.bc \
lib/offtostr.bc \
lib/path-concat.bc \
lib/physmem.bc \
lib/quote.bc \
lib/quotearg.bc \
lib/readtokens.bc \
lib/root-dev-ino.bc \
lib/safe-read.bc \
lib/safe-write.bc \
lib/same.bc \
lib/save-cwd.bc \
lib/savedir.bc \
lib/settime.bc \
lib/sha1.bc \
lib/stripslash.bc \
lib/time_r.bc \
lib/umaxtostr.bc \
lib/unicodeio.bc \
lib/userspec.bc \
lib/utimens.bc \
lib/version-etc.bc \
lib/xfts.bc \
lib/xgetcwd.bc \
lib/xgethostname.bc \
lib/xmalloc.bc \
lib/xmemcoll.bc \
lib/xnanosleep.bc \
lib/xreadlink.bc \
lib/xstrdup.bc \
lib/xstrndup.bc \
lib/xstrtod.bc \
lib/xstrtoimax.bc \
lib/xstrtol.bc \
lib/xstrtoul.bc \
lib/xstrtoumax.bc \
lib/yesno.bc \
lib/fsusage.bc \
lib/mktime.bc \
lib/sig2str.bc \
lib/vasnprintf.bc \
lib/printf-args.bc \
lib/printf-parse.bc \
lib/asnprintf.bc \
lib/getndelim2.bc \
lib/mountlist.bc \
lib/readutmp.bc \
lib/getcwd.bc \
lib/free.bc 

BITCODES= src/mkdir.bc

.SUFFIXES:
.SUFFIXES: .c .o .bc

all: base_ls_nostatic wpd_nostatic wpd_custlink_nostatic
#base_ls_static wpd_static wpd_custlink_static
# base_ls_static: lib/libcoreutils.a $(BITCODES)
# 	llvm-link $(BITCODES) -o mkdir_linked_static.bc
# 	opt \
# 	  --function-sections \
#       -O3 \
#       -loop-simplify \
#       < mkdir_linked_static.bc \
#       > mkdir_baseline_ls_opt_static.bc
# 	llc  \
# 	  --function-sections \
#       mkdir_baseline_ls_opt_static.bc \
#       -relocation-model=pic \
#       -o mkdir_opt_static.s
# 	g++ \
# 	  -no-pie \
# 	  -ffunction-sections \
# 	  -Wl,--verbose \
#       mkdir_opt_static.s \
#       -o mkdir_static \
#       -lm -lrt -Llib -lgreputils > linker.lds
# 	readelf -s --wide mkdir_static > readelf-static.out
# 	readelf --sections mkdir_static > readelf-sections-static.out
# 	cp linker.lds linker_static.lds

# wpd_static: lib/libcoreutils.a $(BITCODES)
# 	llvm-link $(BITCODES) -o mkdir_linked_static.bc
# 	opt \
# 	  --function-sections \
#       -O3 \
#       -loop-simplify \
#       < mkdir_linked_static.bc \
#       > mkdir_baseline_ls_opt_static.bc
# 	opt \
# 	  --function-sections \
#       -load libWholeProgramDebloat.so \
#       -WholeProgramDebloat \
#       < mkdir_baseline_ls_opt_static.bc \
#       > mkdir_wpd_opt_static.bc
# 	llc  \
# 	  --function-sections \
#       mkdir_wpd_opt_static.bc \
#       -relocation-model=pic \
#       -o mkdir_wpd_opt_static.s
# 	g++ \
# 	  -no-pie \
# 	  -ffunction-sections \
# 	  -Wl,--verbose \
#       mkdir_wpd_opt_static.s \
#       -o mkdir_wpd_static \
#       -ldebloat_rt -lm -lrt -Llib -lgreputil > linker.lds
# 	readelf -s --wide mkdir_wpd_static > readelf-wpd-static.out
# 	readelf --sections mkdir_wpd_static > readelf-sections-wpd-static.out
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

# wpd_custlink_static: lib/libcoreutils.a mkdir_wpd_opt_static.s
# 	g++ \
# 	  -no-pie \
#       -ffunction-sections \
#       -c mkdir_wpd_opt_static.s \
#       -o mkdir_wpd_custlink_opt_static.o
# 	g++ \
# 	  -no-pie \
# 	  -ffunction-sections \
#       -T wpd-linker-script.lds \
#       mkdir_wpd_custlink_opt_static.o \
#       -o mkdir_wpd_custlink_static \
#       -ldebloat_rt -lm -lrt -Llib -lgreputil
# 	readelf -s --wide mkdir_wpd_custlink_static > readelf-wpd-custlink-static.out
# 	readelf --sections mkdir_wpd_custlink_static > readelf-sections-wpd-custlink-static.out

base_ls_nostatic: $(LIBBITCODES) $(BITCODES)
	llvm-link $(LIBBITCODES) $(BITCODES) -o mkdir_linked_nostatic.bc
	opt \
	  --function-sections \
      -O3 \
      -loop-simplify \
      < mkdir_linked_nostatic.bc \
      > mkdir_baseline_ls_opt_nostatic.bc
	llc  \
	  --function-sections \
      mkdir_baseline_ls_opt_nostatic.bc \
      -relocation-model=pic \
      -o mkdir_opt_nostatic.s
	g++ \
	  -no-pie \
	  -ffunction-sections \
	  -Wl,--verbose \
      mkdir_opt_nostatic.s \
      -o mkdir_nostatic \
      -lm -lrt -lpcre

wpd_nostatic: $(LIBBITCODES) $(BITCODES)
	# llvm-link $(LIBBITCODES) $(BITCODES) -o mkdir_linked_nostatic.bc
	# opt \
	#   --function-sections \
  #     -O3 \
  #     -loop-simplify \
  #     < mkdir_linked_nostatic.bc \
  #     > mkdir_baseline_ls_opt_nostatic.bc
	opt \
	  --function-sections \
      -load libWholeProgramDebloat.so \
      -WholeProgramDebloat \
      < mkdir_baseline_ls_opt_nostatic.bc \
      > mkdir_wpd_opt_nostatic.bc
	llc  \
	  --function-sections \
      mkdir_wpd_opt_nostatic.bc \
      -relocation-model=pic \
      -o mkdir_wpd_opt_nostatic.s
	g++ \
	  -no-pie \
	  -ffunction-sections \
	  -Wl,--verbose \
      mkdir_wpd_opt_nostatic.s \
      -o mkdir_wpd_nostatic \
      -ldebloat_rt -lm -lrt -lpcre > linker.lds
	readelf -s --wide mkdir_wpd_nostatic > readelf-wpd-nostatic.out
	readelf --sections mkdir_wpd_nostatic > readelf-sections-wpd-nostatic.out
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

wpd_custlink_nostatic: mkdir_wpd_opt_nostatic.s
	g++ \
	  -no-pie \
      -ffunction-sections \
      -c mkdir_wpd_opt_nostatic.s \
      -o mkdir_wpd_custlink_opt_nostatic.o
	g++ \
	  -no-pie \
	  -ffunction-sections \
      -T wpd-linker-script.lds \
      mkdir_wpd_custlink_opt_nostatic.o \
      -o mkdir_wpd_custlink_nostatic \
      -ldebloat_rt -lm -lrt -lpcre
	readelf -s --wide mkdir_wpd_custlink_nostatic > readelf-wpd-custlink-nostatic.out
	readelf --sections mkdir_wpd_custlink_nostatic > readelf-sections-wpd-custlink-nostatic.out

wpd_ics_nostatic: $(LIBBITCODES) $(BITCODES)
	llvm-link $(LIBBITCODES) $(BITCODES) ics.ll -o mkdir_linked_nostatic.bc
	opt \
	  --function-sections \
	    -O3 \
	    -loop-simplify \
	    < mkdir_linked_nostatic.bc \
	    > mkdir_baseline_ls_opt_nostatic.bc
	opt \
	  --function-sections \
      -load libWholeProgramDebloat.so \
      -WholeProgramDebloat \
      --enable-indirect-call-sinking=true \
      < mkdir_baseline_ls_opt_nostatic.bc \
      > mkdir_wpd_ics_opt_nostatic.bc
	# disassemble so we can do a hacky fix to the ics symbols
	llvm-dis mkdir_wpd_ics_opt_nostatic.bc
	sed -i \
      's/declare extern_weak i32 @ics_map_indirect_call.2(i64)//w sed_changes_0.txt' \
      mkdir_wpd_ics_opt_nostatic.ll
	sed -i \
      's/declare extern_weak i32 @ics_wrapper_debrt_protect_loop_end.3(i32)//w sed_changes_1.txt' \
      mkdir_wpd_ics_opt_nostatic.ll
	sed -i \
      's/ics_map_indirect_call.2/ics_map_indirect_call/w sed_changes_2.txt' \
      mkdir_wpd_ics_opt_nostatic.ll
	sed -i \
      's/ics_wrapper_debrt_protect_loop_end.3/ics_wrapper_debrt_protect_loop_end/w sed_changes_3.txt' \
      mkdir_wpd_ics_opt_nostatic.ll
	sed -i \
      's/debrt_protect_indirect.1/debrt_protect_indirect/w sed_changes_5.txt' \
      mkdir_wpd_ics_opt_nostatic.ll
	sed -i \
      's/declare i32 @debrt_protect_indirect(i64)$$//w sed_changes_4.txt' \
      mkdir_wpd_ics_opt_nostatic.ll
	# now ingest the modified .ll file and run always-inline on it.
	opt \
	 --function-sections \
     -always-inline \
     < mkdir_wpd_ics_opt_nostatic.ll \
     > mkdir_wpd_ics_opt_nostatic.bc
	llc  \
	  --function-sections \
      mkdir_wpd_ics_opt_nostatic.bc \
      -relocation-model=pic \
      -o mkdir_wpd_ics_opt_nostatic.s
	g++ \
	  -ffunction-sections \
	  -Wl,--verbose \
      mkdir_wpd_ics_opt_nostatic.s \
      -o mkdir_wpd_ics_nostatic \
      -ldebloat_rt -lm -lrt > linker.lds
	readelf -s --wide mkdir_wpd_ics_nostatic > readelf.out
	readelf --sections mkdir_wpd_ics_nostatic > readelf-sections.out
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

wpd_custlink_ics_nostatic: mkdir_wpd_ics_opt_nostatic.s
	g++ \
      -ffunction-sections \
      -c mkdir_wpd_ics_opt_nostatic.s \
      -o mkdir_wpd_custlink_ics_opt_nostatic.o
	g++ \
	  -ffunction-sections \
      -T wpd-linker-script.lds \
      mkdir_wpd_custlink_ics_opt_nostatic.o \
      -o mkdir_wpd_custlink_ics_nostatic \
      -ldebloat_rt -lm -lrt
	readelf -s --wide mkdir_wpd_custlink_ics_nostatic > readelf.out
	readelf --sections mkdir_wpd_custlink_ics_nostatic > readelf-sections.out
	cp readelf.out readelf-custlink-ics-nostatic.out
	cp readelf-sections.out readelf-sections-custlink-ics-nostatic.out

%.o: %.c 
	$(CC) $(HEADERS) $(CFLAGS) -c $< -o $@


lib/%.bc: lib/%.c
	$(CC) -DLIBDIR=\"/usr/local/lib\" -DHAVE_CONFIG_H -I. -Ilib -Ilib/glthread -g -fPIC -O3 -ffunction-sections -emit-llvm -S $< -o $@

src/%.bc: src/%.c
	$(CC) -DLIBDIR=\"/usr/local/lib\" -I. -Isrc -Ilib -Ilib/glthread -fPIC -O3 -ffunction-sections -emit-llvm -S $< -o $@

lib/libcoreutils.a: $(LIB)
	rm -f lib/libcoreutils.a
	$(AR) cq lib/libcoreutils.a $(LIB)

clean: 
	rm -f lib/*.o lib/glthread/*.bc lib/glthread/*.o lib/*.bc src/*.bc src/*.o
