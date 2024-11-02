VERSION = 8.4
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
lib/areadlink.bc \
lib/areadlink-with-size.bc \
lib/areadlinkat.bc \
lib/argv-iter.bc \
lib/base64.bc \
lib/c-ctype.bc \
lib/c-strcasecmp.bc \
lib/c-strncasecmp.bc \
lib/close-hook.bc \
lib/diacrit.bc \
lib/fd-safer-flag.bc \
lib/dup-safer-flag.bc \
lib/file-set.bc \
lib/filevercmp.bc \
lib/freadahead.bc \
lib/freading.bc \
lib/freadptr.bc \
lib/freadseek.bc \
lib/fseterr.bc \
lib/full-read.bc \
lib/full-write.bc \
lib/getdate.bc \
lib/hash-pjw.bc \
lib/hash-triple.bc \
lib/linebuffer.bc \
lib/localcharset.bc \
lib/glthread/lock.bc \
lib/malloca.bc \
lib/mbchar.bc \
lib/mbsalign.bc \
lib/mbscasecmp.bc \
lib/mbslen.bc \
lib/mbsstr.bc \
lib/mbswidth.bc \
lib/memchr2.bc \
lib/memcmp2.bc \
lib/nproc.bc \
lib/openat-die.bc \
lib/printf-frexp.bc \
lib/printf-frexpl.bc \
lib/priv-set.bc \
lib/progname.bc \
lib/propername.bc \
lib/randint.bc \
lib/randperm.bc \
lib/randread.bc \
lib/rand-isaac.bc \
lib/readtokens0.bc \
lib/savewd.bc \
lib/sockets.bc \
lib/striconv.bc \
lib/strnlen1.bc \
lib/glthread/threadlib.bc \
lib/glthread/tls.bc \
lib/trim.bc \
lib/unicodeio.bc \
lib/unistr/u8-uctomb.bc \
lib/unistr/u8-uctomb-aux.bc \
lib/uniwidth/width.bc \
lib/verror.bc \
lib/version-etc.bc \
lib/version-etc-fsf.bc \
lib/xalloc-die.bc \
lib/xfreopen.bc \
lib/xgethostname.bc \
lib/xmemcoll.bc \
lib/xprintf.bc \
lib/xreadlink.bc \
lib/xstriconv.bc \
lib/xstrndup.bc \
lib/xstrtoimax.bc \
lib/xstrtoumax.bc \
lib/xvasprintf.bc \
lib/xasprintf.bc \
lib/buffer-lcm.bc \
lib/xmemxfrm.bc \
lib/argmatch.bc \
lib/asnprintf.bc \
lib/asprintf.bc \
lib/backupfile.bc \
lib/basename.bc \
lib/basename-lgpl.bc \
lib/c-strtod.bc \
lib/c-strtold.bc \
lib/canon-host.bc \
lib/canonicalize.bc \
lib/chdir-long.bc \
lib/cloexec.bc \
lib/close-stream.bc \
lib/closein.bc \
lib/closeout.bc \
lib/creat-safer.bc \
lib/cycle-check.bc \
lib/dirchownmod.bc \
lib/dirname.bc \
lib/dirname-lgpl.bc \
lib/dup-safer.bc \
lib/exclude.bc \
lib/exitfail.bc \
lib/fcntl.bc \
lib/fd-safer.bc \
lib/fflush.bc \
lib/file-type.bc \
lib/filemode.bc \
lib/filenamecat.bc \
lib/filenamecat-lgpl.bc \
lib/fopen-safer.bc \
lib/fprintftime.bc \
lib/fpurge.bc \
lib/freopen-safer.bc \
lib/fseeko.bc \
lib/fsusage.bc \
lib/fts.bc \
lib/gethrxtime.bc \
lib/getndelim2.bc \
lib/getpass.bc \
lib/gettime.bc \
lib/getugroups.bc \
lib/hard-locale.bc \
lib/hash.bc \
lib/human.bc \
lib/i-ring.bc \
lib/idcache.bc \
lib/imaxtostr.bc \
lib/isapipe.bc \
lib/isnanl.bc \
lib/linkat.bc \
lib/long-options.bc \
lib/md5.bc \
lib/memcasecmp.bc \
lib/memcoll.bc \
lib/mgetgroups.bc \
lib/mkancesdirs.bc \
lib/mkdir-p.bc \
lib/mkstemp-safer.bc \
lib/modechange.bc \
lib/mountlist.bc \
lib/mpsort.bc \
lib/nanosleep.bc \
lib/offtostr.bc \
lib/open-safer.bc \
lib/openat-proc.bc \
lib/openat-safer.bc \
lib/opendir-safer.bc \
lib/physmem.bc \
lib/pipe-safer.bc \
lib/posixtm.bc \
lib/posixver.bc \
lib/printf-args.bc \
lib/printf-parse.bc \
lib/quote.bc \
lib/quotearg.bc \
lib/readtokens.bc \
lib/readutmp.bc \
lib/regex.bc \
lib/root-dev-ino.bc \
lib/safe-read.bc \
lib/safe-write.bc \
lib/same.bc \
lib/save-cwd.bc \
lib/savedir.bc \
lib/selinux-at.bc \
lib/settime.bc \
lib/sha1.bc \
lib/sha256.bc \
lib/sha512.bc \
lib/sig2str.bc \
lib/strftime.bc \
lib/stripslash.bc \
lib/tempname.bc \
lib/uinttostr.bc \
lib/umaxtostr.bc \
lib/userspec.bc \
lib/utimecmp.bc \
lib/utimens.bc \
lib/vasnprintf.bc \
lib/vasprintf.bc \
lib/vfprintf.bc \
lib/vprintf.bc \
lib/write-any-file.bc \
lib/xgetcwd.bc \
lib/xmalloc.bc \
lib/xnanosleep.bc \
lib/xstrtod.bc \
lib/xstrtol.bc \
lib/xstrtol-error.bc \
lib/xstrtold.bc \
lib/xstrtoul.bc \
lib/yesno.bc \
lib/euidaccess-stat.bc \
lib/fd-reopen.bc \
lib/xfts.bc \
lib/memxfrm.bc \
lib/strintcmp.bc \
lib/strnumcmp.bc

BITCODES= src/rm.bc \
src/remove.bc \
src/version.bc

.SUFFIXES:
.SUFFIXES: .c .o .bc

all: base_ls wpd wpd_custlink

base_ls: $(LIBBITCODES) $(BITCODES)
	llvm-link $(LIBBITCODES) $(BITCODES) -o rm_linked.bc
	opt \
	  --function-sections \
      -O3 \
      -loop-simplify \
      < rm_linked.bc \
      > rm_baseline_ls_opt.bc
	llc  \
	  --function-sections \
      rm_baseline_ls_opt.bc \
      -relocation-model=pic \
      -o rm_opt.s
	g++ \
	  -no-pie \
	  -ffunction-sections \
	  -Wl,--verbose \
      rm_opt.s \
      -o rm \
      -lm -lrt -lpcre

wpd: $(LIBBITCODES) $(BITCODES)
	# llvm-link $(LIBBITCODES) $(BITCODES) -o rm_linked.bc
	# opt \
	#   --function-sections \
  #     -O3 \
  #     -loop-simplify \
  #     < rm_linked.bc \
  #     > rm_baseline_ls_opt.bc
	opt \
	  --function-sections \
      -load libWholeProgramDebloat.so \
      -WholeProgramDebloat \
      < rm_baseline_ls_opt.bc \
      > rm_wpd_opt.bc
	llc  \
	  --function-sections \
      rm_wpd_opt.bc \
      -relocation-model=pic \
      -o rm_wpd_opt.s
	g++ \
	  -no-pie \
	  -ffunction-sections \
	  -Wl,--verbose \
      rm_wpd_opt.s \
      -o rm_wpd \
      -ldebloat_rt -lm -lrt -lpcre > linker.lds
	readelf -s --wide rm_wpd > readelf-wpd.out
	readelf --sections rm_wpd > readelf-sections-wpd.out
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

wpd_custlink: rm_wpd_opt.s
	g++ \
	  -no-pie \
      -ffunction-sections \
      -c rm_wpd_opt.s \
      -o rm_wpd_custlink_opt.o
	g++ \
	  -no-pie \
	  -ffunction-sections \
      -T wpd-linker-script.lds \
      rm_wpd_custlink_opt.o \
      -o rm_wpd_custlink \
      -ldebloat_rt -lm -lrt -lpcre
	readelf -s --wide rm_wpd_custlink > readelf-wpd-custlink.out
	readelf --sections rm_wpd_custlink > readelf-sections-wpd-custlink.out

wpd_ics: $(LIBBITCODES) $(BITCODES)
	llvm-link $(LIBBITCODES) $(BITCODES) ics.ll -o rm_linked.bc
	opt \
	  --function-sections \
	    -O3 \
	    -loop-simplify \
	    < rm_linked.bc \
	    > rm_baseline_ls_opt.bc
	opt \
	  --function-sections \
      -load libWholeProgramDebloat.so \
      -WholeProgramDebloat \
      --enable-indirect-call-sinking=true \
      < rm_baseline_ls_opt.bc \
      > rm_wpd_ics_opt.bc
	# disassemble so we can do a hacky fix to the ics symbols
	llvm-dis rm_wpd_ics_opt.bc
	sed -i \
      's/declare extern_weak i32 @ics_map_indirect_call.2(i64)//w sed_changes_0.txt' \
      rm_wpd_ics_opt.ll
	sed -i \
      's/declare extern_weak i32 @ics_wrapper_debrt_protect_loop_end.3(i32)//w sed_changes_1.txt' \
      rm_wpd_ics_opt.ll
	sed -i \
      's/ics_map_indirect_call.2/ics_map_indirect_call/w sed_changes_2.txt' \
      rm_wpd_ics_opt.ll
	sed -i \
      's/ics_wrapper_debrt_protect_loop_end.3/ics_wrapper_debrt_protect_loop_end/w sed_changes_3.txt' \
      rm_wpd_ics_opt.ll
	sed -i \
      's/debrt_protect_indirect.1/debrt_protect_indirect/w sed_changes_5.txt' \
      rm_wpd_ics_opt.ll
	sed -i \
      's/declare i32 @debrt_protect_indirect(i64)$$//w sed_changes_4.txt' \
      rm_wpd_ics_opt.ll
	# now ingest the modified .ll file and run always-inline on it.
	opt \
	 --function-sections \
     -always-inline \
     < rm_wpd_ics_opt.ll \
     > rm_wpd_ics_opt.bc
	llc  \
	  --function-sections \
      rm_wpd_ics_opt.bc \
      -relocation-model=pic \
      -o rm_wpd_ics_opt.s
	g++ \
	  -ffunction-sections \
	  -Wl,--verbose \
      rm_wpd_ics_opt.s \
      -o rm_wpd_ics \
      -ldebloat_rt -lm -lrt > linker.lds
	readelf -s --wide rm_wpd_ics > readelf.out
	readelf --sections rm_wpd_ics > readelf-sections.out
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

wpd_custlink_ics: rm_wpd_ics_opt.s
	g++ \
      -ffunction-sections \
      -c rm_wpd_ics_opt.s \
      -o rm_wpd_custlink_ics_opt.o
	g++ \
	  -ffunction-sections \
      -T wpd-linker-script.lds \
      rm_wpd_custlink_ics_opt.o \
      -o rm_wpd_custlink_ics \
      -ldebloat_rt -lm -lrt
	readelf -s --wide rm_wpd_custlink_ics > readelf.out
	readelf --sections rm_wpd_custlink_ics > readelf-sections.out
	cp readelf.out readelf-custlink-ics.out
	cp readelf-sections.out readelf-sections-custlink-ics.out

artd_opt: $(LIBBITCODES) $(BITCODES)
	llvm-link $(LIBBITCODES) $(BITCODES) ics.ll -o rm_ics_linked.bc
	opt \
      --function-sections \
      -O3 \
      -loop-simplify \
      < rm_ics_linked.bc \
      > rm_ics_opt.bc
artd_pass_profile:
	opt \
      --function-sections \
      -load libAdvancedRuntimeDebloat.so \
      -AdvancedRuntimeDebloat \
      --artd-build=profile \
      < rm_ics_opt.bc \
      > rm_artd.bc
artd_pass_test_predict:
	opt \
      --function-sections \
      -load libAdvancedRuntimeDebloat.so \
      -AdvancedRuntimeDebloat \
      --artd-build=test_predict \
      < rm_ics_opt.bc \
      > rm_artd.bc
artd_pass_release:
	opt \
      --function-sections \
      -load libAdvancedRuntimeDebloat.so \
      -AdvancedRuntimeDebloat \
      --artd-build=release \
      < rm_ics_opt.bc \
      > rm_artd.bc
artd_ics_inline:
	# disassemble before inlining
	llvm-dis rm_artd.bc -o rm_artd-preinline.ll
	# inline
	opt \
      --function-sections \
      -always-inline \
      < rm_artd-preinline.ll \
      > rm_artd.bc
	# disassemble after inlining
	llvm-dis rm_artd.bc -o rm_artd-postinline.ll
artd_assemble:
	llc  \
      --function-sections \
      rm_artd.bc \
      -relocation-model=pic \
      -o rm_artd.s
	# Produce a default linker script.
	# FIXME Is there an easier way to do this than building the entire binary here?
	g++ \
      -ffunction-sections \
      -Wl,--verbose \
      rm_artd.s \
      -o rm_artd_tmp \
      -ldebloat_rt -lm -lrt > linker.lds
	rm rm_artd_tmp
	# Create a custom linker script
	python3 linker.py .
	g++ \
      -ffunction-sections \
      -c rm_artd.s \
      -o rm_artd.o
artd_bin_profile:
	g++ \
      -ffunction-sections \
      -T artd-linker-script.lds \
      rm_artd.o \
      -o rm_artd_profile \
      -ldebloat_rt -lm -lrt
artd_bin_test_predict:
	g++ \
      -ffunction-sections \
      -T artd-linker-script.lds \
      rm_artd.o \
      -o rm_artd_test_predict \
      -ldebloat_rt -lm -lrt
artd_bin_release:
	g++ \
      -ffunction-sections \
      -T artd-linker-script.lds \
      rm_artd.o \
      -o rm_artd_release \
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
      < rm_ics_opt.bc \
      > rm_datalog.bc

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
