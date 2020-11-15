#include <stdio.h>
#include <stdarg.h>
#include <stdlib.h>
#include <errno.h>                                                              


//#define PREDICTED_FUNCS_SET_SIZE 5


char *CSV_COLUMNS = "callsite_id," \
                    "called_func_id," \
                    "called_func_arg1," \
                    "called_func_arg2," \
                    "...";

char *DEFAULT_OUTPUT_FILENAME = "debprof.out";
FILE *fp_out;

int _debprof_init(void);
void _debprof_destroy(void);

//int function_set_id_counter = 0;

//int last_funcs_seen[PREDICTED_FUNCS_SET_SIZE];
//int lfs_idx = 0


//
// Receives a variable number of arguments:
// argc: Nnumber of args to follow.
// Function ID
// Callsite ID
// called func arg1 (optional)
// called func arg2 (optional)
// ...
// called func argn (optional)
// 
/*int debprof_print_args(int argc, ...)
{
    static int lib_initialized = 0;
    static int funcs_seen_count = 0;
    int i;
    int curr_func_id;
    va_list ap;

    if(!lib_initialized){
        lib_initialized = 1;
        _debprof_init(); // ignore return
    }

    va_start(ap, argc);
    curr_func_id = va_arg(ap, int);
    last_funcs_seen[lfs_idx] = curr_func_id;
    lfs_idx = (lfs_idx + 1) % PREDICTED_FUNCS_SET_SIZE

    funcs_seen_count++;
    if(funcs_seen_count < PREDICTED_FUNCS_SET_SIZE){
        va_end(ap);
        return 0;
    }

    funcs_seen_count = PREDICTED_FUNCS_SET_SIZE; // never overflows

    fprintf(fp_out, "%d", curr_func_id);

    fprintf(fp_out, ",%d", curr_func_id);
    for(i = 1; i < argc; i++){
        fprintf(fp_out, ",%d", va_arg(ap, int));
    }
    fprintf(fp_out, "\n");

    va_end(ap);
    return 0;
}*/
int debprof_print_args(int argc, ...)
{
    static int lib_initialized = 0;
    int i;
    va_list ap;

    if(!lib_initialized){
        _debprof_init(); // ignore return
        lib_initialized = 1;
    }

    va_start(ap, argc);

    fprintf(fp_out, "%d", va_arg(ap, int));
    for(i = 1; i < argc; i++){
        fprintf(fp_out, ",%d", va_arg(ap, int));
    }
    fprintf(fp_out, "\n");

    va_end(ap);
    return 0;
}


int _debprof_init(void)
{
    int e;
    char *output_filename;

    output_filename = getenv("DEBPROF_OUT");
    if(!output_filename){
        output_filename = DEFAULT_OUTPUT_FILENAME;
    }
    fp_out = fopen(output_filename, "w");
    if(!fp_out){
        e = errno;
        fprintf(stderr, "debprof_init failed to open %s (errno: %d)\n",
                        output_filename, e);
        return e;
    }
    fprintf(fp_out, "%s\n", CSV_COLUMNS);

    atexit(_debprof_destroy);
    return 0;
}


void _debprof_destroy(void)
{
    int e;
    int rc;
    rc = fclose(fp_out);
    if(rc == EOF){
        e = errno;
        fprintf(stderr, "debprof_destroy failed to close output file " \
                        "(errno: %d)\n", e);
    }
}
