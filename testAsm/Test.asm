main:
    NOP
    MOV R0, #0x7B7B
    MOV R1, #0x0400
    STOR R0, R1, #0
    LOAD R3, R1, #0
    MOV R1, #0x1111 
    MOV R2, #0x1111
    CMP R1, R2, R1
    B.eq end
    SET R0
end:
    NOP
    HALT