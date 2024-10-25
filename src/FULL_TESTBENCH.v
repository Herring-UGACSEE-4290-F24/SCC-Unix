module FULL_TESTBENCH();

    reg clk_s, reset_s;
    wire in_mem_s, data_in_s, in_mem_addr_s, in_mem_en_s, data_addr_s, data_out_s, data_read_s, data_write_s;

    SCC unixSCC(.clk(clk_s), .reset(reset_s), .in_mem(in_mem_s), .data_in(data_in_s), .in_mem_addr(in_mem_addr_s), .in_mem_en(in_mem_en_s), .data_addr(data_addr_s), .data_out(data_out_s), .data_read(data_read_s), .data_write(data_write_s));
    Instruction_and_data IMandDM(.mem_Clk(clk_s), .instruction_memory_en(in_mem_en_s), .instruction_memory_a(in_mem_addr_s), .data_memory_a(data_addr_s), .data_memory_read(data_read_s), .data_memory_write(data_write_s), .data_memory_out_v(data_out_s), .instruction_memory_v(in_mem_s), .data_memory_in_v(data_in_s));

    always begin
        clk_s = 0;
        #10;
        clk_s = 1;
        #10;
    end

    initial begin
        @(posedge clk_s)
        @(posedge clk_s)
        @(posedge clk_s)
        @(posedge clk_s)
        @(posedge clk_s)
        @(posedge clk_s)
        @(posedge clk_s)
        @(posedge clk_s)
        @(posedge clk_s)
        @(posedge clk_s)
        @(posedge clk_s)
        @(posedge clk_s)
        @(posedge clk_s)
        @(posedge clk_s)
        @(posedge clk_s)
        @(posedge clk_s)
        @(posedge clk_s)
        @(posedge clk_s)
        @(posedge clk_s)
        @(posedge clk_s)
        @(posedge clk_s)
        @(posedge clk_s)
        @(posedge clk_s)
        @(posedge clk_s)
        @(posedge clk_s)
        @(posedge clk_s)
        @(posedge clk_s)
        @(posedge clk_s)
        @(posedge clk_s)
    end
endmodule