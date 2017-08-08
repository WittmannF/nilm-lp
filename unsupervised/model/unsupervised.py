import pandas as pd
import numpy as np
from nilmtk.dataset_converters import convert_ampds
from nilmtk import DataSet
from nilmtk.disaggregate.hart_85 import Hart85
import os
from feature_extractor import find_steady_states


# Input local data in WHE
def process_WHE(month, n_rows, try_new_ds = True):
    print("Reading original WHE file...")
    WHE = pd.read_csv('/Users/wittmann/nilmtk/nilmtk/data/AMPds/WHE.csv')

    print("Processing and saving...")
    if try_new_ds:
            WHE = pd.DataFrame(np.zeros((n_rows,12)),columns=WHE.columns)
            WHE['TS'] = month['T']
            WHE['S'] = WHE['P'] = WHE['Q'] = month['P']
            WHE['V'] = WHE['V'].apply(lambda x: 127)
            WHE['I'] = WHE['P']/127
            WHE['f'] = WHE['f'].apply(lambda x: 60)
            WHE['DPF'] = WHE['DPF'].apply(lambda x: 1)
            WHE['APF'] = WHE['APF'].apply(lambda x: 0.92)
            WHE['Pt'] = WHE['Pt'].apply(lambda x: 22)
            WHE['Qt'] = WHE['Qt'].apply(lambda x: 3)
            WHE['St'] = WHE['St'].apply(lambda x: 23)
            WHE.to_csv('/Users/wittmann/nilmtk/nilmtk/data/unsupervised/WHE.csv', index=False)
    else:
            WHE['TS'] = month['T']
            WHE['S'] = WHE['P'] = WHE['Q'] = month['P']
            WHE.to_csv('/Users/wittmann/nilmtk/nilmtk/data/unsupervised/WHE.csv', index=False)

    print("Done!")

def read_ph1(path):

    return pd.read_csv(path, header=None, names=['T', 'P'])

def read_ph2(path):
    month = pd.read_csv(path, header=None, names=['T', 'P'])

    return sync_ph2(month)

def sync_ph2(month):
    FIRST_TS = month['T'][0] # First timestamp of the dataset
    NEW_SR = 30 # New sampling rate to be converted

    month['T'] = month['T'].apply(lambda x: x-FIRST_TS)
    month = month[month['T'].apply(lambda x: x%NEW_SR==0)]
    month.index = range(len(month.index))
    month['T'] = month['T'].apply(lambda x: x+FIRST_TS)

    return month

def create_h5_file(ph1_path, ph2_path, files_path, h5_files_path, change_phase):
    # Read and process phase 1
    month1 = read_ph1(ph1_path)
    month2 = read_ph2(ph2_path)

    # Put dataset into WHE.csv file
    if not change_phase:
        process_WHE(month1, len(month1))
    else:
        process_WHE(month2, len(month2))

    # Convert to H5 file
    convert_ampds(files_path, h5_files_path)

def get_states(h5_files_path):
    # Read H5 file
    localhome = DataSet(h5_files_path)

    # Get mains
    elec = localhome.buildings[1].elec
    mains = elec.mains()

    # Train Hart's model
    h = Hart85()
    h.train(mains)
    pairs = h.pair_df

    # Get states with duration
    states = pd.DataFrame(pairs['T2 Time'] - pairs['T1 Time'], columns=['duration'])
    states['P'] = pairs['T1 Active']

    # return centroids (load models)
    return [h.centroids, states]

def describe(centroids, states):
    '''Describe states acquired from get_states'''

    # Print power states
    print("I found those states's models")
    print(centroids)

    ### Describe states and get minimum time
    for c in centroids.values:
            filt = np.array(states.P<1.1*int(c)) & np.array(states.P>0.9*int(c))
            print(states[filt].describe())

def write_dataset(dataset, dat_path):
    with open(dat_path,'w') as f:
        f.writelines('param: TS:  Ptotal:=\n')

    dataset.index = range(1,len(dataset)+1)
    dataset['P'].to_csv(dat_path, sep='\t', mode='a')

    with open(dat_path, 'a') as f:
        f.writelines(';')

def simulate():
    # Send terminal command to run AMPL
    response = os.system("ampl 1_NILM_LP.run > z_results_out.out")

def write_input_file(input_path, wind_size, standby):
    with open(input_path,'w') as f:
        f.writelines('include 3_NILM_LP_dados_medidor.dat;\n\n'\
            'param:  ESTADO:    disp    ant        Pdisp    mindisc :=\n'\
            '1        1        0        235        9\n'\
            '2        2        0        5569    8\n'\
            '3        3        0        7608    10\n'\
            '4        4        0        3753    2\n'\
            '5        5        0        2373    10\n'\
            '6        6        0        {}      0;\n\n\n'.format(standby))

        f.writelines('let numdisp := 6;\n'\
                    'let standby_state := 6;\n'\
                    'let disc_i := 1;\n'\
                    'let window := {};\n'\
                    'let TH := 30;\n'.format(wind_size))

def preprocess(df, q=0.05):

    # Convert df index to datetime
    df['T'] = pd.to_datetime(df['T'], unit='s')
    df = df.set_index('T')

    # Get edges and standby power
    steady_states, transitions = find_steady_states(df)

    # Get values for a given quantile q (default 5%)
    standby_power = int(df.quantile(q).values)

    return transitions, standby_power

def main():
    '''
    This file is split into 5 steps:
            1. Create H5 file (optional to use as input in NILMTK)
            2. Learn appliance's models (also optional if models weren't learned yet)
            3. Disaggregate
    '''
    ############ Input parameters and flags ###########
    #create_h5 = False # Save Dataset
    
    #create_h5 = False
    ph2_ck = False # True - phase 2 ; False - phase 1
    month = 'may'
    files_path = '/Users/wittmann/nilmtk/nilmtk/data/unsupervised/'
    h5_name = 'house_{}_{}.h5'.format(month, 2 if ph2_ck else 1)
    h5_files_path = files_path + h5_name
    create_h5 = False

    # Inputs for saving the dataset
    bool_write_ds = False
    dat_name = '3_NILM_LP_dados_medidor.dat'
    model_path = '/Users/wittmann/projects/nilm-lp/unsupervised/model/'
    dat_path = model_path + dat_name

    input_name = '3_NILM_LP_dados.dat'
    input_path = model_path + input_name

    wind_size = 160 # Length of measurements for performing optimization
    n_wind = 4 # Number of windows for performing preprocessing
    n_meas = 1000 # Number of measurements to analyze and disaggregate
    horizon = n_wind * wind_size # Horizon of measurements for preprocessing

    # Measurements with the phase 1 and 2 of the month
    ph1_path = '/Users/wittmann/projects/nilm-lp/unsupervised/data/{}_1.csv'.format(month)
    ph2_path = '/Users/wittmann/projects/nilm-lp/unsupervised/data/{}_2.csv'.format(month)

    # Flag for Learn appliance's models from the last month
    learn_appliance = False
    describe_states = False

    ############ Beginning of logical implementation ############

    # 1. Read local data and create h5 file
    if create_h5:
        create_h5_file(ph1_path, ph2_path, files_path, h5_files_path, ph2_ck)

    # 2. Learn appliance's model
    if learn_appliance:
        # Get main power states from H5 file
        [centroids, states] = get_states(h5_files_path)
        if describe_states:
            describe(centroids, states)

    # 3. Disaggregate
    # Read full month dataset 
    dataset = read_ph1(ph1_path) if not ph2_ck else read_ph1(ph1_path)

    # Clean the file with results and ground truth
    open(model_path+'z_results_x.csv','w').close()
    open(model_path+'z_ground_truth.csv','w').close()

    # Perform a range over time (simulate real time disaggregation)
    for t in range(0, n_meas, horizon):

        # Data for preprocessing and perform disaggregation
        dataframe = dataset[t:t+horizon]

        # Get edges from the last n_wind windows for the input table
        edges, standby_power = preprocess(dataframe)

        # Write table of states for inputting in AMPL
        write_input_file(input_path, wind_size, standby_power)

        # Update dataset and simulate
        print('Simulating on AMPL from t = {} to t = {}'.format(t,t+horizon))
        write_dataset(dataframe, dat_path)
        simulate()

        # Export ground gruth data for comparison
        dataframe.to_csv('z_ground_truth.csv', mode='a', index=False, header=False)


if __name__ == '__main__':
    main()





