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

    wire func_clk, reset_s, regWrite, regAddr, branchValue, instruction, branchAddress, new_pc_val, write_pc_s, if_write_pc, id_write_pc, read_addr1_s, read_addr2_s, reg1_val_s, reg_data, reg_data_sel, alu_op_s, in_reg_s, op2_s, alu_result, new_cpsr_val, wr_cpsr_s;

    assign func_clk = clk & ~halt;
    assign new_pc_val = if_pc_val | id_pc_val;
    assign write_pc_s = if_write_pc | id_write_pc;
    assign in_mem_en = 1;

    IF instructionFetch(.clk(func_clk), 
                        .reset(reset_s),  
                        .br_value(branchValue), 
                        .instruction_in(in_mem), 
                        .instruction_out(instruction), 
                        .br_addr(branchAddress), 
                        .re_pc_val(in_mem_addr), 
                        .wr_pc_val(if_pc_val), 
                        .wr_pc(if_write_pc));

    ID instructionDecode(.instruction(instruction), 
                         .reset(reset_s), 
                         .halt_flag(halt), 
                         .read_addr1(read_addr1_s), 
                         .read_addr2(read_addr2_s), 
                         .reg1_val(reg1_val_s), 
                         .write_addr(regAddr), 
                         .write_data(reg_data), 
                         .write_data_sel(reg_data_sel), 
                         .write_enable(regWrite), 
                         .wr_cpsr(wr_cpsr_s), 
                         .data_addr(data_addr),
                         .data_val(data_in), 
                         .data_read(data_read),
                         .data_write(data_write), 
                         .data_out(data_out), 
                         .opcode(alu_op_s), 
                         .operand2(op2_s), 
                         .ir_op(in_reg_s), 
                         .re_cpsr_val(cpsr_val),  
                         .re_pc_val(pc_val), 
                         .wr_pc_val(id_pc_val), 
                         .wr_pc(id_write_pc));

    EXE executeModule(.reg1_val(reg1_val_s), 
                      .reg2_val(reg2_val_s), 
                      .immediate(op2_s), 
                      .alu_oc(alu_op_s), 
                      .ir_op(in_reg_s), 
                      .result(alu_result), 
                      .wr_cpsr_val(new_cpsr_val));

    NormalRegs normalRegisterFile(.reset(reset_s), 
                                  .read_addr1(read_addr1_s), 
                                  .read_addr2(read_addr2_s), 
                                  .br_addr(branchAddress), 
                                  .write_addr(regAddr), 
                                  .write_value_alu(alu_result), 
                                  .write_value_id(reg_data), 
                                  .write_data_sel(reg_data_sel), 
                                  .write_enable(regWrite), 
                                  .clk(func_clk), 
                                  .reg1_val(reg1_val_s), 
                                  .reg2_val(reg2_val_s), 
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
                                    .wr_cpsr_data(new_cpsr_val), 
                                    .wr_usr_enable(), 
                                    .wr_zr(), 
                                    .wr_r1(), 
                                    .wr_r2(), 
                                    .wr_r3(), 
                                    .wr_sp(), 
                                    .wr_lr(), 
                                    .wr_pc(write_pc_s), 
                                    .wr_cpsr(wr_cpsr_s), 
                                    .write_usr_addr(), 
                                    .read_usr_addr(), 
                                    .clk(func_clk), 
                                    .re_zr(), 
                                    .re_r1(), 
                                    .re_r2(), 
                                    .re_r3(), 
                                    .re_sp(), 
                                    .re_lr(), 
                                    .re_pc(in_mem_addr), 
                                    .re_cpsr(cpsr_val), 
                                    .re_usr());

endmodule