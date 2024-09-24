module SCC_Wrapper ()
begin

    // Outer layer 
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

    // Inner layer 
    output          scc_clk;            // main clock signal
    output          scc_reset;           // sets all regs to known state
    output [31:0]   scc_in_mem;          // instructions being fetched
    output [31:0]   scc_data_in;         // data read from memory

    input [31:0]    scc_in_mem_addr;     // address pointed to in instruction memory
    input           scc_in_mem_en;       // enable instruction memory fetch
    input [31:0]    scc_data_addr;       // address pointed to in data memory
    input [31:0]    scc_data_out;        // data to write to memory
    input           scc_data_read;       // control reading data
    input           scc_data_write;      // control writing data

    assign clk0 = clk;

end