main:
    MOV R2, #0x1111
    NOP
    ADD R2, R2, #1
    CLR R2
    SET R1
    SUB R1, R1, #1
    CLR R1

    ADD R0, R0, #5
    SUB R1, R0, #6
    MOV R0, #0
    B label
    MOV R0, #3
    NOP
label:
    ADD R3, R1, #7
    NOP
    MOV R1, #1
    ADD R3, R3, R1
    HALT