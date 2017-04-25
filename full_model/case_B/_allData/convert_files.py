# -*- coding: utf-8 -*-
"""
Created on Tue Apr 25 14:10:31 2017

@author: wittmann
"""

import numpy as np
import pandas as pd

def get_PQ(app_list):
    data = [pd.read_csv(f+'.csv') for f in app_list]
    
    all_P = sum(d.P for d in data)
    all_Q = sum(d.Q for d in data)
    
    return[all_P, all_Q]

def create_ground_truth(app_list, init, ending, path):
    data = [pd.read_csv(f+'.csv') for f in app_list]
    
    appl_P = np.transpose([d.P.values[init-1:ending] for d in data])
    ground_truth = pd.DataFrame(appl_P, columns=app_list, index=range(init,ending+1))
    
    ground_truth['all_P'] = ground_truth.sum(1)
    
    ground_truth.to_csv(path)
    