""" File system module """

from os import path as os_path
from os import walk as os_walk
from shutil import copy2 as copy

def copy_files(source_dir, dest_dir, dest_only=False, ext_only=None):
    """ Copy files from @source_dir to @dest_dir.

        @param source_dir Directory from where to take files.
        @param dest_dir Directory where to copy files.
        @dest_only Determines if @dest_dir's files only will be copied.
        @ext_only Allowed for copy file extension or iterable of extensions
    """
    source_dir = os_path.expanduser(source_dir)
    dest_dir = os_path.expanduser(dest_dir)

    if not os_path.isdir(source_dir):
        print(" ".join((">>>", source_dir, "is not a directory or there is no such directory")))
        return

    elif not os_path.isdir(dest_dir):
        print(" ".join((">>>", dest_dir, "is not a directory or there is no such directory")))
        return

    #determine files to copy
    if dest_only:
        files_to_copy = (file_name for file_name in next(os_walk(source_dir))[2] if file_name in set(next(os_walk(dest_dir))[2]))
    else:
        files_to_copy = (file_name for file_name in next(os_walk(source_dir))[2])

    #filter by extensions
    if ext_only:
        ext_only = set([ext_only]) if isinstance(ext_only, str) else set(ext_only)
        files_to_copy = (file_name for file_name in files_to_copy if file_name.rsplit(".", 1)[-1] in ext_only)

    for file_name in files_to_copy:
        try:
            copy(os_path.join(source_dir, file_name), dest_dir)
        except IOError as errno:
            print(" ".join(("Cannot copy", file_name, "from", source_dir, "to", dest_dir)))
            print(" ".join((">>>Exception:", str(errno))))
