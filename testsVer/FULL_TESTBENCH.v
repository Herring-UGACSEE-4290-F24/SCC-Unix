`timescale 1ns/1ns

module FULL_TESTBENCH();

    reg  clk_s, reset_s;

    SCC unixSCC(.clk(clk_s), 
                .reset_s(reset_s));

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
