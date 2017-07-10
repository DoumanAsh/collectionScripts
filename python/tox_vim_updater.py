from subprocess import check_output, call
from os import path, chdir, remove
from re import compile as re_compile

from requests import get as http_get


def get_exe_version():
    vim_exe = path.join('vim', 'vim.exe')

    vim_version = check_output([vim_exe, '--version'])
    vim_version_re = re_compile(b'Included patches: \d+-(\d+)\s')
    vim_version = vim_version_re.search(vim_version)
    return vim_version.group(1).decode()


def get_tox_version(tox_index):
    vim_version_re = re_compile("<b>Vim version:</b> \d\.\d\.(\d+)*")

    vim_version = vim_version_re.search(tox_index)
    return vim_version.group(1)


def download_tox_vim():
    print("Downloading new vim version...")
    vim_archive = "complete-x64.exe"
    vim_download_link = "http://tuxproject.de/projects/vim/{}".format(vim_archive)

    response = http_get(vim_download_link, stream=True)
    with open(vim_archive, "wb") as vim_exe:
        for chunk in response.iter_content(chunk_size=1024):
            if chunk:
                vim_exe.write(chunk)

    return vim_archive


def extract_tox_vim(path, to):
    print("Extract new vim version...")
    cmd = "{} -y -gm2 -o\"{}\"".format(path, to)
    call(cmd, shell=True)


def main():
    current_dir = path.dirname(path.realpath(__file__))
    chdir(current_dir)

    vim_version = int(get_exe_version())

    tox_vim_res = http_get("https://tuxproject.de/projects/vim/")

    if tox_vim_res.status_code != 200:
        print("Failed to access tuxproject.de :(")
        return

    tox_vim_res = tox_vim_res.text
    tox_vim_version = int(get_tox_version(tox_vim_res))

    if tox_vim_version <= vim_version:
        print("Vim is up-to-date")
        return

    new_vim_path = download_tox_vim()
    extract_tox_vim(path.join(current_dir, new_vim_path), path.join(current_dir, "vim"))

    remove(new_vim_path)

if __name__ == "__main__":
    main()
