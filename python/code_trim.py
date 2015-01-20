""" Script to remove tailing spaces in provided dir/file """

#!/usr/bin/python

import os
#use io variant of open(). It has encoding in py2
from io import open
from sys import argv
from shutil import copy2

def trimm_file(filename):
    """ Trimms file of white spaces """
    backup = filename + ".old"
    try:
        copy2(filename, backup)
        input_file = open(backup, 'r', encoding='utf-8')
        output_file = open(filename, 'w', encoding='utf-8')
    except IOError:
        print("Permission denied")
        print("".join((filename, " will be ignored")))
        return

    try:
        for line in ("".join((line.rstrip(), '\n')) for line in input_file):
            output_file.write(line)
    except UnicodeDecodeError as e:
        print("".join(("Encoding error: ", str(e))))
        print("".join(("Failed to trimm ", filename)))

    input_file.close()
    output_file.close()
    os.remove(backup)
    return

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
                    if not file_extension == '' and not file_extension == ".old":
                        trimm_file(os.path.join(path, proc_file))
        else:
            print("".join((arg, " is not found")))

if __name__ == "__main__":
    trimmer()