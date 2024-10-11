module EXE();

    reg [31:0] op1, op2;

    ALU alu1();

    always @(posedge clk)
    begin

        op1 <= operand1;
        if (ir_op) 
        begin
            op2 <= i_operand2;
        end else
        begin
            op2 <= r_operand2;
        end

    end

endmodule