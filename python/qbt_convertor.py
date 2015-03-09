""" uTorrent migration to qBittorrent module """
from tkinter import Tk, StringVar, N, W, E, S, filedialog, messagebox, HORIZONTAL
from tkinter.ttk import Frame, Entry, Button, Label, Progressbar
from shutil import copy
from os import path
from hashlib import sha1
from time import time
from re import compile as re_compile
from tpp.bencodepy import encode as bencode
from tpp.bencodepy import decode as bdecode
from tpp.bencodepy import DecodingError

FIELD_MAP = {"active_time"          :   0,
             "added_time"           :   0,
             "allocation"           :   "full",
             "announce_to_dht"      :   1,
             "announce_to_lsd"      :   1,
             "announce_to_trackers" :   1,
             "auto_managed"         :   1,
             "banned_peers"         :   "",
             "banned_peers6"        :   "",
             "blocks per piece"     :   0,
             "completed_time"       :   0,
             "download_rate_limit"  :   0,
             "file sizes"           :   [[0, 0], [0, 0], [0, 0]],
             "file-format"          :   "libtorrent resume file",
             "file-version"         :   1,
             "file_priority"        :   [2, 0, 1],
             "finished_time"        :   0,
             "info-hash"            :   "",
             "last_download"        :   0,
             "last_scrape"          :   0,
             "last_seen_complete"   :   0,
             "last_upload"          :   0,
             "libtorrent-version"   :   "0.16.19.0",
             "mapped_files"         :   ["relative\\path\\to\\file1.ext", "r\\p\\t\\file2.ext", "file3.ext"],
             "max_connections"      :   100,
             "max_uploads"          :   16777215,
             "num_downloaders"      :   16777215,
             "num_incomplete"       :   0,
             "num_seeds"            :   0,
             "paused"               :   0,
             "peers"                :   "",
             "peers6"               :   "",
             "piece_priority"       :   "",
             "pieces"               :   "",
             "seed_mode"            :   0,
             "seeding_time"         :   0,
             "sequential_download"  :   0,
             "super_seeding"        :   0,
             "total_downloaded"     :   0,
             "total_uploaded"       :   0,
             "upload_rate_limit"    :   0,
             "trackers"             :   [["https://tracker"]]}


def mkfr(res, tor):
    """ Creates libtorrent fast resume file.

        @res uTorrent data.
        @tor Torrent File.
    """
    qbt_torrent = FIELD_MAP
    time_now = int(time())
    pieces_num = int(tor['info']['pieces'].size / 20) # SHA1 hash is 20 bytes
    qbt_torrent['added_time']               = int(res['added_on'])
    qbt_torrent['completed_time']           = int(res['completed_on'])
    qbt_torrent['active_time']              = int(res['runtime'])
    qbt_torrent['seeding_time']             = qbt_torrent['active_time']
    qbt_torrent['blocks per piece']         = int(int(tor['info']['piece length']) / int(res['blocksize']))
    qbt_torrent['info-hash']                = sha1(bencode(tor['info'])).digest()
    qbt_torrent['paused']                   = 1 if res['started'] == 0 else 0
    qbt_torrent['auto_managed']             = 0
    qbt_torrent['total_downloaded']         = int(res['downloaded'])
    qbt_torrent['total_uploaded']           = int(res['uploaded'])
    qbt_torrent['upload_rate_limit']        = int(res['upspeed'])
    qbt_torrent['trackers']                 = [[tracker] for tracker in res['trackers']]
    #wat?
    qbt_torrent['piece_priority']           = "".join(bin(hexik)[2:]*pieces_num for hexik in res["have"])
    #wat?
    qbt_torrent['pieces']                   = qbt_torrent['piece_priority']
    qbt_torrent['finished_time']            = time_now - qbt_torrent['completed_time']
    qbt_torrent['last_seen_complete']       = int(time_now) if qbt_torrent["finished_time"] else 0
    qbt_torrent['last_download']            = qbt_torrent['finished_time']
    qbt_torrent['last_scrape']              = qbt_torrent['finished_time']
    qbt_torrent['last_upload']              = qbt_torrent['finished_time']
    qbt_torrent['mapped_files']             = []
    qbt_torrent['file sizes']               = []
    # Per file fields:
    ##########
    # mapped_files
    # file_priority
    # file sizes
    #wat?
    get_hex = re_compile("[0-9A-Fa-f][0-9A-Fa-f]")
    qbt_torrent["file_priority"] = [(1 if int(hex_number, 16) in range(1, 9) else
                                     (2 if int(hex_number, 16) in range(9, 16) else
                                     (0))) for hex_number in get_hex.split(res["prio"])]

    fmt = 0
    if "files" in tor['info']:
        for file_index in range(len(tor['info']['files'])):
            tor_file = tor['info']['files'][file_index]
            qbt_torrent['mapped_files'].append(path.normpath(tor_file))

            if not "modtimes" in res:
                fmt = int(res['modtimes'][file_index])
            else:
                fmt = 0

            res_file = path.join(res['path'], qbt_torrent['mapped_files'][-1])
            if path.isfile(res_file) and not fmt:
                fmt = int(path.getmtime(res_file))

            if qbt_torrent['file_priority'][file_index]:
                qbt_torrent['file sizes'].append([int(tor_file['length']), fmt])
            else:
                qbt_torrent['file sizes'].append([0, 0])

        qbt_torrent['qBt-savePath'] = res['path']

    else:
        qbt_torrent['qBt-savePath'] = path.dirname(res['path'])

        if "modtimes" in res:
            fmt = int(res['modtimes'][0]) # file time to avoid checking / not presen in ut2.2
        else:
            fmt = 0

        res_file = res['path']
        if path.isfile(res_file) and not fmt:
            fmt = int(path.getmtime(res_file))

        if qbt_torrent['file_priority'][0]:
            qbt_torrent['file sizes'].append([int(tor['info']['length']), fmt])
        else:
            qbt_torrent['file sizes'].append([0, 0])
    ##########
    # qBittorrent 3.1+ Fields
    ##########
    if "label" in res:
        qbt_torrent['qBt-label']        = res['label']
    qbt_torrent['qBt-queuePosition']    = -1  # -1 for completed
    qbt_torrent['qBt-seedDate']         = qbt_torrent['completed_time']
    qbt_torrent['qBt-ratioLimit']       = "-2"  # -2 = Use Global, -1 = No limit, other number = actual ratio?
    return qbt_torrent

def punchup(res, tor, dotracker=True, doname=False):
    torrent = tor
    if dotracker:
        utrax = res['trackers']
        if len(utrax) > 1:
            if "announce-list" in torrent:
                if not set(torrent['announce-list']) == set(utrax):
                    torrent['announce-list'] = [[element] for element in set(utrax)]
            elif "announce" in torrent:
                if not torrent['announce'] == utrax[0]:
                    torrent['announce'] = utrax[0]
    if doname:
        res_path = res['path']
        if not "files" in torrent:
            torrent['info']['name'] = path.basename(res_path)
    return torrent

def convertor(ut_data: str, qbt_dir: str):
    """ Converts from uTorrent resume.dat to qBt

        @ut_data Path to uT resum.data
        @qbt_dir Path to store results
    """
    message = messagebox

    """
    backup_data = ".".join((ut_data, "old"))
    try:
        copy(ut_data, backup_data)
    except IOError:
        if message.askyesno("Backup error", "Cannot back-up UT data\nIs it ok?"):
            backup_data = ""
        else:
            return
    """

    with open(ut_data, 'rb') as ut_fd:
        data = ut_fd.read()

        try:
            torrents = bdecode(data)
        except DecodingError as error:
            message.showerror("Decoding error", "".join(("Cannot decode uTorrent data\n",
                                                         "Error: ", str(error))))
            return

    ut_folder = path.dirname(ut_data)

    print(torrents)
    for key, value in torrents.items():
        torrent_file = path.join(ut_folder, key)
        with open(torrent_file, 'rb') as ut_fd:
            try:
                bdecoded_data = bdecode(ut_fd.read())
            except BTFailure:
                continue
            tor_file = punchup(value, bdecoded_data)

            file_hash = sha1(bencode(tor_file["info"])).hexdigest().lower()

            #paths
            path_torrent_file = path.join(qbt_dir, ".".join((file_hash, "torrent")))
            path_fast_resume = path.join(qbt_dir, ".".join((file_hash, "fastresume")))

            if path.exists(path_torrent_file) or path.exists(path_fast_resume):
                continue

            fast_resume_file = mkfr(value, tor_file)

            with open(path_torrent_file, "wb") as tor_file:
                tor_file.write(bencode(tor_file))

            with open(path_fast_resume, "wb") as tor_file:
                tor_file.write(bencode(fast_resume_file))

class qbtConvertor(Tk):
    """ GUI Application for migration from uTorrent to qBittorrent """
    def __init__(self):
        Tk.__init__(self)
        self.title("uT to qBt convertor")

        #main frame
        self.main_frame = Frame(self, padding="3 3 12 12")
        self.main_frame.grid(column=0, row=0, sticky=(N, W, E, S))
        self.main_frame.columnconfigure(0, weight=1)
        self.main_frame.rowconfigure(0, weight=1)

        #uT part
        self.ut_data = StringVar()
        self.ut_label = Label(self.main_frame, text="uT data")
        self.ut_label.grid(column=0, row=1, sticky=(W))
        self.ut_entry = Entry(self.main_frame, width=100, textvariable=self.ut_data)
        self.ut_entry.grid(column=1, row=1, sticky=(W))
        self.ut_button = Button(self.main_frame, text="Browse", command=self.load_file)
        self.ut_button.grid(column=2, row=1)

        #qBt part
        self.qbt_folder = StringVar()
        self.qbt_label = Label(self.main_frame, text="qBt folder")
        self.qbt_label.grid(column=0, row=4, sticky=(W))
        self.qbt_entry = Entry(self.main_frame, width=100, textvariable=self.qbt_folder)
        self.qbt_entry.grid(column=1, row=4, sticky=(W))
        self.qbt_button = Button(self.main_frame, text="Browse", command=self.open_dir)
        self.qbt_button.grid(column=2, row=4, sticky=(W, E))


        #convertor
        self.convertor_button = Button(self.main_frame, text="Convert", command=self.convert,
                                       width=50)
        self.convertor_button.grid(column=1, columnspan=2, row=5)

        self.progress_bar = Progressbar(self.main_frame, orient=HORIZONTAL, length=300, mode="indeterminate")
        self.progress_bar.grid(column=1, columnspan=3, row=6)

        #set padding for each element
        for child in self.main_frame.winfo_children():
            child.grid_configure(padx=5, pady=5)

    def convert(self):
        message = messagebox
        if not self.qbt_folder.get() or not self.ut_data.get():
            message.showerror("ERROR", "Specify paths!")
            return
        self.progress_bar.start()
        convertor(self.ut_data.get(), self.qbt_folder.get())
        self.progress_bar.stop()

    def load_file(self):
        file_name = filedialog.askopenfilename(filetypes=(("UT resume file", "*.dat"),
                                                          ("All", "*")))
        if file_name:
            self.ut_data.set(file_name)

    def open_dir(self):
        dir_name = filedialog.askdirectory()

        if dir_name:
            self.qbt_folder.set(dir_name)

if __name__ == "__main__":
    app = qbtConvertor()
    app.geometry("800x160")
    app.mainloop()
