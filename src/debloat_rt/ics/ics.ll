; ModuleID = 'ics.cpp'
source_filename = "ics.cpp"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

@cached_fp_addrs = global [1048576 x i64] zeroinitializer, align 16
@cached_fp_addrs_idx = global i64 0, align 8

; Function Attrs: alwaysinline uwtable
define i32 @ics_map_indirect_call(i64 %0) #0 {
  %2 = alloca i32, align 4
  %3 = alloca i64, align 8
  %4 = alloca i64, align 8
  store i64 %0, i64* %3, align 8
  %5 = load i64, i64* %3, align 8
  store i64 %5, i64* %4, align 8
  %6 = load i64, i64* %4, align 8
  %7 = load i64, i64* %4, align 8
  %8 = ashr i64 %7, 30
  %9 = xor i64 %6, %8
  %10 = mul i64 %9, -4658895280553007687
  store i64 %10, i64* %4, align 8
  %11 = load i64, i64* %4, align 8
  %12 = load i64, i64* %4, align 8
  %13 = ashr i64 %12, 27
  %14 = xor i64 %11, %13
  %15 = mul i64 %14, -7723592293110705685
  store i64 %15, i64* %4, align 8
  %16 = load i64, i64* %4, align 8
  %17 = load i64, i64* %4, align 8
  %18 = ashr i64 %17, 31
  %19 = xor i64 %16, %18
  %20 = srem i64 %19, 1048576
  store i64 %20, i64* %4, align 8
  %21 = load i64, i64* %4, align 8
  %22 = getelementptr inbounds [1048576 x i64], [1048576 x i64]* @cached_fp_addrs, i64 0, i64 %21
  %23 = load i64, i64* %22, align 8
  %24 = load i64, i64* %3, align 8
  %25 = icmp eq i64 %23, %24
  br i1 %25, label %26, label %27

26:                                               ; preds = %1
  store i32 0, i32* %2, align 4
  br label %36

27:                                               ; preds = %1
  %28 = load i64, i64* %3, align 8
  %29 = call i32 @debrt_protect_indirect(i64 %28)
  %30 = icmp eq i32 %29, 0
  br i1 %30, label %31, label %35

31:                                               ; preds = %27
  %32 = load i64, i64* %3, align 8
  %33 = load i64, i64* %4, align 8
  %34 = getelementptr inbounds [1048576 x i64], [1048576 x i64]* @cached_fp_addrs, i64 0, i64 %33
  store i64 %32, i64* %34, align 8
  br label %35

35:                                               ; preds = %31, %27
  store i32 0, i32* %2, align 4
  br label %36

36:                                               ; preds = %35, %26
  %37 = load i32, i32* %2, align 4
  ret i32 %37
}

declare i32 @debrt_protect_indirect(i64) #1

; Function Attrs: alwaysinline uwtable
define i32 @ics_wrapper_debrt_protect_loop_end(i32 %0) #0 {
  %2 = alloca i32, align 4
  store i32 %0, i32* %2, align 4
  %3 = load i32, i32* %2, align 4
  %4 = call i32 @debrt_protect_loop_end(i32 %3)
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
!2 = !{!"clang version 11.0.0 (https://github.com/portersrc/llvm-project.git 9a8f8118d69154d0cb6684a1441330023de7e021)"}
