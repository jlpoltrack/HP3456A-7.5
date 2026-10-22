# HP-IB (GPIB) Command Reference

The 3456A command set as implemented by this firmware, taken from the parser in
[`src/u7fixed.asm`](../src/u7fixed.asm) (`sub116` and the tables at $F834–$F8FF). It matches
the factory command set; the 7.5-digit additions are `7STG` and the extra output digit.

The factory HP-IB address is 22. Examples use PyVISA:

```python
import pyvisa
dvm = pyvisa.ResourceManager().open_resource("GPIB0::22::INSTR")
dvm.read_termination = "\r\n"
dvm.write("H F1 R1 T1")
print(dvm.read())
```

## Syntax

- Commands are uppercase ASCII and can be chained in one string: `F1R3M0T3`.
- Most commands are a letter plus one digit (`F1`), or two letters plus one digit (`FL1`).
- A number is sent **before** the command that uses it: `10STN` stores 10 in register N.
  Numbers may use `+ - . E e`, e.g. `-1.5E-3STZ`.
- An unrecognised command sets the syntax-error status bit (16). An out-of-range register value
  shows `ERROR 4` and is not stored.

## Function, range and measurement

| Command | Meaning |
| --- | --- |
| `F1` | DC volts |
| `F2` | AC volts |
| `F3` | AC + DC volts |
| `F4` | 2-wire ohms |
| `F5` | 4-wire ohms |
| `S0` / `S1` | Shift off / on. With `S1`: `F1`–`F3` become ratio (÷ DC reference), `F4`/`F5` become extended ohms |
| `R1` | Autorange |
| `R2`–`R9` | Fixed range: 0.1, 1, 10, 100, 1K, 10K, 100K, 1M (volts, or kΩ for ohms) |
| `Z0` / `Z1` | Autozero off / on |
| `FL0` / `FL1` | AC filter off / on |

Ohms ranges map as `R2` = 100 Ω … `R9` = 1 GΩ; volts ranges are `R2` (100 mV) to `R6` (1000 V).

```
F1R4Z1        DC volts, 10 V range, autozero on
F5R1          4-wire ohms, autorange
S1F1          DC:DC ratio
F2FL1R5       AC volts, filter on, 100 V range
```

## Triggering

| Command | Meaning |
| --- | --- |
| `T1` | Internal (free run) |
| `T2` | External trigger input |
| `T3` | Single trigger: take one reading now |
| `T4` | Hold |

A bus Group Execute Trigger (GET) also triggers a reading in hold.

```python
dvm.write("F1R1T4")          # set up, then hold
dvm.write("T3")              # one reading
print(dvm.read())            # e.g. +1.234567E+0
dvm.assert_trigger()         # or use GET
print(dvm.read())
```

## Registers: store and recall

`<value>ST<reg>` stores a value; `RE<reg>` recalls it to the display and the bus.

| Reg | Contents | Notes |
| --- | --- | --- |
| `N` | Number of readings per trigger | |
| `G` | Digits displayed | 3–7. **7** is the 7.5-digit mode (10 or 100 PLC only); 2 or 8 gives `ERROR 4` |
| `I` | Integration time, power-line cycles | .01, .1, 1, 10, 100 |
| `D` | Delay before each reading, seconds | |
| `L` | Lower limit | Pass/fail (`M1`) |
| `U` | Upper limit | Pass/fail (`M1`); preset +1.999999E9 |
| `R` | Reference resistance, Ω | dBm (`M4`); preset 600 |
| `Y` | Constant Y | Scale, % error, dB |
| `Z` | Null / offset Z | Null (`M3`) and scale |
| `C` | Count | Statistics (`M2`) result |
| `M` | Mean | Statistics result |
| `V` | Variance | Statistics result |

```
10STI         10 PLC
7STG          7 digits (7.5-digit mode)
5STN          5 readings per trigger
0.1STD        100 ms delay
600STR        600 Ω dBm reference
REM           recall the mean
```

```python
dvm.write("F1R1 10STI 7STG T1")   # 7.5-digit DCV
```

## Math

| Command | Function |
| --- | --- |
| `M0` | Math off |
| `M1` | Pass/fail against `L` and `U` (sets SRQ bit 128 on fail) |
| `M2` | Statistics: fills `C`, `M`, `V` |
| `M3` | Null: reading − `Z` |
| `M4` | dBm, referenced to `R` |
| `M5` | Thermistor, °F |
| `M6` | Thermistor, °C |
| `M7` | Scale: (X − Z) / Y |
| `M8` | % error: 100 (X − Y) / Y |
| `M9` | dB: 20 log (X / Y) |

```
0STZ M3       null with Z = 0
-0.5STL 0.5STU M1      pass/fail window ±0.5
10STN M2 T3 REM        10-reading statistics, then recall the mean
1.000STY M8            % error from 1.000
```

## Output and display

| Command | Meaning |
| --- | --- |
| `P0` / `P1` | Unpacked ASCII / packed BCD output |
| `O0` / `O1` | EOI with the last byte off / on |
| `D0` / `D1` | Display off / on (off shows dashes) |
| `SO0` / `SO1` | System output mode off / on |
| `RS0` / `RS1` | Reading storage off / on |
| `SW1` | Return the front/rear terminal switch state as `0` or `1` + CR LF |

### Reading format

Unpacked readings are ASCII terminated with CR LF, e.g. `+1.234567E+0`: sign, 7 digits with
a decimal point, `E`, exponent sign, one exponent digit.

In 7-digit mode (`7STG` at 10 or 100 PLC), the 7th digit is appended to the mantissa:
`+1.2345678E+0`. It is left out at 1 PLC or less, while a number is being entered, and in packed
output. HP-IB output of the 7th digit has not been tested on hardware yet.

Packed output (`P1`) sends 3–4 bytes of BCD per reading.

## Service request

`SM<ooo>` sets the SRQ mask as three octal digits (0–7). A condition raises SRQ only when its
bit is set in the mask; read the cause with a serial poll.

| Bit | Value | Condition |
| --- | --- | --- |
| 0 | 1 | Front-panel SRQ key |
| 1 | 2 | Program memory finished (`X1`) |
| 2 | 4 | Data ready |
| 3 | 8 | Trigger received |
| 4 | 16 | Syntax or hardware (inguard) error |
| 5 | 32 | Program memory interrupted or full |
| 6 | 64 | RQS (set by the bus chip) |
| 7 | 128 | Pass/fail limit exceeded |

```
SM004         SRQ on data ready
SM024         SRQ on data ready or error (4 + 16 = 20 = octal 024)
SM200         SRQ on limit failure
```

```python
dvm.write("SM004 F1 T3")
dvm.wait_for_srq()
print(dvm.read_stb(), dvm.read())
```

## Program memory

`L1` starts learning: the rest of the command string is stored instead of executed. `X1` runs the stored program (SRQ bit 2 on completion). Spaces are ignored.

```
L1 F1 R1 10STI 7STG T1      learn a 7.5-digit DCV setup
X1                          replay it
```

## Reset, clear and test

| Command | Meaning |
| --- | --- |
| `H` | Home: reset to the power-on state |
| `CL1` | Clear: abort the current command and reading, restart the measurement loop |
| `TE1` | Start self-test |
| `TE0` | Stop self-test (resets the meter) |

```
H             power-on defaults
TE1           self-test; TE0 or H to end
```
