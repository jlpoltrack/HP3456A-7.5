# HP 3456A 7.5-Digit Firmware, Fixed

A corrected build of the community 7.5-digit firmware for the HP 3456A digital voltmeter.

The 7.5-digit mod, shared in the EEVblog thread "Adventures in retrocomputing"
(`3456AFirmware.zip`), shows a 7th digit at 10 and 100 PLC. Its published ROM also has seven
bugs. They crept in when the disassembly was restructured, and the best known is an **autorange
freeze**. This build fixes all seven, keeps the 7.5-digit feature, and tightens when the 7th
digit appears.

**Status:** tested on a real meter on 2026-10-19. All front-panel tests pass; see
[`docs/HARDWARE_VALIDATION.md`](docs/HARDWARE_VALIDATION.md). HPIB output of the 7th digit
has not been tested on hardware yet.

## What you get

- **7th digit** at 10 and 100 PLC, in the display's exponent position.
- **Autorange that works:** the meter ranges up and down without freezing.
- **Factory behaviour restored** for error 4 on bad digit counts, the dBm reference, NULL, the
  R and U presets, and storing the delay register D.

## Using 7-digit mode

Set 10 or 100 PLC, then enter `7` for digits displayed. The 7th digit is hidden, and the meter
behaves as a stock 6.5-digit unit, when:

- PLC is 1 or lower (the extra digit would only be noise);
- a number is being entered on the keypad or over HPIB.

### Reading the display

The 7th digit replaces the exponent, and the exponent sign is blank. Read the six mantissa digits
and append the 7th.

- **One decimal point lit:** no exponent is hidden, so read the value as shown.
- **Every decimal point lit except one:** the 7th digit is hiding an exponent. The digit with
  the **dark** decimal point is the true decimal position. The exponent is whatever the same
  range shows at 1 PLC, so check it once for each range you use.

Example: DCV, 100 mV range, shorted input, 10 PLC, 7 digits:

```
display   - 0. 0  0. 0. 0. 4.   7      dark DP after digit 2; at 1 PLC the range shows E-3
reads     -00.00047 E-3 V  = -0.47 µV  (10 nV resolution)
```

## Bugs fixed

None of these are in the factory ROM. Each was found by comparing against the factory `u7.bin`
and is tagged `FIX:` in [`src/u7fixed.asm`](src/u7fixed.asm).

| Where | Bug | Effect in the published ROM |
| --- | --- | --- |
| `sub012` (LA70F, LA724) | `jmp LC9D2` (main-loop restart) instead of `rts` | **Autorange freeze:** the new range never reaches the inguard |
| Power-on init (LD9A1) | 600 Ω preset written to the null register Z instead of R | Z = 600 and R = 0 after power-on |
| `subMathFcnDBM` | Tests Z instead of R for zero | The dBm guard checks the wrong register |
| `subPresetLnUregs` | U exponent written to U5 instead of U6 | Upper limit U is wrong (should be +1.999999E9) |
| RECALL key (LF4B8) | Clears Z0 instead of R0 | Wrong register cleared |
| Register D entry (LE0BC) | `bcc LE191` became an unconditional `jmp LE191` | Valid delay values are never stored |
| Digits-displayed entry (LE1DE) | `jsr subDisplayError4` dropped | Entering 2 or 8 is silently ignored instead of showing E4 |

The 7th-digit display and HPIB output now go through one routine, `sub7thDigitShown`, which
applies the PLC and number-entry rules above.

## Build

Requires Python 3.

```
python3 tools/as02.py src/u7fixed.asm build/u7fixed.bin build/u7fixed.lst
```

`build/u7fixed.bin` is a 32 KB image for U7, with the same layout as the original. For a larger
chip, tile it so the image works whatever the unused upper address lines are tied to:

```
python3 tools/replicate.py build/u7fixed.bin build/u7fixed_512K.bin 512K
```

Expected hashes for the tested build are listed in `docs/HARDWARE_VALIDATION.md`.

## Install

The validated meter uses an SST39SF040 flash chip, wired as a 27256-style ROM in the 28-pin U7
socket on the A4 controller board, and programmed with a TL866 (`minipro`). Wiring, continuity
checks and programming commands are in
[`docs/U7_FLASH_ADAPTER.md`](docs/U7_FLASH_ADAPTER.md).

Before you install:

- **Back up the current chip** first (`minipro -p SST39SF040 -r backup.bin`).
- **Run the self-test** after installing. TEST cycles all segments on and off continuously
  until you press another key; a failure breaks the cycle and shows an error.

## ROM space

About 950 bytes are free for future changes:

| Range | Bytes | Notes |
| --- | --- | --- |
| $F33E–$F65A | 797 | Directly after the code |
| $FF56–$FFEF | 154 | Below the interrupt vectors |
| $8000–$9FFF | 8192 | Never used by the factory ROM; whether the board maps it to U7 is unverified |

### Ideas for the free space

Contributions welcome. Sizes are rough estimates.

| Idea | Size | Why |
| --- | --- | --- |
| Firmware version at power-on (e.g. `FIX 1` after `+HP3456+`) | ~30 B | Tells you which ROM a meter is running |
| ROM checksum in self-test | ~60 B | Catches a bad flash or failing chip, which the current self-test can't |
| Power-on defaults (e.g. 10 PLC, 7 digits) | ~20 B | The meter has no settings memory |
| ppm deviation math mode | ~150–250 B | % error has too few digits for 7.5-digit drift and calibration work |
| Stability indicator | ~100–150 B | Annunciator lights once the last N readings agree within X counts |
| Min/max hold | ~100 B | Track the extremes, viewable with RECALL L / U |
| Pt100 RTD temperature | ~300–400 B | 4-wire ohms to °C (Callendar–Van Dusen), using the ROM's BCD maths |
| 7th digit in packed HPIB output | small | Currently only the unpacked format carries it |

The first three fit together in the 154-byte block below the vectors, leaving the 797-byte
block for one larger feature.

To try out code in $8000–$9FFF, a [One ROM](https://onerom.org/) Fire 28 in place of the flash
chip makes testing and rollback fast. See the end of `docs/HARDWARE_VALIDATION.md`.

## Repository layout

| Path | Contents |
| --- | --- |
| `src/u7fixed.asm` | Fixed source; changes tagged `FIX:` (this build) and `MODDED` (the original 7.5-digit mod) |
| `src/u7modded.asm` | The published mod's source, recovered from its listing (the zip has no `.asm`); reassembles byte-identical to `u7modded.bin` |
| `tools/as02.py` | 6800 assembler for the AS02 subset used here, with branch relaxation |
| `tools/compare.py` | Lockstep semantic diff of two ROMs: `compare.py orig.bin new.bin new.lst`. Run it against the factory `u7.bin` |
| `tools/dis.py` | Linear 6800 disassembler: `dis.py rom.bin start end` |
| `tools/replicate.py` | Tiles an image to fill a larger chip |
| `tools/lst2asm.py` | Recovers source from an AS02 listing |
| `tools/patch.py` | Earlier in-place binary patcher, superseded by the source build |
| `docs/` | Flash adapter wiring and the hardware test plan with results |

## Credits, license and disclaimer

The disassembly, commentary and 7.5-digit mod come from the work shared in the EEVblog
"Adventures in retrocomputing" thread. This project only fixes and extends it. The original
firmware is HP's.

This project's own work (the tools, the docs and the `FIX:` changes) is MIT-licensed; see
[`LICENSE`](LICENSE). The licence doesn't cover HP's firmware or the upstream mod. No ROM
images are included: get `3456AFirmware.zip` from the thread, then build from source.

Use at your own risk. Back up your original ROM, and work only on the outguard controller
board with the meter unplugged.
