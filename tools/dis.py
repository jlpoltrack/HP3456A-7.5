import sys
from m6800 import decode, fmt
mem = open(sys.argv[1], 'rb').read()
a, end = int(sys.argv[2], 16), int(sys.argv[3], 16)
while a < end:
    ins = decode(mem, a)
    print(f'{a:04X}: {mem[a-0x8000:a-0x8000+ins[3]].hex():8} {fmt(ins)}')
    a += ins[3]
