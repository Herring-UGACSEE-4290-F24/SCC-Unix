module FULL_TESTBENCH();


    
    Instruction_and_data IMandDM(.mem_Clk(), .instruction_memory_en(), .instruction_memory_a(), .data_memory_a(), .data_memory_read(), .data_memory_write(), .data_memory_out_v(), .instruction_memory_v(), .data_memory_in_v());

endmodule