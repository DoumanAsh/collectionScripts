#! python3
from windows import GetWindowText, FindWindowByEnum, GetWindowThreadProcessId, RealGetWindowClass, OpenProcess, CloseHandle, ReadProcessMemory, WriteProcessMemory
import ctypes

def games():
    yield ("神採りアルケミーマイスター",          "ARCGameEngine", 0x00411BD3, "3D 60 EA 00 00 EB 70 E8 89 67 14 00", "3d 60 EA 00 00 7E 70 E8 89 67 14 00")
    yield ("創刻のアテリアル",                   "ARCGameEngine", 0x00412003, "3D 60 EA 00 00 EB 70 E8 66 39 17 00", "3D 60 EA 00 00 7E 70 E8 66 39 17 00")
    yield ("魔導巧殻 ～闇の月女神は導国で詠う～",  "ARCGameEngine", 0x00412153, "3D 60 EA 00 00 EB 70 E8 86 1D 1E 00", "3D 60 EA 00 00 7E 70 E8 86 1D 1E 00")
    yield ("戦女神ZERO",                        "ARCGameEngine", 0x0040B54A, "3D 60 EA 00 00 EB 64 E8 08 17 12 00", "3D 60 EA 00 00 7E 64 E8 08 17 12 00")
    yield ("戦女神VERITA",                      "ARCGameEngine", 0x0041219A, "3D 60 EA 00 00 EB 64 E8 55 07 14 00", "3D 60 EA 00 00 7E 64 E8 55 07 14 00")
    yield ("姫狩りダンジョンマイスター",          "ARCGameEngine", 0x004119CA, "3D 60 EA 00 00 EB 64 E8 0E F6 13 00", "3D 60 EA 00 00 7E 64 E8 0E F6 13 00")
    yield ("天秤のLa DEA。 ～戦女神MEMORIA～",          "ARCGameEngine", 0x004125C3, "3D 60 EA 00 00 EB 70 E8 A6 26 1E 00", "3D 60 EA 00 00 7E 70 E8 A6 26 1E 00")
    yield ("神のラプソディ",          "ARCGameEngine", 0x00411D83, "3D 60 EA 00 00 EB 70 E8 36 2B 1E 00", "3D 60 EA 00 00 7E 70 E8 36 2B 1E 00")
    yield ("珊海王の円環",          "ARCGameEngine", 0x00412203, "3D 60 EA 00 00 EB 70 E8 D6 44 1E 00", "3D 60 EA 00 00 7E 70 E8 D6 44 1E 00")

def main():
    for i in FindWindowByEnum(lambda x:RealGetWindowClass(x) =="ARCGameEngine"):
        print("Detected game:", GetWindowText(i))
    str2hex = lambda x:" ".join(['%02x'%i for i in x])
    gameDetect = lambda x:GetWindowText(x) == game[0] and RealGetWindowClass(x) == game[1]
    for game in games():
        lst = FindWindowByEnum(gameDetect)
        if not lst:
            continue
        print(game[0])
        assert len(lst)==1, lst
        orig = bytes.fromhex(game[4])
        pathed = bytes.fromhex(game[3])
        assert len(pathed)==len(orig)
        pid, pthread = GetWindowThreadProcessId(lst[0])
        hp = OpenProcess(0x0038,False,pid)
        if hp:
            buf = ctypes.create_string_buffer(len(orig))
            rsize = ctypes.c_size_t()
            assert ReadProcessMemory(hp, game[2], buf, len(orig), rsize),ctypes.FormatError()
            data = bytes(buf)
            if data == pathed:
                print('Already patched')
            elif data == orig:
                print('Apply patch...')
                buf = ctypes.create_string_buffer(pathed)
                if not WriteProcessMemory(hp,game[2],buf,len(orig),rsize):
                    print('Error: ',ctypes.FormatError())
                else:
                    buf = ctypes.create_string_buffer(len(orig))
                    rsize = ctypes.c_size_t()
                    assert ReadProcessMemory(hp, game[2], buf, len(orig), rsize),ctypes.FormatError()
                    assert bytes(buf) == pathed, str2hex(data)
            else:
                print('Unknown state:',str2hex(data), len(data))
            CloseHandle(hp)
        else:
            print('Failed to open process:',ctypes.FormatError())

if __name__ == "__main__":
    main()
