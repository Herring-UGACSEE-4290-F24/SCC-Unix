/*
 * This module defines the Instruction Fetch (IF) implementation by the Linux SCC group. IF keeps track
 * of the program counter (PC) which points to a word address in Instruction Memory (IM). 
 */
module IF(clk, b_relAddr, b_cond, instruction_in, instruction_out, pc);

    input               clk;             // Clock signal
    input               b_cond;          // Branch Condition StatusS
    input [15:0]        b_relAddr;       // Amount to branch relative to current PC

    input [31:0]	    instruction_in;  // Retrieved from Instruction Memory
    output [31:0]       instruction_out; // Passing onto Instruction Decode

    output reg [31:0]   pc;              // Program Counter: points to an address in instruction memory

    reg [31:0]          offset;          // Amount to adjust the pc

    parameter NOP = 'hC8000000;          // 11001000...

    always @(posedge clk) begin

        if (instruction_in[31:25] == 'b1100000) begin            // B instruction
            offset[31:16] = {16{instruction_in[15]}};            // Duplicates the msb (sign extension)
            offset[15:0] = instruction_in[15:0];                 // Copying the immediate value
            offset = offset * 4 ;                                 // Left shifts (4 byte alligned)
            pc <= pc + offset;                                   // adds the offset to the pc
            instruction_out <= NOP;                              // NOPs the instruction that would be executed
        end else if (instruction_in[31:25] == 'b1100010) begin   // BR instruction
            // NEED TO CHECK: if the register being jumped to is being UPDATED in the instruction currently being executed
            // -> just grab the value 
            // EX: ADDS R0, R0, 1
            //     BR R0
            // Allowed to have more than 2 ports of reading on the register file
            pc <=                                                // change to address in  +/- the offset
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
