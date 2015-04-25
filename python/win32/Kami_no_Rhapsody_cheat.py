#!python3
#Regards to asidonus

from windows import GetWindowText, FindWindowByEnum, GetWindowThreadProcessId, RealGetWindowClass, OpenProcess, CloseHandle, ReadProcessMemory, WriteProcessMemory
import ctypes
import struct
import time
import array
from sys import argv

game =  ("神のラプソディ",          "ARCGameEngine")

str2hex = lambda x:' '.join([('%02x'%i) for i in x])
intlist2hex = lambda lst:'; '.join(map(lambda x:'%08x'%x, lst))
sar = lambda x,y:(x>>y)|(x&((2<<(y-1))-1))<<(32-y)
sal = lambda x,y:sar(x, 32-y)
def fixsign(x):
    if x & 0x80000000:
        return x-0x100000000
    return x

inv = lambda x:((x&0xFF000000)>> 24) + \
      ((x&0x00FF0000)>> 8) + \
      ((x&0x0000FF00)<< 8) + \
      ((x&0x000000FF)<< 24)

gameDetect = lambda x:GetWindowText(x) == game[0] and RealGetWindowClass(x) == game[1]

class GameMonitor(object):
    BASE = 0x400000  # 0x1170000
    def __init__(self, pid):
        self.pid = pid

        self.hp = OpenProcess(0x0038,False,self.pid)
        if not self.hp:
            raise ctypes.WinError()

    def readMemory(self, pos, size):
        buf = ctypes.create_string_buffer(size)
        rsize = ctypes.c_size_t()
        assert ReadProcessMemory(self.hp, pos,buf,size,rsize),ctypes.FormatError()
        data = bytes(buf)
        return data

    def writeMemory(self, pos, value):
        buf = ctypes.create_string_buffer(bytes(value))
        rsize = ctypes.c_size_t()
        assert WriteProcessMemory(self.hp,pos,buf,len(value),rsize), ctypes.FormatError()

    def readUInt32(self, pos):
        return struct.unpack('I',self.readMemory(pos,4))[0]

    def writeUInt32(self, pos, value):
        self.writeMemory(pos, struct.pack('I',value))

    def decode(self, x):
        return fixsign(sar(sal(x, 11) ^ self.salt,25))
    def encode(self, x):
        return sar(sal(x, 25) ^ self.salt,11)

    def postInit(self):
        self.base = self.BASE + 0x00670990 - 0x400000
        self.base_size = 0xAAA50
        self.base_p = self.readUInt32(self.base)

        self.types = [(self.readUInt32(self.base_p+0x0005D6F0+i*4+8),
                       self.readUInt32(self.base_p+0x0005D708+i*8+8),
                       self.readUInt32(self.base_p+0x0005D70C+i*8+8)) for i in range(6)]
        for q in self.types:
            if q[2] != 0:
                raise NotImplementedError()
        self.salt = self.readUInt32(self.base_p+0x0005EB94+8)
        self.integers = self.types[0][1]
        self.integers_c = self.types[0][0]
        print('Type3: %08x-%08x'%(self.integers,self.integers+4*self.integers_c))
        print(self.types[:])

    def findInt(self, value):
        r1 = self.readMemory(self.integers,4*self.integers_c)
        m1 = memoryview(r1).cast('I')
        step = self.integers_c // 100
        value = self.encode(value)
        for i in range(self.integers_c):
            if i%(step*5) == 0:
                print('%d%%'%(i/step))
            if m1[i] == value:
                print('%08x: %d'%(i*4, self.decode(m1[i])))

    def takeDump(self):
        r1 = self.readMemory(self.integers,4*self.integers_c)
        m1 = memoryview(r1).cast('I')
        return m1

    def diffInts(self, pairs=None, limit=None, delta=None):
        r1 = self.readMemory(self.integers,4*self.integers_c)
        print('Press enter...')
        input()
        r2 = self.readMemory(self.integers,4*self.integers_c)
        m1 = memoryview(r1).cast('I')
        m2 = memoryview(r2).cast('I')
        print('Compare...')
        step = self.integers_c // 100
        res = []
        for i in range(self.integers_c):
            if i%(step*5) == 0:
                print('%d%%'%(i/step))
            if limit and i > limit:
                break
            if m1[i] != m2[i]:
                v1 = self.decode(m1[i])
                v2 = self.decode(m2[i])
                s = '%08x: %d -> %d'%(i*4, v1, v2)
                if pairs:
                    if (v1, v2) in pairs or (v1, None) in pairs or (None, v2) in pairs:
                        res.append(s)
                if delta:
                    if v2-v1 == delta:
                        res.append(s)
                print(s)
        print('Done')
        if pairs:
            print("\n".join(res))


    def main(self, state):
        resourceHack = state.get('resourceHack', dict())
        #self.resourceHack(resourceHack)
        state['resourceHack'] = resourceHack

##        if self.getValue(0x00010a6c)>15:
##            self.update(0x00010a6c, 1, "Turn")

    @staticmethod
    def help():
        print("Options:")
        print("    > shield - sets C001 to 99")
        print("    > tokens - set all tokens of characters to 99")
        print("    > all - above options are included")
        print("    > find - look for address")
        print("    > hook - print ITH hooks")
        print("    > help - show this message")

    @staticmethod
    def unexpected(arg):
        print("".join((">>>", arg, " is not a valid option")))
        print("See help")

    @staticmethod
    def hook(_):
        print(">>>ITH Hooks:")
        print("HS18@70D30:AGE.EXE - dialogues")
        print("/HS8@54970:AGE.EXE - interface text")
    ##################################
    # Options
    ##################################
    def shield(self, _):
        #self.FindValue(7220)
        print("Shields")
        self.update(0x00289f10, 99)

    def tokens(self, _):
        #Erudo tokens
        print("Erbalard tokens:")
        self.update(0x002929f0, 99) #sword
        self.update(0x002929f4, 99) #blue question mark?
        self.update(0x002929f8, 99) #some green shit?
        self.update(0x002929fc, 99) #some yellow triangle?
        print("Lavirie tokens:")
        self.update(0x00292a00, 99) #sword
        self.update(0x00292a04, 99) #blue question mark?
        self.update(0x00292a08, 99) #some green shit?
        self.update(0x00292a0c, 99) #some yellow triangle?
        print("Mistoria tokens:")
        self.update(0x00292a10, 99) #sword
        self.update(0x00292a14, 99) #blue question mark?
        self.update(0x00292a18, 99) #some green shit?
        self.update(0x00292a1c, 99) #some yellow triangle?

    def all(self, _):
        self.shield(_)
        self.tokens(_)

    def find(self, _):
        print("Looking for address...")
        while True:
            value_to_look = input("Enter game variable to look:")
            if value_to_look.isdigit():
                value_to_look = int(value_to_look)
                break
            else:
                print("".join(">>>", value_to_look, " is not a valid digit"))

        first_set = self.find_set_addrs_by_value(value_to_look)
        print("Found addresses. Please change value in-game")

        while True:
            value_to_look = input("Enter a new value:")
            if value_to_look.isdigit():
                value_to_look = int(value_to_look)
                break
            else:
                print("".join(">>>", value_to_look, " is not a valid digit"))

        second_set = self.find_set_addrs_by_value(value_to_look)
        print("Found second set of addresses. Look for value's address...")

        diff_set = first_set & second_set

        print("Diff:")
        for value in diff_set:
            print(value)

    ##################################
    # Utils
    ##################################
    def find_set_addrs_by_value(self, val):
        ret = set()
        q = self.encode(val)
        r1 = self.readMemory(self.integers, 4*self.integers_c)
        m1 = memoryview(r1).cast('I')

        step = self.integers_c // 100
        for i in range(self.integers_c):
            if m1[i] == q:
                ret.add('%08x' % (i*4))

        return ret

    def FindValue(self, val):
        print('To search: %08x'%inv(self.encode(val)))
        q = self.encode(val)
        r1 = self.readMemory(self.integers, 4*self.integers_c)
        m1 = memoryview(r1).cast('I')

        step = self.integers_c // 100
        for i in range(self.integers_c):
            if i%(step*5) == 0:
                print('%d%%'%(i/step))
            if m1[i] == q:
                print('%08x: %d'%(i*4, val))


    def getValue(self, offset):
        if offset%4 != 0:
            raise ValueError(offset)
        if offset >= 4*self.integers_c:
            raise ValueError(offset)
        return self.decode(self.readUInt32(self.integers+offset))

    def update(self, offset, maxval, desc=''):
        v = self.getValue(offset)
        print(('%08x: %d -> %d'%(offset, v, maxval)).ljust(30)+desc)
        self.setValue(offset, maxval)

    def updateH(self, offset, maxval, desc='', minval=1):
        v = self.getValue(offset)
        if minval <= v < maxval:
            print(('%08x: %d -> %d'%(offset, v, maxval)).ljust(30)+desc)
            self.setValue(offset, maxval)

    def updateL(self, offset, minval, desc=''):
        v = self.getValue(offset)
        if minval < v:
            print(('%08x: %d -> %d'%(offset, v, minval)).ljust(30)+desc)
            self.setValue(offset, minval)

    def setValue(self,offset,value):
        if offset%4 != 0:
            raise ValueError(offset)
        if offset >= 4*self.integers_c:
            raise ValueError(offset)
        return self.writeUInt32(self.integers+offset, self.encode(value))

    def increase(self, pos, value):
        v = self.getValue(pos)
        assert v>=0
        if self.getValue(pos)<value:
            self.setValue(pos, value)

    def loop(self, once=False):
        self.counter = 0
        state = dict()
        while True:
            self.main(state)
            if once:
                break
            time.sleep(0.5)
            self.counter += 1


def main(args):
    lst = FindWindowByEnum(gameDetect)
    if lst:
        assert len(lst)==1
        print('Kami no Rhapsody')
        pid, pthread = GetWindowThreadProcessId(lst[0])
        a = GameMonitor(pid)
        a.postInit()
        if not args:
            a.help()
        else:
            for arg in args:
                getattr(a, arg, a.unexpected)(arg)

if __name__ == "__main__":
    main(argv[1:])
