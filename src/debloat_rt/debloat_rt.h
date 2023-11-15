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

int debrt_profile_print_args_0(int func_or_loop_id, int deck_id);
int debrt_profile_print_args_1(int func_or_loop_id, int deck_id,
  int arg1);
int debrt_profile_print_args_2(int func_or_loop_id, int deck_id,
  int arg1, int arg2);
int debrt_profile_print_args_3(int func_or_loop_id, int deck_id,
  int arg1, int arg2, int arg3);
int debrt_profile_print_args_4(int func_or_loop_id, int deck_id,
  int arg1, int arg2, int arg3, int arg4);
int debrt_profile_print_args_5(int func_or_loop_id, int deck_id,
  int arg1, int arg2, int arg3, int arg4, int arg5);

int debrt_profile_indirect_print_args_0(long long fp_addr, long long deck_id);
int debrt_profile_indirect_print_args_1(long long fp_addr, long long deck_id,
  long long arg1);
int debrt_profile_indirect_print_args_2(long long fp_addr, long long deck_id,
  long long arg1, long long arg2);
int debrt_profile_indirect_print_args_3(long long fp_addr, long long deck_id,
  long long arg1, long long arg2, long long arg3);
int debrt_profile_indirect_print_args_4(long long fp_addr, long long deck_id,
  long long arg1, long long arg2, long long arg3, long long arg4);
int debrt_profile_indirect_print_args_5(long long fp_addr, long long deck_id,
  long long arg1, long long arg2, long long arg3, long long arg4, long long arg5);

int debrt_profile_indirect_print_args_ics(long long *varargs);
int debrt_profile_update_recorded_funcs(int and_dump);


int debrt_test_predict_trace(int func_id);

int debrt_test_predict_predict_0(int func_or_loop_id, int deck_id);
int debrt_test_predict_predict_1(int func_or_loop_id, int deck_id,
  int arg1);
int debrt_test_predict_predict_2(int func_or_loop_id, int deck_id,
  int arg1, int arg2);
int debrt_test_predict_predict_3(int func_or_loop_id, int deck_id,
  int arg1, int arg2, int arg3);
int debrt_test_predict_predict_4(int func_or_loop_id, int deck_id,
  int arg1, int arg2, int arg3, int arg4);
int debrt_test_predict_predict_5(int func_or_loop_id, int deck_id,
  int arg1, int arg2, int arg3, int arg4, int arg5);

int debrt_test_predict_indirect_predict_0(long long fp_addr, long long deck_id);
int debrt_test_predict_indirect_predict_1(long long fp_addr, long long deck_id,
  long long arg1);
int debrt_test_predict_indirect_predict_2(long long fp_addr, long long deck_id,
  long long arg1, long long arg2);
int debrt_test_predict_indirect_predict_3(long long fp_addr, long long deck_id,
  long long arg1, long long arg2, long long arg3);
int debrt_test_predict_indirect_predict_4(long long fp_addr, long long deck_id,
  long long arg1, long long arg2, long long arg3, long long arg4);
int debrt_test_predict_indirect_predict_5(long long fp_addr, long long deck_id,
  long long arg1, long long arg2, long long arg3, long long arg4, long long arg5);

int debrt_test_predict_indirect_predict_ics(long long *varargs);


int debrt_release_predict_0(int func_or_loop_id, int deck_id);
int debrt_release_predict_1(int func_or_loop_id, int deck_id,
  int arg1);
int debrt_release_predict_2(int func_or_loop_id, int deck_id,
  int arg1, int arg2);
int debrt_release_predict_3(int func_or_loop_id, int deck_id,
  int arg1, int arg2, int arg3);
int debrt_release_predict_4(int func_or_loop_id, int deck_id,
  int arg1, int arg2, int arg3, int arg4);
int debrt_release_predict_5(int func_or_loop_id, int deck_id,
  int arg1, int arg2, int arg3, int arg4, int arg5);

int debrt_release_rectify(int func_id);

int debrt_release_indirect_predict_0(long long fp_addr, long long deck_id);
int debrt_release_indirect_predict_1(long long fp_addr, long long deck_id,
  long long arg1);
int debrt_release_indirect_predict_2(long long fp_addr, long long deck_id,
  long long arg1, long long arg2);
int debrt_release_indirect_predict_3(long long fp_addr, long long deck_id,
  long long arg1, long long arg2, long long arg3);
int debrt_release_indirect_predict_4(long long fp_addr, long long deck_id,
  long long arg1, long long arg2, long long arg3, long long arg4);
int debrt_release_indirect_predict_5(long long fp_addr, long long deck_id,
  long long arg1, long long arg2, long long arg3, long long arg4, long long arg5);

int debrt_release_indirect_predict_ics(long long num_args, long long fp_addr, va_list args);

}

#endif
