/*
 * This module defines the Instruction Fetch (IF) implementation by the Linux SCC group. IF keeps track
 * of the program counter (PC) which points to a word address in Instruction Memory (IM). 
 */
module IF(clk, b_cond, b_relAddr, write_enable, write_addr, write_value, br_value, instruction_in, instruction_out, br_addr, pc);

    input               clk;             // Clock signal
    input               b_cond;          // Branch Condition StatusS
    input [15:0]        b_relAddr;       // Amount to branch relative to current PC

    input               write_enable;    // Signal sent from ID when the register files are being written to
    input [2:0]         write_addr;      // Address in register file being written to 
    input [31:0]        write_value;     // Value being written to the register file

    input [31:0]        br_value;        // Value retrieved from register pointed to by br_addr

    input [31:0]	    instruction_in;  // Retrieved from Instruction Memory
    output reg [31:0]   instruction_out; // Passing onto Instruction Decode

    output reg [2:0]    br_addr;         // Address of register containing the value to branch to
    output reg [31:0]   pc;              // Program Counter: points to an address in instruction memory

    reg [31:0]          offset;          // Amount to adjust the pc
    reg [31:0]          prefetch;        // Prefetching registers

    parameter NOP = 'hC8000000;          // 11001000...

    always @(posedge clk) begin

    // FOR HANDLING THE IMMEDIATE/OFFSET FIELD IN B and BR //
    // =================================================== //
    // This will grab the lower 16 bits of the instruction //
    // and sign-extend AND bit shift left by 2 so that the //
    // value can be applied to the branch instructions.    //
    // - - - - - - - - - - - - - - - - - - - - - - - - - - //
        offset[31:16] = {16{instruction_in[15]}};          // Duplicates the msb (sign extension)
        offset[15:0] = instruction_in[15:0];               // Copying the immediate value
        offset = offset * 4 ;                              // Left shifts (4 byte alligned)
    // =================================================== //

    // FOR HANDLING BRANCHES THAT ARE UNCONDITIONAL //
    // ============================================ //
    // The B instructions will need to add or sub   //
    // from the current program counter value while //
    // BR will need to access the registers through //
    // using the inputs/outputs on the module.      //
    // - - - - - - - - - - - - - - - - - - - - - -  //
        if (instruction_in[31:25] == 'b1100000)                 // B instruction //
        begin

            instruction_out = prefetch;         // Feeds the prefetched instruction to the ID
            prefetch = NOP;                     // Stores a NOP as the prefetched instruction
            pc <= pc + offset;                  // update the pc based on the instruction's offset

        end else if (instruction_in[31:25] == 'b1100010)        // BR instruction //
        begin

            instruction_out = prefetch;         // Feeds the prefetched instruction to the ID
            prefetch = NOP;                     // Stores a NOP as the prefetched instruction
            br_addr = instruction_in[24:22];    // Uses bitfield to fetch address of register

            // If the registers are being written to, and the register being accessed is the target //
            if (write_enable && br_addr == write_addr) begin
                pc <= write_value + offset;     // Update pc to the value being written +/- the offset
            end else begin                      // Otherwise, there is no hazard is accessing a value to read
                pc <= br_value + offset;        // Update pc to address in the register pointed to by br_addr +/- the offset
            end
    // ============================================ //

    // FOR HANDLING CONDITIONAL AND NON BRANCH INSTRUCTIONS //
    // ==================================================== //
    // The instructions that are conditional branches will  //
    // be passed through and handled by the ID, but the pc  //
    // will get updated through a signal sent to the IF by  //
    // the ID, and will then update the value based on the  //
    // value in the instruction. All other instruction will //
    // implement the pc as normal, 4 bytes per instruction. //
    // - - - - - - - - - - - - - - - - - - - - - - - - - -  //
        end else                                                // Not B or BR // 
        begin

            instruction_out = prefetch;         // Feeds the prefetched instruction to the ID
            prefetch = instruction_in;          // Prefetches the next instruction from IM
            if (b_cond)                         // If conditional branch is decoded AND taken (signal sent from ID)
            begin
                pc <= pc + (4 * b_relAddr);     // Branch according to the conditional branch statement
            end else
            begin                               // Otherwise, no branches are being taken
                pc <= pc + 4;                   // Increment the PC (4 byte alligned)
            end

        end 

    end
    // ==================================================== //

endmodule
