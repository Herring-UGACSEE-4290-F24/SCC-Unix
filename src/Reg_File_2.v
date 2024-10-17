/*
 * This module contains the register file for special set of registers for the Single Cycle Computer
 * that are not directly accessible by the user (they are writable but it is not reccomended). 
 * R0 --> Zero Register (ZR)
 * R1 --> TBD
 * R2 --> TBD
 * R3 --> TBD
 * R4 --> Stack Pointer (SP)
 * R5 --> Link Register (LR)
 * R6 --> Program Counter (PC)
 * R7 --> CPSR (NZCV....+)
 * 
 * Jake's thoughts: 
 * -----------------------------------
 *  - Design mostly as single port write, single port read 
 *  - Should be channels where there is direct access to CPSR & PC
 *  - We don't need direct access to the LR, BL 
 */

module Reg_File_2(...);




endmodule

