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
    input [31:0] usr_data;
    input [31:0] wr_zr_data;
    input [31:0] wr_r1_data;
    input [31:0] wr_r2_data;
    input [31:0] wr_r3_data;
    input [31:0] wr_sp_data;
    input [31:0] wr_lr_data; 
    input [31:0] wr_pc_data;
    input [31:0] wr_cpsr_data;

    input wr_zr;
    input wr_r1;
    input wr_r2; 
    input wr_r3; 
    input wr_sp; 
    input wr_lr;
    input wr_pc;
    input wr_cpsr;
    input wr_sp;
    input wr_enable;

    input [2:0] write_addr;
    input [2:0] read_addr;

    input clk;

    output [31:0] re_zr;
    output [31:0] re_r1;
    output [31:0] re_r2;
    output [31:0] re_r3;
    output [31:0] re_sp;
    output [31:0] re_lr;
    output [31:0] re_pc;
    output [31:0] re_cpsr;
    output [31:0] re_usr;




endmodule

