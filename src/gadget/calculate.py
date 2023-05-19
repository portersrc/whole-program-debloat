# Standard Library Imports
import argparse
import sys
import os

# Parse Arguments
parser = argparse.ArgumentParser()
parser.add_argument("--A", help="Look at Group A benchmarks of Spec", action='store_true')
parser.add_argument("--B", help="Look at Group B benchmarks of Spec", action='store_true')
parser.add_argument("--C", help="Look at Group C benchmarks of Spec", action='store_true')
parser.add_argument("--D", help="Look at Group D benchmarks of Spec", action='store_true')
parser.add_argument("--E", help="Example to test script", action='store_true')
parser.add_argument("--base", help="Produce Gadget results for Base Code", action='store_true')
parser.add_argument("--linker", help="Produce Gadget results for Base Code with Linker Script", action='store_true')
parser.add_argument("--sink", help="Produce Gadget results for Sink Code", action='store_true')
parser.add_argument("--sink_linker", help="Produce Gadget results for Sink Code with Linker Script", action='store_true')
parser.add_argument("--ics", help="Produce Gadget results for ICS Code", action='store_true')
parser.add_argument("--ics_linker", help="Produce Gadget results for ICS Code with Linker Script", action='store_true')
parser.add_argument("--ics_sc_linker", help="Produce Gadget results for ICS Code with Linker Script", action='store_true')

args = parser.parse_args()

all_spec_benchs = ["500.perlbench_r", "502.gcc_r", "505.mcf_r", "508.namd_r", "510.parest_r", "511.povray_r", "519.lbm_r", "520.omnetpp_r", "523.xalancbmk_r", "525.x264_r", "526.blender_r", "531.deepsjeng_r", "538.imagick_r", "541.leela_r", "544.nab_r", "557.xz_r"]
print_benchs = []
curr_benchs = []
groupA = ["505.mcf_r", "519.lbm_r", "531.deepsjeng_r", "541.leela_r", "544.nab_r", "557.xz_r"]
groupB = ["500.perlbench_r", "508.namd_r", "511.povray_r", "520.omnetpp_r", "523.xalancbmk_r", "525.x264_r"]
#groupB = ["500.perlbench_r", "511.povray_r", "520.omnetpp_r", "523.xalancbmk_r", "525.x264_r"]
groupC = ["510.parest_r", "526.blender_r", "538.imagick_r"]
groupD = ["502.gcc_r"]
#groupE = ["502.gcc_r","520.omnetpp_r"]
groupE = ["500.perlbench_r"]
maxROP = {}
maxCOP = {}
maxJOP = {}
maxOther = {}
maxTotal = {}
minROP = {}
minCOP = {}
minJOP = {}
minOther = {}
minTotal = {}
avgROP = {}
avgCOP = {}
avgJOP = {}
avgOther = {}
avgTotal = {}
totalROP = {}
totalCOP = {}
totalJOP = {}
totalOther = {}
totalTotal = {}
first = {}

if(args.D):
    curr_benchs.extend(groupD)
    print_benchs = all_spec_benchs
if(args.A):
    curr_benchs.extend(groupA)
    print_benchs = all_spec_benchs
if(args.B):
    curr_benchs.extend(groupB)
    print_benchs = all_spec_benchs
if(args.C):
    curr_benchs.extend(groupC)
    print_benchs = all_spec_benchs
if(args.E):
    curr_benchs.extend(groupE)
    print_benchs = all_spec_benchs

if(args.base):
    for bench in curr_benchs:
        f = open("resultswpd/"+bench+"/GadgetCounts_Reduction.csv", 'r')
        line = f.readline()
        line = f.readline().strip()
        split = line.split(",")[1:]
        first[bench] = bench + "," + ",".join(split) + "\r"
        split = [int(i) for i in split]
        totalROP[bench], totalJOP[bench], totalCOP[bench], totalOther[bench], totalTotal[bench] = split
        count = 0
        ROPsum, COPsum, JOPsum, Othersum, Totalsum = 0, 0, 0, 0, 0
        ROPmax, ROPmin = 0,split[0]
        JOPmax, JOPmin = 0,split[1]
        COPmax, COPmin = 0,split[2]
        Othermax, Othermin = 0,split[3]
        Totalmax, Totalmin = 0,split[4]
        line = f.readline()
        while(line):
            line = line.strip()
            split = line.split(",")[1:]
            split = [int(i) for i in split]
            ROPsum += split[0]
            ROPmax = max(ROPmax, split[0])
            ROPmin = min(ROPmin, split[0])
            JOPsum += split[1]
            JOPmax = max(JOPmax, split[1])
            JOPmin = min(JOPmin, split[1])
            COPsum += split[2]
            COPmax = max(COPmax, split[2])
            COPmin = min(COPmin, split[2])
            Othersum += split[3]
            Othermax = max(Othermax, split[3])
            Othermin = min(Othermin, split[3])
            Totalsum += split[4]
            Totalmax = max(Totalmax, split[4])
            Totalmin = min(Totalmin, split[4])
            count += 1
            line = f.readline()
        maxROP[bench] = ROPmax
        minROP[bench] = ROPmin
        avgROP[bench] = ROPsum / count
        maxCOP[bench] = COPmax
        minCOP[bench] = COPmin
        avgCOP[bench] = COPsum / count
        maxJOP[bench] = JOPmax
        minJOP[bench] = JOPmin
        avgJOP[bench] = JOPsum / count
        maxOther[bench] = Othermax
        minOther[bench] = Othermin
        avgOther[bench] = Othersum / count
        maxTotal[bench] = Totalmax
        minTotal[bench] = Totalmin
        avgTotal[bench] = Totalsum / count 
        f.close()
                
    output = ",ROP,JOP,COP,Special,Total\r"
    for bench in print_benchs:
        if(bench not in first):
            output += bench + "\r"
        else:
            output += first[bench]
    output += "\r"
    output += "ROP,total,max,min-decrease,min,max-decrease,avg,avg-decrease\r"
    for bench in print_benchs:
        if(bench not in first):
            output += bench + "\r"
        else:
            total = totalROP[bench]
            actual_total = total
            if(total == 0):
                total = 1
            ma = maxROP[bench]
            mi = minROP[bench]
            avg = avgROP[bench]
            output += bench + "," + str(actual_total) + "," + str(ma) + "," + str((100 - (ma*100/total))) + "," + str(mi) + "," + str((100 - (mi*100/total))) + "," + str(avg) + "," + str((100 - (avg*100/total))) + "\r"
    output += "\r"
    output += "JOP,total,max,min-decrease,min,max-decrease,avg,avg-decrease\r"
    for bench in print_benchs:
        if(bench not in first):
            output += bench + "\r"
        else:
            total = totalJOP[bench]
            actual_total = total
            if(total == 0):
                total = 1
            ma = maxJOP[bench]
            mi = minJOP[bench]
            avg = avgJOP[bench]
            output += bench + "," + str(actual_total) + "," + str(ma) + "," + str((100 - (ma*100/total))) + "," + str(mi) + "," + str((100 - (mi*100/total))) + "," + str(avg) + "," + str((100 - (avg*100/total))) + "\r"
    output += "\r"
    output += "COP,total,max,min-decrease,min,max-decrease,avg,avg-decrease\r"
    for bench in print_benchs:
        if(bench not in first):
            output += bench + "\r"
        else:
            total = totalCOP[bench]
            actual_total = total
            if(total == 0):
                total = 1
            ma = maxCOP[bench]
            mi = minCOP[bench]
            avg = avgCOP[bench]
            output += bench + "," + str(actual_total) + "," + str(ma) + "," + str((100 - (ma*100/total))) + "," + str(mi) + "," + str((100 - (mi*100/total))) + "," + str(avg) + "," + str((100 - (avg*100/total))) + "\r"
    output += "\r"
    output += "Special,total,max,min-decrease,min,max-decrease,avg,avg-decrease\r"
    for bench in print_benchs:
        if(bench not in first):
            output += bench + "\r"
        else:
            total = totalOther[bench]
            actual_total = total
            if(total == 0):
                total = 1
            ma = maxOther[bench]
            mi = minOther[bench]
            avg = avgOther[bench]
            output += bench + "," + str(actual_total) + "," + str(ma) + "," + str((100 - (ma*100/total))) + "," + str(mi) + "," + str((100 - (mi*100/total))) + "," + str(avg) + "," + str((100 - (avg*100/total))) + "\r"
    output += "\r"
    output += "Total,total,max,min-decrease,min,max-decrease,avg,avg-decrease\r"
    for bench in print_benchs:
        if(bench not in first):
            output += bench + "\r"
        else:
            total = totalTotal[bench]
            actual_total = total
            if(total == 0):
                total = 1
            ma = maxTotal[bench]
            mi = minTotal[bench]
            avg = avgTotal[bench]
            output += bench + "," + str(actual_total) + "," + str(ma) + "," + str((100 - (ma*100/total))) + "," + str(mi) + "," + str((100 - (mi*100/total))) + "," + str(avg) + "," + str((100 - (avg*100/total))) + "\r"
    
    with open("base.csv", 'w') as write:
        write.write(output)

maxROP = {}
maxCOP = {}
maxJOP = {}
maxOther = {}
maxTotal = {}
minROP = {}
minCOP = {}
minJOP = {}
minOther = {}
minTotal = {}
avgROP = {}
avgCOP = {}
avgJOP = {}
avgOther = {}
avgTotal = {}
totalROP = {}
totalCOP = {}
totalJOP = {}
totalOther = {}
totalTotal = {}
first = {}

if(args.linker):
    for bench in curr_benchs:
        f = open("resultswpd_cl/"+bench+"/GadgetCounts_Reduction.csv", 'r')
        line = f.readline()
        line = f.readline().strip()
        split = line.split(",")[1:]
        first[bench] = bench + "," + ",".join(split) + "\r"
        split = [int(i) for i in split]
        totalROP[bench], totalJOP[bench], totalCOP[bench], totalOther[bench], totalTotal[bench] = split
        count = 0
        ROPsum, COPsum, JOPsum, Othersum, Totalsum = 0, 0, 0, 0, 0
        ROPmax, ROPmin = 0,split[0]
        JOPmax, JOPmin = 0,split[1]
        COPmax, COPmin = 0,split[2]
        Othermax, Othermin = 0,split[3]
        Totalmax, Totalmin = 0,split[4]
        line = f.readline()
        while(line):
            line = line.strip()
            split = line.split(",")[1:]
            split = [int(i) for i in split]
            ROPsum += split[0]
            ROPmax = max(ROPmax, split[0])
            ROPmin = min(ROPmin, split[0])
            JOPsum += split[1]
            JOPmax = max(JOPmax, split[1])
            JOPmin = min(JOPmin, split[1])
            COPsum += split[2]
            COPmax = max(COPmax, split[2])
            COPmin = min(COPmin, split[2])
            Othersum += split[3]
            Othermax = max(Othermax, split[3])
            Othermin = min(Othermin, split[3])
            Totalsum += split[4]
            Totalmax = max(Totalmax, split[4])
            Totalmin = min(Totalmin, split[4])
            count += 1
            line = f.readline()
        maxROP[bench] = ROPmax
        minROP[bench] = ROPmin
        avgROP[bench] = ROPsum / count
        maxCOP[bench] = COPmax
        minCOP[bench] = COPmin
        avgCOP[bench] = COPsum / count
        maxJOP[bench] = JOPmax
        minJOP[bench] = JOPmin
        avgJOP[bench] = JOPsum / count
        maxOther[bench] = Othermax
        minOther[bench] = Othermin
        avgOther[bench] = Othersum / count
        maxTotal[bench] = Totalmax
        minTotal[bench] = Totalmin
        avgTotal[bench] = Totalsum / count 
        f.close()
    
    output = ",ROP,JOP,COP,Special,Total\r"
    for bench in print_benchs:
        if(bench not in first):
            output += bench + "\r"
        else:
            output += first[bench]
    output += "\r"
    output += "ROP,total,max,min-decrease,min,max-decrease,avg,avg-decrease\r"
    for bench in print_benchs:
        if(bench not in first):
            output += bench + "\r"
        else:
            total = totalROP[bench]
            actual_total = total
            if(total == 0):
                total = 1
            ma = maxROP[bench]
            mi = minROP[bench]
            avg = avgROP[bench]
            output += bench + "," + str(actual_total) + "," + str(ma) + "," + str((100 - (ma*100/total))) + "," + str(mi) + "," + str((100 - (mi*100/total))) + "," + str(avg) + "," + str((100 - (avg*100/total))) + "\r"
    output += "\r"
    output += "JOP,total,max,min-decrease,min,max-decrease,avg,avg-decrease\r"
    for bench in print_benchs:
        if(bench not in first):
            output += bench + "\r"
        else:
            total = totalJOP[bench]
            actual_total = total
            if(total == 0):
                total = 1
            ma = maxJOP[bench]
            mi = minJOP[bench]
            avg = avgJOP[bench]
            output += bench + "," + str(actual_total) + "," + str(ma) + "," + str((100 - (ma*100/total))) + "," + str(mi) + "," + str((100 - (mi*100/total))) + "," + str(avg) + "," + str((100 - (avg*100/total))) + "\r"
    output += "\r"
    output += "COP,total,max,min-decrease,min,max-decrease,avg,avg-decrease\r"
    for bench in print_benchs:
        if(bench not in first):
            output += bench + "\r"
        else:
            total = totalCOP[bench]
            actual_total = total
            if(total == 0):
                total = 1
            ma = maxCOP[bench]
            mi = minCOP[bench]
            avg = avgCOP[bench]
            output += bench + "," + str(actual_total) + "," + str(ma) + "," + str((100 - (ma*100/total))) + "," + str(mi) + "," + str((100 - (mi*100/total))) + "," + str(avg) + "," + str((100 - (avg*100/total))) + "\r"
    output += "\r"
    output += "Special,total,max,min-decrease,min,max-decrease,avg,avg-decrease\r"
    for bench in print_benchs:
        if(bench not in first):
            output += bench + "\r"
        else:
            total = totalOther[bench]
            actual_total = total
            if(total == 0):
                total = 1
            ma = maxOther[bench]
            mi = minOther[bench]
            avg = avgOther[bench]
            output += bench + "," + str(actual_total) + "," + str(ma) + "," + str((100 - (ma*100/total))) + "," + str(mi) + "," + str((100 - (mi*100/total))) + "," + str(avg) + "," + str((100 - (avg*100/total))) + "\r"
    output += "\r"
    output += "Total,total,max,min-decrease,min,max-decrease,avg,avg-decrease\r"
    for bench in print_benchs:
        if(bench not in first):
            output += bench + "\r"
        else:
            total = totalTotal[bench]
            actual_total = total
            if(total == 0):
                total = 1
            ma = maxTotal[bench]
            mi = minTotal[bench]
            avg = avgTotal[bench]
            output += bench + "," + str(actual_total) + "," + str(ma) + "," + str((100 - (ma*100/total))) + "," + str(mi) + "," + str((100 - (mi*100/total))) + "," + str(avg) + "," + str((100 - (avg*100/total))) + "\r"
    
    with open("linker.csv", 'w') as write:
        write.write(output)

maxROP = {}
maxCOP = {}
maxJOP = {}
maxOther = {}
maxTotal = {}
minROP = {}
minCOP = {}
minJOP = {}
minOther = {}
minTotal = {}
avgROP = {}
avgCOP = {}
avgJOP = {}
avgOther = {}
avgTotal = {}
totalROP = {}
totalCOP = {}
totalJOP = {}
totalOther = {}
totalTotal = {}
first = {}

if(args.sink):
    for bench in curr_benchs:
        f = open("resultswpd_sink/"+bench+"/GadgetCounts_Reduction.csv", 'r')
        line = f.readline()
        line = f.readline().strip()
        split = line.split(",")[1:]
        first[bench] = bench + "," + ",".join(split) + "\r"
        split = [int(i) for i in split]
        totalROP[bench], totalJOP[bench], totalCOP[bench], totalOther[bench], totalTotal[bench] = split
        count = 0
        ROPsum, COPsum, JOPsum, Othersum, Totalsum = 0, 0, 0, 0, 0
        ROPmax, ROPmin = 0,split[0]
        JOPmax, JOPmin = 0,split[1]
        COPmax, COPmin = 0,split[2]
        Othermax, Othermin = 0,split[3]
        Totalmax, Totalmin = 0,split[4]
        line = f.readline()
        while(line):
            line = line.strip()
            split = line.split(",")[1:]
            split = [int(i) for i in split]
            ROPsum += split[0]
            ROPmax = max(ROPmax, split[0])
            ROPmin = min(ROPmin, split[0])
            JOPsum += split[1]
            JOPmax = max(JOPmax, split[1])
            JOPmin = min(JOPmin, split[1])
            COPsum += split[2]
            COPmax = max(COPmax, split[2])
            COPmin = min(COPmin, split[2])
            Othersum += split[3]
            Othermax = max(Othermax, split[3])
            Othermin = min(Othermin, split[3])
            Totalsum += split[4]
            Totalmax = max(Totalmax, split[4])
            Totalmin = min(Totalmin, split[4])
            count += 1
            line = f.readline()
        maxROP[bench] = ROPmax
        minROP[bench] = ROPmin
        avgROP[bench] = ROPsum / count
        maxCOP[bench] = COPmax
        minCOP[bench] = COPmin
        avgCOP[bench] = COPsum / count
        maxJOP[bench] = JOPmax
        minJOP[bench] = JOPmin
        avgJOP[bench] = JOPsum / count
        maxOther[bench] = Othermax
        minOther[bench] = Othermin
        avgOther[bench] = Othersum / count
        maxTotal[bench] = Totalmax
        minTotal[bench] = Totalmin
        avgTotal[bench] = Totalsum / count 
        f.close()
    
    output = ",ROP,JOP,COP,Special,Total\r"
    for bench in print_benchs:
        if(bench not in first):
            output += bench + "\r"
        else:
            output += first[bench]
    output += "\r"
    output += "ROP,total,max,min-decrease,min,max-decrease,avg,avg-decrease\r"
    for bench in print_benchs:
        if(bench not in first):
            output += bench + "\r"
        else:
            total = totalROP[bench]
            actual_total = total
            if(total == 0):
                total = 1
            ma = maxROP[bench]
            mi = minROP[bench]
            avg = avgROP[bench]
            output += bench + "," + str(actual_total) + "," + str(ma) + "," + str((100 - (ma*100/total))) + "," + str(mi) + "," + str((100 - (mi*100/total))) + "," + str(avg) + "," + str((100 - (avg*100/total))) + "\r"
    output += "\r"
    output += "JOP,total,max,min-decrease,min,max-decrease,avg,avg-decrease\r"
    for bench in print_benchs:
        if(bench not in first):
            output += bench + "\r"
        else:
            total = totalJOP[bench]
            actual_total = total
            if(total == 0):
                total = 1
            ma = maxJOP[bench]
            mi = minJOP[bench]
            avg = avgJOP[bench]
            output += bench + "," + str(actual_total) + "," + str(ma) + "," + str((100 - (ma*100/total))) + "," + str(mi) + "," + str((100 - (mi*100/total))) + "," + str(avg) + "," + str((100 - (avg*100/total))) + "\r"
    output += "\r"
    output += "COP,total,max,min-decrease,min,max-decrease,avg,avg-decrease\r"
    for bench in print_benchs:
        if(bench not in first):
            output += bench + "\r"
        else:
            total = totalCOP[bench]
            actual_total = total
            if(total == 0):
                total = 1
            ma = maxCOP[bench]
            mi = minCOP[bench]
            avg = avgCOP[bench]
            output += bench + "," + str(actual_total) + "," + str(ma) + "," + str((100 - (ma*100/total))) + "," + str(mi) + "," + str((100 - (mi*100/total))) + "," + str(avg) + "," + str((100 - (avg*100/total))) + "\r"
    output += "\r"
    output += "Special,total,max,min-decrease,min,max-decrease,avg,avg-decrease\r"
    for bench in print_benchs:
        if(bench not in first):
            output += bench + "\r"
        else:
            total = totalOther[bench]
            actual_total = total
            if(total == 0):
                total = 1
            ma = maxOther[bench]
            mi = minOther[bench]
            avg = avgOther[bench]
            output += bench + "," + str(actual_total) + "," + str(ma) + "," + str((100 - (ma*100/total))) + "," + str(mi) + "," + str((100 - (mi*100/total))) + "," + str(avg) + "," + str((100 - (avg*100/total))) + "\r"
    output += "\r"
    output += "Total,total,max,min-decrease,min,max-decrease,avg,avg-decrease\r"
    for bench in print_benchs:
        if(bench not in first):
            output += bench + "\r"
        else:
            total = totalTotal[bench]
            actual_total = total
            if(total == 0):
                total = 1
            ma = maxTotal[bench]
            mi = minTotal[bench]
            avg = avgTotal[bench]
            output += bench + "," + str(actual_total) + "," + str(ma) + "," + str((100 - (ma*100/total))) + "," + str(mi) + "," + str((100 - (mi*100/total))) + "," + str(avg) + "," + str((100 - (avg*100/total))) + "\r"
    
    with open("sink.csv", 'w') as write:
        write.write(output)

maxROP = {}
maxCOP = {}
maxJOP = {}
maxOther = {}
maxTotal = {}
minROP = {}
minCOP = {}
minJOP = {}
minOther = {}
minTotal = {}
avgROP = {}
avgCOP = {}
avgJOP = {}
avgOther = {}
avgTotal = {}
totalROP = {}
totalCOP = {}
totalJOP = {}
totalOther = {}
totalTotal = {}
first = {}

if(args.sink_linker):
    for bench in curr_benchs:
        f = open("resultswpd_cl_sink/"+bench+"/GadgetCounts_Reduction.csv", 'r')
        line = f.readline()
        line = f.readline().strip()
        split = line.split(",")[1:]
        first[bench] = bench + "," + ",".join(split) + "\r"
        split = [int(i) for i in split]
        totalROP[bench], totalJOP[bench], totalCOP[bench], totalOther[bench], totalTotal[bench] = split
        count = 0
        ROPsum, COPsum, JOPsum, Othersum, Totalsum = 0, 0, 0, 0, 0
        ROPmax, ROPmin = 0,split[0]
        JOPmax, JOPmin = 0,split[1]
        COPmax, COPmin = 0,split[2]
        Othermax, Othermin = 0,split[3]
        Totalmax, Totalmin = 0,split[4]
        line = f.readline()
        while(line):
            line = line.strip()
            split = line.split(",")[1:]
            split = [int(i) for i in split]
            ROPsum += split[0]
            ROPmax = max(ROPmax, split[0])
            ROPmin = min(ROPmin, split[0])
            JOPsum += split[1]
            JOPmax = max(JOPmax, split[1])
            JOPmin = min(JOPmin, split[1])
            COPsum += split[2]
            COPmax = max(COPmax, split[2])
            COPmin = min(COPmin, split[2])
            Othersum += split[3]
            Othermax = max(Othermax, split[3])
            Othermin = min(Othermin, split[3])
            Totalsum += split[4]
            Totalmax = max(Totalmax, split[4])
            Totalmin = min(Totalmin, split[4])
            count += 1
            line = f.readline()
        maxROP[bench] = ROPmax
        minROP[bench] = ROPmin
        avgROP[bench] = ROPsum / count
        maxCOP[bench] = COPmax
        minCOP[bench] = COPmin
        avgCOP[bench] = COPsum / count
        maxJOP[bench] = JOPmax
        minJOP[bench] = JOPmin
        avgJOP[bench] = JOPsum / count
        maxOther[bench] = Othermax
        minOther[bench] = Othermin
        avgOther[bench] = Othersum / count
        maxTotal[bench] = Totalmax
        minTotal[bench] = Totalmin
        avgTotal[bench] = Totalsum / count 
        f.close()
    
    output = ",ROP,JOP,COP,Special,Total\r"
    for bench in print_benchs:
        if(bench not in first):
            output += bench + "\r"
        else:
            output += first[bench]
    output += "\r"
    output += "ROP,total,max,min-decrease,min,max-decrease,avg,avg-decrease\r"
    for bench in print_benchs:
        if(bench not in first):
            output += bench + "\r"
        else:
            total = totalROP[bench]
            actual_total = total
            if(total == 0):
                total = 1
            ma = maxROP[bench]
            mi = minROP[bench]
            avg = avgROP[bench]
            output += bench + "," + str(actual_total) + "," + str(ma) + "," + str((100 - (ma*100/total))) + "," + str(mi) + "," + str((100 - (mi*100/total))) + "," + str(avg) + "," + str((100 - (avg*100/total))) + "\r"
    output += "\r"
    output += "JOP,total,max,min-decrease,min,max-decrease,avg,avg-decrease\r"
    for bench in print_benchs:
        if(bench not in first):
            output += bench + "\r"
        else:
            total = totalJOP[bench]
            actual_total = total
            if(total == 0):
                total = 1
            ma = maxJOP[bench]
            mi = minJOP[bench]
            avg = avgJOP[bench]
            output += bench + "," + str(actual_total) + "," + str(ma) + "," + str((100 - (ma*100/total))) + "," + str(mi) + "," + str((100 - (mi*100/total))) + "," + str(avg) + "," + str((100 - (avg*100/total))) + "\r"
    output += "\r"
    output += "COP,total,max,min-decrease,min,max-decrease,avg,avg-decrease\r"
    for bench in print_benchs:
        if(bench not in first):
            output += bench + "\r"
        else:
            total = totalCOP[bench]
            actual_total = total
            if(total == 0):
                total = 1
            ma = maxCOP[bench]
            mi = minCOP[bench]
            avg = avgCOP[bench]
            output += bench + "," + str(actual_total) + "," + str(ma) + "," + str((100 - (ma*100/total))) + "," + str(mi) + "," + str((100 - (mi*100/total))) + "," + str(avg) + "," + str((100 - (avg*100/total))) + "\r"
    output += "\r"
    output += "Special,total,max,min-decrease,min,max-decrease,avg,avg-decrease\r"
    for bench in print_benchs:
        if(bench not in first):
            output += bench + "\r"
        else:
            total = totalOther[bench]
            actual_total = total
            if(total == 0):
                total = 1
            ma = maxOther[bench]
            mi = minOther[bench]
            avg = avgOther[bench]
            output += bench + "," + str(actual_total) + "," + str(ma) + "," + str((100 - (ma*100/total))) + "," + str(mi) + "," + str((100 - (mi*100/total))) + "," + str(avg) + "," + str((100 - (avg*100/total))) + "\r"
    output += "\r"
    output += "Total,total,max,min-decrease,min,max-decrease,avg,avg-decrease\r"
    for bench in print_benchs:
        if(bench not in first):
            output += bench + "\r"
        else:
            total = totalTotal[bench]
            actual_total = total
            if(total == 0):
                total = 1
            ma = maxTotal[bench]
            mi = minTotal[bench]
            avg = avgTotal[bench]
            output += bench + "," + str(actual_total) + "," + str(ma) + "," + str((100 - (ma*100/total))) + "," + str(mi) + "," + str((100 - (mi*100/total))) + "," + str(avg) + "," + str((100 - (avg*100/total))) + "\r"
    
    with open("sink_linker.csv", 'w') as write:
        write.write(output)

maxROP = {}
maxCOP = {}
maxJOP = {}
maxOther = {}
maxTotal = {}
minROP = {}
minCOP = {}
minJOP = {}
minOther = {}
minTotal = {}
avgROP = {}
avgCOP = {}
avgJOP = {}
avgOther = {}
avgTotal = {}
totalROP = {}
totalCOP = {}
totalJOP = {}
totalOther = {}
totalTotal = {}
first = {}

if(args.ics):
    for bench in curr_benchs:
        print(bench + " - ics")
        if(not os.path.exists("resultswpd_ics/"+bench+"/GadgetCounts_Reduction.csv")):
            continue
        f = open("resultswpd_ics/"+bench+"/GadgetCounts_Reduction.csv", 'r')
        line = f.readline()
        line = f.readline().strip()
        split = line.split(",")[1:]
        first[bench] = bench + "," + ",".join(split) + "\r"
        split = [int(i) for i in split]
        totalROP[bench], totalJOP[bench], totalCOP[bench], totalOther[bench], totalTotal[bench] = split
        count = 0
        ROPsum, COPsum, JOPsum, Othersum, Totalsum = 0, 0, 0, 0, 0
        ROPmax, ROPmin = 0,split[0]
        JOPmax, JOPmin = 0,split[1]
        COPmax, COPmin = 0,split[2]
        Othermax, Othermin = 0,split[3]
        Totalmax, Totalmin = 0,split[4]
        line = f.readline()
        while(line):
            line = line.strip()
            split = line.split(",")[1:]
            split = [int(i) for i in split]
            ROPsum += split[0]
            ROPmax = max(ROPmax, split[0])
            ROPmin = min(ROPmin, split[0])
            JOPsum += split[1]
            JOPmax = max(JOPmax, split[1])
            JOPmin = min(JOPmin, split[1])
            COPsum += split[2]
            COPmax = max(COPmax, split[2])
            COPmin = min(COPmin, split[2])
            Othersum += split[3]
            Othermax = max(Othermax, split[3])
            Othermin = min(Othermin, split[3])
            Totalsum += split[4]
            Totalmax = max(Totalmax, split[4])
            Totalmin = min(Totalmin, split[4])
            count += 1
            line = f.readline()
        maxROP[bench] = ROPmax
        minROP[bench] = ROPmin
        avgROP[bench] = ROPsum / count
        maxCOP[bench] = COPmax
        minCOP[bench] = COPmin
        avgCOP[bench] = COPsum / count
        maxJOP[bench] = JOPmax
        minJOP[bench] = JOPmin
        avgJOP[bench] = JOPsum / count
        maxOther[bench] = Othermax
        minOther[bench] = Othermin
        avgOther[bench] = Othersum / count
        maxTotal[bench] = Totalmax
        minTotal[bench] = Totalmin
        avgTotal[bench] = Totalsum / count 
        f.close()
    
    output = ",ROP,JOP,COP,Special,Total\r"
    for bench in print_benchs:
        if(bench not in first):
            output += bench + "\r"
        else:
            output += first[bench]
    output += "\r"
    output += "ROP,total,max,min-decrease,min,max-decrease,avg,avg-decrease\r"
    for bench in print_benchs:
        if(bench not in first):
            output += bench + "\r"
        else:
            total = totalROP[bench]
            actual_total = total
            if(total == 0):
                total = 1
            ma = maxROP[bench]
            mi = minROP[bench]
            avg = avgROP[bench]
            output += bench + "," + str(actual_total) + "," + str(ma) + "," + str((100 - (ma*100/total))) + "," + str(mi) + "," + str((100 - (mi*100/total))) + "," + str(avg) + "," + str((100 - (avg*100/total))) + "\r"
    output += "\r"
    output += "JOP,total,max,min-decrease,min,max-decrease,avg,avg-decrease\r"
    for bench in print_benchs:
        if(bench not in first):
            output += bench + "\r"
        else:
            total = totalJOP[bench]
            actual_total = total
            if(total == 0):
                total = 1
            ma = maxJOP[bench]
            mi = minJOP[bench]
            avg = avgJOP[bench]
            output += bench + "," + str(actual_total) + "," + str(ma) + "," + str((100 - (ma*100/total))) + "," + str(mi) + "," + str((100 - (mi*100/total))) + "," + str(avg) + "," + str((100 - (avg*100/total))) + "\r"
    output += "\r"
    output += "COP,total,max,min-decrease,min,max-decrease,avg,avg-decrease\r"
    for bench in print_benchs:
        if(bench not in first):
            output += bench + "\r"
        else:
            total = totalCOP[bench]
            actual_total = total
            if(total == 0):
                total = 1
            ma = maxCOP[bench]
            mi = minCOP[bench]
            avg = avgCOP[bench]
            output += bench + "," + str(actual_total) + "," + str(ma) + "," + str((100 - (ma*100/total))) + "," + str(mi) + "," + str((100 - (mi*100/total))) + "," + str(avg) + "," + str((100 - (avg*100/total))) + "\r"
    output += "\r"
    output += "Special,total,max,min-decrease,min,max-decrease,avg,avg-decrease\r"
    for bench in print_benchs:
        if(bench not in first):
            output += bench + "\r"
        else:
            total = totalOther[bench]
            actual_total = total
            if(total == 0):
                total = 1
            ma = maxOther[bench]
            mi = minOther[bench]
            avg = avgOther[bench]
            output += bench + "," + str(actual_total) + "," + str(ma) + "," + str((100 - (ma*100/total))) + "," + str(mi) + "," + str((100 - (mi*100/total))) + "," + str(avg) + "," + str((100 - (avg*100/total))) + "\r"
    output += "\r"
    output += "Total,total,max,min-decrease,min,max-decrease,avg,avg-decrease\r"
    for bench in print_benchs:
        if(bench not in first):
            output += bench + "\r"
        else:
            total = totalTotal[bench]
            actual_total = total
            if(total == 0):
                total = 1
            ma = maxTotal[bench]
            mi = minTotal[bench]
            avg = avgTotal[bench]
            output += bench + "," + str(actual_total) + "," + str(ma) + "," + str((100 - (ma*100/total))) + "," + str(mi) + "," + str((100 - (mi*100/total))) + "," + str(avg) + "," + str((100 - (avg*100/total))) + "\r"
    
    with open("ics.csv", 'w') as write:
        write.write(output)

maxROP = {}
maxCOP = {}
maxJOP = {}
maxOther = {}
maxTotal = {}
minROP = {}
minCOP = {}
minJOP = {}
minOther = {}
minTotal = {}
avgROP = {}
avgCOP = {}
avgJOP = {}
avgOther = {}
avgTotal = {}
totalROP = {}
totalCOP = {}
totalJOP = {}
totalOther = {}
totalTotal = {}
first = {}

if(args.ics_linker):
    for bench in curr_benchs:
        if(not os.path.exists("resultsartd_release/"+bench+"/GadgetCounts_Reduction.csv")):
            continue
        print(bench + " - ics_linker")
        f = open("resultsartd_release/"+bench+"/GadgetCounts_Reduction.csv", 'r')
        line = f.readline()
        line = f.readline().strip()
        split = line.split(",")[1:]
        first[bench] = bench + "," + ",".join(split) + "\n"
        split = [int(i) for i in split]
        totalROP[bench], totalJOP[bench], totalCOP[bench], totalOther[bench], totalTotal[bench] = split
        count = 0
        ROPsum, COPsum, JOPsum, Othersum, Totalsum = 0, 0, 0, 0, 0
        ROPmax, ROPmin = 0,split[0]
        JOPmax, JOPmin = 0,split[1]
        COPmax, COPmin = 0,split[2]
        Othermax, Othermin = 0,split[3]
        Totalmax, Totalmin = 0,split[4]
        line = f.readline()
        while(line):
            line = line.strip()
            split = line.split(",")[1:]
            split = [int(i) for i in split]
            ROPsum += split[0]
            ROPmax = max(ROPmax, split[0])
            ROPmin = min(ROPmin, split[0])
            JOPsum += split[1]
            JOPmax = max(JOPmax, split[1])
            JOPmin = min(JOPmin, split[1])
            COPsum += split[2]
            COPmax = max(COPmax, split[2])
            COPmin = min(COPmin, split[2])
            Othersum += split[3]
            Othermax = max(Othermax, split[3])
            Othermin = min(Othermin, split[3])
            Totalsum += split[4]
            Totalmax = max(Totalmax, split[4])
            Totalmin = min(Totalmin, split[4])
            count += 1
            line = f.readline()
        maxROP[bench] = ROPmax
        minROP[bench] = ROPmin
        avgROP[bench] = ROPsum / count
        maxCOP[bench] = COPmax
        minCOP[bench] = COPmin
        avgCOP[bench] = COPsum / count
        maxJOP[bench] = JOPmax
        minJOP[bench] = JOPmin
        avgJOP[bench] = JOPsum / count
        maxOther[bench] = Othermax
        minOther[bench] = Othermin
        avgOther[bench] = Othersum / count
        maxTotal[bench] = Totalmax
        minTotal[bench] = Totalmin
        avgTotal[bench] = Totalsum / count 
        f.close()
    
    output = ",ROP,JOP,COP,Special,Total\n"
    for bench in print_benchs:
        if(bench not in first):
            output += bench + "\n"
        else:
            output += first[bench]
    output += "\n"
    output += "ROP,total,max,min-decrease,min,max-decrease,avg,avg-decrease\n"
    for bench in print_benchs:
        if(bench not in first):
            output += bench + "\n"
        else:
            total = totalROP[bench]
            actual_total = total
            if(total == 0):
                total = 1
            ma = maxROP[bench]
            mi = minROP[bench]
            avg = avgROP[bench]
            output += bench + "," + str(actual_total) + "," + str(ma) + "," + str((100 - (ma*100/total))) + "," + str(mi) + "," + str((100 - (mi*100/total))) + "," + str(avg) + "," + str((100 - (avg*100/total))) + "\n"
    output += "\n"
    output += "JOP,total,max,min-decrease,min,max-decrease,avg,avg-decrease\n"
    for bench in print_benchs:
        if(bench not in first):
            output += bench + "\n"
        else:
            total = totalJOP[bench]
            actual_total = total
            if(total == 0):
                total = 1
            ma = maxJOP[bench]
            mi = minJOP[bench]
            avg = avgJOP[bench]
            output += bench + "," + str(actual_total) + "," + str(ma) + "," + str((100 - (ma*100/total))) + "," + str(mi) + "," + str((100 - (mi*100/total))) + "," + str(avg) + "," + str((100 - (avg*100/total))) + "\n"
    output += "\n"
    output += "COP,total,max,min-decrease,min,max-decrease,avg,avg-decrease\n"
    for bench in print_benchs:
        if(bench not in first):
            output += bench + "\n"
        else:
            total = totalCOP[bench]
            actual_total = total
            if(total == 0):
                total = 1
            ma = maxCOP[bench]
            mi = minCOP[bench]
            avg = avgCOP[bench]
            output += bench + "," + str(actual_total) + "," + str(ma) + "," + str((100 - (ma*100/total))) + "," + str(mi) + "," + str((100 - (mi*100/total))) + "," + str(avg) + "," + str((100 - (avg*100/total))) + "\n"
    output += "\n"
    output += "Special,total,max,min-decrease,min,max-decrease,avg,avg-decrease\n"
    for bench in print_benchs:
        if(bench not in first):
            output += bench + "\n"
        else:
            total = totalOther[bench]
            actual_total = total
            if(total == 0):
                total = 1
            ma = maxOther[bench]
            mi = minOther[bench]
            avg = avgOther[bench]
            output += bench + "," + str(actual_total) + "," + str(ma) + "," + str((100 - (ma*100/total))) + "," + str(mi) + "," + str((100 - (mi*100/total))) + "," + str(avg) + "," + str((100 - (avg*100/total))) + "\n"
    output += "\n"
    output += "Total,total,max,min-decrease,min,max-decrease,avg,avg-decrease\n"
    for bench in print_benchs:
        if(bench not in first):
            output += bench + "\n"
        else:
            total = totalTotal[bench]
            actual_total = total
            if(total == 0):
                total = 1
            ma = maxTotal[bench]
            mi = minTotal[bench]
            avg = avgTotal[bench]
            #output += bench + "," + str(actual_total) + "," + str(ma) + "," + str((100 - (ma*100/total))) + "," + str(mi) + "," + str((100 - (mi*100/total))) + "," + str(avg) + "," + str((100 - (avg*100/total))) + "\n"
            output += bench + "," + str(actual_total) + "," + str(ma) + "," + str(round(100 - (ma*100/total),1)) + "," + str(mi) + "," + str(round(100 - (mi*100/total),1)) + "," + str(round(avg,1)) + "," + str(round(100 - (avg*100/total),1)) + "\n"
    
    with open("ics_linker.csv", 'w') as write:
        write.write(output)

maxROP = {}
maxCOP = {}
maxJOP = {}
maxOther = {}
maxTotal = {}
minROP = {}
minCOP = {}
minJOP = {}
minOther = {}
minTotal = {}
avgROP = {}
avgCOP = {}
avgJOP = {}
avgOther = {}
avgTotal = {}
totalROP = {}
totalCOP = {}
totalJOP = {}
totalOther = {}
totalTotal = {}
first = {}

if(args.ics_sc_linker):
    for bench in curr_benchs:
        if(not os.path.exists("resultswpd_cl_ics_sc/"+bench+"/GadgetCounts_Reduction.csv")):
            continue
        print(bench + " - ics_sc_linker")
        f = open("resultswpd_cl_ics_sc/"+bench+"/GadgetCounts_Reduction.csv", 'r')
        line = f.readline()
        line = f.readline().strip()
        split = line.split(",")[1:]
        first[bench] = bench + "," + ",".join(split) + "\r"
        split = [int(i) for i in split]
        totalROP[bench], totalJOP[bench], totalCOP[bench], totalOther[bench], totalTotal[bench] = split
        count = 0
        ROPsum, COPsum, JOPsum, Othersum, Totalsum = 0, 0, 0, 0, 0
        ROPmax, ROPmin = 0,split[0]
        JOPmax, JOPmin = 0,split[1]
        COPmax, COPmin = 0,split[2]
        Othermax, Othermin = 0,split[3]
        Totalmax, Totalmin = 0,split[4]
        line = f.readline()
        while(line):
            line = line.strip()
            split = line.split(",")[1:]
            split = [int(i) for i in split]
            ROPsum += split[0]
            ROPmax = max(ROPmax, split[0])
            ROPmin = min(ROPmin, split[0])
            JOPsum += split[1]
            JOPmax = max(JOPmax, split[1])
            JOPmin = min(JOPmin, split[1])
            COPsum += split[2]
            COPmax = max(COPmax, split[2])
            COPmin = min(COPmin, split[2])
            Othersum += split[3]
            Othermax = max(Othermax, split[3])
            Othermin = min(Othermin, split[3])
            Totalsum += split[4]
            Totalmax = max(Totalmax, split[4])
            Totalmin = min(Totalmin, split[4])
            count += 1
            line = f.readline()
        maxROP[bench] = ROPmax
        minROP[bench] = ROPmin
        avgROP[bench] = ROPsum / count
        maxCOP[bench] = COPmax
        minCOP[bench] = COPmin
        avgCOP[bench] = COPsum / count
        maxJOP[bench] = JOPmax
        minJOP[bench] = JOPmin
        avgJOP[bench] = JOPsum / count
        maxOther[bench] = Othermax
        minOther[bench] = Othermin
        avgOther[bench] = Othersum / count
        maxTotal[bench] = Totalmax
        minTotal[bench] = Totalmin
        avgTotal[bench] = Totalsum / count 
        f.close()
    
    output = ",ROP,JOP,COP,Special,Total\r"
    for bench in print_benchs:
        if(bench not in first):
            output += bench + "\r"
        else:
            output += first[bench]
    output += "\r"
    output += "ROP,total,max,min-decrease,min,max-decrease,avg,avg-decrease\r"
    for bench in print_benchs:
        if(bench not in first):
            output += bench + "\r"
        else:
            total = totalROP[bench]
            actual_total = total
            if(total == 0):
                total = 1
            ma = maxROP[bench]
            mi = minROP[bench]
            avg = avgROP[bench]
            output += bench + "," + str(actual_total) + "," + str(ma) + "," + str((100 - (ma*100/total))) + "," + str(mi) + "," + str((100 - (mi*100/total))) + "," + str(avg) + "," + str((100 - (avg*100/total))) + "\r"
    output += "\r"
    output += "JOP,total,max,min-decrease,min,max-decrease,avg,avg-decrease\r"
    for bench in print_benchs:
        if(bench not in first):
            output += bench + "\r"
        else:
            total = totalJOP[bench]
            actual_total = total
            if(total == 0):
                total = 1
            ma = maxJOP[bench]
            mi = minJOP[bench]
            avg = avgJOP[bench]
            output += bench + "," + str(actual_total) + "," + str(ma) + "," + str((100 - (ma*100/total))) + "," + str(mi) + "," + str((100 - (mi*100/total))) + "," + str(avg) + "," + str((100 - (avg*100/total))) + "\r"
    output += "\r"
    output += "COP,total,max,min-decrease,min,max-decrease,avg,avg-decrease\r"
    for bench in print_benchs:
        if(bench not in first):
            output += bench + "\r"
        else:
            total = totalCOP[bench]
            actual_total = total
            if(total == 0):
                total = 1
            ma = maxCOP[bench]
            mi = minCOP[bench]
            avg = avgCOP[bench]
            output += bench + "," + str(actual_total) + "," + str(ma) + "," + str((100 - (ma*100/total))) + "," + str(mi) + "," + str((100 - (mi*100/total))) + "," + str(avg) + "," + str((100 - (avg*100/total))) + "\r"
    output += "\r"
    output += "Special,total,max,min-decrease,min,max-decrease,avg,avg-decrease\r"
    for bench in print_benchs:
        if(bench not in first):
            output += bench + "\r"
        else:
            total = totalOther[bench]
            actual_total = total
            if(total == 0):
                total = 1
            ma = maxOther[bench]
            mi = minOther[bench]
            avg = avgOther[bench]
            output += bench + "," + str(actual_total) + "," + str(ma) + "," + str((100 - (ma*100/total))) + "," + str(mi) + "," + str((100 - (mi*100/total))) + "," + str(avg) + "," + str((100 - (avg*100/total))) + "\r"
    output += "\r"
    output += "Total,total,max,min-decrease,min,max-decrease,avg,avg-decrease\r"
    for bench in print_benchs:
        if(bench not in first):
            output += bench + "\r"
        else:
            total = totalTotal[bench]
            actual_total = total
            if(total == 0):
                total = 1
            ma = maxTotal[bench]
            mi = minTotal[bench]
            avg = avgTotal[bench]
            output += bench + "," + str(actual_total) + "," + str(ma) + "," + str((100 - (ma*100/total))) + "," + str(mi) + "," + str((100 - (mi*100/total))) + "," + str(avg) + "," + str((100 - (avg*100/total))) + "\r"
    
    with open("ics_sc_linker.csv", 'w') as write:
        write.write(output)
