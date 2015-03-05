""" Win32 API for interaction with windows """

import ctypes
from ctypes import wintypes, windll
from time import sleep

####################
# Constants
####################
HWND = wintypes.HWND #window handler
WPARAM = wintypes.WPARAM #message parameter
LPARAM = wintypes.LPARAM #message parameter
LRESULT = wintypes.DWORD #message result(signed type)
LPCWSTR = wintypes.LPCWSTR #null-terminated string of 16-bit Unicode characters.
UINT = wintypes.UINT
POINTER = ctypes.POINTER
INT = wintypes.INT
BOOL = wintypes.BOOL
WNDENUMPROC = ctypes.WINFUNCTYPE(BOOL, HWND, LPARAM)

SMTO_BLOCK = 0x0001
WM_SYSCOMMAND = 0x0112
WM_GETTEXT = 0x000D
WM_GETTEXTLENGTH = 0x000E
WM_SETTEXT = 0x000C
BM_CLICK = 0x00F5

SC_MINIMIZE = 0xF020

####################
# Win32 functions
####################
""" FindWindow

    @param lpClassName string with class name or null
    @param lpWindowName string with window's name or null

    @retval Window handler
"""
FindWindow = windll.user32.FindWindowW
FindWindow.restype = HWND
FindWindow.argtypes = [LPCWSTR, LPCWSTR]

""" FindWindowEx

    @param hwndParent handler of parent
           IF NULL then desktop window
    @param hwndChildAfter Handler of child.
           The search begins with the next child window in the Z order.
           The child window must be a direct child window of hwndParent, not just a descendant window.
           IF NULL then he search begins with the first child window of hwndParent
    @param lpszClass string with class name
    @param lpszWindow stwing with window name

    @retval Window handler
"""
FindWindowEx = windll.user32.FindWindowExW
FindWindowEx.restype = HWND
FindWindowEx.argtypes = [HWND, HWND, LPCWSTR, LPCWSTR]

__IsWindowVisible = windll.user32.IsWindowVisible
__IsWindowVisible.restype = BOOL
__IsWindowVisible.argtypes = [HWND]

def IsWindowVisible(hwnd):
    """ IsWindowVisible wrapper

        @param hWind window handler

        @retval True if window is visible(has WS_VISIBLE)
        @retval False otherwise
    """
    return bool(__IsWindowVisible(hwnd))

__RealGetWindowClass = windll.user32.RealGetWindowClassW
__RealGetWindowClass.restype = INT
__RealGetWindowClass.argtypes = [HWND, LPCWSTR, UINT]

def RealGetWindowClass(hwnd):
    buf_length = 200
    buf = ctypes.create_unicode_buffer(buf_length)
    buf_true_length = __RealGetWindowClass(hwnd, buf, buf_length)
    res = buf.value
    return res

__GetWindowText = windll.user32.GetWindowTextW
__GetWindowText.restype = INT
__GetWindowText.argtypes = [HWND, LPCWSTR, INT]

def GetWindowText(hwnd):
    buf_length = 2000
    buf = ctypes.create_unicode_buffer(buf_length)
    buf_true_length = __GetWindowText(hwnd, buf, buf_length)
    res = buf.value
    return res

SendMessage_ = windll.user32.SendMessageW
SendMessage_.restype = LRESULT
SendMessage_.argtypes = [HWND, UINT, WPARAM, LPARAM]

SendMessageTimeout_ = windll.user32.SendMessageTimeoutW
SendMessageTimeout_.restype = LRESULT
SendMessageTimeout_.argtypes = [HWND, UINT, WPARAM, LPARAM, UINT, UINT, wintypes.LPDWORD]

EnumChildWindows_ = windll.user32.EnumChildWindows
EnumChildWindows_.restype = BOOL
EnumChildWindows_.argtypes = [HWND, WNDENUMPROC, LPARAM]

EnumWindows_ = windll.user32.EnumWindows
EnumWindows_.restype = BOOL
EnumWindows_.argtypes = [WNDENUMPROC, LPARAM]

GetWindowThreadProcessId_ = windll.user32.GetWindowThreadProcessId
GetWindowThreadProcessId_.restype = wintypes.DWORD
GetWindowThreadProcessId_.argtypes = [HWND, wintypes.LPDWORD]

def GetWindowThreadProcessId(x):
    a2 = wintypes.DWORD()
    a1 = GetWindowThreadProcessId_(x, a2)
    return (a2.value, a1)

OpenProcess = windll.kernel32.OpenProcess
OpenProcess.restype = HWND
OpenProcess.argtypes = [wintypes.DWORD, BOOL, ctypes.wintypes.DWORD]

CloseHandle = windll.kernel32.CloseHandle
CloseHandle.restype = BOOL
CloseHandle.argtypes = [HWND]

ReadProcessMemory = windll.kernel32.ReadProcessMemory
ReadProcessMemory.restype = BOOL
ReadProcessMemory.argtypes = [HWND, wintypes.LPCVOID, ctypes.wintypes.LPVOID, ctypes.c_size_t, ctypes.c_size_t]

WriteProcessMemory = windll.kernel32.WriteProcessMemory
WriteProcessMemory.restype = BOOL
WriteProcessMemory.argtypes = [HWND, wintypes.LPCVOID, ctypes.wintypes.LPVOID, ctypes.c_size_t, ctypes.c_size_t]


####################
# Py functions
####################
class TimeoutError(Exception):
    pass

def SendMessage(hwnd, MessageCode, wParam, lParam, Timeout=1000):
    r = LRESULT()
    if Timeout == 0:
        r = SendMessage_(hwnd, MessageCode, wParam, lParam)
    else:
        if SendMessageTimeout_(hwnd, MessageCode, wParam, lParam, SMTO_BLOCK, Timeout, ctypes.byref(r)) == 0:
            raise TimeoutError()
    return r.value

def FindWindowByEnum(cmpfunc, parent=0):
    if not callable(cmpfunc):
        raise ValueError('cmpfunc must be callable')
    res = []
    def a1(x, y):
        if cmpfunc(x):
            res.append(x)
        return True
    q = WNDENUMPROC(a1)
    if parent:
        EnumChildWindows_(parent, q, 0)
    else:
        EnumWindows_(q, 0)
    return res

def WND_SetText(wnd, txt):
    buf = ctypes.create_unicode_buffer(txt)
    res = SendMessage(wnd, WM_SETTEXT, 0, ctypes.addressof(buf))
    return res


def WND_GetText(wnd):
    buf_len = SendMessage(wnd, WM_GETTEXTLENGTH, 0, 0)
    if buf_len > 0:
        buf = ctypes.create_unicode_buffer(buf_len)
        res = SendMessage(wnd, WM_GETTEXT, buf_len+1, ctypes.addressof(buf))
        if res != buf_len:
            print('WND_GetText: length error')
        return buf.value
    else:
        return ''

def PushButton(wnd, timeout=0):
    res = SendMessage(wnd, BM_CLICK, 0, 0, timeout)
    return res

def PushButtonIgnore(wnd, timeout=5000):
    try:
        return SendMessage(wnd, BM_CLICK, 0, 0, timeout)
    except TimeoutError:
        return None

def WaitWindowCreate(Class, Window, times=20, maxdelay=3, waitcallback=None):
    master = FindWindow(Class, Window)
    delay = 0.5
    while master is None:
        if waitcallback is not None:
            waitcallback(Class, Window, times)
        sleep(delay)
        master = FindWindow(Class, Window)
        if times > 0:
            times -= 1
            if delay < maxdelay:
                delay += 0.5
        else:
            raise ValueError('WaitWindowCreate failed')
    return master
