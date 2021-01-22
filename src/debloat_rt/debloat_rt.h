#ifndef DEBLOAT_RT_H
#define DEBLOAT_RT_H

extern "C" {
int debrt_monitor(int argc, ...);

int debrt_protect(int argc, ...);

//int debrt_return(int);
//int debrt_return(void *);
int debrt_return(long long);

int debrt_protect_loop(int argc, ...);
int debrt_loop_end(void);

}

#endif
