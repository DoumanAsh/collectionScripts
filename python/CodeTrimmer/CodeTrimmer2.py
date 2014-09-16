#!/usr/bin/python
#remove tailing spaces in provided dir/file
#Usage: CodeTrimmer path [-l/--language language] [-e/--extension extension]
import sys
import os
import argparse
convertLan = { 'c'          : ['.c', '.cc', '.h', '.hh'],
               'c++'        : ['.c', '.cc', '.h', '.hh'],
               'python'     : ['.py'],
               'renpy'      : ['.rpy'],
               'bash'       : ['.sh'],
               'powershell' : ['.ps1', '.psm1', '.psd1']          }

def trimmFile(filename):
    dest = filename
    source = dest + '.old'
    if os.path.isfile(source):
        os.remove(source)
    os.rename(dest, source)
    try:
        #utf-8 is enforced
        with open(source, 'r') as input, open(dest, 'w') as output:
            for line in input:
                #\n is interpreted according to platform in text mode
                output.write(line.rstrip() + '\n')
        os.remove(source)
    except Exception as e:
        print(">>>Exception: " + str(e))
        print("Something wrong with " + dest)
        print("Rollback changes")
        if os.path.isfile(dest):
            os.remove(dest)
        os.rename(source, dest)

parser = argparse.ArgumentParser(prog="CodeTrimmer", usage="%(prog)s path [-l/--language language] [-e/--extension extension]")
parser.add_argument('strings', nargs='+', metavar='path', help='pathes to proceed')
parser.add_argument('-l', '--language', dest='lan', nargs='*', required=False, help='coding languages to proceed')
parser.add_argument('-e', '--extension', dest='ext', nargs='*', required=False, help='extensions to proceed')
args = parser.parse_args()
#c/c++ is default cuz it is my work ;)
listExtensions = ['.c', '.cc', '.h', '.hh']
#convert provided languages to their extensions
if args.lan is not None:
    for lan in args.lan:
        try:
            listExtensions.extend(convertLan[lan])
        except:
            print(lan + ": not a valid language")
            pass
    listExtensions = list(set(listExtensions))
#add user defined extensions
if args.ext is not None:
    for ext in args.ext:
        listExtensions.extend(ext)
    listExtensions = list(set(listExtensions))
#main work
for arg in args.strings:
    if os.path.isdir(arg):
        for path, dirs, files in os.walk(arg):
            for f in files:
                file_name, file_extension = os.path.splitext(f)
                if file_extension in listExtensions:
                    trimmFile(os.path.join(path, f))
    elif os.path.isfile(arg):
        trimmFile(arg)
    else:
        print(arg + ": not found")