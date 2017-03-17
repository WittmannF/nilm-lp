# -*- coding: utf-8 -*-
"""
Created on Thu Mar 16 21:18:12 2017

@author: wittmann
"""

import pandas as pd
import matplotlib.pyplot as plt
import os

# Get all csv files from the current folder
files = [f for f in os.listdir('.') if os.path.isfile(f) and f[-3:]=='csv']

# Create list of dataframes from all csv files
data = [pd.read_csv(f) for f in files]

# Get name list to use in dictionary
names = [f[:-4] for f in files]

# Create dictionary with database.
d = dict(zip(names,data))

# Plot by size 
init = 0
end = 5000

# Sum all active power, except WHE 
all_P = sum(v.P for (k,v) in d.iteritems() if k!='WHE')
all_Q = sum(v.Q for (k,v) in d.iteritems() if k!='WHE')

# Plot all appliances
for appl in names:
    plt.plot(d[appl].P[init:end])

plt.legend(names)

# Plot clusters of active and reactive power
for appl in names:
    if appl != 'WHE':
        plt.plot(d[appl].P[init:end], d[appl].Q[init:end],'o', alpha=0.1)

to_leg = [n for n in names if n!='WHE']
to_leg.append('WHE Steps')

# Get steps
w = 5
P_steps = all_P.values[init+w:end] - all_P.values[init:end-w]
Q_steps = all_Q.values[init+w:end] - all_Q.values[init:end-w]

# Plot steps
plt.plot(abs(P_steps),abs(Q_steps),'o', alpha=0.1)
plt.legend(to_leg)