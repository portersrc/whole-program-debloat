#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>


int main(int argc, char *argv[])
{
    FILE *fp;
    void *null_bytes;

    if(argc != 4){
        printf("\n");
        printf("Zero out part of a file.\n");
        printf("\n");
        printf("  Usage: \n");
        printf("    ./zofp <file> <offset> <size>\n");
        printf("\n");
        exit(1);
    }

    char *lib = argv[1];
    int offset = (int) strtol(argv[2], NULL, 10);
    int size   = (int) strtol(argv[3], NULL, 10);

    null_bytes = malloc(size);
    memset(null_bytes, 0, size);

    //printf("lib: %s\n", lib);
    //printf("size: %d\n", size);
    //printf("offset: %d\n", offset);

    size_t rv;
    int e;
    fp = fopen(lib, "r+b");
    if(fp == NULL){
        e = errno;
        printf("fopen returned errno %d: %s\n", e, strerror(e));
        return e;
    }

    // debug: check size of the file
    //fseek(fp, 0L, SEEK_END);
    //long sz = ftell(fp);
    //printf("ftell sz: %ld\n", sz);
    //rewind(fp);

    e = fseek(fp, offset, 0);
    if(e == -1){
        e = errno;
        printf("fseek returned errno %d: %s\n", e, strerror(e));
        return e;
    }

    // debug: sanity check current position
    //long curr_pos = ftell(fp);
    //printf("ftell curr_pos: %ld\n", curr_pos);

    rv = fwrite(null_bytes, size, 1, fp);
    if(rv != 1){
        e = errno;
        printf("fwrite returned errno %d: %s\n", e, strerror(e));
        return e;
    }

    fclose(fp);

    return 0;
}
