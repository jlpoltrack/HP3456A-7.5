"""Minimal 6800 assembler compatible with the AS02 subset used by the 3456A source.

Mimics AS02 branch relaxation: jsr/jmp to an already-defined in-range target become
bsr/bra; bsr/bra to an already-defined out-of-range target become jsr/jmp.
Usage: as02.py src.asm out.bin [out.lst]   (binary covers $8000-$FFFF)
"""
import re
import sys
from m6800 import OPS

# mnemonic -> {mode: opcode}
TABLE = {}
for op, (n, mode) in OPS.items():
    TABLE.setdefault(n, {})[mode] = op
ALIAS = {'lsla': 'asla', 'lslb': 'aslb', 'lsl': 'asl'}


class AsmError(Exception):
    pass


def parse_line(line):
    code = re.sub(r';.*', '', line).rstrip()
    label = None
    m = re.match(r'^([A-Za-z_]\w*):?', code)
    if m and not code[0].isspace():
        label = m.group(1)
        code = code[m.end():]
    parts = code.split(None, 1)
    if not parts:
        return label, None, None
    return label, parts[0].lower(), parts[1].strip() if len(parts) > 1 else ''


def assemble(src):
    lines = src.splitlines()
    syms, known = {}, set()
    sizes = {}

    def value(tok, strict):
        tok = tok.strip()
        if tok.startswith('$'):
            return int(tok[1:], 16)
        if tok.startswith('%'):
            return int(tok[1:], 2)
        if re.fullmatch(r'\d+', tok):
            return int(tok)
        if tok in syms:
            return syms[tok]
        if strict:
            raise AsmError(f'undefined symbol {tok}')
        return None

    def encode(mn, arg, pc, pass_no, ln):
        """Return bytes for one instruction (pass 1 may return placeholders)."""
        mn = ALIAS.get(mn, mn)
        strict = pass_no == 2
        if mn not in TABLE:
            raise AsmError(f'unknown mnemonic {mn}')
        modes = TABLE[mn]
        if not arg:
            return bytes([modes['inh']])
        if arg.startswith('#'):
            v = value(arg[1:], strict) or 0
            if 'imm16' in modes:
                return bytes([modes['imm16'], v >> 8 & 0xFF, v & 0xFF])
            return bytes([modes['imm'], v & 0xFF])
        m = re.fullmatch(r'(.*),\s*[xX]', arg)
        if m:
            v = value(m.group(1), strict) if m.group(1).strip() else 0
            return bytes([modes['idx'], (v or 0) & 0xFF])
        v = value(arg, strict)
        if mn in ('jsr', 'jmp', 'bsr', 'bra'):
            short, long_ = {'jsr': ('bsr', 'jsr'), 'bsr': ('bsr', 'jsr'),
                            'jmp': ('bra', 'jmp'), 'bra': ('bra', 'jmp')}[mn]
            if pass_no == 1:
                # size fixed in pass 1 from backward references only, as AS02 does
                in_range = arg in known and -128 <= syms[arg] - (pc + 2) <= 127
                use_short = in_range if arg in known else mn in ('bsr', 'bra')
                sizes[ln] = 2 if use_short else 3
            if sizes[ln] == 2:
                d = (v or 0) - (pc + 2)
                if strict and not -128 <= d <= 127:
                    raise AsmError(f'branch out of range to {arg}')
                return bytes([TABLE[short]['rel'], d & 0xFF])
            return bytes([TABLE[long_]['ext'], (v or 0) >> 8 & 0xFF, (v or 0) & 0xFF])
        if 'rel' in modes:
            d = (v or pc + 2) - (pc + 2)
            if strict and not -128 <= d <= 127:
                raise AsmError(f'branch out of range to {arg}')
            return bytes([modes['rel'], d & 0xFF])
        if v is not None and v < 0x100 and 'dir' in modes and (pass_no == 2 or arg in known or arg[0] == '$'):
            if pass_no == 1:
                sizes[ln] = 2
            if sizes.get(ln, 2) == 2:
                return bytes([modes['dir'], v])
        if pass_no == 1:
            sizes[ln] = 3
        v = v or 0
        return bytes([modes['ext'], v >> 8 & 0xFF, v & 0xFF])

    for pass_no in (1, 2):
        pc, out, listing = 0, {}, []
        for ln, line in enumerate(lines, 1):
            prefix = ' ' * 24
            try:
                label, mn, arg = parse_line(line)
                if mn == 'equ':
                    syms[label] = value(arg, True)
                    known.add(label)
                    listing.append(f'{syms[label]:04x} = '.ljust(24) + line)
                    continue
                if label:
                    if pass_no == 1 and label in syms:
                        raise AsmError(f'duplicate label {label}')
                    syms[label] = pc
                    known.add(label)
                if mn is None or mn in ('code', 'data', 'end'):
                    listing.append((f'{pc:04x} : '.ljust(24) if label else prefix) + line)
                    continue
                if mn == 'org':
                    pc = value(arg, True)
                    listing.append(f'{pc:04x} = '.ljust(24) + line)
                    continue
                if mn == 'rmb':
                    n = value(arg, True)
                    for i in range(n):
                        out[pc + i] = 0
                    listing.append(f'{pc:04x} : '.ljust(24) + line)
                    pc += n
                    continue
                if mn in ('db', 'fcb'):
                    data = bytes(value(t, pass_no == 2) or 0 for t in arg.split(','))
                elif mn in ('dw', 'fdb'):
                    data = b''.join(((value(t, pass_no == 2) or 0) & 0xFFFF).to_bytes(2, 'big')
                                    for t in arg.split(','))
                else:
                    data = encode(mn, arg, pc, pass_no, ln)
                for i, b in enumerate(data):
                    out[pc + i] = b
                listing.append(f'{pc:04x} : {data[:8].hex()}'.ljust(24) + line)
                pc += len(data)
            except AsmError as e:
                raise AsmError(f'line {ln}: {e}: {line.strip()}')
        known = set()  # pass 2 relies on sizes fixed in pass 1
    rom = bytearray(0x8000)  # AS02 zero-fills gaps
    for a, b in out.items():
        if 0x8000 <= a <= 0xFFFF:
            rom[a - 0x8000] = b
    return rom, syms, listing


if __name__ == '__main__':
    try:
        rom, _, listing = assemble(open(sys.argv[1]).read())
    except AsmError as e:
        sys.exit(str(e))
    open(sys.argv[2], 'wb').write(rom)
    if len(sys.argv) > 3:
        open(sys.argv[3], 'w').write('no errors in pass 1\n' + '\n'.join(listing)
                                     + '\nNo errors in pass 2.\n')
