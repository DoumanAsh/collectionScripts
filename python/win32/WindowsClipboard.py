from ctypes import *

kernel32 = windll.kernel32
user32 = windll.user32

OpenClipboard = user32.OpenClipboard
EmptyClipboard = user32.EmptyClipboard
GetClipboardData = user32.GetClipboardData
GetClipboardFormatName = user32.GetClipboardFormatNameW
SetClipboardData = user32.SetClipboardData
EnumClipboardFormats = user32.EnumClipboardFormats
CloseClipboard = user32.CloseClipboard

OpenClipboard.argtypes=[c_int]
EnumClipboardFormats.argtypes=[c_int]
CloseClipboard.argtypes=[]
GetClipboardFormatName.argtypes=[c_uint,c_wchar_p,c_int]
GetClipboardData.argtypes=[c_int]
SetClipboardData.argtypes=[c_int,c_int]

GlobalLock = kernel32.GlobalLock
GlobalAlloc = kernel32.GlobalAlloc
GlobalUnlock = kernel32.GlobalUnlock
GlobalSize = kernel32.GlobalSize

GlobalAlloc.argtypes=[c_int,c_int]
GlobalLock.argtypes=[c_void_p]
GlobalUnlock.argtypes=[c_int]
GlobalSize.argtypes=[c_int]

memcpy = cdll.msvcrt.memcpy
memcpy.argtypes=[c_void_p,c_void_p,c_int]

GHND = 66

class WindowsClipboard:
    @classmethod
    def formats(cls):
        OpenClipboard(0)
        res = []
        q=EnumClipboardFormats(0)
        while q:
            res.append(q)
            q=EnumClipboardFormats(q)
        CloseClipboard()
        return res

    @classmethod
    def formatname(cls, format):
        raise NotImplementedError()
        buffer = create_unicode_buffer(" "*100)
        bufferSize = sizeof(buffer)
        if OpenClipboard(0):
            GetClipboardFormatName(format,buffer,bufferSize)
            CloseClipboard()
        else:
            raise ValueError()
        return buffer.value

    @classmethod
    def get(cls, format):
        res = None
        if OpenClipboard(0):
            hClipMem = GetClipboardData(format)
            if hClipMem:
                size = GlobalSize(hClipMem)
                res = string_at(GlobalLock(hClipMem),size)
                GlobalUnlock(hClipMem)
            CloseClipboard()
        return res

    @classmethod
    def getall(cls):
        return {i:cls.get(i) for i in cls.formats()}

    @classmethod
    def gettext(cls, format, encoding):
        return cls.get(format).decode(encoding)[:-1]

    @classmethod
    def getunicode(cls, format=13):
        return cls.get(format).decode('UTF-16')[:-1]
