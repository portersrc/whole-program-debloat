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
      -lm -lrt -lpcre > linker.lds
	readelf -s --wide mkdir_nostatic > readelf-nostatic.out
	readelf --sections mkdir_nostatic > readelf-sections-nostatic.out
	cp linker.lds linker_nostatic.lds

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

%.o: %.c 
	$(CC) $(HEADERS) $(CFLAGS) -c $< -o $@


lib/%.bc: lib/%.c
	$(CC) -DLIBDIR=\"/usr/local/lib\" -I. -Ilib -Ilib/glthread -g -O3 -ffunction-sections -emit-llvm -S $< -o $@

src/%.bc: src/%.c
	$(CC) -DLIBDIR=\"/usr/local/lib\" -I. -Isrc -Ilib -Ilib/glthread -O3 -ffunction-sections -emit-llvm -S $< -o $@

lib/libcoreutils.a: $(LIB)
	rm -f lib/libcoreutils.a
	$(AR) cq lib/libcoreutils.a $(LIB)

clean: 
	rm -f lib/*.o lib/glthread/*.bc lib/glthread/*.o lib/*.bc src/*.bc src/*.o
