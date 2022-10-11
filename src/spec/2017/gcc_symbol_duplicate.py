from os import listdir
from os.path import isfile, join
from shutil import copyfile

onlyfiles = [f for f in listdir(".") if isfile(f) and ".bc" in f]
onlyfiles.remove("main.bc")
remove = ["@getchar()", "@vprintf(i8*", "@fgetc_unlocked(%struct._IO_FILE*", "@getc_unlocked(%struct._IO_FILE*", "@getchar_unlocked()", "@putchar(i32", "@fputc_unlocked(i32", 
"@putc_unlocked(i32", "@putchar_unlocked(i32", "@getline(i8**", "@feof_unlocked(%struct._IO_FILE*", "@ferror_unlocked(%struct._IO_FILE*", "@tolower(i32", "@toupper(i32", 
"@gnu_dev_major(i64", "@gnu_dev_minor(i64", "@gnu_dev_makedev(i32", "@atoi(i8*", "@atol(i8*", "@atoll(i8*", "@bsearch(i8*", "@atof(i8*", "@strtoimax(i8*", "@strtoumax(i8*", 
"@wcstoimax(i32*", "@wcstoumax(i32*", "@stat(i8*", "@lstat(i8*", "@fstat(i32", "@fstatat(i32", "@mknod(i8*", "@mknodat(i32", "@stat64(i8*", "@lstat64(i8*", "@fstat64(i32", "@fstatat64(i32"]

#onlyfiles = ["main.bc"]
for f in onlyfiles:
    string = ""
    with open(f, 'r') as read:
        line = read.readline()
        while(line):
            temp = ""
            temp += line
            line = line.strip()
            lst = line.split()
            if(len(lst) >= 2 and lst[1] == "Function"):
                line = read.readline()
                temp += line
                line = line.strip()
                lst = line.split()
                if(lst[2] in remove):
                    temp = ""
                    line = read.readline()
                    while(line):
                        lst = line.strip().split()
                        if(len(lst) >= 1 and lst[0] == "}"):
                            break
                        line = read.readline()
            string += temp
                    
            line = read.readline()

    with open("sharjeel.txt", 'w') as write:
        write.write(string)
    
    copyfile("sharjeel.txt",f)