; ModuleID = 'ics.cpp'
source_filename = "ics.cpp"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.__va_list_tag = type { i32, i32, i8*, i8* }

@cached_fp_addrs = global [1048576 x i64] zeroinitializer, align 16
@cached_fp_addrs_idx = global i64 0, align 8
@indirect_call_static_vararg_stack = global [512 x i64] zeroinitializer, align 16
@.str = private unnamed_addr constant [10 x i8] c"argc >= 2\00", align 1
@.str.1 = private unnamed_addr constant [8 x i8] c"ics.cpp\00", align 1
@__PRETTY_FUNCTION__.ics_map_indirect_call = private unnamed_addr constant [42 x i8] c"int ics_map_indirect_call(long long, ...)\00", align 1
@.str.2 = private unnamed_addr constant [50 x i8] c"(argc-1) <= INDIRECT_CALL_STATIC_VARARG_STATIC_SZ\00", align 1

; Function Attrs: alwaysinline uwtable
define i32 @ics_map_indirect_call(i64 %argc, ...) #0 {
entry:
  %retval = alloca i32, align 4
  %argc.addr = alloca i64, align 8
  %x = alloca i64, align 8
  %i = alloca i32, align 4
  %ap = alloca [1 x %struct.__va_list_tag], align 16
  %fp_addr = alloca i64, align 8
  store i64 %argc, i64* %argc.addr, align 8
  %arraydecay = getelementptr inbounds [1 x %struct.__va_list_tag], [1 x %struct.__va_list_tag]* %ap, i64 0, i64 0
  %arraydecay1 = bitcast %struct.__va_list_tag* %arraydecay to i8*
  call void @llvm.va_start(i8* %arraydecay1)
  %arraydecay2 = getelementptr inbounds [1 x %struct.__va_list_tag], [1 x %struct.__va_list_tag]* %ap, i64 0, i64 0
  %gp_offset_p = getelementptr inbounds %struct.__va_list_tag, %struct.__va_list_tag* %arraydecay2, i32 0, i32 0
  %gp_offset = load i32, i32* %gp_offset_p, align 16
  %fits_in_gp = icmp ule i32 %gp_offset, 40
  br i1 %fits_in_gp, label %vaarg.in_reg, label %vaarg.in_mem

vaarg.in_reg:                                     ; preds = %entry
  %0 = getelementptr inbounds %struct.__va_list_tag, %struct.__va_list_tag* %arraydecay2, i32 0, i32 3
  %reg_save_area = load i8*, i8** %0, align 16
  %1 = getelementptr i8, i8* %reg_save_area, i32 %gp_offset
  %2 = bitcast i8* %1 to i64*
  %3 = add i32 %gp_offset, 8
  store i32 %3, i32* %gp_offset_p, align 16
  br label %vaarg.end

vaarg.in_mem:                                     ; preds = %entry
  %overflow_arg_area_p = getelementptr inbounds %struct.__va_list_tag, %struct.__va_list_tag* %arraydecay2, i32 0, i32 2
  %overflow_arg_area = load i8*, i8** %overflow_arg_area_p, align 8
  %4 = bitcast i8* %overflow_arg_area to i64*
  %overflow_arg_area.next = getelementptr i8, i8* %overflow_arg_area, i32 8
  store i8* %overflow_arg_area.next, i8** %overflow_arg_area_p, align 8
  br label %vaarg.end

vaarg.end:                                        ; preds = %vaarg.in_mem, %vaarg.in_reg
  %vaarg.addr = phi i64* [ %2, %vaarg.in_reg ], [ %4, %vaarg.in_mem ]
  %5 = load i64, i64* %vaarg.addr, align 8
  store i64 %5, i64* %fp_addr, align 8
  %6 = load i64, i64* %fp_addr, align 8
  store i64 %6, i64* %x, align 8
  %7 = load i64, i64* %x, align 8
  %8 = load i64, i64* %x, align 8
  %shr = ashr i64 %8, 30
  %xor = xor i64 %7, %shr
  %mul = mul i64 %xor, -4658895280553007687
  store i64 %mul, i64* %x, align 8
  %9 = load i64, i64* %x, align 8
  %10 = load i64, i64* %x, align 8
  %shr3 = ashr i64 %10, 27
  %xor4 = xor i64 %9, %shr3
  %mul5 = mul i64 %xor4, -7723592293110705685
  store i64 %mul5, i64* %x, align 8
  %11 = load i64, i64* %x, align 8
  %12 = load i64, i64* %x, align 8
  %shr6 = ashr i64 %12, 31
  %xor7 = xor i64 %11, %shr6
  %rem = srem i64 %xor7, 1048576
  store i64 %rem, i64* %x, align 8
  %13 = load i64, i64* %x, align 8
  %arrayidx = getelementptr inbounds [1048576 x i64], [1048576 x i64]* @cached_fp_addrs, i64 0, i64 %13
  %14 = load i64, i64* %arrayidx, align 8
  %15 = load i64, i64* %fp_addr, align 8
  %cmp = icmp eq i64 %14, %15
  br i1 %cmp, label %if.then, label %if.end

if.then:                                          ; preds = %vaarg.end
  %arraydecay8 = getelementptr inbounds [1 x %struct.__va_list_tag], [1 x %struct.__va_list_tag]* %ap, i64 0, i64 0
  %arraydecay89 = bitcast %struct.__va_list_tag* %arraydecay8 to i8*
  call void @llvm.va_end(i8* %arraydecay89)
  store i32 0, i32* %retval, align 4
  br label %return

if.end:                                           ; preds = %vaarg.end
  %16 = load i64, i64* %argc.addr, align 8
  %cmp10 = icmp sge i64 %16, 2
  br i1 %cmp10, label %cond.true, label %cond.false

cond.true:                                        ; preds = %if.end
  br label %cond.end

cond.false:                                       ; preds = %if.end
  call void @__assert_fail(i8* getelementptr inbounds ([10 x i8], [10 x i8]* @.str, i64 0, i64 0), i8* getelementptr inbounds ([8 x i8], [8 x i8]* @.str.1, i64 0, i64 0), i32 58, i8* getelementptr inbounds ([42 x i8], [42 x i8]* @__PRETTY_FUNCTION__.ics_map_indirect_call, i64 0, i64 0)) #5
  unreachable

17:                                               ; No predecessors!
  br label %cond.end

cond.end:                                         ; preds = %17, %cond.true
  %18 = load i64, i64* %argc.addr, align 8
  %sub = sub nsw i64 %18, 1
  %cmp11 = icmp sle i64 %sub, 512
  br i1 %cmp11, label %cond.true12, label %cond.false13

cond.true12:                                      ; preds = %cond.end
  br label %cond.end14

cond.false13:                                     ; preds = %cond.end
  call void @__assert_fail(i8* getelementptr inbounds ([50 x i8], [50 x i8]* @.str.2, i64 0, i64 0), i8* getelementptr inbounds ([8 x i8], [8 x i8]* @.str.1, i64 0, i64 0), i32 66, i8* getelementptr inbounds ([42 x i8], [42 x i8]* @__PRETTY_FUNCTION__.ics_map_indirect_call, i64 0, i64 0)) #5
  unreachable

19:                                               ; No predecessors!
  br label %cond.end14

cond.end14:                                       ; preds = %19, %cond.true12
  %20 = load i64, i64* %argc.addr, align 8
  %sub15 = sub nsw i64 %20, 1
  store i64 %sub15, i64* getelementptr inbounds ([512 x i64], [512 x i64]* @indirect_call_static_vararg_stack, i64 0, i64 0), align 16
  store i32 1, i32* %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %cond.end14
  %21 = load i32, i32* %i, align 4
  %conv = sext i32 %21 to i64
  %22 = load i64, i64* %argc.addr, align 8
  %cmp16 = icmp slt i64 %conv, %22
  br i1 %cmp16, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %arraydecay17 = getelementptr inbounds [1 x %struct.__va_list_tag], [1 x %struct.__va_list_tag]* %ap, i64 0, i64 0
  %gp_offset_p18 = getelementptr inbounds %struct.__va_list_tag, %struct.__va_list_tag* %arraydecay17, i32 0, i32 0
  %gp_offset19 = load i32, i32* %gp_offset_p18, align 16
  %fits_in_gp20 = icmp ule i32 %gp_offset19, 40
  br i1 %fits_in_gp20, label %vaarg.in_reg21, label %vaarg.in_mem23

vaarg.in_reg21:                                   ; preds = %for.body
  %23 = getelementptr inbounds %struct.__va_list_tag, %struct.__va_list_tag* %arraydecay17, i32 0, i32 3
  %reg_save_area22 = load i8*, i8** %23, align 16
  %24 = getelementptr i8, i8* %reg_save_area22, i32 %gp_offset19
  %25 = bitcast i8* %24 to i64*
  %26 = add i32 %gp_offset19, 8
  store i32 %26, i32* %gp_offset_p18, align 16
  br label %vaarg.end27

vaarg.in_mem23:                                   ; preds = %for.body
  %overflow_arg_area_p24 = getelementptr inbounds %struct.__va_list_tag, %struct.__va_list_tag* %arraydecay17, i32 0, i32 2
  %overflow_arg_area25 = load i8*, i8** %overflow_arg_area_p24, align 8
  %27 = bitcast i8* %overflow_arg_area25 to i64*
  %overflow_arg_area.next26 = getelementptr i8, i8* %overflow_arg_area25, i32 8
  store i8* %overflow_arg_area.next26, i8** %overflow_arg_area_p24, align 8
  br label %vaarg.end27

vaarg.end27:                                      ; preds = %vaarg.in_mem23, %vaarg.in_reg21
  %vaarg.addr28 = phi i64* [ %25, %vaarg.in_reg21 ], [ %27, %vaarg.in_mem23 ]
  %28 = load i64, i64* %vaarg.addr28, align 8
  %29 = load i32, i32* %i, align 4
  %idxprom = sext i32 %29 to i64
  %arrayidx29 = getelementptr inbounds [512 x i64], [512 x i64]* @indirect_call_static_vararg_stack, i64 0, i64 %idxprom
  store i64 %28, i64* %arrayidx29, align 8
  br label %for.inc

for.inc:                                          ; preds = %vaarg.end27
  %30 = load i32, i32* %i, align 4
  %inc = add nsw i32 %30, 1
  store i32 %inc, i32* %i, align 4
  br label %for.cond

for.end:                                          ; preds = %for.cond
  %arraydecay30 = getelementptr inbounds [1 x %struct.__va_list_tag], [1 x %struct.__va_list_tag]* %ap, i64 0, i64 0
  %arraydecay3031 = bitcast %struct.__va_list_tag* %arraydecay30 to i8*
  call void @llvm.va_end(i8* %arraydecay3031)
  %call = call i32 @debrt_profile_indirect_print_args(i64* getelementptr inbounds ([512 x i64], [512 x i64]* @indirect_call_static_vararg_stack, i64 0, i64 0))
  %31 = load i64, i64* %fp_addr, align 8
  %call32 = call i32 @debrt_protect_indirect(i64 %31)
  %cmp33 = icmp eq i32 %call32, 0
  br i1 %cmp33, label %if.then34, label %if.end36

if.then34:                                        ; preds = %for.end
  %32 = load i64, i64* %fp_addr, align 8
  %33 = load i64, i64* %x, align 8
  %arrayidx35 = getelementptr inbounds [1048576 x i64], [1048576 x i64]* @cached_fp_addrs, i64 0, i64 %33
  store i64 %32, i64* %arrayidx35, align 8
  br label %if.end36

if.end36:                                         ; preds = %if.then34, %for.end
  store i32 0, i32* %retval, align 4
  br label %return

return:                                           ; preds = %if.end36, %if.then
  %34 = load i32, i32* %retval, align 4
  ret i32 %34
}

; Function Attrs: nounwind
declare void @llvm.va_start(i8*) #1

; Function Attrs: nounwind
declare void @llvm.va_end(i8*) #1

; Function Attrs: noreturn nounwind
declare void @__assert_fail(i8*, i8*, i32, i8*) #2

declare i32 @debrt_profile_indirect_print_args(i64*) #3

declare i32 @debrt_protect_indirect(i64) #3

; Function Attrs: alwaysinline uwtable
define i32 @ics_wrapper_debrt_protect_loop_end(i32 %loop_id) #0 {
entry:
  %loop_id.addr = alloca i32, align 4
  store i32 %loop_id, i32* %loop_id.addr, align 4
  %0 = load i32, i32* %loop_id.addr, align 4
  %call = call i32 @debrt_protect_loop_end(i32 %0)
  call void @llvm.memset.p0i8.i64(i8* align 16 bitcast ([1048576 x i64]* @cached_fp_addrs to i8*), i8 0, i64 8388608, i1 false)
  ret i32 0
}

declare i32 @debrt_protect_loop_end(i32) #3

; Function Attrs: argmemonly nounwind willreturn writeonly
declare void @llvm.memset.p0i8.i64(i8* nocapture writeonly, i8, i64, i1 immarg) #4

attributes #0 = { alwaysinline uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind }
attributes #2 = { noreturn nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #4 = { argmemonly nounwind willreturn writeonly }
attributes #5 = { noreturn nounwind }

!llvm.module.flags = !{!0, !1}
!llvm.ident = !{!2}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"PIC Level", i32 2}
!2 = !{!"clang version 11.0.0 (git@github.com:rudyjantz/llvm-project.git 9a8f8118d69154d0cb6684a1441330023de7e021)"}
