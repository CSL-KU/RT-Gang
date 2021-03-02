#! /usr/bin/python
# usage: python printstat.py <file> [-d <deadline>]

import sys
import os
import getopt

import corestats
import matplotlib.pyplot as plt

def main():
    try:
        optlist, args = getopt.getopt(sys.argv[1:], 'd:h', ["deadline=", "help"])
    except getopt.GetoptError as err:
        print (str(err))
        sys.exit(2)

    deadline = 0
    for opt, val in optlist:
        if opt in ("-h", "--help"):
            print (args[0] + " [-d <deadline>]")
        elif opt in ("-d", "--deadline"):
            deadline = float(val)
        else:
            assert False, "unhandled option"

    if deadline > 0:
        print ("deadline: %.2f" % deadline)

    items = {}
        
    print ("\t\tmin\tavg\t99pct\tmax\tstdev\tcount\tdmiss")
    for f in args:
        file1 = open(f, 'r')
        items[f] = []
        deadline_miss = 0;
        while(True):
            line = file1.readline()
            if not line:
                break
            # parsing
            # e.g., "Job 499 Took 2494 us"
            tokens = line.split();
            if len(tokens) == 0:
                continue
            if tokens[0] != 'Job':
                continue
            try:
                num  = float(tokens[3])
            except ValueError:
                break

            # update array
            items[f][len(items[f]):] = [num]

            # update deadline miss
            if deadline > 0 and num > deadline:
                deadline_miss += 1
            
        stats = corestats.Stats(items[f])        
        print ("%10s \t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%5d\t%5d" %
               (f, stats.min(), stats.avg(), stats.percentile(99), stats.max(), stats.stdev(),
                stats.count(), deadline_miss))

    fig, ax = plt.subplots()
    ax.set_title('Solo vs. Corun vs. RT-Gang')
    ax.set_ylabel('Time (us)')
    ax.boxplot(items.values())
    plt.xticks(range(1, len(items.keys())+1), items.keys())
    plt.savefig('plot.pdf')
    plt.show()
    
if __name__ == "__main__":
    main()
