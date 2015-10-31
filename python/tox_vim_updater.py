""" Vim updater from tuxproject.de

    Check build date and download new bulds, if any
    Requires initial config file with build date [year]-[month]-[day]
    Note: year is 4 digits
"""

#!/usr/bin/env python3

from http.client import HTTPSConnection as https
from re import compile as re_compile
from os import getenv, path
from sys import argv

CONFIG_FILE = "vim_updater.cfg"

def read_config():
    """ Read config and return list [year, month, day]

        Check order:
        [current dir]/CONFIG_FILE
        [script location]/CONFIG_FILE
        [APPDATA]/CONFIG_FILE
    """
    global CONFIG_FILE

    try:
        with open(CONFIG_FILE) as config_file:
            return config_file.read().split("-")
    except FileNotFoundError:
        pass

    app_data = path.dirname(path.realpath(argv[0]))
    CONFIG_FILE = path.join(app_data, CONFIG_FILE)

    try:
        with open(CONFIG_FILE) as config_file:
            return config_file.read().split("-")
    except FileNotFoundError:
        pass

    app_data = getenv("APPDATA")
    CONFIG_FILE = path.join(app_data, "tox_vim_updater.cfg")

    try:
        with open(CONFIG_FILE) as config_file:
            return config_file.read().split("-")
    except FileNotFoundError:
        print("No config file")
        exit(0)


def tox_vim_updater():
    """ Main function """
    old_date = tuple(int(number) for number in read_config())

    connection = https("tuxproject.de")
    connection.request("GET", "/projects/vim/")
    response = connection.getresponse()

    if response.status != 200:
        print("Failed to connect. Reason:", response.reason)
        return

    data = response.read().decode('utf-8')
    check_date = re_compile("[0-9]{4,}(-[0-9]{2,}){2,}")
    check_version = re_compile("[0-9]+.[0-9]+.[0-9]+")

    result_date = check_date.search(data)
    result_date = result_date.group(0)

    date = tuple(int(number) for number in result_date.split("-"))

    if not date > old_date:
        print("Vim is up-to-date")
        return

    result_version = check_version.search(data)
    version = result_version.group(0)

    print("New build is found:")
    print("Version:", version)
    print("Build date:", result_date)

    #update config
    with open(CONFIG_FILE, "w") as config:
        config.write(result_date)

    #64bit
    connection.request("GET", "/projects/vim/complete-x64.7z")
    response = connection.getresponse()

    if response.status != 200:
        print("Failed to connect. Reason:", response.reason)
        return

    with open("vim-x64.7z", "wb") as vim_file:
        vim_file.write(response.read())

    print("Succesfully downloaded vim-x64.7z")

if __name__ == "__main__":
    print("#"*50)
    print("Source: https://tuxproject.de/projects/vim/")
    print("Visit site to give thanks(donate button at bottom)")
    print("#"*50)
    tox_vim_updater()
