"""Patch u7modded.bin to fix restructuring bugs. Usage: patch.py in.bin out.bin"""
import sys

# (address, expected old bytes, new bytes, description)
PATCHES = [
    (0xA6EA, '7ec81d', '390101', 'sub012 uprange: return to caller (was jmp main loop) - AUTORANGE FREEZE'),
    (0xA6F5, '7ec81d', '390101', 'sub012 overrange no-uprange: return to caller (was jmp main loop)'),
    (0xD71D, 'b7013e', 'b70130', 'power-on preset R=600: byte1 into R1 (was Z1)'),
    (0xD722, 'b70143', 'b70135', 'power-on preset R=600: exponent into R6 (was Z6)'),
    (0xB696, 'b70150', 'b70151', 'preset U=+1.999999E9: exponent into U6 (was U5)'),
    (0xB85C, 'b6013e', 'b60130', 'dBm: test R register for zero (was Z)'),
    (0xF1BE, '7f013d', '7f012f', 'RECALL key: clear R0 (was Z0)'),
]

data = bytearray(open(sys.argv[1], 'rb').read())
for addr, old, new, desc in PATCHES:
    off = addr - 0x8000
    cur = data[off:off + len(old) // 2].hex()
    if cur != old:
        sys.exit(f'{addr:04X}: expected {old}, found {cur} ({desc})')
    data[off:off + len(new) // 2] = bytes.fromhex(new)
    print(f'{addr:04X}: {old} -> {new}  {desc}')
open(sys.argv[2], 'wb').write(data)
