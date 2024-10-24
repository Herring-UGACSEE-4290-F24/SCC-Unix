module NormalRegs(read_addr1, read_addr2, br_addr, write_addr, write_value_alu, write_value_id, write_data_sel, write_enable, clk, value1, value2, br_value);

    input [2:0] read_addr1, read_addr2;     // Two ports for reading from registers (3 bits to address 8 registers)
    input [2:0] br_addr;                    // Register accessed by a BR instruction (3 bits to address 8 regs)
    input [2:0] write_addr;                 // One port to write to a register (3 bits to address 8 regs)
    input [31:0] write_value_alu;           // Value from the ALU to be written to register pointed at by write_addr 
    input [31:0] write_value_id;            // Value from the ID to be written to register pointed at by write_addr
    input write_data_sel;                   // Determines which value is being used to write to regs (1 bit, choose ALU or ID)
    input write_enable;                     // Enable the writing of write_value to write_addr

    input clk;                              // Static design requires a clock

    output wire [31:0] value1, value2;      // Values retrieved from registers at read_addr1 and read_addr2
    output wire [31:0] br_value;            // Value for the BR instruction to branch to    

    reg [31:0] registers [0:7];             // Actual register layout (8 registers that are 32 bits long)

    assign value1 = registers[read_addr1];  // Read value in register pointed at by read_addr1
    assign value2 = registers[read_addr2];  // Read value in register pointed at by read_addr2
    assign br_value = registers[br_addr];   // Read value in register pointed at by br_addr

   
    initial begin                                          // used for testbenching
        $dumpvars(0, registers[0], registers[1], registers[2], registers[3], registers[4], registers[5], registers[6], registers[7]); 
    end

    always @(posedge clk) begin                            // static design (controlled by clk)

        if (write_enable) begin                            // When the write_enable is HIGH

            if (write_data_sel) begin                      // Chooses if data comes from ALU or ID
                registers[write_addr] <= write_value_alu;  // Store write_value_alu in register at address write_addr
            end else begin
                registers[write_addr] <= write_value_id;   // Store write_value_id in register at address write_addr
            end
            
        end

    end

endmodule