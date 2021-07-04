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
# src/tar-core.bc \
# src/chmod.bc \
# src/tar.bc \
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
# 	llvm-link $(BITCODES) -o tar_linked_static.bc
# 	opt \
# 	  --function-sections \
#       -O3 \
#       -loop-simplify \
#       < tar_linked_static.bc \
#       > tar_baseline_ls_opt_static.bc
# 	llc  \
# 	  --function-sections \
#       tar_baseline_ls_opt_static.bc \
#       -relocation-model=pic \
#       -o tar_opt_static.s
# 	g++ \
# 	  -no-pie \
# 	  -ffunction-sections \
# 	  -Wl,--verbose \
#       tar_opt_static.s \
#       -o tar_static \
#       -lm -lrt -Llib -lgreputils > linker.lds
# 	readelf -s --wide tar_static > readelf-static.out
# 	readelf --sections tar_static > readelf-sections-static.out
# 	cp linker.lds linker_static.lds

# wpd_static: lib/libcoreutils.a $(BITCODES)
# 	llvm-link $(BITCODES) -o tar_linked_static.bc
# 	opt \
# 	  --function-sections \
#       -O3 \
#       -loop-simplify \
#       < tar_linked_static.bc \
#       > tar_baseline_ls_opt_static.bc
# 	opt \
# 	  --function-sections \
#       -load libWholeProgramDebloat.so \
#       -WholeProgramDebloat \
#       < tar_baseline_ls_opt_static.bc \
#       > tar_wpd_opt_static.bc
# 	llc  \
# 	  --function-sections \
#       tar_wpd_opt_static.bc \
#       -relocation-model=pic \
#       -o tar_wpd_opt_static.s
# 	g++ \
# 	  -no-pie \
# 	  -ffunction-sections \
# 	  -Wl,--verbose \
#       tar_wpd_opt_static.s \
#       -o tar_wpd_static \
#       -ldebloat_rt -lm -lrt -Llib -lgreputil > linker.lds
# 	readelf -s --wide tar_wpd_static > readelf-wpd-static.out
# 	readelf --sections tar_wpd_static > readelf-sections-wpd-static.out
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

# wpd_custlink_static: lib/libcoreutils.a tar_wpd_opt_static.s
# 	g++ \
# 	  -no-pie \
#       -ffunction-sections \
#       -c tar_wpd_opt_static.s \
#       -o tar_wpd_custlink_opt_static.o
# 	g++ \
# 	  -no-pie \
# 	  -ffunction-sections \
#       -T wpd-linker-script.lds \
#       tar_wpd_custlink_opt_static.o \
#       -o tar_wpd_custlink_static \
#       -ldebloat_rt -lm -lrt -Llib -lgreputil
# 	readelf -s --wide tar_wpd_custlink_static > readelf-wpd-custlink-static.out
# 	readelf --sections tar_wpd_custlink_static > readelf-sections-wpd-custlink-static.out

base_ls_nostatic: $(LIBBITCODES) $(BITCODES)
	python3 tar_symbol_duplicate.py
	llvm-link $(LIBBITCODES) $(BITCODES) -o tar_linked_nostatic.bc
	opt \
	  --function-sections \
      -O3 \
      -loop-simplify \
      < tar_linked_nostatic.bc \
      > tar_baseline_ls_opt_nostatic.bc
	llc  \
	  --function-sections \
      tar_baseline_ls_opt_nostatic.bc \
      -relocation-model=pic \
      -o tar_opt_nostatic.s
	g++ \
	  -no-pie \
	  -ffunction-sections \
	  -Wl,--verbose \
      tar_opt_nostatic.s \
      -o tar_nostatic \
      -lm -lrt -lpcre > linker.lds
	readelf -s --wide tar_nostatic > readelf-nostatic.out
	readelf --sections tar_nostatic > readelf-sections-nostatic.out
	cp linker.lds linker_nostatic.lds

wpd_nostatic: $(LIBBITCODES) $(BITCODES)
	python3 tar_symbol_duplicate.py
	# llvm-link $(LIBBITCODES) $(BITCODES) -o tar_linked_nostatic.bc
	# opt \
	#   --function-sections \
  #     -O3 \
  #     -loop-simplify \
  #     < tar_linked_nostatic.bc \
  #     > tar_baseline_ls_opt_nostatic.bc
	opt \
	  --function-sections \
      -load libWholeProgramDebloat.so \
      -WholeProgramDebloat \
      < tar_baseline_ls_opt_nostatic.bc \
      > tar_wpd_opt_nostatic.bc
	llc  \
	  --function-sections \
      tar_wpd_opt_nostatic.bc \
      -relocation-model=pic \
      -o tar_wpd_opt_nostatic.s
	g++ \
	  -no-pie \
	  -ffunction-sections \
	  -Wl,--verbose \
      tar_wpd_opt_nostatic.s \
      -o tar_wpd_nostatic \
      -ldebloat_rt -lm -lrt -lpcre > linker.lds
	readelf -s --wide tar_wpd_nostatic > readelf-wpd-nostatic.out
	readelf --sections tar_wpd_nostatic > readelf-sections-wpd-nostatic.out
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

wpd_custlink_nostatic: tar_wpd_opt_nostatic.s
	g++ \
	  -no-pie \
      -ffunction-sections \
      -c tar_wpd_opt_nostatic.s \
      -o tar_wpd_custlink_opt_nostatic.o
	g++ \
	  -no-pie \
	  -ffunction-sections \
      -T wpd-linker-script.lds \
      tar_wpd_custlink_opt_nostatic.o \
      -o tar_wpd_custlink_nostatic \
      -ldebloat_rt -lm -lrt -lpcre
	readelf -s --wide tar_wpd_custlink_nostatic > readelf-wpd-custlink-nostatic.out
	readelf --sections tar_wpd_custlink_nostatic > readelf-sections-wpd-custlink-nostatic.out

%.o: %.c 
	$(CC) $(HEADERS) $(CFLAGS) -c $< -o $@


lib/%.bc: lib/%.c
	$(CC) -DHAVE_CONFIG_H -I. -Ilib -Ilib/glthread -g -O3 -ffunction-sections -emit-llvm -S $< -o $@

src/%.bc: src/%.c
	$(CC) -DHAVE_CONFIG_H -I. -Isrc -Ilib -Ilib/glthread -O3 -ffunction-sections -emit-llvm -S $< -o $@

lib/libcoreutils.a: $(LIB)
	rm -f lib/libcoreutils.a
	$(AR) cq lib/libcoreutils.a $(LIB)

clean: 
	rm -f lib/*.o lib/glthread/*.bc lib/glthread/*.o lib/*.bc src/*.bc src/*.o
