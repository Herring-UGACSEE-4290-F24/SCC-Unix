main:
	MOV R0, #0x1111		; R0 will have all 1's for low byte
	MOV R1, #1			; R1 will have 1
	CLR R0				; R0 set to 0
	STOR R1, R0			; 1 will be stored at address 0 in data
	LOAD R0, R0			; 1 will loaded into R0 from data

	MOV R0, #5			; R0 will have 5
	MOV R1, #1 			; R1 will have 1
	
	ADD R2, R0, R1		; R2 will have 6
	SUB R2, R0, R1		; R2 will have 4
	AND R2, R0, R1		; R2 will have 1
	OR R2, R0, R1		; R2 will have 5
	XOR R2, R0, R1		; R2 will have 4
	NOT R2, R0 			; R2 will have -6 

	LSL R2, R0, #1		; R2 will have 10
	LSR R2, R2, #1		; R2 will have 5
	CLR R2				; R2 will have 0
	SET R2				; R2 will have -1

	CLR R0				; R0 will have 0
	CLR R1				; R1 will have 0
	CLR R2				; R2 will have 0
	b skipa				; Skips over the SETs
	SET R0				; R0 will have -1
	SET R1				; R1 will have -1
	SET R2				; R2 will have -1
skipa:
	ADDS R0, R0, R0		; R0 will have 0, and CPSR will be 0x400
	B.eq skipb			; Skips over the SETs
	SET R0				; R0 will have -1
	SET R1				; R1 will have -1
	SET R2				; R2 will have -1
skipb:
	MOV R0, #4			; R0 will have 4
	MOV R1, #12			; R1 will have 12
	XOR R2, R1, R0		; R2 will have 8
	CLR R2				; R2 will have 0
	XOR R2, R1, #4		; R2 will have 8
	HALT
