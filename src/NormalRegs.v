module NormalRegs(reset, read_addr1, read_addr2, br_addr, write_addr, write_value_alu, write_value_id, write_data_sel, write_enable, clk, reg1_val, reg2_val, br_value);

    input reset;                            // Resets the values in the registers to zero
    input [2:0] read_addr1, read_addr2;     // Two ports for reading from registers (3 bits to address 8 registers)
    input [2:0] br_addr;                    // Register accessed by a BR instruction (3 bits to address 8 regs)
    input [2:0] write_addr;                 // One port to write to a register (3 bits to address 8 regs)
    input [31:0] write_value_alu;           // Value from the ALU to be written to register pointed at by write_addr 
    input [31:0] write_value_id;            // Value from the ID to be written to register pointed at by write_addr
    input write_data_sel;                   // Determines which value is being used to write to regs (1 bit, choose ALU or ID)
    input write_enable;                     // Enable the writing of write_value to write_addr

    input clk;                              // Static design requires a clock

    output wire [31:0] reg1_val, reg2_val;  // Values retrieved from registers at read_addr1 and read_addr2
    output wire [31:0] br_value;            // Value for the BR instruction to branch to    

    reg [31:0] nor_regs [0:7];              // Actual register layout (8 registers that are 32 bits long)

    assign reg1_val = nor_regs[read_addr1]; // Read value in register pointed at by read_addr1
    assign reg2_val = nor_regs[read_addr2]; // Read value in register pointed at by read_addr2
   
    initial begin                                          // used for testbenching
        $dumpvars(0, nor_regs[0], nor_regs[1], nor_regs[2], nor_regs[3], nor_regs[4], nor_regs[5], nor_regs[6], nor_regs[7]); 
    end

    always @(reset) begin
        nor_regs[0] <= 0;
        nor_regs[1] <= 0;
        nor_regs[2] <= 0;
        nor_regs[3] <= 0;
        nor_regs[4] <= 0;
        nor_regs[5] <= 0;
        nor_regs[6] <= 0;
        nor_regs[7] <= 0;
    end

    always @(posedge clk) begin                            // static design (controlled by clk)

        if (write_enable) begin                            // When the write_enable is HIGH

            if (write_data_sel) begin                      // Chooses if data comes from ALU or ID
                nor_regs[write_addr] = write_value_alu;    // Store write_value_alu in register at address write_addr
            end else begin
                nor_regs[write_addr] = write_value_id;     // Store write_value_id in register at address write_addr
            end
            
        end

        br_value = nor_regs[br_addr];                      // Read value in register pointed at by br_addr

    end

endmodule