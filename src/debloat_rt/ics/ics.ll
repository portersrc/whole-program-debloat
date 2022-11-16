; ModuleID = 'ics.cpp'
source_filename = "ics.cpp"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.fp_addr_recorded_t = type { i64, i64 }
%struct.__va_list_tag = type { i32, i32, i8*, i8* }

@cached_fp_addrs = global [1048576 x %struct.fp_addr_recorded_t] zeroinitializer, align 16
@cached_fp_addrs_idx = global i64 0, align 8
@indirect_call_static_vararg_stack = global [512 x i64] zeroinitializer, align 16
@.str = private unnamed_addr constant [23 x i8] c"ics_map_indirect_call\0A\00", align 1
@.str.1 = private unnamed_addr constant [42 x i8] c"ics_map_indirect_call: fp_addr is 0x%llx\0A\00", align 1
@.str.2 = private unnamed_addr constant [45 x i8] c"ics_map_indirect_call: hashed value is %lld\0A\00", align 1
@.str.3 = private unnamed_addr constant [60 x i8] c"ics_map_indirect_call: checking for cache hit or free spot\0A\00", align 1
@.str.4 = private unnamed_addr constant [45 x i8] c"ics_map_indirect_call: found cached address\0A\00", align 1
@.str.5 = private unnamed_addr constant [56 x i8] c"ics_map_indirect_call: adding a new recorded_funcs set\0A\00", align 1
@.str.6 = private unnamed_addr constant [46 x i8] c"0 && \22TODO implement dynamic hashmap support\22\00", align 1
@.str.7 = private unnamed_addr constant [8 x i8] c"ics.cpp\00", align 1
@__PRETTY_FUNCTION__.ics_map_indirect_call = private unnamed_addr constant [42 x i8] c"int ics_map_indirect_call(long long, ...)\00", align 1
@.str.8 = private unnamed_addr constant [34 x i8] c"ics_map_indirect_call: iterating\0A\00", align 1
@.str.9 = private unnamed_addr constant [10 x i8] c"argc >= 2\00", align 1
@.str.10 = private unnamed_addr constant [46 x i8] c"argc <= INDIRECT_CALL_STATIC_VARARG_STATIC_SZ\00", align 1
@.str.11 = private unnamed_addr constant [53 x i8] c"ics_map_indirect_call: invoking indirect-print-args\0A\00", align 1
@.str.12 = private unnamed_addr constant [50 x i8] c"ics_map_indirect_call: invoking protect-indirect\0A\00", align 1
@.str.13 = private unnamed_addr constant [42 x i8] c"ics_map_indirect_call: setting the cache\0A\00", align 1
@.str.14 = private unnamed_addr constant [43 x i8] c"ics_end_indirect_call for fp_addr: 0x%llx\0A\00", align 1
@.str.15 = private unnamed_addr constant [48 x i8] c"ics_end_indirect_call: checking for cached hit\0A\00", align 1
@.str.16 = private unnamed_addr constant [45 x i8] c"ics_end_indirect_call: found cached fp-addr\0A\00", align 1
@.str.17 = private unnamed_addr constant [71 x i8] c"ics_end_indirect_call: found the cached address. need to pop and dump\0A\00", align 1
@.str.18 = private unnamed_addr constant [67 x i8] c"ics_end_indirect_call: found the cached address. just need to pop\0A\00", align 1
@__PRETTY_FUNCTION__.ics_end_indirect_call = private unnamed_addr constant [37 x i8] c"int ics_end_indirect_call(long long)\00", align 1
@.str.19 = private unnamed_addr constant [191 x i8] c"Unexpected behavior, safe to ignore at start-up: ics-end could not find the cached fp-addr. Is there some mismatched instrumentation or unexpected/unhandled control flow in the application?\0A\00", align 1

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
  %call = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([23 x i8], [23 x i8]* @.str, i64 0, i64 0))
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
  %call3 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([42 x i8], [42 x i8]* @.str.1, i64 0, i64 0), i64 %6)
  %7 = load i64, i64* %fp_addr, align 8
  store i64 %7, i64* %x, align 8
  %8 = load i64, i64* %x, align 8
  %9 = load i64, i64* %x, align 8
  %shr = ashr i64 %9, 30
  %xor = xor i64 %8, %shr
  %mul = mul i64 %xor, -4658895280553007687
  store i64 %mul, i64* %x, align 8
  %10 = load i64, i64* %x, align 8
  %11 = load i64, i64* %x, align 8
  %shr4 = ashr i64 %11, 27
  %xor5 = xor i64 %10, %shr4
  %mul6 = mul i64 %xor5, -7723592293110705685
  store i64 %mul6, i64* %x, align 8
  %12 = load i64, i64* %x, align 8
  %13 = load i64, i64* %x, align 8
  %shr7 = ashr i64 %13, 31
  %xor8 = xor i64 %12, %shr7
  %rem = srem i64 %xor8, 1048576
  store i64 %rem, i64* %x, align 8
  %14 = load i64, i64* %x, align 8
  %call9 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([45 x i8], [45 x i8]* @.str.2, i64 0, i64 0), i64 %14)
  %call10 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([60 x i8], [60 x i8]* @.str.3, i64 0, i64 0))
  %15 = load i64, i64* %x, align 8
  store i64 %15, i64* %x_start, align 8
  br label %while.cond

while.cond:                                       ; preds = %if.end22, %vaarg.end
  %16 = load i64, i64* %x, align 8
  %arrayidx = getelementptr inbounds [1048576 x %struct.fp_addr_recorded_t], [1048576 x %struct.fp_addr_recorded_t]* @cached_fp_addrs, i64 0, i64 %16
  %fp_addr11 = getelementptr inbounds %struct.fp_addr_recorded_t, %struct.fp_addr_recorded_t* %arrayidx, i32 0, i32 0
  %17 = load i64, i64* %fp_addr11, align 16
  %cmp = icmp ne i64 %17, 0
  br i1 %cmp, label %while.body, label %while.end

while.body:                                       ; preds = %while.cond
  %18 = load i64, i64* %x, align 8
  %arrayidx12 = getelementptr inbounds [1048576 x %struct.fp_addr_recorded_t], [1048576 x %struct.fp_addr_recorded_t]* @cached_fp_addrs, i64 0, i64 %18
  %fp_addr13 = getelementptr inbounds %struct.fp_addr_recorded_t, %struct.fp_addr_recorded_t* %arrayidx12, i32 0, i32 0
  %19 = load i64, i64* %fp_addr13, align 16
  %20 = load i64, i64* %fp_addr, align 8
  %cmp14 = icmp eq i64 %19, %20
  br i1 %cmp14, label %if.then, label %if.end

if.then:                                          ; preds = %while.body
  %call15 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([45 x i8], [45 x i8]* @.str.4, i64 0, i64 0))
  %arraydecay16 = getelementptr inbounds [1 x %struct.__va_list_tag], [1 x %struct.__va_list_tag]* %ap, i64 0, i64 0
  %arraydecay1617 = bitcast %struct.__va_list_tag* %arraydecay16 to i8*
  call void @llvm.va_end(i8* %arraydecay1617)
  %call18 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([56 x i8], [56 x i8]* @.str.5, i64 0, i64 0))
  %call19 = call i32 @debrt_profile_update_recorded_funcs(i32 0)
  store i32 0, i32* %retval, align 4
  br label %return

if.end:                                           ; preds = %while.body
  %21 = load i64, i64* %x, align 8
  %add = add nsw i64 %21, 1
  %and = and i64 %add, 1048576
  store i64 %and, i64* %x, align 8
  %22 = load i64, i64* %x, align 8
  %23 = load i64, i64* %x_start, align 8
  %cmp20 = icmp eq i64 %22, %23
  br i1 %cmp20, label %if.then21, label %if.end22

if.then21:                                        ; preds = %if.end
  call void @__assert_fail(i8* getelementptr inbounds ([46 x i8], [46 x i8]* @.str.6, i64 0, i64 0), i8* getelementptr inbounds ([8 x i8], [8 x i8]* @.str.7, i64 0, i64 0), i32 89, i8* getelementptr inbounds ([42 x i8], [42 x i8]* @__PRETTY_FUNCTION__.ics_map_indirect_call, i64 0, i64 0)) #5
  unreachable

if.end22:                                         ; preds = %if.end
  %call23 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([34 x i8], [34 x i8]* @.str.8, i64 0, i64 0))
  br label %while.cond

while.end:                                        ; preds = %while.cond
  %24 = load i64, i64* %argc.addr, align 8
  %cmp24 = icmp sge i64 %24, 2
  br i1 %cmp24, label %cond.true, label %cond.false

cond.true:                                        ; preds = %while.end
  br label %cond.end

cond.false:                                       ; preds = %while.end
  call void @__assert_fail(i8* getelementptr inbounds ([10 x i8], [10 x i8]* @.str.9, i64 0, i64 0), i8* getelementptr inbounds ([8 x i8], [8 x i8]* @.str.7, i64 0, i64 0), i32 100, i8* getelementptr inbounds ([42 x i8], [42 x i8]* @__PRETTY_FUNCTION__.ics_map_indirect_call, i64 0, i64 0)) #5
  unreachable

25:                                               ; No predecessors!
  br label %cond.end

cond.end:                                         ; preds = %25, %cond.true
  %26 = load i64, i64* %argc.addr, align 8
  %cmp25 = icmp sle i64 %26, 512
  br i1 %cmp25, label %cond.true26, label %cond.false27

cond.true26:                                      ; preds = %cond.end
  br label %cond.end28

cond.false27:                                     ; preds = %cond.end
  call void @__assert_fail(i8* getelementptr inbounds ([46 x i8], [46 x i8]* @.str.10, i64 0, i64 0), i8* getelementptr inbounds ([8 x i8], [8 x i8]* @.str.7, i64 0, i64 0), i32 107, i8* getelementptr inbounds ([42 x i8], [42 x i8]* @__PRETTY_FUNCTION__.ics_map_indirect_call, i64 0, i64 0)) #5
  unreachable

27:                                               ; No predecessors!
  br label %cond.end28

cond.end28:                                       ; preds = %27, %cond.true26
  %28 = load i64, i64* %argc.addr, align 8
  store i64 %28, i64* getelementptr inbounds ([512 x i64], [512 x i64]* @indirect_call_static_vararg_stack, i64 0, i64 0), align 16
  %29 = load i64, i64* %fp_addr, align 8
  store i64 %29, i64* getelementptr inbounds ([512 x i64], [512 x i64]* @indirect_call_static_vararg_stack, i64 0, i64 1), align 8
  store i32 1, i32* %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %cond.end28
  %30 = load i32, i32* %i, align 4
  %conv = sext i32 %30 to i64
  %31 = load i64, i64* %argc.addr, align 8
  %cmp29 = icmp slt i64 %conv, %31
  br i1 %cmp29, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %arraydecay30 = getelementptr inbounds [1 x %struct.__va_list_tag], [1 x %struct.__va_list_tag]* %ap, i64 0, i64 0
  %gp_offset_p31 = getelementptr inbounds %struct.__va_list_tag, %struct.__va_list_tag* %arraydecay30, i32 0, i32 0
  %gp_offset32 = load i32, i32* %gp_offset_p31, align 16
  %fits_in_gp33 = icmp ule i32 %gp_offset32, 40
  br i1 %fits_in_gp33, label %vaarg.in_reg34, label %vaarg.in_mem36

vaarg.in_reg34:                                   ; preds = %for.body
  %32 = getelementptr inbounds %struct.__va_list_tag, %struct.__va_list_tag* %arraydecay30, i32 0, i32 3
  %reg_save_area35 = load i8*, i8** %32, align 16
  %33 = getelementptr i8, i8* %reg_save_area35, i32 %gp_offset32
  %34 = bitcast i8* %33 to i64*
  %35 = add i32 %gp_offset32, 8
  store i32 %35, i32* %gp_offset_p31, align 16
  br label %vaarg.end40

vaarg.in_mem36:                                   ; preds = %for.body
  %overflow_arg_area_p37 = getelementptr inbounds %struct.__va_list_tag, %struct.__va_list_tag* %arraydecay30, i32 0, i32 2
  %overflow_arg_area38 = load i8*, i8** %overflow_arg_area_p37, align 8
  %36 = bitcast i8* %overflow_arg_area38 to i64*
  %overflow_arg_area.next39 = getelementptr i8, i8* %overflow_arg_area38, i32 8
  store i8* %overflow_arg_area.next39, i8** %overflow_arg_area_p37, align 8
  br label %vaarg.end40

vaarg.end40:                                      ; preds = %vaarg.in_mem36, %vaarg.in_reg34
  %vaarg.addr41 = phi i64* [ %34, %vaarg.in_reg34 ], [ %36, %vaarg.in_mem36 ]
  %37 = load i64, i64* %vaarg.addr41, align 8
  %38 = load i32, i32* %i, align 4
  %add42 = add nsw i32 %38, 1
  %idxprom = sext i32 %add42 to i64
  %arrayidx43 = getelementptr inbounds [512 x i64], [512 x i64]* @indirect_call_static_vararg_stack, i64 0, i64 %idxprom
  store i64 %37, i64* %arrayidx43, align 8
  br label %for.inc

for.inc:                                          ; preds = %vaarg.end40
  %39 = load i32, i32* %i, align 4
  %inc = add nsw i32 %39, 1
  store i32 %inc, i32* %i, align 4
  br label %for.cond

for.end:                                          ; preds = %for.cond
  %arraydecay44 = getelementptr inbounds [1 x %struct.__va_list_tag], [1 x %struct.__va_list_tag]* %ap, i64 0, i64 0
  %arraydecay4445 = bitcast %struct.__va_list_tag* %arraydecay44 to i8*
  call void @llvm.va_end(i8* %arraydecay4445)
  %call46 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([53 x i8], [53 x i8]* @.str.11, i64 0, i64 0))
  %call47 = call i32 @debrt_profile_indirect_print_args(i64* getelementptr inbounds ([512 x i64], [512 x i64]* @indirect_call_static_vararg_stack, i64 0, i64 0))
  %call48 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([50 x i8], [50 x i8]* @.str.12, i64 0, i64 0))
  %40 = load i64, i64* %fp_addr, align 8
  %call49 = call i32 @debrt_protect_indirect(i64 %40)
  %cmp50 = icmp eq i32 %call49, 0
  br i1 %cmp50, label %if.then51, label %if.end56

if.then51:                                        ; preds = %for.end
  %call52 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([42 x i8], [42 x i8]* @.str.13, i64 0, i64 0))
  %41 = load i64, i64* %fp_addr, align 8
  %42 = load i64, i64* %x, align 8
  %arrayidx53 = getelementptr inbounds [1048576 x %struct.fp_addr_recorded_t], [1048576 x %struct.fp_addr_recorded_t]* @cached_fp_addrs, i64 0, i64 %42
  %fp_addr54 = getelementptr inbounds %struct.fp_addr_recorded_t, %struct.fp_addr_recorded_t* %arrayidx53, i32 0, i32 0
  store i64 %41, i64* %fp_addr54, align 16
  %43 = load i64, i64* %x, align 8
  %arrayidx55 = getelementptr inbounds [1048576 x %struct.fp_addr_recorded_t], [1048576 x %struct.fp_addr_recorded_t]* @cached_fp_addrs, i64 0, i64 %43
  %recorded = getelementptr inbounds %struct.fp_addr_recorded_t, %struct.fp_addr_recorded_t* %arrayidx55, i32 0, i32 1
  store i64 0, i64* %recorded, align 8
  br label %if.end56

if.end56:                                         ; preds = %if.then51, %for.end
  store i32 0, i32* %retval, align 4
  br label %return

return:                                           ; preds = %if.end56, %if.then
  %44 = load i32, i32* %retval, align 4
  ret i32 %44
}

declare i32 @printf(i8*, ...) #1

; Function Attrs: nounwind
declare void @llvm.va_start(i8*) #2

; Function Attrs: nounwind
declare void @llvm.va_end(i8*) #2

declare i32 @debrt_profile_update_recorded_funcs(i32) #1

; Function Attrs: noreturn nounwind
declare void @__assert_fail(i8*, i8*, i32, i8*) #3

declare i32 @debrt_profile_indirect_print_args(i64*) #1

declare i32 @debrt_protect_indirect(i64) #1

; Function Attrs: alwaysinline uwtable
define i32 @ics_end_indirect_call(i64 %fp_addr) #0 {
entry:
  %retval = alloca i32, align 4
  %fp_addr.addr = alloca i64, align 8
  %x = alloca i64, align 8
  %x_start = alloca i64, align 8
  store i64 %fp_addr, i64* %fp_addr.addr, align 8
  %0 = load i64, i64* %fp_addr.addr, align 8
  %call = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([43 x i8], [43 x i8]* @.str.14, i64 0, i64 0), i64 %0)
  %1 = load i64, i64* %fp_addr.addr, align 8
  store i64 %1, i64* %x, align 8
  %2 = load i64, i64* %x, align 8
  %3 = load i64, i64* %x, align 8
  %shr = ashr i64 %3, 30
  %xor = xor i64 %2, %shr
  %mul = mul i64 %xor, -4658895280553007687
  store i64 %mul, i64* %x, align 8
  %4 = load i64, i64* %x, align 8
  %5 = load i64, i64* %x, align 8
  %shr1 = ashr i64 %5, 27
  %xor2 = xor i64 %4, %shr1
  %mul3 = mul i64 %xor2, -7723592293110705685
  store i64 %mul3, i64* %x, align 8
  %6 = load i64, i64* %x, align 8
  %7 = load i64, i64* %x, align 8
  %shr4 = ashr i64 %7, 31
  %xor5 = xor i64 %6, %shr4
  %rem = srem i64 %xor5, 1048576
  store i64 %rem, i64* %x, align 8
  %8 = load i64, i64* %x, align 8
  %call6 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([45 x i8], [45 x i8]* @.str.2, i64 0, i64 0), i64 %8)
  %call7 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([48 x i8], [48 x i8]* @.str.15, i64 0, i64 0))
  %9 = load i64, i64* %x, align 8
  store i64 %9, i64* %x_start, align 8
  br label %while.cond

while.cond:                                       ; preds = %if.end25, %entry
  %10 = load i64, i64* %x, align 8
  %arrayidx = getelementptr inbounds [1048576 x %struct.fp_addr_recorded_t], [1048576 x %struct.fp_addr_recorded_t]* @cached_fp_addrs, i64 0, i64 %10
  %fp_addr8 = getelementptr inbounds %struct.fp_addr_recorded_t, %struct.fp_addr_recorded_t* %arrayidx, i32 0, i32 0
  %11 = load i64, i64* %fp_addr8, align 16
  %cmp = icmp ne i64 %11, 0
  br i1 %cmp, label %while.body, label %while.end

while.body:                                       ; preds = %while.cond
  %12 = load i64, i64* %x, align 8
  %arrayidx9 = getelementptr inbounds [1048576 x %struct.fp_addr_recorded_t], [1048576 x %struct.fp_addr_recorded_t]* @cached_fp_addrs, i64 0, i64 %12
  %fp_addr10 = getelementptr inbounds %struct.fp_addr_recorded_t, %struct.fp_addr_recorded_t* %arrayidx9, i32 0, i32 0
  %13 = load i64, i64* %fp_addr10, align 16
  %14 = load i64, i64* %fp_addr.addr, align 8
  %cmp11 = icmp eq i64 %13, %14
  br i1 %cmp11, label %if.then, label %if.end22

if.then:                                          ; preds = %while.body
  %call12 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([45 x i8], [45 x i8]* @.str.16, i64 0, i64 0))
  %15 = load i64, i64* %x, align 8
  %arrayidx13 = getelementptr inbounds [1048576 x %struct.fp_addr_recorded_t], [1048576 x %struct.fp_addr_recorded_t]* @cached_fp_addrs, i64 0, i64 %15
  %recorded = getelementptr inbounds %struct.fp_addr_recorded_t, %struct.fp_addr_recorded_t* %arrayidx13, i32 0, i32 1
  %16 = load i64, i64* %recorded, align 8
  %cmp14 = icmp eq i64 %16, 0
  br i1 %cmp14, label %if.then15, label %if.else

if.then15:                                        ; preds = %if.then
  %call16 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([71 x i8], [71 x i8]* @.str.17, i64 0, i64 0))
  %call17 = call i32 @debrt_profile_update_recorded_funcs(i32 2)
  %17 = load i64, i64* %x, align 8
  %arrayidx18 = getelementptr inbounds [1048576 x %struct.fp_addr_recorded_t], [1048576 x %struct.fp_addr_recorded_t]* @cached_fp_addrs, i64 0, i64 %17
  %recorded19 = getelementptr inbounds %struct.fp_addr_recorded_t, %struct.fp_addr_recorded_t* %arrayidx18, i32 0, i32 1
  store i64 1, i64* %recorded19, align 8
  br label %if.end

if.else:                                          ; preds = %if.then
  %call20 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([67 x i8], [67 x i8]* @.str.18, i64 0, i64 0))
  %call21 = call i32 @debrt_profile_update_recorded_funcs(i32 1)
  br label %if.end

if.end:                                           ; preds = %if.else, %if.then15
  store i32 0, i32* %retval, align 4
  br label %return

if.end22:                                         ; preds = %while.body
  %18 = load i64, i64* %x, align 8
  %add = add nsw i64 %18, 1
  %and = and i64 %add, 1048576
  store i64 %and, i64* %x, align 8
  %19 = load i64, i64* %x, align 8
  %20 = load i64, i64* %x_start, align 8
  %cmp23 = icmp eq i64 %19, %20
  br i1 %cmp23, label %if.then24, label %if.end25

if.then24:                                        ; preds = %if.end22
  call void @__assert_fail(i8* getelementptr inbounds ([46 x i8], [46 x i8]* @.str.6, i64 0, i64 0), i8* getelementptr inbounds ([8 x i8], [8 x i8]* @.str.7, i64 0, i64 0), i32 202, i8* getelementptr inbounds ([37 x i8], [37 x i8]* @__PRETTY_FUNCTION__.ics_end_indirect_call, i64 0, i64 0)) #5
  unreachable

if.end25:                                         ; preds = %if.end22
  br label %while.cond

while.end:                                        ; preds = %while.cond
  %call26 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([191 x i8], [191 x i8]* @.str.19, i64 0, i64 0))
  store i32 1, i32* %retval, align 4
  br label %return

return:                                           ; preds = %while.end, %if.end
  %21 = load i32, i32* %retval, align 4
  ret i32 %21
}

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

declare i32 @debrt_protect_loop_end(i32) #1

; Function Attrs: argmemonly nounwind willreturn writeonly
declare void @llvm.memset.p0i8.i64(i8* nocapture writeonly, i8, i64, i1 immarg) #4

attributes #0 = { alwaysinline uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { nounwind }
attributes #3 = { noreturn nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #4 = { argmemonly nounwind willreturn writeonly }
attributes #5 = { noreturn nounwind }

!llvm.module.flags = !{!0, !1}
!llvm.ident = !{!2}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"PIC Level", i32 2}
!2 = !{!"clang version 11.0.0 (git@github.com:rudyjantz/llvm-project.git 9a8f8118d69154d0cb6684a1441330023de7e021)"}
