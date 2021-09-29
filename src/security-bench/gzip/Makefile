SHELL = /bin/sh

LOADLIBES = $(LIBS)

TAR = tar

SRCS = gzip.c zip.c deflate.c trees.c bits.c unzip.c inflate.c util.c crypt.c\
       lzw.c unlzw.c unpack.c unlzh.c getopt.c 

OBJS = gzip$O zip$O deflate$O trees$O bits$O unzip$O inflate$O util$O \
       crypt$O lzw$O unlzw$O unpack$O unlzh$O getopt$O $(OBJA)

HDRS = gzip.h lzw.h tailor.h revision.h crypt.h getopt.h

VERSION = 1.2.4
VERSADD = 
VPATH=. $(RESDIR)

# To assist in cross-compiling
CC=clang
LDFLAGS= -Wl,-s $(VERSADD)
  
CFLAGS = -fPIC -O3 -ffunction-sections -g -c
CFLAGSL = -O3 -ffunction-sections -emit-llvm -S
HEADERS = -I.
LIBS = 


LIB= #Fill with object files of LIBBITCODES libcoreutils.a

LIBBITCODES=#EMpty

BITCODES= gzip.bc \
zip.bc \
deflate.bc \
trees.bc \
bits.bc \
unzip.bc \
inflate.bc \
util.bc \
crypt.bc\
lzw.bc \
unlzw.bc \
unpack.bc \
unlzh.bc \
getopt.bc 

.SUFFIXES:
.SUFFIXES: .c .o .bc

all: base_ls_nostatic wpd_nostatic wpd_custlink_nostatic

base_ls_nostatic: $(LIBBITCODES) $(BITCODES)
	llvm-link $(LIBBITCODES) $(BITCODES) -o gzip_linked_nostatic.bc
	opt \
	  --function-sections \
      -O3 \
      -loop-simplify \
      < gzip_linked_nostatic.bc \
      > gzip_baseline_ls_opt_nostatic.bc
	llc  \
	  --function-sections \
      gzip_baseline_ls_opt_nostatic.bc \
      -relocation-model=pic \
      -o gzip_opt_nostatic.s
	g++ \
	  -no-pie \
	  -ffunction-sections \
	  -Wl,--verbose \
      gzip_opt_nostatic.s \
      -o gzip_nostatic \
      -lm -lrt -lpcre

wpd_nostatic: $(LIBBITCODES) $(BITCODES)
	# llvm-link $(LIBBITCODES) $(BITCODES) -o gzip_linked_nostatic.bc
	# opt \
	#   --function-sections \
  #     -O3 \
  #     -loop-simplify \
  #     < gzip_linked_nostatic.bc \
  #     > gzip_baseline_ls_opt_nostatic.bc
	opt \
	  --function-sections \
      -load libWholeProgramDebloat.so \
      -WholeProgramDebloat \
      < gzip_baseline_ls_opt_nostatic.bc \
      > gzip_wpd_opt_nostatic.bc
	llc  \
	  --function-sections \
      gzip_wpd_opt_nostatic.bc \
      -relocation-model=pic \
      -o gzip_wpd_opt_nostatic.s
	g++ \
	  -no-pie \
	  -ffunction-sections \
	  -Wl,--verbose \
      gzip_wpd_opt_nostatic.s \
      -o gzip_wpd_nostatic \
      -ldebloat_rt -lm -lrt -lpcre > linker.lds
	readelf -s --wide gzip_wpd_nostatic > readelf-wpd-nostatic.out
	readelf --sections gzip_wpd_nostatic > readelf-sections-wpd-nostatic.out
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

wpd_custlink_nostatic: gzip_wpd_opt_nostatic.s
	g++ \
	  -no-pie \
      -ffunction-sections \
      -c gzip_wpd_opt_nostatic.s \
      -o gzip_wpd_custlink_opt_nostatic.o
	g++ \
	  -no-pie \
	  -ffunction-sections \
      -T wpd-linker-script.lds \
      gzip_wpd_custlink_opt_nostatic.o \
      -o gzip_wpd_custlink_nostatic \
      -ldebloat_rt -lm -lrt -lpcre
	readelf -s --wide gzip_wpd_custlink_nostatic > readelf-wpd-custlink-nostatic.out
	readelf --sections gzip_wpd_custlink_nostatic > readelf-sections-wpd-custlink-nostatic.out

wpd_ics_nostatic: $(LIBBITCODES) $(BITCODES)
	llvm-link $(LIBBITCODES) $(BITCODES) ics.ll -o gzip_linked_nostatic.bc
	opt \
	  --function-sections \
	    -O3 \
	    -loop-simplify \
	    < gzip_linked_nostatic.bc \
	    > gzip_baseline_ls_opt_nostatic.bc
	opt \
	  --function-sections \
      -load libWholeProgramDebloat.so \
      -WholeProgramDebloat \
      --enable-indirect-call-sinking=true \
      < gzip_baseline_ls_opt_nostatic.bc \
      > gzip_wpd_ics_opt_nostatic.bc
	# disassemble so we can do a hacky fix to the ics symbols
	llvm-dis gzip_wpd_ics_opt_nostatic.bc
	sed -i \
      's/declare extern_weak i32 @ics_map_indirect_call.2(i64)//w sed_changes_0.txt' \
      gzip_wpd_ics_opt_nostatic.ll
	sed -i \
      's/declare extern_weak i32 @ics_wrapper_debrt_protect_loop_end.3(i32)//w sed_changes_1.txt' \
      gzip_wpd_ics_opt_nostatic.ll
	sed -i \
      's/ics_map_indirect_call.2/ics_map_indirect_call/w sed_changes_2.txt' \
      gzip_wpd_ics_opt_nostatic.ll
	sed -i \
      's/ics_wrapper_debrt_protect_loop_end.3/ics_wrapper_debrt_protect_loop_end/w sed_changes_3.txt' \
      gzip_wpd_ics_opt_nostatic.ll
	sed -i \
      's/debrt_protect_indirect.1/debrt_protect_indirect/w sed_changes_5.txt' \
      gzip_wpd_ics_opt_nostatic.ll
	sed -i \
      's/declare i32 @debrt_protect_indirect(i64)$$//w sed_changes_4.txt' \
      gzip_wpd_ics_opt_nostatic.ll
	# now ingest the modified .ll file and run always-inline on it.
	opt \
	 --function-sections \
     -always-inline \
     < gzip_wpd_ics_opt_nostatic.ll \
     > gzip_wpd_ics_opt_nostatic.bc
	llc  \
	  --function-sections \
      gzip_wpd_ics_opt_nostatic.bc \
      -relocation-model=pic \
      -o gzip_wpd_ics_opt_nostatic.s
	g++ \
	  -ffunction-sections \
	  -Wl,--verbose \
      gzip_wpd_ics_opt_nostatic.s \
      -o gzip_wpd_ics_nostatic \
      -ldebloat_rt -lm -lrt > linker.lds
	readelf -s --wide gzip_wpd_ics_nostatic > readelf.out
	readelf --sections gzip_wpd_ics_nostatic > readelf-sections.out
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

wpd_custlink_ics_nostatic: gzip_wpd_ics_opt_nostatic.s
	g++ \
      -ffunction-sections \
      -c gzip_wpd_ics_opt_nostatic.s \
      -o gzip_wpd_custlink_ics_opt_nostatic.o
	g++ \
	  -ffunction-sections \
      -T wpd-linker-script.lds \
      gzip_wpd_custlink_ics_opt_nostatic.o \
      -o gzip_wpd_custlink_ics_nostatic \
      -ldebloat_rt -lm -lrt
	readelf -s --wide gzip_wpd_custlink_ics_nostatic > readelf.out
	readelf --sections gzip_wpd_custlink_ics_nostatic > readelf-sections.out
	cp readelf.out readelf-custlink-ics-nostatic.out
	cp readelf-sections.out readelf-sections-custlink-ics-nostatic.out

%.o: %.c 
	$(CC) -DSTDC_HEADERS=1 -DHAVE_UNISTD_H=1 -DDIRENT=1 -I. -g -O3 -fPIC -c $< -o $@

%.bc: %.c
	$(CC) -DSTDC_HEADERS=1 -DHAVE_UNISTD_H=1 -DDIRENT=1 -I. -g -O3 -fPIC -ffunction-sections -emit-llvm -S $< -o $@

clean: 
	rm -f lib/*.o lib/glthread/*.bc lib/glthread/*.o lib/*.bc src/*.bc src/*.o
