"""Tile a ROM image to fill a larger chip, so any tied-off upper address lines work.
Usage: replicate.py in.bin out.bin size   (size e.g. 65536, 64K, 512K, 1M)"""
import sys

def parse_size(s):
    s = s.upper()
    mult = {'K': 1024, 'M': 1024 * 1024}.get(s[-1], 1)
    return int(s.rstrip('KM')) * mult

data = open(sys.argv[1], 'rb').read()
size = parse_size(sys.argv[3])
if size % len(data):
    sys.exit(f'{size} is not a multiple of the {len(data)}-byte image')
open(sys.argv[2], 'wb').write(data * (size // len(data)))
print(f'{len(data)} bytes x {size // len(data)} -> {sys.argv[2]}')
