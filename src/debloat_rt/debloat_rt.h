#ifndef DEBLOAT_RT_H
#define DEBLOAT_RT_H

extern "C" {
int debrt_monitor(int argc, ...);

int debrt_protect(int argc, ...);
int debrt_protect_end(int argc, ...);

int debrt_protect_indirect(long long fp_value);
int debrt_protect_end_indirect(long long fp_value);

int debrt_protect_sequence(int argc, ...);

int debrt_return(long long);

int debrt_protect_loop(int argc, ...);
int debrt_protect_loop_end(int argc, ...);

int debrt_cgmonitor(int argc, ...);
int debrt_cgreturn(long long);

}

#endif
