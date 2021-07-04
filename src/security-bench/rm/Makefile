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

all: base_ls_nostatic wpd_nostatic wpd_custlink_nostatic
#base_ls_static wpd_static wpd_custlink_static
# base_ls_static: lib/libcoreutils.a $(BITCODES)
# 	llvm-link $(BITCODES) -o rm_linked_static.bc
# 	opt \
# 	  --function-sections \
#       -O3 \
#       -loop-simplify \
#       < rm_linked_static.bc \
#       > rm_baseline_ls_opt_static.bc
# 	llc  \
# 	  --function-sections \
#       rm_baseline_ls_opt_static.bc \
#       -relocation-model=pic \
#       -o rm_opt_static.s
# 	g++ \
# 	  -no-pie \
# 	  -ffunction-sections \
# 	  -Wl,--verbose \
#       rm_opt_static.s \
#       -o rm_static \
#       -lm -lrt -Llib -lgreputils > linker.lds
# 	readelf -s --wide rm_static > readelf-static.out
# 	readelf --sections rm_static > readelf-sections-static.out
# 	cp linker.lds linker_static.lds

# wpd_static: lib/libcoreutils.a $(BITCODES)
# 	llvm-link $(BITCODES) -o rm_linked_static.bc
# 	opt \
# 	  --function-sections \
#       -O3 \
#       -loop-simplify \
#       < rm_linked_static.bc \
#       > rm_baseline_ls_opt_static.bc
# 	opt \
# 	  --function-sections \
#       -load libWholeProgramDebloat.so \
#       -WholeProgramDebloat \
#       < rm_baseline_ls_opt_static.bc \
#       > rm_wpd_opt_static.bc
# 	llc  \
# 	  --function-sections \
#       rm_wpd_opt_static.bc \
#       -relocation-model=pic \
#       -o rm_wpd_opt_static.s
# 	g++ \
# 	  -no-pie \
# 	  -ffunction-sections \
# 	  -Wl,--verbose \
#       rm_wpd_opt_static.s \
#       -o rm_wpd_static \
#       -ldebloat_rt -lm -lrt -Llib -lgreputil > linker.lds
# 	readelf -s --wide rm_wpd_static > readelf-wpd-static.out
# 	readelf --sections rm_wpd_static > readelf-sections-wpd-static.out
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

# wpd_custlink_static: lib/libcoreutils.a rm_wpd_opt_static.s
# 	g++ \
# 	  -no-pie \
#       -ffunction-sections \
#       -c rm_wpd_opt_static.s \
#       -o rm_wpd_custlink_opt_static.o
# 	g++ \
# 	  -no-pie \
# 	  -ffunction-sections \
#       -T wpd-linker-script.lds \
#       rm_wpd_custlink_opt_static.o \
#       -o rm_wpd_custlink_static \
#       -ldebloat_rt -lm -lrt -Llib -lgreputil
# 	readelf -s --wide rm_wpd_custlink_static > readelf-wpd-custlink-static.out
# 	readelf --sections rm_wpd_custlink_static > readelf-sections-wpd-custlink-static.out

base_ls_nostatic: $(LIBBITCODES) $(BITCODES)
	llvm-link $(LIBBITCODES) $(BITCODES) -o rm_linked_nostatic.bc
	opt \
	  --function-sections \
      -O3 \
      -loop-simplify \
      < rm_linked_nostatic.bc \
      > rm_baseline_ls_opt_nostatic.bc
	llc  \
	  --function-sections \
      rm_baseline_ls_opt_nostatic.bc \
      -relocation-model=pic \
      -o rm_opt_nostatic.s
	g++ \
	  -no-pie \
	  -ffunction-sections \
	  -Wl,--verbose \
      rm_opt_nostatic.s \
      -o rm_nostatic \
      -lm -lrt -lpcre > linker.lds
	readelf -s --wide rm_nostatic > readelf-nostatic.out
	readelf --sections rm_nostatic > readelf-sections-nostatic.out
	cp linker.lds linker_nostatic.lds

wpd_nostatic: $(LIBBITCODES) $(BITCODES)
	# llvm-link $(LIBBITCODES) $(BITCODES) -o rm_linked_nostatic.bc
	# opt \
	#   --function-sections \
  #     -O3 \
  #     -loop-simplify \
  #     < rm_linked_nostatic.bc \
  #     > rm_baseline_ls_opt_nostatic.bc
	opt \
	  --function-sections \
      -load libWholeProgramDebloat.so \
      -WholeProgramDebloat \
      < rm_baseline_ls_opt_nostatic.bc \
      > rm_wpd_opt_nostatic.bc
	llc  \
	  --function-sections \
      rm_wpd_opt_nostatic.bc \
      -relocation-model=pic \
      -o rm_wpd_opt_nostatic.s
	g++ \
	  -no-pie \
	  -ffunction-sections \
	  -Wl,--verbose \
      rm_wpd_opt_nostatic.s \
      -o rm_wpd_nostatic \
      -ldebloat_rt -lm -lrt -lpcre > linker.lds
	readelf -s --wide rm_wpd_nostatic > readelf-wpd-nostatic.out
	readelf --sections rm_wpd_nostatic > readelf-sections-wpd-nostatic.out
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

wpd_custlink_nostatic: rm_wpd_opt_nostatic.s
	g++ \
	  -no-pie \
      -ffunction-sections \
      -c rm_wpd_opt_nostatic.s \
      -o rm_wpd_custlink_opt_nostatic.o
	g++ \
	  -no-pie \
	  -ffunction-sections \
      -T wpd-linker-script.lds \
      rm_wpd_custlink_opt_nostatic.o \
      -o rm_wpd_custlink_nostatic \
      -ldebloat_rt -lm -lrt -lpcre
	readelf -s --wide rm_wpd_custlink_nostatic > readelf-wpd-custlink-nostatic.out
	readelf --sections rm_wpd_custlink_nostatic > readelf-sections-wpd-custlink-nostatic.out

%.o: %.c 
	$(CC) $(HEADERS) $(CFLAGS) -c $< -o $@

#-DLIBDIR=\"/home/rudy/wo/security-bench/mkdir\"
lib/%.bc: lib/%.c
	$(CC) -DHAVE_CONFIG_H -DLIBDIR=\"/usr/local/lib\" -I. -Ilib -Ilib/glthread -g -O3 -ffunction-sections -emit-llvm -S $< -o $@

src/%.bc: src/%.c
	$(CC) -DHAVE_CONFIG_H -DLIBDIR=\"/usr/local/lib\" -I. -Isrc -Ilib -Ilib/glthread -O3 -ffunction-sections -emit-llvm -S $< -o $@

lib/libcoreutils.a: $(LIB)
	rm -f lib/libcoreutils.a
	$(AR) cq lib/libcoreutils.a $(LIB)

clean: 
	rm -f lib/*.o lib/glthread/*.bc lib/glthread/*.o lib/*.bc src/*.bc src/*.o
