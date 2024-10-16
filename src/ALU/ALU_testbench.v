module ALU_testbench();

reg [31:0] operand1_s, operand2_s;
wire [32:0] result_s;
reg clk_s, rst_s, en_s;
wire overflow_s;
reg [2:0] opcode_s;

ALU CompToTest(operand1_s, operand2_s, opcode_s, clk_s, rst_s, en_s, result_s, overflow_s);

always begin
    clk_s <= 0;
    #10;
    clk_s <= 1;
    #10;
end

initial begin
    $dumpvars(0, ALU_testbench);

    rst_s <= 1;
    operand1_s <= 0;
    operand2_s <= 0;
    en_s <= 0;
    opcode_s <= 0;

    @(posedge clk_s)

    rst_s <= 0;

    @(posedge clk_s)
    @(posedge clk_s)

    operand1_s <= 32'hFFFFFFFF;
    operand2_s <= 32'hFFFFFFFF;
    opcode_s <= 3'b001;

    en_s <= 1;

    @(posedge clk_s)


    #100;
    $finish;
end

endmodule