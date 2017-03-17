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

size = 1000

plt.plot(d['B1E'].TS.values[:size], d['B1E'].P.values[:size])
plt.plot(d['B2E'].TS.values[:size], d['B2E'].P.values[:size])

# Sum all active power, except WHE 
all_P = sum(v.P for (k,v) in d.iteritems() if k!='WHE')

plt.plot(d['WHE'].P)
plt.plot(all_P)
plt.plot(d['WHE'].P-all_P)