# HP 3456A U7 Flash Adapter Wiring

As of 2026-10-19.

## Summary

The wiring is correct. A 32-pin SST39SF040 (512K x 8 flash) runs in the 28-pin U7 socket on the
A4 controller board. Its four extra address lines are grounded and it is powered from C1. It
behaves as a 32K x 8 ROM, so the 32K firmware image must sit at offset 0, or be repeated across
the whole chip.

This was traced from a photo of the installed chip; the continuity checks below confirm it. The
meter works with this wiring today.

## Pin map

The chip's notch faces the board edge (the bottom of the photo), so the six modified pins are at
that end: pins 1–3 on one side and 30–32 on the other. Chip pins 4–29 plug straight into socket
pins 2–27. Socket pins 1 and 28 are left empty.

| Chip pin | Signal | Connection | Purpose |
| --- | --- | --- | --- |
| 1 | A18 | Bent out; bare-wire bridge to pins 2 and 3; green wire to C1 ground end | Tie low |
| 2 | A16 | Same bridge | Tie low |
| 3 | A15 | Same bridge; kept out of socket pin 1 | Tie low |
| 4–29 | A0–A14, DQ0–DQ7, CE#, OE#, VSS | Socket pins 2–27 (standard 27256 positions; VSS pin 16 lands on socket GND pin 14) | Direct |
| 30 | A17 | Bent out; green wire to C1 ground end; kept out of socket pin 28 | Tie low |
| 31 | WE# | Bent out; bridged to pin 32 | Held high, so the chip is never written in circuit |
| 32 | VDD | Bent out; white wire to C1 +5 V end | Power |

SST39SF040 32-pin DIP pinout, for reference (top view, notch up):

```
          +---\_/---+
 NC/A18  1|         |32 VDD
    A16  2|         |31 WE#
    A15  3|         |30 NC/A17
    A12  4|         |29 A14
     A7  5|         |28 A13
     A6  6|         |27 A8
     A5  7|         |26 A9
     A4  8|         |25 A11
     A3  9|         |24 OE#
     A2 10|         |23 A10
     A1 11|         |22 CE#
     A0 12|         |21 DQ7
    DQ0 13|         |20 DQ6
    DQ1 14|         |19 DQ5
    DQ2 15|         |18 DQ4
    VSS 16|         |17 DQ3
          +---------+
```

## Why it works

- **Power:** VDD comes from the +5 V end of C1 through the white wire. Ground reaches VSS
  (pin 16) through socket pin 14. Socket pin 28 is not used.
- **WE# tied high:** the chip is read-only in the meter.
- **A15–A18 tied low:** the chip shows only its first 32K (offsets $00000–$07FFF). The board
  drives A0–A14, CE# and OE# exactly as it would a 27256-style ROM.
- **Pins 3 and 30 kept out of the socket:** they are grounded, so if pin 30 sat in socket pin 28
  (+5 V on a 27256 footprint) it would short the supply. The meter working confirms they are out.
- **Image layout:** `build/u7fixed_512K.bin` repeats the 32K image 16 times, so it works
  whatever the upper address lines are tied to.

## Continuity checks

With the power off and the chip in place, measure on the chip's legs:

1. Pin 31 to pin 32: 0 Ω (WE# tied to VDD).
2. Pins 1, 2, 3 and 30 to pin 16: 0 Ω each (upper address lines grounded).
3. Pin 32 to pin 16: not a short (the meter may show C1 charging).
4. Pin 3 to socket pin 1, and pin 30 to socket pin 28: open.

With the meter powered: pins 31 and 32 at +5 V, and pins 1, 2, 3 and 30 at 0 V.

## Reprogramming

To program the chip, all six wired pins must be free for the TL866 to drive:

- **The VDD–WE# bridge (pins 32, 31):** the programmer pulls WE# low to write.
- **The A15/A16/A18 bridge (pins 1–3) and the A17 wire (pin 30):** the programmer drives these
  to different values as it steps through addresses.
- **The wires to C1:** they hold the chip to the board.

The bent legs must also make contact in the ZIF socket. Bending them back and forth risks
breaking them.

Recommended: use the adapter PCB, [`hardware/u7-adapter/`](../hardware/u7-adapter/). The flash
chip stays stock and goes straight into the TL866. The PCB powers the chip from U7 pin 28 through a
solder jumper, or from a wire pad to C1. It also has A15–A18 bank jumpers with pull-downs. Keep the
current wired chip as a known-good fallback.

Without the PCB, a hand-wired carrier does the same job:

1. Take a 32-pin turned-pin DIP socket as a carrier.
2. Bend out its pins 1, 2, 3, 30, 31 and 32 and wire them as in the pin map.
3. Plug the carrier into the U7 socket, and the flash chip into the carrier.

Check that the extra height of the adapter clears anything above the board.

A 28-pin drop-in part (for example a 27C256-family device) would avoid an adapter. That depends on
what socket pins 1 and 28 carry, which has not been checked.

## Programming with the TL866 (minipro)

Build the 512K image from the repo root:

```
python3 tools/as02.py src/u7fixed.asm build/u7fixed.bin build/u7fixed.lst
python3 tools/replicate.py build/u7fixed.bin build/u7fixed_512K.bin 512K
```

Put the chip in the ZIF socket: pin 1 toward the lever, pushed to the lever end. minipro checks
the chip ID before writing, which catches a misplaced chip or a bad contact.

```
minipro -p SST39SF040 -r build/backup_current.bin   # optional: save what's on the chip now
minipro -p SST39SF040 -w build/u7fixed_512K.bin      # erase, write, verify
minipro -p SST39SF040 -m build/u7fixed_512K.bin      # re-verify later if needed
```
