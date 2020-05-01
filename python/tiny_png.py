""" PNG/JPG compression via tinypng.com

    Get API key https://tinypng.com/developers
"""

#!/usr/bin/env python3

from sys import argv
from os import mkdir
from os.path import dirname
from os.path import basename
from os.path import isfile
from os.path import isdir
from os.path import join as path_join
from os import walk as os_walk
from base64 import b64encode
from http.client import HTTPSConnection as https

def gen_file_list(args):
    """ Generate list of picutres """
    allowed_ext = {"png", "jpeg", "jpg"}

    for arg in args:
        if isfile(arg):
            if not arg.rsplit(".", 1)[-1] in allowed_ext:
                print("".join((">>>File ", arg, " is not png or jpg/jpeg")))
            yield arg

        elif isdir(arg):
            for pic in (file_name for file_name in next(os_walk(arg))[2] if file_name.rsplit(".", 1)[-1] in allowed_ext):
                yield path_join(arg, pic)

        else:
            print("".join((">>>", arg, " no such file or directory")))
            continue

def main(args):
    if not args:
        return

    key = "" #enter API key
    auth = b64encode(bytes("api:" + key, "ascii")).decode("ascii")
    headers = {"Authorization" : " ".join(("Basic", auth))}
    connection = https("api.tinypng.com")
    for picture_file in gen_file_list(args):
        print(" ".join((">>>Shrink pic:", picture_file)))

        result_dir = path_join(dirname(picture_file), "tiny_png_optimized")
        if not isdir(result_dir):
            mkdir(result_dir)
        output = path_join(result_dir, basename(picture_file))

        connection.request("POST", "https://api.tinypng.com/shrink", open(picture_file, "rb").read(), headers)
        response = connection.getresponse()
        if response.status == 201:
            # Compression was successful, retrieve output from Location header.
            response.read()
            connection.request("GET", response.getheader("Location"))
            result = connection.getresponse()
            open(output, "wb").write(result.read())
            print(" ".join(("Succesfuly shrinked. Result pic:", output)))
        else:
            # Something went wrong! You can parse the JSON body for details.
            print(" ".join(("Failed to compress:", picture_file, "Status:", str(response.status))))
            print(" ".join(("Reason:", response.reason)))
            response.read()


if __name__ == "__main__":
    main(argv[1:])
    input("Press any key...")
