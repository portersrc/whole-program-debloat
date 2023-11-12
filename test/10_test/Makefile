NUMBER = 10
NAME   = flagboy
LD     = llvm-link


CSRCDIRS =
FINAL_SOURCES:=$(shell find $(CSRCDIRS) -type f -name \*.c -print)

OBJ    = .ll
OBJS   = $(addsuffix $(OBJ),$(basename $(FINAL_SOURCES)))


# To debug, just add -g flag to this obj target
obj:
	clang \
      -c \
      -S \
      -emit-llvm \
      -fPIC \
      -ffunction-sections \
      $(NUMBER).$(NAME).c \
      -o $(NUMBER).$(NAME).ll
.PHONY: obj


bc_base: $(OBJS)
	$(LD) $^ -o $(NUMBER).$(NAME)_base.bc
bc_artd: $(OBJS)
	$(LD) $^ ics.ll -o $(NUMBER).$(NAME)_ics.bc
basebin:
	opt \
      --function-sections \
      -O3 \
      -loop-simplify \
      < $(NUMBER).$(NAME)_base.bc \
      > $(NUMBER).$(NAME)_base_opt.bc
	llc  \
      $(NUMBER).$(NAME)_base_opt.bc \
      -relocation-model=pic \
      -o $(NUMBER).$(NAME)_base_opt.s
	g++ \
      $(NUMBER).$(NAME)_base_opt.s \
      -o $(NUMBER).$(NAME)_base \
      -lm -lrt
artd_opt:
	opt \
      --function-sections \
      -O3 \
      -loop-simplify \
      < $(NUMBER).$(NAME)_ics.bc \
      > $(NUMBER).$(NAME)_ics_opt.bc
gendot:
	llvm-dis $(NUMBER).$(NAME)_ics_opt.bc
	opt -dot-cfg $(NUMBER).$(NAME)_ics_opt.ll -disable-output -enable-new-pm=0
test:
	llvm-dis $(NUMBER).$(NAME)_ics_opt.bc
	opt \
      --function-sections \
      -load libAdvancedRuntimeDebloat.so \
      -AdvancedRuntimeDebloat \
      < $(NUMBER).$(NAME)_ics_opt.bc \
      > $(NUMBER).$(NAME)_artd.bc
	llvm-dis $(NUMBER).$(NAME)_artd.bc
artd_pass_static:
	opt \
      --function-sections \
      -load libAdvancedRuntimeDebloat.so \
      -AdvancedRuntimeDebloat \
      --artd-build=static \
      < $(NUMBER).$(NAME)_ics_opt.bc \
      > $(NUMBER).$(NAME)_artd.bc
artd_pass_profile:
	opt \
      --function-sections \
      -load libAdvancedRuntimeDebloat.so \
      -AdvancedRuntimeDebloat \
      --artd-build=profile \
      < $(NUMBER).$(NAME)_ics_opt.bc \
      > $(NUMBER).$(NAME)_artd.bc
artd_pass_test_predict:
	opt \
      --function-sections \
      -load libAdvancedRuntimeDebloat.so \
      -AdvancedRuntimeDebloat \
      --artd-build=test_predict \
      < $(NUMBER).$(NAME)_ics_opt.bc \
      > $(NUMBER).$(NAME)_artd.bc
artd_pass_release:
	opt \
      --function-sections \
      -load libAdvancedRuntimeDebloat.so \
      -AdvancedRuntimeDebloat \
      --artd-build=release \
      < $(NUMBER).$(NAME)_ics_opt.bc \
      > $(NUMBER).$(NAME)_artd.bc
artd_ics_inline_pre:
	# disassemble so we can do a hacky fix to the ics symbols
	llvm-dis $(NUMBER).$(NAME)_artd.bc
artd_ics_inline_post:
	# now ingest the modified .ll file and run always-inline on it.
	opt \
      --function-sections \
      -always-inline \
      < $(NUMBER).$(NAME)_artd.ll \
      > $(NUMBER).$(NAME)_artd.bc
artd_ics_inline_static_sed:
	# these sed commands have to change if prototypes change, we add more, etc.
	sed -i \
      's/debrt_protect_indirect.2/debrt_protect_indirect/w sed_changes_0.txt' \
      $(NUMBER).$(NAME)_artd.ll
	sed -i \
      's/declare i32 @debrt_protect_indirect(i64)$$//w sed_changes_1.txt' \
      $(NUMBER).$(NAME)_artd.ll
	sed -i \
      's/declare extern_weak i32 @ics_static_map_indirect_call.5(i64)//w sed_changes_2.txt' \
      $(NUMBER).$(NAME)_artd.ll
	sed -i \
      's/declare extern_weak i32 @ics_static_wrapper_debrt_protect_loop_end.6(i32)//w sed_changes_3.txt' \
      $(NUMBER).$(NAME)_artd.ll
	sed -i \
      's/ics_static_map_indirect_call.5/ics_static_map_indirect_call/w sed_changes_4.txt' \
      $(NUMBER).$(NAME)_artd.ll
	sed -i \
      's/ics_static_wrapper_debrt_protect_loop_end.6/ics_static_wrapper_debrt_protect_loop_end/w sed_changes_5.txt' \
      $(NUMBER).$(NAME)_artd.ll
	sed -i \
      's/debrt_protect_reachable_end.1/debrt_protect_reachable_end/w sed_changes_6.txt' \
      $(NUMBER).$(NAME)_artd.ll
	sed -i \
      's/declare i32 @debrt_protect_reachable_end(i32)$$//w sed_changes_7.txt' \
      $(NUMBER).$(NAME)_artd.ll
	sed -i \
      's/debrt_protect_indirect_end.3/debrt_protect_indirect_end/w sed_changes_8.txt' \
      $(NUMBER).$(NAME)_artd.ll
	sed -i \
      's/declare i32 @debrt_protect_indirect_end(i64)$$//w sed_changes_9.txt' \
      $(NUMBER).$(NAME)_artd.ll
artd_ics_inline_profile_sed:
	# these sed commands have to change if prototypes change, we add more, etc.
	sed -i \
      's/debrt_protect_indirect.2/debrt_protect_indirect/w sed_changes_0.txt' \
      $(NUMBER).$(NAME)_artd.ll
	sed -i \
      's/declare i32 @debrt_protect_indirect(i64)$$//w sed_changes_1.txt' \
      $(NUMBER).$(NAME)_artd.ll
	sed -i \
      's/declare extern_weak i32 @debrt_profile_update_recorded_funcs.4(i32)//w sed_changes_2.txt' \
      $(NUMBER).$(NAME)_artd.ll
	#sed -i \
    #  's/debrt_profile_update_recorded_funcs.2/debrt_profile_update_recorded_funcs/w sed_changes_3.txt' \
    #  $(NUMBER).$(NAME)_artd.ll
	sed -i \
      's/declare extern_weak i32 @ics_profile_map_indirect_call.7(i64, ...)//w sed_changes_4.txt' \
      $(NUMBER).$(NAME)_artd.ll
	sed -i \
      's/ics_profile_map_indirect_call.7/ics_profile_map_indirect_call/w sed_changes_5.txt' \
      $(NUMBER).$(NAME)_artd.ll
	sed -i \
      's/declare extern_weak i32 @ics_profile_end_indirect_call.8(i64)//w sed_changes_6.txt' \
      $(NUMBER).$(NAME)_artd.ll
	sed -i \
      's/ics_profile_end_indirect_call.8/ics_profile_end_indirect_call/w sed_changes_7.txt' \
      $(NUMBER).$(NAME)_artd.ll
	sed -i \
      's/declare extern_weak i32 @ics_profile_wrapper_debrt_protect_loop_end.9(i32)//w sed_changes_8.txt' \
      $(NUMBER).$(NAME)_artd.ll
	sed -i \
      's/ics_profile_wrapper_debrt_protect_loop_end.9/ics_profile_wrapper_debrt_protect_loop_end/w sed_changes_9.txt' \
      $(NUMBER).$(NAME)_artd.ll
	sed -i \
      's/debrt_protect_reachable_end.1/debrt_protect_reachable_end/w sed_changes_10.txt' \
      $(NUMBER).$(NAME)_artd.ll
	sed -i \
      's/declare i32 @debrt_protect_reachable_end(i32)$$//w sed_changes_11.txt' \
      $(NUMBER).$(NAME)_artd.ll
	sed -i \
      's/debrt_protect_indirect_end.3/debrt_protect_indirect_end/w sed_changes_12.txt' \
      $(NUMBER).$(NAME)_artd.ll
	sed -i \
      's/declare i32 @debrt_protect_indirect_end(i64)$$//w sed_changes_13.txt' \
      $(NUMBER).$(NAME)_artd.ll
artd_ics_inline_test_predict_sed:
	# these sed commands have to change if prototypes change, we add more, etc.
	sed -i \
      's/debrt_protect_indirect.2/debrt_protect_indirect/w sed_changes_0.txt' \
      $(NUMBER).$(NAME)_artd.ll
	sed -i \
      's/declare i32 @debrt_protect_indirect(i64)$$//w sed_changes_1.txt' \
      $(NUMBER).$(NAME)_artd.ll
	sed -i \
      's/declare extern_weak i32 @ics_test_predict_map_indirect_call.10(i64, ...)//w sed_changes_2.txt' \
      $(NUMBER).$(NAME)_artd.ll
	sed -i \
      's/ics_test_predict_map_indirect_call.10/ics_test_predict_map_indirect_call/w sed_changes_3.txt' \
      $(NUMBER).$(NAME)_artd.ll
	sed -i \
      's/declare extern_weak i32 @ics_test_predict_wrapper_debrt_protect_loop_end.11(i32)//w sed_changes_4.txt' \
      $(NUMBER).$(NAME)_artd.ll
	sed -i \
      's/ics_test_predict_wrapper_debrt_protect_loop_end.11/ics_test_predict_wrapper_debrt_protect_loop_end/w sed_changes_5.txt' \
      $(NUMBER).$(NAME)_artd.ll
	sed -i \
      's/debrt_protect_reachable_end.1/debrt_protect_reachable_end/w sed_changes_6.txt' \
      $(NUMBER).$(NAME)_artd.ll
	sed -i \
      's/declare i32 @debrt_protect_reachable_end(i32)$$//w sed_changes_7.txt' \
      $(NUMBER).$(NAME)_artd.ll
	sed -i \
      's/debrt_protect_indirect_end.3/debrt_protect_indirect_end/w sed_changes_8.txt' \
      $(NUMBER).$(NAME)_artd.ll
	sed -i \
      's/declare i32 @debrt_protect_indirect_end(i64)$$//w sed_changes_9.txt' \
      $(NUMBER).$(NAME)_artd.ll
artd_ics_inline_release_sed:
	# these sed commands have to change if prototypes change, we add more, etc.
	#sed -i \
    #  's/debrt_protect_indirect.2/debrt_protect_indirect/w sed_changes_0.txt' \
    #  $(NUMBER).$(NAME)_artd.ll
	sed -i \
      's/declare i32 @debrt_protect_indirect.2(i64)$$//w sed_changes_1.txt' \
      $(NUMBER).$(NAME)_artd.ll
	sed -i \
      's/declare extern_weak i32 @ics_release_map_indirect_call.12(i64, i64, ...)//w sed_changes_2.txt' \
      $(NUMBER).$(NAME)_artd.ll
	sed -i \
      's/ics_release_map_indirect_call.12/ics_release_map_indirect_call/w sed_changes_3.txt' \
      $(NUMBER).$(NAME)_artd.ll
	sed -i \
      's/declare extern_weak i32 @ics_release_wrapper_debrt_protect_loop_end.13(i32)//w sed_changes_4.txt' \
      $(NUMBER).$(NAME)_artd.ll
	sed -i \
      's/ics_release_wrapper_debrt_protect_loop_end.13/ics_release_wrapper_debrt_protect_loop_end/w sed_changes_5.txt' \
      $(NUMBER).$(NAME)_artd.ll
	sed -i \
      's/declare extern_weak i32 @ics_release_wrapper_debrt_protect_reachable_end.14(i32)//w sed_changes_6.txt' \
      $(NUMBER).$(NAME)_artd.ll
	sed -i \
      's/ics_release_wrapper_debrt_protect_reachable_end.14/ics_release_wrapper_debrt_protect_reachable_end/w sed_changes_7.txt' \
      $(NUMBER).$(NAME)_artd.ll
	sed -i \
      's/declare extern_weak i32 @ics_release_rectify.16(i32)//w sed_changes_8.txt' \
      $(NUMBER).$(NAME)_artd.ll
	sed -i \
      's/ics_release_rectify.16/ics_release_rectify/w sed_changes_9.txt' \
      $(NUMBER).$(NAME)_artd.ll
	#sed -i \
    #  's/debrt_protect_indirect_end.3/debrt_protect_indirect_end/w sed_changes_10.txt' \
    #  $(NUMBER).$(NAME)_artd.ll
	sed -i \
      's/declare i32 @debrt_protect_indirect_end.3(i64)$$//w sed_changes_11.txt' \
      $(NUMBER).$(NAME)_artd.ll
	sed -i \
      's/declare extern_weak i32 @ics_release_wrapper_debrt_protect_indirect_end.15(i64)//w sed_changes_12.txt' \
      $(NUMBER).$(NAME)_artd.ll
	sed -i \
      's/ics_release_wrapper_debrt_protect_indirect_end.15/ics_release_wrapper_debrt_protect_indirect_end/w sed_changes_13.txt' \
      $(NUMBER).$(NAME)_artd.ll
	sed -i \
      's/declare extern_weak i32 @ics_release_trace.17(i32)//w sed_changes_14.txt' \
      $(NUMBER).$(NAME)_artd.ll
	sed -i \
      's/ics_release_trace.17/ics_release_trace/w sed_changes_15.txt' \
      $(NUMBER).$(NAME)_artd.ll
artd_ics_inline_static:  artd_ics_inline_pre artd_ics_inline_static_sed  artd_ics_inline_post
artd_ics_inline_profile: artd_ics_inline_pre artd_ics_inline_profile_sed artd_ics_inline_post
artd_ics_inline_test_predict: artd_ics_inline_pre artd_ics_inline_test_predict_sed artd_ics_inline_post
artd_ics_inline_release: artd_ics_inline_pre artd_ics_inline_release_sed artd_ics_inline_post
artd_assemble:
	llc  \
      --function-sections \
      $(NUMBER).$(NAME)_artd.bc \
      -relocation-model=pic \
      -o $(NUMBER).$(NAME)_artd.s
	# Produce a default linker script.
	# FIXME Is there an easier way to do this than building the entire binary here?
	g++ \
      -ffunction-sections \
      -Wl,--verbose \
      $(NUMBER).$(NAME)_artd.s \
      -o $(NUMBER).$(NAME)_artd_tmp \
      -ldebloat_rt -lm -lrt > linker.lds
	rm $(NUMBER).$(NAME)_artd_tmp
	# Create a custom linker script
	python3 linker.py .
	g++ \
      -ffunction-sections \
      -c $(NUMBER).$(NAME)_artd.s \
      -o $(NUMBER).$(NAME)_artd.o
artd_bin_static:
	g++ \
      -ffunction-sections \
      -T artd-linker-script.lds \
      $(NUMBER).$(NAME)_artd.o \
      -o $(NUMBER).$(NAME)_artd_static \
      -ldebloat_rt -lm -lrt
artd_bin_profile:
	g++ \
      -ffunction-sections \
      -T artd-linker-script.lds \
      $(NUMBER).$(NAME)_artd.o \
      -o $(NUMBER).$(NAME)_artd_profile \
      -ldebloat_rt -lm -lrt
artd_bin_test_predict:
	g++ \
      -ffunction-sections \
      -T artd-linker-script.lds \
      $(NUMBER).$(NAME)_artd.o \
      -o $(NUMBER).$(NAME)_artd_test_predict \
      -ldebloat_rt -lm -lrt
artd_bin_release:
	g++ \
      -ffunction-sections \
      -T artd-linker-script.lds \
      $(NUMBER).$(NAME)_artd.o \
      -o $(NUMBER).$(NAME)_artd_release \
      -ldebloat_rt -lm -lrt
baseline:     bc_base basebin
artd_static:  bc_artd artd_opt artd_pass_static  artd_ics_inline_static  artd_assemble artd_bin_static
artd_profile: bc_artd artd_opt artd_pass_profile artd_ics_inline_profile artd_assemble artd_bin_profile
artd_test_predict: bc_artd artd_opt artd_pass_test_predict artd_ics_inline_test_predict artd_assemble artd_bin_test_predict
artd_release: bc_artd artd_opt artd_pass_release artd_ics_inline_release artd_assemble artd_bin_release



clean:
	rm -f \
      *.bc \
      *.s \
      a.out \
      *.lds \
      readelf*.out \
      artd*.txt \
      artd*.out \
      debrt.out \
      debrt*.out \
      sed_changes*.txt \
      $(NUMBER).$(NAME)_artd_profile \
      $(NUMBER).$(NAME)_artd.o \
      $(NUMBER).$(NAME)_artd.ll \
      $(NUMBER).$(NAME).ll \
      func-set-id-to-funcs.out \
      func-set-id-to-complements.out \
      base.out \
      training-data.out \
      func-set-id-deck-root-pairs.out \
      10.flagboy_artd_release \
      10.flagboy_artd_static \
      10.flagboy_artd_test_predict \
      10.flagboy_base
.PHONY: clean
