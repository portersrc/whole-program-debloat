# Standard Library Imports
import argparse
import sys
import os
import glob
from tkinter import N

# Parse Arguments
parser = argparse.ArgumentParser()
parser.add_argument("--base", help="Produce Gadget results for Base Code", action='store_true')
parser.add_argument("--linker", help="Produce Gadget results for Base Code with Linker Script", action='store_true')
parser.add_argument("--ics", help="Produce Gadget results for ICS Code", action='store_true')
parser.add_argument("--ics_linker", help="Produce Gadget results for ICS Code with Linker Script", action='store_true')
parser.add_argument("--ics_sc_linker", help="Produce Gadget results for ICS Code with Linker Script", action='store_true')

args = parser.parse_args()

#"bzip2", "gzip", "tar", "grep", "chown", "date", "mkdir", "rm", "sort", "uniq"
all_benches = ["bzip2", "gzip", "tar", "grep", "chown", "date", "mkdir", "rm", "sort", "uniq"]

if(args.base):
    for bench in all_benches:
        path = "resultswpd/"+bench
        if(not os.path.exists(path)):
            continue
        print(bench + " - base")

        folders = glob.glob(path + "/*/")
        numbers = []

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
        for folder in folders:
            number = int(folder.split("/")[-2])
            numbers.append(number)
            with open(folder+"GadgetCounts_Reduction.csv","r") as f:
                line = f.readline()
                line = f.readline().strip()
                split = line.split(",")[1:]
                first[number] = str(number) + "," + ",".join(split) + "\r"
                split = [int(i) for i in split]
                totalROP[number], totalJOP[number], totalCOP[number], totalOther[number], totalTotal[number] = split
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
                    #print(split)
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
                maxROP[number] = ROPmax
                minROP[number] = ROPmin
                avgROP[number] = ROPsum / count
                maxCOP[number] = COPmax
                minCOP[number] = COPmin
                avgCOP[number] = COPsum / count
                maxJOP[number] = JOPmax
                minJOP[number] = JOPmin
                avgJOP[number] = JOPsum / count
                maxOther[number] = Othermax
                minOther[number] = Othermin
                avgOther[number] = Othersum / count
                maxTotal[number] = Totalmax
                minTotal[number] = Totalmin
                avgTotal[number] = Totalsum / count 
                f.close()

        numbers.sort()
        output = ",ROP,JOP,COP,Special,Total\r"
        for n in numbers:
            if(n not in first):
                output += str(n) + "\r"
            else:
                output += first[n]
        output += "\r"
        
        output += "ROP,total,max,min-decrease,min,max-decrease,avg,avg-decrease\r"
        for n in numbers:
            if(n not in first):
                output += str(n) + "\r"
            else:
                total = totalROP[n]
                actual_total = total
                if(total == 0):
                    total = 1
                ma = maxROP[n]
                mi = minROP[n]
                avg = avgROP[n]
                output += str(n) + "," + str(actual_total) + "," + str(ma) + "," + str((100 - (ma*100/total))) + "," + str(mi) + "," + str((100 - (mi*100/total))) + "," + str(avg) + "," + str((100 - (avg*100/total))) + "\r"
        output += "\r"
        
        output += "JOP,total,max,min-decrease,min,max-decrease,avg,avg-decrease\r"
        for n in numbers:
            if(n not in first):
                output += str(n) + "\r"
            else:
                total = totalJOP[n]
                actual_total = total
                if(total == 0):
                    total = 1
                ma = maxJOP[n]
                mi = minJOP[n]
                avg = avgJOP[n]
                output += str(n) + "," + str(actual_total) + "," + str(ma) + "," + str((100 - (ma*100/total))) + "," + str(mi) + "," + str((100 - (mi*100/total))) + "," + str(avg) + "," + str((100 - (avg*100/total))) + "\r"
        output += "\r"
        output += "COP,total,max,min-decrease,min,max-decrease,avg,avg-decrease\r"
        for n in numbers:
            if(n not in first):
                output += str(n) + "\r"
            else:
                total = totalCOP[n]
                actual_total = total
                if(total == 0):
                    total = 1
                ma = maxCOP[n]
                mi = minCOP[n]
                avg = avgCOP[n]
                output += str(n) + "," + str(actual_total) + "," + str(ma) + "," + str((100 - (ma*100/total))) + "," + str(mi) + "," + str((100 - (mi*100/total))) + "," + str(avg) + "," + str((100 - (avg*100/total))) + "\r"
        output += "\r"
        
        output += "Special,total,max,min-decrease,min,max-decrease,avg,avg-decrease\r"
        for n in numbers:
            if(n not in first):
                output += str(n) + "\r"
            else:
                total = totalOther[n]
                actual_total = total
                if(total == 0):
                    total = 1
                ma = maxOther[n]
                mi = minOther[n]
                avg = avgOther[n]
                output += str(n) + "," + str(actual_total) + "," + str(ma) + "," + str((100 - (ma*100/total))) + "," + str(mi) + "," + str((100 - (mi*100/total))) + "," + str(avg) + "," + str((100 - (avg*100/total))) + "\r"
        output += "\r"
        
        output += "Total,total,max,min-decrease,min,max-decrease,avg,avg-decrease\r"
        for n in numbers:
            if(n not in first):
                output += str(n) + "\r"
            else:
                total = totalTotal[n]
                actual_total = total
                if(total == 0):
                    total = 1
                ma = maxTotal[n]
                mi = minTotal[n]
                avg = avgTotal[n]
                output += str(n) + "," + str(actual_total) + "," + str(ma) + "," + str((100 - (ma*100/total))) + "," + str(mi) + "," + str((100 - (mi*100/total))) + "," + str(avg) + "," + str((100 - (avg*100/total))) + "\r"
        
        with open("output/"+bench+"/base.csv", 'w') as write:
            write.write(output)

if(args.linker):
    for bench in all_benches:
        path = "resultswpd_cl/"+bench
        if(not os.path.exists(path)):
            continue
        print(bench + " - linker")

        folders = glob.glob(path + "/*/")
        numbers = []

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
        for folder in folders:
            number = int(folder.split("/")[-2])
            numbers.append(number)

            with open(folder+"GadgetCounts_Reduction.csv","r") as f:
                line = f.readline()
                line = f.readline().strip()
                split = line.split(",")[1:]
                first[number] = str(number) + "," + ",".join(split) + "\r"
                split = [int(i) for i in split]
                #print(split)
                totalROP[number], totalJOP[number], totalCOP[number], totalOther[number], totalTotal[number] = split
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
                    #print(split)
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
                maxROP[number] = ROPmax
                minROP[number] = ROPmin
                avgROP[number] = ROPsum / count
                maxCOP[number] = COPmax
                minCOP[number] = COPmin
                avgCOP[number] = COPsum / count
                maxJOP[number] = JOPmax
                minJOP[number] = JOPmin
                avgJOP[number] = JOPsum / count
                maxOther[number] = Othermax
                minOther[number] = Othermin
                avgOther[number] = Othersum / count
                maxTotal[number] = Totalmax
                minTotal[number] = Totalmin
                avgTotal[number] = Totalsum / count 
                f.close()

        numbers.sort()
        output = ",ROP,JOP,COP,Special,Total\r"
        for n in numbers:
            if(n not in first):
                output += str(n) + "\r"
            else:
                output += first[n]
        output += "\r"
        
        output += "ROP,total,max,min-decrease,min,max-decrease,avg,avg-decrease\r"
        for n in numbers:
            if(n not in first):
                output += str(n) + "\r"
            else:
                total = totalROP[n]
                actual_total = total
                if(total == 0):
                    total = 1
                ma = maxROP[n]
                mi = minROP[n]
                avg = avgROP[n]
                output += str(n) + "," + str(actual_total) + "," + str(ma) + "," + str((100 - (ma*100/total))) + "," + str(mi) + "," + str((100 - (mi*100/total))) + "," + str(avg) + "," + str((100 - (avg*100/total))) + "\r"
        output += "\r"
        
        output += "JOP,total,max,min-decrease,min,max-decrease,avg,avg-decrease\r"
        for n in numbers:
            if(n not in first):
                output += str(n) + "\r"
            else:
                total = totalJOP[n]
                actual_total = total
                if(total == 0):
                    total = 1
                ma = maxJOP[n]
                mi = minJOP[n]
                avg = avgJOP[n]
                output += str(n) + "," + str(actual_total) + "," + str(ma) + "," + str((100 - (ma*100/total))) + "," + str(mi) + "," + str((100 - (mi*100/total))) + "," + str(avg) + "," + str((100 - (avg*100/total))) + "\r"
        output += "\r"
        output += "COP,total,max,min-decrease,min,max-decrease,avg,avg-decrease\r"
        for n in numbers:
            if(n not in first):
                output += str(n) + "\r"
            else:
                total = totalCOP[n]
                actual_total = total
                if(total == 0):
                    total = 1
                ma = maxCOP[n]
                mi = minCOP[n]
                avg = avgCOP[n]
                output += str(n) + "," + str(actual_total) + "," + str(ma) + "," + str((100 - (ma*100/total))) + "," + str(mi) + "," + str((100 - (mi*100/total))) + "," + str(avg) + "," + str((100 - (avg*100/total))) + "\r"
        output += "\r"
        
        output += "Special,total,max,min-decrease,min,max-decrease,avg,avg-decrease\r"
        for n in numbers:
            if(n not in first):
                output += str(n) + "\r"
            else:
                total = totalOther[n]
                actual_total = total
                if(total == 0):
                    total = 1
                ma = maxOther[n]
                mi = minOther[n]
                avg = avgOther[n]
                output += str(n) + "," + str(actual_total) + "," + str(ma) + "," + str((100 - (ma*100/total))) + "," + str(mi) + "," + str((100 - (mi*100/total))) + "," + str(avg) + "," + str((100 - (avg*100/total))) + "\r"
        output += "\r"
        
        output += "Total,total,max,min-decrease,min,max-decrease,avg,avg-decrease\r"
        for n in numbers:
            if(n not in first):
                output += str(n) + "\r"
            else:
                total = totalTotal[n]
                actual_total = total
                if(total == 0):
                    total = 1
                ma = maxTotal[n]
                mi = minTotal[n]
                avg = avgTotal[n]
                output += str(n) + "," + str(actual_total) + "," + str(ma) + "," + str((100 - (ma*100/total))) + "," + str(mi) + "," + str((100 - (mi*100/total))) + "," + str(avg) + "," + str((100 - (avg*100/total))) + "\r"
        
        with open("output/"+bench+"/linker.csv", 'w') as write:
            write.write(output)

if(args.ics):
    for bench in all_benches:
        path = "resultswpd_ics/"+bench
        if(not os.path.exists(path)):
            continue
        print(bench + " - ics")

        folders = glob.glob(path + "/*/")
        numbers = []

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
        for folder in folders:
            number = int(folder.split("/")[-2])
            numbers.append(number)

            with open(folder+"GadgetCounts_Reduction.csv","r") as f:
                line = f.readline()
                line = f.readline().strip()
                split = line.split(",")[1:]
                first[number] = str(number) + "," + ",".join(split) + "\r"
                split = [int(i) for i in split]
                #print(split)
                totalROP[number], totalJOP[number], totalCOP[number], totalOther[number], totalTotal[number] = split
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
                    #print(split)
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
                maxROP[number] = ROPmax
                minROP[number] = ROPmin
                avgROP[number] = ROPsum / count
                maxCOP[number] = COPmax
                minCOP[number] = COPmin
                avgCOP[number] = COPsum / count
                maxJOP[number] = JOPmax
                minJOP[number] = JOPmin
                avgJOP[number] = JOPsum / count
                maxOther[number] = Othermax
                minOther[number] = Othermin
                avgOther[number] = Othersum / count
                maxTotal[number] = Totalmax
                minTotal[number] = Totalmin
                avgTotal[number] = Totalsum / count 
                f.close()
        
        numbers.sort()
        output = ",ROP,JOP,COP,Special,Total\r"
        for n in numbers:
            if(n not in first):
                output += str(n) + "\r"
            else:
                output += first[n]
        output += "\r"
        
        output += "ROP,total,max,min-decrease,min,max-decrease,avg,avg-decrease\r"
        for n in numbers:
            if(n not in first):
                output += str(n) + "\r"
            else:
                total = totalROP[n]
                actual_total = total
                if(total == 0):
                    total = 1
                ma = maxROP[n]
                mi = minROP[n]
                avg = avgROP[n]
                output += str(n) + "," + str(actual_total) + "," + str(ma) + "," + str((100 - (ma*100/total))) + "," + str(mi) + "," + str((100 - (mi*100/total))) + "," + str(avg) + "," + str((100 - (avg*100/total))) + "\r"
        output += "\r"
        
        output += "JOP,total,max,min-decrease,min,max-decrease,avg,avg-decrease\r"
        for n in numbers:
            if(n not in first):
                output += str(n) + "\r"
            else:
                total = totalJOP[n]
                actual_total = total
                if(total == 0):
                    total = 1
                ma = maxJOP[n]
                mi = minJOP[n]
                avg = avgJOP[n]
                output += str(n) + "," + str(actual_total) + "," + str(ma) + "," + str((100 - (ma*100/total))) + "," + str(mi) + "," + str((100 - (mi*100/total))) + "," + str(avg) + "," + str((100 - (avg*100/total))) + "\r"
        output += "\r"
        output += "COP,total,max,min-decrease,min,max-decrease,avg,avg-decrease\r"
        for n in numbers:
            if(n not in first):
                output += str(n) + "\r"
            else:
                total = totalCOP[n]
                actual_total = total
                if(total == 0):
                    total = 1
                ma = maxCOP[n]
                mi = minCOP[n]
                avg = avgCOP[n]
                output += str(n) + "," + str(actual_total) + "," + str(ma) + "," + str((100 - (ma*100/total))) + "," + str(mi) + "," + str((100 - (mi*100/total))) + "," + str(avg) + "," + str((100 - (avg*100/total))) + "\r"
        output += "\r"
        
        output += "Special,total,max,min-decrease,min,max-decrease,avg,avg-decrease\r"
        for n in numbers:
            if(n not in first):
                output += str(n) + "\r"
            else:
                total = totalOther[n]
                actual_total = total
                if(total == 0):
                    total = 1
                ma = maxOther[n]
                mi = minOther[n]
                avg = avgOther[n]
                output += str(n) + "," + str(actual_total) + "," + str(ma) + "," + str((100 - (ma*100/total))) + "," + str(mi) + "," + str((100 - (mi*100/total))) + "," + str(avg) + "," + str((100 - (avg*100/total))) + "\r"
        output += "\r"
        
        output += "Total,total,max,min-decrease,min,max-decrease,avg,avg-decrease\r"
        for n in numbers:
            if(n not in first):
                output += str(n) + "\r"
            else:
                total = totalTotal[n]
                actual_total = total
                if(total == 0):
                    total = 1
                ma = maxTotal[n]
                mi = minTotal[n]
                avg = avgTotal[n]
                output += str(n) + "," + str(actual_total) + "," + str(ma) + "," + str((100 - (ma*100/total))) + "," + str(mi) + "," + str((100 - (mi*100/total))) + "," + str(avg) + "," + str((100 - (avg*100/total))) + "\r"
        
        with open("output/"+bench+"/ics.csv", 'w') as write:
            write.write(output)

if(args.ics_linker):
    mxROP = {}
    mxCOP = {}
    mxJOP = {}
    mxOther = {}
    mxTotal = {}
    miROP = {}
    miCOP = {}
    miJOP = {}
    miOther = {}
    miTotal = {}
    agROP = {}
    agCOP = {}
    agJOP = {}
    agOther = {}
    agTotal = {}
    tROP = {}
    tCOP = {}
    tJOP = {}
    tOther = {}
    tTotal = {}
    firstb = {}
    for bench in all_benches:
        path = "resultswpd_cl_ics/"+bench
        if(not os.path.exists(path)):
            continue
        print(bench + " - ics_linker")

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

        folders = glob.glob(path + "/*/")
        numbers = []
        for folder in folders:
            number = int(folder.split("/")[-2])
            numbers.append(number)

            with open(folder+"GadgetCounts_Reduction.csv","r") as f:
                line = f.readline()
                line = f.readline().strip()
                split = line.split(",")[1:]
                first[number] = str(number) + "," + ",".join(split) + "\r"
                split = [int(i) for i in split]
                totalROP[number], totalJOP[number], totalCOP[number], totalOther[number], totalTotal[number] = split
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
                    #print(split)
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
                maxROP[number] = ROPmax
                minROP[number] = ROPmin
                avgROP[number] = ROPsum / count
                maxCOP[number] = COPmax
                minCOP[number] = COPmin
                avgCOP[number] = COPsum / count
                maxJOP[number] = JOPmax
                minJOP[number] = JOPmin
                avgJOP[number] = JOPsum / count
                maxOther[number] = Othermax
                minOther[number] = Othermin
                avgOther[number] = Othersum / count
                maxTotal[number] = Totalmax
                minTotal[number] = Totalmin
                avgTotal[number] = Totalsum / count 
        numbers.sort()
        output = ",ROP,JOP,COP,Special,Total\r"
        for n in numbers:
            if(n not in first):
                output += str(n) + "\r"
            else:
                output += first[n]
        output += "\r"
        
        output += "ROP,total,max,min-decrease,min,max-decrease,avg,avg-decrease\r"
        for n in numbers:
            if(n not in first):
                output += str(n) + "\r"
            else:
                total = totalROP[n]
                actual_total = total
                if(total == 0):
                    total = 1
                ma = maxROP[n]
                mi = minROP[n]
                avg = avgROP[n]
                output += str(n) + "," + str(actual_total) + "," + str(ma) + "," + str((100 - (ma*100/total))) + "," + str(mi) + "," + str((100 - (mi*100/total))) + "," + str(avg) + "," + str((100 - (avg*100/total))) + "\r"
        output += "\r"
        
        output += "JOP,total,max,min-decrease,min,max-decrease,avg,avg-decrease\r"
        for n in numbers:
            if(n not in first):
                output += str(n) + "\r"
            else:
                total = totalJOP[n]
                actual_total = total
                if(total == 0):
                    total = 1
                ma = maxJOP[n]
                mi = minJOP[n]
                avg = avgJOP[n]
                output += str(n) + "," + str(actual_total) + "," + str(ma) + "," + str((100 - (ma*100/total))) + "," + str(mi) + "," + str((100 - (mi*100/total))) + "," + str(avg) + "," + str((100 - (avg*100/total))) + "\r"
        output += "\r"
        output += "COP,total,max,min-decrease,min,max-decrease,avg,avg-decrease\r"
        for n in numbers:
            if(n not in first):
                output += str(n) + "\r"
            else:
                total = totalCOP[n]
                actual_total = total
                if(total == 0):
                    total = 1
                ma = maxCOP[n]
                mi = minCOP[n]
                avg = avgCOP[n]
                output += str(n) + "," + str(actual_total) + "," + str(ma) + "," + str((100 - (ma*100/total))) + "," + str(mi) + "," + str((100 - (mi*100/total))) + "," + str(avg) + "," + str((100 - (avg*100/total))) + "\r"
        output += "\r"
        
        output += "Special,total,max,min-decrease,min,max-decrease,avg,avg-decrease\r"
        for n in numbers:
            if(n not in first):
                output += str(n) + "\r"
            else:
                total = totalOther[n]
                actual_total = total
                if(total == 0):
                    total = 1
                ma = maxOther[n]
                mi = minOther[n]
                avg = avgOther[n]
                output += str(n) + "," + str(actual_total) + "," + str(ma) + "," + str((100 - (ma*100/total))) + "," + str(mi) + "," + str((100 - (mi*100/total))) + "," + str(avg) + "," + str((100 - (avg*100/total))) + "\r"
        output += "\r"
        
        output += "Total,total,max,min-decrease,min,max-decrease,avg,avg-decrease\r"
        for n in numbers:
            if(n not in first):
                output += str(n) + "\r"
            else:
                total = totalTotal[n]
                actual_total = total
                if(total == 0):
                    total = 1
                ma = maxTotal[n]
                mi = minTotal[n]
                avg = avgTotal[n]
                output += str(n) + "," + str(actual_total) + "," + str(ma) + "," + str((100 - (ma*100/total))) + "," + str(mi) + "," + str((100 - (mi*100/total))) + "," + str(avg) + "," + str((100 - (avg*100/total))) + "\r"
        
        with open("output/"+bench+"/ics_linker.csv", 'w') as write:
            write.write(output)

        # Just take the first input's Gadget Count since they are all similar
        firstb[bench] = first[numbers[0]]
        mxROP[bench] = maxROP[numbers[0]]
        mxCOP[bench] = maxCOP[numbers[0]]
        mxJOP[bench] = maxJOP[numbers[0]]
        mxOther[bench] = maxOther[numbers[0]]
        mxTotal[bench] = maxTotal[numbers[0]]
        miROP[bench] = minROP[numbers[0]]
        miCOP[bench] = minCOP[numbers[0]]
        miJOP[bench] = minJOP[numbers[0]]
        miOther[bench] = minOther[numbers[0]]
        miTotal[bench] = minTotal[numbers[0]]
        agROP[bench] = avgROP[numbers[0]]
        agCOP[bench] = avgCOP[numbers[0]]
        agJOP[bench] = avgJOP[numbers[0]]
        agOther[bench] = avgOther[numbers[0]]
        agTotal[bench] = avgTotal[numbers[0]]
        tROP[bench] = totalROP[numbers[0]]
        tCOP[bench] = totalCOP[numbers[0]]
        tJOP[bench] = totalJOP[numbers[0]]
        tOther[bench] = totalOther[numbers[0]]
        tTotal[bench] = totalTotal[numbers[0]]

        
    output = ",ROP,JOP,COP,Special,Total\r"
    for n in all_benches:
        if(n not in firstb):
            output += str(n) + "\r"
        else:
            lst = firstb[n].split(",")
            lst[0] = n
            output += ",".join(lst)
    output += "\r"
    
    output += "ROP,total,max,min-decrease,min,max-decrease,avg,avg-decrease\r"
    for n in all_benches:
        if(n not in firstb):
            output += str(n) + "\r"
        else:
            total = tROP[n]
            actual_total = total
            if(total == 0):
                total = 1
            ma = mxROP[n]
            mi = miROP[n]
            avg = agROP[n]
            output += str(n) + "," + str(actual_total) + "," + str(ma) + "," + str((100 - (ma*100/total))) + "," + str(mi) + "," + str((100 - (mi*100/total))) + "," + str(avg) + "," + str((100 - (avg*100/total))) + "\r"
    output += "\r"
    
    output += "JOP,total,max,min-decrease,min,max-decrease,avg,avg-decrease\r"
    for n in all_benches:
        if(n not in firstb):
            output += str(n) + "\r"
        else:
            total = tJOP[n]
            actual_total = total
            if(total == 0):
                total = 1
            ma = mxJOP[n]
            mi = miJOP[n]
            avg = agJOP[n]
            output += str(n) + "," + str(actual_total) + "," + str(ma) + "," + str((100 - (ma*100/total))) + "," + str(mi) + "," + str((100 - (mi*100/total))) + "," + str(avg) + "," + str((100 - (avg*100/total))) + "\r"
    output += "\r"
    output += "COP,total,max,min-decrease,min,max-decrease,avg,avg-decrease\r"
    for n in all_benches:
        if(n not in firstb):
            output += str(n) + "\r"
        else:
            total = tCOP[n]
            actual_total = total
            if(total == 0):
                total = 1
            ma = mxCOP[n]
            mi = miCOP[n]
            avg = agCOP[n]
            output += str(n) + "," + str(actual_total) + "," + str(ma) + "," + str((100 - (ma*100/total))) + "," + str(mi) + "," + str((100 - (mi*100/total))) + "," + str(avg) + "," + str((100 - (avg*100/total))) + "\r"
    output += "\r"
    
    output += "Special,total,max,min-decrease,min,max-decrease,avg,avg-decrease\r"
    for n in all_benches:
        if(n not in firstb):
            output += str(n) + "\r"
        else:
            total = tOther[n]
            actual_total = total
            if(total == 0):
                total = 1
            ma = mxOther[n]
            mi = miOther[n]
            avg = agOther[n]
            output += str(n) + "," + str(actual_total) + "," + str(ma) + "," + str((100 - (ma*100/total))) + "," + str(mi) + "," + str((100 - (mi*100/total))) + "," + str(avg) + "," + str((100 - (avg*100/total))) + "\r"
    output += "\r"
    
    output += "Total,total,max,min-decrease,min,max-decrease,avg,avg-decrease\r"
    for n in all_benches:
        if(n not in firstb):
            output += str(n) + "\r"
        else:
            total = tTotal[n]
            actual_total = total
            if(total == 0):
                total = 1
            ma = mxTotal[n]
            mi = miTotal[n]
            avg = agTotal[n]
            output += str(n) + "," + str(actual_total) + "," + str(ma) + "," + str((100 - (ma*100/total))) + "," + str(mi) + "," + str((100 - (mi*100/total))) + "," + str(avg) + "," + str((100 - (avg*100/total))) + "\r"

    with open("ics_linker.csv", 'w') as write:
        write.write(output)

if(args.ics_sc_linker):
    for bench in all_benches:
        path = "resultswpd_cl_ics_sc/"+bench
        if(not os.path.exists(path)):
            continue
        print(bench + " - ics_sc_linker")

        folders = glob.glob(path + "/*/")
        numbers = []

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
        for folder in folders:
            number = int(folder.split("/")[-2])
            numbers.append(number)

            with open(folder+"GadgetCounts_Reduction.csv","r") as f:
                line = f.readline()
                line = f.readline().strip()
                split = line.split(",")[1:]
                first[number] = str(number) + "," + ",".join(split) + "\r"
                split = [int(i) for i in split]
                #print(split)
                totalROP[number], totalJOP[number], totalCOP[number], totalOther[number], totalTotal[number] = split
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
                    #print(split)
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
                maxROP[number] = ROPmax
                minROP[number] = ROPmin
                avgROP[number] = ROPsum / count
                maxCOP[number] = COPmax
                minCOP[number] = COPmin
                avgCOP[number] = COPsum / count
                maxJOP[number] = JOPmax
                minJOP[number] = JOPmin
                avgJOP[number] = JOPsum / count
                maxOther[number] = Othermax
                minOther[number] = Othermin
                avgOther[number] = Othersum / count
                maxTotal[number] = Totalmax
                minTotal[number] = Totalmin
                avgTotal[number] = Totalsum / count 
                f.close()
        
        numbers.sort()
        output = ",ROP,JOP,COP,Special,Total\r"
        for n in numbers:
            if(n not in first):
                output += str(n) + "\r"
            else:
                output += first[n]
        output += "\r"
        
        output += "ROP,total,max,min-decrease,min,max-decrease,avg,avg-decrease\r"
        for n in numbers:
            if(n not in first):
                output += str(n) + "\r"
            else:
                total = totalROP[n]
                actual_total = total
                if(total == 0):
                    total = 1
                ma = maxROP[n]
                mi = minROP[n]
                avg = avgROP[n]
                output += str(n) + "," + str(actual_total) + "," + str(ma) + "," + str((100 - (ma*100/total))) + "," + str(mi) + "," + str((100 - (mi*100/total))) + "," + str(avg) + "," + str((100 - (avg*100/total))) + "\r"
        output += "\r"
        
        output += "JOP,total,max,min-decrease,min,max-decrease,avg,avg-decrease\r"
        for n in numbers:
            if(n not in first):
                output += str(n) + "\r"
            else:
                total = totalJOP[n]
                actual_total = total
                if(total == 0):
                    total = 1
                ma = maxJOP[n]
                mi = minJOP[n]
                avg = avgJOP[n]
                output += str(n) + "," + str(actual_total) + "," + str(ma) + "," + str((100 - (ma*100/total))) + "," + str(mi) + "," + str((100 - (mi*100/total))) + "," + str(avg) + "," + str((100 - (avg*100/total))) + "\r"
        output += "\r"
        output += "COP,total,max,min-decrease,min,max-decrease,avg,avg-decrease\r"
        for n in numbers:
            if(n not in first):
                output += str(n) + "\r"
            else:
                total = totalCOP[n]
                actual_total = total
                if(total == 0):
                    total = 1
                ma = maxCOP[n]
                mi = minCOP[n]
                avg = avgCOP[n]
                output += str(n) + "," + str(actual_total) + "," + str(ma) + "," + str((100 - (ma*100/total))) + "," + str(mi) + "," + str((100 - (mi*100/total))) + "," + str(avg) + "," + str((100 - (avg*100/total))) + "\r"
        output += "\r"
        
        output += "Special,total,max,min-decrease,min,max-decrease,avg,avg-decrease\r"
        for n in numbers:
            if(n not in first):
                output += str(n) + "\r"
            else:
                total = totalOther[n]
                actual_total = total
                if(total == 0):
                    total = 1
                ma = maxOther[n]
                mi = minOther[n]
                avg = avgOther[n]
                output += str(n) + "," + str(actual_total) + "," + str(ma) + "," + str((100 - (ma*100/total))) + "," + str(mi) + "," + str((100 - (mi*100/total))) + "," + str(avg) + "," + str((100 - (avg*100/total))) + "\r"
        output += "\r"
        
        output += "Total,total,max,min-decrease,min,max-decrease,avg,avg-decrease\r"
        for n in numbers:
            if(n not in first):
                output += str(n) + "\r"
            else:
                total = totalTotal[n]
                actual_total = total
                if(total == 0):
                    total = 1
                ma = maxTotal[n]
                mi = minTotal[n]
                avg = avgTotal[n]
                output += str(n) + "," + str(actual_total) + "," + str(ma) + "," + str((100 - (ma*100/total))) + "," + str(mi) + "," + str((100 - (mi*100/total))) + "," + str(avg) + "," + str((100 - (avg*100/total))) + "\r"
        
        with open("output/"+bench+"/ics_sc_linker.csv", 'w') as write:
            write.write(output)
