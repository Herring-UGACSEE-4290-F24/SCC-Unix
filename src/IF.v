/*
 * This module defines the Instruction Fetch (IF) implementation by the Linux SCC group. IF keeps track
 * of the program counter (PC) which points to a word address in Instruction Memory (IM). 
 */
module IF(clk, reset, br_value, instruction_in, instruction_out, br_addr, re_pc_val, wr_pc_val, wr_pc, br_pc_val, branch);

    input               clk;                // Clock signal
    input               reset;              // Reset signal

    input [31:0]        br_value;           // Value retrieved from register pointed to by br_addr

    input [31:0]	    instruction_in;     // Retrieved from Instruction Memory
    output reg [31:0]   instruction_out;    // Passing onto Instruction Decode

    output reg [2:0]    br_addr;            // Address of register containing the value to branch to
    input [31:0]        re_pc_val;          // Reads in the pc from the special registers
    output reg [31:0]   wr_pc_val = 32'b0;  // Program Counter: points to an address in instruction memory
    output reg          wr_pc = 1;          // Enables writing to the PC register (in special regs)
    output reg [31:0]   br_pc_val;          // Value to write to PC on branch 
    input               branch;             // if a cond branch is being taken

    reg [31:0]          offset;             // Amount to adjust the pc
    reg [31:0]          prefetch;           // Prefetching registers

    always @(reset) begin
        prefetch = 32'bx;
        instruction_out = 32'bx;
    end

    always @(posedge clk) begin
        instruction_out = prefetch;
        prefetch = instruction_in;
        if ((instruction_in[31:25] != 7'b1100000) && (instruction_in[31:25] != 7'b1100010) && (instruction_out[31:25] != 7'b1100001)) begin
            wr_pc_val = re_pc_val + 4;              // Increment the PC (4 byte alligned)
        end
        if (instruction_out[31:25] == 7'b1100001 && branch == 1) begin
            prefetch = 'hC8000000;                  // Replace with NOP to prevent broken next instructions
        end
    end

    always @(instruction_in) begin

    // FOR HANDLING THE IMMEDIATE/OFFSET FIELD IN B and BR //
    // =================================================== //
    // This will grab the lower 16 bits of the instruction //
    // and sign-extend AND bit shift left by 2 so that the //
    // value can be applied to the branch instructions.    //
    // - - - - - - - - - - - - - - - - - - - - - - - - - - //
        offset[31:16] = {16{instruction_in[15]}};          // Duplicates the msb (sign extension)
        offset[15:0] = instruction_in[15:0];               // Copying the immediate value
    // =================================================== //

    // FOR HANDLING BRANCHES THAT ARE UNCONDITIONAL //
    // ============================================ //
    // The B instructions will need to add or sub   //
    // from the current program counter value while //
    // BR will need to access the registers through //
    // using the inputs/outputs on the module.      //
    // ============================================ //

    // FOR HANDLING CONDITIONAL AND NON BRANCH INSTRUCTIONS //
    // ==================================================== //
    // The instructions that are conditional branches will  //
    // be passed through and handled by the ID, but the pc  //
    // will get updated through a signal sent to the IF by  //
    // the ID, and will then update the value based on the  //
    // value in the instruction. All other instruction will //
    // implement the pc as normal, 4 bytes per instruction. //
    // ==================================================== //

        if (instruction_in[31:25] == 7'b1100000) begin

            if (prefetch[31:25] == 7'b1100001) begin
                
            end else begin
                br_pc_val = re_pc_val + offset;         // Update the pc based on the instruction's offset
            end

        end else if (instruction_in[31:25] == 7'b1100010) begin

            if (prefetch [31:25] == 7'b1100001) begin

            end else begin
                br_addr = instruction_in[24:22];        // Uses bitfield to fetch address of register
                br_pc_val = br_value + offset;          // Update pc to address in the register pointed to by br_addr +/- the offset
            end

        end
        br_pc_val[1:0] = 'b00;                      // Ensures 4 bytes alignment

    end

endmodule