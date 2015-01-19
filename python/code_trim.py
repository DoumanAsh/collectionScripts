#!/usr/bin/python
#remove tailing spaces in provided dir/file

import os
from sys import argv
from shutil import copy2

def trimm_file(filename):
    backup = filename + ".old"
    copy2(filename, backup)
    try:
        with open(backup, 'r') as input_file, open(filename, 'w') as output_file:
            for line in input_file:
                #\n is interpreted according to platform in text mode
                output_file.write(line.rstrip() + '\n')
        os.remove(backup)
    except Exception as e:
        print(">>>Exception: " + str(e))
        print("Something wrong with " + filename)
        print("Rollback changes")
        if os.path.isfile(filename):
            os.remove(filename)
        os.rename(backup, filename)

def trimmer():
    args = argv[1:]
    for arg in args:
        if os.path.isfile(arg):
            trimm_file(arg)
        elif os.path.isdir(arg):
            for path, dirs, files in os.walk(arg):
                for f in files:
                    file_name, file_extension = os.path.splitext(f)
                    if not file_extension == '':
                        trimm_file(os.path.join(path, f))
        else:
            print("".join((arg, " is not found")))

if __name__ == "__main__":
    trimmer()
