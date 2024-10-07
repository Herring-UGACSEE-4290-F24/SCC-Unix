/*
 * This module defines the Instruction Fetch (IF) implementation by the Linux SCC group. IF keeps track
 * of the program counter (PC) which points to a word address in Instruction Memory (IM). 
 */
module IF(clk, b_relAddr, b_absAddr, b_cond, b_abs, offset, instruction_in, instruction_out, pc);

    input               clk;            // Clock signal
    input               b_cond;         // Branch Condition Status
    input               b_abs;          // Branch is Absolute or not, i.e. branch to target addr
    input [15:0]        b_relAddr;      // Amount to branch relative to current PC
    input [31:0]        b_absAddr;      // Address to branch to on absolute branch (to value in register)
    input [15:0]        offset;         // Optional offset for the branch address

    input [31:0] instruction_in;
    output [31:0] instruction_out;

    output reg [31:0]   pc;             // Program Counter: points to an address in instruction memory

    always @(posedge clk)               // Ensures that PC only changes on rising clock edge
    begin

        if (b_cond)                        // check if branch condition is met i.e. the b_cond flag is set by execution stage
        begin
            if (b_abs)                     // check if absolute  branch
            begin
                pc = b_absAddr + offset;   // if abs branch, then set pc = target address
            end else                       // else, then relative branch
            begin
                pc = pc + (4 * b_relAddr); // relative address is shifted left by 2 bits and pc is set to this value
            end
        end else                           // branch condition not met i.e. no branch
        begin
            pc = pc + 4;                   // incrementing, pc by 4 bytes 
        end

    end

endmodule 

// Change to the other layout, where instructions are returned back to here, the IF

// Then we can check for unconditional branches, and immediately handle them so that ID doesn't see a b
// Won't need the b_abs boolean because the conditional branches can't be absolute