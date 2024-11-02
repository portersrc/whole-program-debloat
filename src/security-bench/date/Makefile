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
lib/binary-io.bc \
lib/bitrotate.bc \
lib/buffer-lcm.bc \
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
lib/chmodat.bc \
lib/chownat.bc \
lib/creat-safer.bc \
lib/open-safer.bc \
lib/fd-hook.bc \
lib/fd-reopen.bc \
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
lib/freading.bc \
lib/freadseek.bc \
lib/freopen-safer.bc \
lib/ftoastr.bc \
lib/full-read.bc \
lib/full-write.bc \
lib/gethrxtime.bc \
lib/xtime.bc \
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
lib/math.bc \
lib/mbchar.bc \
lib/mbiter.bc \
lib/mbsalign.bc \
lib/mbscasecmp.bc \
lib/mbslen.bc \
lib/mbsstr.bc \
lib/mbswidth.bc \
lib/mbuiter.bc \
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
lib/root-dev-ino.bc \
lib/safe-read.bc \
lib/safe-write.bc \
lib/same.bc \
lib/save-cwd.bc \
lib/savedir.bc \
lib/savewd.bc \
lib/se-context.bc \
lib/se-selinux.bc \
lib/settime.bc \
lib/sig-handler.bc \
lib/sockets.bc \
lib/spawn-pipe.bc \
lib/stat-time.bc \
lib/statat.bc \
lib/mkstemp-safer.bc \
lib/strftime.bc \
lib/striconv.bc \
lib/strnlen1.bc \
lib/strintcmp.bc \
lib/strnumcmp.bc \
lib/sys_socket.bc \
lib/tempname.bc \
lib/glthread/threadlib.bc \
lib/timespec.bc \
lib/glthread/tls.bc \
lib/trim.bc \
lib/u64.bc \
lib/unicodeio.bc \
lib/unistd.bc \
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
lib/wctype-h.bc \
lib/write-any-file.bc \
lib/xmalloc.bc \
lib/xalloc-die.bc \
lib/xfreopen.bc \
lib/xfts.bc \
lib/xgetcwd.bc \
lib/xgetgroups.bc \
lib/xgethostname.bc \
lib/xmemcoll.bc \
lib/xnanosleep.bc \
lib/xprintf.bc \
lib/xreadlink.bc \
lib/xsize.bc \
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
lib/asnprintf.bc \
lib/asprintf.bc \
lib/chdir-long.bc \
lib/fclose.bc \
lib/fcntl.bc \
lib/fflush.bc \
lib/fpurge.bc \
lib/freadahead.bc \
lib/freadptr.bc \
lib/fseek.bc \
lib/fseeko.bc \
lib/fseterr.bc \
lib/fsusage.bc \
lib/fts.bc \
lib/futimens.bc \
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
lib/regex.bc \
lib/selinux-at.bc \
lib/sig2str.bc \
lib/utimensat.bc \
lib/vasnprintf.bc \
lib/vasprintf.bc \
lib/vfprintf.bc \
lib/vprintf.bc

BITCODES= src/date.bc \
src/version.bc


# BITCODES= src/version.bc \
# src/chroot.bc \
# src/hostid.bc \
# src/nice.bc \
# src/who.bc \
# src/users.bc \
# src/pinky.bc \
# src/uptime.bc \
# src/stty.bc \
# src/df.bc \
# src/stdbuf.bc \
# src/lbracket.bc \
# src/base64.bc \
# src/basename.bc \
# src/cat.bc \
# src/chcon.bc \
# src/chgrp.bc \
# src/chown-core.bc \
# src/chmod.bc \
# src/chown.bc \
# src/cksum.bc \
# src/comm.bc \
# src/cp.bc \
# src/copy.bc \
# src/cp-hash.bc \
# src/csplit.bc \
# src/cut.bc \
# src/date.bc \
# src/dd.bc \
# src/ls.bc \
# src/ls-dir.bc \
# src/dircolors.bc \
# src/dirname.bc \
# src/du.bc \
# src/echo.bc \
# src/env.bc \
# src/expand.bc \
# src/expr.bc \
# src/factor.bc \
# src/false.bc \
# src/fmt.bc \
# src/fold.bc \
# src/groups.bc \
# src/group-list.bc \
# src/head.bc \
# src/id.bc \
# src/join.bc \
# src/kill.bc \
# src/operand2sig.bc \
# src/link.bc \
# src/ln.bc \
# src/logname.bc \
# src/ls-ls.bc \
# src/mkdir.bc \
# src/prog-fprintf.bc \
# src/mkfifo.bc \
# src/mknod.bc \
# src/mktemp.bc \
# src/mv.bc \
# src/remove.bc \
# src/nl.bc \
# src/nproc.bc \
# src/nohup.bc \
# src/od.bc \
# src/paste.bc \
# src/pathchk.bc \
# src/pr.bc \
# src/printenv.bc \
# src/printf.bc \
# src/ptx.bc \
# src/pwd.bc \
# src/readlink.bc \
# src/rm.bc \
# src/rmdir.bc \
# src/runcon.bc \
# src/seq.bc \
# src/shred.bc \
# src/shuf.bc \
# src/sleep.bc \
# src/sort.bc \
# src/split.bc \
# src/stat.bc \
# src/sum.bc \
# src/sync.bc \
# src/tac.bc \
# src/tail.bc \
# src/tee.bc \
# src/test.bc \
# src/timeout.bc \
# src/touch.bc \
# src/tr.bc \
# src/true.bc \
# src/truncate.bc \
# src/tsort.bc \
# src/tty.bc \
# src/uname.bc \
# src/uname-uname.bc \
# src/unexpand.bc \
# src/uniq.bc \
# src/unlink.bc \
# src/ls-vdir.bc \
# src/wc.bc \
# src/whoami.bc \
# src/yes.bc \
# src/setuidgid.bc \
# src/getlimits.bc \
# src/su.bc

.SUFFIXES:
.SUFFIXES: .c .o .bc

all: base_ls wpd wpd_custlink

base_ls: $(LIBBITCODES) $(BITCODES)
	llvm-link $(LIBBITCODES) $(BITCODES) -o date_linked.bc
	opt \
	  --function-sections \
      -O3 \
      -loop-simplify \
      < date_linked.bc \
      > date_baseline_ls_opt.bc
	llc  \
	  --function-sections \
      date_baseline_ls_opt.bc \
      -relocation-model=pic \
      -o date_opt.s
	g++ \
	  -no-pie \
	  -ffunction-sections \
	  -Wl,--verbose \
      date_opt.s \
      -o date \
      -lm -lrt -lpcre

wpd: $(LIBBITCODES) $(BITCODES)
	llvm-link $(LIBBITCODES) $(BITCODES) -o date_linked.bc
	opt \
	  --function-sections \
      -O3 \
      -loop-simplify \
      < date_linked.bc \
      > date_baseline_ls_opt.bc
	opt \
	  --function-sections \
      -load libWholeProgramDebloat.so \
      -WholeProgramDebloat \
      < date_baseline_ls_opt.bc \
      > date_wpd_opt.bc
	llc  \
	  --function-sections \
      date_wpd_opt.bc \
      -relocation-model=pic \
      -o date_wpd_opt.s
	g++ \
	  -no-pie \
	  -ffunction-sections \
	  -Wl,--verbose \
      date_wpd_opt.s \
      -o date_wpd \
      -ldebloat_rt -lm -lrt -lpcre > linker.lds
	readelf -s --wide date_wpd > readelf-wpd.out
	readelf --sections date_wpd > readelf-sections-wpd.out
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

wpd_custlink: date_wpd_opt.s
	g++ \
	  -no-pie \
      -ffunction-sections \
      -c date_wpd_opt.s \
      -o date_wpd_custlink_opt.o
	g++ \
	  -no-pie \
	  -ffunction-sections \
      -T wpd-linker-script.lds \
      date_wpd_custlink_opt.o \
      -o date_wpd_custlink \
      -ldebloat_rt -lm -lrt -lpcre
	readelf -s --wide date_wpd_custlink > readelf-wpd-custlink.out
	readelf --sections date_wpd_custlink > readelf-sections-wpd-custlink.out

wpd_ics: $(LIBBITCODES) $(BITCODES)
	llvm-link $(LIBBITCODES) $(BITCODES) ics.ll -o date_linked.bc
	opt \
	  --function-sections \
	    -O3 \
	    -loop-simplify \
	    < date_linked.bc \
	    > date_baseline_ls_opt.bc
	opt \
	  --function-sections \
      -load libWholeProgramDebloat.so \
      -WholeProgramDebloat \
      --enable-indirect-call-sinking=true \
      < date_baseline_ls_opt.bc \
      > date_wpd_ics_opt.bc
	# disassemble so we can do a hacky fix to the ics symbols
	llvm-dis date_wpd_ics_opt.bc
	sed -i \
      's/declare extern_weak i32 @ics_map_indirect_call.2(i64)//w sed_changes_0.txt' \
      date_wpd_ics_opt.ll
	sed -i \
      's/declare extern_weak i32 @ics_wrapper_debrt_protect_loop_end.3(i32)//w sed_changes_1.txt' \
      date_wpd_ics_opt.ll
	sed -i \
      's/ics_map_indirect_call.2/ics_map_indirect_call/w sed_changes_2.txt' \
      date_wpd_ics_opt.ll
	sed -i \
      's/ics_wrapper_debrt_protect_loop_end.3/ics_wrapper_debrt_protect_loop_end/w sed_changes_3.txt' \
      date_wpd_ics_opt.ll
	sed -i \
      's/debrt_protect_indirect.1/debrt_protect_indirect/w sed_changes_5.txt' \
      date_wpd_ics_opt.ll
	sed -i \
      's/declare i32 @debrt_protect_indirect(i64)$$//w sed_changes_4.txt' \
      date_wpd_ics_opt.ll
	# now ingest the modified .ll file and run always-inline on it.
	opt \
	 --function-sections \
     -always-inline \
     < date_wpd_ics_opt.ll \
     > date_wpd_ics_opt.bc
	llc  \
	  --function-sections \
      date_wpd_ics_opt.bc \
      -relocation-model=pic \
      -o date_wpd_ics_opt.s
	g++ \
	  -ffunction-sections \
	  -Wl,--verbose \
      date_wpd_ics_opt.s \
      -o date_wpd_ics \
      -ldebloat_rt -lm -lrt > linker.lds
	readelf -s --wide date_wpd_ics > readelf.out
	readelf --sections date_wpd_ics > readelf-sections.out
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

wpd_custlink_ics: date_wpd_ics_opt.s
	g++ \
      -ffunction-sections \
      -c date_wpd_ics_opt.s \
      -o date_wpd_custlink_ics_opt.o
	g++ \
	  -ffunction-sections \
      -T wpd-linker-script.lds \
      date_wpd_custlink_ics_opt.o \
      -o date_wpd_custlink_ics \
      -ldebloat_rt -lm -lrt
	readelf -s --wide date_wpd_custlink_ics > readelf.out
	readelf --sections date_wpd_custlink_ics > readelf-sections.out
	cp readelf.out readelf-custlink-ics.out
	cp readelf-sections.out readelf-sections-custlink-ics.out

artd_opt: $(LIBBITCODES) $(BITCODES)
	llvm-link $(LIBBITCODES) $(BITCODES) ics.ll -o date_ics_linked.bc
	opt \
      --function-sections \
      -O3 \
      -loop-simplify \
      < date_ics_linked.bc \
      > date_ics_opt.bc
artd_pass_profile:
	opt \
      --function-sections \
      -load libAdvancedRuntimeDebloat.so \
      -AdvancedRuntimeDebloat \
      --artd-build=profile \
      < date_ics_opt.bc \
      > date_artd.bc
artd_pass_test_predict:
	opt \
      --function-sections \
      -load libAdvancedRuntimeDebloat.so \
      -AdvancedRuntimeDebloat \
      --artd-build=test_predict \
      < date_ics_opt.bc \
      > date_artd.bc
artd_pass_release:
	opt \
      --function-sections \
      -load libAdvancedRuntimeDebloat.so \
      -AdvancedRuntimeDebloat \
      --artd-build=release \
      < date_ics_opt.bc \
      > date_artd.bc
artd_ics_inline:
	# disassemble before inlining
	llvm-dis date_artd.bc -o date_artd-preinline.ll
	# inline
	opt \
      --function-sections \
      -always-inline \
      < date_artd-preinline.ll \
      > date_artd.bc
	# disassemble after inlining
	llvm-dis date_artd.bc -o date_artd-postinline.ll
artd_assemble:
	llc  \
      --function-sections \
      date_artd.bc \
      -relocation-model=pic \
      -o date_artd.s
	# Produce a default linker script.
	# FIXME Is there an easier way to do this than building the entire binary here?
	g++ \
      -ffunction-sections \
      -Wl,--verbose \
      date_artd.s \
      -o date_artd_tmp \
      -ldebloat_rt -lm -lrt > linker.lds
	rm date_artd_tmp
	# Create a custom linker script
	python3 linker.py .
	g++ \
      -ffunction-sections \
      -c date_artd.s \
      -o date_artd.o
artd_bin_profile:
	g++ \
      -ffunction-sections \
      -T artd-linker-script.lds \
      date_artd.o \
      -o date_artd_profile \
      -ldebloat_rt -lm -lrt
artd_bin_test_predict:
	g++ \
      -ffunction-sections \
      -T artd-linker-script.lds \
      date_artd.o \
      -o date_artd_test_predict \
      -ldebloat_rt -lm -lrt
artd_bin_release:
	g++ \
      -ffunction-sections \
      -T artd-linker-script.lds \
      date_artd.o \
      -o date_artd_release \
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
      < date_ics_opt.bc \
      > date_datalog.bc
	  
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
