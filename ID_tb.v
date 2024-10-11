`timescale 1ns/1ns

module Testbench();

    always begin
        clk = 0;
        #10;
        clk = 1;
        #10;
    end

    initial begin
        
    end

endmodule