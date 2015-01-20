""" Script to remove tailing spaces in provided dir/file """

#!/usr/bin/python

import os
from sys import argv
from shutil import copy2

def trimm_file(filename):
    """ Trimms file of white spaces """
    backup = filename + ".old"
    copy2(filename, backup)
    with open(backup, 'r') as input_file, open(filename, 'w') as output_file:
        for line in input_file:
            #\n is interpreted according to platform in text mode
            output_file.write(line.rstrip() + '\n')
    os.remove(backup)

def trimmer():
    """ Run through arguments to apply trimm_file() """
    args = argv[1:]
    for arg in args:
        if os.path.isfile(arg):
            trimm_file(arg)
        elif os.path.isdir(arg):
            for path, _, files in os.walk(arg):
                for proc_file in files:
                    _, file_extension = os.path.splitext(proc_file)
                    if not file_extension == '':
                        trimm_file(os.path.join(path, proc_file))
        else:
            print("".join((arg, " is not found")))

if __name__ == "__main__":
    trimmer()
