# -*- coding: utf-8 -*-
"""
Created on Thu Mar 16 21:18:12 2017

@author: wittmann
"""

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import os

# Get all csv files from the current folder
files = [f for f in os.listdir('.') if os.path.isfile(f) and f[-3:]=='csv' and 'ground_truth' not in f]

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
all_P = sum(v.P for (k,v) in d.items() if k!='WHE')
all_Q = sum(v.Q for (k,v) in d.items() if k!='WHE')

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

# Create ground truth data and export to csv
# all_P.to_csv('ground_truth_P.csv')
# all_Q.to_csv('ground_truth_Q.csv')

# TODO: Create DBSCAN clustering algorithm to get the main states of each algorithm

# Visualize appliance for test clustering 
init = 0
end = 43200 # minutes
appl = 'BME'
# plt.plot(d[appl].P[init:end], d[appl].Q[init:end],'o', alpha=0.1)

# Import clusterer
from sklearn.cluster import DBSCAN
from sklearn.preprocessing import StandardScaler
from numpy import linalg as LA

# Set list of colors
colors = np.array([x for x in 'bgrcmykbgrcmykbgrcmykbgrcmyk'])
colors = np.hstack([colors] * 20)

# Compute DBSCAN
X = np.transpose([d[appl].P[init:end].values, d[appl].Q[init:end].values])
X = StandardScaler().fit_transform(X)
db = DBSCAN(eps=0.8, min_samples=50).fit(X)
y_pred = y_pred = db.labels_.astype(np.int)
plt.figure()
plt.scatter(X[:,0],X[:,1], color=colors[y_pred])

# Plot multiple graphs with clusterers
delta = 30 # VA (minimum aparent power to be identified)
for appl in names:
    if appl == 'B2E':
        continue
    # Create vector with P and Q values
    P = d[appl].P[init:end].values
    Q = d[appl].Q[init:end].values
    X = np.transpose([P, Q])
    X = [x for x in X if LA.norm(x)>=delta] # Ignore values lower than delta VA

    # Normalize X
    if len(X) == 0:
        print 'No value lower than {} VA was found in {}'.format(delta, appl)
        continue
    
    sscl = StandardScaler().fit(X)
    X = sscl.transform(X)
    
    # Apply clusterer
    db = DBSCAN(eps=1, min_samples=50).fit(X)
    y_pred = y_pred = db.labels_.astype(np.int)

    # Plot clusters with X unnormalized
    X = sscl.inverse_transform(X)    
    plt.figure()
    plt.scatter(X[:,0],X[:,1], color=colors[y_pred])
    





















