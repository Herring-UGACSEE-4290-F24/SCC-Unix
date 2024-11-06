main:
	MOVT R2, #0xFFFF
	NOP
	MOV R2, #0xFFFE
twos: ; converts from twos complement in R2
	NOT R2, R2
	NOP
	ADD R2, R2, #0x0001
	NOP ; should be -2
slide:
	LSL R3, R2, #0x0001
	LSR R3, R3, #0x0001
	NOP
	CLR R3 ; all 0's
	NOP
	SET R3 ; all 1's
	NOP
	XORS R3, R3, R3 ; should clear it
	B.pl skipo ; if we ever see 3 NOP's then branches aren't working or I am bad
	NOP
	NOP
	NOP
skipo:
	LSL R3, R2, #0x0001 ; same value as earlier
	NOP
	OR R4, R3, R2 ; should or in R4
	NOP
	ORS R5, R3, R2 ; same as R4
	B.mi nobrch ; should not branch here
	NOP
	CMP R7, R5, R4 ; should be same
	B.hs skipw ; go to skipw
	NOP
	NOP
	NOP
skipw:
	CLR R3
	SET R2
	AND R4, R3, R2 ; R4 should be 0
	NOP
	ANDS R4, R3, R2 ; should still be 0
	B.mi nobrch ; should not branch here
	NOP
	XOR R5, R5, R5 ; should clear
	MOV R5, #0x00A8 ; find VAL to skip the NOPS (0x00AC => 0x00A8)
	BR R5, #0x0004 ; guaranteed branch to P5 plus offset
	NOP
	NOP
	NOP
	;BR branch here
	LSL R3, R2, #0x0001
	CMP R7, R3, R2 ; should be not equal
	B.ne skipt ; go to skipt
	NOP
	NOP
	NOP
skipt:
	ADDS R4, R3, R2 ; should overflow since R2 and R3 are set/set -> slide 1
	B.vs skipf ; go to skipf
	NOP
	NOP
	NOP
skipf:
	CLR R2
	SET R3
	ADDS R4, R3, R2 ; should not overflow since R2 is clear and R3 is set
	B.vc skipl ; go to skipl
	NOP
	NOP
	NOP
skipl:
	CLR R2
	CLR R3
	MOV R2, #0xFFFF ; R2 = 0000_FFFF = 65,535
	MOV R3, #0xFFFE ; R3 = 0000_FFFE = 65,534
	CMP R7, R2, R3 ; should be higher by 1
	B.hi skipi ; go to skipi
	NOP
	NOP
	NOP
skipi:
	CMP R7, R3, R2 ; should be lower by 1
	B.ls skips ; go to skips
	NOP
	NOP
	NOP
skips:
	; signed flags
	MOVT R2, #0xFFFF ; R2 = FFFF_FFFF = -1
	MOVT R3, #0xFFFF ; R3 = FFFF_FFFE = -2
	CMP R7, R2, R3
	B.ge skipe ; go to skipe
	NOP
	NOP
	NOP
skipe:
	CMP R7, R3, R2
	B.lt skipg ; go to skipg
	NOP
	NOP
	NOP
skipg:
	CMP R7, R2, R3
	B.gt skipn ; go to skipn
	NOP
	NOP
	NOP
skipn:
	CMP R7, R3, R2
	B.le skipd ; branch to skipd
	NOP
	NOP
	NOP
skipd:
	B.al nexbr ; always branch to nexbr
	NOP
	NOP
	NOP
nexbr:
	B.nv nobrch ; should not branch to the end, should just halt next instruction
	HALT ; should not go to this line
	
nobrch:
	NOP
	NOP
	NOP
	HALT
	
;Need:
;eq DONE
;ne DONE
;hs DONE
;lo DONE
;mi DONE
;pl DONE
;vs DONE
;vc DONE
;hi DONE
;ls DONE
;ge DONE
;lt DONE
;gt DONE
;le DONE
;al DONE
;nv DONE
