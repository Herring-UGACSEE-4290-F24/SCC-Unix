module EXE(reg1_val, reg2_val, immediate, alu_oc, ir_op, result, wr_cpsr_val);

    input [31:0]        reg1_val, reg2_val, immediate; 
    input [2:0]         alu_oc;
    input               ir_op;
    output wire [31:0]  result;

    output reg [31:0]   wr_cpsr_val;

    reg [31:0]          op1;
    reg [31:0]          op2;
    wire                carry;
    ALU alu1(
        .operand1 (op1),
        .operand2 (op2),
        .opcode (alu_oc),
        .res_out (result),
        .overflow (carry)
    );

    always @(*)
    begin

        op1 = reg1_val;
        if (ir_op)              // Loads immediate into the ALU on 0, and the register value on 1
        begin
            op2 = reg2_val;      // Loading value returned by Registers
        end else
        begin
            op2 = immediate;   // Loading immediate value from ID
        end

        wr_cpsr_val = 32'b0;
        wr_cpsr_val[31] = result[31];       // N
        if (result == 0) begin
            wr_cpsr_val[30] = 1;            // Z
        end
        wr_cpsr_val[29] = carry;            // C
        wr_cpsr_val[28] = ((op1[30] ^ op2[30]) & (~result[30])) | (op1[30] & op2[30]);       // V

    end

endmodule