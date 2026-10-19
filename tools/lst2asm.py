"""Recover AS02 source from an AS02 listing. Usage: lst2asm.py in.lst out.asm"""
import sys

lines = open(sys.argv[1], errors='replace').read().splitlines()
start = next(i for i, l in enumerate(lines) if 'no errors in pass 1' in l) + 1
end = next(i for i, l in enumerate(lines) if 'errors in pass 2' in l)
with open(sys.argv[2], 'w') as f:
    for l in lines[start:end]:
        f.write(l[24:].rstrip() + '\n')
