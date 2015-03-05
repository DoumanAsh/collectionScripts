""" Win 32 API for interaction with clipboard """

from ctypes import *
kernel32 = windll.kernel32
user32 = windll.user32

def SetConsoleTitle(string):
    if isinstance(string, bytes):
        return kernel32.SetConsoleTitleA(create_string_buffer(string))
    elif isinstance(string, str):
        return kernel32.SetConsoleTitleW(create_unicode_buffer(string))
    else:
        raise Exception()

OpenClipboard = user32.OpenClipboard
EmptyClipboard = user32.EmptyClipboard
GetClipboardData = user32.GetClipboardData
GetClipboardFormatName = user32.GetClipboardFormatNameW
SetClipboardData = user32.SetClipboardData
EnumClipboardFormats = user32.EnumClipboardFormats
CloseClipboard = user32.CloseClipboard

OpenClipboard.argtypes = [c_int]
EnumClipboardFormats.argtypes = [c_int]
CloseClipboard.argtypes = []
GetClipboardFormatName.argtypes = [c_uint, c_wchar_p, c_int]
GetClipboardData.argtypes = [c_int]
SetClipboardData.argtypes = [c_int, c_int]

GlobalLock = kernel32.GlobalLock
GlobalAlloc = kernel32.GlobalAlloc
GlobalUnlock = kernel32.GlobalUnlock
GlobalAlloc.argtypes = [c_int, c_int]
GlobalLock.argtypes = [c_int]
GlobalUnlock.argtypes = [c_int]
memcpy = cdll.msvcrt.memcpy
memcpy.argtypes = [c_void_p, c_void_p, c_int]

GHND = 66

def Clipboard_enum():
    OpenClipboard(0)
    res = []
    q = EnumClipboardFormats(0)
    while q:
        res.append(q)
        q = EnumClipboardFormats(q)
    CloseClipboard()
    return res

def Clipboard_getformatname(format):
    buf = create_unicode_buf(" "*100)
    bufferSize = sizeof(buf)
    OpenClipboard(0)
    GetClipboardFormatName(format, buf, bufferSize)
    CloseClipboard()
    return buf.value

def Clipboard_GetUnicode(Format=13):
    res = ''
    if OpenClipboard(0):
        hClipMem = GetClipboardData(Format)
        if hClipMem:
            GlobalLock.restype = c_wchar_p
            res = GlobalLock(hClipMem)
            GlobalUnlock(hClipMem)
        CloseClipboard()
    return res

def Clipboard_GetData(Format, size=-1):
    res = b''
    if OpenClipboard(0):
        hClipMem = GetClipboardData(Format)
        if hClipMem:
            GlobalLock.restype = c_void_p
            res = string_at(GlobalLock(hClipMem), size=size)
            GlobalUnlock(hClipMem)
        CloseClipboard()
    return res

def Clipboard_SetDataUnicode(Format, buf, size=None):
    if isinstance(buf, str):
        if buf:
            if size:
                size = min(size, len(buf))
            else:
                size = len(buf)
            size = 2*size+2
            hGlobalMem = GlobalAlloc(GHND, size)
            if hGlobalMem:
                GlobalLock.restype = c_void_p
                lock = GlobalLock(hGlobalMem)
                memcpy.argtypes = [c_void_p, c_wchar_p, c_int]
                memcpy(lock, buf, size)
                GlobalUnlock(hGlobalMem)
                if OpenClipboard(0):
                    EmptyClipboard()
                    SetClipboardData(Format, hGlobalMem)
                    CloseClipboard()
    else:
        raise TypeError(type(buf))

def Clipboard_SetData(Format, buf, size=None):
    if type(buf) in {bytes, bytearray}:
        if buf:
            if size:
                size = min(size, len(buf))
            else:
                size = len(buf) + 1
            hGlobalMem = GlobalAlloc(GHND, size)
            if hGlobalMem:
                GlobalLock.restype = c_void_p
                lock = GlobalLock(hGlobalMem)
                memcpy.argtypes = [c_void_p, c_char_p, c_int]
                memcpy(lock, buf, size)
                GlobalUnlock(hGlobalMem)
                if OpenClipboard(0):
                    EmptyClipboard()
                    SetClipboardData(Format, hGlobalMem)
                    CloseClipboard()
    else:
        raise TypeError(type(buf))

def Clipboard_SetText(buf):
    if isinstance(buf, str):
        if buf:
            size = len(buf)
            if OpenClipboard(0):
                EmptyClipboard()
                try:
                    encoded = buf.encode('cp1251')
                    hGlobalMem = GlobalAlloc(GHND, size+1)
                    assert hGlobalMem
                    GlobalLock.restype = c_void_p
                    lock = GlobalLock(hGlobalMem)
                    memcpy.argtypes = [c_void_p, c_char_p, c_int]
                    memcpy(lock, encoded, size)
                    GlobalUnlock(hGlobalMem)
                    SetClipboardData(1, hGlobalMem)
                except UnicodeEncodeError:
                    pass

                hGlobalMem = GlobalAlloc(GHND, 2*size+2)
                assert hGlobalMem
                GlobalLock.restype = c_void_p
                lock = GlobalLock(hGlobalMem)
                memcpy.argtypes = [c_void_p, c_wchar_p, c_int]
                memcpy(lock, buf, 2*size+2)
                GlobalUnlock(hGlobalMem)
                SetClipboardData(13, hGlobalMem)
                CloseClipboard()
    else:
        raise TypeError(type(buf))
