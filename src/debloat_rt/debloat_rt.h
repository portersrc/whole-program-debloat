#ifndef DEBLOAT_RT_H
#define DEBLOAT_RT_H

extern "C" {

int debrt_init(int main_func_id, int sink_is_enabled);
int debrt_destroy(int notused);

int debrt_protect_single(int callee_func_id);
int debrt_protect_single_end(int callee_func_id);

int debrt_protect_reachable(int callee_func_id);
int debrt_protect_reachable_end(int callee_func_id);

int debrt_protect_loop(int loop_id);
int debrt_protect_loop_end(int loop_id);

int debrt_protect_indirect(long long callee_addr);
int debrt_protect_indirect_end(long long callee_addr);

int debrt_protect_sink(int sink_id);
int debrt_protect_sink_end(int sink_id);

int debrt_profile_trace(int func_id);
int debrt_profile_print_args(int argc, ...);
int debrt_profile_indirect_print_args(long long argc, ...);
int debrt_profile_indirect_print_args_ics(long long *varargs);
int debrt_profile_update_recorded_funcs(int and_dump);

int debrt_test_predict_trace(int func_id);
int debrt_test_predict_predict(int argc, ...);
int debrt_test_predict_indirect_predict(long long argc, ...);
int debrt_test_predict_indirect_predict_ics(long long *varargs);

int debrt_release_predict(int argc, ...);
int debrt_release_rectify(int func_id);
int debrt_release_indirect_predict(long long argc, ...);
int debrt_release_indirect_predict_ics(long long *varargs);

}

#endif
