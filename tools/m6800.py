"""Minimal 6800 decoder: decode(mem, addr) -> (mnemonic, mode, operand, length)."""

OPS = {}

def _add(base, names, mode):
    for i, n in enumerate(names):
        if n:
            OPS[base + i] = (n, mode)

for op, n in {0x01: 'nop', 0x06: 'tap', 0x07: 'tpa', 0x08: 'inx', 0x09: 'dex', 0x0A: 'clv',
              0x0B: 'sev', 0x0C: 'clc', 0x0D: 'sec', 0x0E: 'cli', 0x0F: 'sei', 0x10: 'sba',
              0x11: 'cba', 0x16: 'tab', 0x17: 'tba', 0x19: 'daa', 0x1B: 'aba', 0x30: 'tsx',
              0x31: 'ins', 0x32: 'pula', 0x33: 'pulb', 0x34: 'des', 0x35: 'txs', 0x36: 'psha',
              0x37: 'pshb', 0x39: 'rts', 0x3B: 'rti', 0x3E: 'wai', 0x3F: 'swi'}.items():
    OPS[op] = (n, 'inh')

BR = ['bra', None, 'bhi', 'bls', 'bcc', 'bcs', 'bne', 'beq', 'bvc', 'bvs', 'bpl', 'bmi', 'bge', 'blt', 'bgt', 'ble']
_add(0x20, BR, 'rel')
OPS[0x8D] = ('bsr', 'rel')

RMW = ['neg', None, None, 'com', 'lsr', None, 'ror', 'asr', 'asl', 'rol', 'dec', None, 'inc', 'tst', 'jmp', 'clr']
_add(0x40, [r and r + 'a' for r in RMW[:14]] + [None, 'clra'], 'inh')
_add(0x50, [r and r + 'b' for r in RMW[:14]] + [None, 'clrb'], 'inh')
OPS[0x4E] = OPS[0x5E] = None
del OPS[0x4E], OPS[0x5E]
_add(0x60, RMW, 'idx')
_add(0x70, RMW, 'ext')

ACC = ['sub', 'cmp', 'sbc', None, 'and', 'bit', 'lda', 'sta', 'eor', 'adc', 'ora', 'add']
for base, reg in ((0x80, 'a'), (0xC0, 'b')):
    for off, mode in ((0, 'imm'), (0x10, 'dir'), (0x20, 'idx'), (0x30, 'ext')):
        for i, n in enumerate(ACC):
            if n and not (n == 'sta' and mode == 'imm'):
                OPS[base + off + i] = (n + reg, mode)
for off, mode in ((0, 'imm16'), (0x10, 'dir'), (0x20, 'idx'), (0x30, 'ext')):
    OPS[0x8C + off] = ('cpx', mode)
    OPS[0x8E + off] = ('lds', mode)
    OPS[0xCE + off] = ('ldx', mode)
    if mode != 'imm16':
        OPS[0x8F + off] = ('sts', mode)
        OPS[0xCF + off] = ('stx', mode)
OPS[0xAD] = ('jsr', 'idx')
OPS[0xBD] = ('jsr', 'ext')

LEN = {'inh': 1, 'rel': 2, 'imm': 2, 'dir': 2, 'idx': 2, 'ext': 3, 'imm16': 3}


def decode(mem, a):
    op = mem[a - 0x8000]
    if op not in OPS:
        return ('???', 'inh', op, 1)
    n, mode = OPS[op]
    ln = LEN[mode]
    if mode == 'rel':
        d = mem[a + 1 - 0x8000]
        val = (a + 2 + (d - 256 if d >= 128 else d)) & 0xFFFF
    elif ln == 2:
        val = mem[a + 1 - 0x8000]
    elif ln == 3:
        val = (mem[a + 1 - 0x8000] << 8) | mem[a + 2 - 0x8000]
    else:
        val = None
    return (n, mode, val, ln)


def fmt(ins):
    n, mode, v, _ = ins
    if mode == 'inh':
        return n
    return {'rel': f'{n} ${v:04X}', 'imm': f'{n} #${v:02X}', 'imm16': f'{n} #${v:04X}',
            'dir': f'{n} ${v:02X}', 'idx': f'{n} ${v:02X},x', 'ext': f'{n} ${v:04X}'}[mode]
