module DM_tb();

reg clk_s, reset_s, MemWrite_s, MemRead_s;
reg [31:0] write_address_s, read_address_s, Write_data_s;

wire [31:0] MemData_out_s;

Data_Memory CompToTest (
    clk_s, 
    reset_s, 
    MemWrite_s, 
    MemRead_s, 
    write_address_s,
    read_address_s, 
    Write_data_s, 
    MemData_out_s
);

always begin
    clk_s <= 0;
    #10;
    clk_s <= 1;
    #10;
end

initial begin
    //$dumpfile("dump.vcd");
    $dumpvars(0, DM_tb);
    reset_s <= 0;  // Deassert reset initially
    @(posedge clk_s);
    @(posedge clk_s);

    reset_s <= 1;  // Assert reset for two cycles
    @(posedge clk_s);
    @(posedge clk_s);
    reset_s <= 0;  // Deassert reset

    // Write operation
    MemRead_s <= 0;
    MemWrite_s <= 1;
    write_address <= 3;
    read_address_s <= 3;         // Address 3
    Write_data_s <= 32'hFFFFFFFF; // Write all 1's to address 3
    @(posedge clk_s);

    // Disable write and enable read
    MemWrite_s <= 0;
    MemRead_s <= 1;
    @(posedge clk_s);

    #500;
    $finish;
end

endmodule