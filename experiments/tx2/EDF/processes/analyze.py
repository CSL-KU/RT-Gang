#!/usr/bin/env python
import os, re
import numpy as np
import matplotlib.pyplot as plt

rexRt = re.compile (r'^Job.* ([\d]+) us$')
def parse_rt (fileName):
    jobTimes = []
    with open (fileName, 'r') as fdi:
        for line in fdi:
            m = rexRt.match (line)

            if not m:
                continue

            jobTime = round ((float (m.group (1)) / 1000), 3)
            jobTimes.append (jobTime)

    if not jobTimes:
        raise ValueError, 'No regex match found in file: <%s>' % (fileName)

    return jobTimes

rexBe = re.compile (r'^[\s]+([\d,]+)[\s]+instructions.*$')
def parse_be (fileName):
    instructions = 0
    with open (fileName, 'r') as fdi:
        for line in fdi:
            m = rexBe.match (line)

            if not m:
                continue

            instructions = int (m.group (1).replace (',', ''))
            break

    if not instructions:
        raise ValueError, 'No regex match found in file: <%s>' % (fileName)

    return instructions

def get_stats (name, series, display = False):
    mean = round (np.mean (series), 3)
    std = round (np.std (series), 3)
    pct = round (np.percentile (series, 99))

    if display:
        print '====== Stats: ', name
        print '%-15s : %.3f' % ('Mean', mean)
        print '%-15s : %.3f' % ('Std. Dev', std)
        print '%-15s : %.3f' % ('WCET (99pct)', pct)
        print

    return [mean, pct]

def plot_stats (data):
    # Layout: X-Axis
    # Series:           Solo                         |              Corun                     |             RT-Gang
    # Labels: tau_1 (mean, wcet), tau_2 (mean, wcet) | tau_1 (mean, wcet), tau_2 (mean, wcet) | tau_1 (mean, wcet), tau_2 (mean, wcet)
    #  Ticks:          1     2             4    5    |          8    9              11   12   |         15    16            18    19
    # Y-Axis: Time (msec)
    series = {}
    xticks = []
    xlabels = []
    names = {'solo': 'Solo', 'becorun': 'Corun', 'bertg': 'RT-Gang'}
    hatches = {'Solo': '**', 'Corun': '..', 'RT-Gang': 'xx'}
    scnOrder = ['solo', 'becorun', 'bertg']
    tskOrder = ['tau_1', 'tau_2']

    tick = 1
    fig = plt.figure (figsize = (10, 5))
    for scenario in scnOrder:
        name = names [scenario]
        series [name] = {'values': [], 'ticks': []}
        for task in tskOrder:
            series [name]['values'] += get_stats ('x', data [scenario]['rt'][task]['jobs'])
            series [name]['ticks'] += [tick, tick + 1]
            xlabels += ['%s (mean)' % task, '%s (WCET)' % task]
            tick += 3
        xticks += series [name]['ticks']
        tick += 1

        # Make bar-plot for this scenario
        plt.bar (series [name]['ticks'], series [name]['values'], width = 1.0, lw = 2.0, color = 'white', edgecolor = 'k', hatch = hatches [name], label = name)

    plt.xticks (xticks, xlabels, rotation = 270, fontweight = 'bold')
    plt.legend (ncol = 1, loc = 'upper left')
    plt.grid (b = True, axis = 'y', linestyle = '--')
    plt.show ()

    return

def plot_cdf (data, task):
    num_bins = 1000
    lineType = {'solo': 'g-', 'bertg': 'b-', 'becorun': 'r-'}
    lineLabels = {'solo': 'Solo', 'becorun': 'CoSched', 'bertg': 'RT-Gang'}
    fontSizeLabels = 'x-large'
    fontWeightLabels = 'bold'
    margins = 0.15
    xLimLeft = min ([min (data [scenario]['rt'][task]['jobs']) for scenario in data.keys ()])
    xLimRight = max ([max (data [scenario]['rt'][task]['jobs']) for scenario in data.keys ()])
    xRange = xLimRight - xLimLeft
    xLimLeft = 0
    xLimRight = 30
    
    logs = ['solo', 'becorun', 'bertg']
    for exp in logs:
        series = [x for x in data [exp]['rt'][task]['jobs'] if x < np.percentile (data [exp]['rt'][task]['jobs'], 99.5)]
        counts, bin_edges = np.histogram (series, bins = num_bins, normed = True)
        cdf = np.cumsum (counts)
        plt.plot (bin_edges [1:], cdf/cdf[-1], lineType [exp], lw = 2.0, label = lineLabels [exp])

    plt.plot ([xLimLeft, xLimRight], [1, 1], 'k--', lw = 1)
    plt.xlim (xLimLeft, xLimRight)
    plt.ylim (0, 1.11)
    plt.xticks (fontsize = 'large', fontweight = 'bold')
    plt.yticks (fontsize = 'large', fontweight = 'bold')
    plt.ylabel ('CDF', fontsize = fontSizeLabels, fontweight = fontWeightLabels)
    plt.xlabel ('Job Execution Time (msec)', fontsize = fontSizeLabels, fontweight = fontWeightLabels)
    plt.legend (loc = 'upper center', ncol = 3, fontsize = 'medium')
    plt.grid ()
    plt.savefig ('%s.pdf' % (task), bbox_inches = 'tight')

    return

def main ():
    data = {
            'solo': {
                    'rt': {
                        'tau_1': {},
                        'tau_2': {}
                        },
                    'be': {}
                    },
            'becorun': {
                    'rt': {
                        'tau_1': {},
                        'tau_2': {}
                        },
                    'be': {
                        'tau_be_mem': {},
                        'tau_be_cpu': {}
                        }
                    },
            'bertg': {
                    'rt': {
                        'tau_1': {},
                        'tau_2': {}
                        },
                    'be': {
                        'tau_be_mem': {},
                        'tau_be_cpu': {}
                        }
                    }
            }

    # 'logs2' data is with tracing on. It seems to be good enough to be used
    # directly; instead of separatly analyzing data without tracing on in 'logs'
    for scenario in data.keys():
        for task in data [scenario]['rt'].keys ():
            fileName = 'logs2/%s.%s.trace' % (task, scenario)

            if not os.path.isfile (fileName):
                raise IOError, 'File does not exist: <%s>' % (fileName)

            data [scenario]['rt'][task]['jobs'] = parse_rt (fileName)

        for task in data [scenario]['be'].keys ():
            fileName = 'logs2/%s.%s.trace' % (task, scenario [2:])

            if not os.path.isfile (fileName):
                raise IOError, 'File does not exist: <%s>' % (fileName)

            data [scenario]['be'][task]['instructions'] = parse_be (fileName)

    # plot_stats (data)
    plot_cdf (data, 'tau_1')

    return

if __name__ == '__main__':
    main ()
