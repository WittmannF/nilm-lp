from __future__ import print_function, division
import sys
import numpy as np
import pandas as pd

def find_steady_states(dataframe, min_n_samples=2, state_threshold=15,
                       noise_level=70):
    """Finds steady states given a DataFrame of power.

    Parameters
    ----------
    dataframe: pd.DataFrame with DateTimeIndex
    min_n_samples(int): number of samples to consider constituting a
        steady state.
    stateThreshold: maximum difference between highest and lowest
        value in steady state.
    noise_level: the level used to define significant
        appliances, transitions below this level will be ignored.
        See Hart 1985. p27.

    Returns
    -------
    steady_states, transitions
    """
    # Tells whether we have both real and reactive power or only real power
    num_measurements = len(dataframe.columns)
    estimated_steady_power = np.array([0] * num_measurements)
    last_steady_power = np.array([0] * num_measurements)
    previous_measurement = np.array([0] * num_measurements)

    # These flags store state of power

    instantaneous_change = False  # power changing this second
    ongoing_change = False  # power change in progress over multiple seconds

    index_transitions = []  # Indices to use in returned Dataframe
    index_steady_states = []
    transitions = []  # holds information on transitions
    steady_states = []  # steadyStates to store in returned Dataframe
    N = 0  # N stores the number of samples in state
    time = dataframe.iloc[0].name  # first state starts at beginning

    # Iterate over the rows performing algorithm
    print("Finding Edges, please wait ...")
    sys.stdout.flush()

    for row in dataframe.itertuples():
        #print(row)

        # test if either active or reactive moved more than threshold
        # http://stackoverflow.com/questions/17418108/elegant-way-to-perform-tuple-arithmetic
        # http://stackoverflow.com/questions/13168943/expression-for-elements-greater-than-x-and-less-than-y-in-python-all-in-one-ret

        # Step 2: this does the threshold test and then we sum the boolean
        # array.
        this_measurement = row[1:3]

        # logging.debug('The current measurement is: %s' % (thisMeasurement,))
        # logging.debug('The previous measurement is: %s' %
        # (previousMeasurement,))

        state_change = np.fabs(
            np.subtract(this_measurement, previous_measurement))
        # logging.debug('The State Change is: %s' % (stateChange,))

        if np.sum(state_change > state_threshold):
            instantaneous_change = True
        else:
            instantaneous_change = False

        # Step 3: Identify if transition is just starting, if so, process it
        if instantaneous_change and (not ongoing_change):

            # Calculate transition size
            last_transition = np.subtract(estimated_steady_power, last_steady_power)
            # logging.debug('The steady state transition is: %s' %
            # (lastTransition,))

            # Sum Boolean array to verify if transition is above noise level
            if np.sum(np.fabs(last_transition) > noise_level):
                # 3A, C: if so add the index of the transition start and the
                # power information

                # Avoid outputting first transition from zero
                index_transitions.append(time)
                # logging.debug('The current row time is: %s' % (time))
                transitions.append(last_transition)

                # I think we want this, though not specifically in Hart's algo notes
                # We don't want to append a steady state if it's less than min samples in length.
                # if N > min_n_samples:
                index_steady_states.append(time)
                # logging.debug('The ''time'' stored is: %s' % (time))
                # last states steady power
                steady_states.append(estimated_steady_power)

            # 3B
            last_steady_power = estimated_steady_power
            # 3C
            time = row[0]

        # Step 4: if a new steady state is starting, zero counter
        if instantaneous_change:
            N = 0

        # Hart step 5: update our estimate for steady state's energy
        estimated_steady_power = np.divide(
            np.add(np.multiply(N, estimated_steady_power),
                   this_measurement), (N + 1))
        # logging.debug('The steady power estimate is: %s' %
        #    (estimatedSteadyPower,))
        # Step 6: increment counter
        N += 1

        # Step 7
        ongoing_change = instantaneous_change

        # Step 8
        previous_measurement = this_measurement

    # Appending last edge
    last_transition = np.subtract(estimated_steady_power, last_steady_power)
    if np.sum(np.fabs(last_transition) > noise_level):
        index_transitions.append(time)
        transitions.append(last_transition)
        index_steady_states.append(time)
        steady_states.append(estimated_steady_power)

    # Removing first edge if the starting steady state power is more
    # than the noise threshold
    #  https://github.com/nilmtk/nilmtk/issues/400

    if np.sum(steady_states[0] > noise_level) and index_transitions[0] == index_steady_states[0] == dataframe.iloc[0].name:
        transitions = transitions[1:]
        index_transitions = index_transitions[1:]
        steady_states = steady_states[1:]
        index_steady_states = index_steady_states[1:]

    print("Edge detection complete.")

    print("Creating transition frame ...")
    sys.stdout.flush()

    cols_transition = {1: ['active transition'],
                       2: ['active transition', 'reactive transition']}

    cols_steady = {1: ['active average'],
                   2: ['active average', 'reactive average']}

    
    if len(index_transitions) == 0:
        # No events
        return pd.DataFrame(), pd.DataFrame()
    else:
        transitions = pd.DataFrame(data=transitions, index=index_transitions,
                                   columns=cols_transition[num_measurements])
        print("Transition frame created.")

        print("Creating states frame ...")
        sys.stdout.flush()
        steady_states = pd.DataFrame(data=steady_states, index=index_steady_states,
                                     columns=cols_steady[num_measurements])
        print("States frame created.")
        print("Finished.")
        return steady_states, transitions