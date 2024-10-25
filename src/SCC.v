module SCC(clk, reset, in_mem, data_in, in_mem_addr, in_mem_en, data_addr, data_out, data_read, data_write);

    input           clk;             // main clock signal
    input           reset;           // sets all regs to known state
    input [31:0]    in_mem;          // instructions being fetched
    input [31:0]    data_in;         // data read from memory

    output wire [31:0]   in_mem_addr;     // address pointed to in instruction memory
    output wire          in_mem_en;       // enable instruction memory fetch
    output wire [31:0]   data_addr;       // address pointed to in data memory
    output wire [31:0]   data_out;        // data to write to memory
    output wire          data_read;       // control reading data
    output wire          data_write;      // control writing data

    wire func_clk, reset_s, regWrite, regAddr, branchValue, instruction, branchAddress, pc_val;

    assign func_clk = clk & ~halt;

    IF instructionFetch(.clk(func_clk), 
                        .reset(reset_s),  
                        .br_value(branchValue), 
                        .instruction_in(in_mem), 
                        .instruction_out(instruction), 
                        .br_addr(branchAddress), 
                        .re_pc_val(pc_val), 
                        .wr_pc_val(new_pc_val), 
                        .wr_pc(write_pc));

    ID instructionDecode(.instruction(instruction), 
                         .reset(reset_s), 
                         .halt_flag(), 
                         .read_addr1(), 
                         .read_addr2(), 
                         .reg1_val(), 
                         .write_addr(regAddr), 
                         .write_data(), 
                         .write_data_sel(), 
                         .write_enable(regWrite), 
                         .wr_cpsr(), 
                         .data_addr(), 
                         .data_read(), 
                         .data_out(), 
                         .opcode(), 
                         .operand2(), 
                         .ir_op(), 
                         .re_cpsr_val(), 
                         .re_cpsr_val(), 
                         .re_pc_val(pc_val), 
                         .wr_pc_val(), 
                         .wr_pc(), 
                         .pc_mux());

    EXE executeModule(.reg1_val(), 
                      .reg2_val(), 
                      .immediate(), 
                      .alu_oc(), 
                      .ir_op(), 
                      .result(), 
                      .wr_cpsr_val());

    NormalRegs normalRegisterFile(.reset(reset_s), 
                                  .read_addr1(), 
                                  .read_addr2(), 
                                  .br_addr(branchAddress), 
                                  .write_addr(regAddr), 
                                  .write_value_alu(), 
                                  .write_value_id(), 
                                  .write_data_sel(), 
                                  .write_enable(regWrite), 
                                  .clk(func_clk), 
                                  .reg1_val(), 
                                  .reg2_val(), 
                                  .br_value(branchValue));

    SpecialRegs specialRegisterFile(.reset(reset_s), 
                                    .usr_data(), 
                                    .wr_zr_data(), 
                                    .wr_r1_data(), 
                                    .wr_r2_data(), 
                                    .wr_r3_data(), 
                                    .wr_sp_data(), 
                                    .wr_lr_data(), 
                                    .wr_pc_data(new_pc_val), 
                                    .wr_cpsr_data(), 
                                    .wr_usr_enable(), 
                                    .wr_zr(), 
                                    .wr_r1(), 
                                    .wr_r2(), 
                                    .wr_r3(), 
                                    .wr_sp(), 
                                    .wr_lr(), 
                                    .wr_pc(write_pc), 
                                    .wr_cpsr(), 
                                    .write_usr_addr(), 
                                    .read_usr_addr(), 
                                    .clk(func_clk), 
                                    .re_zr(), 
                                    .re_r1(), 
                                    .re_r2(), 
                                    .re_r3(), 
                                    .re_sp(), 
                                    .re_lr(), 
                                    .re_pc(pc_val), 
                                    .re_cpsr(), 
                                    .re_usr());

endmodule