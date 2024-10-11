module EXE(value1, value2, immediate, ir_op, result);

    input [31:0]        value1, value2, immediate; 
    input               ir_op;
    output reg [31:0]   result;

    reg [31:0]          op2;
    ALU alu1();

    always @(posedge clk)
    begin

        if (ir_op)              // Loads immediate into the ALU on 0, and the register value on 1
        begin
            op2 <= value2;      // Loading value returned by Registers
        end else
        begin
            op2 <= immediate;   // Loading immediate value from ID
        end

    end

endmodule