module EXE(value1, value2, immediate, alu_oc, ir_op, result, wr_cpsr_val);

    input [31:0]        value1, value2, immediate; 
    input [2:0]         alu_oc;
    input               ir_op;
    output wire [32:0]  result;

    output reg [31:0]   wr_cpsr_val;

    reg [31:0]          op2;
    ALU alu1(
        .operand1 (value1),
        .operand2 (op2),
        .opcode (alu_oc),
        .result (result)
    );

    always @(*)
    begin

        if (ir_op)              // Loads immediate into the ALU on 0, and the register value on 1
        begin
            op2 <= value2;      // Loading value returned by Registers
        end else
        begin
            op2 <= immediate;   // Loading immediate value from ID
        end
        wr_cpsr_val[31] = result[31];       // N
        if (result == 0) begin
            wr_cpsr_val[30] = 1;            // Z
        end
        //wr_cpsr_val[29] = result[];       // C
        wr_cpsr_val[28] = result[32];       // V

    end

endmodule