; ModuleID = 'ics.cpp'
source_filename = "ics.cpp"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

@cached_fp_addrs = global [1048576 x i64] zeroinitializer, align 16
@cached_fp_addrs_idx = global i64 0, align 8

; Function Attrs: alwaysinline uwtable
define i32 @ics_map_indirect_call(i64 %fp_addr) #0 {
entry:
  %retval = alloca i32, align 4
  %fp_addr.addr = alloca i64, align 8
  %x = alloca i64, align 8
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
  %arrayidx = getelementptr inbounds [1048576 x i64], [1048576 x i64]* @cached_fp_addrs, i64 0, i64 %7
  %8 = load i64, i64* %arrayidx, align 8
  %9 = load i64, i64* %fp_addr.addr, align 8
  %cmp = icmp eq i64 %8, %9
  br i1 %cmp, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  store i32 0, i32* %retval, align 4
  br label %return

if.end:                                           ; preds = %entry
  %10 = load i64, i64* %fp_addr.addr, align 8
  %call = call i32 @debrt_protect_indirect(i64 %10)
  %cmp6 = icmp eq i32 %call, 0
  br i1 %cmp6, label %if.then7, label %if.end9

if.then7:                                         ; preds = %if.end
  %11 = load i64, i64* %fp_addr.addr, align 8
  %12 = load i64, i64* %x, align 8
  %arrayidx8 = getelementptr inbounds [1048576 x i64], [1048576 x i64]* @cached_fp_addrs, i64 0, i64 %12
  store i64 %11, i64* %arrayidx8, align 8
  br label %if.end9

if.end9:                                          ; preds = %if.then7, %if.end
  store i32 0, i32* %retval, align 4
  br label %return

return:                                           ; preds = %if.end9, %if.then
  %13 = load i32, i32* %retval, align 4
  ret i32 %13
}

declare i32 @debrt_protect_indirect(i64) #1

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

declare i32 @debrt_protect_loop_end(i32) #1

; Function Attrs: argmemonly nounwind willreturn writeonly
declare void @llvm.memset.p0i8.i64(i8* nocapture writeonly, i8, i64, i1 immarg) #2

attributes #0 = { alwaysinline uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { argmemonly nounwind willreturn writeonly }

!llvm.module.flags = !{!0, !1}
!llvm.ident = !{!2}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"PIC Level", i32 2}
!2 = !{!"clang version 11.0.0 (git@github.com:rudyjantz/llvm-project.git 9a8f8118d69154d0cb6684a1441330023de7e021)"}
