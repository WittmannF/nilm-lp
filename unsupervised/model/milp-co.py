import os

def remote_simulation(server_address):
    print('Sending files to the remote server...')
    os.system("scp -qp * {}:unsupervised/".format(server_address))

    print('Simulating on remote AMPL...')
    response = os.system("ssh -t '{}' 'cd unsupervised && ampl 1_NILM_LP.run > z_results_out.out'".format(server_address))

    if response == 0:
        print('Copying results from server to local machine...')
        os.system("scp -qp {}:unsupervised/z_results_\* .".format(server_address))

def run():
    # Server address
    server_address = ''
    # Open server, send files, simulate and copy files back to local machine
    remote_simulation(server_address)

if __name__ == "__main__":
    run()
