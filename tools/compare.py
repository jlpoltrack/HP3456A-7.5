"""Lockstep semantic comparison of original vs restructured 6800 ROM.

Follows unconditional bra/jmp transparently, handles inverted conditional branches,
and pairs code addresses discovered along the way. Reports first divergence per path.
"""
import re
import sys
from m6800 import decode, fmt

INV = {'bne': 'beq', 'beq': 'bne', 'bcc': 'bcs', 'bcs': 'bcc', 'bhi': 'bls', 'bls': 'bhi',
       'bpl': 'bmi', 'bmi': 'bpl', 'bge': 'blt', 'blt': 'bge', 'bgt': 'ble', 'ble': 'bgt',
       'bvc': 'bvs', 'bvs': 'bvc'}

orig = open(sys.argv[1], 'rb').read()
new = open(sys.argv[2], 'rb').read()
lst = open(sys.argv[3], errors='replace').read().splitlines()

# label -> new address, and new address -> listing line index
labels, linemap = {}, {}
for i, l in enumerate(lst):
    m = re.match(r'^([0-9a-f]{4}) :\s+(?:[0-9a-f]+\s+)?(\S.*)?$', l)
    if m:
        linemap.setdefault(int(m.group(1), 16), i)
    m = re.match(r'^([0-9a-f]{4}) :\s+([A-Za-z_]\w*):', l)
    if m:
        labels[m.group(2)] = int(m.group(1), 16)

def follow(mem, a):
    seen = set()
    while a not in seen:
        seen.add(a)
        ins = decode(mem, a)
        if ins[0] == 'bra' or (ins[0] == 'jmp' and ins[1] == 'ext'):
            a = ins[2]
        else:
            return a, ins
    return a, ins

def is_rom(v):
    return v is not None and 0xA000 <= v <= 0xFFFF

pairs, work, diffs, data_pairs = set(), [], [], set()
def queue(o, n, why):
    if (o, n) not in pairs:
        pairs.add((o, n))
        work.append((o, n, why))

for vec in (0xFFF8, 0xFFFC, 0xFFFE, 0xFFF6, 0xFFF0):
    o = (orig[vec - 0x8000] << 8) | orig[vec - 0x7FFF]
    n = (new[vec - 0x8000] << 8) | new[vec - 0x7FFF]
    queue(o, n, f'vector {vec:04X}')
# jump-table entries: constant block is at the same address in both ROMs
for i, l in enumerate(lst):
    m = re.match(r'^([0-9a-f]{4}) : ([0-9a-f]{4})\s+dw\s+(\w+)', l)
    if m and 0xF65B <= int(m.group(1), 16) <= 0xFA38:
        a = int(m.group(1), 16) - 0x8000
        queue((orig[a] << 8) | orig[a + 1], int(m.group(2), 16), 'table ' + m.group(3))
for name, n in labels.items():
    m = re.fullmatch(r'L([0-9A-F]{4})', name)
    if m and int(m.group(1), 16) >= 0xA000:
        queue(int(m.group(1), 16), n, 'label ' + name)

def loose_eq(a, b):
    if a[0] != b[0] or a[1] != b[1]:
        return False
    return a[2] == b[2] or a[1] == 'rel' or (is_rom(a[2]) and is_rom(b[2]))

def advance(mem, a, k):
    for _ in range(k):
        a += decode(mem, a)[3]
    return a

def resync(o, n, k=4):
    # find smallest skip (orig i, new j) after which k instructions line up again
    for total in range(1, 48):
        for i in range(0, min(total, 12) + 1):
            oa, na = advance(orig, o, i), advance(new, n, total - i)
            if all(loose_eq(decode(orig, advance(orig, oa, t)), decode(new, advance(new, na, t)))
                   for t in range(k)):
                return oa, na
    return None

omap = {}  # orig addr -> set of new addrs it was paired with
while work:
    o, n, why = work.pop()
    steps = 0
    while steps < 5000:
        steps += 1
        o, oi = follow(orig, o)
        n, ni = follow(new, n)
        omap.setdefault(o, set()).add(n)
        on, om, ov, ol = oi
        nn, nm, nv, nl = ni
        if on == 'bsr': on, om = 'jsr', 'ext'
        if nn == 'bsr': nn, nm = 'jsr', 'ext'
        def bad(msg):
            diffs.append((o, n, why, msg, fmt(oi), fmt(ni)))
            r = resync(o, n)
            if r:
                queue(r[0], r[1], f'resync after {o:04X}/{n:04X}')
        if on == nn and om == nm == 'rel':
            queue(ov, nv, f'branch from {o:04X}')
            o += ol; n += nl
            continue
        if om == nm == 'rel' and INV.get(on) == nn:
            queue(ov, n + nl, f'inv branch from {o:04X}')
            o += ol; n = nv
            continue
        if on != nn or om != nm:
            bad('opcode'); break
        if om in ('ext', 'imm16') and (is_rom(ov) or is_rom(nv)):
            if on == 'jsr':
                queue(ov, nv, f'jsr from {o:04X}')
            else:
                data_pairs.add((ov, nv, o))
        elif ov != nv:
            bad('operand'); break
        if on in ('rts', 'rti') or (on == 'jmp' and om == 'idx'):
            break
        o += ol; n += nl

def ctx(n):
    i = linemap.get(n)
    return lst[i] if i is not None else '?'

print(f'paired paths: {len(pairs)}  divergences: {len(diffs)}')
for o, n, why, msg, a, b in sorted(set(diffs)):
    print(f'{msg:8} orig {o:04X}: {a:16} new {n:04X}: {b:16} [{why}]  | {ctx(n).strip()[:90]}')
print('\n# orig addrs paired with >1 new addr (duplicated code, informational):',
      sum(1 for v in omap.values() if len(v) > 1))
print('\n# data pointer pairs (orig, new, at):')
for ov, nv, at in sorted(data_pairs):
    print(f'  {ov:04X} -> {nv:04X}  @{at:04X}')
