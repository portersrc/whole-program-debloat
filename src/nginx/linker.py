import argparse
import sys

# Parse Arguments
parser = argparse.ArgumentParser()
parser.add_argument("folder", help="Folder where all the files are located", type=str)
args = parser.parse_args()

folder = args.folder
if(folder[-1] != "/"):
    folder = folder + "/"

# Read file that contains id mapping to function names
id_to_func = {}
with open(folder+"wpd_func_name_to_id.txt", "r") as f:
    line = f.readline()
    while(line):
        line_list = line.strip().split()
        id_to_func[int(line_list[1])] = line_list[0]
        line = f.readline()
#print(id_to_func)
#sys.exit(42)

# Read file containing the disjoint sets
sets = {}
with open(folder+"wpd_disjoint_sets.txt", "r") as f:
    line = f.readline()
    index = 0
    while(line):
        line_list = line.strip().split()
        sets[index] = line_list[1:]
        line = f.readline()
        index += 1
#print(sets)
#sys.exit(42)

write = False
with open(folder+"wpd-linker-script.lds", "w") as w:
    with open(folder+"linker.lds", "r") as r:
        line = r.readline()
        #print('reading first line: {}.'.format(line))
        while(line):
            line = line.strip()
            if(write):
                if(line == ""):
                    #print('line was empty, breaking')
                    break
                #else:
                #    print('nonempty line')
                
                if(len(sets) != 0):
                    #if("*(.text .stub .text.* .gnu.linkonce.t.*)" in line):
                    if("*(.text)" in line):
                        #w.write("*(.stub .gnu.linkonce.t.*)\n")
                        w.write("*(.text)\n")

                        for key in sets:
                            w.write(". = ALIGN(0x1000);\n")
                            s = "*("
                            for val in sets[key]:
                                #s += ".text."+id_to_func[int(val)]+" "
                                # cporter: put a leading underscore before function symbol because of windows
                                #s += ".text._"+id_to_func[int(val)]+" "
                                # cporter: just trying shit at this point
                                #s += "_"+id_to_func[int(val)]+" "
                                # cporter: just trying shit at this point
                                s += ".text$"+id_to_func[int(val)]+" "
                            s = s[:-1] + ")\n"
                            w.write(s)

                        w.write(". = ALIGN(0x1000);\n")
                        w.write("*(.text.*)\n")
                    elif(line.split() == [".text",":"]):
                        w.write(".text ALIGN(0x1000):\n")
                    elif(line.split() == [".fini",":"]):
                        w.write(".fini ALIGN(0x1000):\n")
                    else:
                        w.write(line+"\n")
                else:
                    w.write(line+"\n")
            
            if(line == "=================================================="):
                print('setting write to true')
                write = True
            
            line = r.readline()
            
