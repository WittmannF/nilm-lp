import pandas as pd
import numpy as np
from nilmtk.dataset_converters import convert_ampds
from nilmtk import DataSet
from nilmtk.disaggregate.hart_85 import Hart85
import os
from feature_extractor import find_steady_states
from sklearn.cluster import KMeans


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

def read_ph2(path, sync_flag=True):
    df = pd.read_csv(path, header=None, names=['T', 'P'])

    return sync_ph2(df) if sync_flag else df

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

def write_input_table(input_path, wind_size, top_states, min_time, standby):
    with open(input_path,'w') as f:
        f.writelines('include 3_NILM_LP_dados_medidor.dat;\n\n'\
            'param:  ESTADO:    disp    ant        Pdisp    mindisc :=\n'\
            '1        1        0        {st[0]}        {mt[0]}\n'\
            '2        2        0        {st[1]}        {mt[1]}\n'\
            '3        3        0        {st[2]}        {mt[2]}\n'\
            '4        4        0        {st[3]}        {mt[3]}\n'\
            '5        5        0        {sb}           0;\n\n\n'.format(st = top_states, mt = min_time, sb = standby))

        f.writelines('let numdisp := card(ESTADO);\n'\
                    'let standby_state := card(ESTADO);\n'\
                    'let disc_i := 1;\n'\
                    'let window := {};\n'\
                    'let TH := 30;\n'.format(wind_size))

def preprocess(df, q=0.01):

    # Convert df index to datetime
    df['T'] = pd.to_datetime(df['T'], unit='s')
    df = df.set_index('T')

    # Get edges and standby power
    steady_states, transitions = find_steady_states(df)

    # Get values for a given quantile q (default 5%)
    standby_power = int(df.quantile(q).values)

    return steady_states, transitions, standby_power

def get_top_states(edges, k=4):
    # Get absolute value
    edges_abs = edges.apply(lambda x: abs(x))

    # If the number of edges is < k, fill the rest with zeros

    if len(edges_abs.values)<k:
        if len(edges_abs)>0:
            top_states = edges_abs['active transition'].values.tolist()
        else:
            top_states = []

        while len(top_states)<k:
            top_states.append(0)
        return top_states

    # Perform k-means clustering
    kmeans = KMeans(n_clusters=k, random_state=0).fit(edges_abs.values)
    labels = kmeans.labels_

    # Get median of each cluster to assing as top state
    top_states = [round(np.median(edges_abs[labels==l])) for l in range(k)]

    return top_states

def get_min_time(edges, top_states, DEFAULT_MIN_TIME):

    min_time = np.ones(len(top_states)) * DEFAULT_MIN_TIME
    return min_time

def remote_simulation(address):
    print('Sending files to the remote server...')
    os.system("scp -qp * {}:unsupervised/".format(address))

    print('Simulating on remote AMPL...')
    response = os.system("ssh -t '{}' 'cd unsupervised && ampl 1_NILM_LP.run > z_results_out.out'".format(address))

    if response == 0:
        print('Copying results from server to local machine...')
        os.system("scp -qp {}:unsupervised/z_results_\* .".format(address))

def send_to_server(address):
    print('Sending files to the remote server...')
    os.system("scp -qp z_results* {}:nilm-results/".format(address))




def main():

    ############ Input parameters and flags ###########
    ph2_ck = False # True - phase 2 ; False - phase 1
    downsample_p2 = True # Check if it is necessary to downsample phase 2
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

    ground_truth_name = 'z_results_ground_truth.csv'

    # Constants
    wind_size = 160 # Length of measurements for performing optimization
    n_wind = 4 if downsample_p2 else 12 # Number of windows for performing preprocessing
    horizon_size = n_wind * wind_size # Horizon of measurements for preprocessing
    n_hor = 40
    n_meas = n_hor * horizon_size # Number of measurements to analyze and disaggregate
    defalt_min_time = 8 if downsample_p2 else 24 # Default mintime value

    # Measurements with the phase 1 and 2 of the month
    ph1_path = '/Users/wittmann/projects/nilm-lp/unsupervised/data/{}_1.csv'.format(month)
    ph2_path = '/Users/wittmann/projects/nilm-lp/unsupervised/data/{}_2.csv'.format(month)

    # Flag for Learn appliance's models from the last month
    learn_appliance = False
    describe_states = False

    dsee_address = 'wittmann@ssh.dsee.fee.unicamp.br'

    '''
    This code is divided into 5 steps:
        1. Create H5 file (optional to use as input in NILMTK)
        2. Learn appliance's models (also optional if models weren't learned yet)
        3. Disaggregate
    '''

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
    dataset = read_ph1(ph1_path) if not ph2_ck else read_ph2(ph2_path, downsample_p2)

    # Create new file with results and ground truth
    open(model_path+'z_results_x.csv','w').close()
    open(model_path+ground_truth_name,'w').close()
    open(model_path+'z_results_estado.csv','w').close()

    n_meas = len(dataset)

    # Perform a range over time (simulating real time disaggregation)
    for t in range(0, n_meas, horizon_size):

        t_f = t+horizon_size

        if t_f > n_meas:
            t_f = n_meas

        # Data for preprocessing and perform disaggregation
        horizon = dataset[t:t_f]

        # Get edges from the last n_wind windows for the input table
        steady_states, edges, standby_power = preprocess(horizon)

        # Get top states to fill in the data table
        top_states = get_top_states(edges)

        # Get minimum time to fill in the data table
        min_time = get_min_time(edges, top_states, defalt_min_time)

        # Write data table to input on AMPL
        write_input_table(input_path, wind_size, top_states, min_time, standby_power)

        # Update dataset and simulate
        print('Simulating on AMPL from t = {} to t = {}'.format(t,t_f))
        write_dataset(horizon, dat_path)
        simulate()

        # Export ground gruth data for comparison
        horizon.to_csv(ground_truth_name, mode='a', index=False, header=False)

        # Send results to my lab's machine
        send_to_server(dsee_address)


if __name__ == '__main__':
    main()





