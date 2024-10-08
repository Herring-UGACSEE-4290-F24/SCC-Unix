module Reg_File(read_addr1, read_addr2, write_addr, write_value, write_enable, clk, value1, value2);

    input [2:0] read_addr1, read_addr2;
    input [2:0] write_addr;
    input [31:0] write_value;
    input write_enable;

    input clk;

    output [31:0] value1, value2;

    reg [2:0] registers [31:0];

    always @(posedge clk) begin

        value1 <= registers[read_addr1];
        value2 <= registers[read_addr2];

        if (write_enable) begin
            registers[write_addr] <= write_value
        end

    end

endmodule