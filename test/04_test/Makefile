PROGNAME = main

obj:
	clang \
      -c \
      -S \
      -emit-llvm \
      -fPIC \
      -ffunction-sections \
      $(PROGNAME).c \
      -o $(PROGNAME).bc
#bc_base:
#	llvm-link $(PROGNAME).bc -o $(PROGNAME)_base.bc
bc_artd:
	llvm-link $(PROGNAME).bc ics.ll -o $(PROGNAME)_ics.bc
#base:
#	opt \
#      --function-sections \
#      -O3 \
#      -loop-simplify \
#      < $(PROGNAME)_base.bc \
#      > $(PROGNAME)_base_opt.bc
#	llc  \
#      $(PROGNAME)_base_opt.bc \
#      -relocation-model=pic \
#      -o $(PROGNAME)_base_opt.s
#	g++ \
#      $(PROGNAME)_base_opt.s \
#      -o $(PROGNAME)_base \
#      -lm -lrt
#artd_opt:
#	opt \
#      --function-sections \
#      -O3 \
#      -loop-simplify \
#      < $(PROGNAME)_ics.bc \
#      > $(PROGNAME)_ics_opt.bc
artd_opt_stub: # just loop-simplify but dont do O3
	opt \
      --function-sections \
      -loop-simplify \
      < $(PROGNAME)_ics.bc \
      > $(PROGNAME)_ics_opt.bc
#hack:
#	opt \
#      --function-sections \
#      -load libAdvancedRuntimeDebloat.so \
#      -AdvancedRuntimeDebloat \
#      --artd-build=profile \
#      < $(PROGNAME)_ics_opt.bc \
#      > $(PROGNAME)_artd.bc
#artd_pass:
#	opt \
#      --function-sections \
#      -load libAdvancedRuntimeDebloat.so \
#      -AdvancedRuntimeDebloat \
#      < $(PROGNAME)_ics_opt.bc \
#      > $(PROGNAME)_artd.bc
artd_pass_profile:
	opt \
      --function-sections \
      -load libAdvancedRuntimeDebloat.so \
      -AdvancedRuntimeDebloat \
      --artd-build=profile \
      < $(PROGNAME)_ics_opt.bc \
      > $(PROGNAME)_artd.bc
artd_assemble:
	# disassemble so we can do a hacky fix to the ics symbols
	llvm-dis $(PROGNAME)_artd.bc
	# this sed changed due to ics-map-indirect-call prototype change.
	sed -i \
      's/declare extern_weak i32 @ics_map_indirect_call.2(i64, ...)//w sed_changes_0.txt' \
      $(PROGNAME)_artd.ll
	sed -i \
      's/declare extern_weak i32 @ics_wrapper_debrt_protect_loop_end.3(i32)//w sed_changes_1.txt' \
      $(PROGNAME)_artd.ll
	sed -i \
      's/ics_map_indirect_call.2/ics_map_indirect_call/w sed_changes_2.txt' \
      $(PROGNAME)_artd.ll
	sed -i \
      's/ics_wrapper_debrt_protect_loop_end.3/ics_wrapper_debrt_protect_loop_end/w sed_changes_3.txt' \
      $(PROGNAME)_artd.ll
	sed -i \
      's/debrt_protect_indirect.1/debrt_protect_indirect/w sed_changes_5.txt' \
      $(PROGNAME)_artd.ll
	sed -i \
      's/declare i32 @debrt_protect_indirect(i64)$$//w sed_changes_4.txt' \
      $(PROGNAME)_artd.ll
	# now ingest the modified .ll file and run always-inline on it.
	opt \
      --function-sections \
      -always-inline \
      < $(PROGNAME)_artd.ll \
      > $(PROGNAME)_artd.bc
	llc  \
      --function-sections \
      $(PROGNAME)_artd.bc \
      -relocation-model=pic \
      -o $(PROGNAME)_artd.s
	# Produce a default linker script.
	# FIXME Is there an easier way to do this than building the entire binary here?
	g++ \
      -ffunction-sections \
      -Wl,--verbose \
      $(PROGNAME)_artd.s \
      -o $(PROGNAME)_artd_tmp \
      -ldebloat_rt -lm -lrt > linker.lds
	rm $(PROGNAME)_artd_tmp
	# Create a custom linker script
	python3 linker.py .
	g++ \
      -ffunction-sections \
      -c $(PROGNAME)_artd.s \
      -o $(PROGNAME)_artd.o
#artd_bin:
#	g++ \
#      -ffunction-sections \
#      -T artd-linker-script.lds \
#      $(PROGNAME)_artd.o \
#      -o $(PROGNAME)_artd \
#      -ldebloat_rt -lm -lrt
artd_bin_profile:
	g++ \
      -ffunction-sections \
      -T artd-linker-script.lds \
      $(PROGNAME)_artd.o \
      -o $(PROGNAME)_artd_profile \
      -ldebloat_rt -lm -lrt
#artd:       artd_opt   artd_pass         artd_assemble artd_bin
#artd_profile: artd_opt artd_pass_profile artd_assemble artd_bin_profile
artd_profile: obj bc_artd artd_opt_stub artd_pass_profile artd_assemble artd_bin_profile


clean:
	rm -f *.bc *.s a.out *.lds readelf*.out artd*.txt artd*.out debrt.out debrt*.out sed_changes*.txt $(PROGNAME)_artd_profile $(PROGNAME)_artd.o $(PROGNAME)_artd.ll
.PHONY: clean


