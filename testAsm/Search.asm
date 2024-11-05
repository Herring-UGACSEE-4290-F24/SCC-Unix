    ORG     #0xD500;
    FCB     #0x5;
    FCB     #0x3;
    FCB     #0x7;
    FCB     #0x1;
    FCB     #0x4;
    FCB     #0x9;
    FCB     #0x6;
    FCB     #0x8;
    FCB     #0x2;
    FCB     #0xA;
    ORG     #0x0;

setup:
    MOV32 R0, #0xABCDEF01   ; Pattern to be searched
    MOV   R1, #4            ; Length of Pattern
    MOV32 R2, #0xD500       ; Starting Address
    MOV32 R3, #0xD528       ; Ending Address (exclusive)

    CMP R1, R1, #1
    b.eq one_byte_search
    CMP R1, R1, #1
    b.eq two_byte_search
    CMP R1, R1, #1
    b.eq three_byte_search
    CMP R1, R1, #1
    b.eq four_byte_search
    MOV32 R7, #0xFFFFFFFE   ; -2 in R7 as error indicator
    b exit

one_byte_search:
    LOAD R4, R2
    LSL R4, R4, #3
    LSR R4, R4, #3
    CMP R4, R4, R0
    b.eq found
    ADD R2, R2, #1
    CMP R4, R3, R2
    b.eq exit
    b one_byte_search

two_byte_search:
    LOAD R4, R2
    LSL R4, R4, #2
    LSR R4, R4, #2
    CMP R4, R4, R0
    b.eq found
    ADD R2, R2, #1
    CMP R4, R3, R2
    b.eq exit
    b two_byte_search

three_byte_search:
    LOAD R4, R2
    LSL R4, R4, #1
    LSR R4, R4, #1
    CMP R4, R4, R0
    b.eq found
    ADD R2, R2, #1
    CMP R4, R3, R2
    b.eq exit
    b three_byte_search

four_byte_search:
    LOAD R4, R2
    CMP R4, R4, R0
    b.eq found
    ADD R2, R2, #1
    CMP R4, R3, R2
    b.eq exit
    b four_byte_search

found:
    MOV32 R7, #1            ; 1 in R7 on found
    HALT

exit:
    MOV32 R7, #0xFFFFFFFF   ; -1 in R7 on not found
    HALT