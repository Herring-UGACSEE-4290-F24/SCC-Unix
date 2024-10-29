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
 */

module SpecialRegs(reset, usr_data, wr_zr_data, wr_r1_data, wr_r2_data, wr_r3_data, wr_sp_data, wr_lr_data, wr_pc_data, wr_cpsr_data, wr_usr_enable, 
                    wr_zr, wr_r1, wr_r2, wr_r3, wr_sp, wr_lr, wr_pc, wr_cpsr, write_usr_addr, read_usr_addr, clk, re_zr, re_r1, re_r2, re_r3, re_sp, re_lr, re_pc, re_cpsr, re_usr);

    input reset;
    input [31:0] usr_data;                     // defining data lines
    input [31:0] wr_zr_data;
    input [31:0] wr_r1_data;
    input [31:0] wr_r2_data;
    input [31:0] wr_r3_data;
    input [31:0] wr_sp_data;
    input [31:0] wr_lr_data; 
    input [31:0] wr_pc_data;
    input [31:0] wr_cpsr_data;

    input wr_zr;                               // defining enable signals for regs to write or read
    input wr_r1;
    input wr_r2; 
    input wr_r3; 
    input wr_sp; 
    input wr_lr;
    input wr_pc;
    input wr_cpsr;
    input wr_usr_enable;

    input [2:0] write_usr_addr;                // defining address lines for write and read
    input [2:0] read_usr_addr;

    input clk;

    reg [31:0] spc_regs [0:7];  

    output wire [31:0] re_zr;
    output wire [31:0] re_r1;
    output wire [31:0] re_r2;
    output wire [31:0] re_r3;
    output wire [31:0] re_sp;
    output wire [31:0] re_lr;
    output wire [31:0] re_pc;
    output wire [31:0] re_cpsr;

    output wire [31:0] re_usr;

    assign   re_zr[31:0]   = spc_regs[0];
    assign   re_r1[31:0]   = spc_regs[1];
    assign   re_r2[31:0]   = spc_regs[2];
    assign   re_r3[31:0]   = spc_regs[3];
    assign   re_sp[31:0]   = spc_regs[4];
    assign   re_lr[31:0]   = spc_regs[5];
    assign   re_pc[31:0]   = spc_regs[6];
    assign re_cpsr[31:0]   = spc_regs[7];

    assign re_usr = spc_regs[read_usr_addr];

    initial begin                                                     // Sending stored values to waveform
        $dumpvars(0, spc_regs[0], spc_regs[1], spc_regs[2], spc_regs[3], spc_regs[4], spc_regs[5], spc_regs[6], spc_regs[7]);
    end

    always @(reset) begin
        spc_regs[0] <= 0;
        spc_regs[1] <= 0;
        spc_regs[2] <= 0;
        spc_regs[3] <= 0;
        spc_regs[4] <= 0;
        spc_regs[5] <= 0;
        spc_regs[6] <= 0;
        spc_regs[7] <= 0;
    end

    always @(wr_pc_data) begin
        spc_regs[6] = wr_pc_data;
    end

    always @(posedge clk) begin                                        // static design controlled by rising clock edge
        if (wr_zr == 1) begin
            spc_regs[0] = wr_zr_data;
        end
        if (wr_r1 == 1) begin
            spc_regs[1] = wr_r1_data;
        end
        if (wr_r2 == 1) begin
            spc_regs[2] = wr_r2_data;
        end
        if (wr_r3 == 1) begin
            spc_regs[3] = wr_r3_data;
        end
        if (wr_sp == 1) begin
            spc_regs[4] = wr_sp_data;
        end
        if (wr_lr == 1) begin
            spc_regs[5] = wr_lr_data;
        end
        if (wr_pc == 1) begin
            spc_regs[6] = wr_pc_data;
        end
        if (wr_cpsr == 1) begin
            spc_regs[7] = wr_cpsr_data;
        end

        if (wr_usr_enable == 1) begin
            spc_regs[write_usr_addr] = usr_data;
        end 

    end    

endmodule

