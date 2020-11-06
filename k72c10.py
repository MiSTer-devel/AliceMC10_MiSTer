#!/usr/bin/python3.6

import sys, os
from os.path import basename

def convert(argv):

    print (argv)

    if len(argv) == 0:
        sys.exit(2)

    for file in argv:
        file_name,_ = os.path.splitext(file)
        new_file=file_name+'.c10';

        print(f"{file_name} is being process.")                
     
        with open(new_file, 'wb') as c10:

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
        print(f"{new_file} is generated\n")

if __name__ == '__main__':
    """
        Input : 
        the input can contain one or more parameter separated by space, these parameters can be 
            - the name of a file
           

        Output : 
            - filename with .c10 extension
    """
    convert(sys.argv[1:])



