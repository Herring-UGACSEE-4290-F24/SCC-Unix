/*
 * This module defines the Instruction Fetch (IF) implementation by the Linux SCC group. IF keeps track
 * of the program counter (PC) which points to a word address in Instruction Memory (IM). 
 */
module IF(clk, b_relAddr, b_cond, offset, instruction_in, instruction_out, pc);

    input               clk;             // Clock signal
    input               b_cond;          // Branch Condition StatusS
    input [15:0]        b_relAddr;       // Amount to branch relative to current PC
    input [31:0]        b_absAddr;       // Address to branch to on absolute branch (to value in register)
    input [15:0]        offset;          // Optional offset for the branch address

    input [31:0]	instruction_in;  // Retrieved from Instruction Memory
    output [31:0]       instruction_out; // Passing onto Instruction Decode

    output reg [31:0]   pc;             // Program Counter: points to an address in instruction memory

    always @(posedge clk) begin

        if (instruction_in[31:25] == 'b1100000) begin            // B instruction
            pc <= pc + instruction_in[15:0];                     // make sure is signed and adds correctly etc (sign extend?)
            instruction_out <= NOP;
        end else if (instruction_in[31:25] == 'b1100010) begin   // BR instruction
            pc <=                                                // change to address in register
            instruction_out <= NOP;
        end else begin                                           // When not a branch instruction
            instruction_out <= instruction_in;                   // Pass instruction through to ID component
            if (b_cond)                                          // If conditional branch is decoded
            begin
                pc <= pc + (4 * b_relAddr);                          // Branch according to the conditional branch statement
            end else
            begin
                pc <= pc + 4;                                        // Otherwise, increment the PC
            end
        end 

    end

endmodule
