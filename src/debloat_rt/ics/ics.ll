; ModuleID = 'ics.cpp'
source_filename = "ics.cpp"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.fp_addr_recorded_t = type { i64, i64 }
%struct.__va_list_tag = type { i32, i32, i8*, i8* }

@cached_fp_addrs = global [1048576 x %struct.fp_addr_recorded_t] zeroinitializer, align 16
@cached_fp_addrs_idx = global i64 0, align 8
@indirect_call_static_vararg_stack = global [512 x i64] zeroinitializer, align 16
@.str = private unnamed_addr constant [46 x i8] c"0 && \22TODO implement dynamic hashmap support\22\00", align 1
@.str.1 = private unnamed_addr constant [8 x i8] c"ics.cpp\00", align 1
@__PRETTY_FUNCTION__.ics_map_indirect_call = private unnamed_addr constant [42 x i8] c"int ics_map_indirect_call(long long, ...)\00", align 1
@.str.2 = private unnamed_addr constant [10 x i8] c"argc >= 2\00", align 1
@.str.3 = private unnamed_addr constant [46 x i8] c"argc <= INDIRECT_CALL_STATIC_VARARG_STATIC_SZ\00", align 1
@__PRETTY_FUNCTION__.ics_end_indirect_call = private unnamed_addr constant [37 x i8] c"int ics_end_indirect_call(long long)\00", align 1
@.str.4 = private unnamed_addr constant [191 x i8] c"Unexpected behavior, safe to ignore at start-up: ics-end could not find the cached fp-addr. Is there some mismatched instrumentation or unexpected/unhandled control flow in the application?\0A\00", align 1

; Function Attrs: alwaysinline uwtable
define i32 @ics_map_indirect_call(i64 %argc, ...) #0 {
entry:
  %retval = alloca i32, align 4
  %argc.addr = alloca i64, align 8
  %x = alloca i64, align 8
  %i = alloca i32, align 4
  %ap = alloca [1 x %struct.__va_list_tag], align 16
  %fp_addr = alloca i64, align 8
  %x_start = alloca i64, align 8
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
  store i64 %13, i64* %x_start, align 8
  br label %while.cond

while.cond:                                       ; preds = %if.end16, %vaarg.end
  %14 = load i64, i64* %x, align 8
  %arrayidx = getelementptr inbounds [1048576 x %struct.fp_addr_recorded_t], [1048576 x %struct.fp_addr_recorded_t]* @cached_fp_addrs, i64 0, i64 %14
  %fp_addr8 = getelementptr inbounds %struct.fp_addr_recorded_t, %struct.fp_addr_recorded_t* %arrayidx, i32 0, i32 0
  %15 = load i64, i64* %fp_addr8, align 16
  %cmp = icmp ne i64 %15, 0
  br i1 %cmp, label %while.body, label %while.end

while.body:                                       ; preds = %while.cond
  %16 = load i64, i64* %x, align 8
  %arrayidx9 = getelementptr inbounds [1048576 x %struct.fp_addr_recorded_t], [1048576 x %struct.fp_addr_recorded_t]* @cached_fp_addrs, i64 0, i64 %16
  %fp_addr10 = getelementptr inbounds %struct.fp_addr_recorded_t, %struct.fp_addr_recorded_t* %arrayidx9, i32 0, i32 0
  %17 = load i64, i64* %fp_addr10, align 16
  %18 = load i64, i64* %fp_addr, align 8
  %cmp11 = icmp eq i64 %17, %18
  br i1 %cmp11, label %if.then, label %if.end

if.then:                                          ; preds = %while.body
  %arraydecay12 = getelementptr inbounds [1 x %struct.__va_list_tag], [1 x %struct.__va_list_tag]* %ap, i64 0, i64 0
  %arraydecay1213 = bitcast %struct.__va_list_tag* %arraydecay12 to i8*
  call void @llvm.va_end(i8* %arraydecay1213)
  %call = call i32 @debrt_profile_update_recorded_funcs(i32 0)
  store i32 0, i32* %retval, align 4
  br label %return

if.end:                                           ; preds = %while.body
  %19 = load i64, i64* %x, align 8
  %add = add nsw i64 %19, 1
  %and = and i64 %add, 1048576
  store i64 %and, i64* %x, align 8
  %20 = load i64, i64* %x, align 8
  %21 = load i64, i64* %x_start, align 8
  %cmp14 = icmp eq i64 %20, %21
  br i1 %cmp14, label %if.then15, label %if.end16

if.then15:                                        ; preds = %if.end
  call void @__assert_fail(i8* getelementptr inbounds ([46 x i8], [46 x i8]* @.str, i64 0, i64 0), i8* getelementptr inbounds ([8 x i8], [8 x i8]* @.str.1, i64 0, i64 0), i32 89, i8* getelementptr inbounds ([42 x i8], [42 x i8]* @__PRETTY_FUNCTION__.ics_map_indirect_call, i64 0, i64 0)) #5
  unreachable

if.end16:                                         ; preds = %if.end
  br label %while.cond

while.end:                                        ; preds = %while.cond
  %22 = load i64, i64* %argc.addr, align 8
  %cmp17 = icmp sge i64 %22, 2
  br i1 %cmp17, label %cond.true, label %cond.false

cond.true:                                        ; preds = %while.end
  br label %cond.end

cond.false:                                       ; preds = %while.end
  call void @__assert_fail(i8* getelementptr inbounds ([10 x i8], [10 x i8]* @.str.2, i64 0, i64 0), i8* getelementptr inbounds ([8 x i8], [8 x i8]* @.str.1, i64 0, i64 0), i32 100, i8* getelementptr inbounds ([42 x i8], [42 x i8]* @__PRETTY_FUNCTION__.ics_map_indirect_call, i64 0, i64 0)) #5
  unreachable

23:                                               ; No predecessors!
  br label %cond.end

cond.end:                                         ; preds = %23, %cond.true
  %24 = load i64, i64* %argc.addr, align 8
  %cmp18 = icmp sle i64 %24, 512
  br i1 %cmp18, label %cond.true19, label %cond.false20

cond.true19:                                      ; preds = %cond.end
  br label %cond.end21

cond.false20:                                     ; preds = %cond.end
  call void @__assert_fail(i8* getelementptr inbounds ([46 x i8], [46 x i8]* @.str.3, i64 0, i64 0), i8* getelementptr inbounds ([8 x i8], [8 x i8]* @.str.1, i64 0, i64 0), i32 107, i8* getelementptr inbounds ([42 x i8], [42 x i8]* @__PRETTY_FUNCTION__.ics_map_indirect_call, i64 0, i64 0)) #5
  unreachable

25:                                               ; No predecessors!
  br label %cond.end21

cond.end21:                                       ; preds = %25, %cond.true19
  %26 = load i64, i64* %argc.addr, align 8
  store i64 %26, i64* getelementptr inbounds ([512 x i64], [512 x i64]* @indirect_call_static_vararg_stack, i64 0, i64 0), align 16
  %27 = load i64, i64* %fp_addr, align 8
  store i64 %27, i64* getelementptr inbounds ([512 x i64], [512 x i64]* @indirect_call_static_vararg_stack, i64 0, i64 1), align 8
  store i32 1, i32* %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %cond.end21
  %28 = load i32, i32* %i, align 4
  %conv = sext i32 %28 to i64
  %29 = load i64, i64* %argc.addr, align 8
  %cmp22 = icmp slt i64 %conv, %29
  br i1 %cmp22, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %arraydecay23 = getelementptr inbounds [1 x %struct.__va_list_tag], [1 x %struct.__va_list_tag]* %ap, i64 0, i64 0
  %gp_offset_p24 = getelementptr inbounds %struct.__va_list_tag, %struct.__va_list_tag* %arraydecay23, i32 0, i32 0
  %gp_offset25 = load i32, i32* %gp_offset_p24, align 16
  %fits_in_gp26 = icmp ule i32 %gp_offset25, 40
  br i1 %fits_in_gp26, label %vaarg.in_reg27, label %vaarg.in_mem29

vaarg.in_reg27:                                   ; preds = %for.body
  %30 = getelementptr inbounds %struct.__va_list_tag, %struct.__va_list_tag* %arraydecay23, i32 0, i32 3
  %reg_save_area28 = load i8*, i8** %30, align 16
  %31 = getelementptr i8, i8* %reg_save_area28, i32 %gp_offset25
  %32 = bitcast i8* %31 to i64*
  %33 = add i32 %gp_offset25, 8
  store i32 %33, i32* %gp_offset_p24, align 16
  br label %vaarg.end33

vaarg.in_mem29:                                   ; preds = %for.body
  %overflow_arg_area_p30 = getelementptr inbounds %struct.__va_list_tag, %struct.__va_list_tag* %arraydecay23, i32 0, i32 2
  %overflow_arg_area31 = load i8*, i8** %overflow_arg_area_p30, align 8
  %34 = bitcast i8* %overflow_arg_area31 to i64*
  %overflow_arg_area.next32 = getelementptr i8, i8* %overflow_arg_area31, i32 8
  store i8* %overflow_arg_area.next32, i8** %overflow_arg_area_p30, align 8
  br label %vaarg.end33

vaarg.end33:                                      ; preds = %vaarg.in_mem29, %vaarg.in_reg27
  %vaarg.addr34 = phi i64* [ %32, %vaarg.in_reg27 ], [ %34, %vaarg.in_mem29 ]
  %35 = load i64, i64* %vaarg.addr34, align 8
  %36 = load i32, i32* %i, align 4
  %add35 = add nsw i32 %36, 1
  %idxprom = sext i32 %add35 to i64
  %arrayidx36 = getelementptr inbounds [512 x i64], [512 x i64]* @indirect_call_static_vararg_stack, i64 0, i64 %idxprom
  store i64 %35, i64* %arrayidx36, align 8
  br label %for.inc

for.inc:                                          ; preds = %vaarg.end33
  %37 = load i32, i32* %i, align 4
  %inc = add nsw i32 %37, 1
  store i32 %inc, i32* %i, align 4
  br label %for.cond

for.end:                                          ; preds = %for.cond
  %arraydecay37 = getelementptr inbounds [1 x %struct.__va_list_tag], [1 x %struct.__va_list_tag]* %ap, i64 0, i64 0
  %arraydecay3738 = bitcast %struct.__va_list_tag* %arraydecay37 to i8*
  call void @llvm.va_end(i8* %arraydecay3738)
  %call39 = call i32 @debrt_profile_indirect_print_args(i64* getelementptr inbounds ([512 x i64], [512 x i64]* @indirect_call_static_vararg_stack, i64 0, i64 0))
  %38 = load i64, i64* %fp_addr, align 8
  %call40 = call i32 @debrt_protect_indirect(i64 %38)
  %cmp41 = icmp eq i32 %call40, 0
  br i1 %cmp41, label %if.then42, label %if.end46

if.then42:                                        ; preds = %for.end
  %39 = load i64, i64* %fp_addr, align 8
  %40 = load i64, i64* %x, align 8
  %arrayidx43 = getelementptr inbounds [1048576 x %struct.fp_addr_recorded_t], [1048576 x %struct.fp_addr_recorded_t]* @cached_fp_addrs, i64 0, i64 %40
  %fp_addr44 = getelementptr inbounds %struct.fp_addr_recorded_t, %struct.fp_addr_recorded_t* %arrayidx43, i32 0, i32 0
  store i64 %39, i64* %fp_addr44, align 16
  %41 = load i64, i64* %x, align 8
  %arrayidx45 = getelementptr inbounds [1048576 x %struct.fp_addr_recorded_t], [1048576 x %struct.fp_addr_recorded_t]* @cached_fp_addrs, i64 0, i64 %41
  %recorded = getelementptr inbounds %struct.fp_addr_recorded_t, %struct.fp_addr_recorded_t* %arrayidx45, i32 0, i32 1
  store i64 0, i64* %recorded, align 8
  br label %if.end46

if.end46:                                         ; preds = %if.then42, %for.end
  store i32 0, i32* %retval, align 4
  br label %return

return:                                           ; preds = %if.end46, %if.then
  %42 = load i32, i32* %retval, align 4
  ret i32 %42
}

; Function Attrs: nounwind
declare void @llvm.va_start(i8*) #1

; Function Attrs: nounwind
declare void @llvm.va_end(i8*) #1

declare i32 @debrt_profile_update_recorded_funcs(i32) #2

; Function Attrs: noreturn nounwind
declare void @__assert_fail(i8*, i8*, i32, i8*) #3

declare i32 @debrt_profile_indirect_print_args(i64*) #2

declare i32 @debrt_protect_indirect(i64) #2

; Function Attrs: alwaysinline uwtable
define i32 @ics_end_indirect_call(i64 %fp_addr) #0 {
entry:
  %retval = alloca i32, align 4
  %fp_addr.addr = alloca i64, align 8
  %x = alloca i64, align 8
  %x_start = alloca i64, align 8
  store i64 %fp_addr, i64* %fp_addr.addr, align 8
  %0 = load i64, i64* %fp_addr.addr, align 8
  store i64 %0, i64* %x, align 8
  %1 = load i64, i64* %x, align 8
  %2 = load i64, i64* %x, align 8
  %shr = ashr i64 %2, 30
  %xor = xor i64 %1, %shr
  %mul = mul i64 %xor, -4658895280553007687
  store i64 %mul, i64* %x, align 8
  %3 = load i64, i64* %x, align 8
  %4 = load i64, i64* %x, align 8
  %shr1 = ashr i64 %4, 27
  %xor2 = xor i64 %3, %shr1
  %mul3 = mul i64 %xor2, -7723592293110705685
  store i64 %mul3, i64* %x, align 8
  %5 = load i64, i64* %x, align 8
  %6 = load i64, i64* %x, align 8
  %shr4 = ashr i64 %6, 31
  %xor5 = xor i64 %5, %shr4
  %rem = srem i64 %xor5, 1048576
  store i64 %rem, i64* %x, align 8
  %7 = load i64, i64* %x, align 8
  store i64 %7, i64* %x_start, align 8
  br label %while.cond

while.cond:                                       ; preds = %if.end19, %entry
  %8 = load i64, i64* %x, align 8
  %arrayidx = getelementptr inbounds [1048576 x %struct.fp_addr_recorded_t], [1048576 x %struct.fp_addr_recorded_t]* @cached_fp_addrs, i64 0, i64 %8
  %fp_addr6 = getelementptr inbounds %struct.fp_addr_recorded_t, %struct.fp_addr_recorded_t* %arrayidx, i32 0, i32 0
  %9 = load i64, i64* %fp_addr6, align 16
  %cmp = icmp ne i64 %9, 0
  br i1 %cmp, label %while.body, label %while.end

while.body:                                       ; preds = %while.cond
  %10 = load i64, i64* %x, align 8
  %arrayidx7 = getelementptr inbounds [1048576 x %struct.fp_addr_recorded_t], [1048576 x %struct.fp_addr_recorded_t]* @cached_fp_addrs, i64 0, i64 %10
  %fp_addr8 = getelementptr inbounds %struct.fp_addr_recorded_t, %struct.fp_addr_recorded_t* %arrayidx7, i32 0, i32 0
  %11 = load i64, i64* %fp_addr8, align 16
  %12 = load i64, i64* %fp_addr.addr, align 8
  %cmp9 = icmp eq i64 %11, %12
  br i1 %cmp9, label %if.then, label %if.end16

if.then:                                          ; preds = %while.body
  %13 = load i64, i64* %x, align 8
  %arrayidx10 = getelementptr inbounds [1048576 x %struct.fp_addr_recorded_t], [1048576 x %struct.fp_addr_recorded_t]* @cached_fp_addrs, i64 0, i64 %13
  %recorded = getelementptr inbounds %struct.fp_addr_recorded_t, %struct.fp_addr_recorded_t* %arrayidx10, i32 0, i32 1
  %14 = load i64, i64* %recorded, align 8
  %cmp11 = icmp eq i64 %14, 0
  br i1 %cmp11, label %if.then12, label %if.else

if.then12:                                        ; preds = %if.then
  %call = call i32 @debrt_profile_update_recorded_funcs(i32 2)
  %15 = load i64, i64* %x, align 8
  %arrayidx13 = getelementptr inbounds [1048576 x %struct.fp_addr_recorded_t], [1048576 x %struct.fp_addr_recorded_t]* @cached_fp_addrs, i64 0, i64 %15
  %recorded14 = getelementptr inbounds %struct.fp_addr_recorded_t, %struct.fp_addr_recorded_t* %arrayidx13, i32 0, i32 1
  store i64 1, i64* %recorded14, align 8
  br label %if.end

if.else:                                          ; preds = %if.then
  %call15 = call i32 @debrt_profile_update_recorded_funcs(i32 1)
  br label %if.end

if.end:                                           ; preds = %if.else, %if.then12
  store i32 0, i32* %retval, align 4
  br label %return

if.end16:                                         ; preds = %while.body
  %16 = load i64, i64* %x, align 8
  %add = add nsw i64 %16, 1
  %and = and i64 %add, 1048576
  store i64 %and, i64* %x, align 8
  %17 = load i64, i64* %x, align 8
  %18 = load i64, i64* %x_start, align 8
  %cmp17 = icmp eq i64 %17, %18
  br i1 %cmp17, label %if.then18, label %if.end19

if.then18:                                        ; preds = %if.end16
  call void @__assert_fail(i8* getelementptr inbounds ([46 x i8], [46 x i8]* @.str, i64 0, i64 0), i8* getelementptr inbounds ([8 x i8], [8 x i8]* @.str.1, i64 0, i64 0), i32 202, i8* getelementptr inbounds ([37 x i8], [37 x i8]* @__PRETTY_FUNCTION__.ics_end_indirect_call, i64 0, i64 0)) #5
  unreachable

if.end19:                                         ; preds = %if.end16
  br label %while.cond

while.end:                                        ; preds = %while.cond
  %call20 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([191 x i8], [191 x i8]* @.str.4, i64 0, i64 0))
  store i32 1, i32* %retval, align 4
  br label %return

return:                                           ; preds = %while.end, %if.end
  %19 = load i32, i32* %retval, align 4
  ret i32 %19
}

declare i32 @printf(i8*, ...) #2

; Function Attrs: alwaysinline uwtable
define i32 @ics_wrapper_debrt_protect_loop_end(i32 %loop_id) #0 {
entry:
  %loop_id.addr = alloca i32, align 4
  store i32 %loop_id, i32* %loop_id.addr, align 4
  %0 = load i32, i32* %loop_id.addr, align 4
  %call = call i32 @debrt_protect_loop_end(i32 %0)
  call void @llvm.memset.p0i8.i64(i8* align 16 bitcast ([1048576 x %struct.fp_addr_recorded_t]* @cached_fp_addrs to i8*), i8 0, i64 16777216, i1 false)
  ret i32 0
}

declare i32 @debrt_protect_loop_end(i32) #2

; Function Attrs: argmemonly nounwind willreturn writeonly
declare void @llvm.memset.p0i8.i64(i8* nocapture writeonly, i8, i64, i1 immarg) #4

attributes #0 = { alwaysinline uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind }
attributes #2 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { noreturn nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #4 = { argmemonly nounwind willreturn writeonly }
attributes #5 = { noreturn nounwind }

!llvm.module.flags = !{!0, !1}
!llvm.ident = !{!2}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"PIC Level", i32 2}
!2 = !{!"clang version 11.0.0 (git@github.com:rudyjantz/llvm-project.git 9a8f8118d69154d0cb6684a1441330023de7e021)"}
