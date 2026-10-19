# HP 3456A Fixed Firmware — Hardware Validation

Planned for 2026-10-20. Status: complete 2026-10-19. Tests 1–14 passed; test 15 (optional HPIB) skipped, no HPIB interface.

Goal: confirm `build/u7fixed.bin` fixes the autorange freeze and that the 7.5-digit changes behave
as designed on the meter. Until now everything has been checked only by static comparison against
the factory ROM, with nothing run on hardware.

## Image under test

| File | Size | SHA-256 |
| --- | --- | --- |
| `build/u7fixed.bin` | 32 KB | `bd916a6a89d88957d149342c0e2c780357c24a25a2ed46e1d09dea345f8a4760` |
| `build/u7fixed_512K.bin` | 512 KB (32 KB x 16) | `10636abae76d22c4b8c99faf99a788bb658c748959798ead6f47c20e80f5e0a5` |

Burn the 512 KB file. If the source changes, rebuild and update these hashes (commands in
`README.md`).

## Before you start

- [ ] Decide the chip route (see `docs/U7_FLASH_ADAPTER.md`):
    - **A:** desolder the wires on the current chip, program it, then rewire it.
    - **B (recommended):** program a fresh SST39SF040 in a socketed adapter, and keep the current chip as a fallback.
- [x] TL866 connected; `minipro --version` shows the programmer (TL866II+ 04.2.132).
- [ ] Record the meter's power-on behaviour with the current chip, as the baseline.
- [ ] Have a variable DC source available for the autorange tests (0 to about 15 V).

## Program

```
minipro -p SST39SF040 -r build/backup_current.bin   # only if the current chip is in the ZIF
minipro -p SST39SF040 -w build/u7fixed_512K.bin      # erase, write, verify
```

- [x] Write and verify passed (2026-10-19; independent read-back SHA-256 matches `u7fixed_512K.bin`).
- [x] If a backup was read: ask Claude to identify it (factory, published modded, or other).
    `build/backup_current.bin` (SHA-256 `e5b72193…65ce98`): first 32 KB identical to the published
    `u7modded.bin` from `3456AFirmware.zip`; the remaining 480 KB blank (0xFF). Chip ID only read
    reliably after several reseats.

## Tests

Run them in order, and stop at the first failure. Record what you see in the Results log.

| # | Test | Steps | Expected | Covers |
| --- | --- | --- | --- | --- |
| 1 | Power on | Power the meter on | `+HP3456+` banner, then the HPIB address, then continuously updating readings | Boot, autorange fix |
| 2 | Autorange up | DCV, auto range; ramp the input from 0.5 V up past 1.2 V, then past 12 V | Ranges up, and the display keeps updating (the published ROM freezes here) | Autorange fix |
| 3 | Autorange down | Ramp back down to about 0.1 V | Ranges down, and the display keeps updating | Autorange fix |
| 4 | Self test | Run TEST from the front panel | Passes, same as with the original ROM | General sanity |
| 5 | 7 digits at 10 PLC | Set 10 PLC; enter `7` for digits displayed | 7th digit in the exponent position; no exponent sign | 7.5-digit mod |
| 6 | Fast PLC | Still in 7-digit mode, set 1 PLC | Normal 6-digit display (exponent shown when the range has one) | 7th digit hidden below 10 PLC |
| 7 | Keypad entry | In 7-digit mode at 10 PLC, start entering a number (e.g. `1.5E3`) | The exponent position follows what you type, not a stale 7th digit | 7th digit hidden during entry |
| 8 | Exponent marker | 7-digit mode at 10 PLC, DCV, manual 100 mV range | Decimal points inverted: lit on every digit except the true decimal position. Check that 10 V shows normal decimals, and that 100 mV at 1 PLC returns to normal with E-3 | 7.5-digit mod |
| 9 | Bad digit count | Enter `8` (or `2`) for digits displayed | Display shows `E4` (error 4) | Fix: missing error |
| 10 | dBm | Fresh power-on, then enable dBm with no setup | Reading uses R = 600 Ω; no error | Fix: R preset, dBm check |
| 11 | Null | Fresh power-on; enable NULL | The first reading becomes the null value, not 600 | Fix: Z no longer preset to 600 |
| 12 | Recall R | Recall the R register after power-on | Shows 600 | Fix: R preset |
| 13 | Limit U | Recall the U register after power-on | Shows +1.999999E9 | Fix: U exponent |
| 14 | Store D | Store a valid delay value in D | Accepted, no error | Fix: register D path |
| 15 | HPIB 7 digits (optional) | 7-digit mode at 10 PLC; read over HPIB in unpacked format | Reading carries the 7th digit | 7.5-digit mod |

## Results log

| # | Result | Notes |
| --- | --- | --- |
| 1 | Pass | |
| 2 | Pass | |
| 3 | Pass | |
| 4 | Pass | All segments/annunciators light, then display blinks every few seconds: the continuous self-test loop (`sub103`). A failure would break the cycle with a ~2 s failure display. |
| 5 | Pass | |
| 6 | Pass | |
| 7 | Pass | |
| 8 | Pass | Short on 100 mV: `-0.00.0.0.4. 7` — all DPs lit except after digit 2 (true DP), 7th digit in exponent position; reads -00.00047 mV. 1 PLC cross-check shows E-3. |
| 9 | Pass | Both `2` and `8` show E4. |
| 10 | Pass | Fresh power-on, 11.4 V DC, dBm shows 23.36 (expected 20·log10(V)+2.218 = 23.36), no error. |
| 11 | Pass | Fresh power-on, 11.4 V, NULL reads ~0; short then reads ~-11.4 V. |
| 12 | Pass | R recalls 600. |
| 13 | Pass | U recalls +1.999999E9. |
| 14 | Pass | D = 1 accepted, no error; readings slow to ~1/s. |
| 15 | Skipped | Meter has no HPIB interface. |

## If something fails

- **Meter dead or garbled display at power-on:** first refit the original chip to rule out the
  hardware. Then re-verify the burned chip with
  `minipro -p SST39SF040 -m build/u7fixed_512K.bin`.
- **A specific test fails:** note the exact display and the steps. Claude can trace it in
  `src/u7fixed.asm`; every change is tagged `FIX:` or `MODDED`.
- **Rollback:** refit the original chip (route B), or reprogram the current chip from
  `build/backup_current.bin`.

## Future option: One ROM Fire 28

A [One ROM](https://onerom.org/) Fire 28 would replace the flash chip and the TL866 for ongoing
firmware development. It emulates a 27C256 natively in the 28-pin U7 socket, with no adapter.

**Which board:** a Fire 28 with USB-C, from the current recommended revisions.

- rev C: flat USB-C connector, lowest height.
- rev D: upright USB-C connector.

Choose by the clearance above U7.

**What it gives us:**

- Reflash over USB in about 10 s, in the meter: `onerom` CLI or browser.
- Patch the running image live (`onerom poke live` / `peek live`), with no reflash for small changes.
- Several images on one device (factory, published modded, fixed), switched at runtime, so A/B
  testing and rollback are trivial.

**Before ordering:**

- [ ] With the chip removed and the meter on, measure U7 socket pin 28 against pin 14.
  If it reads +5 V, One ROM plugs straight in. Otherwise, run a power wire to One ROM's 5 V header
  pin, as the current flash chip does from C1. The One ROM docs warn the board can be damaged
  without power.
- [ ] Note what socket pin 1 measures (VPP position on a 27256; not used by One ROM).
- [ ] Measure the clearance above U7 to choose rev C or rev D.

**Why it should work:** socket pins 2–27 already carry 27256 signals (A0–A14, D0–D7, CE# on
pin 20, OE# on pin 22), as the flash adapter shows. One ROM's 5 V logic levels are rated against
6502-class buses, which match the 6800. It serves 1–2 MHz systems such as the C64.

**Safety:** U7 is on the outguard (chassis-grounded) controller board, so USB to a computer while
the meter runs is fine. Never connect USB to anything on the floating inguard.

**Workflow change once fitted:** the Program step above becomes a USB flash, the tests stay the
same, and rollback becomes an image switch.

References: One ROM `docs/COMPATIBILITY.md` (Fire 28 rev C/D: 27C256 native, 64 KB image),
`docs/VOLTAGE-LEVELS.md` and `hardware/pcb/README.md` in the
[GitHub repo](https://github.com/piersfinlayson/one-rom).
