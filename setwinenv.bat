

:: LLVM 11.0.0
:: set LLVM_DIR=%USERPROFILE%/h/wo/llvm/llvm-project
:: set LLVM_BIN=%LLVM_DIR%/build/Debug/bin
set LLVM_DIR=%USERPROFILE%/h/wo/llvm/llvm-project/build/lib/cmake/llvm
:: set LLVM_BIN=%USERPROFILE%/h/wo/llvm/llvm-project/build/Debug/bin
:: set LLVM_DIR=%USERPROFILE%/h/wo/llvm/llvm-project

:: set PROJ_DIR=%USERPROFILE%/h/wo/whole-program-debloat
:: set PROJ_DEBRT_LIB=%PROJ_DIR%/build/debloat_rt
:: set PROJ_PASS_WPD=%PROJ_DIR%/build/passes/wpd


:: set PATH=%PATH%;%LLVM_BIN%
:: export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$PROJ_DEBRT_LIB:$PROJ_PASS_PROFILING:$PROJ_PASS_RUNTIME:$PROJ_PASS_CG_PREDICT:$PROJ_PASS_WPD:$PROJ_PASS_LS
:: export LIBRARY_PATH=$LIBRARY_PATH:$PROJ_DEBRT_LIB