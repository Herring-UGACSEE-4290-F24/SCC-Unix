module SCC(clk, reset, in_mem, data_in, in_mem_addr, in_mem_en, data_addr, data_out, data_read, data_write);

    input           clk;             // main clock signal
    input           reset;           // sets all regs to known state
    input [31:0]    in_mem;          // instructions being fetched
    input [31:0]    data_in;         // data read from memory

    output [31:0]   in_mem_addr;     // address pointed to in instruction memory
    output          in_mem_en;       // enable instruction memory fetch
    output [31:0]   data_addr;       // address pointed to in data memory
    output [31:0]   data_out;        // data to write to memory
    output          data_read;       // control reading data
    output          data_write;      // control writing data

endmodule