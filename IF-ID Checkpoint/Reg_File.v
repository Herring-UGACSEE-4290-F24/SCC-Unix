module Reg_File(read_addr1, read_addr2, br_addr, write_addr, write_value, write_enable, clk, value1, value2, br_value);

    input [2:0] read_addr1, read_addr2;     // Two ports for reading from registers
    input [2:0] br_addr;                    // Register accessed by a BR instruction
    input [2:0] write_addr;                 // One port to write to a register
    input [31:0] write_value;               // Value to be written to register pointed at by write_addr
    input write_enable;                     // Enable the writing of write_value to write_addr

    input clk;                              // Static design requires a clock

    output reg [31:0] value1, value2;       // Values retrieved from registers at read_addr1 and read_addr2
    output reg [31:0] br_value;             // Value for the BR instruction to branch to    

    reg [31:0] registers [0:7];             // Acutal register layout (8 registers that are 32 bits long)

    always @(posedge clk) begin

        value1 <= registers[read_addr1];           // Read value in register pointed at by read_addr1
        value2 <= registers[read_addr2];           // Read value in register pointed at by read_addr2

        if (write_enable) begin                    // When the write_enable is HIGH
            registers[write_addr] <= write_value;  // Store write_value in register at address write_addr
        end

    end

endmodule

/*
 * Reg 7 in the user accessible will be the Zero Register
 * 
 * Separate registers for reserved (8 new regs) NOT USER ACCESSIBLE
 * Reg 7 should be CPSR -> (Formatted as ARMv8 is)
 * Reg 6 will be pc
 */