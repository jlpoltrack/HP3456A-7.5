;
; Commented disassembly of 3456A U7 32K ROM
;
; Disassembled with the DASMx disassembler v 1.40 from http://myweb.tiscali.co.uk/pclare/DASMx/
;
; Some rearrangement of this code has been done to eliminate some jumps and branches
; to improve readability, but otherwise the code is unchanged.
;
; Naming Convention
;
; The disassembler created label names Lhhhh where hhhh is the hex location in the original
; code.  Because of all the deleted branches and jumps (hundreds, actually) in
; straightening up the code, the labels no longer assemble into the previously
; absolute locations, but that doesn't matter.
;
; The disassembler created variable (RAM storage locations) with names Xhhhh, where
; hhhh is again the hex locations.  Where variables have been found to be local to
; only one subroutine, the first letter was changed from "X" to "x" to make it easier
; to distinguish between local and global variables when reading the code.
;
; Where the purpose of a variable or subroutine has been determined with some confidence
; a descriptive name has been given.
;
; Subroutine names are sub*.  I/O addresses are io*.  Names not starting with
; sub or io are variables.
;
;
; ROM Space
;
; The ROM space on the 3456A is the top 32K of the memory map, although the installed
; ROMs only used the top 24K of that.  We're going to use a 32KB (or larger) ROM so
; we will just reserve the first 8K for nothing.

	code
	org	$8000	; 32KB for start of ROM
	rmb	$2000	; 8K of zeros -> code occupies top 24K of ROM space
;


;=====================================================================================

;===============================================================================
;
; Symbols - with notes on their usage
;
;===============================================================================
X0000	equ	$0000
X0001	equ	$0001
X0002	equ	$0002	; used with 0003 for index pointers
X0003	equ	$0003
x0004	equ	$0004	; local in subNMI
x0005	equ	$0005	; local in subNMI
x0008	equ	$0008	; local in subNMI
x0009	equ	$0009	; local in subNMI
x000C	equ	$000C	; local in subNMI
x000E	equ	$000E	; local in subNMI
x0014	equ	$0014	; local in subNMI
X0016	equ	$0016	; local in subNMI
X0024	equ	$0024	; local in subIRQ
X0025	equ	$0025	; local in subIRQ
X0026	equ	$0026	; local in subIRQ
X0027	equ	$0027	; local in subIRQ
X0028	equ	$0028	; local in subIRQ
X0029	equ	$0029	; local in subIRQ
X002A	equ	$002A	; local in subIRQ
X002C	equ	$002C	; local in subIRQ
X002E	equ	$002E	; local in subIRQ
X002F	equ	$002F	; local in subIRQ
X0032	equ	$0032	; local in subIRQ
Digit7	equ	$0040	; ***** MODDED stores the 7th digit *****
flag7Digits	equ	$0041	; ***** MODDED indicates 7 display digits selected  *****
x0044	equ	$0044	; local in many subs
x0045	equ	$0045	; used with above to form index in several subs
x0046	equ	$0046	; local in several subs
x0047	equ	$0047	; used with above to form index in subStoreDisplayToRegister
x0048	equ	$0048	; local in many subs
x0049	equ	$0049	; used with above to form index in many subs
x004A	equ	$004A	; local in many subs
x004B	equ	$004B	; used with above to form index in many subs
x004C	equ	$004C	; local in many subs
x004D	equ	$004D	; used with above to form index in several subs
x004E	equ	$004E	; local in many subs
x004F	equ	$004F	; used with above to form index in several subs
x0050	equ	$0050	; local in many subs
x0051	equ	$0051	; used with above to form index in 2 subs
x0052	equ	$0052	; local in subSetAnnuncByte4
x0054	equ	$0054	; local in several subs
x0056	equ	$0056	; local in subSetAnnuncByte4
x0058	equ	$0058	; local in sub107, sub116
x005A	equ	$005A	; local in subSetAnnuncByte4
x005E	equ	$005E	; local in subSetAnnuncByte4, sub023
x005F	equ	$005F	; used with above to form index in sub023
x0066	equ	$0066	; local in subSetAnnuncByte4
x00BC	equ	$00BC	; local in subWaitForIGStatus, for timeout length of Inguard response
StackStart	equ	$0101	; stack starts at 00FF
X0103	equ	$0103	; flag used in sub081, set in sub116, subIRQ
flagOutputEOI	equ	$0104	; =1 if EOI to be output with readings on HPIB
flagHPIBPackedOutput	equ	$0105	; flag used in sub019, sub023, subHPIBOutputMeasurement, sub078, set in sub
flagHPIBOutputStatus	equ	$0106	; = Talker Active (08) | Ready for Data (10) | Output Empty (40)
flagDispNeedUpdate	equ	$0107	; = 1 if display needs to be updated
X0108	equ	$0108	; counter variable? in sub043, subMathFcnStats
flagMeasFormatted	equ	$0109	; = 1 if current measurement is formatted for output (?)
X010A	equ	$010A	; flag used in subAnnuncNDisplayUpdate, set in sub089
flag010B	equ	$010B
X010C	equ	$010C	; flag used in sub078,sub086,sub103, set in sub060
flagHPIBByteInIntr	equ	$010D	; 1=HPIB will issue interrupts on data received.
x0117	equ	$0117	; local in subCheckIfIGReadyToMeasure,sub060,sub062
x0118	equ	$0118	; used with above as index
x0119	equ	$0119	; local in subGetInguardReading,sub060,sub077,subRST, passes value sub012 to sub011
X011A	equ	$011A	; passes value sub012 to sub011
X011B	equ	$011B	; may be global
x011C	equ	$011C	; local in many subs
InguardStatus	equ	$011D
X011E	equ	$011E	; local in several subs and returns value from sub062
x011F	equ	$011F	; local in sub063, sub088
PressedKeyCode	equ	$0120	; local in subIRQ
flagX0121	equ	$0121
flagHPIBOutput	equ	$0122	; bit4=service requested,bit6,bit7=multiple readings out
InguardCmd	equ	$0123
X0124	equ	$0124	; set in sub016 from table values, used in sub078
IGCmdRegister0	equ	$0125	; global, 69@reset, set from table values in sub098,subTestInguardMeasuring
IGCmdRegister1	equ	$0126
IGCmdRegister2	equ	$0127
IGCmdRegister3	equ	$0128	; set in sub112, used in subHPIBRequestService
IGCmdRegister4	equ	$0129	; bit0,1 are for # digits displayed
X012A	equ	$012A	; measurement digit? set in sub114, used in sub028,sub077,sub116,subNMI
X012B	equ	$012B
X012C	equ	$012C
X012D	equ	$012D
X012E	equ	$012E


; --- 7 byte Registers --- some are described in manual, Table 3.2
; offsets given from address $0125
; data structure:
;	byte0	polarity, FF = negative, 00 = positive
;	byte1	lower nibble holds "overrange" BCD digit (0 or 1), upper nibble is where decimal would be
;	byte2	digits 1,2
;	byte3	digits 3,4
;	byte4	digits 5,6
;	byte5	additional digits for calculation
;	byte6	exponent, 2's compliment if negative

; appears to be used in statistics calculations
X010E	equ	$010E
X010F	equ	$010F
X0110	equ	$0110
X0111	equ	$0111
X0112	equ	$0112
X0113	equ	$0113
X0114	equ	$0114

; R, offset = 0A
RegisterR0	equ	$012F
RegisterR1	equ	$0130
RegisterR2	equ	$0131
RegisterR3	equ	$0132
RegisterR4	equ	$0133
RegisterR5	equ	$0134
RegisterR6	equ	$0135

; Y, offset = 11
RegisterY0	equ	$0136
RegisterY1	equ	$0137
RegisterY2	equ	$0138
RegisterY3	equ	$0139
RegisterY4	equ	$013A
RegisterY5	equ	$013B
RegisterY6	equ	$013C

; Z, offset = 18
RegisterZ0	equ	$013D
RegisterZ1	equ	$013E
RegisterZ2	equ	$013F
RegisterZ3	equ	$0140
RegisterZ4	equ	$0141
RegisterZ5	equ	$0142
RegisterZ6	equ	$0143

; LOWER, offset = 1F
RegisterL0	equ	$0144	; 0144-014A set in subPresetLnUregs to FF 01 99 99 99 00 10 (= -1.999999E9)
RegisterL1	equ	$0145
RegisterL2	equ	$0146
RegisterL3	equ	$0147
RegisterL4	equ	$0148
RegisterL5	equ	$0149
RegisterL6	equ	$014A

; UPPER, offset = 26
RegisterU0	equ	$014B	; 014B-0151 set in subPresetLnUregs to 00 01 99 99 99 00 10 (= +1.999999E9)
RegisterU1	equ	$014C
RegisterU2	equ	$014D
RegisterU3	equ	$014E
RegisterU4	equ	$014F
RegisterU5	equ	$0150
RegisterU6	equ	$0151

; Count, offset = 2D
RegisterC0	equ	$0152
RegisterC1	equ	$0153
RegisterC2	equ	$0154
RegisterC3	equ	$0155
RegisterC4	equ	$0156
RegisterC5	equ	$0157
RegisterC6	equ	$0158

; STAT1, offset = 34, used in statistics calculations, sum of (xi - x1)^2
RegisterSTAT10	equ	$0159
RegisterSTAT11	equ	$015A
RegisterSTAT12	equ	$015B
RegisterSTAT13	equ	$015C
RegisterSTAT14	equ	$015D
RegisterSTAT15	equ	$015E
RegisterSTAT16	equ	$015F

; STAT2, offset = 3B, sum of (xi - x1)
RegisterSTAT20	equ	$0160
RegisterSTAT21	equ	$0161
RegisterSTAT22	equ	$0162
RegisterSTAT23	equ	$0163
RegisterSTAT24	equ	$0164
RegisterSTAT25	equ	$0165
RegisterSTAT26	equ	$0166

; AccumRegister, offset	= 42
AccumRegister0	equ	$0167
AccumRegister1	equ	$0168
AccumRegister2	equ	$0169
AccumRegister3	equ	$016A
AccumRegister4	equ	$016B
AccumRegister5	equ	$016C
AccumRegister6	equ	$016D

; STAT3, offset = 4A, (xi - x1)
RegisterSTAT30	equ	$016F
RegisterSTAT31	equ	$0170
RegisterSTAT32	equ	$0171
RegisterSTAT33	equ	$0172
RegisterSTAT34	equ	$0173
RegisterSTAT35	equ	$0174
RegisterSTAT36	equ	$0175

; also some registers are used but maybe just as temporary scratch variables
X0176	equ	$0176	; register 0176-017C start byte
X017D	equ	$017D	; register 017D-0183 start byte
; register at 0184-018A is used to hold x1 for statistics calculations, but individual bytes are not addre
; --- end of 7 byte registers ---

X018B	equ	$018B
X018C	equ	$018C
CopyOfIGCmdByte	equ	$018D
X018E	equ	$018E
X018F	equ	$018F
BCDRoundupValue	equ	$0190	; either 01 or 05
X0191	equ	$0191	; local in sub085,sub086
X0192	equ	$0192	; local in sub085,sub086
InguardByte3	equ	$0193
InguardByte2	equ	$0194
InguardByte1	equ	$0195
InguardByte0	equ	$0196
AnDUpdatedFlag	equ	$0197	; = 1 once Annunciator and Display updated
X0198	equ	$0198
X0199	equ	$0199	; set in sub027, used in sub012
X019A	equ	$019A	; set in sub027, used in sub012
X019B	equ	$019B
X019C	equ	$019C
X019D	equ	$019D	; flag, 0,1
DecimalPosition	equ	$019E	; set in sub027, used in sub026
x019F	equ	$019F	; local in sub112
X01A0	equ	$01A0	; local in subRunMeasurement
flag01A1	equ	$01A1	; flag, set to 1 or 2 in sub116, cleared in other subs
flagCmdParse	equ	$01A2	; bits0,3,4,6,7 used as flags
CmdChar	equ	$01A3	; ASCII character from command
X01A4	equ	$01A4	; local in sub023
X01A5	equ	$01A5	; local in sub023
X01A6	equ	$01A6	; temp store for MeasExponent
X01A7	equ	$01A7	; temp store for MeasExponentSign
X01A8	equ	$01A8	; local in sub085
X01A9	equ	$01A9	; set in sub028, used in sub085,sub087
MeasArrayORd	equ	$01AA	; MeasArray 1-4 or'd together
X01AB	equ	$01AB	; set in subRunSelfTest,114, used in sub096,sub098,subTestInguardMeasuring
X01AC	equ	$01AC	; local in subRunSelfTest
flagTestMode	equ	$01AD	; bit0 = 1 puts unit in test mode, bit1 action unknown.
flagInguardTimeout	equ	$01AE	; set to FF if timeout waiting for data from Inguard
flagInguard1stTimeout	equ	$01AF	; 0 and set to 1 after 1st timeout from inguard
x01B0	equ	$01B0	; local
X01B1	equ	$01B1
X01B2	equ	$01B2

; 01B8-C5 are formatted measurment, 14 bytes of ASCII
FormattedReading0	equ	$01B8
FormattedReading1	equ	$01B9
FormattedReading2	equ	$01BA
FormattedReading3	equ	$01BB
FormattedReading4	equ	$01BC
FormattedReading5	equ	$01BD
FormattedReading6	equ	$01BE
FormattedReading7	equ	$01BF
FormattedReading8	equ	$01C0
FormattedReading9	equ	$01C1
FormattedReading10	equ	$01C2
FormattedReading11	equ	$01C3
FormattedReading12	equ	$01C4
FormattedReading13	equ	$01C5
X01C6	equ	$01C6
X01C7	equ	$01C7
DecimalDisplayPosition	equ	$01C8	; 6 = leading digit, 5 = next digit, then 4 then 3
X01C9	equ	$01C9
x01CA	equ	$01CA	; local used in several routines

X01CC	equ	$01CC
X01CD	equ	$01CD
X01CE	equ	$01CE
X01CF	equ	$01CF
CmdTableIndex	equ	$01D0	; used to pass value into subCmdTableLookup and as a local in several routines
MeasArray0	equ	$01D1	; least significant digit
MeasArray1	equ	$01D2	; contains reading from Inguard.
MeasArray2	equ	$01D3	; initially packed in 1st 4 bytes as 2 digit BCD
MeasArray3	equ	$01D4	; later 1 BCD digit per byte
MeasArray4	equ	$01D5
MeasArray5	equ	$01D6
MeasArray6	equ	$01D7
MeasArray7	equ	$01D8	; most significant digit
DisplayArray0	equ	$01D9	; these values are sent to the display.  One will be ASCII "."
DisplayArray1	equ	$01DA
DisplayArray2	equ	$01DB
DisplayArray3	equ	$01DC
DisplayArray4	equ	$01DD
DisplayArray5	equ	$01DE
DisplayArray6	equ	$01DF
DisplayArray7	equ	$01E0
flagDisplayHasExponent	equ	$01E1	; = 1 if exponent not zero
DisplayExponentSign	equ	$01E2
DisplayExponent	equ	$01E3
DisplayPolaritySign	equ	$01E4
flagDisplayArrayHasNoDecimal	equ	$01E5	; = 1 when 1 BCD digit/byte
X01E7	equ	$01E7
flag01ED	equ	$01ED	; only set = 1 in sub107,sub112
MeasPolaritySign	equ	$01EE	; contains "+" or "-" ASCII
flagMeasArrayUnpacked	equ	$01EF	; = 1 when 1 BCD digit/byte
tempCmdParseFlag	equ	$01F0
X01F1	equ	$01F1
MeasExponentSign	equ	$01F2	; contains "+" or "-" ASCII
flagMeasHasExponent	equ	$01F3	; = 1 if exponent not zero
MeasExponent	equ	$01F4	; one digit exponent
AnnuncByte0	equ	$01F5	; data that controls front panel LEDs
AnnuncByte1	equ	$01F6
AnnuncByte2	equ	$01F7
AnnuncByte3	equ	$01F8
AnnuncByte4	equ	$01F9
AnnuncByte6	equ	$01FA	; controls leading +/-1 digit (5th byte is exponent polarity, is not stored separate
flagX01FB	equ	$01FB	; only bits6,1,0 used, set and tested in subIRQ, cleared elsewhere
				; bit6 = 1 means entering exponent
flagX01FC	equ	$01FC
HPIBIntrMask	equ	$01FD
X01FE	equ	$01FE	; pointer to something in user RAM
X01FF	equ	$01FF
X0200	equ	$0200	; some indicator of user RAM
X0201	equ	$0201	; pointer to something in user RAM
X0202	equ	$0202	; with above
X0203	equ	$0203	; pointer to next user RAM data storage location
X0204	equ	$0204	; with above
X0205	equ	$0205	; pointer to something in user RAM
X0206	equ	$0206

; 0207 to 05EE appear to be the user storage space (see sub085)
X0789	equ	$0789	; flag
X078A	equ	$078A	; set in sub027, used for comparisons in sub016
flagNumPLCcode	equ	$078B	; # power line cycles to integrate = 0,1,2,3,4 for .01,.1,1,10,100
X078C	equ	$078C	; passes value into sub010, sub012, subInsertDisplayDecimal, set in sub016, sub027
flagOverrange_Maybe	equ	$078D	; flag, values 0,1
ErrorNumber	equ	$078E	; takes values 1-3,5,6, stored in MeasArray1 in subDisplayError
HPIBSerialPollStatus	equ	$078F	; mask used in subHPIBRequestService, takes values 01,02,04,08,10,12,20,80
X0790	equ	$0790	; offset for arrays from 0125, values 0A,11,18,1F,26,2D or 42
X0791	equ	$0791	; word of flag bits
HPIBSerialPollMask	equ	$0792	; mask for HPIB serial poll, values FB,FE
X0793	equ	$0793	; passes register offset into subCopyAccumRegToRegister, values 1E,25,2C,49,57,65
IdxPtr0169	equ	$0794	; used to hold index pointer set to 0RegisterSTAT21
IdxPtr0174	equ	$0796
X0798	equ	$0798	; local in subRunMeasurement
X0799	equ	$0799	; local in sub104
X079A	equ	$079A	; local in sub104
X079B	equ	$079B	; with 079C used with index reg., values F8B1,F857,F861
X079C	equ	$079C
X079D	equ	$079D	; holds offset for register, values given in sub114 0A,11,18,1F,26 or 42
x079E	equ	$079E	; local in subStoreDisplayToRegister for holding version of DisplayExponent
X079F	equ	$079F	; holds index, values F84D,F857,F861,F86B,F875,F87F,F889,F893,F89D,F8A7,F8CB,F8CC,F8F7
IGCmdRegisterNumber	equ	$07A1	; values set in sub114 of 00,01,02,04.  Used in subAdjustIGCmdRegister to cr
IGCmdRegBitClearMask	equ	$07A2	; mask used in subAdjustIGCmdRegister, values set in sub114,116,IRQ

; The following variables are used inside the math subroutines subMath*
X07A5	equ	$07A5	; X07A5-x07C6 are local variables used for math functions
X07A6	equ	$07A6	; in subRegisterAdd-141
X07A7	equ	$07A7	; X07A5-B hold result of register math functions
X07A8	equ	$07A8
X07A9	equ	$07A9
X07AA	equ	$07AA
X07AB	equ	$07AB
X07B0	equ	$07B0
X07B1	equ	$07B1	; X07B1-7 hold 2nd argument passed to register math functions
X07B2	equ	$07B2
X07B3	equ	$07B3
X07B4	equ	$07B4
X07B5	equ	$07B5
X07B6	equ	$07B6
X07B7	equ	$07B7
X07B8	equ	$07B8	; X07B8-E hold 1st argument passed to register math functions
X07B9	equ	$07B9
X07BA	equ	$07BA
X07BB	equ	$07BB
X07BC	equ	$07BC
X07BD	equ	$07BD
X07BE	equ	$07BE
x07BF	equ	$07BF	; set in subMath04,126, not used.
x07C0	equ	$07C0	; local in subMath10-134
x07C1	equ	$07C1	; local in subMath17-141
x07C2	equ	$07C2	; local in subMath10-134
x07C3	equ	$07C3	; local in subMath17-141
x07C4	equ	$07C4	; local in subMath10-134 (index with 07C5)
x07C6	equ	$07C6	; local in subMath10-141 (index with 07C5)
x07C8	equ	$07C8	; local in subMath24-156 (index with 07C9)
x07CA	equ	$07CA	; local in subMath22-157 (index with 07CB)
x07CC	equ	$07CC	; local in subMath22-157 (index with 07CD)
x07CE	equ	$07CE	; local in subMath28

; Memory mapped I/O addresses

ioIsoLogic	equ	$0800
ioVmComplete	equ	$1000
ioRateLite	equ	$1800
ioDAdata	equ	$3000
ioIOreset	equ	$3800
ioHPIB_r0	equ	$4000
ioHPIB_r1	equ	$4001
ioHPIB_r2	equ	$4002
ioHPIB_r3	equ	$4003
ioHPIB_r4	equ	$4004
ioHPIB_r5	equ	$4005
ioHPIB_r6	equ	$4006
ioHPIB_r7	equ	$4007
ioKBrdStrb	equ	$4800
ioKBrdClr	equ	$5000
ioDsplyStrb	equ	$5800
ioAnnunc	equ	$6000
ioSAstrb1	equ	$6800
ioSAstrb2	equ	$7000

;===============================================================================
; Routines for Signature Analysis service procedures
SigAnalyzer1:
	sei
	lds	#$00FF
	stab	ioKBrdClr
	cli
LA008:
	staa	ioSAstrb1
	ldaa	#$55
LA00D:
	ldx	#$0000
LA010:
	staa	$00,x
	cmpa	$00,x
	bne	LA028
	coma
	inx
	staa	$00,x
	cmpa	$00,x
	bne	LA028
	coma
	inx
	cpx	#$0800
	bne	LA010
	coma
	bmi	LA00D
LA028:
	nop
	clra
	sec
	staa	ioSAstrb2
LA02E:
	rora
	staa	ioDAdata
	staa	ioDsplyStrb
	staa	ioAnnunc
	staa	ioVmComplete
	staa	ioRateLite
	staa	ioIOreset
	staa	ioHPIB_r0
	bhi	LA02E
	bra	LA008
;
SigAnalyzer2:
	ldaa	ioKBrdStrb
	anda	#$BF
	staa	ioKBrdClr
	lds	#$00FF
	psha
	cli
	ldab	#$FF
	stab	ioIsoLogic
LA05A:
	staa	ioSAstrb1
	pula
	des
	ldab	#$07
LA061:
	staa	ioDAdata
	asra
	decb
	cmpb	#$00
	bhi	LA061
	ldab	#$8F
	stab	ioIsoLogic
	stab	ioKBrdStrb
	stab	ioKBrdClr
	staa	ioSAstrb2
	bra	LA05A
;
	db	$FF, $FF, $FF, $FF
	db	$FF, $FF, $FF
;
;===============================================================================
; MeasArray7 is the left-most, most signifcant digit
subShiftMeasArrayLeft:
	ldaa	MeasArray6
	staa	MeasArray7
	ldaa	MeasArray5
	staa	MeasArray6
	ldaa	MeasArray4
	staa	MeasArray5
	ldaa	MeasArray3
	staa	MeasArray4
	ldaa	MeasArray2
	staa	MeasArray3
	ldaa	MeasArray1
	staa	MeasArray2
	ldaa	MeasArray0
	staa	MeasArray1
	clr	MeasArray0
	rts
;===============================================================================
; MeasArray7 is the left-most, most signifcant digit
subShiftMeasArrayRight:
	ldaa	MeasArray1
	staa	MeasArray0
	ldaa	MeasArray2
	staa	MeasArray1
	ldaa	MeasArray3
	staa	MeasArray2
	ldaa	MeasArray4
	staa	MeasArray3
	ldaa	MeasArray5
	staa	MeasArray4
	ldaa	MeasArray6
	staa	MeasArray5
	ldaa	MeasArray7
	staa	MeasArray6
	clr	MeasArray7
	rts
;===============================================================================
; packs measurement digits into FormattedReading2-D for HPIB "packed" data output
;
subPackReading:
	ldaa	#$2B		; ASCII "+"
	cmpa	MeasPolaritySign
	bne	LA0EF
	clr	X01CC		; if MeasPolaritySign = "+"
	bra	LA0F4
;
LA0EF:				; sign is not "+"
	ldaa	#$02
	staa	X01CC		; bit2 is polarity, 1 = negative
LA0F4:
	ldaa	MeasArray7	; called "overrange" digit in manual
	cmpa	#$01
	beq	LA130		; branch if 1st digit = 1
	bsr	subShiftMeasArrayRight	; otherwise shift digits down one position
	ldaa	#$2B		; ASCII "+"
	cmpa	MeasExponentSign
	bne	LA110		; branch if negative exponent
	ldab	MeasExponent	; if MeasExponentSign = "+"
	incb
	stab	X01CE		; = exponent+1
	clr	X01CD
	bra	LA147
;
LA110:				; negative exponent
	ldaa	MeasExponent
	tsta
	bne	LA122
	ldab	#$01		; if MeasExponent = 0, 01CE = 01, 01CD = 80
	stab	X01CE
	ldaa	#$80
	staa	X01CD
	bra	LA147
;
LA122:
	ldaa	MeasExponent	; != 0
	deca
	staa	X01CE		; exponent -1
	ldaa	#$80
	staa	X01CD		; if MeasExponent != 0, 01CE = MeasExponent-1, 01CD = 80
	bra	LA147
;
LA130:				; first digit is 1
	ldaa	MeasExponent
	staa	X01CE
	ldaa	#$2B		; ASCII "+"
	cmpa	MeasExponentSign
	bne	LA142
	clr	X01CD		; if MeasExponentSign = "+", 01CE = MeasExponent, 01CD = 00
	bra	LA147
;
LA142:
	ldaa	#$80
	staa	X01CD	; if MeasExponentSign != "+", 01CE = MeasExponent, 01CD = 80

LA147:
	ldaa	X01CE
	asla
	asla
	oraa	X01CC	; = 00 if MeasPolaritySign = "+", else 02
	oraa	X01CD	; = 00 or 80
	oraa	MeasArray7
	staa	FormattedReading2

	; above constructs the 1st packed byte:
	;	bit7: 	exponent sign, 1 = -
	; 	bit6-2: exponent digit
	;	bit1: 	polarity sign, 1 = -
	;	bit0: 	overrange if 1

	ldaa	MeasArray6	; packs 6 digits into three bytes
	asla
	asla
	asla
	asla
	oraa	MeasArray5
	staa	FormattedReading3
	ldaa	MeasArray4
	asla
	asla
	asla
	asla
	oraa	MeasArray3
	staa	FormattedReading4
	ldaa	MeasArray2
	asla
	asla
	asla
	asla
	oraa	MeasArray1
	staa	FormattedReading5
	ldaa	MeasArray7
	tsta
	bne	LA18D
	jsr	subShiftMeasArrayLeft	; if MeasArray7 = 0, shift values in array up one position.
LA18D:
	rts

;===============================================================================
; Formats reading into character FormattedReading including signs, exponent and decimal.
; copies bytes from 01D1-01D8 (MeasArray) converting to ASCII.
; One byte contains ASCII ".", and it is copied too.
;
subFormatReadingForHPIB:
	ldaa	MeasPolaritySign
	staa	FormattedReading0	; 1st byte of formatted reading, the polarity
	ldaa	#$01
	staa	x01B0
LA19B:	;--- begin loop for each digit
	ldaa	x01B0	; loop counter index, 1-8
	cmpa	#$08
	bhi	LA1CC
	ldaa	#$B8
	ldab	#$01
	adda	x01B0
	adcb	#$00
	staa	x0049
	stab	x0048	; 01B9 to 01C1, FormattedReading1-9
	ldaa	#$08
	suba	x01B0	; A = 7...0
	clrb
	adda	#$D1
	adcb	#$01	; base address of MeasArray
	staa	x004D
	stab	x004C	; 01D8 to 01D1 (MeasArray)
	ldx	x004C
	ldaa	$00,x
	oraa	#$30	; turn on bits b4-5, converts BCD to ASCII digits
	ldx	x0048
	staa	$00,x
	inc	x01B0
	bra	LA19B
	;--- end loop
;
	; Array MeasArray has BCD digits and an ASCII ".".  Previous loop
	; copied values adding 30 to each to convert numbers to characters, and
	; added 30 to the decimal point.  This loop goes through all the digits
	; again and puts "." into the formatted array.
LA1CC:	;--- begin loop
	clr	x01CA
LA1CF:
	ldaa	x01CA	; loop counter index, 0-7
	cmpa	#$07
	bhi	LA209
	ldaa	#$D1
	ldab	#$01	; base address of MeasArray
	adda	x01CA
	adcb	#$00
	staa	x0049
	stab	x0048
	ldx	x0048	; 01D1 to 01D8 (MeasArray)
	ldaa	$00,x
	cmpa	#$2E	; ASCII "."
	bne	LA204
	ldab	#$08	; if current byte is decimal point
	subb	x01CA	; B = 8...1
	clra
	addb	#$B8
	adca	#$01
	stab	x004F
	staa	x004E
	ldaa	#$2E	; ASCII "."
	ldx	x004E	; place decimal in 01B9 to 01C1 array
	staa	$00,x
LA204:
	inc	x01CA
	bra	LA1CF
	;--- end loop
;
LA209:
	ldaa	MeasExponentSign
	staa	FormattedReading10
	ldaa	#$30
	oraa	MeasExponent
	staa	FormattedReading11
	rts
;===============================================================================
; sends a write pulse to clock a byte into display controller chip.
; (maybe two are necessary for timing?).
subStrobeDisplay:
	ldaa	#$01
	staa	ioDsplyStrb
	ldaa	#$01
	staa	ioDsplyStrb
	rts
;---------------------------------
; sends a write pulse to clock a byte into display controller chip.
subStrobeAnnunciator:
	ldaa	#$01
	staa	ioAnnunc
	ldaa	#$01
	staa	ioAnnunc
	rts
;===============================================================================
; sends all the data to update the Annunciator LEDs.  Controller chip blanks
; all output until an 8th byte is written.  Any extra writes are ignored.
; Annunciator also controls the exponent sign.
;
subWriteAnnunc:
	ldaa	#$B0		; data is coming command to chip
	staa	ioDAdata
	bsr	subStrobeAnnunciator
	ldaa	AnnuncByte0
	staa	ioDAdata
	bsr	subStrobeAnnunciator
	ldaa	AnnuncByte1
	staa	ioDAdata
	bsr	subStrobeAnnunciator
	ldaa	AnnuncByte2
	staa	ioDAdata
	bsr	subStrobeAnnunciator
	ldaa	AnnuncByte3
	staa	ioDAdata
	bsr	subStrobeAnnunciator
	ldaa	AnnuncByte4
	staa	ioDAdata
	bsr	subStrobeAnnunciator

	; ***** MODDED don't show exponent sign if 7 digit mode *****
	ldaa	flag7Digits	; if 7 digit mode
	bne	LA270		; branch around code that sets exponent sign
	; end mod

	ldaa	flagDisplayHasExponent
	coma
	rora
	bcc	LA271		; branch if there is an exponent sign to display
LA270:				; new label
	ldaa	#$10		; code for display nothing
	staa	ioDAdata
	bra	LA292
;
LA271:				; these will be the exponent signs
	ldaa	#$2B		; ASCII "+"
	cmpa	DisplayExponentSign
	bne	LA27F
	ldab	#$17		; code for display "+"
	stab	ioDAdata
	bra	LA292
;
LA27F:
	ldaa	#$2D		; ASCII "-"
	cmpa	DisplayExponentSign
	bne	LA28D
	ldab	#$14		; code for display "-"
	stab	ioDAdata
	bra	LA292
;
LA28D:
	ldaa	#$10
	staa	ioDAdata
LA292:
	bsr	subStrobeAnnunciator
	ldaa	AnnuncByte6
	staa	ioDAdata
	bsr	subStrobeAnnunciator
	bsr	subStrobeAnnunciator
	rts
;===============================================================================
; fills AnnuncByte0-3, which set the state of all the front panel LEDs except
; for MATH, LISTEN, SRQ, TALK, REMOTE and FILTER (which are done in subSetAnnuncByte4).
;
LA31B:			; rearranged some branches for readability
	rts

subSetAnnuncBytes123:
	ldaa	flagTestMode
	tsta
	bne	LA31B		; if flagTestMode != 0, rts
	ldab	IGCmdRegister0
	lsrb
	lsrb
	lsrb
	lsrb
	lsrb		; IGCmdRegister0 bit5-7 now in bit0-2, max value is 7
	clra
	addb	#$9B	; offset = 0xF79B, possible range F79B to F7A2 -> data
	adca	#$F7		; range in ROM
	stab	x004D
	staa	x004C
	ldaa	IGCmdRegister1
	lsra
	ldab	IGCmdRegister0
	aslb
	aslb
	anda	#$08
	ldx	x004C
	oraa	$00,x	; values are $10, $14, $12, $11, $50, $30, $00, $18
	andb	#$40
	staa	x0054
	orab	x0054
	stab	AnnuncByte0	; data for 7 front panel LEDs
	ldaa	IGCmdRegister1
	lsra
	lsra
	lsra
	lsra
	lsra
	lsra		; IGCmdRegister1 bit6-7 now in bit0-1, max value is 3
	clrb
	adda	#$A2
	adcb	#$F7
	staa	x004B
	stab	x004A	; F7A2 to F7A5
	ldaa	IGCmdRegister4
	lsra
	lsra
	ldab	IGCmdRegister0
	andb	#$01
	ldx	x004A
	orab	$00,x	; values are $18, $00, $30, $50
	anda	#$02
	stab	x0050
	oraa	x0050
	staa	AnnuncByte1	; data for 7 front panel LEDs
	ldaa	#$0F
	anda	IGCmdRegister2
	staa	InguardStatus
	clrb
	adda	#$87
	adcb	#$F7
	staa	x004B
	stab	x004A
	ldaa	flagX0121
	asla
	asla
	anda	#$20
	ldx	x004A
	oraa	$00,x
	staa	AnnuncByte2
	ldaa	#$91
	ldab	#$F7
	adda	InguardStatus
	adcb	#$00
	staa	x0049
	stab	x0048
	ldaa	flagX0121
	anda	#$01
	asla
	asla
	ldx	x0048
	oraa	$00,x
	ldab	#$07
	andb	IGCmdRegister1
	staa	x004E
	clra
	cmpb	#$03
	bne	LA34C
	deca
LA34C:
	anda	#$10
	oraa	x004E
	staa	AnnuncByte3
	rts

;===============================================================================
; Updates the Display digits and Annunciator LEDs. Also determines signs and
; decimal points to display.
; inputs: X010A
;
; Coding for leading digit, AnnuncByte6:
;	- bits 0,1,2 = 010b (02) --> minus sign
;	- bits 0,1,2 = 111b (07) --> plus sign
;	- bits 4,3 = 01b (08) --> digit "1" on
;	- bits 4,3 = 10b (10) --> digit "1" off
;	- bit 5 on (20) --> decimal point displayed

subAnnuncNDisplayUpdate:

	ldaa	#$40
	anda	IGCmdRegister1
	tsta
	bne	LA361		; branch if bit6 = 1
	clr	ioIOreset
LA361:
	ldaa	flagDispNeedUpdate
	rora
	bcc	LA3CD		; if flagDispNeedUpdate = 0, return
	sei			; disable IRQ interrupts
	ldaa	#$10
	staa	ioHPIB_r0	; turn off interrupts from HPIB
	ldaa	X010A		; only set to 01 before first routine call from sub089
	cmpa	#$01
	bne	LA37A		; branch if != 1
	ldab	ioRateLite	; reading this port must strobe the enable line, toggling the LED?
	stab	X01CC		; why store this?  01CC is overwritten below.
LA37A:
	clr	X010A
	ldaa	#$2E		; ASCII "."
	cmpa	DisplayArray6
	bne	LA38B
	ldab	#$01
	stab	x01CA
	bra	LA38E
;
LA3CD:
	rts
LA38B:
	clr	x01CA		; x01CA = 0 if first full digit != ".", else 1
LA38E:
	ldaa	flagDisplayArrayHasNoDecimal
	tsta
	bne	LA39B
	ldab	#$06		; if flagDisplayArrayHasNoDecimal = 0
	stab	X01CC
	bra	LA3A0
LA39B:
	ldaa	#$07
	staa	X01CC
LA3A0:
	ldaa	#$D9
	ldab	#$01		; 01D9 is base of DisplayArray0
	adda	X01CC		; = 6 or 7
	adcb	#$00
	staa	x0049
	stab	x0048
	ldx	x0048
	ldaa	$00,x		; most signifcant digit, DisplayArray6 or DisplayArray7
	cmpa	#$01
	beq	LA412		; branch if a leading "1"
	; a leading "1" not to be displayed
	ldab	#$2B		; ASCII "+"
	cmpb	DisplayPolaritySign
	bne	LA3DD		; branch if not "+"
	ldaa	x01CA		; 0 or 1
	adda	#$02
	clrb
	adda	#$5C		; 5E or 5F
	adcb	#$F9
	staa	x0051
	stab	x0050
	ldx	x0050		; F95E or F95F
	ldaa	$00,x		; 17 or 37 -> "+" or "+."
	staa	AnnuncByte6	; +/-/1 digit on display
	jmp	LA462

LA3DD:
	ldaa	#$2D		; ASCII "-"
	cmpa	DisplayPolaritySign
	bne	LA3FB
	ldab	x01CA		; 0 or 1
	addb	#$0A		; 0A or 0B
	clra
	addb	#$5C		; 66 or 67
	adca	#$F9
	stab	x004D
	staa	x004C
	ldx	x004C
	ldaa	$00,x		; F966 = 12, F967 = 32 -> "-" or "-."
	staa	AnnuncByte6
	bra	LA462
;
LA3FB:				; arrive here if no polarity sign
	ldaa	x01CA		; 0 or 1
	adda	#$06		; 6 or 7
	clrb
	adda	#$5C
	adcb	#$F9
	staa	x004B
	stab	x004A
	ldx	x004A
	ldaa	$00,x		; F962 = 10, F963 = 30 -> " " or "." ?
	staa	AnnuncByte6
	bra	LA462
;
LA412:	; arrive here if a "1" to be displayed.
	ldaa	#$2B		; ASCII "+"
	cmpa	DisplayPolaritySign
	bne	LA42F
	ldab	#$5C
	ldaa	#$F9
	addb	x01CA		; 0 or 1
	adca	#$00
	stab	x004B
	staa	x004A
	ldx	x004A
	ldaa	$00,x		; F95C = 0F, F95D = 2F -> "+1" or "+1." ?
	staa	AnnuncByte6
	bra	LA462
;
LA42F:
	ldaa	#$2D		; ASCII "-"
	cmpa	DisplayPolaritySign
	bne	LA44D
	ldab	x01CA		; 0 or 1
	addb	#$08
	clra
	addb	#$5C
	adca	#$F9
	stab	x004D
	staa	x004C
	ldx	x004C
	ldaa	$00,x		; F964 = 0A, F965 = 2A -> "-1" or "-1." ?
	staa	AnnuncByte6
	bra	LA462
;
LA44D:
	ldaa	x01CA		; 0 or 1
	adda	#$04
	clrb
	adda	#$5C
	adcb	#$F9
	staa	x004B
	stab	x004A
	ldx	x004A
	ldaa	$00,x		; F960 = 08, F961 = 28 -> "1" or "1." ?
	staa	AnnuncByte6

	; now have overrange 1 and polarity sign determined.
LA462:
	jsr	subWriteAnnunc
	ldaa	#$90		; bit7 means mode command to display chip, bit4 means data coming, bit6 means display hex data
	staa	ioDAdata
	jsr	subStrobeDisplay
	ldaa	flagDisplayArrayHasNoDecimal
	cmpa	#$01
	bne	LA497
	clr	x01CA
	bra	LA49C
;
LA497:
	ldaa	#$01
	staa	x01CA		; =0 if flagDisplayArrayHasNoDecimal = 1 else 1
LA49C:
	ldaa	#$2E		; ASCII "."
	cmpa	DisplayArray6
	bne	LA4A8
	ldab	#$01
	stab	x01CA
LA4A8:
	;--- loop begin ---
	ldaa	x01CA
	staa	X01CC
LA4AE:
	ldaa	X01CC		; loop counter, starts at 0 or 1 to 5
	cmpa	#$05
	bhi	LA4E6		; exit loop if 6
	ldaa	X01CC
	inca			; A = 1 or 2 to 6
	ldab	#$06
	staa	x0048
	subb	x0048		; B = 5 to 0
	clra
	addb	#$D9
	adca	#$01		; 01D9 is base of DisplayArray
	stab	x004D
	staa	x004C
	ldx	x004C
	ldaa	$00,x		; 0x01DE to D9, DisplayArray5 to 0
	cmpa	#$2E		; ASCII "."
	bne	LA4DA		; branch if not decimal point

	; display digit with decimal point
	clr	X01CD		; bit5 off turns decimal point on
	bsr	subDisplayDigit	; writes DisplayArray[X01CC] to display with decimal if X01CD = 0
	inc	X01CC		; this position of DisplayArray contained the decimal point, so go to next
	bra	LA4E1

LA4DA:	; display digit without decimal point
	ldaa	#$10
	staa	X01CD		; bit5 on turns decimal point off
	bsr	subDisplayDigit	; writes DisplayArray[X01CC] to display with decimal if X01CD = 0
LA4E1:
	inc	X01CC
	bra	LA4AE
	;--- loop end ---
;
LA4E6:
	ldaa	#$2E		; ASCII "."
	cmpa	DisplayArray0	; least signifcant position
	beq	LA4FA
	ldab	#$06
	stab	X01CC
	ldaa	#$10		; bit5 on turns decimal point off
	staa	X01CD
	jsr	subDisplayDigit	; writes DisplayArray[X01CC] to display with decimal if X01CD = 0

LA4FA:
	;***** MODDED substitute 7th digit for exponent *****
	ldaa	flag7Digits
	beq	LA4FB		; if flag not set, go to regular exponent code
	ldaa	#$10		; decimal point off
	oraa	Digit7
	staa	ioDAdata	; substitute our digit for exponent
	bra	LA50F
	; end mod

LA4FB:				; new label
	ldaa	flagDisplayHasExponent
	rora
	bcc	LA50A		; branch if no exponent
	; code when there's an exponent
	ldaa	#$10		; decimal point off
	oraa	DisplayExponent
	staa	ioDAdata
	bra	LA50F

	; code when there's no exponent
LA50A:
	ldaa	#$1F		; F means blank digit, 1 means decimal point off
	staa	ioDAdata

LA50F:
	jsr	subStrobeDisplay
	jsr	subStrobeDisplay
	ldaa	AnDUpdatedFlag
	rora
	bcc	LA522
	cli			; clear keyboard interrupt
	ldaa	HPIBIntrMask
	staa	ioHPIB_r0	; restore HPIB interrupts
LA522:
	rts

;===============================================================================
; Writes one digit to display, with setting decimal point on or off.
; It's wired so the first digit will be displayed on DS2, the left-most
; digit, and last is DS9, the exponent digit.
; Inputs X01CC (digit number), X01CD (decimal point mask)
subDisplayDigit:

	; ***** MODDED if we overwrite the exponent with 7th digit, invert decimals to indicate this *****
	ldaa	flagDisplayHasExponent
	beq	LA525		; skip if there's no exponent
	ldaa	flag7Digits
	beq	LA525		; skip if not in 7 digit mode
	ldaa	X01CD
	beq	LA524		; branch if 0
	clr	X01CD		; if was 10, set to 0
	bra	LA525
LA524:
	ldaa	#$10
	staa	X01CD		; if it was 0, make it 10
	; end mod

LA525:				; new label
	ldaa	#$06
	suba	X01CC		; 0-6
	clrb
	adda	#$D9
	adcb	#$01		; 01D9 is base of DisplayArray
	staa	x004B
	stab	x004A
	ldx	x004A
	ldaa	$00,x		; 01D9-01DF, DisplayArray0-6
	oraa	X01CD		; turns decimal point on (if 00) or off (if 10)
	staa	ioDAdata
	jsr	subStrobeDisplay
	rts
;===============================================================================
; fills AnnuncByte4 which sets the front panel LEDs for MATH, LISTEN, SRQ,
; TALK, REMOTE and FILTER.

subSetAnnuncByte4:
	ldaa	#$10
	anda	flagHPIBOutput
	tsta
	beq	LA54B	; branch if bit4 = 0
	ldaa	#$40
	anda	ioHPIB_r5	; bit6 is service request state, = 1 if meter has requested service
	tsta
	bne	LA54B	; branch if service requested
	ldaa	#$04
	anda	ioHPIB_r1	; bit2 set if HPIB serial poll function is active
	tsta
	bne	LA54B	; branch if HPIB serial poll function is active
	ldaa	#$EF
	anda	flagHPIBOutput
	staa	flagHPIBOutput	; clear bit4
	clr	ioHPIB_r5	; clear serial poll status and request for service from meter
LA54B:
	ldaa	#$40
	anda	ioHPIB_r1	; bit6 set if meter in HPIB Remote mode
	tsta
	bne	LA55B	; branch if in remote mode
	ldaa	#$10
	oraa	IGCmdRegister4
	staa	IGCmdRegister4	; set bit4
LA55B:
	ldaa	flagTestMode
	tsta
	bne	LA5B9
	ldab	#$40
	andb	ioHPIB_r1	; bit6 set if meter in HPIB Remote mode
	lsrb
	lsrb
	lsrb
	lsrb
	lsrb			; now bit1 = 1 if meter in Remote mode
	ldaa	ioHPIB_r2	; Address Status register
	lsra
	lsra
	lsra
	staa	x004E		; LSB = 1 if meter in Talker Active State
	ldaa	flagHPIBOutput	; bit4 = 1 if HPIB Service Requested
	lsra
	staa	x0050		; bit3 = 1 if HPIB Service Requested
	ldaa	IGCmdRegister1
	asla
	asla
	staa	x0052
	ldaa	ioHPIB_r2
	anda	#$04		; A = 04 if meter in Listener Active state
	stab	x004C		; B = 02 if meter in Remote mode
	oraa	x004C		; A = Listener Active (04) | Remote (02)
	ldab	x004E
	andb	#$01		; B = 01 if meter in Talker Active State
	staa	x0056		; x0056 = Listener Active (04) | Remote (02)
	orab	x0056		; B = Talker Active (01) | Remote (02) | Listener Active (04)
	ldaa	x0050
	anda	#$08		; bit3 = 1 if HPIB Service Requested
	stab	x005A
	oraa	x005A		; A = Talker Active (01) | Remote (02) | Listener Active (04) | Service Requested (08)
	ldab	#$0F
	andb	IGCmdRegister2		; lower nibble
	staa	x005E
	clra			; A = 0
	tstb
	bne	LA5AA
	deca			; if IGCmdRegister2 lower nibble = 0, A = FF, else 00
LA5AA:
	anda	#$10		; A = 10 if IGCmdRegister2 lower nibble = 0
	oraa	x005E		; A = Talker Active (01) | Remote (02) | Listener Active (04) | Service Requested (08) | IGCm
	ldab	x0052
	andb	#$20
	staa	x0066
	orab	x0066
	stab	AnnuncByte4
LA5B9:
	rts
;===============================================================================
;
sub010:
	ldaa	flagX0121
	rora
	bcc	LA5E2	; branch if flagX0121 bit0 = 0
	ldaa	X012D
	oraa	X012C
	oraa	X012E
	tsta
	beq	LA5D8	; branch if X012C,D,E = 0
	ldaa	#$02
	oraa	flagX0121
	staa	flagX0121	; set bit1
	rts
;
LA5D8:
	ldaa	#$FD
	anda	flagX0121
	staa	flagX0121	; clear bit1
	rts
;
LA5E2:
	clr	X012C
	clr	X012D
	clr	X012E
	ldaa	#$08
	anda	IGCmdRegister1
	tsta
	beq	LA62C	; branch if IGCmdRegister1 bit3 = 0
	ldaa	#$02
	oraa	flagX0121
	staa	flagX0121	; set bit1
	ldaa	#$80
	anda	X0198
	clrb
	tsta
	beq	LA605	; branch if X0198 bit7 = 0
	decb
LA605:
	ldaa	flagTestMode
	stab	x004A	; = 00 if X0198 bit7 = 0, else FF
	clrb
	tsta
	beq	LA60F	; branch if flagTestMode = 00
	decb
LA60F:			; B = 0 if flagTestMode = 00, else FF
	orab	x004A
	rorb
	bcc	LA61B	; branch if X0198 bit7 = 0 and flagTestMode = 00
	ldab	#$08
	stab	X012D
	rts
;
LA61B:
	ldaa	#$06
	staa	X012D
	ldaa	#$50
	staa	X012E
	rts		; X012D = 06, X012E = 50 if X0198 bit7 = 0 and flagTestMode = 00
;			; else X012D = 08, X012E = 00

LA62C:			; IGCmdRegister1 bit3 = 0
	ldaa	flagTestMode
	tsta
	beq	LA641	; branch if flagTestMode = 00
	ldab	#$80
	stab	X012E
	ldaa	#$02
	oraa	flagX0121
	staa	flagX0121
	rts		; if flagTestMode != 00, X012E = 80 and flagX0121 bit1 is set
;
LA641:			; flagTestMode = 00
	ldaa	#$80
	anda	X0198
	tsta
	beq	LA65D	; branch if X0198 bit7 = 0
	ldaa	#$60
	staa	X012E
	ldaa	#$02
	oraa	flagX0121
	staa	flagX0121
	rts		; if flagTestMode = 00 and X0198 bit7 = 1, X012E = 60 and flagX0121 bit1 is set
;
LA65D:			; flagTestMode = 00, X0198 bit7 = 0
	ldaa	#$10
	anda	X0198
	clrb
	tsta
	beq	LA667	; branch if X0198 bit4 = 0
	decb
LA667:
	ldaa	X078C
	stab	x004A	; if X0198 bit4 = 0, x004A = 00 else FF
	clrb
	cmpa	#$03
	bcs	LA672	; branch if X078C > 03
	decb
LA672:
	andb	x004A
	rorb
	bcc	LA6AC	; branch if X0198 bit4 = 0 or X078C > 03
	ldab	#$02	; X0198 bit4 = 1 and X078C <= 03
	orab	flagX0121
	stab	flagX0121	; flagX0121 bit1 is set
	ldaa	#$03
	cmpa	X078C
	bne	LA68D
	ldab	#$01
	stab	X012E	; if X078C = 03, X012E = 01
	rts
;
LA68D:			; X078C < 03
	ldaa	#$04
	cmpa	X078C
	bne	LA6A0
	ldab	#$08
	stab	X012E
	rts

LA6A0:
	ldaa	#$80
	staa	X012E
	rts

;
LA6AC:
	ldaa	#$FD
	anda	flagX0121
	staa	flagX0121
	rts

;===============================================================================
;

sub011:
	ldaa	#$80
	anda	x0119
	staa	X011B
	ldaa	#$80
	anda	X011A
	staa	x011C
	ldaa	x011C
	cmpa	X011B
	bne	LA6E3
	ldab	x0119
	cmpb	X011A
	bcc	LA6DE
	ldaa	#$01
	staa	InguardStatus
	bra	LA6E1
;
LA6DE:
	clr	InguardStatus
LA6E1:
	bra	LA6F3
;
LA6E3:
	ldaa	X011B
	tsta
	bne	LA6EE
	clr	InguardStatus
	bra	LA6F3
;
LA6EE:
	ldaa	#$01
	staa	InguardStatus
LA6F3:
	rts

;===============================================================================
; used when meter is in Auto range
sub012:
	ldaa	flagOverrange_Maybe
	tsta
	beq	LA72E
	ldab	X078C
	cmpb	X019A
	bcc	LA724
	ldaa	#$04
	anda	X018B
	tsta
	bne	LA70F
	inc	X018B
LA70F:
	ldaa	#$02
	adda	IGCmdRegister0
	staa	IGCmdRegister0
	clr	flagOverrange_Maybe
	ldaa	#$0C
	oraa	X018B
	staa	X018B	; set bit2-3
	jmp	LC9D2
;
LA724:
	ldaa	#$F7
	anda	X018B
	staa	X018B	; clear bit3
	jmp	LC9D2
;
LA72E:
	ldaa	X019B
	cmpa	AccumRegister6
	bne	LA740
	ldab	#$E7
	andb	X018B
	stab	X018B
	bra	LA784
;
LA740:
	ldaa	X019B
	deca
	cmpa	AccumRegister6
	bne	LA77C
	ldaa	AccumRegister1
	clrb
	cmpa	#$01
	bne	LA752
	decb
LA752:
	ldaa	#$F0
	anda	AccumRegister2
	stab	x004C
	clrb
	tsta
	bne	LA75E
	decb
LA75E:
	andb	x004C
	rorb
	bcc	LA772
	ldaa	#$10
	oraa	X018B
	staa	X018B	; set bit4
	bra	LA77A
;
LA772:
	ldaa	#$E7
	anda	X018B
	staa	X018B	; clear bit3
LA77A:
	bra	LA784
LA7F3:
	jmp	LA822
;
LA77C:
	ldaa	#$10
	oraa	X018B
	staa	X018B	; set bit4
LA784:
	ldaa	#$10
	anda	X018B
	tsta
	beq	LA7F3	; branch if bit4 = 0
	ldaa	X078C
	cmpa	X0199
	bls	LA7F3
	ldab	#$03
	andb	X018B
	cmpb	#$03
	bcc	LA7F3
	ldab	IGCmdRegister0
	subb	#$02
	stab	IGCmdRegister0
	ldaa	AccumRegister6
	staa	x0119
	ldaa	X019B
	deca
	staa	X011A
	jsr	sub011
	ldaa	InguardStatus
	clrb
	cmpa	#$01
	bne	LA7C3
	decb
LA7C3:
	ldaa	X078C
	deca
	stab	x0048
	clrb
	cmpa	X0199
	bls	LA7D0
	decb
LA7D0:
	andb	x0048
	rorb
	bcc	LA816
	ldaa	IGCmdRegister0
	suba	#$02
	staa	IGCmdRegister0
	dec	X011A
	jsr	sub011
	ldaa	InguardStatus
	clrb
	cmpa	#$01
	bne	LA7EC
	decb
LA7EC:
	ldaa	X078C
	suba	#$02
	stab	x0048
	clrb
	cmpa	X0199
	bls	LA7FF
	decb
LA7FF:
	andb	x0048
	rorb
	bcc	LA816
	ldaa	IGCmdRegister0
	suba	#$02
	staa	IGCmdRegister0
LA816:
	ldaa	#$FB
	anda	X018B
	oraa	#$08
	staa	X018B	; clear bit2 & set bit3
	rts
;
LA822:
	ldaa	#$E7
	anda	X018B
	staa	X018B	; clear bit3
	rts

;
;===============================================================================
; Causes display digits to be blanked.
subBlankMeasArray:
	ldaa	#$0F		; 0F will cause display digits to be blanked
	staa	MeasPolaritySign
	staa	MeasArray7
	staa	MeasArray6
	staa	MeasArray5
	staa	MeasArray4
	staa	MeasArray3
	staa	MeasArray2
	staa	MeasArray1
	staa	MeasArray0

	staa	Digit7		;***** MODDED clears 7th digit if being displayed

	clr	MeasExponent
	clr	flagMeasHasExponent
	rts
;---------------------------------
; Issue HPIB Service Request if caller parameter matches bit in IGCmdRegister3
subHPIBRequestService:
	ldaa	HPIBSerialPollStatus		; parameter from caller, possible values 01,02,04,08,10,12,20,80
	anda	IGCmdRegister3
	staa	x01CA
	ldaa	x01CA
	tsta
	beq	LA886		; if A = 00, don't request service
	oraa	#$40		; bit6 = 1 for meter to request service
	oraa	ioHPIB_r5	; keep remaining status bits
	staa	ioHPIB_r5	; request service
	ldaa	#$10
	oraa	flagHPIBOutput
	staa	flagHPIBOutput	; set bit4, means HPIB service requested
LA886:
	rts
;---------------------------------
; appears to format digits in MeasArray and set sign
; used when meter is in Auto range
sub015:
	clr	x01CA		; loop index
LA88C:	;--- start loop
	ldaa	x01CA
	cmpa	#$03		; loop over 0,1,2,3
	bhi	LA8AF
	ldaa	#$D1
	ldab	#$01		; base address of MeasArray
	adda	x01CA
	adcb	#$00
	staa	x0049
	stab	x0048
	ldx	x0048
	ldaa	$00,x
	cmpa	#$0F		; if MeasArray0-4 = 0F, make it 00
	bne	LA8AA
	clr	$00,x
LA8AA:
	inc	x01CA
	bra	LA88C
	;--- end loop
;
LA8AF:	; take care of 0F in exponent and sign
	ldaa	#$07
	staa	x01CA
	ldaa	#$0F
	cmpa	MeasExponentSign
	bne	LA8C0
	ldab	#$2B		; ASCII "+" if it was 0F
	stab	MeasExponentSign
LA8C0:
	ldaa	#$0F
	cmpa	MeasExponent
	bne	LA8CA
	clr	MeasExponent	; clear if it was 0F

LA8CA:	;--- loop start, from most significant MeasArray
	; to least signifcant, break if MeasArray != 00 or 0F
	; (i.e., find 1st non-zero digit?
	ldaa	#$D1
	ldab	#$01		; base address of MeasArray
	adda	x01CA		; = 7,6,..0, count down from most to least significant digit
	adcb	#$00
	staa	x0049
	stab	x0048
	ldx	x0048
	ldaa	$00,x		; 1st iteration at MeasArray7
	clrb
	cmpa	#$0F
	bne	LA8E1
	decb
LA8E1:
	stab	x004A		; = FF if MeasArray = 0F, else00
	clrb
	tsta
	bne	LA8E8
	decb
LA8E8:				; B = FF if MeasArray = 00, else 00
	orab	x004A
	ldaa	x01CA		; loop index
	stab	x004E		; = FF if MeasArray = 00 or = 0F, else 00
	clrb
	cmpa	#$FF
	bne	LA8F5		; brach if index not FF, i.e., >= 0
	decb
LA8F5:				; B = FF if index FF, else 00
	comb			; B = 00 if index FF, else FF
	andb	x004E		; = FF if index != FF and (MeasArray = 00 or 0F), else 00
	rorb
	bcc	LA905		; exit loop if index = FF or MeasArray != 00 or 0F
	dec	x01CA
	bra	LA8CA
	;--- loop end
;
LA905:
	ldaa	#$D1
	ldab	#$01	; base address of MeasArray
	adda	x01CA	; 1st non 00 or 0F digit
	adcb	#$00
	staa	x0049
	stab	x0048
	ldx	x0048
	ldaa	$00,x
	cmpa	#$2E	; ASCII "."
	bne	LA96C	; branch if digit is not decimal point
	dec	x01CA	; go to next lower significant digit

LA91D:	;--- loop, appears to adjust exponent
	ldaa	#$D1
	ldab	#$01	; base address of MeasArray
	adda	x01CA
	adcb	#$00
	staa	x0049
	stab	x0048
	ldx	x0048
	ldaa	$00,x	; 1st digit to right of decimal point
	clrb
	tsta
	bne	LA933	; branch if not a 0
	decb
LA933:			; B = 00 if leading digit != 0, else FF
	ldaa	x01CA
	stab	x004A
	clrb
	cmpa	#$FF
	bne	LA93E
	decb
LA93E:			; B = 00 if index >= 0, else FF
	comb		; B = FF if index >= 0, else 00
	andb	x004A
	rorb
	bcc	LA9D3	; branch if leading digit != 0 or index < 0
	dec	x01CA
	ldaa	MeasExponent
	tsta
	bne	LA952	; branch if exponent != 0
	ldab	#$2D	; ASCII "-"
	stab	MeasExponentSign
LA952:
	ldaa	#$2B	; ASCII "+"
	cmpa	MeasExponentSign
	bne	LA95E
	dec	MeasExponent
	bra	LA968
;
LA95E:
	ldaa	#$2D	; ASCII "-"
	cmpa	MeasExponentSign
	bne	LA968
	inc	MeasExponent
LA968:
	bra	LA91D
	;--- end loop

LA9D3:
	jmp	LAA3F
;
	;--- loop, apears to also adjust exponent
LA96C:			; arrive here if leading digit is not decimal point
	ldaa	#$D1
	ldab	#$01	; base address of MeasArray
	adda	x01CA
	adcb	#$00
	staa	x0049
	stab	x0048
	ldx	x0048
	ldaa	$00,x
	clrb
	cmpa	#$09
	bhi	LA983
	decb
LA983:
	andb	#$FF
	ldaa	x01CA
	stab	x004C
	clrb
	cmpa	#$FF
	bne	LA990
	decb
LA990:
	comb
	andb	x004C
	rorb
	bcc	LA9C7
	dec	x01CA
	ldaa	MeasExponent
	tsta
	bne	LA9A4
	ldab	#$2B	; ASCII "+"
	stab	MeasExponentSign
LA9A4:
	ldaa	#$2B	; ASCII "+"
	cmpa	MeasExponentSign
	bne	LA9B0
	inc	MeasExponent
	bra	LA9C5
;
LA9B0:
	ldaa	#$2D	; ASCII "-"
	cmpa	MeasExponentSign
	bne	LA9C5
	dec	MeasExponent
	ldaa	MeasExponent
	tsta
	bne	LA9C5
	ldab	#$2B	; ASCII "+"
	stab	MeasExponentSign
LA9C5:
	bra	LA96C
	;--- end loop
;
LA9C7:
	clr	X01CC
LA9CA:
	ldaa	X01CC
	cmpa	#$03
	bhi	LA9F2		; loop over 0,1,2,3
	ldaa	#$D1
	ldab	#$01	; base address of MeasArray
	adda	X01CC
	adcb	#$00
	staa	x0049
	stab	x0048
	ldx	x0048
	ldaa	$00,x
	cmpa	#$0F
	bne	LA9ED
	clr	$00,x		; change values 0F to 00
LA9ED:
	inc	X01CC
	bra	LA9CA
;
LA9F2:
	ldaa	#$D1
	ldab	#$01	; base address of MeasArray
	adda	x01CA
	adcb	#$00
	staa	x0049
	stab	x0048
	ldx	x0048
	ldaa	$00,x
	cmpa	#$2E	; ASCII "."
	bne	LAA3F	; branch if not "."

LAA07:	;--- loop moves digits up one place
	ldaa	x01CA
	deca
	clrb
	cmpa	#$FF
	bne	LAA11
	decb
LAA11:			; B = FF if x01CA != 0
	comb
	rorb
	bcc	LAA3C	; branch if B = 0, x01CA = 0
	ldab	#$D1
	staa	x0048
	ldaa	#$01
	addb	x01CA
	adca	#$00
	stab	x004F
	staa	x004E
	ldaa	x0048	; x0048 = x01CA - 1
	clrb
	adda	#$D1
	adcb	#$01	; base address of MeasArray
	staa	x0051
	stab	x0050
	ldx	x0050
	ldaa	$00,x	; @ 01D1 + x01CA - 1
	ldx	x004E
	staa	$00,x	; @ 01D1 + x01CA
	dec	x01CA
	bra	LAA07
	;--- end loop
LAA3C:
	clr	MeasArray0

LAA3F:
	ldaa	#$07
	staa	x01CA
LAA44:	;--- loop left justifies data in MeasArray
	ldaa	#$0F
	clrb
	cmpa	MeasArray7
	bne	LAA4D
	decb		; FF if MeasArray7 is blanked (0F)
LAA4D:
	ldaa	#$2E	; ASCII "."
	stab	x0048
	clrb
	cmpa	MeasArray7
	bne	LAA58
	decb
LAA58:			; B = 00 if MeasArray7 != 2E, else FF
	orab	x0048
	ldaa	MeasArray7
	stab	x004C	; = 00 if MeasArray7 != 0F or 2E
	clrb
	tsta
	bne	LAA64
	decb
LAA64:			; B = 00 if MeasArray7 != 00, else FF
	orab	x004C
	ldaa	x01CA
	stab	x0050	; = 00 if MeasArray7 != 0F or 2E or 00
	clrb
	cmpa	#$FF
	bne	LAA71	; branch if index >= 0
	decb
LAA71:			; B = 00 if index >= 0, else FF
	comb		; B = 00 if index < 0, else FF
	andb	x0050
	rorb
	bcc	LAA7F	; branch to rts if MeasArray7 != 0F or 2E or 00 or index <= 0
	jsr	subShiftMeasArrayLeft
	dec	x01CA
	bra	LAA44
	;--- loop end

LAA7F:
	rts

;===============================================================================
; returns InguardStatus bit3-0 or 5 in DecimalDisplayPosition
; uses X078A,C, flagTestMode
sub016:
	ldaa	flagTestMode	; possible values 0,1,3
	tsta
	beq	LAA97		; branch if flagTestMode = 0
	ldab	#$05
	stab	DecimalDisplayPosition
	ldaa	#$02
	staa	X078C		; if flagTestMode != 0, DecimalDisplayPosition = 5 and X078C = 02, else is set elsewhere
	clr	InguardStatus
	bra	LAAE4
;
LAA97:
	ldaa	#$0A
	clrb
	cmpa	X078A
	bne	LAAA0
	decb
LAAA0:				; B = FF if X078A = 0A
	ldaa	#$0C
	stab	x0048
	clrb
	cmpa	X078A
	bne	LAAAB
	decb
LAAAB:				; B = FF if X078A = 0C
	orab	x0048
	rorb
	bcc	LAACB		; branch if X078A != 0A or 0C
	ldab	#$AB		; X078A = 0A or 0C
	ldaa	#$F7
	addb	X078C		; may be 0-7
	adca	#$00
	stab	x004F
	staa	x004E
	ldx	x004E
	ldaa	$00,x
	; X078C =	0	1	2	3	4	5
	; A =		04	03 	35 	34	33 	65
	staa	InguardStatus
	anda	#$0F
	staa	DecimalDisplayPosition
	bra	LAAE4
;
LAACB:				; X078A != 0A or 0C
	ldaa	#$A6
	ldab	#$F7		; F7AB - F7A6 = 5, so X078C range 0-4?
	adda	X078C
	adcb	#$00
	staa	x0049
	stab	x0048
	ldx	x0048
	ldaa	$00,x
	; X078C =	0	1	2	3	4	5
	; A =		D4	06 	05 	04 	03	04
	staa	InguardStatus
	anda	#$0F
	staa	DecimalDisplayPosition


LAAE4:
	ldaa	#$F0
	anda	InguardStatus
	staa	InguardStatus	; clear bit3-0
	bpl	LAAF7		; branch if MSB = 0
	ldaa	#$FF
	bra	LAAF8
;
LAAF7:
	clra
LAAF8:				; A = 00 if InguardStatus bit7 = 0, else FF
	rora
	bcc	LAB07		; branch if InguardStatus bit7 = 0
	ldaa	#$2D		; ASCII "-"
	staa	MeasExponentSign
	ldaa	#$03
	staa	MeasExponent	; -3 must be only allowed negative exponent
	bra	LAB16
;
LAB07:
	ldaa	#$2B		; ASCII "+"
	staa	MeasExponentSign
	ldaa	InguardStatus
	lsra
	lsra
	lsra
	lsra
	staa	MeasExponent	; InguardStatus bits 6-4 become exponent when positive

LAB16:
	ldaa	#$0A
	clrb
	cmpa	X078A
	bne	LAB1F
	decb
LAB1F:				; B = FF if X078A = 0A
	ldaa	#$0C
	stab	x0048
	clrb
	cmpa	X078A
	bne	LAB2A
	decb
LAB2A:				; B = FF if X078A = 0C
	orab	x0048
	rorb
	bcc	LAB45		; branch if X078A != 0A or 0C
	ldab	#$51		; X078A = 0A or 0C
	ldaa	#$F9
	addb	X078C
	adca	#$00
	stab	x004F
	staa	x004E
	ldx	x004E
	ldaa	$00,x
	; X078C =	0	1	2	3	4	5
	; A =		0C 	10	14 	18 	1C 	20
	staa	X0124
	bra	LAB59
;
LAB45:				; X078A != 0A or 0C
	ldaa	#$57
	ldab	#$F9		; F957 - F951 = 6, so X078C has range 0-5?
	adda	X078C
	adcb	#$00
	staa	x0049
	stab	x0048
	ldx	x0048
	ldaa	$00,x
	; X078C =	0	1	2	3	4	5
	; A =		00 	04 	08 	0C	10 	0F
	staa	X0124
LAB59:
	ldaa	MeasExponent
	staa	X01A6
	ldaa	MeasExponentSign
	staa	X01A7
	ldaa	MeasExponent
	tsta
	bne	LAB70
	clr	flagMeasHasExponent
	rts
;
LAB70:
	ldaa	#$01
	staa	flagMeasHasExponent
	rts

;===============================================================================
; puts measurement into register format
; used when meter is in Auto range
subCopyMeasToAccumReg:
	ldaa	#$2D	; ASCII "-"
	cmpa	MeasPolaritySign
	bne	LAB86
	ldab	#$FF
	stab	AccumRegister0	; FF indicates negative
	bra	LAB89
;
LAB86:
	clr	AccumRegister0	; = 00 if +, else FF
LAB89:
	ldaa	MeasArray7	; most significant digit
	staa	AccumRegister1
	ldaa	MeasArray6
	asla
	asla
	asla
	asla
	oraa	MeasArray5
	staa	AccumRegister2	; digits 2,3
	ldaa	MeasArray4
	asla
	asla
	asla
	asla
	oraa	MeasArray3
	staa	AccumRegister3	; digits 4,5
	ldaa	MeasArray2
	asla
	asla
	asla
	asla
	oraa	MeasArray1
	staa	AccumRegister4	; digits 6,7
	clr	AccumRegister5
	ldaa	#$2D	; ASCII "-"
	cmpa	MeasExponentSign
	bne	LABCC
	ldab	MeasExponent
	comb
	stab	AccumRegister6
	inc	AccumRegister6	; compliment + 1
	bra	LABD2
;
LABCC:
	ldaa	MeasExponent
	staa	AccumRegister6
LABD2:
	rts
;---------------------------------
; Stores packed reading from FormattedReading2-5 to RAM at position pointed to by X0203-4
; inputs: IGCmdRegister4, X0200, X0205, X0206
subStoreReading:
	ldaa	#$08
	anda	IGCmdRegister4	; bit3 = 1 means OK to store data
	tsta
	beq	LAC4C	; branch if bit3 = 0
	ldaa	#$30
	anda	X0200
	tsta
	bne	LAC4C	; branch if bit4,5 != 00b, so X0200 > 10
	ldaa	X0200
	anda	#$01
	tsta
	beq	LAC0D	; branch if bit0 = 0
	ldaa	#$0E
	anda	X0200
	staa	X0200	; keep bits 3-1
	ldaa	#$02
	oraa	X0200
	staa	X0200	; set bit1
	ldaa	X0206
	ldab	X0205
	adda	#$01
	adcb	#$00
	staa	X0204
	stab	X0203	; X0203-4 = X0205-6 + 1
LAC0D:
	ldaa	#$78
	ldab	#$05	; limit on user RAM location
	suba	X0204
	sbcb	X0203	; 0578 - X0203-4
	bcc	LAC25	; branch if subrraction result is non-negative
	clr	X0200	; = 0	Amount of remaining User RAM?
	ldaa	#$F7
	anda	IGCmdRegister4
	staa	IGCmdRegister4	; clear bit3
LAC4C:
	rts
;
LAC25:
	ldaa	#$02
	anda	X0200
	tsta
	beq	LAC4C	; branch if bit1 = 0
	ldaa	#$03
	clrb
	adda	X0204
	adcb	X0203
	adda	#$07
	adcb	#$02
	staa	x004F
	stab	x004E	; = 0207 + X0203-4 + 3
	ldaa	FormattedReading5
	ldx	x004E
	staa	$00,x	; copy FormattedReading5 to this location
	ldaa	#$02
	clrb
	adda	X0204
	adcb	X0203
	adda	#$07
	adcb	#$02
	staa	x004B
	stab	x004A	; = 0207 + X0203-4 + 2
	ldaa	FormattedReading4
	ldx	x004A
	staa	$00,x	; copy FormattedReading4 to this location
	ldaa	X0204
	ldab	X0203
	adda	#$01
	adcb	#$00
	adda	#$07
	adcb	#$02
	staa	x004B
	stab	x004A	; = 0207 + X0203-4 + 1
	ldaa	FormattedReading3
	ldx	x004A
	staa	$00,x	; copy FormattedReading3 to this location
	ldaa	#$07
	ldab	#$02
	adda	X0204
	adcb	X0203
	staa	x0049
	stab	x0048	; = 0207 + X0203-4
	ldaa	FormattedReading2
	ldx	x0048
	staa	$00,x	; copy FormattedReading2 to this location
	ldaa	#$04
	clrb
	adda	X0204
	adcb	X0203
	staa	X0204
	stab	X0203	; increments X0203-4 by 4
	rts
;---------------------------------

sub019:
	sei
	ldaa	#$10
	staa	ioHPIB_r0	; turn off interrupts from HPIB
	ldaa	#$0A		; bit3,1
	anda	X018C
	staa	InguardStatus
	ldaa	#$03
	anda	X0200
	clrb
	tsta
	beq	LACC9
	decb
LACC9:
	orab	flagHPIBPackedOutput
	tstb
	beq	LACEF
	ldaa	InguardStatus
	tsta
	beq	LACDC
	ldab	#$43	; ASCII "C"
	stab	FormattedReading2
	bra	LACE1
;
LACDC:
	ldaa	#$41	; ASCII "A"
	staa	FormattedReading2
LACE1:
	ldaa	#$99
	staa	FormattedReading3
	staa	FormattedReading4
	staa	FormattedReading5
	jsr	subStoreReading
LACEF:
	ldaa	flagHPIBPackedOutput
	tsta
	bne	LAD37
	ldab	#$2E	; ASCII "."
	stab	FormattedReading8
	ldaa	#$45	; ASCII "E"
	staa	FormattedReading9
	ldaa	#$39	; ASCII "9"
	staa	FormattedReading2
	staa	FormattedReading3
	staa	FormattedReading4
	staa	FormattedReading5
	staa	FormattedReading6
	staa	FormattedReading7
	staa	FormattedReading11
	ldaa	#$31	; ASCII "1"
	staa	FormattedReading1
	ldaa	#$2B	; ASCII "+"
	staa	FormattedReading10
	ldaa	InguardStatus
	tsta
	beq	LAD32
	ldab	#$2D	; ASCII "-"
	stab	FormattedReading0
	bra	LAD37
;
LAD32:
	ldaa	#$2B	; ASCII "+"
	staa	FormattedReading0
LAD37:
	cli
	ldaa	#$A5
	staa	ioHPIB_r0	; turn on interrupts from HPIB
	rts
;---------------------------------

subCopyDisp2MeasArray:
	ldaa	flagDisplayHasExponent
	staa	flagMeasHasExponent
	ldaa	DisplayExponentSign
	staa	MeasExponentSign
	ldaa	DisplayExponent
	staa	MeasExponent
	ldaa	DisplayPolaritySign
	staa	MeasPolaritySign
	ldaa	flagDisplayArrayHasNoDecimal
	staa	flagMeasArrayUnpacked
	ldaa	DisplayArray0
	staa	MeasArray0
	ldaa	DisplayArray1
	staa	MeasArray1
	ldaa	DisplayArray2
	staa	MeasArray2
	ldaa	DisplayArray3
	staa	MeasArray3
	ldaa	DisplayArray4
	staa	MeasArray4
	ldaa	DisplayArray5
	staa	MeasArray5
	ldaa	DisplayArray6
	staa	MeasArray6
	ldaa	DisplayArray7
	staa	MeasArray7
	rts
;---------------------------------

subCopyMeas2DispBytes:
	ldaa	flagMeasHasExponent
	staa	flagDisplayHasExponent
	ldaa	MeasExponentSign
	staa	DisplayExponentSign
	ldaa	MeasExponent
	staa	DisplayExponent
	ldaa	MeasPolaritySign
	staa	DisplayPolaritySign
	ldaa	flagMeasArrayUnpacked
	staa	flagDisplayArrayHasNoDecimal
	ldaa	MeasArray0
	staa	DisplayArray0
	ldaa	MeasArray1
	staa	DisplayArray1
	ldaa	MeasArray2
	staa	DisplayArray2
	ldaa	MeasArray3
	staa	DisplayArray3
	ldaa	MeasArray4
	staa	DisplayArray4
	ldaa	MeasArray5
	staa	DisplayArray5
	ldaa	MeasArray6
	staa	DisplayArray6
	ldaa	MeasArray7
	staa	DisplayArray7
	rts
;===============================================================================
; Update Annunciator & Display if they are ready for new data
subUpdateDisplayIfReady:
	ldaa	#$40
	anda	ioKBrdStrb	;bit6 high indicates the display is ready to write to.
	tsta
	beq	LADED
	jsr	subAnnuncNDisplayUpdate
LADED:
	rts
;===============================================================================
; calling routine sets X0790 (register offset) and X0791 (possible values 0D,20,2A,2C)
; used when meter is in Auto range
sub023:
	ldaa	#$02
	staa	x01B0	; loop index 2,4,6,8
LADF5:
	;--- loop moves data array to 01D1-8 (MeasArray), unpacking and reversing byte order
	ldaa	x01B0
	cmpa	#$08
	bhi	LAE63
	ldaa	x01B0
	clrb		; B = 00
	lsrb		; shift right, C = 0
	rora		; idx/2
	staa	x011C	; 1 to 4
	adda	#$01
	adcb	#$00
	staa	X011E	; 2 to 5
	ldaa	#$09
	suba	x01B0	; A = 7,5,3,1
	clrb
	adda	#$D1
	adcb	#$01	; 01D8,6,4,2  (MeasArray)
	staa	x004B
	stab	x004A
	ldaa	x011C	; 1 to 4
	adda	X0790	; 0A,11,18,1F,26,2D or 42 from calling routine, offsets to data arrays
	clrb
	adda	#$25
	adcb	#$01
	staa	x004F
	stab	x004E
	ldx	x004E	; 0130-0133, 0137-013A, etc (on a voltage measurement, was 0168)
	ldaa	$00,x
	anda	#$0F	; lower nibble
	ldx	x004A	; 01D8,6,4,2  (MeasArray)
	staa	$00,x	; 01D8...
	ldaa	#$08
	suba	x01B0	; 6,4,2,0
	clrb
	adda	#$D1
	adcb	#$01	; base address of MeasArray
	staa	x004B
	stab	x004A	; 01D7,5,3,1
	ldaa	X011E	; 2 to 5
	adda	X0790
	clrb
	adda	#$25
	adcb	#$01
	staa	x004F
	stab	x004E
	ldx	x004E	; 0131-0134, etc (on a voltage measurement, was 0169)
	ldaa	$00,x
	lsra
	lsra
	lsra
	lsra		; upper nibble
	ldx	x004A	; 01D7,5,3,1
	staa	$00,x
	ldaa	x01B0
	adda	#$02
	staa	x01B0
	bra	LADF5
	;--- end loop
;
LAE63:
	ldaa	#$20
	anda	X0791	; 2nd parameter from caller routine, intitially 0D,20,2A or 2C
	tsta
	beq	LAE86	; branch if bit5 = 1
	ldaa	MeasArray7
	tsta
	bne	LAE86	; branch if MeasArray7 != 0 (negative polarity?)
	ldab	#$0B
	orab	X0791
	stab	X0791	; set bits 0,1,3 if bit5 = 0 and MeasArray7 = 0

LAE86:
	ldaa	#$7F
	anda	X0791
	staa	X0791	; clear bit7
	ldaa	#$06
	adda	X0790	; 0790 has an offset to arrays at 012F,0136,013D,0144,014B,0167
	clrb
	adda	#$25
	adcb	#$01
	staa	x004B
	stab	x004A
	ldx	x004A	; 0135, 013C, i.e., highest byte of array
	ldaa	$00,x
	anda	#$80
	tsta
	beq	LAEC5	; branch if bit7 = 0, i.e., positive exponent
	ldaa	#$2D	; ASCII "-" if bit7 = 1 (indicates negative reading)
	staa	MeasExponentSign
	ldaa	#$06
	adda	X0790
	clrb
	adda	#$25
	adcb	#$01
	staa	x004B
	stab	x004A
	ldx	x004A	; 0135, 013C, etc
	ldaa	$00,x
	coma		; 1's compliment
	staa	MeasExponent
	inc	MeasExponent	; 2's compliment as negative exponent is given in complimented form
	bra	LAEDF
;
LAEC5:			; exponent is positive
	ldaa	#$2B	; ASCII "+"
	staa	MeasExponentSign
	ldaa	#$06
	adda	X0790
	clrb
	adda	#$25
	adcb	#$01
	staa	x004B
	stab	x004A
	ldx	x004A	; 0135, 013C, etc
	ldaa	$00,x
	staa	MeasExponent

LAEDF:
	ldaa	#$2B	; ASCII "+"
	cmpa	MeasExponentSign
	bne	LAF52	; branch if "-"
	ldab	MeasArray7
	clra
	cmpb	#$01
	bne	LAEEF
	deca
LAEEF:			; A = 00 if MeasArray7 != 01 else FF
	staa	x004A
	ldaa	MeasExponent
	clrb
	cmpa	#$10
	bls	LAEFA
	decb
LAEFA:			; B = 00 if MeasExponent <= 10 else FF
	andb	x004A
	ldaa	MeasArray7
	stab	x004E	; = FF if MeasArray7 = 01 and MeasExponent > 10
	clrb
	cmpa	#$01
	beq	LAF07	; branch if MeasArray7 = 01
	decb
LAF07:			; B = 00 if MeasArray7 = 01 else FF
	ldaa	MeasExponent
	stab	x0050	; = 00 if MeasArray7 = 01 else FF
	clrb
	cmpa	#$0F
	bls	LAF12
	decb
LAF12:			; B = 00 if MeasExponent <= 0F else FF
	andb	x0050	; = FF if MeasArray7 != 01 and MeasExponent > 0F
	orab	x004E	; = FF if (MeasArray7 != 01 and MeasExponent > 0F) or (MeasArray7 = 01 and MeasExponent > 10)
	tstb
	beq	LAF52	; branch if above is 00
	ldab	#$2E	; ASCII "."
	andb	X018C
	tstb
	bne	LAF47
	ldab	#$25
	ldaa	#$01
	addb	X0790
	adca	#$00
	stab	x005F
	staa	x005E
	ldx	x005E		; possible locations 012F,0136,013D,0144,014B,0167
	ldaa	$00,x
	tsta
	bne	LAF3F
	ldab	#$20
	orab	X018C
	stab	X018C	; set bit5
	bra	LAF47
;
LAF3F:
	ldaa	#$08
	oraa	X018C
	staa	X018C	; set bit3
LAF47:
	jsr	sub019
	jmp	LB213
;
LAF52:
	ldaa	#$25
	ldab	#$01
	adda	X0790
	adcb	#$00
	staa	x0049
	stab	x0048
	ldx	x0048		; possible locations 012F,0136,013D,0144,014B,0167
	ldaa	$00,x
	tsta
	bne	LAF6D
	ldab	#$2B	; ASCII "+"
	stab	MeasPolaritySign
	bra	LAF72
;
LAF6D:
	ldaa	#$2D	; ASCII "-"
	staa	MeasPolaritySign
LAF72:
	jsr	subPackReading
	ldaa	flagOverrange_Maybe
	tsta
	bne	LAF86
	ldab	#$20
	andb	X0791
	tstb
	bne	LAF86
	jsr	subStoreReading
LAF86:
	ldaa	#$1F
	anda	X0791
	staa	X01CC	; lower 5 bits of x0791, possible range 0-24?
LAF8E:
	clr	X01CF
	ldaa	X01CC
	cmpa	#$15
	bls	LAFA0
	ldab	#$80
	orab	X0791
	stab	X0791	; set bit7
LAFA0:
	ldaa	MeasArray7
	cmpa	#$01
	bne	LAFBD	; branch if leading digit != 1
	ldab	#$64
	ldaa	#$F6	; table values @ F664
	addb	X01CC
	adca	#$00
	stab	x004B
	staa	x004A
	ldx	x004A
	ldaa	$00,x
	staa	X01A4	; 28-21, 00-10?
	bra	LAFD1

; data in original file
;F664 : 28 27 26
;F667 : 25 24 23 22
;F66B : 21 00 01 02
;F66F : 03 04 05 06
;F673 : 07 08 09 0A
;F677 : 0B 0C 0D 0E
;F67B : 0F 10 29 28

;F67D : 29 28
;F67F : 27 26 25 24
;F683 : 23 22 21 00
;F687 : 01 02 03 04
;F68B : 05 06 07 08
;F68F : 09 0A 0B 0C
;F693 : 0D 0E 0F 19
;
LAFBD:
	ldaa	#$7D
	ldab	#$F6	; table values @ F67D
	adda	X01CC
	adcb	#$00
	staa	x0049
	stab	x0048
	ldx	x0048
	ldaa	$00,x
	staa	X01A4	; 29-21, 00-0F?
LAFD1:
	ldaa	#$2B	; ASCII "+"
	cmpa	MeasExponentSign
	bne	LAFF4	; branch if not +
	ldab	#$20
	andb	X01A4
	tstb
	bne	LAFF2	; branch if 01A4 < 20
	ldab	#$1F
	andb	X01A4	; lower 5 bits
	cmpb	MeasExponent
	bcs	LAFF2
	ldab	#$40
	orab	X0791
	stab	X0791	; set bit6
LAFF2:
	bra	LB026
;
LAFF4:
	ldaa	#$2D	; ASCII "-"
	cmpa	MeasExponentSign
	bne	LB026	; branch if not -
	ldab	#$20
	andb	X01A4
	tstb
	bne	LB00B	; branch if 01A4 < 20
	ldab	#$40
	orab	X0791
	stab	X0791	; set bit6
LB00B:
	ldaa	#$20
	anda	X01A4
	cmpa	#$20
	bne	LB026	; branch if 01A4 < 20
	ldaa	#$1F
	anda	X01A4	; lower 5 bits
	cmpa	MeasExponent
	bhi	LB026	; branch if higher
	ldaa	#$40	; if less or equal, set bit6
	oraa	X0791
	staa	X0791
LB026:
	ldaa	#$40
	anda	X0791
	tsta
	beq	LB098	; branch if bit6 = 0
	ldaa	#$96
	ldab	#$F6	; table values @ F696
	adda	X01CC	; possible range 0-24?
	adcb	#$00
	staa	x004D
	stab	x004C
	ldx	x004C
	ldaa	$00,x
	staa	X01CD
	ldaa	#$2B	; ASCII "+"
	clrb
	cmpa	MeasExponentSign
	bne	LB04B
	decb
LB04B:			; B = 00 if sign != +, else FF
	ldaa	#$1F
	anda	X01CD	; possible results 00,03,06,09,13,16,19
	stab	x0048
	clrb
	cmpa	#$10
	bls	LB058
	decb
LB058:
	andb	x0048
	tstb
	beq	LB07F
LB05D:
	ldaa	#$2B	; ASCII "+"
	cmpa	MeasExponentSign
	bne	LB0AE
	dec	MeasExponent
	inc	X01CF
	ldaa	MeasExponent
	tsta
	bne	LB07B
	inc	MeasExponent
	ldaa	#$2D	; ASCII "-"
	staa	MeasExponentSign
	inc	X01CF
LB07B:
	bra	LB05D
LB098:
	inc	X01CC
	jmp	LAF8E
;
;F696 :  19
;F697 : 39 59 79 36
;F69B : 56 76 33 53
;F69F : 00 20 40 60
;F6A3 : 23 43 63 26
;F6A7 : 46 66 29 49
;F6AB : 69 89 A9 C9
;
;
LB07F:
	ldaa	#$2D	; ASCII "-"
	cmpa	MeasExponentSign
	bne	LB0AE
	ldab	#$1F
	andb	X01CD
	cmpb	#$10
	bcc	LB0AE
LB08F:
	ldaa	#$2D	; ASCII "-"
	cmpa	MeasExponentSign
	bne	LB0AE
	dec	MeasExponent
	inc	X01CF
	ldaa	MeasExponent
	tsta
	bne	LB0AC
	ldab	#$2B	; ASCII "+"
	stab	MeasExponentSign
LB0AC:
	bra	LB08F
;
LB0AE:
	ldaa	#$0F
	anda	X01CD
	staa	X01CD
	ldaa	#$2D	; ASCII "-"
	cmpa	MeasExponentSign
	bne	LB0D5
	ldab	X01CD
	stab	X01A4
	ldaa	MeasExponent
	staa	X01A5
	ldaa	MeasExponent
	staa	X01CD
	ldaa	X01A4
	staa	MeasExponent
LB0D5:
	ldaa	MeasExponent
	cmpa	X01CD
	bls	LB0E7
	ldab	#$40
	orab	X0791
	stab	X0791
	bra	LB0EF
;
LB0E7:
	ldaa	#$BF
	anda	X0791
	staa	X0791
LB0EF:
	ldaa	MeasExponent
	cmpa	X01CD
	bls	LB0FF
	dec	MeasExponent
	inc	X01CF
	bra	LB0EF
;
LB0FF:
	ldaa	MeasExponent
	cmpa	X01CD
	bcc	LB10F
	inc	MeasExponent
	inc	X01CF
	bra	LB0FF
;
LB10F:
	ldaa	#$96
	ldab	#$F6	; table values @ F696
	adda	X01CC
	adcb	#$00
	staa	x0049
	stab	x0048
	ldx	x0048
	ldaa	$00,x
	anda	#$0F
	staa	MeasExponent
	ldaa	#$96
	ldab	#$F6	; table values @ F696
	adda	X01CC
	adcb	#$00
	staa	x0049
	stab	x0048
	ldx	x0048
	ldaa	$00,x
	lsra
	lsra
	lsra
	lsra
	lsra
	staa	X01CE
	inc	X01CE
	ldaa	#$40
	anda	X0791
	tsta
	beq	LB1B5
	ldaa	#$07
	suba	X01CF
	staa	X01CD
	clr	X01A5
LB154:
	ldaa	X01CD
	tsta
	beq	LB184
	ldab	#$D1
	ldaa	#$01	; base address of MeasArray
	addb	X01A5
	adca	#$00
	stab	x004B
	staa	x004A
	ldaa	X01A5
	inca
	clrb
	adda	#$D1
	adcb	#$01	; base address of MeasArray
	staa	x004F
	stab	x004E
	ldx	x004E
	ldaa	$00,x
	ldx	x004A
	staa	$00,x
	inc	X01A5
	dec	X01CD
	bra	LB154
;
LB184:
	ldaa	#$D1
	ldab	#$01	; base address of MeasArray
	adda	X01A5
	adcb	#$00
	staa	x0049
	stab	x0048
	ldaa	#$2E	; ASCII "."
	ldx	x0048
	staa	$00,x
	ldaa	X01CE
	suba	X01CF
	staa	X01A4
LB1A0:
	ldaa	X01A4
	tsta
	beq	LB1E5
	jsr	subShiftMeasArrayRight
	dec	X01A4
	bra	LB1A0
;
LB1B5:
	ldaa	X01CF
	inca
	staa	X01CD
LB1BC:
	ldaa	X01CD
	tsta
	beq	LB1CA
	jsr	subShiftMeasArrayRight
	dec	X01CD
	bra	LB1BC
;
LB1CA:
	ldaa	#$2E	; ASCII "."
	staa	MeasArray7
LB1CF:
	ldaa	X01CE
	tsta
	beq	LB1E5
	jsr	subShiftMeasArrayRight
	dec	X01CE
	bra	LB1CF
;
LB1E5:
	ldaa	flagHPIBPackedOutput
	tsta
	bne	LB1EE
	jsr	subFormatReadingForHPIB
LB1EE:
	ldaa	#$01
	staa	flagMeasArrayUnpacked
	ldaa	#$20
	anda	X0791
	tsta
	beq	LB213
	ldaa	MeasExponent
	tsta
	bne	LB206
	clr	flagMeasHasExponent
	bra	LB20B
LB206:
	ldaa	#$01
	staa	flagMeasHasExponent
LB20B:
	jsr	subCopyMeas2DispBytes
	ldaa	#$01
	staa	flagMeasFormatted
LB213:
	clr	X0790
	ldaa	X0791
	staa	X019C
	clra
	clrb
	rts
;---------------------------------

subUpdateHPIBSerialPoll:
	ldaa	HPIBSerialPollMask	; possible values FB, FD, FE, i.e., turn off bit6, 5 or 4
	anda	ioHPIB_r5	; serial poll register, used to give meter status on HPIB
	staa	x01CA
	ldaa	#$40
	cmpa	x01CA
	bne	LB23E		; branch if HPIB service requested
	clr	ioHPIB_r5
	ldaa	#$EF
	anda	flagHPIBOutput
	staa	flagHPIBOutput	; clear bit4
	bra	LB247
;
LB23E:
	ldaa	HPIBSerialPollMask
	anda	ioHPIB_r5
	staa	ioHPIB_r5	; update status info given to bus
LB247:
	clra
	clrb
	rts
;---------------------------------
; called if the inguard has timed out, i.e., inguard did not respond fast enough
subHandleIGTimeout:
	ldaa	flagInguard1stTimeout
	tsta
	bne	LB271
	ldab	#$10
	stab	HPIBSerialPollStatus
	jsr	subHPIBRequestService
	ldaa	#$01
	staa	flagInguard1stTimeout
	ldaa	#$F7
	anda	flagCmdParse
	staa	flagCmdParse	; clear bit3
	ldaa	#$01
	staa	flagHPIBByteInIntr
	jmp	LD421		; jumps into sub103 if 2nd timeout occurs

LB271:				; if it was the 1st timeout, try again
	clr	ioIOreset
	ldaa	#$FF
	staa	ioIsoLogic
	ldaa	#$B0
	ldab	#$04
	psha
	pshb
	ldaa	#$01
	psha		; 01, 04, B0 on stack
	jsr	subProgrammedDelay
	ldaa	#$8F
	staa	ioIsoLogic
	ldaa	#$20	; ASCII " "
	ldab	#$4E
	psha
	pshb
	ldaa	#$01
	psha		; 01, 4E, 20 on stack
	jsr	subProgrammedDelay
	clr	flagInguard1stTimeout
	ldaa	#$F7
	anda	flagCmdParse
	staa	flagCmdParse	; clear bit3
	ldaa	#$01
	staa	flagHPIBByteInIntr
	jmp	LD421		; jumps into sub103
LB2A9:
	rts
;---------------------------------

sub026:
	ldaa	#$0F
	staa	MeasArray7
	staa	MeasPolaritySign
	ldaa	#$0A	; puts dashes on display
	staa	MeasArray0
	staa	MeasArray1
	staa	MeasArray2
	staa	MeasArray3
	staa	MeasArray4
	staa	MeasArray5
	staa	MeasArray6

	staa	Digit7	;***** MODDED put a dash in exponent digit, too

	ldaa	#$D1
	ldab	#$01	; base address of MeasArray
	adda	DecimalPosition
	adcb	#$00
	staa	x0049
	stab	x0048
	ldaa	#$2E	; ASCII "."
	ldx	x0048
	staa	$00,x	; inserts decimal point
	jsr	sub016	; returns InguardStatus bit3-0 or 5 in DecimalDisplayPosition
	ldaa	#$01
	staa	flagMeasArrayUnpacked
	jsr	subCopyMeas2DispBytes
	clr	flag010B
	rts
;---------------------------------

sub027:
	ldaa	#$80
	anda	IGCmdRegister2	; IGCmdRegister2 bit 7 determines if EOI added to HPIB output
	tsta
	beq	LB2FE
	ldaa	#$01
	staa	flagOutputEOI
	bra	LB301
;
LB2FE:
	clr	flagOutputEOI
LB301:				; flagOutputEOI = 01 if IGCmdRegister2 bit7 = 1, else 00
	ldaa	#$20
	anda	IGCmdRegister4	; IGCmdRegister4 bit 5 determines if output is in packed format
	tsta
	beq	LB310
	ldaa	#$01
	staa	flagHPIBPackedOutput
	bra	LB313
;
LB310:
	clr	flagHPIBPackedOutput
LB313:				; flagHPIBPackedOutput = 01 if IGCmdRegister4 bit5 = 1, else 00
	ldaa	#$10
	anda	IGCmdRegister4	; IGCmdRegister4 bit 4 sets display to update
	tsta
	beq	LB322
	ldaa	#$01
	staa	flagDispNeedUpdate
	bra	LB325
;
LB322:
	clr	flagDispNeedUpdate
LB325:				; flagDispNeedUpdate = 01 if IGCmdRegister4 bit4 = 1, else 00
	ldaa	#$E0
	anda	IGCmdRegister0
	lsra
	lsra
	lsra
	lsra
	staa	X078A			; X078A is bit7-5 of IGCmdRegister0 in bit3-1
	ldaa	#$0E
	anda	IGCmdRegister0
	lsra
	staa	X078C			; X078C is bit3-1 of IGCmdRegister0 in bit2-0 -> max value 7
	ldaa	#$07
	anda	IGCmdRegister1
	staa	flagNumPLCcode	; bit2-0
	jsr	sub016			; returns InguardStatus bit3-0 or 5 in DecimalDisplayPosition
	ldaa	DecimalDisplayPosition
	staa	DecimalPosition
	ldaa	#$01
	staa	X019D
	ldaa	IGCmdRegister0
	lsra
	lsra
	lsra
	lsra
	staa	x011C
	ldaa	x011C
	suba	#$02
	staa	x011C	; = IGCmdRegister0 >> 4 - 2, max value is 13(dec)
	ldaa	#$7B
	ldab	#$F7
	adda	x011C
	adcb	#$00
	staa	x0049
	stab	x0048
	ldx	x0048
	ldaa	$00,x
	; table F77B
	; index		0	1	2	3	4	5	6	7	8	9	10	11	12	13
	; return	0C 	0C 	0C 	0C	04 	04 	07 	07	07 	03 	07 	03	10 	10
	staa	X011E
	ldaa	X011E
	lsra
	lsra
	lsra
	anda	#$07
	staa	X0199
	ldaa	#$07
	anda	X011E
	staa	X019A
	ldaa	#$6F
	ldab	#$F7
	adda	x011C
	adcb	#$00
	staa	x0049
	stab	x0048
	ldx	x0048
	ldaa	$00,x
	; table F76F
	; index		0	1	2	3	4	5	6	7	8	9	10	11	12	13
	; return81 	86 	81 	86	01 	06 	40 	40	11 	1A 	11 	1A	0C 	0C
	staa	X0198
	ldaa	#$18
	anda	X0198
	cmpa	#$10
	bne	LB3D7		; branch if bit4 = 1
	ldaa	#$06
	cmpa	X078C
	bne	LB3C1
	ldab	#$20
	orab	X0198
	andb	#$FE
	stab	X0198		; set bit5, clear bit0
	ldaa	#$04
	staa	DecimalPosition
LB3C1:
	ldaa	#$07
	cmpa	X078C
	bne	LB3D7
	ldab	#$03
	stab	DecimalPosition
	ldaa	#$20
	oraa	X0198
	anda	#$FE
	staa	X0198		; set bit5, clear bit0
LB3D7:
	ldaa	#$0F
	anda	IGCmdRegister2
	clrb
	tsta
	beq	LB3E1
	decb
LB3E1:				; B = FF if IGCmdRegister2 lower nibble != 00, else 00
	ldaa	IGCmdRegister0
	anda	#$01
	stab	x004A
	clrb
	tsta
	beq	LB3ED
	decb
LB3ED:				; B = FF if IGCmdRegister0 bit0 != 1, else 00
	orab	x004A
	rorb
	bcc	LB3FA		; branch if IGCmdRegister2 lower nibble = 00 and IGCmdRegister0 bit0 = 1
	ldaa	#$FE
	anda	X0198
	staa	X0198		; clear bit0
LB3FA:
	ldaa	#$10
	anda	X0198
	tsta
	beq	LB40C		; branch if X0198 bit4 = 0
	ldaa	#$03
	adda	X078C
	staa	X019B
	bra	LB412
;
LB40C:
	ldaa	X078C
	staa	X019B
LB412:				; if X0198 bit4 = 0, X019B = X078C, else = X078C + 3
	rts
;---------------------------------

sub028:
	jsr	sub027
	ldaa	#$08
	adda	X019B
	staa	X019C
	ldaa	X019C
	staa	X01A9		; X01A9 = X019C = X019B + 8
	ldaa	#$D1
	anda	X018C
	staa	X018C		; clear bits 5,3-1
	clr	flagOverrange_Maybe
	ldaa	#$45		; ASCII "E"
	staa	FormattedReading9
	ldaa	#$0D		; ASCII [cr]
	staa	FormattedReading12
	ldaa	#$0A		; ASCII [lf]
	staa	FormattedReading13
	ldaa	X012A
	staa	X018F
	ldaa	X012B
	staa	X018E		; X018E,F = X012A,B
	ldaa	#$08
	oraa	flagCmdParse
	staa	flagCmdParse	; set bit3
	rts
;---------------------------------
; puts "Ex" on the display, where x is the error number
; imports error number in ErrorNumber
subDisplayError:
	clr	flagX01FB
	clr	flagCmdParse
	clr	tempCmdParseFlag
	clr	flag01A1
	ldaa	#$40
	anda	ioHPIB_r1	; bit6 set if meter in HPIB Remote mode
	tsta
	beq	LB473		; branch if not in Remote mode
	ldaa	#$10
	staa	HPIBSerialPollStatus
	jsr	subHPIBRequestService
LB473:
	jsr	subBlankMeasArray
	clr	flagMeasArrayUnpacked
	ldaa	#$0B		; display "E"
	staa	MeasArray2
	ldaa	#$0F
	anda	ErrorNumber		; possible values 1,2,3,5,6 Error Number
	staa	MeasArray1
	jsr	subCopyMeas2DispBytes
	jmp	LC9D2
;---------------------------------

subDisplayError4:
	ldaa	#$04
	staa	ErrorNumber
	bsr	subDisplayError
	rts
;---------------------------------
; Measurement is in AccumRegister, in register format. Perhaps this detects overrange?  Sets flagOverrange
; only called when in Auto range
subTestForOverrange_Maybe:
	ldaa	X019B		; something to do with the exponent range?
	cmpa	AccumRegister6	; is either MeasExponent or its compliment
	bne	LB4D6		; branch if exponent not flagOverrange_Maybe
	ldab	AccumRegister2	; contains digits 2 and 3
	lsrb
	lsrb
	lsrb
	lsrb			; B = digit2
	ldaa	AccumRegister1	; digit1
	stab	x004A		; digit2 in lower nibble
	clrb
	cmpa	#$01
	bne	LB4B2		; branch if digit1 != 1, i.e., must be 0
	decb
LB4B2:
	ldaa	x004A		; A = digit2
	stab	x004C		; = FF if digit1 = 1, else 00
	clrb
	cmpa	X019D		; X019D = 0 or 1
	bls	LB4BD		; branch if digit2 is <= 0 or 1 (X019D)
	decb
LB4BD:				; B = FF if digit2 is > 0 or 1 (X019D)
	andb	x004C		; B = FF if digit1 = 1 and digit2 > 0 or 1 (X019D)  maybe overrange indication?
	ldaa	AccumRegister1	; digit1
	stab	x0050
	clrb
	cmpa	#$01
	bls	LB4CA		; branch if digit1 = 0 or 1
	decb
LB4CA:				; B = FF if digit1 >= 2
	orab	x0050		; B = FF if (digit1 = 1 and digit2 > 0 or 1 (X019D)) or digit1 >= 2
	rorb
	bcc	LB4D4
	ldab	#$01
	stab	flagOverrange_Maybe	; set flag if (digit1 = 1 and digit2 > 0 or 1 (X019D)) or digit1 >= 2
LB4D4:
	rts
;
LB4D6:				 ; arrive here if exponent != flagOverrange_Maybe
	ldaa	#$80
	anda	AccumRegister6
	tsta
	bne	LB4EB		; branch to rts if exponent < 0
	ldaa	AccumRegister6
	cmpa	X019B
	bls	LB4EB		; branch to rts if exponent <= flagOverrange_Maybe
	ldab	#$01
	stab	flagOverrange_Maybe	; must be set if exponent > flagOverrange_Maybe
LB4EB:
	rts
;---------------------------------
; copies 7 byte register AccumRegister (0167-016D) to another register.  Given offset (X0793)
; to last byte of register to copy to and copies from last to first bytes.
subCopyAccumRegToRegister:
	clr	x01B0	; loop index
LB4F1:
	ldaa	x01B0
	cmpa	#$06
	bhi	LB522	; rts when = 7
	ldaa	X0793	; parameter from calling sub, values 1E,25,2C,49,57,65
	suba	x01B0	; subtract index 0-6
	clrb
	adda	#$25
	adcb	#$01
	staa	x004B
	stab	x004A
	ldaa	#$48
	suba	x01B0
	clrb
	adda	#$25
	adcb	#$01
	staa	x004F
	stab	x004E
	ldx	x004E	; 16D-167  <-- copies from this register
	ldaa	$00,x
	ldx	x004A	; 143-13D,14A-144,151-14B,16E-168,17C-176,18A-184  <-- to one of these
	staa	$00,x
	inc	x01B0
	bra	LB4F1
LB522:
	rts
;---------------------------------
; returns with AccumRegister = AccumRegister / (1.0E7 - AccumRegister), unless denominator
; is < 1E-9, then no change to AccumRegister and flagOverrange_Maybe = 1
sub033:
	ldaa	#$57
	staa	X0793
	bsr	subCopyAccumRegToRegister	; copies to 0176-017C
	clr	X0176
	ldaa	#$D3
	ldab	#$F7		; F7D3 = 00 01 00 00 00 00 08 = 1.0E+7
	psha
	pshb
	ldaa	#$76
	ldab	#$01
	psha
	pshb
	ldaa	#$E6
	ldab	#$01
	psha
	pshb
	ldaa	#$03
	psha
	jsr	subRegisterSubtract	; 01E6 =  F7D3(= 1.0E+7) - 0176
	ldaa	X01E7			; first byte of mantissa
	tsta
	beq	LB56F			; testing if subtraction result magnitude is too small?
	ldab	#$07
	addb	AccumRegister6
	stab	AccumRegister6
	ldaa	#$67
	ldab	#$01			; 0167 = base address of AccumRegister
	psha
	pshb
	ldaa	#$E6
	ldab	#$01
	psha
	pshb
	ldaa	#$67
	ldab	#$01
	psha
	pshb
	ldaa	#$03
	psha
	jsr	subRegisterDivide	; 0167 = 0167 / 01E6
	bra	LB574
;
LB56F:
	ldaa	#$01
	staa	flagOverrange_Maybe
LB574:
	rts
;---------------------------------

sub034:
	ldaa	#$67
	ldab	#$01			; 0167 = base address of AccumRegister
	psha
	pshb
	ldaa	#$76
	ldab	#$01
	psha
	pshb
	ldaa	#$67
	ldab	#$01
	psha
	pshb
	ldaa	#$03
	psha
	jsr	subRegisterSubtract	; 0167 = 0167 - 0176
	rts
;---------------------------------

sub035:
	ldaa	#$08
	oraa	X018C
	staa	X018C		; set bit3
	ldaa	#$01
	staa	AccumRegister1
	ldaa	#$11
	staa	AccumRegister6
	rts
;---------------------------------

sub036:
	ldaa	#$20
	oraa	X018C
	staa	X018C		; set bit5
	ldaa	#$01
	staa	AccumRegister1
	ldaa	#$11
	staa	AccumRegister6
	rts
;---------------------------------

subClearAccumRegister:
	clr	AccumRegister0
	clr	AccumRegister1
	clr	AccumRegister2
	clr	AccumRegister3
	clr	AccumRegister4
	clr	AccumRegister5
	clr	AccumRegister6
	rts
;---------------------------------

sub038:
	ldaa	AccumRegister6	; measurement exponent, 2's compliment if negative
	staa	x01B0
	ldaa	#$80
	anda	x01B0
	tsta
	beq	LB5EA		; branch if bit7 = 0, ie, x01B0 is positive
	ldaa	x01B0
	coma			; 1's compliment
	inca			; 2's compliment
	staa	x01B0
LB5EA:
	ldaa	x01B0		; absolute value of exponent
	cmpa	#$1F		; 3456A manual, paragraph 3-74 says exponent can be up to +/-9
	bls	LB5F4
	jmp	LB67E
;
LB5F4:
	clr	AccumRegister0
	ldaa	AccumRegister1
	tsta
	bne	LB600
	jmp	LB682
;
LB600:
	ldaa	#$49
	staa	X0793
	jsr	subCopyAccumRegToRegister	; copies to 0168-016E
	ldx	#$0169
	stx	IdxPtr0169
	ldx	#$0174
	stx	IdxPtr0174
	ldaa	#$FF
	staa	RegisterSTAT30
	clr	RegisterSTAT31
	clr	RegisterSTAT32
	clr	RegisterSTAT33
	clr	RegisterSTAT34
	clr	RegisterSTAT35
	clr	RegisterSTAT36
	clra
	psha		; push 00 on stack
	jsr	subMath22	;
	sts	x0048
	ldaa	x0049
	ldab	x0048
	adda	#$01
	adcb	#$00
	staa	x004B
	stab	x004A
	lds	x004A	; increment stack pointer to get rid of the 00 pushed on?
	jsr	subClearAccumRegister
	clra
	psha		; push 00 on stack
	jsr	sub158	; does not use stack
	sts	x0048	; stack pointer
	ldaa	x0049
	ldab	x0048
	adda	#$01
	adcb	#$00
	staa	x004B
	stab	x004A
	lds	x004A	; increment stack pointer to get rid of the 00 pushed on?
	ldaa	#$0F
	anda	RegisterSTAT31
	staa	RegisterSTAT31
	ldaa	#$6F
	ldab	#$01
	psha
	pshb
	ldaa	#$68
	ldab	#$01
	psha
	pshb
	ldaa	#$67
	ldab	#$01		; 0167 = base address of AccumRegister
	psha
	pshb
	ldaa	#$03
	psha
	jsr	subRegisterAdd	; 0167 = 016F + 0168
	rts
;
LB67E:
	jsr	sub036
	rts
;
LB682:
	jsr	sub035
	rts
;===============================================================================
; (X - Y)/Y function
sub039:
	ldaa	#$67
	ldab	#$01			; 0167 = base address of AccumRegister
	psha
	pshb
	ldaa	#$3D
	ldab	#$01
	psha
	pshb
	ldaa	#$B1
	ldab	#$01
	psha
	pshb
	ldaa	#$03
	psha
	jsr	subRegisterSubtract	; 01B1 = 0167 - 013D
	ldaa	RegisterY1		; byte 1 of Y register
	tsta
	bne	LB6A9
	jmp	LB6CB		; jump to avoid divide by zero
;
LB6A9:
	ldaa	#$B1
	ldab	#$01
	psha
	pshb
	ldaa	#$36
	ldab	#$01
	psha
	pshb
	ldaa	#$67
	ldab	#$01			; 0167 = base address of AccumRegister
	psha
	pshb
	ldaa	#$03
	psha
	jsr	subRegisterDivide		; 0167 = 01B1 / 0136
	ldaa	X019C
	suba	RegisterY6	; constant at 01
	staa	X019C
	rts
;
LB6CB:
	ldaa	X01B1
	tsta
	bne	LB6D6
	jsr	sub036
	bra	LB6D9
;
LB6D6:
	jsr	sub035
LB6D9:
	rts
;===============================================================================
; 100(X - Y)/Y function
sub040:
	ldaa	#$67
	ldab	#$01		; 0167 = base address of AccumRegister
	psha
	pshb
	ldaa	#$36
	ldab	#$01
	psha
	pshb
	ldaa	#$D1
	ldab	#$01	; base address of MeasArray
	psha
	pshb
	ldaa	#$03
	psha
	jsr	subRegisterSubtract	;  01D1 = 0167 - 0136
	ldaa	RegisterY1	; byte 1 of Y register
	tsta
	bne	LB6FD
	jmp	LB723		; jump to avoid divide by zero
;
LB6FD:
	ldaa	#$D1
	ldab	#$01	; base address of MeasArray
	psha
	pshb
	ldaa	#$36
	ldab	#$01
	psha
	pshb
	ldaa	#$67
	ldab	#$01
	psha
	pshb
	ldaa	#$03
	psha
	jsr	subRegisterDivide		; 0167 = 01D1 / 0136
	ldaa	#$02
	adda	AccumRegister6
	staa	AccumRegister6		; add 2 to exponent, --> x 100
	ldaa	#$0B
	staa	X019C
	rts

;
LB723:
	ldaa	MeasArray0
	tsta
	bne	LB72E
	jsr	sub036
	bra	LB731
;
LB72E:
	jsr	sub035
LB731:
	rts
;===============================================================================
; Null function
sub041:
	ldaa	X018C
	anda	#$01
	cmpa	#$01
	bne	LB74D
	ldaa	#$1E
	staa	X0793
	jsr	subCopyAccumRegToRegister	; copies to 013D-0143
	ldaa	#$FE
	anda	X018C
	staa	X018C	; clear bit0
LB74D:
	ldaa	#$67
	ldab	#$01			; 0167 = base address of AccumRegister
	psha
	pshb
	ldaa	#$3D
	ldab	#$01
	psha
	pshb
	ldaa	#$67
	ldab	#$01
	psha
	pshb
	ldaa	#$03
	psha
	jsr	subRegisterSubtract	; 0167 = 0167 - 013D
	rts
;===============================================================================
; preload LOWER and UPPER register 7 byte data arrays
subPresetLnUregs:
	ldaa	#$01
	staa	RegisterL1
	staa	RegisterU1
	clr	RegisterU0
	clr	RegisterL5
	clr	RegisterU5
	ldaa	#$FF
	staa	RegisterL0
	ldaa	#$10
	staa	RegisterL6
	staa	RegisterU5
	ldaa	#$99
	staa	RegisterL2
	staa	RegisterL3
	staa	RegisterL4
	staa	RegisterU2
	staa	RegisterU3
	staa	RegisterU4
	rts
;===============================================================================

sub043:
	ldaa	X018C
	anda	#$01
	rora
	bcc	LB80C	; branch if bit0 is 0
	ldaa	#$0F
	anda	IGCmdRegister2
	cmpa	#$02
	bne	LB80C
	ldaa	#$25
	staa	X0793
	jsr	subCopyAccumRegToRegister	; copies current measurement to 0144-014A
	ldaa	#$2C
	staa	X0793
	jsr	subCopyAccumRegToRegister	; copies current measurement to 014B-0151
	ldaa	#$65
	staa	X0793
	jsr	subCopyAccumRegToRegister	; copies current measurement to 0184-018A
	ldaa	#$1E
	staa	X0793
	jsr	subCopyAccumRegToRegister	; copies current measurement to 013D-0143

	ldaa	#$2D
	staa	x01B0
LB7D3:
	ldaa	x01B0
	cmpa	#$41		; loop from 2D to 41
	bhi	LB7F0
	ldaa	#$25
	ldab	#$01
	adda	x01B0
	adcb	#$00
	staa	x0049
	stab	x0048
	ldx	x0048
	clr	$00,x		; clears memory from 0152 to 166
	inc	x01B0
	bra	LB7D3

LB80C:
	rts
;
LB7F0:
	clr	X010E		; then clear all these
	clr	X010F
	clr	X0110
	clr	X0111
	clr	X0112
	clr	X0113
	clr	X0114
	clr	X0108
	ldaa	#$FE
	anda	X018C
	staa	X018C	; clear bit0
	rts
;===============================================================================
; Statistics function
subMathFcnStats:
	ldaa	#$10
	anda	X018C
	tsta
	beq	LB82B	; branch if bit4 = 0
	rts
;
LB82B:
	ldaa	flagOverrange_Maybe
	clrb
	tsta
	beq	LB833
	decb
LB833:
	ldaa	#$28
	anda	X018C
	stab	x0048	; keep bits 5,3
	clrb
	tsta
	beq	LB83F
	decb
LB83F:
	orab	x0048
	rorb
	bcc	LB855
	ldaa	#$10
	oraa	X018C
	anda	#$FE
	staa	X018C	; set bit4, clear bit0
	jsr	subPresetLnUregs
	clr	RegisterC1
	rts
;
LB855:
	ldaa	#$10
	staa	ioHPIB_r0	; turn off interrupts from HPIB
	sei
	jsr	sub043
	ldaa	#$5D
	ldab	#$F6		; F65D = 00 01 00 00 00 00 01
	psha
	pshb
	ldaa	#$52
	ldab	#$01
	psha
	pshb
	psha
	pshb
	ldaa	#$03
	psha
	jsr	subRegisterAdd	; 0152 = F65D (= 1) + 0152
	inc	X0108
	ldaa	#$67
	ldab	#$01			; 0167 = base address of AccumRegister
	psha
	pshb
	ldaa	#$84
	ldab	#$01
	psha
	pshb
	ldaa	#$6F
	ldab	#$01
	psha
	pshb
	ldaa	#$03
	psha
	jsr	subRegisterSubtract	; 016F = 0167 - 0184
	ldaa	#$60
	ldab	#$01
	psha
	pshb
	ldaa	#$6F
	ldab	#$01
	psha
	pshb
	ldaa	#$60
	ldab	#$01
	psha
	pshb
	ldaa	#$03
	psha
	jsr	subRegisterAdd	; 0160 = 0160 + 016F
	ldaa	#$6F
	ldab	#$01
	psha
	pshb
	psha
	pshb
	psha
	pshb
	ldaa	#$03
	psha
	jsr	subRegisterMultiply	; 016F = 016F * 016F
	ldaa	#$6F
	ldab	#$01
	psha
	pshb
	ldaa	#$59
	ldab	#$01
	psha
	pshb
	psha
	pshb
	ldaa	#$03
	psha
	jsr	subRegisterAdd	; 0159 = 016F + 0159
	ldaa	#$41
	ldab	#$03
	eora	X0108
	staa	X0002
	orab	X0002
	bne	LB90B
	ldaa	#$0E
	ldab	#$01
	psha
	pshb
	ldaa	#$60
	ldab	#$01
	psha
	pshb
	ldaa	#$0E
	ldab	#$01
	psha
	pshb
	ldaa	#$03
	psha
	jsr	subRegisterAdd	; 010E = 010E + 0160
	clr	RegisterSTAT20
	clr	RegisterSTAT21
	clr	RegisterSTAT22
	clr	RegisterSTAT23
	clr	RegisterSTAT24
	clr	RegisterSTAT25
	clr	RegisterSTAT26
	clr	X0108
LB90B:
	ldaa	#$44
	ldab	#$01
	psha
	pshb
	ldaa	#$67
	ldab	#$01
	psha
	pshb
	ldaa	#$D1
	ldab	#$01		; base address of MeasArray
	psha
	pshb
	ldaa	#$03
	psha
	jsr	subRegisterSubtract	; 01D1 = 0144 - 0167
	ldaa	MeasArray0
	tsta
	bne	LB933
	ldab	#$25
	stab	X0793
	jsr	subCopyAccumRegToRegister	; copies current measurement to 0144-014A
	bra	LB959
;
LB933:
	ldaa	#$67
	ldab	#$01
	psha
	pshb
	ldaa	#$4B
	ldab	#$01
	psha
	pshb
	ldaa	#$D1
	ldab	#$01		; base address of MeasArray
	psha
	pshb
	ldaa	#$03
	psha
	jsr	subRegisterSubtract	; 01D1 = 0167 - 014B
	ldaa	MeasArray0
	tsta
	bne	LB959
	ldab	#$2C
	stab	X0793
	jsr	subCopyAccumRegToRegister	; copies current measurement to 014B-0151
LB959:
	cli
	ldaa	#$A5
	staa	ioHPIB_r0	; turn on interrupts from HPIB
	rts
;===============================================================================
; dBm function
subMathFcnDBM:
	ldaa	RegisterZ1	; byte 1 of Z register
	tsta
	bne	LB96B
	jmp	LB9BB
;
LB96B:
	ldaa	#$67
	ldab	#$01			; 0167 = base address of AccumRegister
	psha
	pshb
	psha
	pshb
	ldaa	#$B1
	ldab	#$01
	psha
	pshb
	ldaa	#$03
	psha
	jsr	subRegisterMultiply	; 01B1 = 0167 * 0167
	ldaa	#$B1
	ldab	#$01
	psha
	pshb
	ldaa	#$2F
	ldab	#$01
	psha
	pshb
	ldaa	#$67
	ldab	#$01
	psha
	pshb
	ldaa	#$03
	psha
	jsr	subRegisterDivide	; 0167 = 01B1 / 012F
	jsr	sub038
	ldaa	#$67
	ldab	#$01
	psha
	pshb
	ldaa	#$2E
	ldab	#$F9	; F92E = 00 03 00 00 00 00 01 (=3.0)
	psha
	pshb
	ldaa	#$67
	ldab	#$01
	psha
	pshb
	ldaa	#$03
	psha
	jsr	subRegisterAdd	; 0167 = 0167 + F92E (=3.0)
	inc	AccumRegister6
	ldaa	#$0C
	staa	X019C
	rts

LB9BB:
	jsr	sub036
	rts
;===============================================================================

sub046:
	ldaa	#$80
	staa	HPIBSerialPollStatus
	jsr	subHPIBRequestService
	rts
;===============================================================================
; Pass/Fail function
subMathFcnPassFail:
	ldaa	flagOverrange_Maybe
	clrb
	tsta
	beq	LB9D4
	decb
LB9D4:
	ldaa	#$28
	anda	X018C
	stab	x0048	; keep bits 3,5
	clrb
	tsta
	beq	LB9E0
	decb
LB9E0:
	orab	x0048
	rorb
	bcc	LB9E9
	bsr	sub046
	bra	LBA41
;
LB9E9:
	ldaa	#$67
	ldab	#$01			; 0167 = base address of AccumRegister
	psha
	pshb
	ldaa	#$44
	ldab	#$01
	psha
	pshb
	ldaa	#$D1
	ldab	#$01	; base address of MeasArray
	psha
	pshb
	ldaa	#$03
	psha
	jsr	subRegisterSubtract	; 01D1 = 0167 - 0144
	ldaa	MeasArray0
	tsta
	bne	LBA37
	ldab	#$4B
	ldaa	#$01
	pshb
	psha
	ldaa	#$67
	ldab	#$01
	psha
	pshb
	ldaa	#$D1
	ldab	#$01	; base address of MeasArray
	psha
	pshb
	ldaa	#$03
	psha
	jsr	subRegisterSubtract	; 01D1 = 014B - 0167
	ldaa	MeasArray0
	tsta
	bne	LBA26
	rts

LBA26:
	ldaa	#$04
	oraa	X018C
	staa	X018C	; set bit2
	bsr	sub046
	rts
;
LBA37:
	ldaa	#$02
	oraa	X018C
	staa	X018C	; set bit1
	bsr	sub046
LBA41:
	rts
;===============================================================================
; Temperature measurement in C
; result returned in array 0167
subMathFcnTempC:
	clr	AccumRegister0
	ldaa	#$67
	ldab	#$01			; 0167 = base address of AccumRegister
	psha
	pshb
	ldaa	#$35
	ldab	#$F9	; F935 = 00 03 70 78 01 87 07 = 3.798E6
	psha
	pshb
	ldaa	#$B1
	ldab	#$01
	psha
	pshb
	ldaa	#$03
	psha
	jsr	subRegisterSubtract	; 01B1 = 0167 - F935

	ldaa	#$3C
	ldab	#$F9	; F93C = 00 09 26 55 48 87 02
	psha
	pshb
	ldaa	#$67
	ldab	#$01
	psha
	pshb
	ldaa	#$7D
	ldab	#$01
	psha
	pshb
	ldaa	#$03
	psha
	jsr	subRegisterSubtract	; 017D = F93C - 0167

	ldaa	X01B1
	tsta
	bne	LBA80	; branch if 01B1 array negative
	jmp	LBB13
;
LBA80:
	ldaa	X017D
	tsta
	bne	LBA89	; branch if 017D array negative
	jmp	LBB0F
;
LBA89:
	ldaa	#$27
	ldab	#$F9	; F927 = 00 03 13 40 00 00 04
	psha
	pshb
	ldaa	#$67
	ldab	#$01
	psha
	pshb
	ldaa	#$D1
	ldab	#$01	; base address of MeasArray
	psha
	pshb
	ldaa	#$03
	psha
	jsr	subRegisterSubtract	; 01D1 = F927 - 0167
	ldaa	MeasArray0
	inca
	ldx	#$0007
	stx	X0002
	clrb
	jsr	sub142
	staa	MeasArray0
	jsr	sub038
	ldaa	#$67
	ldab	#$01
	psha
	pshb
	ldaa	MeasArray0
	clrb
	adda	#$FD
	adcb	#$F8	; F8FD = FF 02 93 62 48 15 01
	psha		; F904 = FF 02 58 49 98 68 01
	pshb
	ldaa	#$67
	ldab	#$01
	psha
	pshb
	ldaa	#$03
	psha
	jsr	subRegisterSubtract	; 0167 = 0167 - F8FD
	ldaa	MeasArray0
	clrb
	adda	#$0B
	adcb	#$F9	; F90B = 00 02 30 79 75 58 04
	psha		; F912 = 00 02 06 34 99 98 04
	pshb
	ldaa	#$67
	ldab	#$01
	psha
	pshb
	psha
	pshb
	ldaa	#$03
	psha
	jsr	subRegisterDivide	; 0167 = F90B / 0167
	ldaa	#$67
	ldab	#$01
	psha
	pshb
	ldaa	MeasArray0
	clrb
	adda	#$19
	adcb	#$F9	; F919 =  00 03 22 80 76 84 03
	psha		; F920 = 00 03 03 33 01 82 03
	pshb
	ldaa	#$67
	ldab	#$01
	psha
	pshb
	ldaa	#$03
	psha
	jsr	subRegisterSubtract	; 0167 = 0167 - F919
	ldaa	#$0C
	staa	X019C
	rts

LBB0F:			; 017D array was positive
	jsr	sub036
	rts

LBB13:			; 01B1 array was positive
	jsr	sub035
	rts
;===============================================================================
; 20 LOG X/Y function
subMathFcn20LogXY:
	ldaa	RegisterY1	; byte 1 of Y register
	tsta
	bne	LBB22
	jmp	LBB56
;
LBB22:
	ldaa	#$67
	ldab	#$01			; 0167 = base address of AccumRegister
	psha
	pshb
	ldaa	#$36
	ldab	#$01
	psha
	pshb
	ldaa	#$67
	ldab	#$01
	psha
	pshb
	ldaa	#$03
	psha
	jsr	subRegisterDivide	; 0167 = 0167 / 0136
	jsr	sub038
	ldaa	#$67
	ldab	#$01
	psha
	pshb
	psha
	pshb
	psha
	pshb
	ldaa	#$03
	psha
	jsr	subRegisterAdd		; 0167 = 0167 + 0167 -> x 2
	inc	AccumRegister6		; inc exponent -> x 10
	ldaa	#$0C
	staa	X019C
	rts

LBB56:
	jsr	sub036
	rts
;===============================================================================
; Temperature measurement and conversion from C to F
; result placed in 0167 array
subMathFcnTempF:
	jsr	subMathFcnTempC
	ldaa	#$4A
	ldab	#$F9	;F94A : 00 01 80 00 00 00 01 = 1.8
	psha
	pshb
	ldaa	#$67
	ldab	#$01			; 0167 = base address of AccumRegister
	psha
	pshb
	psha
	pshb
	ldaa	#$03
	psha
	jsr	subRegisterMultiply	; 0167 = F94A * 0167
	ldaa	#$67
	ldab	#$01
	psha
	pshb
	ldaa	#$43
	ldab	#$F9	; F943 = 00 03 20 00 00 00 02 = 32
	psha
	pshb
	ldaa	#$67
	ldab	#$01
	psha
	pshb
	ldaa	#$03
	psha
	jsr	subRegisterAdd	; 0167 = 0167 + F943
	rts
;===============================================================================

sub051:
	ldaa	#$40
	anda	ioKBrdStrb
	tsta
	beq	LBB9F
	ldaa	flag010B
	rora
	bcc	LBB9F
	jsr	sub026
LBB9F:
	rts
;---------------------------------
; This initiates a measurement handshake to the Inguard.
subCheckIfIGReadyToMeasure:
	clr	ioIsoLogic	; sends 00 to Inguard
	ldx	#$FA00
	stx	x0117
	ldaa	x0118
	ldab	x0117
	psha
	pshb
	ldaa	#$01
	psha			; stack has 01 FA 00
	jsr	subWaitForIGStatus
	ldaa	flagInguardTimeout	; has value FF if timed out waiting for Inguard
	tsta
	beq	LBBC2
	jsr	subHandleIGTimeout	; deal with timeout
LBBC2:				; didn't time out
	ldaa	#$F1
	cmpa	ioIsoLogic
	beq	LBBCC		; if Inguard returned F1, goto return, appears to be code from IG that it's ready to measure.
	jsr	subHandleIGTimeout	; else deal with it
LBBCC:
	rts
;===============================================================================

subGetInguardReading:
	ldaa	#$10
	staa	ioHPIB_r0	; turn off interrupts from HPIB
	sei			; disable keyboard interrupts
	ldaa	#$F0
	staa	ioIsoLogic	; tell Inguard to take reading
	clra
	psha
	jsr	subWaitForIGbyte
	ldaa	ioIsoLogic
	staa	InguardByte0

	; first byte MSB = 1 indicates the measurement polarity is positive
	bpl	LBBEB		; branch if bit7 from inguard = 0
	ldaa	#$FF
	bra	LBBEC
LBBEB:
	clra
LBBEC:				; A = 00 if negative polarity, else FF
	rora			; LSB -> C
	bcc	LBBF6		; branch if C = 0, i.e., negative
	ldaa	#$99
	staa	x0119
	bra	LBBF9
;
LBBF6:
	clr	x0119
LBBF9:				; x0119 = 00 if negative polarity, else FF
	clra
	psha			; push 00 on stack
	jsr	subWaitForIGbyte
	ldaa	ioIsoLogic
	staa	InguardByte1
	clra
	psha
	jsr	subWaitForIGbyte
	ldaa	ioIsoLogic
	staa	InguardByte2
	clra
	psha
	jsr	subWaitForIGbyte
	ldaa	ioIsoLogic
	staa	InguardByte3
	cli			; enable keyboard interrupts
	ldaa	HPIBIntrMask
	staa	ioHPIB_r0	; set interrupts from HPIB to previous state
	ldaa	flagInguardTimeout ; = 00 if no timeout
	tsta
	beq	LBC2A
	jsr	subHandleIGTimeout	; inguard did time out
LBC2A:
	ldaa	flagNumPLCcode
	cmpa	#$03
	bls	LBC6B		; branch if flagNumPLCcode <= 03
	ldab	InguardByte3	; if PLC = 100, accumulate readings in AccumRegister
	addb	AccumRegister0
	tba			; B -> A
	daa			; convert addition result to BCD
	staa	AccumRegister0
	ldaa	InguardByte2
	adca	AccumRegister1
	daa
	staa	AccumRegister1
	ldaa	InguardByte1
	adca	AccumRegister2
	daa
	staa	AccumRegister2
	ldaa	InguardByte0
	adca	AccumRegister3
	daa
	staa	AccumRegister3
	ldaa	x0119		; x0119 = 00 if negative polarity, else FF
	adca	AccumRegister4
	daa
	staa	AccumRegister4	; extra digit for overflows when accumulating readings
	bra	LBC83
;
LBC6B:				; for PLC < 100, put reading directly into MeasArray
	ldaa	InguardByte3
	staa	MeasArray0
	ldaa	InguardByte2
	staa	MeasArray1
	ldaa	InguardByte1
	staa	MeasArray2
	ldaa	InguardByte0
	staa	MeasArray3
LBC83:
	rts
;===============================================================================
; Zeros contents of MeasArray.
subZeroMeasArray:
	clr	MeasArray0
	clr	MeasArray1
	clr	MeasArray2
	clr	MeasArray3
	clr	MeasArray4
	clr	MeasArray5
	clr	MeasArray6
	clr	MeasArray7
	rts
;===============================================================================
; separates pairs of BCD digits in MeasArray0-3 to individual digits MeasArray0-7
subUnpackMeasArray:
	ldaa	MeasArray3
	lsra
	lsra
	lsra
	lsra
	staa	MeasArray7	; high nibble
	ldaa	#$0F
	anda	MeasArray3
	staa	MeasArray6	; low nibble
	ldaa	MeasArray2
	lsra
	lsra
	lsra
	lsra
	staa	MeasArray5
	ldaa	#$0F
	anda	MeasArray2
	staa	MeasArray4
	ldaa	MeasArray1
	lsra
	lsra
	lsra
	lsra
	staa	MeasArray3
	ldaa	#$0F
	anda	MeasArray1
	staa	MeasArray2
	ldaa	MeasArray0
	lsra
	lsra
	lsra
	lsra
	staa	MeasArray1
	ldaa	#$0F
	anda	MeasArray0
	staa	MeasArray0
	ldaa	#$01
	staa	flagMeasArrayUnpacked	; = true
	ldaa	#$03
	anda	IGCmdRegister4
	staa	X011B		; bit0-1
	ldaa	flagNumPLCcode
	cmpa	#$01
	bcc	LBD00
	jsr	subShiftMeasArrayLeft
LBD00:
	ldaa	flagNumPLCcode
	cmpa	#$02
	bcc	LBD0F
	jsr	subShiftMeasArrayLeft
LBD0F:
	ldaa	flagNumPLCcode
	cmpa	#$03
	bcc	LBD19
	jsr	subShiftMeasArrayLeft
LBD19:
	rts
;===============================================================================
; Shifts MeasArray digits on right of decimal position right (MeasArray1 --> MeasArray0, etc)
; and puts 2E (ASCII ".") in proper display position (= 01D1 + DecimalDisplayPosition).
; DecimalDisplayPosition = 6 for "1" position on display, 5 for "10",
; 4 for "100" and 3 for "1K" positions.
; Inputs: DecimalDisplayPosition, X0198, X078C
; This is where the 7th digit is lost.
subInsertDisplayDecimal:
	ldaa	#$10
	anda	X0198
	tsta
	beq	LBD30	; branch if X0198 bit4 = 0
	ldaa	X078C
	cmpa	#$05
	bls	LBD30
	ldab	#$05
	stab	DecimalDisplayPosition	; if X078C >5, DecimalDisplayPosition = 5
LBD30:
	; ***** MODDED save the least significant digit before it is lost below *****
	ldaa	MeasArray0
	staa	Digit7
	; end mod

	clr	x011C	; loop index = 0,1,...
LBD33:
	ldaa	DecimalDisplayPosition
	deca
	cmpa	x011C
	bcs	LBD63	; branch out of loop if x011C > DecimalDisplayPosition
	ldaa	#$D1
	ldab	#$01	; base address of MeasArray
	adda	x011C
	adcb	#$00
	staa	x0049
	stab	x0048
	ldaa	x011C
	inca
	clrb
	adda	#$D1
	adcb	#$01
	staa	x004D
	stab	x004C
	ldx	x004C
	ldaa	$00,x	; MeasArray[i+1]
	ldx	x0048
	staa	$00,x	; MeasArray[i]	MeasArray0 will be overwritten, deleting 7th digit
	inc	x011C
	bra	LBD33
;
LBD63:
	ldaa	#$D1
	ldab	#$01
	adda	DecimalDisplayPosition
	adcb	#$00
	staa	x0049
	stab	x0048
	ldaa	#$2E	; ASCII "."
	ldx	x0048
	staa	$00,x
	rts
;===============================================================================
; Adds value BCDRoundupValue to packed MeasArray, uses BCD addition to propagate through array.
subBCDRoundup:
	ldaa	BCDRoundupValue
	adda	MeasArray0
	daa
	staa	MeasArray0
	ldaa	MeasArray1
	adca	#$00
	daa
	staa	MeasArray1
	ldaa	MeasArray2
	adca	#$00
	daa
	staa	MeasArray2
	ldaa	MeasArray3
	adca	#$00
	daa
	staa	MeasArray3
	rts
;===============================================================================
; Takes packed data in MeasArray0-3, determines polarity and uncompliments complimented
; data from Inguard.
subMeasSignNCompliment:
	ldaa	MeasArray1
	oraa	MeasArray0
	oraa	MeasArray3
	oraa	MeasArray2
	staa	MeasArrayORd
	ldaa	MeasArrayORd
	tsta
	bne	LBDBD		; branch if any MeasArray != 0
	ldab	#$2B		; ASCII "+"
	stab	MeasPolaritySign	; MeasPolaritySign = "+" if measurement bytes 1-4 are all 00
	bra	LBE1D		; no need to process all zeros
;

LBDBD:				; MeasArray has data
	ldaa	#$80
	anda	MeasArray3
	tsta
	beq	LBE04		; branch if bit7 = 0

	ldaa	#$10
	anda	IGCmdRegister1
	cmpa	#$10
	bne	LBDD5		; branch if IGCmdRegister1 bit4 != 0
	ldaa	#$2B
	staa	MeasPolaritySign	; "+" if IGCmdRegister1 bit4 = 0
	bra	LBDDA
LBDD5:
	ldaa	#$2D
	staa	MeasPolaritySign	; "-" if IGCmdRegister1 bit4 = 1

LBDDA:
	ldaa	#$99		; data arrives from Inguard in 10's compliment form
	suba	MeasArray3	; so convert first to 9's compliment
	staa	MeasArray3
	ldaa	#$99
	suba	MeasArray2
	staa	MeasArray2
	ldaa	#$99
	suba	MeasArray1
	staa	MeasArray1
	ldaa	#$99
	suba	MeasArray0
	staa	MeasArray0
	ldaa	#$01
	staa	BCDRoundupValue	; then add 1 to get uncomplimented values
	jsr	subBCDRoundup
	bra	LBE1D

LBE04:				; reach here if MeasArray3 bit7 = 0.  does it mean MeasArray is not in compliment form?
	ldaa	#$10
	anda	IGCmdRegister1
	tsta
	bne	LBE18
	ldaa	#$2B		; "+" if IGCmdRegister1 bit4 = 0
	staa	MeasPolaritySign
	bra	LBE1D
LBE18:
	ldaa	#$2D		; ASCII "-"
	staa	MeasPolaritySign
LBE1D:
	ldaa	flagNumPLCcode	; # power line cycles to integrate = 0,1,2,3,4 for .01,.1,1,10,100
	cmpa	#$02
	bls	LBE2C		; do a roundup for 10 & 100 PLC cases

	;***** MODDED don't round up if the 7th digit will be displayed
	ldaa	flag7Digits
	bne	LBE2C		; branch over roundup if in in 7 digit mode
	; end mod

	ldab	#$05
	stab	BCDRoundupValue
	jsr	subBCDRoundup
LBE2C:
	rts
;---------------------------------

subProcessMeasurement:
	jsr	subMeasSignNCompliment
	jsr	subUnpackMeasArray
	jsr	subInsertDisplayDecimal
	jsr	sub015
	jsr	subCopyMeasToAccumReg
	rts
;---------------------------------

sub060:
	ldaa	#$10
	anda	IGCmdRegister1
	tsta
	bne	LBEB0			; branch if bit4 = 1
	jsr	subCheckIfIGReadyToMeasure
	jsr	subZeroMeasArray
	ldaa	#$04
	cmpa	flagNumPLCcode		; 4 is the code for PLC = 100
	bne	LBE65
	ldab	#$03			; 3 is code for 10 PLC.  This change causes subGetInguardReading to put reading into MeasArra
	stab	flagNumPLCcode
	jsr	subGetInguardReading
	ldaa	#$04
	staa	flagNumPLCcode
	bra	LBE68
;
LBEB0:
	jmp	LBEF2
LBE65:
	jsr	subGetInguardReading
LBE68:
	ldaa	#$15
	cmpa	MeasArray3		; this is the first (most signifcant) byte from the IG, in 10's compliment form
	bne	LBE76
	ldab	#$01
	stab	X010C
	bra	LBE9F
;
LBE76:
	jsr	sub027
	bsr	subProcessMeasurement
	ldaa	flagOverrange_Maybe
	staa	x0119
	clr	flagOverrange_Maybe
	jsr	subTestForOverrange_Maybe
	ldaa	flagOverrange_Maybe
	staa	X010C
	ldaa	x0119
	staa	flagOverrange_Maybe
	ldaa	X01A7
	staa	MeasExponentSign
	ldaa	X01A6
	staa	MeasExponent
LBE9F:				; is this a post measurement test the IG is working correctly?
	ldaa	InguardCmd
	oraa	#$01
	anda	#$FD
	staa	InguardCmd	; clear bit1, set bit0
	ldaa	InguardCmd
	staa	ioIsoLogic	; send to Inguard
	ldx	#$00AA
	stx	x0117
	ldaa	#$10
	staa	ioHPIB_r0	; turn off interrupts from HPIB
	sei			; turn off keyboard interrupts
	ldaa	x0118
	ldab	x0117
	psha
	pshb
	ldaa	#$01
	psha			; stack has 01 00 AA
	jsr	subWaitForIGStatus
	cli			; turn on keyboard interrupts
	ldaa	HPIBIntrMask
	staa	ioHPIB_r0 	; resets interrupts from HPIB
	ldaa	flagInguardTimeout ; = 00 if no timeout
	tsta
	beq	LBEE3
	jsr	subHandleIGTimeout	; deal with timeout
LBEE3:
	ldaa	#$EF
	anda	ioIsoLogic	; clear bit4
	cmpa	InguardCmd	; Inguard returns cmd if it's OK
	beq	LBEF0
	jsr	subHandleIGTimeout
LBEF0:
	rts
;
LBEF2:
	clr	X010C
	ldaa	#$0F
	psha
	clrb
	pshb
	ldaa	#$01
	psha		; 01, 00, 0F on stack
	jsr	subProgrammedDelay
	rts
;---------------------------------

sub061:
	ldaa	#$F1
	anda	IGCmdRegister0
	staa	IGCmdRegister0	; clear bits3-1
	ldaa	#$06
	oraa	IGCmdRegister0
	staa	IGCmdRegister0	; set bits3-2
	ldaa	#$F1
	anda	CopyOfIGCmdByte
	staa	CopyOfIGCmdByte	; clear bits3-1
	ldaa	#$06
	oraa	CopyOfIGCmdByte
	staa	CopyOfIGCmdByte	; set bits3-2
	ldaa	CopyOfIGCmdByte
	lsra
	suba	#$10
	staa	X011B
	ldaa	#$AF
	ldab	#$F6
	;F6AF : 00 11 15 19
	adda	X011B
	adcb	#$00
	staa	x0049
	stab	x0048
	ldx	x0048
	ldaa	$00,x
	staa	InguardStatus
	rts
;---------------------------------
; sends command to Inguard and waits for status byte returned
; called from Sub063
sub062:
	ldaa	ioIsoLogic
	staa	InguardStatus
	ldaa	InguardCmd
	staa	ioIsoLogic
	ldx	#$00AA
	stx	x0117
	ldaa	x0118
	ldab	x0117
	psha
	pshb
	ldaa	#$01
	psha			; stack has 01 00 AA
	jsr	subWaitForIGStatus	; waits for status data from Inguard
	ldaa	flagInguardTimeout	; = 00 if no timeout
	tsta
	beq	LBF6C
	jsr	subHandleIGTimeout
LBF6C:
	ldaa	ioIsoLogic	; read byte from Inguard
	staa	InguardStatus
	ldaa	#$10
	anda	InguardStatus
	cmpa	#$10
	bne	LBF8A
	ldaa	#$EF		; if bit4 was set
	anda	InguardStatus
	staa	InguardStatus	; clear bit4
	ldaa	#$01
	staa	X011E		; = 01
	bra	LBF8D
;
LBF8A:
	clr	X011E		; = 00
LBF8D:
	rts
;===============================================================================

sub063:
	ldaa	#$40
	anda	ioHPIB_r1	; bit6 set if meter in HPIB Remote mode
	staa	x011C		; = 40 if unit in HPIB Remote mode, else 00
	ldaa	IGCmdRegister1	; from table lookups
	asla
	asla
	staa	InguardStatus
	ldaa	#$10
	anda	IGCmdRegister1
	tsta
	bne	LBFEC		; branch if bit4 = 1
	ldaa	IGCmdRegister0
	anda	#$10
	tsta
	beq	LBFD0		; branch if bit4 = 0
	ldaa	flagTestMode
	tsta
	bne	LBFD0		; branch if flagTestMode = 1
	ldab	x011C
	tstb
	bne	LBFC8		; branch if in Remote mode
	ldaa	#$10
	oraa	IGCmdRegister1
	staa	IGCmdRegister1	; set bit4
	bra	sub063		; back to top
;
LBFC8:
	ldaa	#$01
	staa	ErrorNumber
	jsr	subDisplayError
LBFD0:
	ldaa	#$07
	anda	IGCmdRegister1
	cmpa	#$02
	bls	LBFE0
	ldaa	#$8C
	staa	InguardCmd
	bra	LC00B
;
LBFE0:
	ldaa	#$0C
	anda	InguardStatus
	oraa	#$80
	staa	InguardCmd
	bra	LC00B
;
LBFEC:
	ldaa	#$07
	anda	IGCmdRegister1
	cmpa	#$02
	bls	LC001
	ldaa	#$8F
	staa	InguardCmd
	bra	LC00B
;
LC001:
	ldaa	#$0C
	anda	InguardStatus
	oraa	#$83
	staa	InguardCmd


LC00B:
	ldaa	#$E0
	anda	IGCmdRegister0
	ldab	#$08
	andb	IGCmdRegister1
	staa	x0048
	orab	x0048
	stab	x011F
	ldaa	#$A8
	clrb
	cmpa	x011F
	bne	LC025
	decb
LC025:
	ldaa	#$C8
	stab	x0048
	clrb
	cmpa	x011F
	bne	LC030
	decb
LC030:
	orab	x0048
	rorb
	bcc	LC050
	ldab	x011C
	tstb
	bne	LC048		; branch if in Remote mode
	ldaa	#$F7
	anda	IGCmdRegister1
	staa	IGCmdRegister1
	jmp	sub063
LC046:
	bra	LC050
;
LC048:
	ldaa	#$02
	staa	ErrorNumber
	jsr	subDisplayError
LC050:
	ldaa	#$20
	anda	InguardStatus
	oraa	InguardCmd
	staa	InguardCmd
	jsr	sub062		; sends cmd to Inguard, returns status
	ldaa	InguardStatus
	cmpa	InguardCmd
	beq	LC069		; OK status must be to return cmd
	jsr	subHandleIGTimeout
LC069:
	ldaa	X011E
	rora
	bcc	LC079
	ldaa	#$20		; if X011E was 1,
	oraa	IGCmdRegister1
	staa	IGCmdRegister1	; set bit5
	rts
;
LC079:
	ldaa	#$DF
	anda	IGCmdRegister1
	staa	IGCmdRegister1	; else clear bit5
	rts
;---------------------------------
; called from sub065
;
;F6AF : 00 11 15 19
;F6B3 : 1D 00 00 00

sub064:
	ldaa	#$02
	adda	IGCmdRegister0
	staa	IGCmdRegister0	; increase by 2
	ldaa	#$02
	adda	CopyOfIGCmdByte
	staa	CopyOfIGCmdByte
	inc	X011B
	ldaa	#$AF
	ldab	#$F6
	adda	X011B
	adcb	#$00
	staa	x0049
	stab	x0048
	ldx	x0048	; F6AF + X011B
	ldaa	$00,x
	staa	InguardStatus
	rts
;---------------------------------
; appears to send 4 bytes to Inguard to set measurement mode
sub065:
	jsr	sub063
	ldaa	CopyOfIGCmdByte
	lsra
	suba	#$10
	staa	X011B
	clrb
	adda	#$AF
	adcb	#$F6
	staa	x004D
	stab	x004C
	ldx	x004C	; F6AF + CopyOfIGCmdByte/2 - 10 (=F6C0 in one run)
	ldaa	$00,x	; (=10 in this run)
	staa	InguardStatus
	ldaa	#$0E
	anda	IGCmdRegister0	; bits3-1
	cmpa	#$06
	bls	LC0F7
	ldaa	#$F0
	anda	IGCmdRegister0	; bits7-4
	staa	x011C
	ldaa	#$B0
	clrb
	cmpa	x011C
	bne	LC0E4
	decb
LC0E4:
	ldaa	#$D0
	stab	x0048
	clrb
	cmpa	x011C
	bne	LC0EF
	decb
LC0EF:
	orab	x0048
	rorb
	bcc	LC0F7
	clr	InguardStatus
LC0F7:
	ldaa	InguardStatus
	tsta
	bne	LC163
	ldab	CopyOfIGCmdByte
	andb	#$01
	tstb
	beq	LC10A
	jsr	sub061
	bra	LC171
LC163:
	jmp	LC1BB
;
LC10A:
	ldaa	#$40
	anda	ioHPIB_r1	; bit6 set if meter in HPIB Remote mode
	tsta
	bne	LC181
	ldaa	#$EF
	anda	CopyOfIGCmdByte
	staa	x011C
	ldaa	#$40
	clrb
	cmpa	x011C
	bne	LC128
	decb
LC128:
	ldaa	#$20
	stab	x0048
	clrb
	cmpa	x011C
	bne	LC133
	decb
LC133:
	orab	x0048
	stab	X011E
	ldaa	#$0F
	anda	CopyOfIGCmdByte
	clrb
	tsta
	bne	LC142
	decb
LC142:
	andb	X011E
	rorb
	bcc	LC186
	ldaa	#$02
	oraa	IGCmdRegister0
	staa	IGCmdRegister0	; set bit1
	ldaa	#$02
	oraa	CopyOfIGCmdByte
	staa	CopyOfIGCmdByte
	ldaa	CopyOfIGCmdByte
	lsra
	suba	#$10
	staa	X011B
	ldaa	#$AF
	ldab	#$F6
	adda	X011B
	adcb	#$00
	bra	LC174
LC171:
	jmp	LC1AD
;
LC174:
	staa	x0049
	stab	x0048
	ldx	x0048
	ldaa	$00,x
	staa	InguardStatus
	bra	LC184
LC181:
	jmp	LC1AD
LC184:
	bra	LC1AD
;
LC186:
	jsr	sub061
	ldaa	#$F0
	anda	IGCmdRegister0	; bits7-4
	staa	X011E
	ldaa	#$B0
	clrb
	cmpa	X011E
	bne	LC19A
	decb
LC19A:
	ldaa	#$D0
	stab	x0048
	clrb
	cmpa	X011E
	bne	LC1A5
	decb
LC1A5:
	orab	x0048
	tstb
	bne	LC1AD
	jsr	sub064
LC1AD:
	ldaa	InguardStatus
	tsta
	bne	LC1BB
	ldab	#$03
	stab	ErrorNumber
	jsr	subDisplayError
LC1BB:
	ldaa	InguardStatus
	lsra
	lsra
	lsra
	lsra
	oraa	#$60	; set bit6-5
	staa	ioIsoLogic	; send command to Inguard
	ldaa	#$02
	psha
	clrb
	pshb
	ldaa	#$01
	psha		; 01, 00, 02 on stack
	jsr	subProgrammedDelay
	ldaa	#$0F
	anda	InguardStatus
	oraa	#$70	; set bit6-4
	staa	ioIsoLogic	; send command to Inguard
	ldaa	#$02
	psha
	clrb
	pshb
	ldaa	#$01
	psha		; 01, 00, 02 on stack
	jsr	subProgrammedDelay
	ldaa	#$0F
	ldab	#$F7
	adda	X011B
	adcb	#$00
	staa	x0049
	stab	x0048
	ldx	x0048
	ldaa	$00,x
	staa	InguardStatus
	ldaa	InguardStatus
	lsra
	lsra
	lsra
	lsra
	oraa	#$40	; set bit6
	staa	ioIsoLogic	; send command to Inguard
	ldaa	#$02
	psha
	clrb
	pshb
	ldaa	#$01
	psha		; 01, 00, 02 on stack
	jsr	subProgrammedDelay
	ldaa	#$0F
	anda	InguardStatus
	oraa	#$50
	staa	ioIsoLogic
	ldaa	#$08
	anda	IGCmdRegister1
	tsta
	beq	LC232
	ldaa	#$94
	ldab	#$11
	psha
	pshb
	ldaa	#$01
	psha		; 01, 11, 94 on stack
	jsr	subProgrammedDelay
	bra	LC23D
;
LC232:
	ldaa	#$1A
	psha
	clrb
	pshb
	ldaa	#$01
	psha		; 01, 00, 1A on stack
	jsr	subProgrammedDelay
LC23D:
	jsr	sub060
	rts
;---------------------------------

sub066:
	ldaa	#$EF
	anda	IGCmdRegister0
	staa	CopyOfIGCmdByte
	jsr	sub065
	jsr	sub028
	jsr	sub010
	rts
;===============================================================================
; Determines HPIB idle (Talker Active, Ready for Data, Output Empty) status
; Sets flagHPIBOutputStatus
subHPIB_Idle:
	ldaa	#$10
	staa	ioHPIB_r0	; turn off interrupts from HPIB
	ldaa	#$10
	anda	ioHPIB_r3	; A = 10 if interface Ready For Data
	ldab	#$40
	andb	ioHPIB_r0	; B = 40 if HPIB output register empty
	staa	x0048
	orab	x0048
	ldaa	#$08
	anda	ioHPIB_r2	; A = 08 if Talker Active state
	stab	x004C
	oraa	x004C
	staa	flagHPIBOutputStatus	; = Talker Active (08) | Ready for Data (10) | Output Empty (40)
	ldaa	HPIBIntrMask
	staa	ioHPIB_r0	; restore to previous interrupt state
	rts
;===============================================================================
; Loops until HPIB port is idle, then updates front panel. Called after a byte
; is written to ioHPIB_r7 output register.
;
subWaitForHPIB_Idle:
	ldaa	#$10
	staa	ioHPIB_r0	; turn off interrupts from HPIB
LC284:
	ldaa	#$10
	anda	ioHPIB_r3	; A = 10 if interface Ready For Data
	ldab	#$40
	andb	ioHPIB_r0	; B = 40 if HPIB output register empty
	staa	x0048
	orab	x0048
	ldaa	#$08
	anda	ioHPIB_r2	; A = 08 if Talker Active state
	stab	x004C
	oraa	x004C		; A = Talker Active (08) | Ready for Data (10) | Output Empty (40)
	cmpa	#$58
	beq	LC2B8		; branch if all three true, then return
	ldaa	flagDispNeedUpdate	; = 1 if display needs to be updated
	rora
	bcc	LC2AB		; branch if flag = 0
	jsr	subSetAnnuncByte4
	jsr	subUpdateDisplayIfReady
LC2AB:
	ldaa	HPIBIntrMask
	staa	ioHPIB_r0	; restore to previous interrupt state
	ldaa	#$10
	staa	ioHPIB_r0	; turn off interrupts from HPIB (?)
	bra	LC284
LC2B8:
	rts
;===============================================================================
; Outputs data in 01B8 to 01C4 to HPIB
;
subHPIBOutputReadingUnpacked:
	clr	x01B0	; loop index
LC2BE:
	ldaa	x01B0	; 0 to B, 12 iterations
	cmpa	#$0B
	bhi	LC2E0
	ldaa	#$B8
	ldab	#$01
	adda	x01B0
	adcb	#$00
	staa	x0049
	stab	x0048
	ldx	x0048	; 01B8 to 01C4
	ldaa	$00,x
	staa	ioHPIB_r7	; send out on HPIB
	bsr	subWaitForHPIB_Idle

	;***** MODDED to output 7th digit *****
	ldaa	x01B0
	cmpa	#$08		; has last digit of the mantissa just been output?
	bne	LC2BF		; branch if no
	ldaa	flag7Digits	; are we in 7 display digit mode?
	beq	LC2BF		; branch if no
	ldaa	Digit7
	adda	#$30		; convert to ASCII
	staa	ioHPIB_r7	; slip 7th digit into output
	bsr	subWaitForHPIB_Idle
	; end mod
LC2BF:
	inc	x01B0
	bra	LC2BE
LC2E0:
	rts
;===============================================================================
;
subHPIBOutputReadingPacked:

	ldaa	FormattedReading2
	staa	ioHPIB_r7
	bsr	subWaitForHPIB_Idle
	ldaa	FormattedReading3
	staa	ioHPIB_r7
	bsr	subWaitForHPIB_Idle
	ldaa	FormattedReading4
	staa	ioHPIB_r7
	bsr	subWaitForHPIB_Idle
	rts
;===============================================================================
; Outputs a measurement on HPIB whether packed or unpacked, single or multiple
; readings.
subHPIBOutputMeasurement:

	ldaa	HPIBIntrMask
	staa	ioHPIB_r0
	ldaa	#$80
	anda	IGCmdRegister4
	tsta
	beq	LC34B		; branch if bit7 = 0
	;--- code block, output 0 or 1 and return
	ldaa	#$20
	anda	IGCmdRegister1
	tsta
	beq	LC31B
	ldaa	#$30		; ASCII "0"
	staa	x01CA
	bra	LC320
;
LC31B:
	ldaa	#$31		; ASCII "1"
	staa	x01CA
LC320:
	ldaa	#$7F
	anda	IGCmdRegister4
	staa	IGCmdRegister4	; clear bit3
	ldaa	x01CA
	staa	ioHPIB_r7
	jsr	subWaitForHPIB_Idle
	ldaa	#$0D		; ASCII [cr]
	staa	ioHPIB_r7
	jsr	subWaitForHPIB_Idle
	ldaa	flagOutputEOI
	rora
	bcc	LC344
	ldaa	#$20
	staa	ioHPIB_r3	; puts EOI signal on HPIB
LC344:
	ldaa	#$0A		; ASCII [lf]
	staa	ioHPIB_r7
	bra	LC3B2
	;--- end code block
;
LC34B:	;--- code block output packed reading
	ldaa	flagMeasFormatted
	rora
	bcc	LC3B2		; rts if flagMeasFormatted = 0
	jsr	subSetAnnuncByte4
	ldaa	flagHPIBPackedOutput
	rora
	bcc	LC388		; branch if unpacked output
	ldaa	#$10
	anda	flagX0121
	tsta
	beq	LC372		; branch if flagX0121 bit4 = 0
	jsr	subHPIBOutputReadingPacked	; outputs packed data without EOI
	ldaa	FormattedReading5
	staa	ioHPIB_r7
	bra	LC3B2
;
LC372:
	jsr	subHPIBOutputReadingPacked	; outputs packed data perhaps with EOI
	ldaa	flagOutputEOI
	rora
	bcc	LC380
	ldaa	#$20
	staa	ioHPIB_r3	; puts EOI signal on HPIB
LC380:
	ldaa	FormattedReading5
	staa	ioHPIB_r7
	bra	LC3B2
	;--- end code block

LC3B2:
	jmp	LC3F7
;
LC388:	;--- code block output unpacked data
	ldaa	flagHPIBPackedOutput		; already tested above
	tsta
	bne	LC3F7		; should never occur
	ldab	#$10
	andb	flagX0121
	tstb
	beq	LC3BF		; branch if flagX0121 bit4 = 0
	ldab	#$80
	andb	flagHPIBOutput	; bit7 = 1 means output multiple readings, comma separated
	tstb
	beq	LC3A8		; branch if bit7 = 0
	ldab	#$2C		; ASCII ","
	stab	ioHPIB_r7
	jsr	subWaitForHPIB_Idle
	jsr	subHPIBOutputReadingUnpacked
	bra	LC3F7
;
LC3A8:
	ldaa	#$80
	oraa	flagHPIBOutput
	staa	flagHPIBOutput	; set bit7
	jsr	subHPIBOutputReadingUnpacked
	bra	LC3F7
;
LC3BF:
	ldaa	#$80
	anda	flagHPIBOutput
	tsta
	beq	LC3CF		; branch if bit7 = 0
	ldaa	#$2C		; ASCII ","
	staa	ioHPIB_r7
	jsr	subWaitForHPIB_Idle
LC3CF:
	jsr	subHPIBOutputReadingUnpacked
	ldaa	#$0D		; ASCII [cr]
	staa	ioHPIB_r7
	jsr	subWaitForHPIB_Idle
	ldaa	flagOutputEOI
	rora
	bcc	LC3E5
	ldaa	#$20
	staa	ioHPIB_r3	; puts EOI signal on HPIB
LC3E5:
	ldaa	#$0A		; ASCII [lf]
	staa	ioHPIB_r7
	ldaa	#$7F
	anda	flagHPIBOutput	; clear bit7
	staa	flagHPIBOutput
LC3F7:
	clr	flagMeasFormatted
	ldaa	#$FB
	staa	HPIBSerialPollMask
	jsr	subUpdateHPIBSerialPoll
	rts
;===============================================================================
; If the HPIB is idle, outputs a measurement, otherwise just returns.
subOutputMeasWhenHPIBReady:
	clr	flagHPIBOutputStatus
	jsr	subHPIB_Idle	; Determines HPIB idle (not busy) status
	ldaa	#$58		; 58 means idle
	cmpa	flagHPIBOutputStatus
	bne	LC415		; branch if HPIB still busy
	jsr	subHPIBOutputMeasurement
LC415:
	rts
;===============================================================================

sub073:
	jsr	subSetAnnuncBytes123
	jsr	subSetAnnuncByte4
	jsr	subUpdateDisplayIfReady
	bsr	subOutputMeasWhenHPIBReady
	rts
;---------------------------------

subClearDisplay:
	clr	DisplayArray7
	ldaa	#$0A		; 0A will display dashes
	staa	DisplayArray6
	staa	DisplayArray5
	staa	DisplayArray4
	staa	DisplayArray3
	staa	DisplayArray2
	staa	DisplayArray1
	staa	DisplayArray0
	clr	DisplayPolaritySign
	clr	flagDisplayHasExponent
	clr	DisplayExponentSign
	clr	flagDisplayArrayHasNoDecimal
	jsr	subAnnuncNDisplayUpdate
	rts
;---------------------------------

sub075:
	ldaa	#$02
	anda	flagX0121
	cmpa	#$02
	bne	LC4DB		; return if bit1 = 0
	ldaa	X012E
	staa	InguardByte3
	ldaa	X012D
	staa	InguardByte2
	ldaa	X012C
	staa	InguardByte1
	ldaa	flag010B
	rora
	bcc	LC482
	jsr	subSetAnnuncBytes123
	jsr	subSetAnnuncByte4
	jsr	sub026
	jsr	subAnnuncNDisplayUpdate
	clr	flag010B
LC482:
	ldaa	InguardByte2
	oraa	InguardByte1
	oraa	InguardByte3
	tsta
	beq	LC4DB		; return if bytes2-4 all zero
	ldaa	#$0D
	psha
	clrb
	pshb
	ldaa	#$01
	psha			; 01, 00, 0D on stack
	jsr	subProgrammedDelay
	ldaa	#$99		; Inguard sends bytes as compliments
	adda	InguardByte3
	daa			; BCD adjust
	staa	InguardByte3
	ldaa	#$99
	adca	InguardByte2
	daa
	staa	InguardByte2
	ldaa	#$99
	adca	InguardByte1
	daa
	staa	InguardByte1
	clr	X011B		; duplicates for timing?
	clr	X011B
	clr	X011B
	clr	X011B
	clr	X011B
	clr	X011B
	clr	X011B
	clr	X011B
	clr	X011B
	bra	LC482		; looping back here.  Does an interrupt put data into InguardByte1-4?
LC4DB:
	rts
;---------------------------------

sub076:
	ldaa	#$40
	anda	ioKBrdStrb
	tsta
	beq	LC4EC
	jsr	sub051
	jsr	sub073
LC4EC:
	rts
;---------------------------------

sub077:
	ldaa	#$01
	staa	x011C
	ldaa	#$08
	anda	flagX0121
	cmpa	#$08
	bne	LC541
	clr	x011C
	ldaa	X012A
	clrb
	cmpa	X018F
	beq	LC50A
	decb
LC50A:
	ldaa	X012B
	stab	x0048
	clrb
	cmpa	X018E
	beq	LC516
	decb
LC516:
	orab	x0048
	rorb
	bcc	LC541
	ldab	IGCmdRegister1
	andb	ioHPIB_r4
	andb	#$40		; bit6 set means an external trigger input has occurred
	tstb
	beq	LC53C
	ldab	#$08		; deal with external trigger
	stab	HPIBSerialPollStatus
	jsr	subHPIBRequestService
	ldaa	X012A
	staa	X018F
	ldaa	X012B
	staa	X018E
	bra	LC541
;
LC53C:
	ldaa	#$01
	staa	flagHPIBByteInIntr
LC541:
	ldaa	#$C0
	anda	IGCmdRegister1
	staa	x0119
	cmpa	#$40
	bne	LC582
	ldab	ioHPIB_r4
	andb	#$40		; bit6 set means an external trigger input has occurred
	tstb
	beq	LC562
	ldab	#$08		; deal with external trigger
	stab	HPIBSerialPollStatus
	jsr	subHPIBRequestService
LC562:
	ldaa	#$40
	anda	ioHPIB_r4
	oraa	flagHPIBByteInIntr
	tsta
	bne	LC572
	jsr	sub076
	bra	LC562
;
LC572:
	clr	ioIOreset
	ldaa	#$0C
	psha
	clrb
	pshb
	ldaa	#$01
	psha		; 01, 00, 0C on stack
	jsr	subProgrammedDelay
	bra	LC5A6
;
LC582:
	ldaa	#$80
	clrb
	cmpa	x0119
	bne	LC58B
	decb
LC58B:
	ldaa	#$C0
	stab	x0048
	clrb
	cmpa	x0119
	bne	LC596
	decb
LC596:
	orab	x0048
	tstb
	beq	LC5A6
LC59B:
	ldaa	flagHPIBByteInIntr
	tsta
	bne	LC5A6
	jsr	sub076
	bra	LC59B
;
LC5A6:
	clr	flagHPIBByteInIntr
	ldaa	x011C
	tsta
	bne	LC5FF
	ldab	#$10
	orab	flagX0121
	stab	flagX0121
	ldaa	X018F
	clrb
	tsta
	bne	LC5BF
	decb
LC5BF:
	ldaa	X018E
	stab	x0048
	clrb
	cmpa	#$01
	bne	LC5CA
	decb
LC5CA:
	andb	x0048
	rorb
	bcc	LC5E5
	ldab	#$EF
	andb	flagX0121
	stab	flagX0121
	ldaa	X012A
	staa	X018F
	ldaa	X012B
	staa	X018E
	bra	LC5FF
;
LC5E5:
	ldaa	#$10
	oraa	flagX0121
	staa	flagX0121
	ldaa	#$99
	adda	X018E
	daa
	staa	X018E
	ldaa	#$99
	adca	X018F
	daa
	staa	X018F
LC5FF:
	rts
;---------------------------------
; inputs MeasArray0-3 in raw packed and complimented form
sub078:
	jsr	subMeasSignNCompliment
	ldaa	MeasArrayORd	; MeasArray0-3 (packed bytes) or'd together
	tsta
	beq	LC626		; branch if MeasArray are all 00
	ldab	#$10
	andb	X0198
	tstb
	beq	LC626		; branch if X0198 bit4 = 0
	ldab	#$2B		; ASCII "+"
	cmpb	MeasPolaritySign
	bne	LC621

	ldaa	#$2D		; ASCII "-"
	staa	MeasPolaritySign	; if if X0198 bit4 != 0 and MeasPolaritySign = "+", make it "-"
	bra	LC626

LC621:				; X0198 bit4 = 0 and MeasPolaritySign != "+"
	ldaa	#$2B		; make MeasPolaritySign "+"
	staa	MeasPolaritySign

LC626:
	ldaa	MeasPolaritySign
	lsra			; = 0x15 or 0x16 (or 00 if MeasArray all 00?)
	staa	InguardStatus
	ldaa	#$02
	anda	InguardStatus
	staa	InguardStatus	; = 00 (if "+") or 02 (if "-")
	ldaa	X0124
	oraa	InguardStatus
	staa	InguardStatus
	ldaa	flagNumPLCcode
	tsta
	bne	LC65D
	ldab	MeasArray2	; PLC = .01, 4 digits maximum can be diplayed
	andb	#$01		; overrange digit must be in MeasArray2 lower nibble
	orab	InguardStatus
	stab	FormattedReading2
	ldaa	MeasArray1
	staa	FormattedReading3
	ldaa	MeasArray0
	staa	FormattedReading4
	jmp	LC742
;
;
LC65D:
	ldaa	flagNumPLCcode
	cmpa	#$01
	bne	LC6B8
	ldab	MeasArray2	; PLC = .1, 5 digits maximum can be diplayed
	lsrb
	lsrb
	lsrb
	lsrb
	andb	#$01		; overrange digit must be in MeasArray2 higher nibble
	orab	InguardStatus
	stab	FormattedReading2
	ldaa	#$0F
	anda	MeasArray2
	asla
	asla
	asla
	asla
	ldab	#$F0
	andb	MeasArray1
	lsrb
	lsrb
	lsrb
	lsrb
	staa	x004A
	orab	x004A
	stab	FormattedReading3
	ldaa	#$0F
	anda	MeasArray1
	asla
	asla
	asla
	asla
	ldab	#$F0
	andb	MeasArray0
	lsrb
	lsrb
	lsrb
	lsrb
	staa	x004A
	orab	x004A
	stab	FormattedReading4
	ldaa	#$0F
	anda	MeasArray0
	asla
	asla
	asla
	asla
	staa	FormattedReading5
	jmp	LC742
;
LC6B8:				; PLC = 1,10 or 100 so 6 digits maximum can be diplayed
	ldaa	#$02
	cmpa	flagNumPLCcode
	bne	LC6E3
	ldab	MeasArray3	; here for PLC = 1
	andb	#$01
	orab	InguardStatus
	stab	FormattedReading2
	ldaa	MeasArray2
	staa	FormattedReading3
	ldaa	MeasArray1
	staa	FormattedReading4
	ldaa	MeasArray0
	staa	FormattedReading5
	bra	LC742
;
LC6E3:				; here for PLC = 10 or 100 (subRunMeasurement takes care of 100 PLC)
	ldaa	MeasArray3
	lsra
	lsra
	lsra
	lsra
	anda	#$01
	oraa	InguardStatus
	staa	FormattedReading2
	ldaa	#$0F
	anda	MeasArray3
	asla
	asla
	asla
	asla
	ldab	#$F0
	andb	MeasArray2
	lsrb
	lsrb
	lsrb
	lsrb
	staa	x004A
	orab	x004A
	stab	FormattedReading3
	ldaa	#$0F
	anda	MeasArray2
	asla
	asla
	asla
	asla
	ldab	#$F0
	andb	MeasArray1
	lsrb
	lsrb
	lsrb
	lsrb
	staa	x004A
	orab	x004A
	stab	FormattedReading4
	ldaa	#$0F
	anda	MeasArray1
	asla
	asla
	asla
	asla
	ldab	#$F0
	andb	MeasArray0
	lsrb
	lsrb
	lsrb
	lsrb
	staa	x004A
	orab	x004A
	stab	FormattedReading5

LC742:				; here all the reading bytes have been transferred
	ldaa	FormattedReading2
	anda	#$01
	rora
	bcc	LC758		; branch if overrange digit is 0
	ldaa	#$F0
	anda	FormattedReading3
	cmpa	#$10
	bls	LC758
	ldaa	#$01
	staa	flagOverrange_Maybe
LC758:
	ldaa	X010C
	oraa	flagOverrange_Maybe
	staa	flagOverrange_Maybe
	ldaa	flagOverrange_Maybe
	tsta
	bne	LC76A
	jsr	subStoreReading
LC76A:
	ldaa	#$30
	anda	IGCmdRegister4
	cmpa	#$20
	beq	LC7D9	; branch if bit5 set, bit4 clear
	jsr	subUnpackMeasArray
	ldaa	MeasArray7
	clrb
	cmpa	#$01
	bne	LC77F
	decb
LC77F:
	ldaa	MeasArray6
	stab	x0048
	clrb
	cmpa	#$01
	bls	LC78A
	decb
LC78A:
	andb	x0048
	rorb
	bcc	LC796
	ldab	#$01
	stab	flagOverrange_Maybe
LC7D9:
	rts
;
LC796:
	jsr	subInsertDisplayDecimal
	ldaa	flagHPIBPackedOutput
	tsta
	bne	LC7AE
	ldab	#$10
	stab	ioHPIB_r0	; turn off interrupts from HPIB
	sei
	jsr	subFormatReadingForHPIB
	cli
	ldaa	#$A5
	staa	ioHPIB_r0	; turn on interrupts from HPIB
LC7AE:
	ldaa	flagDispNeedUpdate
	rora
	bcc	LC7D9
	ldaa	#$10
	anda	X0198
	clrb
	tsta
	beq	LC7BE
	decb
LC7BE:
	ldaa	#$2B	; ASCII "+"
	stab	x004A
	clrb
	cmpa	MeasPolaritySign
	bne	LC7C9
	decb
LC7C9:
	andb	x004A
	ldaa	#$80
	anda	X0198
	stab	x004E
	clrb
	tsta
	beq	LC7D7
	decb
LC7D7:
	orab	x004E
	rorb
	bcc	LC7E6
	ldaa	#$1F
	staa	MeasPolaritySign	; 1F code for blank sign?
LC7E6:
	ldaa	flagNumPLCcode
	tsta
	bne	LC7F4		; branch if PLC != .01
	ldab	#$0F
	stab	MeasArray0	; 0F means blank these two digits
	stab	MeasArray1
LC7F4:
	ldaa	flagNumPLCcode
	cmpa	#$01
	bne	LC805		; branch if PLC != .1
	ldab	#$0F
	stab	MeasArray0	; blank just this digit
LC805:
	ldaa	#$03
	staa	x011C		; loop index, 3 to ?
LC80A:	;--- loop begin
	ldaa	#$05
	suba	X011B		; X011B contains code for # digits to display?
	cmpa	x011C
	bcs	LC832
	ldaa	x011C
	suba	#$03		; A = 0 to ?
	clrb
	adda	#$D1
	adcb	#$01		; base address of MeasArray
	staa	x004B
	stab	x004A
	ldaa	#$0F
	ldx	x004A
	staa	$00,x		; 0F blanks digit least significant digit MeasArray0 to ?
	inc	x011C
	bra	LC80A
	;--- loop end
;
LC832:
	ldaa	MeasArray7	; most signifcant digit
	tsta
	bne	LC83D
	ldab	#$0F		; if 0, blank digit
	stab	MeasArray7
LC83D:
	rts
;===============================================================================
; This runs measurements in all modes.  If 100 Power Line Cycle integration is in effect,
; this runs a loop of 10, 10 PLC measurements.  Loop index X01A0 starts at 0A and decrements.
; For 100 PLC, measurements accumulated into AccumRegister, then transfered to MeasArray.
; Less than 100 PLC measurement are done in MeasArray.

subRunMeasurement:
	jsr	subCheckIfIGReadyToMeasure
	ldaa	X0198
	anda	#$01
	rora
	bcc	LC857
	ldaa	flagNumPLCcode
	cmpa	#$04
	bcc	LC857
	ldab	#$10
	stab	ioVmComplete	; if PLC code > 4, signal VM complete?
LC857:
	jsr	subZeroMeasArray
	clr	FormattedReading5
	ldaa	flagNumPLCcode
	cmpa	#$03
	bls	LC8CE		; branch if 10 PLC or less
	jsr	subClearAccumRegister
	ldaa	#$0A		; decimal 10
	staa	X01A0
	ldaa	#$FB
	anda	flagX0121
	staa	flagX0121	; clear bit2

LC874:	;--- loop begin
	ldaa	#$04
	anda	flagX0121
	tsta
	bne	LC8E5		; return if flagX0121 bit2 = 1
	ldaa	flag010B
	rora
	bcc	LC88B		; branch if flag = 0
	jsr	sub026
	jsr	subAnnuncNDisplayUpdate
	clr	flag010B
LC88B:
	jsr	subUpdateDisplayIfReady
	jsr	subGetInguardReading
	ldaa	#$15		; why compare against 15?  Inguard code for error?
	cmpa	InguardByte0
	bne	LC8AC
	ldab	#$01
	stab	flagOverrange_Maybe
	ldaa	#$04
	oraa	flagX0121
	staa	flagX0121	; set bit2
	bra	LC874
;
LC91B:
	jsr	subCheckIfIGReadyToMeasure
	bra	LC874
;
LC8CE:				; go here if 10 PLC or less
	jsr	subGetInguardReading
	ldaa	#$15
	cmpa	InguardByte0
	bne	LC8E5
	ldab	#$01
	stab	flagOverrange_Maybe	; flagOverrange_Maybe set if InguardByte0 = 15
LC8E5:
	rts
;
LC8AC:
	dec	X01A0		;
	ldaa	X01A0
	tsta
	bne	LC91B		; branch into previous loop if counter not 0
				; continue here for 100 PLC and 10 readings done
	ldab	#$04
	orab	flagX0121
	stab	flagX0121	; set bit2
	jsr	subZeroMeasArray
	ldaa	AccumRegister0	; copy from AccumRegister to MeasArray
	staa	MeasArray0	; this is packed, complimented form.
	ldaa	AccumRegister1
	staa	MeasArray1
	ldaa	AccumRegister2
	staa	MeasArray2
	ldaa	AccumRegister3
	staa	MeasArray3
	ldaa	AccumRegister4
	staa	MeasArray4

	ldaa	MeasArray0	; least significant 2 digits
	lsra			; dropping the last digit does a divide by 10 of the 10 accumulated readings.
	lsra
	lsra
	lsra
	staa	MeasArray0	; shift high nibble to low, eliminating the least significant digit
	ldaa	MeasArray1
	staa	X0798
	bsr	subCallNibbleSwap	; swap high and low nibbles of MeasArray1
	staa	MeasArray1
	ldaa	#$F0
	anda	MeasArray1
	oraa	MeasArray0
	staa	MeasArray0	; put high nibble of MB2 in MB1
	ldaa	MeasArray2
	staa	X0798
	bsr	subCallNibbleSwap	; swap high and low nibbles of MeasArray2
	staa	MeasArray2
	ldaa	#$0F
	anda	MeasArray1
	ldab	#$F0
	andb	MeasArray2
	staa	x0048
	orab	x0048
	stab	MeasArray1
	ldaa	MeasArray3
	staa	X0798
	bsr	subCallNibbleSwap	; swap high and low nibbles of MeasArray3
	staa	MeasArray3
	ldaa	#$F0
	anda	MeasArray3
	ldab	#$0F
	andb	MeasArray2
	staa	x0048
	orab	x0048
	stab	MeasArray2
	ldaa	MeasArray4
	staa	X0798
	jsr	subCallNibbleSwap	; swap high and low nibbles of MeasArray4
	staa	MeasArray4
	ldaa	#$0F
	anda	MeasArray3
	ldab	#$F0
	andb	MeasArray4
	staa	x0048
	orab	x0048
	stab	MeasArray3
	jmp	LC874
;
;===============================================================================
; (this code was originally inside subRunMeasurement.)
; Seems to just load stack to call subNibbleSwap
subCallNibbleSwap:
	ldaa	X0798
	psha
	clrb
	pshb
	ldaa	#$04
	psha
	pshb
	ldaa	#$02
	psha		; stack, from top: 02, 00, 04, 00, X0798
	jsr	subNibbleSwap
	staa	X0798
	ldaa	X0798	; now contains high and low nibbles swapped.
	clrb
	rts

;===============================================================================

sub081:
	ldaa	X0103
	cmpa	#$01
	bne	LC9D1
	clr	X0103
	ldaa	#$10
	staa	HPIBIntrMask	; setting for interrupts off
	ldaa	X018C
	anda	#$01
	tsta
	beq	LC9CE		; branch if bit0 = 0
	ldaa	#$0F
	anda	IGCmdRegister2
	cmpa	#$02
	bne	LC9CE
	jsr	subClearAccumRegister
	jsr	sub043
	jsr	subPresetLnUregs
	ldaa	X018C
	oraa	#$01
	staa	X018C		; set bit0
LC9CE:
	jsr	sub066
LC9D1:
	rts
;===============================================================================
;
LC9D2:
	lds	StackStart
	bsr	sub081
	cli
	ldaa	#$A5
	staa	HPIBIntrMask	; setting for interrupts on
	ldaa	#$A5
	staa	ioHPIB_r0	; turn on interrupts from HPIB
	jsr	sub073
	bra	LC9D2
;===============================================================================
; appears that once a measurement is taken, this invokes whatever math function (stats, dBm, etc.)
; is currently on.
; used when meter is in Auto range
subDoMathFunction:
	ldaa	#$0F
	anda	IGCmdRegister2
	staa	InguardStatus
	ldaa	#$82
	anda	X0198
	cmpa	#$80
	bne	LC9FD
	clr	AccumRegister0
LC9FD:
	ldaa	flagOverrange_Maybe
	clrb
	tsta
	beq	LCA05
	decb
LCA05:
	ldaa	#$28
	anda	X018C
	stab	x0048	; keep bits 3,5
	clrb
	tsta
	beq	LCA11	; branch if bit1,7 are set
	decb
LCA11:
	orab	x0048
	ldaa	InguardStatus
	stab	x004E
	clrb
	cmpa	#$02
	bls	LCA1E
	decb
LCA1E:
	andb	x004E
	rorb
	bcc	LCA24
	rts

LCA24:
	ldaa	InguardStatus
	clrb
	bra	LCA5C
;


;---------- Switch LCA5C -----------------------
LCA5C:
	asla
	rolb
	adda	#$68
	adcb	#$F9
	staa	X0003
	stab	X0002
	ldx	X0002
	ldx	$00,x
	jmp	$00,x
	; index jump
	;	jump index values
;	f968
;	LCA6C
;	LCA2A
;	LCA2F
;	LCA34
;	LCA39
;	LCA3E
;	LCA43
;	LCA48
;	LCA4D
;	LCA57
;
;---------- Switch LCA5C case 0 ----------------
; Disable Math operation
LCA6C:
	ldaa	AccumRegister1 	; leading digit?
	tsta
	bne	LCA78
	clrb
	subb	#$03
	stab	AccumRegister6 	; exponent = -3
LCA78:
	rts

;---------- Switch LCA5C case 1 ----------------
; Pass/Fail function
LCA2A:
	jsr	subMathFcnPassFail
	bra	LCA6C
;
;---------- Switch LCA5C case 2 ----------------
; Statistics function
LCA2F:
	jsr	subMathFcnStats
	bra	LCA6C
;
;---------- Switch LCA5C case 3 ----------------
; Null function
LCA34:
	jsr	sub041
	bra	LCA6C
;
;---------- Switch LCA5C case 4 ----------------
; dBm function
LCA39:
	jsr	subMathFcnDBM
	bra	LCA6C
;
;---------- Switch LCA5C case 5 ----------------
; temperature measurement in F
LCA3E:
	jsr	subMathFcnTempF
	bra	LCA6C
;
;---------- Switch LCA5C case 6 ----------------
; temperature measurement in C
LCA43:
	jsr	subMathFcnTempC
	bra	LCA6C
;
;---------- Switch LCA5C case 7 ----------------
; (X - Y)/Y function
LCA48:
	jsr	sub039
	bra	LCA6C
;
;---------- Switch LCA5C case 8 ----------------
; 100(X - Y)/Y function
LCA4D:
	jsr	sub040
	bra	LCA6C
;
;---------- Switch LCA5C case 9 ----------------
; 20 LOG X/Y function
LCA57:
	jsr	subMathFcn20LogXY
	bra	LCA6C
;
;===============================================================================

sub083:
	jsr	sub075
	jsr	subRunMeasurement
	ldaa	flagNumPLCcode
	cmpa	#$03
	bls	LCA8D
	ldab	#$10
	stab	ioVmComplete
LCA8D:
	jsr	sub078
	rts
;---------------------------------
; adjusts AccumRegister0 = FF if sign1 = + and leading digit != 0, else 00
; and X0198 != 0
; used when meter is in Auto range
sub084:
	ldaa	#$10
	anda	X0198
	tsta
	beq	LCABC
	ldaa	AccumRegister0	; = 00 if sign1 = +, else FF
	clrb
	tsta
	bne	LCAA3
	decb
LCAA3:				; B = 00 if sign1 = -, else FF
	ldaa	AccumRegister1
	stab	x004C
	clrb
	tsta
	beq	LCAAD	; branch if leading digit = 0
	decb
LCAAD:
	andb	x004C	; = FF if sign1 = + and leading digit != 0
	rorb
	bcc	LCAB9
	ldab	#$FF
	stab	AccumRegister0
	bra	LCABC
;
LCAB9:
	clr	AccumRegister0
LCABC:		; AccumRegister0 = FF if sign1 = + and leading digit != 0, else 00
	rts
;---------------------------------

sub085:
	ldaa	X018E
	staa	X0191
	ldaa	X018F
	staa	X0192
	jsr	sub028
LCACE:
	jsr	sub075
	jsr	subRunMeasurement
	jsr	subProcessMeasurement
	jsr	subTestForOverrange_Maybe
	ldaa	#$F7
	anda	flagCmdParse
	staa	flagCmdParse		; clear bit3
	ldaa	flagOverrange_Maybe
	tsta
	bne	LCB3B
	ldab	#$57			; ASCII "W"
	stab	X0793
	jsr	subCopyAccumRegToRegister	; copies current measurement to 0176-017B
	ldaa	#$08
	anda	X0198
	tsta
	beq	LCB3B			; branch if bit3 = 0
	ldaa	IGCmdRegister0
	staa	CopyOfIGCmdByte
	jsr	sub065
	jsr	sub075
	jsr	subRunMeasurement	; gets a new measurement
	ldaa	X01A6
	staa	MeasExponent
	ldaa	X01A7
	staa	MeasExponentSign
	jsr	subProcessMeasurement
	jsr	subTestForOverrange_Maybe
	ldaa	flagOverrange_Maybe
	tsta
	bne	LCB3B			; branch if AccumRegister in overrange
	ldab	#$76
	ldaa	#$01
	pshb
	psha
	ldaa	#$67
	ldab	#$01			; 0167 = base address of AccumRegister
	psha
	pshb
	psha
	pshb
	ldaa	#$03
	psha
	jsr	subRegisterSubtract	; 0167 = 0176 - 0167 i.e., previous measurment minus this one
	jsr	subTestForOverrange_Maybe
LCB3B:
	ldaa	IGCmdRegister0
	anda	#$01
	tsta
	beq	LCB54			; branch if bit0 = 0
	jsr	sub012
	ldaa	#$08
	anda	X018B
	tsta
	beq	LCB54			; branch if bit3 = 0
	jsr	sub066
	jmp	LCACE
;
LCBC1:
	jmp	LCC82
LCB54:
	ldaa	flagOverrange_Maybe
	tsta
	bne	LCBC1
	ldab	#$04
	andb	X0198
	tstb
	beq	LCBC1
	ldab	DecimalDisplayPosition
	stab	X01A8
	ldaa	#$01
	staa	X019C
	ldaa	#$04
	staa	DecimalDisplayPosition
	ldaa	#$03
	staa	MeasExponent
	ldaa	#$2D			; ASCII "-"
	staa	MeasExponentSign	; exponent = -3
	clr	X019B
	ldaa	#$18
	staa	CopyOfIGCmdByte
	clr	X019D
LCB87:
	jsr	sub063
	ldaa	#$0F
	ldab	#$F7			; F70F
	adda	CopyOfIGCmdByte		; range possibly 18-1A
	adcb	#$00
	staa	x0049
	stab	x0048
	ldx	x0048
	ldaa	$00,x			; F727-9 is 51 55 57
	staa	InguardStatus
	ldaa	InguardStatus
	lsra
	lsra
	lsra
	lsra
	oraa	#$40
	staa	ioIsoLogic
	ldaa	#$02
	psha
	clrb
	pshb
	ldaa	#$01
	psha				; 01, 00, 02 on stack
	jsr	subProgrammedDelay
	ldaa	#$0F
	anda	InguardStatus
	oraa	#$50
	staa	ioIsoLogic
	ldaa	#$1A
	psha
	clrb
	pshb
	ldaa	#$01
	psha				; 01, 00, 1A on stack
	jsr	subProgrammedDelay
	jsr	sub060
	jsr	subRunMeasurement
	jsr	subProcessMeasurement
	jsr	subTestForOverrange_Maybe
	ldaa	flagOverrange_Maybe
	tsta
	beq	LCC32			; branch if not overrange?
	ldab	#$1A
	cmpb	CopyOfIGCmdByte
	beq	LCC2B
	inc	CopyOfIGCmdByte
	inc	X019B
	clr	flagOverrange_Maybe
	ldaa	#$1A
	cmpa	CopyOfIGCmdByte
	bne	LCC16
	ldab	#$01
	stab	X019D
	clr	MeasExponent
	ldaa	#$2B			; ASCII "+"
	staa	MeasExponentSign
	ldaa	#$05
	staa	DecimalDisplayPosition
	clra
	deca
	staa	X019C			; = FF
	jmp	LCB87
LCC16:
	clr	MeasExponent
	clr	X019C			; = 00
	ldaa	#$2B			; ASCII "+"
	staa	MeasExponentSign
	ldaa	#$06
	staa	DecimalDisplayPosition
	jmp	LCB87
;
LCC2B:
	ldaa	#$0A
	staa	X019C			; = 0A
	bra	LCC77
;
LCC32:
	ldaa	AccumRegister1		; contains overrange digit 0 or 1
	tsta
	bne	LCC4E			; branch if a 1
	ldab	X0176			; sign byte of register 0176-017B, previous measurement
	tstb
	bne	LCC43			; branch if it is negative
	jsr	sub036
	bra	LCC46
;
LCC43:
	jsr	sub035
LCC46:
	ldaa	X01A9
	staa	X019C
	bra	LCC77
;
LCC4E:
	ldaa	X01A9
	adda	X019C
	staa	X019C
	ldaa	#$76
	ldab	#$01
	psha
	pshb
	ldaa	#$67
	ldab	#$01
	psha
	pshb
	psha
	pshb
	ldaa	#$03
	psha
	jsr	subRegisterDivide	; 0167 = 0176 / 0167
	ldaa	AccumRegister1		; contains overrange digit 0 or 1
	tsta
	bne	LCC77
	clrb
	subb	#$03
	stab	AccumRegister6
LCC77:
	ldaa	X01A8
	staa	DecimalDisplayPosition
	ldaa	#$01
	staa	X019D
LCC82:
	ldaa	#$10
	staa	ioVmComplete
	jsr	sub084
	jsr	subDoMathFunction
	ldaa	#$EF
	anda	IGCmdRegister0
	staa	CopyOfIGCmdByte
	jsr	sub065
	ldaa	X0192
	staa	X018F
	ldaa	X0191
	staa	X018E
	ldaa	#$08
	oraa	flagCmdParse
	staa	flagCmdParse	; set bit3
	rts
;---------------------------------
; used when meter is in Auto range
sub086:
	ldaa	X018E
	staa	X0191
	ldaa	X018F
	staa	X0192
LCCBB:
	jsr	sub075
	jsr	subRunMeasurement
	ldaa	X010C
	oraa	flagOverrange_Maybe
	staa	flagOverrange_Maybe
	jsr	subProcessMeasurement
	ldaa	flagTestMode
	tsta
	bne	LCD04
	jsr	sub084
	ldaa	#$20
	anda	X0198
	tsta
	beq	LCCE1	; branch if X0198 bit5 = 0
	jsr	sub033	; does some math
LCCE1:
	jsr	subTestForOverrange_Maybe
	ldaa	IGCmdRegister0
	anda	#$01
	tsta
	beq	LCCFC	; branch if IGCmdRegister0 bit0 = 0
	jsr	sub012
	ldaa	#$08
	anda	X018B
	tsta
	beq	LCCFC	; branch if bit3 = 0
	jsr	sub066
	bra	LCCBB
;
LCCFC:
	ldaa	#$10
	staa	ioVmComplete
	jsr	subDoMathFunction
LCD04:
	ldaa	X0192
	staa	X018F
	ldaa	X0191
	staa	X018E
	rts
;---------------------------------

sub087:
	ldaa	#$C0
	anda	X018B
	staa	X018B	; clear bit0-5
	ldaa	X01A9
	staa	X019C
	ldaa	X01A7
	staa	MeasExponentSign
	ldaa	X01A6
	staa	MeasExponent
	ldaa	X0198
	anda	#$01
	tsta
	beq	LCD3A	; branch if bit0 = 0
	jsr	sub083
	bra	LCD4A
;
LCD3A:
	ldaa	#$02
	anda	X0198
	tsta
	beq	LCD47
	jsr	sub085
	bra	LCD4A
;
LCD47:
	jsr	sub086
LCD4A:
	rts
;---------------------------------
; appears to put "OL" on display with all decimals on.
sub088:
	jsr	subClearAccumRegister
	clra
	suba	#$03
	staa	AccumRegister6
	ldaa	#$42
	staa	X0790
	ldab	X019C
	stab	X0791
	jsr	sub023
	ldaa	#$0F		; blank right most digit
	staa	MeasArray0

	staa	Digit7		;***** MODDED blank our 7th digit, too

	ldaa	#$0D		; next gets "L"
	staa	MeasArray1
	clr	MeasArray2	; then a "0"
	ldaa	#$0F
	staa	MeasPolaritySign
	ldaa	#$03
	staa	x011F
LCD7B:	;--- loop begin		; put decimal points everywhere else
	ldaa	x011F		; range from 3 to 7
	cmpa	#$07
	bhi	LCDA0
	ldaa	#$D1
	ldab	#$01		; base address of MeasArray
	adda	x011F
	adcb	#$00
	staa	x0049
	stab	x0048
	ldx	x0048
	ldaa	$00,x		; 01D4 to 01D8  (MeasArray3-7)
	cmpa	#$2E		; ASCII "."
	beq	LCD9B
	ldab	#$0F
	stab	$00,x		; if 01D4 - 01D8 are not ".", make them 0F
LCD9B:
	inc	x011F
	bra	LCD7B
	;--- loop end
;
LCDA0:
	jsr	sub019
	rts
;===============================================================================
; inputs: flagDispNeedUpdate, MeasArray7, MeasExponent
sub089:
	ldaa	flagDispNeedUpdate
	rora
	bcc	LCDE7		; branch if update not needed
	ldaa	#$10
	staa	ioHPIB_r0	; turn off interrupts from HPIB
	sei			; inhibit keyboard interrupts
	ldaa	MeasExponent
	tsta
	bne	LCDBD		; branch if exponent != 00
	clr	flagMeasHasExponent
	bra	LCDC2
;
LCDBD:
	ldaa	#$01
	staa	flagMeasHasExponent
LCDC2:
	ldaa	MeasArray7	; overrange digit
	cmpa	#$01
	bls	LCDD0		; branch if MeasArray7 <= 01
	cmpa	#$0A		; C set if < 0A
	bcc	LCDD0		; branch if MeasArray7 >= 0A
	jsr	subShiftMeasArrayRight	; shift right if most significant digit was 2-9 (display can only show 0 or 1
LCDD0:
	jsr	subCopyMeas2DispBytes
	cli			; enable keyboard interrupts
	ldaa	#$A5
	staa	ioHPIB_r0	; turn on interrupts from HPIB
	jsr	subSetAnnuncBytes123
	jsr	subSetAnnuncByte4
	ldaa	#$01
	staa	X010A		; seems to send a strobe to the RateLite LED
	jsr	subUpdateDisplayIfReady

LCDE7:
	clr	flagOverrange_Maybe
	ldaa	#$D1
	anda	X018C
	staa	X018C		; keep bits 7,6,4,0
	ldaa	#$01
	staa	flagMeasFormatted
	ldaa	#$04
	staa	HPIBSerialPollStatus
	jsr	subHPIBRequestService
	ldaa	IGCmdRegister4
	anda	#$04
	tsta
	beq	LCE32	; branch if bit2 = 0
	clr	flagHPIBOutputStatus
	jsr	subHPIB_Idle
LCE12:
	ldaa	#$58
	cmpa	flagHPIBOutputStatus
	beq	LCE2D
	jsr	subHPIB_Idle
	jsr	subSetAnnuncBytes123
	jsr	subSetAnnuncByte4
	jsr	subUpdateDisplayIfReady
	ldaa	HPIBIntrMask
	staa	ioHPIB_r0
	bra	LCE12
;
LCE2D:
	jsr	subHPIBOutputMeasurement
	rts
;
LCE32:
	jsr	subOutputMeasWhenHPIBReady
	rts
;===============================================================================
; inputs: flagOverrange_Maybe, X0198, X019C, IGCmdRegister2
; sets X0790,1 and calls sub023
; adjusts MeasArray0-2, MeasPolaritySign (but maybe not in all cases)
; called much more frequently when meter is in Auto range
sub090:
	ldaa	flagOverrange_Maybe
	tsta
	beq	LCE43		; jump if flagOverrange_Maybe = 00
	jsr	sub088		; appears to display "OL"
	jmp	LCF65
;
LCE43:
	ldaa	X0198
	anda	#$01
	tsta
	bne	LCEB3		; branch if bit0 = 1
	ldaa	#$80
	anda	X019C
	tsta
	beq	LCE56
	clr	X019C
LCE56:				; X019C set to 00 if bit7 was 1
	ldaa	#$42		; ASCII "B"
	staa	X0790
	ldab	X019C
	stab	X0791
	jsr	sub023
	ldaa	#$2E
	anda	X018C
	tsta
	beq	LCECA		; branch if bits 5,3,2,1 = 0
	jsr	subBlankMeasArray
	ldaa	#$28
	anda	X018C
	tsta
	beq	LCE95		; branch if bits 5,3 = 0
	ldaa	#$0D		; this puts "OL" in the 2nd & 3rd rightmost digits of display
	staa	MeasArray1
	clr	MeasArray2

	ldaa	#$1F		;***** MODDED blank 7th digit if displaying OL
	staa	Digit7

	ldaa	#$08
	anda	X018C
	tsta
	beq	LCE8E		; branch if bit3 = 0
	ldaa	#$2D		; ASCII "-"
	staa	MeasPolaritySign
LCEB3:
	jmp	LCF65
;
LCE8E:				; X018C bit3 = 0
	ldaa	#$2B		; ASCII "+"
	staa	MeasPolaritySign
	jmp	LCF65
;
LCE95:				; X018C bits 5,3 = 0
	ldaa	#$04
	anda	X018C
	tsta
	beq	LCEB8		; branch if bit2 = 0
	ldaa	#$0C
	staa	MeasArray2
	ldaa	#$01
	staa	MeasArray1
	jmp	LCF65
;
LCEB8:				; X018C bit2 = 0
	ldaa	#$02
	anda	X018C
	tsta
	beq	LCEC8		; branch if bit1 = 0
	ldaa	#$0D		; this puts "OL" in the 2nd & 3rd rightmost digits of display
	staa	MeasArray2
	clr	MeasArray1

	ldaa	#$1F		;***** MODDED blank 7th digit if displaying OL
	staa	Digit7

LCEC8:
	jmp	LCF65
;
LCECA:				; X018C bits 5,3,2,1 = 0
	ldaa	#$80
	anda	X0198
	clrb
	tsta
	beq	LCED4		; branch if bit7 = 0
	decb
LCED4:				; B = 00 if X0198 bit7 = 0, else FF
	ldaa	#$04
	anda	X0198
	stab	x004A
	clrb
	tsta
	bne	LCEE0		; branch if bit6 = 1
	decb
LCEE0:
	andb	x004A
	stab	InguardStatus	; = FF if X0198 bit7 = 1 and bit6 = 0, else 00
	ldaa	#$10
	anda	X0198
	clrb
	tsta
	beq	LCEEF		; branch if bit4 = 0
	decb
LCEEF:
	ldaa	#$2B		; ASCII "+"
	stab	x004A		; = FF if X0198bit4 = 1
	clrb
	cmpa	MeasPolaritySign
	bne	LCEFA		; branch if polarity = "-"
	decb
LCEFA:
	andb	x004A		; = FF if X0198 bit4 = 1 and polarity positive
	orab	InguardStatus	; = FF if X0198 bit4 = 1 and polarity positive or X0198 bit7 = 1 and bit6 = 0
	ldaa	#$0F
	anda	IGCmdRegister2
	stab	x0050
	clrb
	cmpa	#$03		; C set if IGCmdRegister2 < 03
	bcc	LCF0C		; branch if IGCmdRegister2 lower nibble >- 03
	decb
LCF0C:				; B = FF if IGCmdRegister2 lower nibble < 03
	andb	x0050		; = FF if (X0198 bit4 = 1 and polarity positive or X0198 bit7 = 1 and bit6 = 0) and IGCmdRegi
	rorb
	bcc	LCF16		; branch if above = 00
	ldaa	#$0F
	staa	MeasPolaritySign
LCF16:
	ldaa	#$80
	anda	X019C
	tsta
	bne	LCF65		; branch if X019C bit7 = 1
	ldaa	flagNumPLCcode
	tsta
	bne	LCF2C		; branch if flagNumPLCcode != 0
	ldab	#$0F
	stab	MeasArray1
	stab	MeasArray0
LCF2C:
	ldaa	flagNumPLCcode
	cmpa	#$01
	bne	LCF3D		; branch if flagNumPLCcode != 1
	ldab	#$0F
	stab	MeasArray0
LCF3D:
	ldaa	#$03
	anda	IGCmdRegister4	; bit1,0	These bits may determine # display digits
	staa	InguardStatus	; = IGCmdRegister4 bit1,0
	cmpa	#$03
	beq	LCF65		; branch if IGCmdRegister4 bit1,0 != 11b	(11 = 6 digit display)
	ldab	#$0F
	stab	MeasArray0	; blank (with 0F) least significant digit
	ldaa	#$02
	cmpa	InguardStatus
	beq	LCF5A		; branch if IGCmdRegister4 bit1,0 != 10b	(10 = 5 digit)
	ldab	#$0F
	stab	MeasArray1
LCF5A:
	ldaa	InguardStatus
	tsta
	bne	LCF65		; branch if IGCmdRegister4 bit1,0 != 00b	(00 = 3 digit)
	ldab	#$0F
	stab	MeasArray2
LCF65:
	jsr	sub089
	rts
;===============================================================================

sub091:
	ldaa	#$0C
	staa	X019C
	ldaa	#$F1
	anda	X018C
	oraa	#$20	; set bit 5
	staa	X018C
	jsr	sub088
	ldaa	#$0F
	staa	MeasArray3
	ldaa	#$2B	; ASCII "+"
	staa	MeasPolaritySign
	clr	flagMeasHasExponent
	jsr	subCopyMeas2DispBytes
	ldaa	#$DF
	anda	X018C
	staa	X018C	; clear bit 5
	ldaa	#$01
	staa	flagMeasFormatted
	rts
;===============================================================================
; set Annunciator Bytes to 0x10, blanks all outputs
subPresetAnnuncBytes:
	ldaa	#$10
	staa	AnnuncByte0
	staa	AnnuncByte1
	staa	AnnuncByte2
	staa	AnnuncByte3
	staa	AnnuncByte4
	staa	AnnuncByte6
	clr	flagDisplayHasExponent
	rts
;===============================================================================
; Test of User RAM space 0207 to 05EE.  Writes 00 then FF to each location and tests
; what was read back.  AccumRegister0 returns 00 if same, FF if difference
subTestUserRAM:
	clr	AccumRegister0
	ldx	#$0000
	stx	X01FE	; 01FE = 0, 01FF = 0
LCFC0:
	ldaa	#$E7
	ldab	#$03	; BA = 03E7
	suba	X01FF
	sbcb	X01FE
	bcs	LD035	; to rts, loop 03E7+1 (1000) iterations ?
	ldaa	#$07
	ldab	#$02
	adda	X01FF
	adcb	X01FE
	staa	x0049
	stab	x0048
	ldx	x0048	; 1st iteration, X = 0207, 2nd 208,
	clr	$00,x	; set to 00
	ldaa	#$07
	ldab	#$02
	adda	X01FF
	adcb	X01FE
	staa	x0049
	stab	x0048
	ldx	x0048	; X is 207, 208...
	ldaa	$00,x	; always 00 (cleared above)?
	tsta
	beq	LCFF8	; branch if A = 0
	ldab	#$FF
	stab	AccumRegister0
LCFF8:
	ldaa	#$07
	ldab	#$02
	adda	X01FF
	adcb	X01FE
	staa	x0049
	stab	x0048
	ldaa	#$FF
	ldx	x0048	; X is 207, 208...
	staa	$00,x	; = FF
	ldaa	#$07
	ldab	#$02
	adda	X01FF
	adcb	X01FE
	staa	x0049
	stab	x0048
	ldx	x0048	; X is 207, 208...
	ldaa	$00,x	; = FF
	cmpa	#$FF
	beq	LD02C	; always equal?
	ldab	#$FF
	stab	AccumRegister0
LD02C:
	ldx	X01FE
	inx
	stx	X01FE	; increment 01FE-01FF
	bra	LCFC0

LD035:
	rts
;---------------------------------

subTestInguardResponse:
	ldaa	#$8F
	staa	InguardCmd
	ldaa	InguardCmd
	staa	ioIsoLogic	; send 0x8F to Inguard
	ldaa	X011B		; = 04 or 64
	psha
	clrb
	pshb
	ldaa	#$01
	psha		; 01, 00, [04 or 64] on stack
	jsr	subProgrammedDelay
	ldaa	ioIsoLogic	; get status(?) from Inguard
	staa	InguardStatus
	ldaa	#$EF
	anda	InguardStatus	; remove bit7
	cmpa	#$8F
	bne	LD068		; did Inguard respond correctly?
	clr	AccumRegister0	; yes, we're good
	rts
;
LD068:
	ldaa	#$FF
	staa	AccumRegister0	; problem
	rts
;---------------------------------
; takes very large number, squares it, then divides by the same number squared.
subTestCalculations:
	clr	MeasArray0
	ldaa	#$01
	staa	MeasArray1
	ldaa	#$09
	staa	MeasArray2
	staa	MeasArray3
	staa	MeasArray4
	staa	MeasArray5
	staa	MeasArray6	; MeasArray = 00 01 09 09 09 09 09 = 1.09090909E9
	ldaa	#$D1
	ldab	#$01	; base address of MeasArray
	psha
	pshb
	psha
	pshb
	ldaa	#$E6
	ldab	#$01
	psha
	pshb
	ldaa	#$03
	psha
	jsr	subRegisterMultiply 	; 01E6 = 01D1 * 01D1
	ldaa	#$D1
	ldab	#$01
	psha
	pshb
	psha
	pshb
	ldaa	#$76
	ldab	#$01
	psha
	pshb
	ldaa	#$03
	psha
	jsr	subRegisterMultiply	; 0176 = 01D1 * 01D1
	ldaa	#$E6
	ldab	#$01
	psha
	pshb
	ldaa	#$76
	ldab	#$01
	psha
	pshb
	ldaa	#$67
	ldab	#$01			; 0167 = base address of AccumRegister
	psha
	pshb
	ldaa	#$03
	psha
	jsr	subRegisterDivide		; 0167 = 01E6 / 0176
	ldaa	AccumRegister0
	tsta
	beq	LD0D4		; branch if result positive
	ldab	#$FF
	stab	AccumRegister0
LD0D4:
	ldaa	AccumRegister1
	cmpa	#$01
	beq	LD0E5
	ldab	#$FF
	stab	AccumRegister0
LD0E5:
	ldaa	AccumRegister3
	adda	AccumRegister2
	adda	AccumRegister4
	adda	AccumRegister5
	tsta
	beq	LD0F9
	ldaa	#$FF
	staa	AccumRegister0
LD0F9:
	ldaa	AccumRegister6
	cmpa	#$01
	beq	LD105
	ldab	#$FF
	stab	AccumRegister0
LD105:
	rts
;---------------------------------
; inputs: main loop counter from subRunSelfTest
; outputs: AccumRegister1-6,
sub096:
	ldaa	X01AB		; caller (subRunSelfTest) main loop index, 01-0C
	cmpa	#$0A		; C set if X01AB < 0A
	bcc	LD11C		; branch if X01AB >= 0A
	staa	AccumRegister1	; 01-9
	clr	AccumRegister2
	ldaa	#$01
	staa	AccumRegister6
	bra	LD138		; AccumRegister0-6 becomes xx [01-09] 00 xx xx xx 01
;
LD11C:				; X01AB >= 0A,B,C
	ldaa	#$01
	staa	AccumRegister1
	ldaa	X01AB
	suba	#$0A
	staa	AccumRegister2	; 0,1,2
	ldaa	AccumRegister2
	asla
	asla
	asla
	asla
	staa	AccumRegister2	; 00,10,20
	ldaa	#$02
	staa	AccumRegister6	; AccumRegister becomes xx 01 [00,10,20] xx xx xx 02
LD138:
	ldaa	#$04
	oraa	AnnuncByte1
	staa	AnnuncByte1	; sets one of the front panel LEDs
	clr	AccumRegister3
	clr	AccumRegister4
	clr	AccumRegister5	; AccumRegister becomes 	xx [11-19] 00 00 00 00 01
				; 		or	xx 11 [00,10,20] 00 00 00 02
	ldaa	#$42
	staa	X0790
	ldab	#$2A
	stab	X0791
	jsr	sub023
	jsr	subUpdateDisplayIfReady
	jsr	subOutputMeasWhenHPIBReady
	rts
;---------------------------------

sub097:
	ldaa	IGCmdRegister0
	staa	CopyOfIGCmdByte
	jsr	sub065
	jsr	sub028
	jsr	sub010
	rts
;---------------------------------


sub098:
	clr	flagX01FB
	jsr	subBlankMeasArray
	jsr	subPresetAnnuncBytes
	ldaa	#$04
	oraa	AnnuncByte1
	staa	AnnuncByte1	; set bit3
	jsr	subAnnuncNDisplayUpdate
	ldaa	X01AB
	cmpa	#$03
	bls	LD1C5		; branch if X01AB <= 3
	suba	#$04
	staa	X011B		; must be 0 and up
	ldaa	#$DA
	ldab	#$F7
	adda	X011B
	adcb	#$00
	staa	x0049
	stab	x0048
	ldx	x0048		; F7DA + X01AB - 4
	ldaa	$00,x		; = 80,82,84,86,88,8C,8E,90,92
	staa	IGCmdRegister0
	ldaa	#$E3
	ldab	#$F7
	adda	X011B
	adcb	#$00
	staa	x0049
	stab	x0048
	ldx	x0048		; F7E3 + X01AB - 4
	ldaa	$00,x		; = 12,12,12,13,11,10,0B,12,02
	staa	IGCmdRegister1
	bsr	sub097
LD1BB:
	jsr	sub086
	jsr	sub090
	bra	LD1BB		; infinite loop

;F7DA :  80
;F7DB : 82 84 86 88
;F7DF : 8C 8E 90 92
;F7E3 : 12 12 12 13
;F7E7 : 11 10 0B 12
;F7EB : 02 99 99 99


;
LD1C5:
	ldaa	X01AB
	clrb
	asla
	rolb
	adda	#$7C
	adcb	#$F9
	staa	X0003
	stab	X0002
	ldx	X0002
	ldx	$00,x
	jmp	$00,x
	; index jump
	;	jump index values
	;	LD1F4
	;	LD1CB
	;	LD1D0
	;	LD1D5
;
LD1CB:
	jsr	subTestUserRAM
	bra	LD1F4
LD1D0:
	jsr	subTestCalculations
	bra	LD1F4
LD1D5:
	ldaa	#$04
	staa	X011B
	jsr	subTestInguardResponse
LD1F4:
	jsr	sub096
	bra	LD1C5		; also seems to be endless loop

;---------------------------------
; Sets command for Inguard, has it measure, then compares to stored answer.  Returns
; value in AccumRegister0 to indicate results.
subTestInguardMeasuring:
	ldaa	X01AB	; X01AB >= 4, <= C
	suba	#$04
	staa	X011B	; X011B = 0 - 8
	ldaa	#$DA
	ldab	#$F7
	adda	X011B
	adcb	#$00
	staa	x0049
	stab	x0048
	ldx	x0048
	ldaa	$00,x
	staa	IGCmdRegister0
	; X011B			0	1	2	3	4	5	6	7	8
	; IGCmdRegister0	80	82	84	86	88	8C	8E	90	92

	ldaa	#$E3
	ldab	#$F7
	adda	X011B
	adcb	#$00
	staa	x0049
	stab	x0048
	ldx	x0048
	ldaa	$00,x
	staa	IGCmdRegister1
	; X011B			0	1	2	3	4	5	6	7	8
	; IGCmdRegister1	12	12	12	13	11	10	0B	12	02

	jsr	sub097
	jsr	sub086

	ldaa	#$57
	staa	X0793
	jsr	subCopyAccumRegToRegister	; copies to 0176-017B
	jsr	subZeroMeasArray
	ldaa	X01AB
	suba	#$04
	staa	X011B
	ldaa	#$07
	ldab	#$F8
	adda	X011B
	adcb	#$00
	staa	x0049
	stab	x0048
	ldx	x0048
	ldaa	$00,x
	staa	MeasArray0
	; X011B		0	1	2	3	4	5	6	7	8
	; MeasArray0	89 	19 	02 	60 	00 	50 	20 	00 	00

	ldaa	#$FE
	ldab	#$F7
	adda	X011B
	adcb	#$00
	staa	x0049
	stab	x0048
	ldx	x0048
	ldaa	$00,x
	staa	MeasArray1
	; X011B		0	1	2	3	4	5	6	7	8
	; MeasArray1	99 	99 	92 	60 	85 	98 	20 	00 	00

	ldaa	#$F5
	ldab	#$F7
	adda	X011B
	adcb	#$00
	staa	x0049
	stab	x0048
	ldx	x0048
	ldaa	$00,x
	staa	MeasArray2
	; X011B		0	1	2	3	4	5	6	7	8
	; MeasArray2	99 	99 	99 	99 	99 	99 	90 	98 	04

	ldaa	#$EC
	ldab	#$F7
	adda	X011B
	adcb	#$00
	staa	x0049
	stab	x0048
	ldx	x0048
	ldaa	$00,x
	staa	MeasArray3
	; X011B		0	1	2	3	4	5	6	7	8
	; MeasArray3	99 	99 	99 	11 	99 	99 	99 	00 	01

	clr	MeasExponent
	ldaa	#$2B	; ASCII "+"
	staa	MeasExponentSign
	jsr	subProcessMeasurement		; does measurement cycle
	jsr	sub034		; subtracts two measurement arrays, result into AccumRegister
	ldaa	AccumRegister0
	tsta
	bne	LD324		; if AccumRegister0 != 0, return (and have error handled}

	jsr	subZeroMeasArray
	ldaa	X01AB
	suba	#$04
	staa	X011B
	ldaa	#$2B
	ldab	#$F8
	adda	X011B
	adcb	#$00
	staa	x0049
	stab	x0048
	ldx	x0048
	ldaa	$00,x
	staa	MeasArray0
	; X011B		0	1	2	3	4	5	6	7	8
	; MeasArray0	11 	81 	98 	40 	30 	03 	80 	00 	00

	ldaa	#$22
	ldab	#$F8
	adda	X011B
	adcb	#$00
	staa	x0049
	stab	x0048
	ldx	x0048
	ldaa	$00,x
	staa	MeasArray1
	; X011B		0	1	2	3	4	5	6	7	8
	; MeasArray1	00 	00 	07 	39 	00 	00 	79 	00 	00

	ldaa	#$19
	ldab	#$F8
	adda	X011B
	adcb	#$00
	staa	x0049
	stab	x0048
	ldx	x0048
	ldaa	$00,x
	staa	MeasArray2
	; X011B		0	1	2	3	4	5	6	7	8
	; MeasArray2	00 	00 	00 	00 	00 	00 	89 	02 	96

	ldaa	#$10
	ldab	#$F8
	adda	X011B
	adcb	#$00
	staa	x0049
	stab	x0048
	ldx	x0048
	ldaa	$00,x
	staa	MeasArray3
	; X011B		0	1	2	3	4	5	6	7	8
	; MeasArray3	00 	00 	00 	12 	00 	00 	99 	01 	00

	clr	MeasExponent
	ldaa	#$2B	; ASCII "+"
	staa	MeasExponentSign
	jsr	subProcessMeasurement		; does measurement cycle
	jsr	sub034		; subtracts two measurement arrays, result into AccumRegister
	ldaa	#$FF
	suba	AccumRegister0
	staa	AccumRegister0
LD324:
	rts
;---------------------------------

subRunSelfTest:
	ldaa	#$01
	staa	X01AB		; loop index, 01-0C
LD32C:
	ldaa	X01AB
	cmpa	#$0C
	bhi	LD397
	ldaa	X01AB
	cmpa	#$04		; C set if X01AB < 4
	bcc	LD364		; branch if X01AB >= 4
	deca
	clrb
	asla
	rolb			; doubling value for word index
	adda	#$84
	adcb	#$F9
	staa	X0003
	stab	X0002
	ldx	X0002
	ldx	$00,x
	jmp	$00,x
	; index jump
	;	jump index values
;	f984
;	LD33E
;	LD343
;	LD348
;
LD33E:				; X01AB = 1
	jsr	subTestUserRAM
	bra	LD367
;
LD343:				; X01AB = 2
	jsr	subTestCalculations
	bra	LD367
;
LD348:				; X01AB = 3
	ldaa	#$64
	staa	X011B
	jsr	subTestInguardResponse
	bra	LD367
;
LD364:				; lands here if X01AB >= 4
	jsr	subTestInguardMeasuring		; passes in X01AB
LD367:
	ldaa	AccumRegister0	; test result is stored here
	tsta
	beq	LD392		; branch if AccumRegister0 = 00, i.e., test result OK

	; reach here if test had error
	;--- inner loop begin	-- about a 2 second delay in total, then return
	ldab	#$01
	stab	X01AC		; loop index

LD372:
	ldaa	X01AC		; 1-78
	cmpa	#$78
	bhi	LD391
	jsr	sub096
	ldaa	#$FF
	psha
	clrb
	pshb
	ldaa	#$01
	psha		; 01, 00, FF on stack
	jsr	subProgrammedDelay
	inc	X01AC
	bra	LD372
	;--- end inner loop
LD391:
	rts
;
LD392:
	inc	X01AB
	bra	LD32C
	;--- end main loop
;
LD397:
	jsr	subClearAccumRegister
	ldaa	#$01
	staa	AccumRegister1
	ldaa	#$03
	staa	AccumRegister6
	ldaa	#$42
	staa	X0790
	ldab	#$0D
	stab	X0791
	jsr	sub023
	ldaa	#$01
	staa	flagMeasFormatted
	jsr	subOutputMeasWhenHPIBReady
	rts
;===============================================================================
; Appears to put default values on Annunc & Display
subResetDisplay:
	jsr	subBlankMeasArray
	jsr	subCopyMeas2DispBytes
	jsr	subPresetAnnuncBytes
	jsr	subAnnuncNDisplayUpdate
	rts
;===============================================================================
; turns on all front panel lights
subTestDisplayOn:
	ldaa	#$B0
	staa	ioDAdata
	jsr	subStrobeAnnunciator
	ldaa	#$6F
	staa	ioDAdata
	ldaa	#$01
	staa	x01B0
LD3DD:
	ldaa	x01B0
	cmpa	#$08
	bhi	LD3EC
	jsr	subStrobeAnnunciator
	inc	x01B0
	bra	LD3DD
;
LD3EC:
	ldaa	#$90		; means data is coming, BCD format
	staa	ioDAdata
	jsr	subStrobeDisplay
	ldaa	#$08		; set digits to "8"
	staa	ioDAdata
	ldaa	#$01
	staa	x01B0
LD3FE:
	ldaa	x01B0		; loop through 8 digits
	cmpa	#$08
	bhi	LD40D
	jsr	subStrobeDisplay
	inc	x01B0
	bra	LD3FE
;
LD40D:
	clr	ioRateLite
	rts
;===============================================================================
;

sub103:
	bsr	subResetDisplay
LD415:
	bsr	subTestDisplayOn
	jsr	subRunSelfTest
	bsr	subResetDisplay
	jsr	subRunSelfTest
	bra	LD415		; infinite loop?
;


;===============================================================================
;
sub104:
	ldaa	#$40
	anda	X0200
	tsta
	bne	LD52F
	ldaa	#$0A
	staa	X0790
	ldab	#$2C
	stab	X0791
	jsr	sub023
	ldaa	#$0F
	staa	DisplayArray3
	staa	DisplayArray2
	staa	DisplayArray1
	staa	DisplayArray0
	clr	DisplayPolaritySign
	clr	DisplayExponentSign
	jsr	subAnnuncNDisplayUpdate
	jsr	sub075
LD52F:
	ldaa	#$03
	clrb
	adda	X0202
	adcb	X0201
	adda	#$07
	adcb	#$02
	staa	x004B
	stab	x004A
	ldx	x004A
	ldaa	$00,x
	staa	FormattedReading5
	ldaa	#$02
	clrb
	adda	X0202
	adcb	X0201
	adda	#$07
	adcb	#$02
	staa	x004B
	stab	x004A
	ldx	x004A
	ldaa	$00,x
	staa	FormattedReading4
	ldaa	X0202
	ldab	X0201
	adda	#$01
	adcb	#$00
	adda	#$07
	adcb	#$02
	staa	x004B
	stab	x004A
	ldx	x004A
	ldaa	$00,x
	staa	FormattedReading3
	ldaa	#$07
	ldab	#$02
	adda	X0202
	adcb	X0201
	staa	x0049
	stab	x0048
	ldx	x0048
	ldaa	$00,x
	staa	FormattedReading2
	ldaa	FormattedReading2
	staa	X011B
	ldaa	#$80
	anda	X011B
	tsta
	beq	LD5A7
	ldaa	#$2D	; ASCII "-"
	staa	MeasExponentSign
	bra	LD5AC
;
LD5A7:
	ldaa	#$2B	; ASCII "+"
	staa	MeasExponentSign
LD5AC:
	ldaa	#$02
	anda	X011B
	tsta
	beq	LD5BB
	ldaa	#$2D	; ASCII "-"
	staa	MeasPolaritySign
	bra	LD5C0
;
LD5BB:
	ldaa	#$2B	; ASCII "+"
	staa	MeasPolaritySign
LD5C0:
	ldaa	X011B
	lsra
	lsra
	anda	#$1F
	staa	MeasExponent
	ldaa	X011B
	anda	#$01
	staa	MeasArray7
	ldaa	FormattedReading3
	lsra
	lsra
	lsra
	lsra
	staa	MeasArray6
	ldaa	#$0F
	anda	FormattedReading3
	staa	MeasArray5
	ldaa	FormattedReading4
	lsra
	lsra
	lsra
	lsra
	staa	MeasArray4
	ldaa	#$0F
	anda	FormattedReading4
	staa	MeasArray3
	ldaa	FormattedReading5
	lsra
	lsra
	lsra
	lsra
	staa	MeasArray2
	ldaa	#$0F
	anda	FormattedReading5
	staa	MeasArray1
	jsr	subShiftMeasArrayRight
	ldaa	#$2E		; ASCII "."
	staa	MeasArray7
	jsr	sub015
	jsr	subCopyMeasToAccumReg
	jsr	subDoMathFunction
	ldaa	#$20		; ASCII " "
	staa	X019C
	ldaa	#$40
	anda	X0200
	tsta
	beq	LD62E
	ldaa	#$10
	oraa	flagX0121
	staa	flagX0121
LD62E:
	ldaa	X0204
	ldab	X0203		; ptr to next user RAM location
	suba	#$04
	sbcb	#$00
	staa	x0049
	stab	x0048
	ldx	x0048		; ptr to last reading put into user RAM
	cpx	X0201		; compare pointers x0048-9 and X0201-2
	bne	LD64B		; branch if not equal
	ldaa	#$EF
	anda	flagX0121
	staa	flagX0121	; clear bit4
LD64B:
	clr	flagOverrange_Maybe
	clr	X0198
	jsr	sub090
	ldaa	#$04
	clrb
	adda	X0202
	adcb	X0201
	staa	X0202
	stab	X0201		; ptr X0201-2 + 4
	ldaa	#$40
	anda	X0200
	tsta
	bne	LD685		; branch if bit6 = 1
	ldaa	#$2F
	ldab	#$01
	psha
	pshb
	ldaa	#$5D
	ldab	#$F6		; contains 00 01 00 00 00 00 01 ( = 1.0)
	psha
	pshb
	ldaa	#$2F
	ldab	#$01
	psha
	pshb
	ldaa	#$03
	psha
	jsr	subRegisterSubtract	; 012F = 012F - F65D
	bra	LD69D
;
LD685:
	ldaa	#$2F
	ldab	#$01
	psha
	pshb
	ldaa	#$5D
	ldab	#$F6		; contains 00 01 00 00 00 00 01 ( = 1.0)
	psha
	pshb
	ldaa	#$2F
	ldab	#$01
	psha
	pshb
	ldaa	#$03
	psha
	jsr	subRegisterAdd	; 012F = 012F + F65D
LD69D:
	ldx	X0203
	cpx	X0201
	bne	LD6BE		; branch if X0201-2 != X0203-4
	ldaa	#$0F
	anda	X0200
	staa	X0200		; keep lower nibble
	clr	flagX01FB
	ldaa	X0789
	anda	#$01
	rora
	bcc	LD6BB		; branch if X0789 bit 0 = 0
	jmp	LED5D		; jumps into sub116
LD6BB:
	jmp	LC9D2
LD6BE:
	rts
;
LD6BF:
	ldaa	#$10
	anda	X0200
	tsta
	beq	LD730
	cli
	ldaa	#$A5
	staa	ioHPIB_r0	; turn on interrupts from HPIB
	clr	flagMeasFormatted
	jsr	sub015
	ldaa	MeasExponent
	clrb
	cmpa	#$03
	bls	LD6DC
	decb
LD6DC:
	ldaa	#$2D	; ASCII "-"
	stab	x0048
	clrb
	cmpa	MeasExponentSign
	bne	LD6E7
	decb
LD6E7:
	orab	x0048
	ldaa	MeasExponent
	stab	x004C
	clrb
	tsta
	bne	LD6F3
	decb
LD6F3:
	orab	x004C
	tstb
	beq	LD708
	ldab	#$0F
	andb	X0200
	stab	X0200
	ldaa	#$06
	staa	ErrorNumber
	jsr	subDisplayError
LD708:
	ldaa	#$03
	cmpa	MeasExponent
	beq	LD717
	jsr	subShiftMeasArrayRight
	inc	MeasExponent
	bra	LD708
;
LD717:
	ldaa	#$8A
	ldab	#$F9
	adda	MeasArray7
	adcb	#$00
	staa	x0049
	stab	x0048
	ldx	x0048
	ldaa	$00,x
	staa	X079A
	clr	X0799
	bra	LD733
LD730:
	jmp	LD7EB
;
LD733:
	ldaa	X079A
	ldab	X0799
	ldx	#$0008
	cpx	#$0000
	beq	LD746
LD741:
	asla
	rolb
	dex
	bne	LD741
LD746:
	staa	x0049
	stab	x0048
	ldaa	#$94
	ldab	#$F9
	adda	MeasArray7
	adcb	#$00
	staa	x004B
	stab	x004A
	ldaa	#$9E
	ldab	#$F9
	adda	MeasArray6
	adcb	#$00
	staa	x004D
	stab	x004C
	ldx	x004A
	ldaa	$00,x
	clrb
	oraa	x0049
	orab	x0048
	ldx	x004C
	adda	$00,x
	adcb	#$00
	adda	MeasArray5
	adcb	#$00
	asla
	rolb
	asla
	rolb
	staa	X079A
	stab	X0799
	ldaa	X0204
	ldab	X0203
	suba	X079A
	sbcb	X0799
	staa	X0202
	stab	X0201
	ldaa	X0206
	ldab	X0205
	suba	X0202
	ldaa	#$00
	sbcb	X0201
	bcs	LD7A5
	deca
LD7A5:
	ldab	#$00
	staa	x0048
	ldaa	#$10
	subb	X0202
	ldab	#$00
	sbca	X0201
	bcc	LD7B6
	decb
LD7B6:
	orab	x0048
	tstb
	beq	LD7CE
	ldaa	#$0F
	anda	X0200
	staa	X0200
	clr	flagX01FB
	ldaa	#$06
	staa	ErrorNumber
	jsr	subDisplayError
LD7CE:
	ldaa	#$07
	anda	IGCmdRegister2
	tsta
	beq	LD7DB
	ldaa	#$01
	staa	X018C
LD7DB:
	ldaa	#$EF
	anda	X0200
	staa	X0200
	ldaa	#$20
	oraa	X0200
	staa	X0200
LD7EB:
	ldaa	#$40
	anda	X0200
	tsta
	bne	LD81A
	lds	StackStart
	cli
	jsr	sub073
	ldaa	HPIBIntrMask
	staa	ioHPIB_r0
	clr	flagX01FB
	ldaa	#$80
	anda	X0200
	tsta
	bne	LD80D
	bra	LD7EB
;
LD80D:
	ldaa	#$7F
	anda	X0200
	staa	X0200
	jsr	sub104
	bra	LD823
;
LD81A:
	jsr	sub104
	jsr	subAnnuncNDisplayUpdate
	jsr	sub075
LD823:
	jmp	LD6BF

;---------------------------------
;
subDisplayHPIBAddr:
	ldaa	#$D0		; data coming, to be displayed as hexadecimal "0"-"F"
	staa	ioDAdata
	jsr	subStrobeDisplay
	ldaa	#$1A		; "A", 1 means no decimal point
	staa	ioDAdata
	jsr	subStrobeDisplay
	ldaa	#$1D		; "DD"
	staa	ioDAdata
	jsr	subStrobeDisplay
	jsr	subStrobeDisplay
	ldaa	#$10		; "0"
	staa	ioDAdata
	jsr	subStrobeDisplay
	ldaa	#$1F
	anda	ioHPIB_r4	; get port address
	clrb
	adda	#$B3
	adcb	#$F7
	staa	x004B
	stab	x004A
	ldx	x004A
	ldaa	$00,x		; convert switch setting to number
	staa	InguardStatus
	lsra
	lsra
	lsra
	lsra
	oraa	#$10		; turn off decimal
	staa	ioDAdata	; left digit
	jsr	subStrobeDisplay
	ldaa	#$0F
	anda	InguardStatus
	oraa	#$10
	staa	ioDAdata	; right digit
	jsr	subStrobeDisplay
	ldaa	#$20
	anda	ioHPIB_r4
	tsta
	beq	LD892
	ldaa	#$11
	staa	ioDAdata
	ldaa	#$40
	staa	ioHPIB_r2	; set HPIB to Talk Only mode
	bra	LD89A
;
LD892:
	ldaa	#$10
	staa	ioDAdata
	clr	ioHPIB_r2	; set HPIB to defaults
LD89A:
	jsr	subStrobeDisplay	; last digit 0 or 1 for HPIB status?
	jsr	subStrobeDisplay
	rts
;===============================================================================
; Reset routine
;
subRST:
	ldx	#$00FF		; stack start at 0x00FF
	stx	StackStart
	lds	StackStart
	clr	ioIOreset	; strobe reset of all I/O
	ldaa	#$01
	staa	flagDispNeedUpdate	; set flag to need update
	clr	AnDUpdatedFlag	; clear flag that says they have been updated
	jsr	subResetDisplay
	ldaa	#$90		; data coming, mode is BCD code B (0-9,E,H,L,P,and -)
	staa	ioDAdata
	jsr	subStrobeDisplay
	ldaa	#$1C		; "H"
	staa	ioDAdata
	jsr	subStrobeDisplay
	ldaa	#$1E		; "P"
	staa	ioDAdata
	jsr	subStrobeDisplay
	ldaa	#$13		; "3"
	staa	ioDAdata
	jsr	subStrobeDisplay
	ldaa	#$14		; "4"
	staa	ioDAdata
	jsr	subStrobeDisplay
	ldaa	#$15		; "5"
	staa	ioDAdata
	jsr	subStrobeDisplay
	ldaa	#$16		; "6"
	staa	ioDAdata
	jsr	subStrobeDisplay
	ldaa	#$1F		; " "
	staa	ioDAdata
	jsr	subStrobeDisplay
	jsr	subStrobeDisplay

	; ***** MODDED puts + on either side of HP3456 via annunciator *****
	ldaa	#$B0			; sets annunciator display mode
	staa	ioDAdata
	bsr	subStrobeAnnunciator	; note: this function overwrites register A
	ldab	#$10			; code for all front panel LEDs off
	stab	ioDAdata
	bsr	subStrobeAnnunciator
	stab	ioDAdata
	bsr	subStrobeAnnunciator
	stab	ioDAdata
	bsr	subStrobeAnnunciator
	stab	ioDAdata
	bsr	subStrobeAnnunciator
	stab	ioDAdata
	bsr	subStrobeAnnunciator
	ldab	#$17			; put a "+" in polarity and exponent signs
	stab	ioDAdata
	bsr	subStrobeAnnunciator
	stab	ioDAdata
	bsr	subStrobeAnnunciator
	bsr	subStrobeAnnunciator

	clr	flag7Digits		; initialize flag before calling other routines.
	; end mod

	ldaa	#$10
	;ldab	#$27
	ldab	#$50			; ***** MODDED lengthend display time *****
	psha
	pshb
	ldaa	#$01
	psha		; 01, 27, 10 on stack, 2710 hex = 10000 units of 67 uS, or .67 S
	jsr	subProgrammedDelay

	; ***** MODDED clear annunciator before displaying HPIB address *****
	ldaa	#$B0
	staa	ioDAdata
	bsr	subStrobeAnnunciator
	ldab	#$10
	stab	ioDAdata
	bsr	subStrobeAnnunciator
	stab	ioDAdata
	bsr	subStrobeAnnunciator
	stab	ioDAdata
	bsr	subStrobeAnnunciator
	stab	ioDAdata
	bsr	subStrobeAnnunciator
	stab	ioDAdata
	bsr	subStrobeAnnunciator
	stab	ioDAdata
	bsr	subStrobeAnnunciator
	stab	ioDAdata
	bsr	subStrobeAnnunciator
	bsr	subStrobeAnnunciator
	; end mod

	jsr	subDisplayHPIBAddr
	ldaa	#$10
	ldab	#$27
	psha
	pshb
	ldaa	#$01
	psha		; 01, 27, 10 on stack, same delay for address
	jsr	subProgrammedDelay

	clr	ioIOreset
	ldaa	#$FF
	staa	ioIsoLogic	; send FF to Inguard
	ldaa	#$B0
	ldab	#$04
	psha
	pshb
	ldaa	#$01
	psha		; 01, 04, B0 on stack
	jsr	subProgrammedDelay
	ldaa	#$8F		; now send 8F to Inguard
	staa	ioIsoLogic
	ldx	#$0000
	stx	X0205
LD93C:
	ldaa	#$01
	staa	flagDispNeedUpdate
	ldaa	#$10
	staa	ioHPIB_r3	; release DAC handshake
	ldaa	#$80
	staa	ioHPIB_r3	; reset HPIB
	clr	ioHPIB_r3	; set it to defaults
	clr	AnDUpdatedFlag
	jsr	subResetDisplay
	ldaa	ioHPIB_r4
	staa	x0119
	ldaa	#$1F
	anda	x0119
	staa	ioHPIB_r4	; tell the chip what its address is
	jsr	subDisplayHPIBAddr
	ldaa	#$A0
	ldab	#$0F
	psha
	pshb
	ldaa	#$01
	psha		; 01, 0F, A0 on stack
	jsr	subProgrammedDelay
LD971:					; RESET command jumps to here
	ldaa	#$10
	staa	HPIBIntrMask
	clr	ioHPIB_r5
	clr	AnDUpdatedFlag
	clr	flag7Digits		;***** MODDED turn off 7 digit mode after reset
	jsr	subClearDisplay

	;--- loop
	ldaa	#$03
	staa	x01B0
LD984:
	ldaa	x01B0
	cmpa	#$41
	bhi	LD9A1
	ldaa	#$25
	ldab	#$01
	adda	x01B0
	adcb	#$00
	staa	x0045
	stab	x0044
	ldx	x0044
	clr	$00,x	; clear the register storage from 0125+3 to +41 = 0128 to 0166
	inc	x01B0
	bra	LD984
	;--- end loop
;
LD9A1:
	ldaa	#$69
	staa	IGCmdRegister0
	ldaa	#$13
	staa	IGCmdRegister1
	ldaa	#$80
	staa	IGCmdRegister2
	ldaa	#$12
	staa	IGCmdRegister4	; set 0001 0010, last 2 bits mean 5 digit display

	ldaa	#$01
	staa	X012B
	staa	RegisterY1	; byte 1 of Y register
	staa	RegisterY6	; and exponent = 1 -> Y = 1.0 preset
	ldaa	#$12
	staa	IGCmdRegister4	; set 0001 0010 (duplicate of above)
	ldaa	#$06
	staa	RegisterZ1	; byte 1 of Z register
	ldaa	#$03
	staa	RegisterZ6	; exponent byte of of Z register (=600, maybe R register?)
	jsr	subPresetLnUregs	; preset LOWER and UPPER registers
	clr	flagCmdParse
	clr	flagTestMode
	clr	flagX01FC
	clr	flag01A1
	clr	flag01ED
	clr	flagOverrange_Maybe
	clr	flagX0121
	clr	flagHPIBByteInIntr
	clr	flagHPIBOutput
	clr	flagMeasFormatted
	clr	flagX01FB
	clr	X018B
	clr	X010C
	clr	flag010B
	clr	flagInguard1stTimeout
	clr	flagInguardTimeout
	clr	X0789
	clr	X0103
	clr	flagInguard1stTimeout
	clr	X0200
	ldaa	#$01
	staa	AnDUpdatedFlag
	clr	ioKBrdClr
	cli			; clear the RST interrupt?
	jmp	LD421		; jumps into sub103

;===============================================================================

subResetCmdFlags:
	ldaa	#$80
	oraa	flagCmdParse
	staa	flagCmdParse	; set bit7 of flagCmdParse
	clr	flag01ED
	clr	flagMeasArrayUnpacked
	clr	flag01A1
	rts
;===============================================================================
; Appears to parse a formatted number to deal with the signs and exponent and
; put the information into measurement variables.
; Blanks MeasArray0-7 but only sets values of MeasArray0 and MeasArray7.
sub107:
	ldaa	flag01ED
	tsta
	bne	LDA9E		; branch if flag01ED = 1
	ldab	#$01
	stab	flag01ED	; if flag01ED = 0, flag01ED = 1
	clr	flagMeasArrayUnpacked
	clr	X01C7
	ldaa	#$2B		; ASCII "+"
	staa	MeasPolaritySign
	clr	X01F1
	ldaa	#$0F
	staa	MeasExponentSign
	clr	flagMeasHasExponent
	clr	MeasExponent
	ldaa	#$0F
	staa	MeasArray0
	staa	MeasArray1
	staa	MeasArray2
	staa	MeasArray3
	staa	MeasArray4
	staa	MeasArray5
	staa	MeasArray6
	staa	MeasArray7

	ldaa	CmdChar
	clrb			; B = 0
	cmpa	#$30		; C = 1 if ACC < (M); Z = 1 if ACC = (M)  ASCII "0"
	bcs	LDA7A		; branches if C = 1, i.e., CmdChar < 30
	decb			; if absolute value of CmdChar >= 0x30, B = 0xFF
LDA7A:
	stab	x0044		; = 00 (CmdChar < 0x30) else FF
	clrb
	cmpa	#$39		; C = 1 if ACC < (M); Z = 1 if ACC = (M)  ASCII "9"
	bhi	LDA82		; bhi branches if C = 0 and Z = 0, i.e., CmdChar >=39 and CmdChar !=39
					; i.e., ACC > 39
	decb			; if unsigned value of CmdChar <= 0x39, B = 0xFF else 00
LDA82:
	andb	x0044		; FF if CmdChar >= 30 and CmdChar <= 39
	rorb			; way to set C flag
	bcc	LDA93		; branch if C=0, ie, CmdChar < 0x30 or CmdChar > 0x39
	anda	#$0F
	staa	MeasArray0	; store lower nibble of CmdChar
	ldaa	#$01
	staa	X01C7		; set X01C7 = 1
	bra	LDAF8		; rts
;
LDA93:				; CmdChar < 0x30 or CmdChar > 0x39
	ldaa	#$2B		; ASCII "+"
	clrb
	cmpa	CmdChar
	bne	LDA9C
	decb			; if CmdChar = 0x2B,  B = 0xFF, else 0
LDA9C:
	bra	LDAA1
LDA9E:				; if flag01ED = 0
	jmp	LDB5D
LDAA1:
	ldaa	#$2D		; ASCII "-"
	stab	x0044		; = 00 or FF
	clrb
	cmpa	CmdChar
	bne	LDAB1
	decb			; if CmdChar = 0x2D,  B = 0xFF
LDAB1:
	orab	x0044		; B = FF if CmdChar = 2B or 2D
	ldaa	#$2E		; ASCII "."
	stab	x0048		; if CmdChar = 2B or 2D,  x0048 = 0xFF
	clrb
	cmpa	CmdChar		; Z=1 if CmdChar = 2E
	bne	LDABE
	decb			; if CmdChar = 0x2E,  B = 0xFF
LDABE:
	orab	x0048
	ldaa	#$45		; ASCII "E"
	stab	x004C		; if CmdChar = 0x2B,2D or 2E,  x004C = 0xFF
	clrb
	cmpa	CmdChar
	bne	LDACB
	decb			; if CmdChar = 0x45,  B = 0xFF
LDACB:
	orab	x004C
	ldaa	#$65		; ASCII "e"
	stab	x0050		; if CmdChar = 0x2B,2D,2E, or 45,  x0050 = 0xFF
	clrb
	cmpa	CmdChar
	bne	LDAD8
	decb			; if CmdChar = 0x65,  B = 0xFF
LDAD8:
	orab	x0050		; if CmdChar = 0x2B,2D,2E,45 or 65, B = FF
	tstb
	beq	LDB44		; do subResetCmdFlags and return if CmdChar != 0x2B,2D,2E,45 or 65
	clr	MeasArray0	; if CmdChar = 0x2B,2D,2E,45 or 65
	ldaa	#$2E		; ASCII "."
	cmpa	CmdChar
	bne	LDAF6
	staa	MeasArray0	; if CmdChar = 0x2E,
	ldaa	#$01
	staa	flagMeasArrayUnpacked
	ldaa	#$01
	staa	X01C7
	bra	LDB56		; rts
LDAF6:				; if CmdChar != 0x2E,
	bra	LDAFB
LDAF8:
	jmp	LDB5B		; rts
;
LDAFB:				; if CmdChar != 0x2E
	ldaa	#$2B		; ASCII "+"
	clrb
	cmpa	CmdChar
	bne	LDB04
	decb			; if CmdChar = 0x2B,  B = 0xFF
LDB04:
	ldaa	#$2D		; ASCII "-"
	stab	x0044
	clrb
	cmpa	CmdChar
	bne	LDB0F
	decb			; if CmdChar = 0x2D,  B = 0xFF
LDB0F:
	orab	x0044		; FF if 2B or 2D
	tstb
	beq	LDB21
	ldab	CmdChar		; if CmdChar = 0x2B or 2D
	stab	MeasPolaritySign	; MeasPolaritySign = CmdChar
	ldaa	#$0F
	staa	MeasArray0
	bra	LDB56		; rts
;
LDB21:				; if CmdChar != 2B or 2D
	ldaa	#$45		; ASCII "E"
	clrb
	cmpa	CmdChar
	bne	LDB2A
	decb			; if CmdChar = 45,  B = FF
LDB2A:
	ldaa	#$65		; ASCII "e"
	stab	x0044
	clrb
	cmpa	CmdChar
	bne	LDB35
	decb			; if CmdChar = 65,  B = 0xFF
LDB35:
	orab	x0044		; FF if 45 or 65
	tstb
	beq	LDB56		; rts if CmdChar != 45 or 65
	clr	MeasArray7
	ldaa	#$01
	staa	X01F1
	bra	LDB47
LDB44:
	jmp	LDB58
;
LDB47:				; if CmdChar = 45 or 65
	ldaa	#$01
	staa	MeasArray0
	ldaa	#$2B		; ASCII "+"
	staa	MeasExponentSign
	ldaa	#$01
	staa	flagMeasHasExponent
LDB56:
	bra	LDB5B		; rts
;
LDB58:
	jsr	subResetCmdFlags
LDB5B:
	bra	LDBCA		; rts
;
LDB5D:				; if flag01ED = 0
	ldaa	CmdChar
	clrb
	cmpa	#$30		; C = 1 if CmdChar < 30  , ASCII "0"
	bcs	LDB66
	decb			; B = FF if CmdChar >= 30
LDB66:
	stab	x0044
	clrb
	cmpa	#$39		; C = 1 if CmdChar < 39, Z = 1 if CmdChar = 39	, ASCII "9"
	bhi	LDB6E
	decb			; B = FF if CmdChar <= 39
LDB6E:
	andb	x0044
	stab	x0048		; = FF if 30 <= CmdChar <= 39, else 00
	cmpa	#$2E		; ASCII "."
	bne	LDB78
	decb			; B = FF if CmdChar = 2E
LDB78:
	orab	x0048
	stab	x004C		; = FF if 30 <= CmdChar <= 39 or = 2E, else 00
	clrb
	cmpa	#$2B		; ASCII "+"
	bne	LDB82
	decb			; B = FF if CmdChar = 2B
LDB82:
	orab	x004C
	stab	x0050		; = FF if 30 <= CmdChar <= 39 or = 2E or 2B, else 00
	clrb
	cmpa	#$2D		; ASCII "-"
	bne	LDB8C
	decb			; B = FF if CmdChar = 2D
LDB8C:
	orab	x0050
	stab	x0054		; = FF if 30 <= CmdChar <= 39 or = 2E or 2B or 2D, else 00
	clrb
	cmpa	#$45		; ASCII "E"
	bne	LDB96
	decb			; B = FF if CmdChar = 45
LDB96:
	orab	x0054
	stab	x0058		; = FF if 30 <= CmdChar <= 39 or = 2E,2B,2D or 45, else 00
	clrb
	cmpa	#$65		; ASCII "e"
	bne	LDBA0
	decb			; B = FF if CmdChar = 65
LDBA0:
	orab	x0058		; = FF if 30 <= CmdChar <= 39 or = 2E,2B,2D,45 or 65, else 00
	tstb
	bne	LDBB4		; branch if 30 <= CmdChar <= 39 or = 2E,2B,2D,45 or 65
	ldab	#$FE
	andb	flagCmdParse
	stab	flagCmdParse	; clear bit0 of flagCmdParse
	clr	flag01A1
	clr	flag01ED
	rts
;
LDBB4:
	ldaa	#$2B		; ASCII "+"
	clrb
	cmpa	CmdChar
	bne	LDBBD
	decb			; B = FF if CmdChar = 2B
LDBBD:
	ldaa	#$2D		; ASCII "-"
	stab	x0044
	clrb
	cmpa	CmdChar
	bne	LDBC8
	decb			; B = FF if CmdChar = 2D
LDBC8:
	bra	LDBCD
LDBCA:
	jmp	LDD7A		; rts
;
LDBCD:
	orab	x0044		; B = FF if CmdChar = 2B or 2D
	ldaa	CmdChar
	stab	x0048		; = FF if CmdChar = 2B or 2D
	clrb
	cmpa	#$30		; ASCII "0"
	bcs	LDBDA		; branch if CmdChar < 30
	decb			; B = FF if CmdChar >= 30
LDBDA:
	stab	x004A
	clrb
	cmpa	#$39		; C = 1 if CmdChar < 39, Z = 1 if CmdChar = 39
	bhi	LDBE2		; branch if CmdChar > 39
	decb			; B = FF if CmdChar <= 39
LDBE2:
	andb	x004A		; B = FF if 30 <= CmdChar <= 39, else 00
	orab	x0048		; B = FF if 30 <= CmdChar <= 39 or 2B or 2D, else 00
	andb	X01F1		; if CmdChar = 45 or 65, X01F1 = 01
					; result always 00? (2B,2D,30-39) AND (45,65)
	rorb
	bcc	LDC00
	ldab	x0048		; = FF if CmdChar = 2B or 2D
	tstb
	beq	LDBF6		; branch if CmdChar != 2B or 2D
	staa	MeasExponentSign	; MeasExponentSign = CmdChar
	jmp	LDCC0
;
LDBF6:				; CmdChar != 2B or 2D
	ldaa	#$0F
	anda	CmdChar
	staa	MeasExponent	; = lower nibble of CmdChar
	jmp	LDCC0
;
LDC00:
	ldaa	#$2E		; ASCII "."
	clrb
	cmpa	CmdChar
	bne	LDC09		; CmdChar != 2E
	decb			; B = FF if CmdChar = 2E
LDC09:
	ldaa	flagMeasArrayUnpacked
	stab	x0044
	clrb
	cmpa	#$01
	bne	LDC14
	decb			; B = FF if flagMeasArrayUnpacked = 01
LDC14:
	andb	x0044
	rorb			; C = 1 if CmdChar = 2E and flagMeasArrayUnpacked = 01
	bcc	LDC1A
	rts				; CmdChar = 2E and flagMeasArrayUnpacked = 01
;
LDC1A:				; CmdChar != 2E or flagMeasArrayUnpacked != 01
	ldaa	#$2B		; ASCII "+"
	clrb
	cmpa	CmdChar
	bne	LDC23
	decb			; B = FF if CmdChar = 2B
LDC23:
	ldaa	#$2D		; ASCII "-"
	stab	x0044
	clrb
	cmpa	CmdChar
	bne	LDC2E
	decb			; B = FF if CmdChar = 2D
LDC2E:
	orab	x0044
	tstb
	beq	LDC6A		; branch if CmdChar != 2B or 2D
	ldab	CmdChar
	stab	MeasPolaritySign	; = 2B or 2D
	ldaa	#$0F
	cmpa	MeasArray0
	bne	LDC4A		; branch if lower nibble of MeasArray0 != 0
	clr	MeasArray0
	ldaa	#$0F
	staa	MeasArray0	; MeasArray0 = 0F
	bra	LDC63
;
LDC4A:
	ldaa	#$2E		; ASCII "."
	cmpa	MeasArray0
	bne	LDC63		; branch if MeasArray0 = 2E
	clr	MeasArray0
	clr	flagMeasArrayUnpacked
	ldaa	#$01
	staa	flagMeasArrayUnpacked
	ldaa	#$2E		; ASCII "."
	staa	MeasArray0	; MeasArray0 = 2E, flagMeasArrayUnpacked = 01
LDC63:
	jmp	LDCC0
;
LDC6A:
	ldaa	#$45		; ASCII "E"
	clrb
	cmpa	CmdChar
	bne	LDC73
	decb			; B = FF if CmdChar = 45
LDC73:
	ldaa	#$65		; ASCII "e"
	stab	x0044
	clrb
	cmpa	CmdChar
	bne	LDC7E
	decb			; B = FF if CmdChar = 65
LDC7E:
	orab	x0044		; B = FF if CmdChar = 45 or 65
	tstb
	beq	LDCC0		; branch if CmdChar != 45 or 65
	ldab	#$01
	stab	X01F1
	ldaa	#$2B		; ASCII "+"
	staa	MeasExponentSign
	ldaa	#$01
	staa	flagMeasHasExponent	; X01F1-3 = 01 2B 01
	ldaa	#$0F
	clrb
	cmpa	MeasArray0
	bne	LDC9B
	decb			; B = FF if MeasArray0 = 0F
LDC9B:
	ldaa	#$2E		; ASCII "."
	stab	x0044		; FF if MeasArray0 = 0F
	clrb
	cmpa	MeasArray0
	bne	LDCA6
	decb			; B = FF if MeasArray0 = 2E
LDCA6:
	ldaa	MeasArray1
	stab	x0046		; FF if MeasArray0 = 2E
	clrb
	cmpa	#$0F
	bne	LDCB1
	decb			; B = FF if MeasArray1 = 0F
LDCB1:
	andb	x0046		; B = FF if MeasArray0 = 2E and MeasArray1 = 0F
	orab	x0044		; B = FF if MeasArray0 = 2E or 0F and MeasArray1 = 0F
	rorb
	bcc	LDCC0
	ldab	#$01
	stab	MeasArray0	; = 01 if if MeasArray0 = 2E or 0F and MeasArray1 = 0F
	clr	flagMeasArrayUnpacked
LDCC0:
	ldaa	X01F1		; if CmdChar = 45 or 65, X01F1 = 01
	tsta
	bne	LDD2C		; if CmdChar = 45 or 65, rts
	ldab	#$08
	cmpb	X01C7
	bne	LDCCE
	rts			; if X01C7 = 08, rts
;
LDCCE:
	ldaa	#$07
	cmpa	X01C7
	bne	LDCE3
	ldab	flagMeasArrayUnpacked
	tstb
	bne	LDCE3
	ldaa	#$2E		; ASCII "."
	cmpa	CmdChar
	beq	LDCE3
	rts			; if X01C7 = 07 and flagMeasArrayUnpacked = 00 and CmdChar = 2E, rts
;
LDCE3:				; X01C7 != 07 or flagMeasArrayUnpacked != 00 or CmdChar = 2E
	ldaa	#$2E		; ASCII "."
	clrb
	cmpa	MeasArray6
	bne	LDCEC
	decb			; B = FF if MeasArray6 = 2E
LDCEC:
	ldaa	MeasArray6
	stab	x0044
	clrb
	cmpa	#$01
	bls	LDCF7		; branch if MeasArray6 = 00
	decb			; B = FF if MeasArray6 > 00
LDCF7:
	stab	x0046
	clrb
	cmpa	#$0A
	bcc	LDCFF		; branch if MeasArray6 >= 0A
	decb			; B = FF if MeasArray6 < 0A
LDCFF:
	andb	x0046
	orab	x0044		; B = FF if MeasArray6 > 00 and < 0A or is 2E
	tstb
	beq	LDD07
	rts			; rts if MeasArray6 > 00 and < 0A or is 2E
;
LDD07:
	ldaa	flagMeasArrayUnpacked
	tsta
	bne	LDD30		; branch if flagMeasArrayUnpacked != 00
	ldab	MeasArray5
	clra
	cmpb	#$01
	bls	LDD16
	deca			; A = FF if MeasArray5 > 00
LDD16:
	staa	x0046
	clra
	cmpb	#$0A
	bcc	LDD1E
	deca			; A = FF if MeasArray5 < 0A
LDD1E:
	anda	x0046		; A = FF if 00 < MeasArray5 < 0A
	rora
	bcc	LDD30
	ldaa	#$2E		; ASCII "."
	cmpa	CmdChar
	beq	LDD30
	bra	LDD2F
LDD2C:
	jmp	LDD7A		; rts
LDD2F:
	rts
;
LDD30:				; flagMeasArrayUnpacked != 00 or MeasArray5 <= 00 and MeasArray5 >= 0A or CmdChar = 2E
	ldaa	#$2E		; ASCII "."
	clrb
	cmpa	CmdChar
	bne	LDD39
	decb			; B = FF if CmdChar = 2E
LDD39:
	ldaa	X01C7
	stab	x0044
	clrb
	cmpa	#$08
	bcc	LDD44
	decb			; B = FF if X01C7 < 08
LDD44:
	andb	x0044
	rorb
	bcc	LDD5B		; branch if CmdChar != 2E or X01C7 >= 08
	jsr	subShiftMeasArrayLeft
	ldaa	#$2E		; ASCII "."
	staa	MeasArray0
	ldaa	#$01
	staa	flagMeasArrayUnpacked
	inc	X01C7
	bra	LDD7A		; rts, MeasArray0 = 2E, flagMeasArrayUnpacked = 01, X01C7++
;
LDD5B:
	ldaa	CmdChar
	cmpa	#$30		; ASCII "0"
	bcs	LDD7A		; rts if CmdChar < 30
	cmpa	#$39		; ASCII "9"
	bhi	LDD7A		; rts if CmdChar > 39
	jsr	subShiftMeasArrayLeft
	ldaa	#$0F
	anda	CmdChar
	staa	CmdChar		; keep lower nibble of CmdChar
	ldaa	CmdChar
	staa	MeasArray0	; and put into MeasArray0
	inc	X01C7
LDD7A:
	rts
;===============================================================================
; puts table value at base X079B/C + index CmdTableIndex into A
subCmdTableLookup:
	ldaa	CmdTableIndex
	clrb
	adda	X079C
	adcb	X079B
	staa	X079C
	stab	X079B
	ldx	X079B
	ldaa	$00,x
	clrb
	rts
;===============================================================================
; clear bit3 & set bit6 of flagCmdParse
sub109:
	clr	flag01A1
	ldaa	#$F7
	anda	flagCmdParse
	staa	flagCmdParse	; clear bit3
	ldaa	#$40
	oraa	flagCmdParse
	staa	flagCmdParse	; set bit6
	rts
;===============================================================================
subStoreDisplayToRegister:
	jsr	subCopyDisp2MeasArray
	jsr	sub015		; does some kind of formatting on array data
	jsr	subCopyMeas2DispBytes
	ldaa	#$2D		; ASCII "-"
	cmpa	DisplayExponentSign
	bne	LDDC6
	ldab	DisplayExponent
	comb
	incb
	stab	x079E
	bra	LDDCC
;
LDDC6:
	ldaa	DisplayExponent
	staa	x079E
LDDCC:				; X079E contains DisplayExponent or compliment if negative
	ldaa	#$2D		; ASCII "-"
	cmpa	DisplayPolaritySign
	bne	LDDE8
	; negative polarity
	ldab	#$25
	ldaa	#$01		; register position 0
	addb	X079D		; values given in sub114 0A,11,18,1F,26 or 42
	adca	#$00
	stab	x0047
	staa	x0046
	ldaa	#$FF
	ldx	x0046		; possible locations 012F,0136,013D,0144,014B,0167
	staa	$00,x		; put in FF if negative polarity
	bra	LDDF9
;
LDDE8:	; positive polarity
	ldaa	#$25		; register position 0
	ldab	#$01
	adda	X079D
	adcb	#$00
	staa	x0045
	stab	x0044
	ldx	x0044
	clr	$00,x		; else put in 00 if positive

LDDF9:
	ldaa	X079D
	inca			; register position 1
	clrb
	adda	#$25
	adcb	#$01
	staa	x0047
	stab	x0046
	ldaa	DisplayArray7
	ldx	x0046
	staa	$00,x		; byte7 here

	ldaa	#$02		; register position 2
	adda	X079D
	clrb
	adda	#$25
	adcb	#$01
	staa	x0047
	stab	x0046
	ldaa	DisplayArray6
	asla
	asla
	asla
	asla
	oraa	DisplayArray5
	ldx	x0046
	staa	$00,x		; pack in byte6,5

	ldaa	#$03		; register position 3
	adda	X079D
	clrb
	adda	#$25
	adcb	#$01
	staa	x0047
	stab	x0046
	ldaa	DisplayArray4
	asla
	asla
	asla
	asla
	oraa	DisplayArray3
	ldx	x0046
	staa	$00,x		; pack in byte4,3

	ldaa	#$04		; register position 4
	adda	X079D
	clrb
	adda	#$25
	adcb	#$01
	staa	x0047
	stab	x0046
	ldaa	DisplayArray2
	asla
	asla
	asla
	asla
	oraa	DisplayArray1
	ldx	x0046
	staa	$00,x		; pack in byte2,1

	ldaa	#$05		; register position 5
	adda	X079D
	clrb
	adda	#$25
	adcb	#$01
	staa	x0047
	stab	x0046
	ldx	x0046
	clr	$00,x		; 00 here

	ldaa	#$06		; register position 6
	adda	X079D
	clrb
	adda	#$25
	adcb	#$01
	staa	x0047
	stab	x0046
	ldaa	x079E
	ldx	x0046
	staa	$00,x		; DisplayExponent here
	jsr	sub109		; clear bit3 & set bit6 of flagCmdParse
	clra
	clrb
	rts
;===============================================================================
; called with a cmd table base in X079F, offset in IGCmdRegisterNumber, mask in IGCmdRegBitClearMask, inde
; adjusts bits in IGCmdRegister0,1,2,4
subAdjustIGCmdRegister:
	ldx	X079F
	stx	X079B
	jsr	subCmdTableLookup	; puts table value at base X079B/C + index CmdTableIndex into A
	staa	CmdTableIndex		; now CmdTableIndex is bits to set
	ldaa	#$EE			; EE code for not valid command
	cmpa	CmdTableIndex
	bne	LDEAD
	jsr	subResetCmdFlags
	clr	flag01A1
	rts
;
LDEAD:					; command is valid
	ldaa	#$25
	ldab	#$01
	adda	IGCmdRegisterNumber	; values set in sub114 of 00,01,02,04.
	adcb	#$00
	staa	x0045
	stab	x0044
	ldx	x0044
	ldaa	$00,x			; IGCmdRegister0,1,2,4
	anda	IGCmdRegBitClearMask
	staa	$00,x			; apply mask to value (clear some bits)
	ldaa	#$25
	ldab	#$01
	adda	IGCmdRegisterNumber	; redundant index calculation
	adcb	#$00
	staa	x0045
	stab	x0044
	ldx	x0044
	ldaa	$00,x
	oraa	CmdTableIndex
	staa	$00,x			; set some bits
	ldaa	flagDispNeedUpdate
	rora
	bcc	LDEF0			; update not needed
	jsr	subSetAnnuncByte4
	jsr	subSetAnnuncBytes123
	clr	AnDUpdatedFlag
	jsr	subAnnuncNDisplayUpdate
	ldaa	#$01
	staa	AnDUpdatedFlag
LDEF0:
	jsr	sub109			; clear bit3 & set bit6 of flagCmdParse
	clr	flag01A1
	rts
;===============================================================================
; This subroutine was originally inside sub112 with branches around it.
; It is now in-lined for readability.
;sub113:
;	clr	flag01A1
;	clr	flag01ED
;	ldaa	#$EF
;	anda	flagCmdParse
;	staa	flagCmdParse		; clear bit4
;	rts
;===============================================================================
sub112:
	ldaa	CmdChar
	clrb
	cmpa	#$30		; ASCII "0"
	bcs	LDF13		; branch if CmdChar < "0"
	decb
LDF13:
	stab	x0044		; = 00 if CmdChar < "0", else FF
	clrb
	cmpa	#$37		; ASCII "7"
	bhi	LDF1B		; branch if CmdChar > "7"
	decb
LDF1B:				; B = 00 if CmdChar > "7", else FF
	andb	x0044
	rorb
	bcc	LDF87		; branch if CmdChar > "7" or < "0"
	anda	#$0F		; strip off ASCII 30, leaving number 0-7
	staa	CmdTableIndex
	ldaa	flag01ED	; set to 01 in sub107 and below, else 00
	tsta
	bne	LDF3D		; branch if 1
	ldab	#$01
	stab	flag01ED	; if 0, make 1
	ldaa	CmdTableIndex		; may contain 00-07
	staa	x019F
	ldaa	#$01
	staa	X01C7		; loop index
	bra	LDF6A
;
LDF87:
	;jsr	sub113
	;-- inlined sub113 here for readability
	clr	flag01A1
	clr	flag01ED
	ldaa	#$EF
	anda	flagCmdParse
	staa	flagCmdParse		; clear bit4
	rts
;
LDF3D:
	ldaa	X01C7
	cmpa	#$02
	bhi	LDF6A
	inc	X01C7
	ldaa	x019F		; may contain 00-07
	asla
	asla
	asla
	staa	x019F		; may contain 00,08,10,18,20,28,30,38
	bcc	LDF5C		; C always 0?
	ldaa	#$FF
	rora			; A = 00 if C = 0, else FF
	bcc	LDF5C		; branch if C = 0
	;bsr	sub113
	;-- inlined sub113 here for readability
	clr	flag01A1
	clr	flag01ED
	ldaa	#$EF
	anda	flagCmdParse
	staa	flagCmdParse	; clear bit4
LDF5C:
	ldaa	CmdTableIndex
	oraa	x019F
	staa	x019F
LDF6A:
	ldaa	#$03
	cmpa	X01C7
	bne	LDF85
	ldab	x019F
	stab	IGCmdRegister3
	ldaa	#$EF
	anda	flagCmdParse
	staa	flagCmdParse	; clear bit4
	jsr	sub109		; clear bit3 & set bit6 of flagCmdParse
	clr	flag01ED
LDF85:
	rts

;===============================================================================
; inputs: CmdTableIndex = letter number of CmdChar, starting at 0
; possibly handles commands involving Registers
sub114:
	;These are the Registers
	ldx	#$F8B1
	stx	X079B
	jsr	subCmdTableLookup		; puts table value at base X079B/C + index CmdTableIndex into A
	; CmdChar =	A	B	C	D	E	F	G	H	I	J	K	L	M	N	O	P	Q	R	S	T	U	V	W	X	Y	Z
	; table value =	EE	EE	00	01	EE	EE	02	EE	03	EE	EE	04	05	06	EE	EE	EE	07	EE	EE	08	09	EE	EE	0A	0B

	staa	CmdTableIndex
	ldaa	#$EE
	cmpa	CmdTableIndex
	bne	LDFAA		; branch if valid CmdChar
	jsr	subResetCmdFlags
	jmp	LE768		; set flagCmdParse bit6 and rts
;
LE018:
	jmp	LE459		; -> switch statement, X01C9 = 1-7
;
LDFAA:
	ldaa	X01C9		; set in sub116, values 0-7
	tsta
	bne	LE018		; branch if > 0
	ldab	DisplayArray1
	clra
	cmpb	#$09
	bls	LDFB9
	deca
LDFB9:
	staa	x0046
	clra
	cmpb	#$0E
	bcc	LDFC1
	deca
LDFC1:
	anda	x0046
	staa	x004A
	ldaa	DisplayArray2
	clrb
	cmpa	#$09
	bls	LDFCE
	decb
LDFCE:
	stab	x004C
	clrb
	cmpa	#$0E
	bcc	LDFD6
	decb
LDFD6:
	andb	x004C
	orab	x004A
	clra
	tstb
	beq	LDFDF
	deca
LDFDF:
	ldab	DisplayArray0
	andb	DisplayArray1
	andb	DisplayArray2
	andb	DisplayArray3
	andb	DisplayArray4
	andb	DisplayArray5
	andb	DisplayArray6
	andb	DisplayArray7
	staa	x0054
	clra
	cmpb	#$0F
	bne	LE004
	deca
LE004:
	oraa	x0054
	rora
	bcc	LE42C
	ldaa	#$08
	staa	flagCmdParse	; set bit3, clear other bits
	clr	flag01A1
	clr	flagX01FB
	jsr	subDisplayError4
	jmp	LE43C
;
;------ Switch LE42C ------------------

LE42C:
	ldaa	CmdTableIndex
	clrb
	asla
	rolb
	adda	#$A8
	adcb	#$F9
	staa	X0003
	stab	X0002
	ldx	X0002
	ldx	$00,x
	jmp	$00,x
	; index jump
	;	jump index values
;	f9a8
;	LE029
;	LE0BC
;	LE1AE
;	LE231
;	LE2FD
;	LE308
;	LE313
;	LE3F5
;	LE400
;	LE40B
;	LE416
;	LE421

;------ Switch LE42C case 0 ------------
; setting register "C"
LE029:
	jsr	sub015
	ldaa	flagTestMode
	tsta
	beq	LE0B2
	ldab	#$2B	; ASCII "+"
	cmpb	MeasExponentSign
	bne	LE09F
	ldaa	MeasExponent
	cmpa	#$01
	bne	LE04D
	ldaa	MeasArray7
	staa	X01AB
	ldaa	#$03
	staa	flagTestMode
	bra	LE0AA
LE09F:
	jmp	LE093
;
LE04D:
	ldaa	#$02
	cmpa	MeasExponent
	bne	LE093
	ldab	MeasArray7
	clra
	cmpb	#$01
	bne	LE05D
	deca
LE05D:
	staa	x0046
	ldaa	MeasArray6
	clrb
	cmpa	#$03
	bcc	LE068
	decb
LE068:
	andb	x0046
	rorb
	bcc	LE093
	ldab	MeasArray7
	aslb
	aslb
	aslb
	aslb
	orab	MeasArray6
	stab	X01AB
	ldaa	X01AB
	suba	#$06
	staa	X01AB
	ldaa	#$03
	staa	flagTestMode
	bra	LE0AA
;
LE093:
	jsr	subDisplayError4
LE0AA:
	clr	flag01ED
	jsr	sub109		; clear bit3 & set bit6 of flagCmdParse
	bra	LE0BA
;
LE0B2:
	ldaa	#$05
	staa	ErrorNumber
	jsr	subDisplayError
LE0BA:
	jmp	LE43C
;
;------ Switch LE42C case 1 ------------
; setting register "D"
LE0BC:
	jsr	sub015
	ldaa	#$2B	; ASCII "+"
	clrb
	cmpa	MeasPolaritySign
	bne	LE0C8
	decb
LE0C8:
	ldaa	MeasExponent
	stab	x0044
	clrb
	cmpa	#$03
	bhi	LE0D3
	decb
LE0D3:
	ldaa	MeasExponentSign
	stab	x0046
	clrb
	cmpa	#$2B	; ASCII "+"
	bne	LE0DE
	decb
LE0DE:
	andb	x0046
	ldaa	MeasExponent
	stab	x004A
	clrb
	cmpa	#$02
	bhi	LE0EB
	decb
LE0EB:
	ldaa	#$2D	; ASCII "-"
	stab	x004C
	clrb
	cmpa	MeasExponentSign
	bne	LE0F6
	decb
LE0F6:
	andb	x004C
	orab	x004A
	andb	x0044
	rorb
	jmp	LE191
;
LE0FF:
	ldaa	#$2B	; ASCII "+"
	clrb
	cmpa	MeasExponentSign
	bne	LE108
	decb
LE108:
	ldaa	#$03
	stab	x0044
	clrb
	cmpa	MeasExponent
	bne	LE113
	decb
LE113:
	andb	x0044
	comb
	rorb
	bcc	LE147
	ldab	#$2D	; ASCII "-"
	cmpb	MeasExponentSign
	bne	LE138
	jsr	subShiftMeasArrayRight
	dec	MeasExponent
	ldaa	MeasExponent
	tsta
	bne	LE136
	ldab	#$2B	; ASCII "+"
	stab	MeasExponentSign
LE136:
	bra	LE145
;

;
LE138:
	ldaa	#$2B	; ASCII "+"
	cmpa	MeasExponentSign
	bne	LE145
	jsr	subShiftMeasArrayRight
	inc	MeasExponent
LE145:
	bra	LE0FF
;
LE147:
	ldaa	MeasArray0
	oraa	MeasArray1
	tsta
	bne	LE189
	ldaa	flagX0121
	oraa	#$01
	staa	flagX0121
	ldaa	MeasArray7
	asla
	asla
	asla
	asla
	oraa	MeasArray6
	staa	X012C
	ldaa	MeasArray5
	asla
	asla
	asla
	asla
	oraa	MeasArray4
	staa	X012D
	ldaa	MeasArray3
	asla
	asla
	asla
	asla
	oraa	MeasArray2
	staa	X012E
	jsr	sub109		; clear bit3 & set bit6 of flagCmdParse
	bra	LE18F
;
LE189:
	jsr	subResetCmdFlags
	jsr	subDisplayError4
LE18F:
	bra	LE1AB
;
LE191:
	ldaa	#$2D	; ASCII "-"
	cmpa	MeasPolaritySign
	bne	LE1A5
	ldab	#$FE
	andb	flagX0121
	stab	flagX0121
	jsr	sub109		; clear bit3 & set bit6 of flagCmdParse
	bra	LE1AB
;
LE1A5:
	jsr	subResetCmdFlags
	jsr	subDisplayError4
LE1AB:
	jmp	LE43C
;
;------ Switch LE42C case 2 ------------  # digits displayed command
; setting register "G"

LE1AE:
	jsr	sub015		; seems to format MeasArray for a decimal before most significant digit
	ldaa	MeasExponent
	clrb
	cmpa	#$01
	bne	LE1BA
	decb
LE1BA:
	comb
	ldaa	#$2D		; ASCII "-"
	stab	x0046		; = FF if entered number not 1-9
	clrb
	cmpa	MeasPolaritySign
	bne	LE1C6
	decb			; = FF if negative emtered
LE1C6:
	orab	x0046
	stab	x004A
	clrb
	cmpa	MeasExponentSign
	bne	LE1D1
	decb
LE1D1:
	orab	x004A
	ldaa	MeasArray7	; contains entered digit (or most significant if multiple entered)
	stab	x004E		; = FF if negative, or outside 1-9 or negative exponent sign
	clrb
	cmpa	#$03	; 3
	bcc	LE1DE
	decb			; = FF if < 3
LE1DE:
	stab	x0050
	clrb
	;cmpa	#$06	; 6
	cmpa	#$07	; ***** MODDED modified to allow an entry of 7 digits *****
	bls	LE1E6
	decb			; = FF if > 6
LE1E6:
	orab	x0050
	orab	x004E
	rorb
	bcc	LE1F5		; branch if entry is 3-6
	jsr	subResetCmdFlags
	jmp	LE43C
;
LE1F5:
	ldaa	MeasArray5
	oraa	MeasArray6
	oraa	MeasArray4
	oraa	MeasArray3
	oraa	MeasArray2
	oraa	MeasArray1
	oraa	MeasArray0
	tsta
	beq	LE215		; branch if all digits are 0
	jsr	subResetCmdFlags	; must be some decimal digits, so error
	jsr	subDisplayError4
	jmp	LE43C
;
LE215:	; arrives here if # display digit entry is good.
	ldaa	MeasArray7

	; ***** MODDED: set the new flag if 7 digits requested, decrement to 6 so meter can carry on as usual. **
	clr	flag7Digits	; clear flag
	cmpa	#$07		; was 7 entered?
	bne	LE216		; branch if not
	inc	flag7Digits	; set flag
	deca			; set digits to 6
	staa	MeasArray7	; just in case it's used elsewhere
	; end modded
LE216:
	staa	CmdTableIndex
	ldx	#$F8CC
	stx	X079F
	ldaa	#$04
	staa	IGCmdRegisterNumber
	ldab	#$FC
	stab	IGCmdRegBitClearMask
	jsr	subAdjustIGCmdRegister
	; table lookup F8CC
	; CmdTableIndex		0	1	2	3	4	5	6	7	8	9
	; IGCmdReg OR bits   	EE	EE	EE	00	01	02	03	49	56	4D
	; digits to display of 3-6 cause values 0-3 to be put in bits0,1 of IGCmdRegister4
	jmp	LE43C
;
;------ Switch LE42C case 3 ------------
; probably for setting I, number of powerline cycles integrated
LE231:
	jsr	sub015
	ldaa	MeasExponent
	clrb
	cmpa	#$01
	bhi	LE23D
	decb
LE23D:
	ldaa	#$2D	; ASCII "-"
	stab	x0044
	clrb
	cmpa	MeasExponentSign
	bne	LE248
	decb
LE248:
	andb	x0044
	ldaa	MeasExponent
	stab	x0048
	clrb
	cmpa	#$03
	bhi	LE255
	decb
LE255:
	ldaa	#$2B	; ASCII "+"
	stab	x004A
	clrb
	cmpa	MeasExponentSign
	bne	LE260
	decb
LE260:
	andb	x004A
	orab	x0048
	ldaa	MeasArray7
	stab	x0050
	clrb
	cmpa	#$01		; lead digit to be 1
	bne	LE26F
	decb
LE26F:
	andb	x0050
	ldaa	MeasPolaritySign
	stab	x0054
	clrb
	cmpa	#$2B		; ASCII "+"
	bne	LE27C		; and positive
	decb
LE27C:
	andb	x0054
	rorb
	bcc	LE2AC

	;--- loop to check other digits are 0
	clr	x01CA
LE284:
	ldaa	x01CA
	cmpa	#$06
	bhi	LE2B2
	ldaa	#$D1
	ldab	#$01	; base address of MeasArray
	adda	x01CA
	adcb	#$00
	staa	x0045
	stab	x0044
	ldx	x0044
	ldaa	$00,x
	tsta
	beq	LE2A5
	jsr	subResetCmdFlags
	jsr	subDisplayError4
LE2A5:
	inc	x01CA
	bra	LE284
	;--- end loop

LE2AC:
	jsr	subResetCmdFlags
	jsr	subDisplayError4

LE2B2:	; entry was good
	ldaa	#$2D	; ASCII "-"
	cmpa	MeasExponentSign		; only negative exponent would be for 0.1E-1 or 0.01 PLC
	bne	LE2D1
	clr	CmdTableIndex			; only 0
	ldx	#$F8CB
	stx	X079F
	ldaa	#$01
	staa	IGCmdRegisterNumber
	ldab	#$F8
	stab	IGCmdRegBitClearMask
	jsr	subAdjustIGCmdRegister		; IGCmdRegister1 bits2-0 cleared and set
	; table lookup F8CB
	; CmdTableIndex		0	1	2	3	4	5	6	7	8	9
	; IGCmdReg OR bits   	00 	EE	EE	EE	00	01	02	03	49	56

	bra	LE2FA
;
LE2D1:
	ldaa	#$2B	; ASCII "+"
	cmpa	MeasExponentSign
	bne	LE2F4
	ldab	MeasExponent
	incb
	stab	CmdTableIndex	; = exponent + 1 --> 1,2,3,4 for .1,1,10,100 PLC
	ldx	#$F8F7
	stx	X079F
	ldaa	#$01
	staa	IGCmdRegisterNumber
	ldab	#$F8
	stab	IGCmdRegBitClearMask
	jsr	subAdjustIGCmdRegister
	; table lookup F8F7
	; CmdTableIndex		0	1	2	3	4	5	6	7	8	9
	; IGCmdReg OR bits   	EE	01	02	03	04	05	FF	02	93	62

	bra	LE2FA
;
LE2F4:	; exponent not "=" or "-"
	jsr	subResetCmdFlags
	jsr	subDisplayError4
LE2FA:
	jmp	LE43C
;
;------ Switch LE42C case 4 ------------
; setting register "L"

LE2FD:
	ldaa	#$1F
	staa	X079D
	jsr	subStoreDisplayToRegister
	jmp	LE43C
;
;------ Switch LE42C case 5 ------------
; setting register "M"
LE308:
	ldaa	#$05
	staa	ErrorNumber
	jsr	subDisplayError
	jmp	LE43C
;
;------ Switch LE42C case 6 ------------
; setting register "N"
LE313:
	jsr	sub015
	ldaa	MeasExponent
	clrb
	cmpa	#$01
	bcs	LE31F
	decb
LE31F:
	stab	x0044
	clrb
	cmpa	#$04
	bhi	LE327
	decb
LE327:
	andb	x0044
	ldaa	#$2B	; ASCII "+"
	stab	x0048
	clrb
	cmpa	MeasPolaritySign
	bne	LE334
	decb
LE334:
	andb	x0048
	stab	x004C
	clrb
	cmpa	MeasExponentSign
	bne	LE33F
	decb
LE33F:
	andb	x004C
	rorb
	bcc	LE3AA
	ldab	#$07
	subb	MeasExponent
	stab	x01CA
LE34C:
	ldaa	x01CA
	clrb
	cmpa	#$FF
	bne	LE355
	decb
LE355:
	comb
	rorb
	bcc	LE374
	clrb
	adda	#$D1
	adcb	#$01	; base address of MeasArray
	staa	x0049
	stab	x0048
	ldx	x0048
	ldaa	$00,x
	tsta
	beq	LE36F
	jsr	subResetCmdFlags
	jsr	subDisplayError4
LE36F:
	dec	x01CA
	bra	LE34C
;
LE3AA:
	jmp	LE3EC
;
LE374:
	ldaa	MeasExponent
	staa	x01CA
LE37A:
	ldaa	x01CA
	cmpa	#$04
	bcc	LE389
	jsr	subShiftMeasArrayRight
	inc	x01CA
	bra	LE37A
;
LE389:
	ldaa	MeasArray6
	oraa	MeasArray7
	oraa	MeasArray5
	oraa	MeasArray4
	tsta
	bne	LE39E
	jsr	subResetCmdFlags
	jsr	subDisplayError4
LE39E:
	ldaa	MeasArray7
	asla
	asla
	asla
	asla
	oraa	MeasArray6
	staa	X012A
	ldaa	MeasArray5
	asla
	asla
	asla
	asla
	oraa	MeasArray4
	staa	X012B
	ldaa	X012A
	clrb
	tsta
	bne	LE3C5
	decb
LE3C5:
	ldaa	X012B
	stab	x0044
	clrb
	cmpa	#$01
	bne	LE3D0
	decb
LE3D0:
	andb	x0044
	rorb
	bcc	LE3DF
	ldab	#$F7
	andb	flagX0121
	stab	flagX0121
	bra	LE3E7
;
LE3DF:
	ldaa	#$08
	oraa	flagX0121
	staa	flagX0121
LE3E7:
	jsr	sub109		; clear bit3 & set bit6 of flagCmdParse
	bra	LE3F2
;
LE3EC:
	jsr	subResetCmdFlags
	jsr	subDisplayError4
LE3F2:
	jmp	LE43C
;
;------ Switch LE42C case 7 ------------
; setting register "R"
LE3F5:
	ldaa	#$0A
	staa	X079D
	jsr	subStoreDisplayToRegister
	jmp	LE43C
;
;------ Switch LE42C case 8 ------------
; setting register "U"
LE400:
	ldaa	#$26
	staa	X079D
	jsr	subStoreDisplayToRegister
	jmp	LE43C
;
;------ Switch LE42C case 9 ------------
; setting register "V"
LE40B:
	ldaa	#$05
	staa	ErrorNumber
	jsr	subDisplayError
	jmp	LE43C
;
;------ Switch LE42C case 10 ------------
; setting register "Y"
LE416:
	ldaa	#$11
	staa	X079D
	jsr	subStoreDisplayToRegister
	jmp	LE43C
;
;------ Switch LE42C case 11 ------------
; setting register "Z"
LE421:
	ldaa	#$18
	staa	X079D
	jsr	subStoreDisplayToRegister
	jmp	LE43C
;
;------- end Switch LE42C -----------------------


;
LE43C:
	ldaa	#$80
	anda	flagCmdParse	; test bit7
	tsta
	bne	LE457
	jsr	sub026
	clr	AnDUpdatedFlag
	jsr	subAnnuncNDisplayUpdate
	ldaa	#$01
	staa	AnDUpdatedFlag
	ldaa	#$A5
	staa	HPIBIntrMask
LE457:
	jmp	LE768
;

;------ Switch LE459 -------------------------------
; This switch branches on selection of the various Registers

LE459:
	ldaa	CmdTableIndex
	clrb
	asla
	rolb
	adda	#$C0
	adcb	#$F9
	staa	X0003
	stab	X0002
	ldx	X0002
	ldx	$00,x
	jmp	$00,x
	; index jump
	;	jump index values
;	f9c0
;	LE45F
;	LE46E
;	LE4F1
;	LE512
;	LE551
;	LE561
;	LE5C0
;	LE61A
;	LE657
;	LE667
;	LE720
;	LE730

;------ Switch LE459 case 0 ------------
; Register C, Count
LE45F:
	ldaa	#$2D
	staa	X0790
	ldab	#$20
	stab	X0791
	jsr	sub023
	jmp	LE750
;
;------ Switch LE459 case 1 ------------
; Register D, Delay
LE46E:
	ldaa	flagX0121
	rora
	bcc	LE47B
	ldaa	#$2B	; ASCII "+"
	staa	MeasPolaritySign
	bra	LE480
;
LE47B:
	ldaa	#$2D	; ASCII "-"
	staa	MeasPolaritySign
LE480:
	ldaa	#$2B	; ASCII "+"
	staa	MeasExponentSign
	clr	MeasExponent
	ldaa	#$0F
	anda	X012E
	staa	MeasArray0
	ldaa	X012E
	lsra
	lsra
	lsra
	lsra
	staa	MeasArray1
	ldaa	#$0F
	anda	X012D
	staa	MeasArray2
	ldaa	X012D
	lsra
	lsra
	lsra
	lsra
	staa	MeasArray4
	ldaa	#$2E
	staa	MeasArray3
	ldaa	#$0F
	anda	X012C
	staa	MeasArray5
	ldaa	X012C
	lsra
	lsra
	lsra
	lsra
	staa	MeasArray6
	ldaa	#$0F
	staa	MeasArray7
	jsr	subCopyMeas2DispBytes
	ldaa	#$42	; ASCII "B"
	staa	X079D
	jsr	subStoreDisplayToRegister
	ldaa	#$42
	staa	X0790
	ldab	#$20
	stab	X0791
	jsr	sub023
	jmp	LE750
;
;------ Switch LE459 case 2 ------------
; Register G, Number of Digits Displayed
LE4F1:
	jsr	subClearAccumRegister
	ldaa	#$03
	anda	IGCmdRegister4	; get bits2,1, code is 00 = 3, 01 = 4,..
	adda	#$03
	staa	AccumRegister1	; # digits
	ldaa	#$01
	staa	AccumRegister6
	ldaa	#$42
	staa	X0790
	ldab	#$20
	stab	X0791
	jsr	sub023
	jmp	LE750
;
;------ Switch LE459 case 3 ------------
; Register I, Number of Power Line Cycles to Integrate
LE512:
	jsr	subClearAccumRegister
	ldaa	#$01
	staa	AccumRegister1
	ldaa	#$07
	anda	IGCmdRegister1
	staa	X01CC
	ldaa	X01CC
	tsta
	bne	LE52F
	ldab	#$FF
	stab	AccumRegister6
	bra	LE542
;
LE52F:
	ldaa	X01CC
	cmpa	#$01
	bne	LE53B
	clr	AccumRegister6
	bra	LE542
;
LE53B:
	ldaa	X01CC
	deca
	staa	AccumRegister6
LE542:
	ldaa	#$42
	staa	X0790
	ldab	#$20
	stab	X0791
	jsr	sub023
	jmp	LE750
;
;------ Switch LE459 case 4 ------------
; Register L, Lower
LE551:
	ldaa	#$1F
	staa	X0790
	ldab	#$20
	stab	X0791
	jsr	sub023
	jmp	LE750
;
;------ Switch LE459 case 5 ------------
; Register M, Mean
LE561:
	ldaa	RegisterC1	; always 00
	tsta
	bne	LE56C
	jsr	sub091
	jmp	LE750
;
LE56C:
	ldaa	#$0E
	ldab	#$01
	psha
	pshb
	ldaa	#$60
	ldab	#$01
	psha
	pshb
	ldaa	#$67
	ldab	#$01		; 0167 = base address of AccumRegister
	psha
	pshb
	ldaa	#$03
	psha
	jsr	subRegisterAdd	; 0167 = 010E  + 0160
	ldaa	#$67
	ldab	#$01
	psha
	pshb
	ldaa	#$52
	ldab	#$01
	psha
	pshb
	ldaa	#$67
	ldab	#$01
	psha
	pshb
	ldaa	#$03
	psha
	jsr	subRegisterDivide	; 0167 = 0167 / 0152 (count)
	ldaa	#$84
	ldab	#$01
	psha
	pshb
	ldaa	#$67
	ldab	#$01
	psha
	pshb
	psha
	pshb
	ldaa	#$03
	psha
	jsr	subRegisterAdd	; 0167 = 0184  + 0167		0184 may be an initial measurement offset, x1
	ldaa	#$42
	staa	X0790
	ldab	#$20
	stab	X0791
	jsr	sub023
	jmp	LE750
;
;------ Switch LE459 case 6 ------------
; Register N, Number of Readings
LE5C0:
	ldaa	X012A
	lsra
	lsra
	lsra
	lsra
	staa	MeasArray7
	ldaa	#$0F
	anda	X012A
	staa	MeasArray6
	ldaa	X012B
	lsra
	lsra
	lsra
	lsra
	staa	MeasArray5
	ldaa	#$0F
	anda	X012B
	staa	MeasArray4
	ldaa	#$2E	; ASCII "."
	staa	MeasArray3
	clr	MeasArray2
	clr	MeasArray1
	clr	MeasArray0
	clr	MeasExponent
	ldaa	#$2B	; ASCII "+"
	staa	MeasExponentSign
	ldaa	#$2B	; ASCII "+"
	staa	MeasPolaritySign
	jsr	subCopyMeas2DispBytes
	ldaa	#$42
	staa	X079D
	jsr	subStoreDisplayToRegister
	ldaa	#$42
	staa	X0790
	ldab	#$20
	stab	X0791
	jsr	sub023
	jmp	LE750
;
;------ Switch LE459 case 7 ------------
; Register R, Resistor value for dBm
LE61A:
	ldaa	#$0A
	staa	X0790
	ldab	#$20
	stab	X0791
	jsr	sub023
	ldaa	#$08
	anda	IGCmdRegister4
	tsta
	beq	LE654	; branch if bit3 = 0
	ldaa	#$2D	; ASCII "-"
	cmpa	MeasPolaritySign
	bne	LE640
	ldab	#$50
	orab	X0200
	stab	X0200
	bra	LE648
LE654:
	jmp	LE750
;
LE640:
	ldaa	#$90
	oraa	X0200
	staa	X0200
LE648:
	clr	flag01A1
	clr	flagCmdParse
	clr	flagX01FB
	jmp	LD6BF
;
;------ Switch LE459 case 8 ------------
; Register U, Upper
LE657:
	ldaa	#$26
	staa	X0790
	ldab	#$20
	stab	X0791
	jsr	sub023
	jmp	LE750
;
;------ Switch LE459 case 9 ------------
; Register V, Variance
LE667:
	ldaa	#$52
	ldab	#$01
	psha
	pshb
	ldaa	#$5D
	ldab	#$F6
	psha
	pshb
	ldaa	#$B1
	ldab	#$01
	psha
	pshb
	ldaa	#$03
	psha
	jsr	subRegisterSubtract	; 01B1 = 0152 (= count) - F65D (= 1)
	ldaa	X01B1
	clrb
	tsta
	beq	LE687
	decb
LE687:
	ldaa	X01B2
	stab	x0044
	clrb
	tsta
	bne	LE691
	decb
LE691:
	orab	x0044
	rorb
	bcc	LE69B
	jsr	sub091
	jmp	LE71D
;
LE69B:
	ldaa	#$0E
	ldab	#$01
	psha
	pshb
	ldaa	#$60
	ldab	#$01
	psha
	pshb
	ldaa	#$6F
	ldab	#$01
	psha
	pshb
	ldaa	#$03
	psha
	jsr	subRegisterAdd	; 016F = 010E  + 0160
	ldaa	#$6F
	ldab	#$01
	psha
	pshb
	psha
	pshb
	psha
	pshb
	ldaa	#$03
	psha
	jsr	subRegisterMultiply	; 016F = 016F * 016F
	ldaa	#$6F
	ldab	#$01
	psha
	pshb
	ldaa	#$52
	ldab	#$01
	psha
	pshb
	ldaa	#$6F
	ldab	#$01
	psha
	pshb
	ldaa	#$03
	psha
	jsr	subRegisterDivide	; 016F = 016F / 0152
	ldaa	#$59
	ldab	#$01
	psha
	pshb
	ldaa	#$6F
	ldab	#$01
	psha
	pshb
	ldaa	#$67
	ldab	#$01			; 0167 = base address of AccumRegister
	psha
	pshb
	ldaa	#$03
	psha
	jsr	subRegisterSubtract	; 0167 = 0159 - 016F
	ldaa	#$67
	ldab	#$01
	psha
	pshb
	ldaa	#$B1
	ldab	#$01
	psha
	pshb
	ldaa	#$67
	ldab	#$01
	psha
	pshb
	ldaa	#$03
	psha
	jsr	subRegisterDivide		; 0167 = 0167 / 01B1
	ldaa	#$42
	staa	X0790
	ldab	#$20
	stab	X0791
	jsr	sub023
LE71D:
	jmp	LE750
;
;------ Switch LE459 case 10 ------------
; Register Y,
LE720:
	ldaa	#$11
	staa	X0790
	ldab	#$20
	stab	X0791
	jsr	sub023
	jmp	LE750
;
;------ Switch LE459 case 11 ------------
; Register Z,
LE730:
	ldaa	#$18
	staa	X0790
	ldab	#$20
	stab	X0791
	jsr	sub023

;------ end Switch LE459 --------------------------


LE750:
	ldaa	#$04
	oraa	flagCmdParse
	staa	flagCmdParse	; set bit2
	ldaa	#$7F
	anda	flagHPIBOutput
	staa	flagHPIBOutput	; clear bit7
	ldaa	#$EF
	anda	flagX0121
	staa	flagX0121	; clear bit7
LE768:
	ldaa	#$40
	oraa	flagCmdParse
	staa	flagCmdParse	; set bit6
	rts
;===============================================================================

sub115:
	clr	X0789
	ldaa	#$20
	staa	HPIBSerialPollStatus
	jsr	subHPIBRequestService
	rts
;===============================================================================

sub116:
	ldaa	#$BF
	anda	flagCmdParse
	staa	flagCmdParse		; clear bit 6 of flagCmdParse
	ldaa	#$10
	anda	flagCmdParse
	tsta
	beq	LE79D
	jsr	sub112		; if bit 4 of flagCmdParse = 1
	ldaa	#$50
	anda	flagCmdParse
	tsta
	beq	LE79D
	rts			; if bits 4,6 of flagCmdParse = 1
;
LE79D:
	ldaa	flagCmdParse
	anda	#$01
	tsta
	beq	LE7B6
	jsr	sub107		; if bit 0 of flagCmdParse = 1
	jsr	subCopyMeas2DispBytes
	ldaa	flagCmdParse
	anda	#$01
	tsta
	beq	LE7B4
	rts

LE7B4:
	bra	sub116

;
;----Switch LE7B6 ---------------------
LE7B6:				; if bit 0 of flagCmdParse = 0
	ldaa	flag01A1
	clrb
	asla
	rolb
	adda	#$1C
	adcb	#$FA
	staa	X0003
	stab	X0002
	ldx	X0002
	ldx	$00,x
	jmp	$00,x
	; index jump
	;	jump index values
;	fa1c
;	LE7BC
;	LE885
;	LEBD9


;----Switch LE7B6  case 0 -----
LE7BC:
	ldaa	#$57		; ASCII "W", Numeric Separator?
	cmpa	CmdChar
	bne	LE7CF
	ldab	flagCmdParse
	orab	#$01
	stab	flagCmdParse	; set bit0
	jsr	sub026
	rts
;
LE7CF:
	ldaa	#$48		; ASCII "H", software reset
	cmpa	CmdChar
	bne	LE7D9
	jmp	LD971		; jumps into subRST
;
LE7D9:
	ldaa	CmdChar
	clrb
	cmpa	#$30		; ASCII "0"
	bcs	LE7E2
	decb
LE7E2:
	stab	x0044
	clrb
	cmpa	#$39		; ASCII "9"
	bhi	LE7EA
	decb
LE7EA:
	andb	x0044		; = FF if between "0" and "9", else 00
	stab	x0048
	clrb
	cmpa	#$2B		; ASCII "+"
	bne	LE7F9
	decb
LE7F9:
	orab	x0048
	stab	x004C		; = FF if between "0" and "9" or "+", else 00
	clrb
	cmpa	#$2D		; ASCII "-"
	bne	LE803
	decb
LE803:
	orab	x004C
	stab	x0050		; = FF if between "0" and "9" or "+" or "-", else 00
	clrb
	cmpa	#$45	; ASCII "E"
	bne	LE80D
	decb
LE80D:
	orab	x0050
	stab	x0054		; = FF if between "0" and "9" or "+" or "-" or "E", else 00
	clrb
	cmpa	#$65	; ASCII "e"
	bne	LE817
	decb
LE817:
	orab	x0054
	stab	x0058		; = FF if  "0-9,+,-,E,e", else 00
	clrb
	cmpa	#$2E	; ASCII "."
	bne	LE821
	decb
LE821:
	orab	x0058		; = FF if  "0-9,+,-,E,e,.", else 00
	rorb
	bcc	LE845		; branch if none of those
	ldab	flagCmdParse
	orab	#$01
	stab	flagCmdParse	; set bit0
	jsr	sub107
	jsr	subCopyMeas2DispBytes
	ldaa	flagCmdParse
	anda	#$01
	tsta
	beq	LE842		; branch if bit0 = 0
	rts

LE842:
	jmp	sub116		; recursion on further characters
;
LE845:
	ldaa	CmdChar
	clrb
	cmpa	#$5A		; ASCII "Z"
	bhi	LE84E
	decb
LE84E:
	stab	x0044		; = FF if <= "Z"
	clrb
	cmpa	#$42		; ASCII "B"
	bcs	LE856
	decb
LE856:
	andb	x0044
	rorb
	bcc	LE880		; branch if not "B-Z"
	suba	#$42		; ASCII "B"
	clrb
	adda	#$34
	adcb	#$F8
	staa	x004D
	stab	x004C
	ldx	x004C
	ldaa	$00,x
	; CmdChar 	B	C	D	E	F	G	H	I	J	K	L	M	N	O	P	Q	R	S	T	U	V	W	X	Y	Z
	; cmd offset	EE	01	02	EE	03	EE	EE	EE	EE	EE	04	05	EE	06	07	EE	08	09	0A	EE	0C	EE	60	40	20

	staa	X01C6
	ldaa	#$EE
	cmpa	X01C6
	bne	LE879
LE880:				; if null command code = EE
	jsr	subResetCmdFlags
	rts
;
LE879:				; else if valid code
	ldaa	#$01
	staa	flag01A1
	rts
;
;----Switch LE7B6  case 1 -----
LE885:
	ldaa	CmdChar
	clrb
	cmpa	#$30	; ASCII "0"
	bcs	LE88E	; branch if CmdChar < "0"
	decb
LE88E:			; B = FF if CmdChar >= "0"
	stab	x0044
	clrb
	cmpa	#$39	; ASCII "9"
	bhi	LE896	; branch if CmdChar > "9"
	decb
LE896:			; B = FF if CmdChar <= "9"
	andb	x0044
	rorb
	bcc	LE902	; branch if CmdChar < "0" or > "9"
	anda	#$0F	; convert from ASCII to number
	staa	CmdTableIndex	; = 0-9 CmdChar
	jmp	LEAD0
;
LE902:
	jmp	LEBC6
;
;----Switch LE7B6  case 2 -----
;
LEBD9:
	ldaa	CmdChar
	clrb
	cmpa	#$41	; ASCII "A"
	bcs	LEBE2	; branch if CmdChar < "A"
	decb
LEBE2:			; B = FF if CmdChar >= "A", else 00
	stab	x0044
	clrb
	cmpa	#$5A	; ASCII "Z"
	bhi	LEBEA	; branch if CmdChar > "Z"
	decb
LEBEA:			; B = FF if CmdChar <= "Z", else 00
	andb	x0044
	rorb
	bcc	LEBF9	; branch if CmdChar < "A" or > "Z"
	suba	#$41	; ASCII "A"
	staa	CmdTableIndex	; = letter number of CmdChar, starting at 0
	jsr	sub114	; only place sub114 is called
	rts
;
LEBF9:			; CmdChar not "A" to "Z"
	ldaa	#$0F
	anda	CmdChar	; lower nibble, could be 0-F
	staa	CmdTableIndex
	ldaa	CmdTableIndex
	clrb
	cmpa	#$09
	bhi	LEC0A	; branch if > 9
	decb
LEC0A:			; B = FF if value 0-9, else 00
	andb	#$FF
	tstb
	beq	LEC76	; branch if B > 9
	jmp	LED10	; do LED10 switch
;
LEC76:
	jsr	subResetCmdFlags
	rts
;
;---- endSwitch LE7B6 ---------------------


;----Switch LEAD0 ---------------------
LEAD0:
	ldaa	X01C6
	clrb
	asla
	rolb
	adda	#$D8
	adcb	#$F9
	staa	X0003
	stab	X0002
	ldx	X0002
	ldx	$00,x
	jmp	$00,x
	; index jump
	;	jump index values
;	f9d8
;	LE8A6
;	LE8AB
;	LE8B0
;	LE928
;	LE93B
;	LE964
;	LE997
;	LE9AD
;	LE9C3
;	LE9F7
;	LEA1D
;	LEA98
;	LEABA

;----Switch LEAD0  case 0 -----
LE8A6:
	jsr	subResetCmdFlags
	rts
;
;----Switch LEAD0  case 1 -----

LE8AB:
	jsr	subResetCmdFlags
	rts
;
;----Switch LEAD0  case 2 -----

LE8B0:
	ldx	#$F893
	stx	X079F
	ldaa	#$04
	staa	IGCmdRegisterNumber
	ldab	#$EF
	stab	IGCmdRegBitClearMask
	jsr	subAdjustIGCmdRegister
	; table lookup F893
	; CmdTableIndex		0	1	2	3	4	5	6	7	8	9
	; IGCmdReg OR bits   	00 	10 	EE 	EE	EE	EE	EE	EE   	EE	EE

	ldaa	#$80
	anda	flagCmdParse	; test bit7
	tsta
	bne	LE926
	ldaa	#$10
	anda	IGCmdRegister4
	tsta
	beq	LE8DA	; branch if bit4 = 0
	ldaa	#$01
	staa	flagDispNeedUpdate
LE926:
	rts
;
LE8DA:
	clr	AnDUpdatedFlag
	jsr	subResetDisplay
	ldaa	#$01
	staa	AnDUpdatedFlag
	ldaa	#$90		; data coming, mode is BCD code B (0-9,E,H,L,P,and -)
	staa	ioDAdata
	jsr	subStrobeDisplay
	ldaa	#$1C		; "H" with no decimal (or maybe on the driver chip this comes out as "-"
	staa	ioDAdata
	jsr	subStrobeDisplay
	jsr	subStrobeDisplay
	jsr	subStrobeDisplay
	jsr	subStrobeDisplay
	jsr	subStrobeDisplay
	jsr	subStrobeDisplay
	ldaa	#$1F		; blank
	staa	ioDAdata
	jsr	subStrobeDisplay
	jsr	subStrobeDisplay
	clr	flagDispNeedUpdate
	rts
;
;----Switch LEAD0  case 3 -----

LE928:
	ldx	#$F84D
	stx	X079F
	clr	IGCmdRegisterNumber
	ldaa	#$1F
	staa	IGCmdRegBitClearMask
	jsr	subAdjustIGCmdRegister
	; table lookup F84D
	; CmdTableIndex		0	1	2	3	4	5	6	7	8	9
	; IGCmdReg OR bits   	EE	60	40	20	C0	A0	EE	EE	EE	EE

	rts
;
;----Switch LEAD0  case 4 -----

LE93B:
	ldaa	#$31	; ASCII "1"
	cmpa	CmdChar
	bne	LE95F
	ldab	#$06
	orab	X0789
	stab	X0789
	ldx	#$F89D
	stx	X079F
	ldaa	#$02
	staa	IGCmdRegisterNumber
	ldab	#$BF
	stab	IGCmdRegBitClearMask
	jsr	subAdjustIGCmdRegister
	; table lookup F89D
	; CmdTableIndex		0	1	2	3	4	5	6	7	8	9
	; IGCmdReg OR bits   	00	40	EE	EE	EE	EE	EE	EE	EE	EE

	rts
;
LE95F:
	jsr	subResetCmdFlags
	rts
;
;----Switch LEAD0  case 5 -----

LE964:
	ldaa	#$32	; ASCII "2"
	cmpa	CmdChar
	bne	LE96E
	clr	RegisterC1
LE96E:
	ldx	#$F86B
	stx	X079F
	ldaa	#$02
	staa	IGCmdRegisterNumber
	ldab	#$F0
	stab	IGCmdRegBitClearMask
	jsr	subAdjustIGCmdRegister
	; table lookup F86B
	; CmdTableIndex		0	1	2	3	4	5	6	7	8	9
	; IGCmdReg OR bits   	00 	10 	EE 	EE	EE	EE	EE	EE   	EE	EE

	ldaa	#$EE
	cmpa	CmdChar
	beq	LE994
	ldab	#$30	; ASCII "0"
	cmpb	CmdChar
	beq	LE994
	ldaa	#$01
	staa	X018C
LE994:
	rts
;
;----Switch LEAD0  case 6 -----

LE997:
	ldx	#$F8A7
	stx	X079F
	ldaa	#$02
	staa	IGCmdRegisterNumber
	ldab	#$7F
	stab	IGCmdRegBitClearMask
	jsr	subAdjustIGCmdRegister
		; table lookup F8A7
	; CmdTableIndex		0	1	2	3	4	5	6	7	8	9
	; IGCmdReg OR bits   	00 	10 	EE 	EE	EE	EE	EE	EE   	EE	EE

	rts
;
;----Switch LEAD0  case 7 -----

LE9AD:
	ldx	#$F87F
	stx	X079F
	ldaa	#$04
	staa	IGCmdRegisterNumber
	ldab	#$DF
	stab	IGCmdRegBitClearMask
	jsr	subAdjustIGCmdRegister
		; table lookup F87F
	; CmdTableIndex		0	1	2	3	4	5	6	7	8	9
	; IGCmdReg OR bits   	00 	10 	EE 	EE	EE	EE	EE	EE   	EE	EE

	rts
;
;----Switch LEAD0  case 8 -----	Range select R1-R9, maybe?

LE9C3:
	ldx	#$F857
	stx	X079B
	jsr	subCmdTableLookup	; puts table value at base X079B/C + index CmdTableIndex into A
	staa	x01CA
 	; CmdTableIndex= 0-9 (CmdChar is a number)
	; CmdChar =	0	1	2	3	4	5	6	7	8	9
	; x01CA =	EE	01	00	02	04	06	08	0A	0C	0E
	ldaa	x01CA
	cmpa	#$01
	bne	LE9DD
	ldab	#$FE	; x01CA = 1 -> CmdChar = 1
	stab	x01CA
	bra	LE9E2
;
LE9DD:
	ldaa	#$F0
	staa	x01CA
LE9E2:			; x01CA = FE if CmdChar = 1, else F0
	ldx	#$F857
	stx	X079F
	clr	IGCmdRegisterNumber
	ldaa	x01CA
	staa	IGCmdRegBitClearMask
	jsr	subAdjustIGCmdRegister
	; table lookup F857
	; CmdTableIndex		0	1	2	3	4	5	6	7	8	9
	; IGCmdReg OR bits   	EE	01	00	02	04	06	08	0A	0C	0E

	rts
;
;----Switch LEAD0  case 9 -----

LE9F7:
	ldx	#$F893
	stx	X079F
	clr	IGCmdRegisterNumber
	ldaa	#$EF
	staa	IGCmdRegBitClearMask
	jsr	subAdjustIGCmdRegister
	; table lookup F893
	; CmdTableIndex		0	1	2	3	4	5	6	7	8	9
	; IGCmdReg OR bits   	00 	10 	EE 	EE	EE	EE	EE	EE   	EE	EE

	ldaa	#$10
	anda	IGCmdRegister0
	tsta
	bne	LEA15
	clr	flagX01FC
	rts
;
LEA15:
	ldaa	#$01
	staa	flagX01FC
	rts
;
;----Switch LEAD0  case 10 -----

LEA1D:
	ldx	#$F861
	; table lookup F861
	; CmdTableIndex		0	1	2	3	4	5	6	7	8	9
	; IGCmdReg OR bits   	EE 	00	40 	80 	C0 	EE	EE 	EE 	EE 	EE
	stx	X079B
	jsr	subCmdTableLookup	; puts table value at base X079B/C + index CmdTableIndex into A
;zzz
	staa	x01CA
	ldaa	#$EE
	cmpa	x01CA
	beq	LEA5E
	ldab	X0789
	andb	#$01
	tstb
	beq	LEA40
	ldab	#$80
	orab	X0789
	stab	X0789
LEA40:
	ldaa	#$01
	staa	flagHPIBByteInIntr
	ldaa	#$40
	anda	x01CA
	tsta
	beq	LEA5E
	clr	flagHPIBByteInIntr
	ldaa	#$C0
	anda	x01CA
	cmpa	#$C0
	bne	LEA5E
	ldaa	#$01
	staa	flagMeasFormatted
LEA5E:
	ldaa	#$08
	anda	flagCmdParse
	staa	tempCmdParseFlag
	ldx	#$F861
	stx	X079F
	ldaa	#$01
	staa	IGCmdRegisterNumber
	ldab	#$3F
	stab	IGCmdRegBitClearMask
	jsr	subAdjustIGCmdRegister
	; table lookup F861
	; CmdTableIndex		0	1	2	3	4	5	6	7	8	9
	; IGCmdReg OR bits   	EE 	00	40 	80 	C0 	EE	EE 	EE 	EE 	EE

	ldaa	#$80
	anda	flagCmdParse
	tsta
	bne	LEA95
	ldaa	#$40
	oraa	tempCmdParseFlag
	staa	flagCmdParse	; set bit6
	ldaa	X012A
	staa	X018F
	ldaa	X012B
	staa	X018E
LEA95:
	rts
;
;----Switch LEAD0  case 11 -----

LEA98:
	ldaa	#$31	; ASCII "1"
	cmpa	CmdChar
	bne	LEAB4
	ldx	#$F87F
	stx	X079F
	ldab	#$02
	stab	IGCmdRegisterNumber
	ldaa	#$DF
	staa	IGCmdRegBitClearMask
	jsr	subAdjustIGCmdRegister
	; table lookup F87F
	; CmdTableIndex		0	1	2	3	4	5	6	7	8	9
	; IGCmdReg OR bits   	00	20	EE	EE	EE	EE	EE	EE	EE	EE

	rts
;
LEAB4:
	jsr	subResetCmdFlags
	rts
;
;----Switch LEAD0  case 12 -----

LEABA:
	ldx	#$F893
	stx	X079F
	ldaa	#$01
	staa	IGCmdRegisterNumber
	ldab	#$EF
	stab	IGCmdRegBitClearMask
	jsr	subAdjustIGCmdRegister
	; table lookup F893
	; CmdTableIndex		0	1	2	3	4	5	6	7	8	9
	; IGCmdReg OR bits   	00 	10 	EE 	EE	EE	EE	EE	EE   	EE	EE

	rts
;
;---- end Switch LEAD0 -------------

;----Switch LEBC6 ---------------------
LEBC6:
	ldaa	#$02
	staa	flag01A1
	ldaa	X01C6
	clrb
	asla
	rolb
	adda	#$F2
	adcb	#$F9
	staa	X0003
	stab	X0002
	ldx	X0002
	ldx	$00,x
	jmp	$00,x
	; index jump
	;	jump index values
;	f9f2
;	LEAED
;	LEAF2
;	LEB05
;	LEB0A
;	LEB1D
;	LEB22
;	LEB27
;	LEB2C
;	LEB31
;	LEB66
;	LEBA9
;	LEBBC
;	LEBC1

;----Switch LEBC6 case 0 ------------

LEAED:
	jsr	subResetCmdFlags
	rts
;
;----Switch LEBC6 case 1 ------------

LEAF2:
	ldaa	#$4C	; ASCII "L"
	cmpa	CmdChar
	bne	LEB00
	ldab	#$02
	stab	X01C9
	rts
;
LEB00:
	jsr	subResetCmdFlags
	rts
;
;----Switch LEBC6 case 2 ------------

LEB05:
	jsr	subResetCmdFlags
	rts
;
;----Switch LEBC6 case 3 ------------

LEB0A:
	ldaa	#$4C	; ASCII "L"
	cmpa	CmdChar
	bne	LEB18
	ldab	#$05
	stab	X01C9
	rts
;
LEB18:
	jsr	subResetCmdFlags
	rts
;
;----Switch LEBC6 case 4 ------------

LEB1D:
	jsr	subResetCmdFlags
	rts
;
;----Switch LEBC6 case 5 ------------

LEB22:
	jsr	subResetCmdFlags
	rts
;
;----Switch LEBC6 case 6 ------------

LEB27:
	jsr	subResetCmdFlags
	rts
;
;----Switch LEBC6 case 7 ------------

LEB2C:
	jsr	subResetCmdFlags
	rts
;
;----Switch LEBC6 case 8 ------------

LEB31:
	ldaa	#$45	; ASCII "E"
	cmpa	CmdChar
	bne	LEB44
	ldab	#$01
	stab	X01C9
	ldaa	#$01
	staa	X0103
	rts
;
LEB44:
	ldaa	#$53	; ASCII "S"
	cmpa	CmdChar
	bne	LEB61
	ldab	#$03
	stab	X01C9
	rts
;
LEB61:
	jsr	subResetCmdFlags
	rts
;
;----Switch LEBC6 case 9 ------------

LEB66:
	ldaa	#$54	; ASCII "T"
	cmpa	CmdChar
	bne	LEB72
	clr	X01C9
	rts
;
LEB72:
	ldaa	#$4F	; ASCII "O"
	cmpa	CmdChar
	bne	LEB80
	ldab	#$04
	stab	X01C9
	rts
;
LEB80:
	ldaa	#$4D	; ASCII "M"
	cmpa	CmdChar
	bne	LEB96
	ldab	#$10
	orab	flagCmdParse
	stab	flagCmdParse	; set bit4
	ldaa	#$02
	staa	X01C7
	rts
;
LEB96:
	ldaa	#$57	; ASCII "W"
	cmpa	CmdChar
	bne	LEBA4
	ldab	#$07
	stab	X01C9
	rts
;
LEBA4:
	jsr	subResetCmdFlags
	rts
;
;----Switch LEBC6 case 10 ------------

LEBA9:
	ldaa	#$45	; ASCII "E"
	cmpa	CmdChar
	bne	LEBB7
	ldab	#$06
	stab	X01C9
	rts
;
LEBB7:
	jsr	subResetCmdFlags
	rts
;
;----Switch LEBC6 case 11 ------------

LEBBC:
	jsr	subResetCmdFlags
	rts
;
;----Switch LEBC6 case 12 ------------

LEBC1:
	jsr	subResetCmdFlags
	rts
;
;----end Switch LEBC6 ----------------




;----Switch LED10 ---------------------
; get here if CmdChar was 0-9
LED10:
	ldaa	X01C9
	clrb
	asla		; multiply by 2 to index word
	rolb
	adda	#$0C
	adcb	#$FA
	staa	X0003
	stab	X0002
	ldx	X0002
	ldx	$00,x
	jmp	$00,x
	; index jump
	;	jump index values
;	fa0c
;	LEC15
;	LEC1A
;	LEC1F
;	LEC4D
;	LEC97
;	LECAC
;	LECC1
;	LECEB


;----Switch LED10 case 0 ------------

LEC15:
	jsr	subResetCmdFlags
	rts
;
;----Switch LED10 case 1 ------------

LEC1A:
	jsr	subResetCmdFlags
	rts
;
;----Switch LED10 case 2 ------------

LEC1F:
	ldaa	CmdTableIndex
	cmpa	#$01
	bne	LEC48
	jsr	sub026
	clr	AnDUpdatedFlag
	jsr	subAnnuncNDisplayUpdate
	ldaa	#$01
	staa	AnDUpdatedFlag
	clr	flagCmdParse
	clr	flag01A1
	clr	flagMeasArrayUnpacked
	clr	flag01ED
	clr	flagX01FB
	jmp	LD421
;
LEC48:
	jsr	subResetCmdFlags
	rts
;
;----Switch LED10 case 3 ------------

LEC4D:
	ldx	#$F889
	stx	X079F
	ldaa	#$04
	staa	IGCmdRegisterNumber
	ldab	#$F7
	stab	IGCmdRegBitClearMask
	jsr	subAdjustIGCmdRegister
		; table lookup F889
	; CmdTableIndex		0	1	2	3	4	5	6	7	8	9
	; IGCmdReg OR bits   	00	08	EE	EE	EE	EE	EE	EE	EE	EE

	ldaa	#$EE
	cmpa	CmdChar
	beq	LEC95
	ldab	#$08
	andb	IGCmdRegister4
	tstb
	beq	LEC8D	; branch if bit3 = 0
	bra	LEC79

LEC79:
	ldab	X0200
	orab	#$01
	stab	X0200	; set bit0
	rts
;
LEC8D:
	ldaa	#$F0
	anda	X0200
	staa	X0200	; clear bits0-3
LEC95:
	rts
;
;----Switch LED10 case 4 ------------

LEC97:
	ldx	#$F875
	stx	X079F
	ldaa	#$04
	staa	IGCmdRegisterNumber
	ldab	#$FB
	stab	IGCmdRegBitClearMask
	jsr	subAdjustIGCmdRegister
	; table lookup F875
	; CmdTableIndex		0	1	2	3	4	5	6	7	8	9
	; IGCmdReg OR bits   	00	04	EE	EE	EE	EE	EE	EE	EE	EE

	rts
;
;----Switch LED10 case 5 ------------

LECAC:
	ldx	#$F889
	stx	X079F
	ldaa	#$01
	staa	IGCmdRegisterNumber
	ldab	#$F7
	stab	IGCmdRegBitClearMask
	jsr	subAdjustIGCmdRegister
	; table lookup F889
	; CmdTableIndex		0	1	2	3	4	5	6	7	8	9
	; IGCmdReg OR bits   	00	08	EE	EE	EE	EE	EE	EE	EE	EE

	rts
;
;----Switch LED10 case 6 ------------

LECC1:
	ldaa	CmdTableIndex
	cmpa	#$01
	bne	LECDD
	ldab	#$01
	stab	flagTestMode
	ldaa	#$40
	oraa	flagCmdParse
	staa	flagCmdParse	; set bit6
	clr	flag01A1
	clr	flag01ED
	rts
;
LECDD:
	ldaa	CmdTableIndex
	tsta
	bne	LECE6
	jmp	LD971		; jumps into subRST
;
LECE6:
	jsr	subResetCmdFlags
	rts
;
;----Switch LED10 case 7 ------------

LECEB:
	ldaa	CmdTableIndex
	cmpa	#$01
	bne	LED0D
	ldab	#$80
	orab	IGCmdRegister4
	stab	IGCmdRegister4	; set bit7
	clr	flag01A1
	ldaa	#$F7
	anda	flagCmdParse
	staa	flagCmdParse	; clear bit3
	ldaa	#$40
	oraa	flagCmdParse
	staa	flagCmdParse	; set bit6
LED0D:
	rts
;
;----end Switch LED10 -----------------


LD421:
	lds	StackStart
	ldaa	#$3F
	anda	flagHPIBOutput
	staa	flagHPIBOutput	; clear bit6-7
	ldaa	#$EF
	anda	flagX0121
	staa	flagX0121	; clear bit4
	clr	flagInguardTimeout
	ldaa	#$0F
	anda	X0200
	staa	X0200
	ldaa	#$08
	anda	flagCmdParse	; check bit3
	tsta
	bne	LD44E
	ldaa	#$01
	staa	flag010B
	bra	LD451
;
LD44E:
	clr	flag010B
LD451:
	cli			; enable keyboard interrupts
	ldaa	flagHPIBByteInIntr
	rora
	bcc	LD465
	ldaa	#$A4		; 10100100b
	staa	HPIBIntrMask
	ldaa	HPIBIntrMask
	staa	ioHPIB_r0	; turn on HPIB interrupts except Byte Input
	bra	LD470
;
LD465:
	ldaa	#$A5		; 10100101b
	staa	HPIBIntrMask
	ldaa	HPIBIntrMask
	staa	ioHPIB_r0	; turn on HPIB interrupts including Byte Input
LD470:
	jsr	sub073
	ldaa	#$20
	anda	IGCmdRegister2
	tsta
	beq	LD47E		; branch if bit5 = 0
	jmp	LED39		; jump into sub116
;
LD47E:
	ldaa	flagTestMode
	tsta
	beq	LD4AB
	clr	flag010B
	clr	flagX01FB
	ldaa	#$FE
	anda	flagX0121
	staa	flagX0121	; clear bit0
	ldaa	#$03
	cmpa	flagTestMode
	bne	LD49E
	jsr	sub098
	bra	LD4AB
;
LD49E:
	ldaa	#$03
	oraa	IGCmdRegister4	; set bit0,1	6 digit display?
	anda	#$F7
	staa	IGCmdRegister4	; clear bit3
	jsr	sub103
LD4AB:
	ldaa	#$07
	anda	IGCmdRegister1
	staa	flagNumPLCcode
	ldaa	#$08
	anda	flagCmdParse	; check bit3
	tsta
	bne	LD4BE
	jsr	sub066
LD4BE:
	ldaa	X010C
	oraa	flagOverrange_Maybe
	staa	flagOverrange_Maybe
LD4C7:
	jsr	sub077
	clr	flagMeasFormatted
	ldaa	#$FB
	staa	HPIBSerialPollMask
	jsr	subUpdateHPIBSerialPoll
	ldaa	#$A5
	staa	HPIBIntrMask
	ldaa	HPIBIntrMask
	staa	ioHPIB_r0	; turn on interrupts from HPIB
	jsr	sub087
	clr	flag010B
	jsr	sub090
	ldaa	X0789
	anda	#$01
	rora
	bcc	LD4FC
	ldaa	#$10
	anda	flagX0121
	tsta
	bne	LD4FC
	jmp	LED5D
LD4FC:
	bra	LD4C7

LED39:
	ldaa	X0789
	tsta
	bne	LED5D
	ldx	#$0000
	stx	X01FE
	ldaa	#$9F
	anda	IGCmdRegister2
	staa	IGCmdRegister2
	ldaa	X0789
	oraa	#$01
	staa	X0789
	ldaa	#$FD
	staa	HPIBSerialPollMask
	jsr	subUpdateHPIBSerialPoll
LED5D:
	ldx	X0205
	cpx	X01FE
	bne	LED79
	clr	X0789
	ldaa	#$02
	staa	HPIBSerialPollStatus
	jsr	subHPIBRequestService
	clr	flag01A1
	clr	flag01ED
	jmp	LD421
;
LED79:
	ldaa	#$10
	staa	ioHPIB_r0	; turn off interrupts from HPIB
	ldaa	#$07
	ldab	#$02
	adda	X01FF
	adcb	X01FE
	staa	x0045
	stab	x0044
	ldx	x0044
	ldaa	$00,x
	staa	CmdChar
	ldx	X01FE
	inx
	stx	X01FE
	ldaa	#$20	; ASCII " "
	cmpa	CmdChar
	bne	LEDA3
	bra	LEDA6
;
LEDA3:
	jsr	sub116
LEDA6:
	ldaa	#$A5
	staa	ioHPIB_r0	; turn on interrupts from HPIB
	ldaa	#$80
	anda	flagCmdParse	; test bit7
	tsta
	beq	LEDC4
	ldaa	#$12
	staa	HPIBSerialPollStatus
	jsr	subHPIBRequestService
	clr	flagCmdParse
	clr	X0789
	jmp	LD421
;
LEDC4:
	ldaa	#$60
	anda	IGCmdRegister2
	oraa	flagTestMode
	tsta
	beq	LEDE0
	jsr	sub115
	ldaa	#$8F
	anda	IGCmdRegister2
	staa	IGCmdRegister2
	clr	flagTestMode
	jmp	LD421
;
LEDE0:
	jsr	sub081
	ldaa	#$04
	anda	flagCmdParse	; test bit6
	tsta
	beq	LEDF3
	clr	flag01A1
	ldaa	#$08
	staa	flagCmdParse	; set bit3, clear others
LEDF3:
	ldaa	#$80
	anda	X0789
	tsta
	beq	LEE08
	ldaa	#$7F
	anda	X0789
	staa	X0789
	jmp	LD421
LEE08:
	jmp	LED5D

;===============================================================================
; Non Maskable Interrupt handler, called when something arrives on HPIB
;
subNMI:
	jsr	subSaveX0000_3
	ldaa	#$10
	staa	ioHPIB_r0	; turn off interrupts from HPIB
	ldaa	#$20
	anda	ioHPIB_r0
	tsta
	beq	LEE36
	ldaa	#$01
	staa	flagHPIBByteInIntr
	ldaa	#$10
	staa	ioHPIB_r3	; release DAC handshake
	ldaa	X012A
	staa	X018F
	ldaa	X012B
	staa	X018E
	jmp	LD421		; jumps into sub103
;
LEEA8:
	jmp	LEFFD
LEEC6:
	jmp	LEF0C
LEE36:
	ldaa	ioHPIB_r0
	anda	#$01
	tsta
	beq	LEEA8
	ldaa	#$7F		; mask for lower 7 bits
	anda	ioHPIB_r7	; gets byte from HPIB
	staa	CmdChar
	ldaa	#$40
	anda	ioHPIB_r1	; bit6 set if meter in HPIB Remote mode
	tsta
	beq	LEEA8
	ldaa	IGCmdRegister2
	anda	#$40
	tsta
	beq	LEEC6
	ldaa	#$04
	anda	X0789
	tsta
	beq	LEE7F
	ldaa	#$02
	staa	X0789
	ldx	#$0000
	stx	X01FE
	ldaa	#$F7
	anda	IGCmdRegister4
	staa	IGCmdRegister4	; clear bit3
	clr	X0200
	ldx	#$0000
	stx	X0203
LEE7F:
	ldaa	#$51	; ASCII "Q"
	cmpa	CmdChar
	bne	LEED5
	ldab	#$BF
	andb	IGCmdRegister2
	stab	IGCmdRegister2
	clr	X0789
	ldx	X01FE
	stx	X0205
LEE97:
	ldaa	#$03
	clrb
	anda	X0206
	andb	X0205
	staa	X0002
	orab	X0002
	beq	LEED2
	ldaa	#$07
	ldab	#$02
	adda	X0206
	adcb	X0205
	staa	x0009
	stab	x0008
	ldaa	#$20	; ASCII " "
	ldx	x0008
	staa	$00,x
	ldx	X0205
	inx
	stx	X0205
	bra	LEE97
LEED2:
	jmp	LD421		; jumps into sub103
;
LEED5:
	ldaa	#$77
	ldab	#$05
	suba	X01FF
	sbcb	X01FE
	bcc	LEEEE
	jsr	sub115
	ldaa	#$BF
	anda	IGCmdRegister2
	staa	IGCmdRegister2
	jmp	LEFFD
;
LEEEE:
	ldaa	#$07
	ldab	#$02
	adda	X01FF
	adcb	X01FE
	staa	x0005
	stab	x0004
	ldaa	CmdChar
	ldx	x0004
	staa	$00,x
	ldx	X01FE
	inx
	stx	X01FE
	jmp	LEFFD
;
LEF0C:
	ldaa	#$0D	; ASCII [cr]
	clrb
	cmpa	CmdChar
	bne	LEF15
	decb
LEF15:
	ldaa	#$0A	; ASCII [lf]
	stab	x0004
	clrb
	cmpa	CmdChar
	bne	LEF20
	decb
LEF20:
	orab	x0004
	ldaa	#$20	; ASCII " "
	stab	x0008
	clrb
	cmpa	CmdChar
	bne	LEF2D
	decb
LEF2D:
	orab	x0008
	ldaa	CmdChar
	stab	x000C
	clrb
	cmpa	#$61	; ASCII "a"
	bcs	LEF3A
	decb
LEF3A:
	stab	x000E
	clrb
	cmpa	#$65	; ASCII "e"
	bcc	LEF42
	decb
LEF42:
	andb	x000E
	orab	x000C
	stab	x0014
	clrb
	cmpa	#$66	; ASCII "f"
	bcs	LEF4E
	decb
LEF4E:
	stab	X0016
	clrb
	cmpa	#$7A	; ASCII "q"
	bhi	LEF56
	decb
LEF56:
	andb	X0016
	orab	x0014
	rorb
	bcc	LEF69
	ldab	HPIBIntrMask
	pshb
	clra
	psha
	ldaa	#$01
	psha
	jsr	sub148
LEF69:
	ldaa	#$40
	anda	flagHPIBOutput	; keep bit6
	ldab	X0789
	andb	#$01
	staa	x0004
	orab	x0004
	tstb
	beq	LEF9E
	ldab	#$BF
	andb	flagHPIBOutput
	stab	flagHPIBOutput	; clear bit6
	clr	flag01A1
	clr	flag01ED
	ldaa	#$08
	staa	flagCmdParse	; set bit3, clear others
	clr	flagX01FB
	ldaa	X0789
	rora
	bcc	LEF9E
	jsr	sub115
LEF9E:
	jsr	sub116
	ldaa	#$80
	anda	flagCmdParse	; set bit7, clear others
	tsta
	beq	LEFB9
	clr	flagCmdParse
	ldaa	#$10
	staa	HPIBSerialPollStatus
	jsr	subHPIBRequestService
	jmp	LD421		; jumps into sub103
;
LEFB9:
	ldaa	#$40
	anda	flagCmdParse	; test bit6
	tsta
	beq	LEFDF
	ldaa	#$04
	anda	flagCmdParse	; test bit2
	tsta
	beq	LEFD4
	ldaa	#$08
	staa	flagCmdParse	; set bit3, clear others
	clr	flag01A1
	jmp	LC9D2
;
LEFD4:
	ldaa	#$08
	anda	flagCmdParse
	staa	flagCmdParse	; keep bit3, clear others
	jmp	LD421		; jumps into sub103
;
LEFDF:
	ldaa	flagCmdParse	; test bit0
	anda	#$01
	tsta
	beq	LEFFA
	jsr	subSetAnnuncBytes123
	clr	AnDUpdatedFlag
	jsr	subAnnuncNDisplayUpdate
	ldaa	#$01
	staa	AnDUpdatedFlag
LEFFA:
	jmp	LC9D2
;
LEFFD:
	ldaa	#$02
	anda	ioHPIB_r1	; checking if device clear function is activated
	tsta
	beq	LF00D
	ldaa	#$10
	staa	ioHPIB_r3	; if so, release DAC handshake
	jmp	LD971		; jumps into subRST
;
LF00D:
	ldaa	#$81
	anda	ioHPIB_r1	; checking if undefined HPIB command received
	tsta
	beq	LF01A
	ldaa	#$10
	staa	ioHPIB_r3	; if so, release DAC handshake
LF01A:
	ldaa	HPIBIntrMask
	psha
	clrb
	pshb
	ldaa	#$01
	psha
	jsr	sub148
	jsr	subRestoreX0000_3	; subRestoreX0000_3 ends with rti

;===============================================================================
; Called as the keyboard interrupt handler
;
; Keyboard
;
; When a key is pressed the keypad encoder IC (MM74C923?) issues a IRQ request to the 6800.
; The 6800 outputs a Keyboard Strobe, causing the encoder to latch the key code onto the data bus.
; Key data is placed in bits D0-5.  D6 high indicates the display is ready to write to.
; Once the key is read, the Keyboard Clear strobe resets the IRQ line.
;
; The data value (lower 6 bits) stored in PressedKeyCode is:
;	0x00	AUTO ZERO
;	0x01	AC+DCV
;	0x02	ACV
;	0x03	DCV
;	0x04	SHIFT
;	0x05	4WR
;	0x06	2WR
;	0x07	AUTO RANGE
;	0x08	UP
;	0x09	DOWN
;	0x0A	INT
;	0x0B	EXT
;	0x0C	SINGLE
;	0x0D	HOLD
;	0x0E	RDGS_STORE
;	0x0F	TEST
;	0x10	LOCAL
;	0x11	SRQ
;	0x12	RESET
;	0x20	ENTER_EXP
;	0x21	STORE
;	0x22	RECALL
;	0x23	MATH
;	0x24	CHS
;	0x25	DOT
;	0x26	0
;	0x27	3
;	0x28	2
;	0x29	1
;	0x2A	6
;	0x2B	5
;	0x2C	4
;	0x2D	9
;	0x2E	8
;	0x2F	7
;	0x30	FILTER
;	0x31	CLEAR_CONT

subIRQ:
	jsr	subSaveX0000_3		; puts X000-3 onto stack
	ldaa	#$3F		; key code is lower 6 bits of byte
	anda	ioKBrdStrb	; put keyboard encoder data on bus
	staa	PressedKeyCode	; key code of pressed key
	clr	ioKBrdClr	; clears the keyboard IRQ
	ldaa	#$40
	anda	ioHPIB_r1	; bit 6 set if unit is in Remote control mode
	tsta
	bne	LF0AC		; branch unit in Remote mode
	ldaa	#$10
	staa	ioHPIB_r0	; turn off interrupts from HPIB
	ldaa	#$40
	oraa	flagHPIBOutput
	staa	flagHPIBOutput	; set bit6
	ldaa	flagCmdParse
	anda	#$01
	tsta
	bne	LF064		; branch if flagCmdParse bit0 = 1
	ldaa	flagCmdParse
	staa	tempCmdParseFlag	; save current state
	ldaa	#$F7
	anda	flagCmdParse	; clear bit 3 of flagCmdParse
	staa	flagCmdParse
LF064:
	ldaa	flagCmdParse
	anda	#$01
	tsta
	beq	LF0D4		; branch if flagCmdParse bit0 = 0
	ldaa	#$25		; key code for "DOT"
	clrb
	cmpa	PressedKeyCode
	bne	LF075		; branch if key not "DOT"
	decb
LF075:				; B = FF if key = "DOT", else 00
	ldaa	#$40
	anda	flagX01FB	; A = flagX01FB bit6
	stab	X0028
	clrb
	tsta
	bne	LF081
	decb
LF081:				; B = FF if flagX01FB bit6 = 0, else 00
	andb	X0028
	tstb
	beq	LF095		; branch if key != "DOT" or flagX01FB bit6 = 1
	ldaa	#$2E		; ASCII "."
	staa	CmdChar		; CmdChar = 2E
	jsr	sub116
LF0D4:
	jmp	LF15C
;
LF0AC:
	jmp	LF607
;
LF095:			; entering exponent
	ldaa	PressedKeyCode
	clrb
	cmpa	#$20		; key code for "ENTER_EXP"
	bne	LF09E		; branch if key != "ENTER_EXP"
	decb
LF09E:				; B = FF if key = "ENTER_EXP", else 00
	ldaa	#$40
	anda	flagX01FB
	stab	X0024
	clrb
	tsta
	bne	LF0AA
	decb
LF0AA:				; B = FF if flagX01FB bit6 = 0, else 00
	andb	X0024
	tstb
	beq	LF0C6		; branch if key != "ENTER_EXP" or flagX01FB bit6 = 1
	ldaa	#$40
	oraa	flagX01FB
	staa	flagX01FB	; set flagX01FB bit6
	ldaa	#$45		; ASCII "E"
	staa	CmdChar
	jsr	sub116
	jmp	LF15C
;
LF0C6:			; changing sign, value or exponent
	ldaa	#$24		; key code for "CHS"
	cmpa	PressedKeyCode
	bne	LF115		; branch if key != "CHS"
	ldab	#$40
	andb	flagX01FB
	tstb
	bne	LF0F5		; branch if flagX01FB bit6 = 1 -- to exponent sign?
	ldab	#$2B		; ASCII "+"
	cmpb	MeasPolaritySign
	bne	LF0EB		; branch if polarity != "+"
	ldaa	#$2D		; ASCII "-"
	staa	CmdChar
	jsr	sub116
	jmp	LF15C
;
LF0EB:
	ldaa	#$2B		; ASCII "+"
	staa	CmdChar
	jsr	sub116
	jmp	LF15C
;
LF0F5:
	ldaa	#$2B		; ASCII "+"
	cmpa	MeasExponentSign
	bne	LF10B
	ldab	#$2D		; ASCII "-"
	stab	CmdChar
	jsr	sub116
	jmp	LF15C
;
LF10B:
	ldaa	#$2B	; ASCII "+"
	staa	CmdChar
	jsr	sub116
	bra	LF15C
;
LF115:
	ldaa	PressedKeyCode
	clrb
	cmpa	#$25		; key code for "DOT"
	bls	LF11E
	decb
LF11E:				; B = FF if key code > 25, else 00
	stab	X0024
	clrb
	cmpa	#$30		; C = 1 if key code < 30
	bcc	LF126
	decb
LF126:				; B = FF if key code < 30, else 00
	andb	X0024
	tstb
	beq	LF14E		; branch if if key code >= 30 or =< 25, i.e., not a number
	suba	#$24		; PressedKeyCode - 24
	staa	CmdChar
	ldaa	#$EB
	ldab	#$F8
	adda	CmdChar
	adcb	#$00
	staa	X0025
	stab	X0024
	ldx	X0024
	ldaa	$00,x
	; table F8EB, looks like ASCII values of keypad buttons
	; index		0	1	2	3	4	5	6	7	8	9	10	11
	; value		2D	45	30	33	32	31	36	35	34	39	38	37

	staa	CmdChar
	jsr	sub116
	bra	LF15C
;
LF14E:				; key was not a number
	clr	flag01A1
	clr	flag01ED
	ldaa	#$FE
	anda	flagCmdParse
	staa	flagCmdParse	; clear bit0
LF15C:
	ldaa	flagCmdParse
	anda	#$01
	tsta
	bne	LF1CC		; branch if flagCmdParse bit0 = 1
	ldaa	#$03
	anda	flagX01FB
	clrb
	tsta
	bne	LF16E		; branch if flagX01FB bit0,1 != 0,0
	decb
LF16E:				; B = FF if flagX01FB bit0,1 = 0,0, else 00
	ldaa	#$12		; key code for "RESET"
	stab	X002A
	clrb
	cmpa	PressedKeyCode
	bne	LF179
	decb
LF179:				; B = FF if PressedKeyCode = "RESET", else 00
	orab	X002A
	tstb
	beq	LF1E4		; branch if flagX01FB bit0,1 != 0,0 and PressedKeyCode != "RESET"
	ldab	PressedKeyCode
	clra
	tstb
	beq	LF186		; branch if PressedKeyCode = 00, "AUTO ZERO"
	deca
LF186:				; B = FF if PressedKeyCode != "AUTO ZERO", else 00
	staa	X0032
	clra
	cmpb	#$07		; key code for "AUTO RANGE"; C = 1 if PressedKeyCode < 07
	bcc	LF18E		; branch if PressedKeyCode >= 07
	deca
LF18E:				; A = FF if PressedKeyCode < 07
	anda	X0032
	tsta
	beq	LF1E7		; branch if key = "AUTO ZERO" or is >= 07, i.e., not a meter mode key
	cmpb	#$04		; key code for "SHIFT"
	bne	LF1B5		; branch if not "SHIFT" key
	inc	flagX01FC
	ldaa	flagX01FC
	anda	#$01
	staa	CmdTableIndex		; bit0 of flagX01FC, = 0,1
	ldx	#$F893
	stx	X079F
	clr	IGCmdRegisterNumber
	ldaa	#$EF
	staa	IGCmdRegBitClearMask
	jsr	subAdjustIGCmdRegister
	; table lookup F893
	; CmdTableIndex		0	1	2	3	4	5	6	7	8	9
	; IGCmdReg OR bits   	00 	10 	EE 	EE	EE	EE	EE	EE   	EE	EE
	jmp	LF5D5
LF1CC:
	jmp	LF607
LF1E4:
	jmp	LF53F
;
LF1B5:
	ldaa	#$07		; lower 3 bits
	anda	PressedKeyCode
	clrb
	adda	#$22
	adcb	#$FA
	staa	X0027
	stab	X0026
	ldx	X0026
	ldaa	$00,x
	; table lookup FA22
	; key code bits2-0	0	1	2	3	4	5	6	7
	; table value		09  	03 	02 	01 	09   	05 	04 	F2
	staa	CmdTableIndex
	ldx	#$F84D
	stx	X079F
	clr	IGCmdRegisterNumber
	ldaa	#$1F
	staa	IGCmdRegBitClearMask
	jsr	subAdjustIGCmdRegister
	; table lookup F84D
	; CmdTableIndex		0	1	2	3	4	5	6	7	8	9
	; IGCmdReg OR bits   	EE	60	40	20	C0	A0	EE	EE	EE	EE

	jmp	LF5D5
;
; ---- deal with range keys
;
LF1E7:
	ldaa	PressedKeyCode
	clrb
	cmpa	#$06		; key code for "2WR"
	bls	LF1F0
	decb
LF1F0:				; B = FF if key > 06, else 00
	stab	X0024
	clrb
	cmpa	#$0A		; key code for "INT"
	bcc	LF1F8		; branch if key code >= 0A
	decb
LF1F8:				; B = FF if key < 0A, else 00
	andb	X0024
	tstb
	beq	LF262		; branch if key <= 06 or >= 0A i.e., not a range key
	clrb
	cmpa	#$07		; key code for "AUTO RANGE"
	bne	LF203
	decb
LF203:				; B = FF if key = "AUTO RANGE", else 00
	ldaa	IGCmdRegister0
	anda	#$01
	stab	X002C		; bit0
	clrb
	tsta
	bne	LF20F
	decb
LF20F:				; B = FF if IGCmdRegister0 bit0 = 0, else 00
	andb	X002C
	tstb
	beq	LF21E		; branch if key != "AUTO RANGE" or IGCmdRegister0 bit0 = 1
	ldaa	IGCmdRegister0
	oraa	#$01
	staa	IGCmdRegister0	; set bit0, bit0 must mean autorange
	jmp	LF5D5
LF262:
	jmp	LF29D
;
LF21E:
	ldaa	#$07		; key code for "AUTO RANGE"
	clrb
	cmpa	PressedKeyCode
	bne	LF227
	decb
LF227:				; B = FF if key = "AUTO RANGE", else 00
	ldaa	IGCmdRegister0
	anda	#$01
	stab	X0024
	anda	X0024
	tsta
	beq	LF23D		; branch if key != "AUTO RANGE" or IGCmdRegister0 bit0 = 1
	ldaa	#$FE
	anda	IGCmdRegister0
	staa	IGCmdRegister0	; clear bit0
	jmp	LF5D5
;
LF23D:
	ldaa	#$FE
	anda	IGCmdRegister0
	staa	IGCmdRegister0	; clear bit0
	ldaa	#$08		; key code for "UP"
	clrb
	cmpa	PressedKeyCode
	bne	LF253
	decb
LF253:				; B = FF if key = "UP", else 00
	ldaa	#$0E
	anda	IGCmdRegister0
	stab	X0024
	clrb
	cmpa	#$0E
	bcc	LF260
	decb
LF260:				; B = FF if IGCmdRegister0 bits3-1 != 111, else 00
	andb	X0024
	tstb
	beq	LF274		; branch if key != "UP" or IGCmdRegister0 bits3-1 = 111
	ldaa	#$02
	adda	IGCmdRegister0
	staa	IGCmdRegister0	; clear all but bit1
	jmp	LF5D5
;
LF274:
	ldaa	#$09		; key code for "DOWN"
	clrb
	cmpa	PressedKeyCode
	bne	LF27D
	decb
LF27D:				; B = FF if key = "DOWN", else 00
	ldaa	#$0E
	anda	IGCmdRegister0
	stab	X0024
	clrb
	tsta
	beq	LF28E
	decb
LF28E:				; B = FF if IGCmdRegister0 bits3-1 != 000, else 00
	andb	X0024
	tstb
	beq	LF29B		; branch if key != "DOWN" or IGCmdRegister0 bits3-1 = 000
	ldaa	IGCmdRegister0
	suba	#$02
	staa	IGCmdRegister0	; decrement IGCmdRegister0 bits3-1 (must be range number?)
LF29B:
	jmp	LF5D5
;
; ---- deal with trigger keys
;
LF29D:
	ldaa	PressedKeyCode
	clrb
	cmpa	#$09		; key code for "DOWN"
	bls	LF2A6
	decb
LF2A6:				; B = FF if key > 09, else 00
	stab	X0024
	clrb
	cmpa	#$0E		; key code for "RDGS_STORE"
	bcc	LF2AE
	decb
LF2AE:				; B = FF if key < 0E, else 00
	andb	X0024
	tstb
	beq	LF2CE		; branch if key <= 09 or >= 0E, i.e., branch if not trigger key
	ldab	tempCmdParseFlag
	stab	flagCmdParse	; restore to earlier value
	ldaa	#$54		; ASCII "T"
	staa	CmdChar
	jsr	sub116
	ldaa	#$27
	adda	PressedKeyCode	; 27 + A,B,C or D
	staa	CmdChar		; "1", "2", "3" or "4"
	jsr	sub116
	jmp	LF5D5
;
; handle RDGS_STORE, TEST, LOCAL, SRQ, RESET
;
LF349:
	jmp	LF371
LF2CE:
	ldaa	PressedKeyCode
	clrb
	cmpa	#$0D
	bls	LF2D7
	decb
LF2D7:				; B = FF if key > 0D, else 00
	stab	X0024
	clrb
	cmpa	#$13
	bcc	LF2DF
	decb
LF2DF:				; B = FF if key < 13, else 00
	andb	X0024
	tstb
	beq	LF349		; branch if key <= 0D or >= 13
	suba	#$0E		; leaves values 0,1,2,3,4
	clrb

;----- Switch LF35F -------------------------
LF35F:
	asla
	rolb
	adda	#$29
	adcb	#$FA
	staa	X0003
	stab	X0002
	ldx	X0002
	ldx	$00,x
	jmp	$00,x
	; index jump
	;	jump index values
;	fa29
;	LF2E9
;	LF31A
;	LF36F
;	LF32A
;	LF35C

;
;----- Switch LF35F case 0 -------------------
; key = 0E, "RDGS_STORE"
LF2E9:
	ldaa	#$08
	anda	IGCmdRegister4
	tsta
	beq	LF308		; branch if bit3 = 0
	ldaa	#$F7
	anda	IGCmdRegister4
	staa	IGCmdRegister4	; clear bit3
	ldaa	#$F0
	anda	X0200
	staa	X0200		; clear bits3-0
	jmp	LF5D5
;
LF308:
	ldaa	#$08
	oraa	IGCmdRegister4
	staa	IGCmdRegister4	; set bit3
	ldaa	X0200
	oraa	#$01
	staa	X0200		; set bit0
	jmp	LF5D5
;
;----- Switch LF35F case 1 -------------------
; key = 0F, "TEST"
LF31A:
	ldaa	flagTestMode
	tsta
	beq	LF323
	jmp	LD971		; jumps into subRST
;
LF323:
	ldaa	#$01
	staa	flagTestMode
	jmp	LF5D5
;
;----- Switch LF35F case 2 -------------------
; key = 10, "LOCAL"
LF36F:
	jmp	LF5D5
;
;----- Switch LF35F case 3 -------------------
; key = 11, "SRQ"
LF32A:
	ldaa	#$41
	anda	ioHPIB_r5
	cmpa	#$41
	bne	LF342		; branch if bits2,0 != 0,0
	ldaa	#$FE
	staa	HPIBSerialPollMask
	jsr	subUpdateHPIBSerialPoll
	bra	LF354
;
LF342:
	ldaa	#$01
	staa	HPIBSerialPollStatus
	bra	LF34C
;
LF34C:
	jsr	subHPIBRequestService	; send service request out on HPIB
LF354:
	ldaa	tempCmdParseFlag
	staa	flagCmdParse	; restore this flag
	jmp	LF5D5

;----- Switch LF35F case 4 -------------------
; key = 12, "RESET"
LF35C:
	jmp	LD93C
;
;----- end Switch LF35F ------------------------------

;
; handle "AUTO ZERO"
;
LF371:
	ldaa	PressedKeyCode
	tsta			; key code for 00, "AUTO ZERO"
	bne	LF393
	ldab	#$10
	andb	IGCmdRegister1
	tstb
	beq	LF389		; branch if IGCmdRegister1 bit4 = 0
	ldab	#$EF
	andb	IGCmdRegister1
	stab	IGCmdRegister1	; clear bit4
	jmp	LF5D5
;
LF389:
	ldaa	#$10
	oraa	IGCmdRegister1
	staa	IGCmdRegister1	; set bit4
	jmp	LF5D5
;
; handle "FILTER"
;
LF393:
	ldaa	#$30		; key code for "FILTER"
	cmpa	PressedKeyCode
	bne	LF3B6
	ldab	#$08
	andb	IGCmdRegister1
	tstb			; check bit3
	beq	LF3AC
	ldab	#$F7
	andb	IGCmdRegister1
	stab	IGCmdRegister1	; clear bit3
	jmp	LF5D5
;
LF3AC:
	ldaa	#$08
	oraa	IGCmdRegister1
	staa	IGCmdRegister1	; set bit3
	jmp	LF5D5
;
; handle "CLEAR_CONT"
;
LF3B6:
	ldaa	#$31		; key code for "CLEAR_CONT"
	cmpa	PressedKeyCode
	bne	LF3DC
	ldab	#$43	; ASCII "C"
	stab	CmdChar
	jsr	sub116
	ldaa	#$4C	; ASCII "L"
	staa	CmdChar
	jsr	sub116
	ldaa	#$31	; ASCII "1"
	staa	CmdChar
	jsr	sub116
	jmp	LF5D5
;
; handle "ENTER_EXP"
;
LF3DC:
	ldaa	PressedKeyCode
	clrb
	cmpa	#$20		; key code for "ENTER_EXP"
	bne	LF3E5
	decb
LF3E5:				; B = FF if key = "ENTER_EXP", else 00
	stab	X0024
	clrb
	cmpa	#$24		; key code for "CHS", 1st keypad key
	bcs	LF3ED
	decb
LF3ED:				; B = FF if key <= 24, else 00
	stab	X0026
	clrb
	cmpa	#$2F		; key code for "7", last keypad key
	bhi	LF3F5
	decb
LF3F5:				; B = FF if key <= 2F, else 00
	andb	X0026
	orab	X0024
	ldaa	#$03
	anda	flagX01FB
	stab	X002C
	clrb
	tsta
	bne	LF40A
	decb
LF40A:
	andb	X002C
	tstb
	beq	LF480
	clr	flagX01FB
	ldaa	PressedKeyCode
	cmpa	#$20		; key code for "ENTER_EXP"
	bne	LF430
	ldab	#$40
	orab	flagX01FB
	stab	flagX01FB
	ldaa	#$45	; ASCII "E"
	staa	CmdChar
	jsr	sub116
	jmp	LC9D2
;
LF430:
	ldaa	#$24		; key code for "CHS"
	cmpa	PressedKeyCode
	bne	LF446
	ldab	#$2D	; ASCII "-"
	stab	CmdChar
	jsr	sub116
	jmp	LC9D2
;
LF446:
	ldaa	#$25		; key code for "DOT"
	cmpa	PressedKeyCode
	bne	LF457
	ldab	#$2E	; ASCII "."
	stab	CmdChar
	jsr	sub116
	jmp	LC9D2
;
LF457:
	ldaa	PressedKeyCode
	suba	#$24		; key code for "CHS", result probably 0-11
	staa	CmdChar
	ldaa	#$EB
	ldab	#$F8
	adda	CmdChar
	adcb	#$00
	staa	X0025
	stab	X0024
	ldx	X0024
	ldaa	$00,x
	; table F8EB, looks like ASCII values of keypad buttons
	; index		0	1	2	3	4	5	6	7	8	9	10	11
	; value		2D	45	30	33	32	31	36	35	34	39	38	37

	staa	CmdChar
	jsr	sub116
	jmp	LC9D2
;
LF480:
	ldaa	PressedKeyCode
	clrb
	cmpa	#$21		; key code for "STORE"
	bcs	LF489
	decb
LF489:
	stab	X0024
	clrb
	cmpa	#$24		; key code for "CHS"
	bcc	LF491
	decb
LF491:
	andb	X0024
	tstb
	beq	LF4FD
	suba	#$21
	clrb
	jmp	LF52D
LF4FD:
	jmp	LF5D5
;
;----- Switch LF52D -----------------------------------
LF52D:
	asla
	rolb
	adda	#$33
	adcb	#$FA
	staa	X0003
	stab	X0002
	ldx	X0002
	ldx	$00,x
	jmp	$00,x
	; index jump
	;	jump index values
;	fa33
;	LF49B
;	LF4B8
;	LF510

;----- Switch LF52D case 0 ---------------------
; STORE key
LF49B:
	ldaa	#$53	; ASCII "S"
	staa	CmdChar
	jsr	sub116
	ldaa	#$54	; ASCII "T"
	staa	CmdChar
	jsr	sub116
	ldaa	flagX01FB
	oraa	#$01
	staa	flagX01FB	; turn on bit0
	jmp	LC9D2
;
;----- Switch LF52D case 1 ---------------------
; RECALL key
LF4B8:
	ldaa	#$20	; test bit6
	anda	X0200
	tsta
	beq	LF4D9
	clr	RegisterZ0	; byte 0 of Z register
	ldaa	#$BF
	anda	X0200
	staa	X0200	; clear bit6
	ldaa	#$80
	oraa	X0200
	staa	X0200	; set bit7
	clr	flagX01FB
	jmp	LD6BF
;
LF4D9:
	ldaa	#$52	; ASCII "R"
	staa	CmdChar
	jsr	sub116
	ldaa	#$45	; ASCII "E"
	staa	CmdChar
	jsr	sub116
	ldaa	#$01
	staa	X0103
	ldaa	#$02
	oraa	flagX01FB
	staa	flagX01FB	; set bit1
	jsr	sub026
	jsr	subAnnuncNDisplayUpdate
	jmp	LC9D2
;
;----- Switch LF52D case 2 ---------------------
; MATH key
LF510:
	ldaa	#$4D	;  ASCII "M"
	staa	CmdChar
	jsr	sub116
	ldaa	#$03
	oraa	flagX01FB
	staa	flagX01FB	; set bits0-1
	jsr	sub026
	jmp	LC9D2

;----- end Switch LF52D ---------------------

;
LF53F:
	ldaa	PressedKeyCode
	suba	#$24	; keyboard code for CHS, 1st keypad key
	staa	CmdChar
	ldaa	CmdChar	; this holds a key number here, not ASCII command
	clrb
	cmpa	#$0B	; 24 + B = 2F = "7", last keypad key
	bhi	LF550
	decb
LF550:
	andb	#$FF
	tstb
	beq	LF5D5	; branch to exit if non-register key pressed?
	ldab	#$03
	andb	flagX01FB
	cmpb	#$01
	bne	LF573	; branch if flagX01FB bits0-1 != 01
	clrb
	adda	#$D3
	adcb	#$F8
	staa	X002F
	stab	X002E
	ldx	X002E
	ldaa	$00,x
	; table F8D3, register names
	; index		0	1	2	3	4	5	6	7	8	9	10	11
	; value		49 	56 	4D 	44	 55 	4C 	4E 	43	52 	47 	59 	5A
	; ASCII		I	V	M	D	U	L	N	C	R	G	Y	Z
	staa	CmdChar
	jsr	sub116
	bra	LF5D5


LF573:
	ldaa	#$03
	anda	flagX01FB
	cmpa	#$02
	bne	LF5B0	; branch if flagX01FB bits0-1 != 10
	ldaa	#$D3
	ldab	#$F8
	adda	CmdChar
	adcb	#$00
	staa	X0029
	stab	X0028
	ldx	X0028
	ldaa	$00,x
	; table F8D3, register names
	; index		0	1	2	3	4	5	6	7	8	9	10	11
	; value		49 	56 	4D 	44	 55 	4C 	4E 	43	52 	47 	59 	5A
	; ASCII		I	V	M	D	U	L	N	C	R	G	Y	Z
	staa	CmdChar
	jsr	sub116
	ldaa	#$80
	anda	flagCmdParse	; test bit7
	tsta
	bne	LF5D5
	ldaa	#$08
	staa	flagCmdParse	; set bit3, clear others
	clr	flag01A1
	clr	flagX01FB
	jmp	LC9D2
;
LF5B0:
	ldaa	#$03
	anda	flagX01FB
	cmpa	#$03
	bne	LF5D5	; branch if flagX01FB bits0-1 != 11
	ldaa	#$DF
	ldab	#$F8
	adda	CmdChar
	adcb	#$00
	staa	X0029
	stab	X0028
	ldx	X0028
	ldaa	$00,x
	; table F8DF, looks like ASCII values of keypad buttons
	; index		0	1	2	3	4	5	6	7	8	9	10	11
	; value		EE 	EE 	30 	33	 32 	31 	36 	35	34 	39 	38 	37

	staa	CmdChar
	jsr	sub116
LF5D5:
	ldaa	#$10		; key code for "LOCAL"
	cmpa	PressedKeyCode
	bne	LF5E2
	ldab	tempCmdParseFlag
	stab	flagCmdParse	; reset value
LF5E2:
	ldaa	#$08
	anda	flagCmdParse
	staa	flagCmdParse	; keep bit3, clear others
	clr	flag01A1
	clr	flag01ED
	clr	flagX01FB
	jsr	subSetAnnuncByte4
	jsr	subSetAnnuncBytes123
	clr	AnDUpdatedFlag
	jsr	subAnnuncNDisplayUpdate
	ldaa	#$01
	staa	AnDUpdatedFlag
	jmp	LD421		; jumps into sub103
;
LF607:
	ldaa	#$60
	anda	ioHPIB_r1	; bit6 set if meter in HPIB Remote mode, bit5 if local lockout set
	cmpa	#$40
	bne	LF658		; branch if bit6=1, bit5=0
	ldaa	#$10		; key code for "LOCAL"
	cmpa	PressedKeyCode
	bne	LF658
	ldab	#$04
	stab	ioHPIB_r3	; return meter to local control
	clr	ioHPIB_r3	; clear commands to HPIB
	clr	flag01A1
	clr	flag01ED
	ldaa	tempCmdParseFlag
	staa	flagCmdParse	; restore value
	ldaa	#$10
	oraa	IGCmdRegister4
	staa	IGCmdRegister4	; set bit4
	ldaa	#$01
	staa	flagDispNeedUpdate
	jsr	sub026
	jsr	subSetAnnuncByte4
	clr	AnDUpdatedFlag
	jsr	subAnnuncNDisplayUpdate
	ldaa	#$01
	staa	AnDUpdatedFlag
	ldaa	X0789
	tsta
	beq	LF655
	clr	flagCmdParse
	jsr	sub115
LF655:
	jmp	LD421		; jumps into sub103
;
LF658:
	jsr	subRestoreX0000_3	; subRestoreX0000_3 ends with rti
;
;===============================================================================
LF65B:
	org $F65B
	db	$00, $00, $00, $01
	db	$00, $00, $00, $00
	db	$01, $28, $27, $26
	db	$25, $24, $23, $22
	db	$21, $00, $01, $02
	db	$03, $04, $05, $06
	db	$07, $08, $09, $0A
	db	$0B, $0C, $0D, $0E
	db	$0F, $10, $29, $28
	db	$27, $26, $25, $24
	db	$23, $22, $21, $00
	db	$01, $02, $03, $04
	db	$05, $06, $07, $08
	db	$09, $0A, $0B, $0C
	db	$0D, $0E, $0F, $19
	db	$39, $59, $79, $36
	db	$56, $76, $33, $53
	db	$00, $20, $40, $60
	db	$23, $43, $63, $26
	db	$46, $66, $29, $49
	db	$69, $89, $A9, $C9
	db	$00, $11, $15, $19
	db	$1D, $00, $00, $00
	db	$00, $00, $00, $00
	db	$00, $00, $00, $00
	db	$00, $10, $14, $18
	db	$1C, $00, $00, $00
	db	$00, $00, $00, $00
	db	$00, $00, $00, $00
	db	$88, $88, $88, $48
	db	$48, $00, $00, $00
	db	$00, $00, $00, $00
	db	$00, $00, $00, $00
	db	$08, $08, $08, $48
	db	$4A, $00, $51, $60
	db	$E0, $35, $00, $00
	db	$00, $00, $00, $00
	db	$2C, $2C, $28, $28
	db	$24, $20, $60, $60
	db	$2A, $2A, $2A, $2A
	db	$00, $00, $00, $00
	db	$AC, $AC, $A8, $A8
	db	$A4, $A0, $E0, $E0
	db	$AA, $AA, $AA, $AA
	db	$00, $00, $00, $00
	db	$00, $4E, $4E, $4E
	db	$4E, $00, $00, $00
	db	$00, $00, $00, $00
	db	$00, $00, $00, $00
	db	$00, $4E, $4E, $4E
	db	$4E, $00, $00, $00
	db	$51, $55, $57, $00
	db	$00, $00, $00, $00
	db	$C0, $C4, $C6, $64
	db	$66, $00, $00, $00
	db	$00, $00, $00, $00
	db	$00, $00, $00, $00
	db	$66, $64, $60, $06
	db	$4E, $00, $4E, $62
	db	$C2, $4A, $00, $00
	db	$00, $00, $00, $00
	db	$51, $55, $55, $53
	db	$53, $53, $53, $53
	db	$51, $55, $55, $53
	db	$00, $00, $00, $00
	db	$C0, $C4, $C4, $C2
	db	$C2, $C2, $C2, $C2
	db	$C0, $C4, $C4, $C2
	db	$00, $00, $00, $00
	db	$81, $86, $81, $86
	db	$01, $06, $40, $40
	db	$11, $1A, $11, $1A
	db	$0C, $0C, $0C, $0C
	db	$04, $04, $07, $07
	db	$07, $03, $07, $03
	db	$10, $10, $10, $10
	db	$18, $00, $50, $11
	db	$12, $14, $00, $01
	db	$02, $08, $00, $00
	db	$00, $00, $00, $00
	db	$10, $14, $12, $11
	db	$50, $30, $00, $18
	db	$00, $30, $50, $D4
	db	$06, $05, $04, $03
	db	$04, $03, $35, $34
	db	$33, $65, $64, $63
	db	$00, $01, $02, $03
	db	$04, $05, $06, $07
	db	$08, $09, $10, $11
	db	$12, $13, $14, $15
	db	$16, $17, $18, $19
	db	$20, $21, $22, $23
	db	$24, $25, $26, $27
	db	$28, $29, $30, $31
	db	$00, $01, $00, $00
	db	$00, $00, $08, $80
	db	$82, $84, $86, $88
	db	$8C, $8E, $90, $92
	db	$12, $12, $12, $13
	db	$11, $10, $0B, $12
	db	$02, $99, $99, $99
	db	$11, $99, $99, $99
	db	$00, $01, $99, $99
	db	$99, $99, $99, $99
	db	$90, $98, $04, $99
	db	$99, $92, $60, $85
	db	$98, $20, $00, $00
	db	$89, $19, $02, $60
	db	$00, $50, $20, $00
	db	$00, $00, $00, $00
	db	$12, $00, $00, $99
	db	$01, $00, $00, $00
	db	$00, $00, $00, $00
	db	$89, $02, $96, $00
	db	$00, $07, $39, $00
	db	$00, $79, $00, $00
	db	$11, $81, $98, $40
	db	$30, $03, $80, $00
	db	$00, $EE, $01, $02
	db	$EE, $03, $EE, $EE
	db	$EE, $EE, $EE, $04
	db	$05, $EE, $06, $07
	db	$EE, $08, $09, $0A
	db	$EE, $EE, $EE, $0B
	db	$EE, $0C, $EE, $60
	db	$40, $20, $C0, $A0
	db	$EE, $EE, $EE, $EE
	db	$EE, $01, $00, $02
	db	$04, $06, $08, $0A
	db	$0C, $0E, $EE, $00
	db	$40, $80, $C0, $EE
	db	$EE, $EE, $EE, $EE
	db	$00, $01, $02, $03
	db	$04, $05, $06, $07
	db	$08, $09, $00, $04
	db	$EE, $EE, $EE, $EE
	db	$EE, $EE, $EE, $EE
	db	$00, $20, $EE, $EE
	db	$EE, $EE, $EE, $EE
	db	$EE, $EE, $00, $08
	db	$EE, $EE, $EE, $EE
	db	$EE, $EE, $EE, $EE
	db	$00, $10, $EE, $EE
	db	$EE, $EE, $EE, $EE
	db	$EE, $EE, $00, $40
	db	$EE, $EE, $EE, $EE
	db	$EE, $EE, $EE, $EE
	db	$00, $80, $EE, $EE
	db	$EE, $EE, $EE, $EE
	db	$EE, $EE, $EE, $EE
	db	$00, $01, $EE, $EE
	db	$02, $EE, $03, $EE
	db	$EE, $04, $05, $06
	db	$EE, $EE, $EE, $07
	db	$EE, $EE, $08, $09
	db	$EE, $EE, $0A, $0B
	db	$00, $EE, $EE, $EE
	db	$00, $01, $02, $03
	db	$49, $56, $4D, $44
	db	$55, $4C, $4E, $43
	db	$52, $47, $59, $5A
	db	$EE, $EE, $30, $33
	db	$32, $31, $36, $35
	db	$34, $39, $38, $37
	db	$2D, $45, $30, $33
	db	$32, $31, $36, $35
	db	$34, $39, $38, $37
	db	$EE, $01, $02, $03
	db	$04, $05, $FF, $02
	db	$93, $62, $48, $15
	db	$01, $FF, $02, $58
	db	$49, $98, $68, $01
	db	$00, $02, $30, $79
	db	$75, $58, $04, $00
	db	$02, $06, $34, $99
	db	$98, $04, $00, $03
	db	$22, $80, $76, $84
	db	$03, $00, $03, $03
	db	$33, $01, $82, $03
	db	$00, $03, $13, $40
	db	$00, $00, $04, $00
	db	$03, $00, $00, $00
	db	$00, $01, $00, $03
	db	$70, $78, $01, $87
	db	$07, $00, $09, $26
	db	$55, $48, $87, $02
	db	$00, $03, $20, $00
	db	$00, $00, $02, $00
	db	$01, $80, $00, $00
	db	$00, $01, $0C, $10
	db	$14, $18, $1C, $20
	db	$00, $04, $08, $0C
	db	$10, $0F, $2F, $17
	db	$37, $08, $28, $10
	db	$30, $0A, $2A, $12
	db	$32

	; F968 jump table
	dw 	LCA6C
	dw 	LCA2A
	dw 	LCA2F
	dw 	LCA34
	dw 	LCA39
	dw 	LCA3E
	dw 	LCA43
	dw 	LCA48
	dw 	LCA4D
	dw 	LCA57

	; F97C  jump table
	dw 	LD1F4
	dw 	LD1CB
	dw 	LD1D0
	dw 	LD1D5

	; F97C  jump table
	dw 	LD33E
	dw 	LD343
	dw 	LD348

	; F98A
	db	$00
	db	$00, $00, $01, $01
	db	$01, $02, $02, $03
	db	$03, $00, $64, $C8
	db	$2C, $90, $F4, $58
	db	$6C, $20, $84, $00
	db	$0A, $14, $1E, $28
	db	$32, $3C, $46, $50
	db	$5A

	; F9A8  jump table
	dw 	LE029
	dw 	LE0BC
	dw 	LE1AE
	dw 	LE231
	dw 	LE2FD
	dw 	LE308
	dw 	LE313
	dw 	LE3F5
	dw 	LE400
	dw 	LE40B
	dw 	LE416
	dw 	LE421
	; F9C0  jump table
	dw 	LE45F
	dw 	LE46E
	dw 	LE4F1
	dw 	LE512
	dw 	LE551
	dw 	LE561
	dw 	LE5C0
	dw 	LE61A
	dw 	LE657
	dw 	LE667
	dw 	LE720
	dw 	LE730

	; F9D8  jump table
	dw 	LE8A6
	dw 	LE8AB
	dw 	LE8B0
	dw 	LE928
	dw 	LE93B
	dw 	LE964
	dw 	LE997
	dw 	LE9AD
	dw 	LE9C3
	dw 	LE9F7
	dw 	LEA1D
	dw 	LEA98
	dw 	LEABA

	; F9F2  jump table
	dw 	LEAED
	dw 	LEAF2
	dw 	LEB05
	dw 	LEB0A
	dw 	LEB1D
	dw 	LEB22
	dw 	LEB27
	dw 	LEB2C
	dw 	LEB31
	dw 	LEB66
	dw 	LEBA9
	dw 	LEBBC
	dw 	LEBC1

	; FA0C  jump table
	dw 	LEC15
	dw 	LEC1A
	dw 	LEC1F
	dw 	LEC4D
	dw 	LEC97
	dw 	LECAC
	dw 	LECC1
	dw 	LECEB

	; FA1C  jump table
	dw 	LE7BC
	dw 	LE885
	dw 	LEBD9

	db	$09
	db	$03, $02, $01, $09
	db	$05, $04

	; FA29  jump table
	dw 	LF2E9
	dw 	LF31A
	dw 	LF36F
	dw 	LF32A
	dw 	LF35C


	; FA33  jump table
	dw 	LF49B
	dw 	LF4B8
	dw 	LF510
;
;===============================================================================
; Data array math functions
; Given pointers to two 7-byte arguments, places result into 3rd array
;
; Stack contents when called:
;	caller address: $00,x  $01,x
;	number of index values on stack: $02,x (always 3)
;	1st index on stack: $03,x $04,x pointer to returned result
;	2nd index on stack: $05,x $06,x pointer to 1st argument
;	3rd index on stack: $07,x $08,x pointer to 2nd argument
;
; Constants used in the calls (in hex):
;F65D	00	01	00	00	00	00	01	(subRegisterAdd)
;F7D3	00	01	00	00	00	00	08	(subRegisterSubtract)
;F8FD	FF	02	93	62	48	15	01	(subRegisterSubtract)
;F90B	00	02	30	79	75	58	04	(subRegisterDivide)
;F919	00	03	22	80	76	84	00	(subRegisterSubtract)
;F927	00	03	13	40	00	00	04	(subRegisterSubtract)
;F92E	00	03	00	00	00	00	01	(subRegisterAdd)
;F935	00	03	70	78	01	87	07	(subRegisterSubtract)
;F93C	00	09	26	55	48	87	02	(subRegisterSubtract)
;F943	00	03	20	00	00	00	02	(subRegisterAdd)
;F94A	00	01	80	00	00	00	01	(subRegisterMultiply)
;

subRegisterAdd:		; addition
	bsr	subMath01
	jsr	subMath03
	bra	LFA53
;
subRegisterSubtract:		; subtraction
	bsr	subMath01
	jsr	subMath02
	bra	LFA53
;
subRegisterMultiply:		; multiplication
	bsr	subMath01
	jsr	subMath05
	bra	LFA53
;
subRegisterDivide:		; division
	bsr	subMath01
	jsr	subMath06
LFA53:
	tsx
	ldx	$03,x	; this puts the calculation result in array specified
	ldaa	X07A5	; by the caller
	staa	$00,x
	ldaa	X07A6
	staa	$01,x
	ldaa	X07A7
	staa	$02,x
	ldaa	X07A8
	staa	$03,x
	ldaa	X07A9
	staa	$04,x
	ldaa	X07AA
	staa	$05,x
	ldaa	X07AB
	staa	$06,x
	tsx
	ldx	$00,x
	ins		; removes 9 bytes from stack, 7 data bytes and caller address
	ins
	ins
	ins
	ins
	ins
	ins
	ins
	ins
	jmp	$00,x	; index jump back to calling routine

;===============================================================================
; pulls the two input argument arrays from the stack
subMath01:

	tsx		; X = SP + 1
	ldaa	$04,x	; 2 calls means 4 caller address bytes on stack
	cmpa	#$03	; 3 arguments passed?
	bne	LFA87	; branches to infinite loop if not
	tsx
	ldx	$09,x	; start at 3rd index on stack --> 2nd argument
	ldaa	$00,x	; put 7 consecutive bytes into X07B1-7
	staa	X07B1
	ldaa	$01,x
	staa	X07B2
	ldaa	$02,x
	staa	X07B3
	ldaa	$03,x
	staa	X07B4
	ldaa	$04,x
	staa	X07B5
	ldaa	$05,x
	staa	X07B6
	ldaa	$06,x
	staa	X07B7
	tsx
	ldx	$07,x	; start at 2nd index on stack --> 1st argument
	ldaa	$00,x	; put 7 consecutive bytes into X07B8-E
	staa	X07B8
	ldaa	$01,x
	staa	X07B9
	ldaa	$02,x
	staa	X07BA
	ldaa	$03,x
	staa	X07BB
	ldaa	$04,x
	staa	X07BC
	ldaa	$05,x
	staa	X07BD
	ldaa	$06,x
	staa	X07BE
	rts
;
LFA87:
	jmp	LFE3C
;===============================================================================
;
subMath02:
	com	X07B8	; 1's compliment of 1st byte of 1st argument

subMath03:
	bsr	subMath04
	jsr	subMath20
	ldx	#$07A6
	jsr	subMath14
	ldx	#$07A6
	jsr	subMath15
	beq	LFB12
	ldx	#$07B9
	jsr	subMath15
	beq	LFB17
	ldaa	X07A5
	bpl	LFB17
	jsr	subMath07
	bcs	LFB17
	ldx	#$07B9
	jsr	subMath19
	ldx	#$07B2
	jsr	subMath19
LFB12:
	ldaa	X07B8
	bra	LFB1A
;
LFB17:
	ldaa	X07B1
LFB1A:
	staa	X07A5
	ldx	#$07A6
	jsr	subMath14
	jsr	subMath08
	ldx	#$07AC
	jsr	subMath16
LFB2C:
	ldx	#$07A6
	jsr	subMath15
	bne	LFB3B
	clr	X07AB
	clr	X07A5
	rts

LFB3B:
	ldx	#$07A6
	ldaa	$00,x
	beq	LFB4E
	anda	#$F0
	beq	LFB64
	inc	X07AB
	bvs	LFBAF
	jmp	subMath12
;
LFB4E:
	jsr	subMath13
	dec	X07AB
	bvs	LFBAF
	bra	LFB3B
;---------------------------------
;
subMath04:
	ldaa	X07B1
	eora	X07B8
	staa	X07A5
	clr	x07BF
LFB64:
	rts
;---------------------------------
;
subMath05:
	bsr	subMath04
	ldaa	X07B7
	adda	X07BE
	bvs	LFBAF
	staa	X07AB
	ldx	#$07AC
	jsr	subMath14
	bsr	subMath09
	bra	LFB2C		; branch into subMath03
;---------------------------------
;
subMath06:
	bsr	subMath04
	ldaa	X07B7
	suba	X07BE
	bvs	LFBAF
	ldx	#$07A6
	jsr	subMath14
	ldx	#$07AC
	jsr	subMath16
	jsr	subMath12
	inca
	bvs	LFBAF
	staa	X07AB
	bsr	subMath10
	bcs	LFBAF
	ldab	#$05
	ldx	#$07A6
LFBA4:
	ldaa	$06,x
	staa	$00,x
	inx
	decb
	bne	LFBA4
	jmp	LFB2C
;
LFBAF:
	com	x07BF
	rts
;---------------------------------
;
subMath07:
	ldx	#$07B9
	jsr	subMath19
subMath08:
	bsr	subMath11
	ldx	#$07A6
	clc
	ldab	#$05
LFBC1:
	ldaa	$04,x
	adca	$17,x
	daa
	staa	$04,x
	dex
	decb
	bne	LFBC1
	bra	LFC0F
;
subMath09:
	ldx	#$07A6
	jsr	subMath16
	ldab	#$09
LFBD6:
	ldaa	X07B0
	anda	#$0F
	beq	LFBE4
	bsr	subMath08
	dec	X07B0
	bra	LFBD6
;
LFBE4:
	bsr	subMath12
	decb
	bne	LFBD6
	rts
;---------------------------------
;
subMath10:
	ldx	#$07B9
	bsr	subMath15
	bne	LFBF3
	sec
	rts

LFBF3:
	ldab	#$0A	; ASCII [lf]
	bsr	subMath07
	bcc	LFC05
	rts

LFBFA:
	bsr	subMath13
LFBFC:
	bsr	subMath08
	bcc	LFC05
	inc	X07B0
	bra	LFBFC
;
LFC05:
	bsr	subMath07
	jsr	subMath19
	decb
	bne	LFBFA
	clc
	rts

LFC0F:
	ldaa	x07C0
	ldab	x07C2
	ldx	x07C4
			; <-- carries on into subMath11
;---------------------------------
;
subMath11:
	staa	x07C0
	stab	x07C2
	stx	x07C4
	rts
;---------------------------------
;
subMath12:
	bsr	subMath11
	ldaa	#$04
LFC26:
	ldx	#$07A6
	ldab	#$01
	clc
	bsr	subMath17
	ldx	#$07AC
	bsr	subMath17
	deca
	bne	LFC26
	bra	LFC0F
				; <-- carries on into subMath10
;---------------------------------
;
subMath13:
	bsr	subMath11
	ldaa	#$04
LFC3C:
	ldx	#$07AC
	clc
	ldab	#$01
	bsr	subMath18
	ldx	#$07A6
	bsr	subMath18
	deca
	bne	LFC3C
	bra	LFC0F
				; <-- carries on into subMath10
;---------------------------------
;
subMath14:
	bsr	subMath11
	ldx	#$07B2
	ldab	#$05
LFC55:
	ldaa	$00,x
	inx
	stx	x07C6
	ldx	x07C4
	staa	$00,x
	inx
	stx	x07C4
	ldx	x07C6
	decb
	bne	LFC55
	bra	LFC0F
				; <-- carries on into subMath10
;---------------------------------
;
subMath15:
	ldab	#$05
LFC6E:
	tst	$00,x
	bne	LFC76
	inx
	decb
	bne	LFC6E
LFC76:
	rts
;---------------------------------
;
subMath16:
	ldab	#$05
LFC79:
	clr	$00,x
	inx
	decb
	bne	LFC79
	rts
;---------------------------------
;
subMath17:
	jsr	subMath21
LFC83:
	ldx	x07C6
	ldaa	#$05
LFC88:
	ror	$00,x
	inx
	deca
	bne	LFC88
	decb
	bne	LFC83
	jmp	LFD16
				; <-- carries on into subMath21
;---------------------------------
;
subMath18:
	bsr	subMath21
LFC96:
	ldx	x07C6
	ldaa	#$05
LFC9B:
	rol	$04,x
	dex
	deca
	bne	LFC9B
	decb
	bne	LFC96
	bra	LFD16
				; <-- carries on into subMath21
;---------------------------------
;
subMath19:
	bsr	subMath21
	ldab	#$05
LFCAA:
	ldaa	#$99
	suba	$04,x
	staa	$04,x
	dex
	decb
	bne	LFCAA
	sec
	ldab	#$05
	ldx	x07C6
LFCBA:
	ldaa	#$00
	adca	$04,x
	daa
	staa	$04,x
	dex
	decb
	bne	LFCBA
	bra	LFD16
				; <-- carries on into subMath21
;---------------------------------
;
subMath20:
	ldaa	X07B7
	cmpa	X07BE
	beq	LFD09
	blt	LFCE1
	ldx	#$07B2
	jsr	subMath15
	tstb
	bne	LFCF6
	ldaa	X07BE
	staa	X07AB
	rts

LFCE1:
	ldx	#$07B9
	jsr	subMath15
	tstb
	beq	LFCF2
	ldx	#$07B2
	ldaa	X07BE
	bra	LFCF9
;
LFCF2:
	staa	X07AB
	rts

LFCF6:
	ldx	#$07B9
LFCF9:
	ldab	#$04
	bsr	subMath17
	ldab	$00,x
	andb	#$0F
	stab	$00,x
	inc	$05,x
	cmpa	$05,x
	bne	LFCF9
LFD09:
	staa	X07AB
	rts
;---------------------------------
;
subMath21:
	stx	x07C6
	staa	x07C1
	stab	x07C3
LFD16:
	ldx	x07C6
	ldaa	x07C1
	ldab	x07C3
	rts
;---------------------------------
;
;==============================================================================
; when called A = MeasArray0 + 1, B = 0
sub142:
	ldx	#$000F
LFD23:
	asla		; shift left, MSB -> C
	rolb		; roll left, C -> LSB
	bcs	LFD32	; branch if C = 1
	dex
	bne	LFD23
	tstb
	beq	LFD31	; branch if B = 0
	ldaa	X0003
	ldab	X0002
LFD31:
	rts

LFD32:
	stab	X0000
	staa	X0001
	ldaa	X0003
	ldab	X0002
LFD3A:
	asla
	rolb
	asl	X0001
	rol	X0000
	bcc	LFD48
	adda	X0003
	adcb	X0002
LFD48:
	dex
	bne	LFD3A
	rts

;===============================================================================
; This sub called right after NMI or IRQ.
;
; Puts values X0000-3 on stack
;
subSaveX0000_3:
	tsx			; IX <- (SP) + 0001
	ldx	$00,x		; calling routine PC address
	ins
	ins
	ldaa	X0000
	psha
	ldaa	X0001
	psha
	ldaa	X0002
	psha
	ldaa	X0003
	psha
	jmp	$00,x		; index jump back to calling routine
;
;---------------------------------
subRestoreX0000_3:		; called at the end of IRQ and NMI subs
	ins
	ins
	pula
	staa	X0003
	pula
	staa	X0002
	pula
	staa	X0001
	pula
	staa	X0000
	rti
;---------------------------------
; Swaps high and low nibbles in byte
; Only called from subCallNibbleSwap, with stack, from top: 02, 00, 04, 00, X0798.
; X0798 contains a copy of MeasArray1,3,4 or 5.
; Returns with A = B = byte with nibbles swapped.

subNibbleSwap:
	tsx		; X = SP + 1
	ldaa	#$02
	cmpa	$02,x	; top byte, = 02
	beq	LFD78	; always followed
	jsr	sub147	; stores stack pointer and waits in loop
LFD78:
	ldaa	$04,x	; A = 04
	ldab	$06,x	; B = X0798
	tsta
	beq	LFDA2	; never followed
LFD7F:
	lsrb		; right shift, LSB -> Carry flag
	bcc	LFD84	; branch if Carry = 0
	orab	#$80	; set bit7
LFD84:
	deca
	bne	LFD7F	; A = 3,2,1
	bra	LFDA2	; return
;
LFD89:			; label not referenced; code never called.
	tsx
	ldaa	#$02
	cmpa	$02,x
	beq	LFD93
	jsr	sub147	; stores stack pointer and waits in loop
LFD93:			; code never called.
	ldaa	$04,x
	ldab	$06,x
	tsta
	beq	LFDA2
LFD9A:			; label not referenced; code never called.
	aslb
	bcc	LFD9F
	orab	#$01
LFD9F:
	deca
	bne	LFD9A
LFDA2:
	tpa		; A = CC
	ldx	$00,x	; address of caller
	ins
	ins
	ins
	ins
	ins
	ins
	ins		; clear data from stack
	tap		; CC = A
	tba		; A = B (= X0798)
	jmp	$00,x	; index jump  back to calling routine

;===============================================================================
; Passed three bytes on stack.  Second and third form a word that is the number
; of delay units of about 67 uS each for the total delay commanded.
; Leaves caller's address in X and A = 00
subProgrammedDelay:
	tsx		; X = SP + 1
	dec	$02,x	; dec last data byte put on stack, is always 01
	bne	LFDCB	; always 00 after dec, this branch never taken
	ldx	$03,x	; read 2nd & 3rd last bytes put on stack
	beq	LFDC1	; if the last (2?) byte(s) is 00, fix stack and return

LFDB9:	;---outer loop
	ldaa	#$0F
LFDBB:	;--- inner loop, done 15 times taking about 67 uS
	deca		; decrement A, Z = 1 if A = 00
	bne	LFDBB	; branch back until A = 00
	;--- end inner loop
	dex
	bne	LFDB9	; also loop until X = 0
	;--- end outer loop
LFDC1:
	tsx		; X = SP + 1
	ldx	$00,x	; address of calling routine
	ins
	ins
	ins
	ins
	ins		; remove caller's address and 3 bytes from stack
	jmp	$00,x	; index jump back to calling routine
;
LFDCB:			; never followed
	jsr	sub147
			; <-- no rts
;---------------------------------
; stores stack pointer and waits in loop
sub147:
	sts	X0000
LFDD0:
	bra	LFDD0	; infinite loop
LFDD2:			; unreferenced label
	bra	LFDD0
;---------------------------------
;
sub148:
	ins
	ins
	ins
	ins
	pulb
	pula
	staa	X0003
	pula
	staa	X0002
	pula
	staa	X0001
	pula
	staa	X0000
	stab	ioHPIB_r0	; mask for interrupts from HPIB
	rti
	rts
;===============================================================================
; Waits until a byte is available from Inguard, or it sets the timeout flag
; Callers put two bytes on stack
subWaitForIGStatus:
	pula			; PC from calling routine MSB
	staa	X0000
	pula			; PC from calling routine LSB
	staa	X0001		; PC is saved
	ins			; skips next byte in stack (alwasy 01)
	pula			; pulls next two bytes
	pulb
				; in subCheckIfIGReadyToMeasure these are A=FA, B=00
				; in sub060 and sub062 are 00 AA
	staa	x00BC		; set to FA (when called from subCheckIfIGReadyToMeasure) or 00
	ldaa	X0001		; returns PC of calling routine to stack
	psha
	ldaa	X0000
	psha
	staa	ioHPIB_r1	; undocumented use of HPIB chip
	tstb			; value 00 or AA from stack
LFDFF:
	beq	LFE09		; branch if B = 0, ie if called from subCheckIfIGReadyToMeasure, or B decremented to 0
LFE01:
	ldaa	ioHPIB_r4	; bit 7 indicates byte is available from Inguard
	bmi	LFE1A		; branch if bit 7 set, does return to caller
	decb
	bra	LFDFF		; stays in loop, decrementing B
;
LFE09:
	ldab	x00BC		; set B to FA if called from subCheckIfIGReadyToMeasure, else to 00
	dec	x00BC		; -> F9 or FF
	tstb
	beq	LFE15		; if B gets to zero...
	ldab	#$FF
	bra	LFE01
;
LFE15:
	ldaa	#$FF		; ...set timeout flag before returning
	staa	flagInguardTimeout
LFE1A:
	rts
;===============================================================================
; Called from subGetInguardReading before Inguard byte is read, waits until byte is ready.
; Sets timeout flag if no data shows up.
; Calling routine pushes 00 on stack, and this sub just deletes it.
subWaitForIGbyte:
	pulb	; 1st two bytes are caller's addresss
	pula
	ins	; deletes last data byte on stack, which was a zero
	psha
	pshb
	clrb
LFE21:
	ldaa	ioHPIB_r4
	bmi	LFE31	; branch if bit7 set, i.e., data byte is available
	incb		; from Inguard.
	beq	LFE2C	; if no data, loop until B rolls over
	jmp	LFE21
;
LFE2C:
	ldaa	#$FF	; timeout has occurred
	staa	flagInguardTimeout
LFE31:
	nop	; perhaps waiting until serial data from inguard is clocked
	nop	; onto bus?
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	rts
LFE3B:
	nop
LFE3C:
	bra	LFE3C
;===============================================================================
;
;
	org	$FE3E		; location of this data in original
	db	$39, $39, $09, $99
	db	$99, $56, $57, $00
	db	$00, $04, $34, $27
	db	$09, $99, $56, $54
	db	$88, $00, $04, $32
	db	$13, $73, $09, $54
	db	$24, $25, $09, $03
	db	$01, $02, $99, $95
;===============================================================================


subMath22:
	ldx	IdxPtr0169	; always 0169
	ldab	#$09
	cmpb	$00,x
	bne	LFE6B
	ldab	#$50
	stab	$0A,x		; if X0169 = 09, RegisterSTAT34 = 50, else not changed
LFE6B:
	ldx	#$FE5D
	stx	x07CC		; = FE5D
	ldaa	#$FF
LFE73:
	inca			; A = 0, 1,...
LFE74:
	bsr	subMath27
	bsr	subMath25
	bsr	subMath24
	bsr	subMath23
	beq	LFE74		; branch if top nibble of X0169 is 0
	ldx	x07CA
	stx	x07CC
LFE84:
	bsr	subMath28
	bsr	subMath24
	bsr	subMath23
	bne	LFE84		; branch if top nibble of X0169 != 0
	ldx	x07CA
	stx	x07CC
	cmpa	#$02
	blt	LFE73
	rts
;---------------------------------
; returns with top nibble of X0169 in B
subMath23:
	ldx	IdxPtr0169	; always 0169
	ldab	$00,x
	andb	#$F0
	rts
;---------------------------------
; BCD addition of 5 digits
subMath24:
	ldx	IdxPtr0174	; always 0174
	stx	x07C8
	ldx	x07CC
	stx	x07CA
subMath25:
	psha		; put A aside
	clra
	ldab	#$05	; B is loop index
LFEAF:
	tap		; transfer A to CC
	ldx	x07CA	; iter 1: x07CA = 016D (measurement exponent), 016C
	decb		; B = 4,3,2,1,0
	ldaa	$00,x
	dex		; X = 016C,016B
	bsr	subMath26
	tstb
	bne	LFEAF
	pula		; restore A
	rts
;---------------------------------
;
subMath26:
	stx	x07CA
	ldx	x07C8	; 1st iteration points to 0RegisterSTAT35
	adca	$00,x
	daa		; BCD adjustment to previous addition
	staa	$00,x
	dex
	stx	x07C8
	tpa		; transfer CC to A
	rts
;---------------------------------

subMath27:
	ldx	IdxPtr0169	; always 0169
	inx
	inx
	inx
	inx			; X now 016D
	stx	x07C8
	cmpa	#$01
	blt	LFEE1
	beq	LFEE0
	dex
LFEE0:
	dex
LFEE1:
	stx	x07CA	; if A = 0, 1, >1, X = 016D, 016C, 016B
	rts
;---------------------------------
;
subMath28:
	psha
	bsr	subMath27
	clra
	psha
	ldab	#$05
	stab	x07CE
LFEEF:
	dec	x07CE
	ldx	x07CA
	ldab	$00,x
	clc
	rorb
	asrb
	asrb
	asrb
	dex
	ldaa	$00,x
	asla
	asla
	asla
	asla
	aba
	adda	#$66	; constant used in BCD number adjustments
	coma
	tab
	pula
	tap
	tba
	bsr	subMath26
	psha
	tst	x07CE
	bne	LFEEF
	ins
	pula
	ldx	x07CC
	rts
;---------------------------------
;
; Conversion from hex to BCD?
sub158:
	ldx	IdxPtr0169	; always 0169
	ldaa	$05,x	; X016E ; 1st byte of a data array
	bita	#$80	; test bit7
	beq	LFF29	; branch if 0, meaning A is positive
	nega		; negate A (2's compliment)
	dex
	ldab	#$FF
	stab	$00,x	; X0168 = 0xFF if the number was negative
	inx		; X = 0169
LFF29:
	tsta
	beq	LFF55	; rts if data in X016E is positive
	clrb		; it's negative
LFF2D:
	cmpa	#$10	; byte contains more than 1 hex digit?
	blt	LFF38	; no
	incb
	anda	#$0F	; A's lower nibble
	adda	#$06	; BCD adjustment, B accumulating next digit
	bra	LFF2D
;
LFF38:
	cmpa	#$0A
	blt	LFF3F	; branch if A < 10
	incb
	suba	#$0A	; if A > 9, subtract 10, inc B
LFF3F:
	tstb
	beq	LFF4F	; branch if there was no carry digit
	stab	$00,x	; X0169, B != 0
	asla
	asla
	asla
	asla
	staa	$01,x	; shift A left 4 bits, put in X016A
	ldab	#$02
	stab	$05,x	; X016E = 0x02
	rts
;
LFF4F:			; B = 0, so no carry digit
	staa	$00,x	; X0169 = A
	ldaa	#$01
	staa	$05,x	; X016E = 0x01
LFF55:
	rts
;===============================================================================
; Interrupt vectors
;
	data
	org	$FFF0		; their location at the end of ROM
SA2:
	dw	SigAnalyzer2
	db	$FF, $FF, $FF, $FF
SA1:
	dw	SigAnalyzer1
irq:
	dw	subIRQ
	db	$FF, $FF
nmi:
	dw	subNMI
rst:
	dw	subRST


