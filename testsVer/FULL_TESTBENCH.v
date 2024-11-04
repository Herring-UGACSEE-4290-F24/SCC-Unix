`timescale 1ns/1ns

module FULL_TESTBENCH();

    reg  clk_s, reset_s;
    wire in_mem_en_s, data_read_s, data_write_s;
    wire [31:0] in_mem_s; 
    wire [31:0] data_in_s;
    wire [31:0] in_mem_addr_s; 
    wire [31:0] data_addr_s; 
    wire [31:0] data_out_s;

    SCC unixSCC(.clk(clk_s), 
                .reset_s(reset_s), 
                .in_mem(in_mem_s), 
                .data_in(data_in_s), 
                .in_mem_addr(in_mem_addr_s), 
                .in_mem_en(in_mem_en_s), 
                .data_addr(data_addr_s), 
                .data_out(data_out_s), 
                .data_read(data_read_s), 
                .data_write(data_write_s));

    Instruction_and_data IMandDM(.mem_Clk(clk_s), 
                                 .instruction_memory_en(in_mem_en_s), 
                                 .instruction_memory_a(in_mem_addr_s), 
                                 .data_memory_a(data_addr_s), 
                                 .data_memory_read(data_read_s), 
                                 .data_memory_write(data_write_s), 
                                 .data_memory_out_v(data_out_s), 
                                 .instruction_memory_v(in_mem_s), 
                                 .data_memory_in_v(data_in_s));

    always begin
        clk_s = 0;
        #10;
        clk_s = 1;
        #10;
    end

    initial begin
        $dumpvars(0, FULL_TESTBENCH);
        reset_s = 1;
        #10 reset_s = 0;
        #1000;
        $finish;
    end
endmodule
