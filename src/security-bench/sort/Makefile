VERSION = 8.16
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

LIBBITCODES=lib/set-mode-acl.bc \
lib/copy-acl.bc \
lib/file-has-acl.bc \
lib/allocator.bc \
lib/areadlink.bc \
lib/areadlink-with-size.bc \
lib/areadlinkat.bc \
lib/argmatch.bc \
lib/argv-iter.bc \
lib/backupfile.bc \
lib/base64.bc \
lib/c-ctype.bc \
lib/c-strcasecmp.bc \
lib/c-strncasecmp.bc \
lib/c-strtod.bc \
lib/c-strtold.bc \
lib/canon-host.bc \
lib/canonicalize.bc \
lib/careadlinkat.bc \
lib/cloexec.bc \
lib/close-stream.bc \
lib/closein.bc \
lib/closeout.bc \
lib/md5.bc \
lib/sha1.bc \
lib/sha256.bc \
lib/sha512.bc \
lib/cycle-check.bc \
lib/di-set.bc \
lib/diacrit.bc \
lib/opendir-safer.bc \
lib/dirname.bc \
lib/basename.bc \
lib/dirname-lgpl.bc \
lib/basename-lgpl.bc \
lib/stripslash.bc \
lib/dtoastr.bc \
lib/dtotimespec.bc \
lib/exclude.bc \
lib/exitfail.bc \
lib/fadvise.bc \
lib/fatal-signal.bc \
lib/creat-safer.bc \
lib/open-safer.bc \
lib/fd-hook.bc \
lib/fd-safer-flag.bc \
lib/dup-safer-flag.bc \
lib/fdutimensat.bc \
lib/file-set.bc \
lib/file-type.bc \
lib/filemode.bc \
lib/filenamecat.bc \
lib/filenamecat-lgpl.bc \
lib/filevercmp.bc \
lib/fopen-safer.bc \
lib/fprintftime.bc \
lib/freadahead.bc \
lib/freading.bc \
lib/freadptr.bc \
lib/freadseek.bc \
lib/freopen-safer.bc \
lib/fseterr.bc \
lib/ftoastr.bc \
lib/full-read.bc \
lib/full-write.bc \
lib/getndelim2.bc \
lib/gettime.bc \
lib/getugroups.bc \
lib/hard-locale.bc \
lib/hash.bc \
lib/hash-pjw.bc \
lib/hash-triple.bc \
lib/heap.bc \
lib/human.bc \
lib/i-ring.bc \
lib/idcache.bc \
lib/ino-map.bc \
lib/imaxtostr.bc \
lib/inttostr.bc \
lib/offtostr.bc \
lib/uinttostr.bc \
lib/umaxtostr.bc \
lib/ldtoastr.bc \
lib/linebuffer.bc \
lib/localcharset.bc \
lib/glthread/lock.bc \
lib/long-options.bc \
lib/malloca.bc \
lib/mbchar.bc \
lib/mbsalign.bc \
lib/mbscasecmp.bc \
lib/mbslen.bc \
lib/mbsstr.bc \
lib/mbswidth.bc \
lib/memcasecmp.bc \
lib/memchr2.bc \
lib/memcmp2.bc \
lib/memcoll.bc \
lib/mgetgroups.bc \
lib/mkancesdirs.bc \
lib/dirchownmod.bc \
lib/mkdir-p.bc \
lib/modechange.bc \
lib/mpsort.bc \
lib/nproc.bc \
lib/openat-die.bc \
lib/openat-safer.bc \
lib/parse-datetime.bc \
lib/physmem.bc \
lib/pipe2.bc \
lib/pipe2-safer.bc \
lib/posixtm.bc \
lib/posixver.bc \
lib/printf-frexp.bc \
lib/printf-frexpl.bc \
lib/priv-set.bc \
lib/progname.bc \
lib/propername.bc \
lib/quotearg.bc \
lib/randint.bc \
lib/randperm.bc \
lib/randread.bc \
lib/rand-isaac.bc \
lib/read-file.bc \
lib/readtokens.bc \
lib/readtokens0.bc \
lib/safe-read.bc \
lib/safe-write.bc \
lib/same.bc \
lib/save-cwd.bc \
lib/savedir.bc \
lib/savewd.bc \
lib/settime.bc \
lib/sockets.bc \
lib/spawn-pipe.bc \
lib/mkstemp-safer.bc \
lib/strftime.bc \
lib/striconv.bc \
lib/strnlen1.bc \
lib/tempname.bc \
lib/glthread/threadlib.bc \
lib/glthread/tls.bc \
lib/trim.bc \
lib/unicodeio.bc \
lib/dup-safer.bc \
lib/fd-safer.bc \
lib/pipe-safer.bc \
lib/unistr/u8-mbtoucr.bc \
lib/unistr/u8-uctomb.bc \
lib/unistr/u8-uctomb-aux.bc \
lib/uniwidth/width.bc \
lib/userspec.bc \
lib/utimecmp.bc \
lib/utimens.bc \
lib/verror.bc \
lib/version-etc.bc \
lib/version-etc-fsf.bc \
lib/wait-process.bc \
lib/write-any-file.bc \
lib/xmalloc.bc \
lib/xalloc-die.bc \
lib/xfreopen.bc \
lib/xgetcwd.bc \
lib/xgetgroups.bc \
lib/xgethostname.bc \
lib/xmemcoll.bc \
lib/xnanosleep.bc \
lib/xprintf.bc \
lib/xreadlink.bc \
lib/xstriconv.bc \
lib/xstrndup.bc \
lib/xstrtod.bc \
lib/xstrtoimax.bc \
lib/xstrtol.bc \
lib/xstrtoul.bc \
lib/xstrtol-error.bc \
lib/xstrtold.bc \
lib/xstrtoumax.bc \
lib/xvasprintf.bc \
lib/xasprintf.bc \
lib/yesno.bc \
lib/buffer-lcm.bc \
lib/asnprintf.bc \
lib/asprintf.bc \
lib/chdir-long.bc \
lib/fclose.bc \
lib/fcntl.bc \
lib/fflush.bc \
lib/fpurge.bc \
lib/fseek.bc \
lib/fseeko.bc \
lib/fsusage.bc \
lib/fts.bc \
lib/futimens.bc \
lib/gethrxtime.bc \
lib/getpass.bc \
lib/isapipe.bc \
lib/isnanl.bc \
lib/linkat.bc \
lib/mountlist.bc \
lib/nanosleep.bc \
lib/openat-proc.bc \
lib/printf-args.bc \
lib/printf-parse.bc \
lib/readutmp.bc \
lib/remove.bc \
lib/root-dev-ino.bc \
lib/selinux-at.bc \
lib/sig2str.bc \
lib/utimensat.bc \
lib/vasnprintf.bc \
lib/vasprintf.bc \
lib/vfprintf.bc \
lib/vprintf.bc \
lib/fd-reopen.bc \
lib/xfts.bc \
lib/strintcmp.bc \
lib/strnumcmp.bc

BITCODES= src/sort.bc \
src/version.bc 


.SUFFIXES:
.SUFFIXES: .c .o .bc

all: base_ls wpd wpd_custlink

base_ls: $(LIBBITCODES) $(BITCODES)
	llvm-link $(LIBBITCODES) $(BITCODES) -o sort_linked.bc
	opt \
	  --function-sections \
      -O3 \
      -loop-simplify \
      < sort_linked.bc \
      > sort_baseline_ls_opt.bc
	llc  \
	  --function-sections \
      sort_baseline_ls_opt.bc \
      -relocation-model=pic \
      -o sort_opt.s
	g++ \
	  -no-pie \
	  -ffunction-sections \
	  -Wl,--verbose \
      sort_opt.s \
      -o sort \
      -lm -lrt -lpcre -lpthread

wpd: $(LIBBITCODES) $(BITCODES)
	# llvm-link $(LIBBITCODES) $(BITCODES) -o sort_linked.bc
	# opt \
	#   --function-sections \
  #     -O3 \
  #     -loop-simplify \
  #     < sort_linked.bc \
  #     > sort_baseline_ls_opt.bc
	opt \
	  --function-sections \
      -load libWholeProgramDebloat.so \
      -WholeProgramDebloat \
      < sort_baseline_ls_opt.bc \
      > sort_wpd_opt.bc
	llc  \
	  --function-sections \
      sort_wpd_opt.bc \
      -relocation-model=pic \
      -o sort_wpd_opt.s
	g++ \
	  -no-pie \
	  -ffunction-sections \
	  -Wl,--verbose \
      sort_wpd_opt.s \
      -o sort_wpd \
      -ldebloat_rt -lm -lrt -lpcre -lpthread > linker.lds
	readelf -s --wide sort_wpd > readelf-wpd.out
	readelf --sections sort_wpd > readelf-sections-wpd.out
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

wpd_custlink: sort_wpd_opt.s
	g++ \
	  -no-pie \
      -ffunction-sections \
      -c sort_wpd_opt.s \
      -o sort_wpd_custlink_opt.o
	g++ \
	  -no-pie \
	  -ffunction-sections \
      -T wpd-linker-script.lds \
      sort_wpd_custlink_opt.o \
      -o sort_wpd_custlink \
      -ldebloat_rt -lm -lrt -lpcre -lpthread
	readelf -s --wide sort_wpd_custlink > readelf-wpd-custlink.out
	readelf --sections sort_wpd_custlink > readelf-sections-wpd-custlink.out

wpd_ics: $(LIBBITCODES) $(BITCODES)
	llvm-link $(LIBBITCODES) $(BITCODES) ics.ll -o sort_linked.bc
	opt \
	  --function-sections \
	    -O3 \
	    -loop-simplify \
	    < sort_linked.bc \
	    > sort_baseline_ls_opt.bc
	opt \
	  --function-sections \
      -load libWholeProgramDebloat.so \
      -WholeProgramDebloat \
      --enable-indirect-call-sinking=true \
      < sort_baseline_ls_opt.bc \
      > sort_wpd_ics_opt.bc
	# disassemble so we can do a hacky fix to the ics symbols
	llvm-dis sort_wpd_ics_opt.bc
	sed -i \
      's/declare extern_weak i32 @ics_map_indirect_call.2(i64)//w sed_changes_0.txt' \
      sort_wpd_ics_opt.ll
	sed -i \
      's/declare extern_weak i32 @ics_wrapper_debrt_protect_loop_end.3(i32)//w sed_changes_1.txt' \
      sort_wpd_ics_opt.ll
	sed -i \
      's/ics_map_indirect_call.2/ics_map_indirect_call/w sed_changes_2.txt' \
      sort_wpd_ics_opt.ll
	sed -i \
      's/ics_wrapper_debrt_protect_loop_end.3/ics_wrapper_debrt_protect_loop_end/w sed_changes_3.txt' \
      sort_wpd_ics_opt.ll
	sed -i \
      's/debrt_protect_indirect.1/debrt_protect_indirect/w sed_changes_5.txt' \
      sort_wpd_ics_opt.ll
	sed -i \
      's/declare i32 @debrt_protect_indirect(i64)$$//w sed_changes_4.txt' \
      sort_wpd_ics_opt.ll
	# now ingest the modified .ll file and run always-inline on it.
	opt \
	 --function-sections \
     -always-inline \
     < sort_wpd_ics_opt.ll \
     > sort_wpd_ics_opt.bc
	llc  \
	  --function-sections \
      sort_wpd_ics_opt.bc \
      -relocation-model=pic \
      -o sort_wpd_ics_opt.s
	g++ \
	  -ffunction-sections \
	  -Wl,--verbose \
      sort_wpd_ics_opt.s \
      -o sort_wpd_ics \
      -ldebloat_rt -lm -lrt -lpthread > linker.lds
	readelf -s --wide sort_wpd_ics > readelf.out
	readelf --sections sort_wpd_ics > readelf-sections.out
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

wpd_custlink_ics: sort_wpd_ics_opt.s
	g++ \
      -ffunction-sections \
      -c sort_wpd_ics_opt.s \
      -o sort_wpd_custlink_ics_opt.o
	g++ \
	  -ffunction-sections \
      -T wpd-linker-script.lds \
      sort_wpd_custlink_ics_opt.o \
      -o sort_wpd_custlink_ics \
      -ldebloat_rt -lm -lrt -lpthread
	readelf -s --wide sort_wpd_custlink_ics > readelf.out
	readelf --sections sort_wpd_custlink_ics > readelf-sections.out
	cp readelf.out readelf-custlink-ics.out
	cp readelf-sections.out readelf-sections-custlink-ics.out


artd_opt: $(LIBBITCODES) $(BITCODES)
	llvm-link $(LIBBITCODES) $(BITCODES) ics.ll -o sort_ics_linked.bc
	opt \
      --function-sections \
      -O3 \
      -loop-simplify \
      < sort_ics_linked.bc \
      > sort_ics_opt.bc
artd_pass_profile:
	opt \
      --function-sections \
      -load libAdvancedRuntimeDebloat.so \
      -AdvancedRuntimeDebloat \
      --artd-build=profile \
      < sort_ics_opt.bc \
      > sort_artd.bc
artd_pass_test_predict:
	opt \
      --function-sections \
      -load libAdvancedRuntimeDebloat.so \
      -AdvancedRuntimeDebloat \
      --artd-build=test_predict \
      < sort_ics_opt.bc \
      > sort_artd.bc
artd_pass_release:
	opt \
      --function-sections \
      -load libAdvancedRuntimeDebloat.so \
      -AdvancedRuntimeDebloat \
      --artd-build=release \
      < sort_ics_opt.bc \
      > sort_artd.bc
artd_ics_inline:
	# disassemble before inlining
	llvm-dis sort_artd.bc -o sort_artd-preinline.ll
	# inline
	opt \
      --function-sections \
      -always-inline \
      < sort_artd-preinline.ll \
      > sort_artd.bc
	# disassemble after inlining
	llvm-dis sort_artd.bc -o sort_artd-postinline.ll
artd_assemble:
	llc  \
      --function-sections \
      sort_artd.bc \
      -relocation-model=pic \
      -o sort_artd.s
	# Produce a default linker script.
	# FIXME Is there an easier way to do this than building the entire binary here?
	g++ \
      -ffunction-sections \
      -Wl,--verbose \
      sort_artd.s \
      -o sort_artd_tmp \
      -ldebloat_rt -lm -lrt -lpthread > linker.lds
	rm sort_artd_tmp
	# Create a custom linker script
	python3 linker.py .
	g++ \
      -ffunction-sections \
      -c sort_artd.s \
      -o sort_artd.o
artd_bin_profile:
	g++ \
      -ffunction-sections \
      -T artd-linker-script.lds \
      sort_artd.o \
      -o sort_artd_profile \
      -ldebloat_rt -lm -lrt -lpthread
artd_bin_test_predict:
	g++ \
      -ffunction-sections \
      -T artd-linker-script.lds \
      sort_artd.o \
      -o sort_artd_test_predict \
      -ldebloat_rt -lm -lrt -lpthread
artd_bin_release:
	g++ \
      -ffunction-sections \
      -T artd-linker-script.lds \
      sort_artd.o \
      -o sort_artd_release \
      -ldebloat_rt -lm -lrt -lpthread
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
      < sort_ics_opt.bc \
      > sort_datalog.bc

%.o: %.c 
	$(CC) $(HEADERS) $(CFLAGS) -c $< -o $@

lib/%.bc: lib/%.c
	$(CC) -DHAVE_CONFIG_H -DLIBDIR=\"/usr/local/lib\" -I. -Ilib -Ilib/glthread -g -fPIC -O3 -ffunction-sections -emit-llvm -S $< -o $@

src/%.bc: src/%.c
	$(CC) -DHAVE_CONFIG_H -DLIBDIR=\"/usr/local/lib\" -I. -Isrc -Ilib -Ilib/glthread -fPIC -O3 -ffunction-sections -emit-llvm -S $< -o $@

lib/libcoreutils.a: $(LIB)
	rm -f lib/libcoreutils.a
	$(AR) cq lib/libcoreutils.a $(LIB)

clean: 
	rm -f lib/*.o lib/glthread/*.bc lib/glthread/*.o lib/*.bc src/*.bc src/*.o
