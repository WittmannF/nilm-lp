# -*- coding: utf-8 -*-
"""
Created on Tue Apr 25 14:11:26 2017

@author: wittmann
"""

from convert_files import create_ground_truth

app_list = app_list = ['BME', 'CDE', 'DWE', 'FGE', 'FRE', 'HPE', 'TVE']
init = 1
ending = 10080

create_ground_truth(app_list, init, ending, '../z_ground_truth.csv')