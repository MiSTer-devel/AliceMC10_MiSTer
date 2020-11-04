#!/usr/bin/python3.6

import sys

def main(argv):

    if len(argv) != 1:
        sys.exit(2)

    with open('k7.c10', 'wb') as c10:

        leader = bytearray([0x55] * 128)
        ba = bytearray()
        
        with open(argv[0], 'rb') as k7:
            ba.extend(leader)
            k7.seek(8)
            ba.extend(k7.read(3))
            length = k7.read(1)
            ba.extend(length)
            ba.extend(k7.read(length[0]+1))
            ba.extend(leader)
            ba.extend(k7.read())

        c10.write(ba)
        c10.close()

if __name__ == '__main__':
    main(sys.argv[1:])


