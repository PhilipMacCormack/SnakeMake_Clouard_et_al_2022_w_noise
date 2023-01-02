'''
utility: force snakemake to wait until sbatch output returns
'''

import argparse
parser = argparse.ArgumentParser()
parser.add_argument("-p", "--parameter", help="Filepath")
args = parser.parse_args()

nr_waitforfiles = int(args.parameter)

import sys, os
import time

# hold here until prophaser folder is created
#while len(os.listdir(r'Output/')) < 6:
#    time.sleep(5)
#    print('waiting on prophaser folder')


# folder path
dir_path = r'Output/prophaser/'

print('waiting for files')
while len(os.listdir(dir_path)) < nr_waitforfiles:
    time.sleep(5)
    print('still waiting, files produced: ', len(os.listdir(dir_path)))

print('done')

