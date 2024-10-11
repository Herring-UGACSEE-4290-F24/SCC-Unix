`timescale 1ns/1ns

module IF_tb();
    /*
     * defining inputs
    */
    reg clk_s;
    reg [31:0] instruction_in_s;
    reg [31:0] br_value_s;

    /*
     * defining outputs
    */
    wire [31:0] instruction_out_s;      // instruction out (32 bits)
    wire [2:0]  br_addr_s;             // address of register to branch to
    wire [31:0] pc_s;                   // program counter (32 bits)
 
    IF dut (                    // instantiating module
        .clk (clk_s),   
        .br_value (br_value_s),                
        .instruction_in (instruction_in_s),         
        .instruction_out (instruction_out_s),
        .br_addr (br_addr_s),
        .pc (pc_s)

    );

    always begin                        // creating clock with period of 20ns
        clk_s = 0;
        #10;
        clk_s = 1;
        #10;
    end

    /*
     * Beginning of testbench. To test IF, the instructions must be manually encoded.
     * ----------------------------------------------------------------------------------------
     * Test Cases :
     *      1 : NOP                       -->  instruction_out = all X's (unitialized), PC = 0
     *      2 : instruction_in = all 1's  -->  instruction_out = NOP, PC = 4
     *      3 : instruction_in = all 0's  -->  instruction_out = 1's, PC = 8
     *      4 : B 5                       -->  instruction_out = all 0's, PC = 8 + (5 * 4) = 28
     *      5 : 0x8000_0001               -->  instruction_out = NOP, PC = 32
     *      6 : BR [br_value == 9]        -->  instruction_out = 0x8000_0001, PC = 9
     *      7 : 0x1100_1100               -->  instruction_out = NOP, PC = 13
     *
     *      Reference for Encoding: 
     *      ---------------------------- 
     *       B   : [ 1 1 0 0 0 0 0  0xC0000005 ]
     *       BR  : [ 1 1 0 0 0 1 0  0xC4000000 ]
     *       NOP : [ 1 1 0 0 1 0 0  0xC8000000 ]
     *
     */
    initial begin
        $dumpvars(0, IF_tb);

        @(posedge clk_s);                   // 1
        #5 instruction_in_s = 'hC800_0000;

        @(posedge clk_s);
        #5 instruction_in_s = 'hFFFF_FFFF;    // 2

        @(posedge clk_s);
        #5 instruction_in_s = 'h0000_0000;    // 3

        @(posedge clk_s);
        #5 instruction_in_s = 'hC000_0005;    // 4

        @(posedge clk_s);
        #5 instruction_in_s = 'h8000_0001;    // 5

        @(posedge clk_s);                   // 6
        #5 br_value_s = 'h0000_0009;
        instruction_in_s = 'hC400_0000;

        @(posedge clk_s);                   // 7
        #5 instruction_in_s = 'h1100_1100;

        @(posedge clk_s);
        @(posedge clk_s);
        @(posedge clk_s);
        @(posedge clk_s);

        $finish;

    end

endmodule