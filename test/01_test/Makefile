all:
	clang \
      -emit-llvm \
      -fPIC \
      -c main.c \
      -o main.bc
	opt \
      -load libWholeProgramDebloat.so -WholeProgramDebloat \
      < main.bc \
      > main_mod.bc
	llc \
      -relocation-model=pic \
      main_mod.bc \
      -o main_mod.s
	g++ main_mod.s -o a.out -ldebloat_rt
	readelf -s --wide a.out > readelf.out
	nm a.out > nm.out
.PHONY: all

clean:
	rm -f *.ll *.bc *.s a.out nm.out readelf.out wpd_func_name_to_id.txt debrt.out
.PHONY: clean
