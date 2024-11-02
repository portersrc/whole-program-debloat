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

all: base_ls wpd wpd_custlink

base_ls: $(LIBBITCODES) $(BITCODES)
	llvm-link $(LIBBITCODES) $(BITCODES) -o gzip_linked.bc
	opt \
	  --function-sections \
      -O3 \
      -loop-simplify \
      < gzip_linked.bc \
      > gzip_baseline_ls_opt.bc
	llc  \
	  --function-sections \
      gzip_baseline_ls_opt.bc \
      -relocation-model=pic \
      -o gzip_opt.s
	g++ \
	  -no-pie \
	  -ffunction-sections \
	  -Wl,--verbose \
      gzip_opt.s \
      -o gzip \
      -lm -lrt -lpcre

wpd: $(LIBBITCODES) $(BITCODES)
	# llvm-link $(LIBBITCODES) $(BITCODES) -o gzip_linked.bc
	# opt \
	#   --function-sections \
  #     -O3 \
  #     -loop-simplify \
  #     < gzip_linked.bc \
  #     > gzip_baseline_ls_opt.bc
	opt \
	  --function-sections \
      -load libWholeProgramDebloat.so \
      -WholeProgramDebloat \
      < gzip_baseline_ls_opt.bc \
      > gzip_wpd_opt.bc
	llc  \
	  --function-sections \
      gzip_wpd_opt.bc \
      -relocation-model=pic \
      -o gzip_wpd_opt.s
	g++ \
	  -no-pie \
	  -ffunction-sections \
	  -Wl,--verbose \
      gzip_wpd_opt.s \
      -o gzip_wpd \
      -ldebloat_rt -lm -lrt -lpcre > linker.lds
	readelf -s --wide gzip_wpd > readelf-wpd.out
	readelf --sections gzip_wpd > readelf-sections-wpd.out
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

wpd_custlink: gzip_wpd_opt.s
	g++ \
	  -no-pie \
      -ffunction-sections \
      -c gzip_wpd_opt.s \
      -o gzip_wpd_custlink_opt.o
	g++ \
	  -no-pie \
	  -ffunction-sections \
      -T wpd-linker-script.lds \
      gzip_wpd_custlink_opt.o \
      -o gzip_wpd_custlink \
      -ldebloat_rt -lm -lrt -lpcre
	readelf -s --wide gzip_wpd_custlink > readelf-wpd-custlink.out
	readelf --sections gzip_wpd_custlink > readelf-sections-wpd-custlink.out

wpd_ics: $(LIBBITCODES) $(BITCODES)
	llvm-link $(LIBBITCODES) $(BITCODES) ics.ll -o gzip_linked.bc
	opt \
	  --function-sections \
	    -O3 \
	    -loop-simplify \
	    < gzip_linked.bc \
	    > gzip_baseline_ls_opt.bc
	opt \
	  --function-sections \
      -load libWholeProgramDebloat.so \
      -WholeProgramDebloat \
      --enable-indirect-call-sinking=true \
      < gzip_baseline_ls_opt.bc \
      > gzip_wpd_ics_opt.bc
	# disassemble so we can do a hacky fix to the ics symbols
	llvm-dis gzip_wpd_ics_opt.bc
	sed -i \
      's/declare extern_weak i32 @ics_map_indirect_call.2(i64)//w sed_changes_0.txt' \
      gzip_wpd_ics_opt.ll
	sed -i \
      's/declare extern_weak i32 @ics_wrapper_debrt_protect_loop_end.3(i32)//w sed_changes_1.txt' \
      gzip_wpd_ics_opt.ll
	sed -i \
      's/ics_map_indirect_call.2/ics_map_indirect_call/w sed_changes_2.txt' \
      gzip_wpd_ics_opt.ll
	sed -i \
      's/ics_wrapper_debrt_protect_loop_end.3/ics_wrapper_debrt_protect_loop_end/w sed_changes_3.txt' \
      gzip_wpd_ics_opt.ll
	sed -i \
      's/debrt_protect_indirect.1/debrt_protect_indirect/w sed_changes_5.txt' \
      gzip_wpd_ics_opt.ll
	sed -i \
      's/declare i32 @debrt_protect_indirect(i64)$$//w sed_changes_4.txt' \
      gzip_wpd_ics_opt.ll
	# now ingest the modified .ll file and run always-inline on it.
	opt \
	 --function-sections \
     -always-inline \
     < gzip_wpd_ics_opt.ll \
     > gzip_wpd_ics_opt.bc
	llc  \
	  --function-sections \
      gzip_wpd_ics_opt.bc \
      -relocation-model=pic \
      -o gzip_wpd_ics_opt.s
	g++ \
	  -ffunction-sections \
	  -Wl,--verbose \
      gzip_wpd_ics_opt.s \
      -o gzip_wpd_ics \
      -ldebloat_rt -lm -lrt > linker.lds
	readelf -s --wide gzip_wpd_ics > readelf.out
	readelf --sections gzip_wpd_ics > readelf-sections.out
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

wpd_custlink_ics: gzip_wpd_ics_opt.s
	g++ \
      -ffunction-sections \
      -c gzip_wpd_ics_opt.s \
      -o gzip_wpd_custlink_ics_opt.o
	g++ \
	  -ffunction-sections \
      -T wpd-linker-script.lds \
      gzip_wpd_custlink_ics_opt.o \
      -o gzip_wpd_custlink_ics \
      -ldebloat_rt -lm -lrt
	readelf -s --wide gzip_wpd_custlink_ics > readelf.out
	readelf --sections gzip_wpd_custlink_ics > readelf-sections.out
	cp readelf.out readelf-custlink-ics.out
	cp readelf-sections.out readelf-sections-custlink-ics.out

artd_opt: $(LIBBITCODES) $(BITCODES)
	llvm-link $(LIBBITCODES) $(BITCODES) ics.ll -o gzip_ics_linked.bc
	opt \
      --function-sections \
      -O3 \
      -loop-simplify \
      < gzip_ics_linked.bc \
      > gzip_ics_opt.bc
artd_pass_profile:
	opt \
      --function-sections \
      -load libAdvancedRuntimeDebloat.so \
      -AdvancedRuntimeDebloat \
      --artd-build=profile \
      < gzip_ics_opt.bc \
      > gzip_artd.bc
artd_pass_test_predict:
	opt \
      --function-sections \
      -load libAdvancedRuntimeDebloat.so \
      -AdvancedRuntimeDebloat \
      --artd-build=test_predict \
      < gzip_ics_opt.bc \
      > gzip_artd.bc
artd_pass_release:
	opt \
      --function-sections \
      -load libAdvancedRuntimeDebloat.so \
      -AdvancedRuntimeDebloat \
      --artd-build=release \
      < gzip_ics_opt.bc \
      > gzip_artd.bc
artd_ics_inline:
	# disassemble before inlining
	llvm-dis gzip_artd.bc -o gzip_artd-preinline.ll
	# inline
	opt \
      --function-sections \
      -always-inline \
      < gzip_artd-preinline.ll \
      > gzip_artd.bc
	# disassemble after inlining
	llvm-dis gzip_artd.bc -o gzip_artd-postinline.ll
artd_assemble:
	llc  \
      --function-sections \
      gzip_artd.bc \
      -relocation-model=pic \
      -o gzip_artd.s
	# Produce a default linker script.
	# FIXME Is there an easier way to do this than building the entire binary here?
	g++ \
      -ffunction-sections \
      -Wl,--verbose \
      gzip_artd.s \
      -o gzip_artd_tmp \
      -ldebloat_rt -lm -lrt > linker.lds
	rm gzip_artd_tmp
	# Create a custom linker script
	python3 linker.py .
	g++ \
      -ffunction-sections \
      -c gzip_artd.s \
      -o gzip_artd.o
artd_bin_profile:
	g++ \
      -ffunction-sections \
      -T artd-linker-script.lds \
      gzip_artd.o \
      -o gzip_artd_profile \
      -ldebloat_rt -lm -lrt
artd_bin_test_predict:
	g++ \
      -ffunction-sections \
      -T artd-linker-script.lds \
      gzip_artd.o \
      -o gzip_artd_test_predict \
      -ldebloat_rt -lm -lrt
artd_bin_release:
	g++ \
      -ffunction-sections \
      -T artd-linker-script.lds \
      gzip_artd.o \
      -o gzip_artd_release \
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
      < gzip_ics_opt.bc \
      > gzip_datalog.bc
	  
%.o: %.c 
	$(CC) -DSTDC_HEADERS=1 -DHAVE_UNISTD_H=1 -DDIRENT=1 -I. -g -O3 -fPIC -c $< -o $@

%.bc: %.c
	$(CC) -DSTDC_HEADERS=1 -DHAVE_UNISTD_H=1 -DDIRENT=1 -I. -g -O3 -fPIC -ffunction-sections -emit-llvm -S $< -o $@

clean: 
	rm -f lib/*.o lib/glthread/*.bc lib/glthread/*.o lib/*.bc src/*.bc src/*.o
