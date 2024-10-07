module Reg_File()

    reg [2:0] registers [31:0];
    input [2:0] in_addr;
    input clk;

    output [31:0] out;

    always @(posedge clk) begin

        out <= registers[in_addr];

    end

endmodule