// Module declaration
module ALU(operand1, operand2, opcode, result, overflow);

// ALU inputs
input [2:0] opcode;
input [31:0] operand1; 
input [31:0] operand2;

// ALU outputs
output reg [32:0] result;
output reg overflow;

// ALU Operation Commands
// NOP: 000
// ADD: 001
// SUB: 010
// AND: 011
// OR:  100
// XOR: 101
// NOT: 110

parameter ADD = 3'b001, SUB = 3'b010, AND = 3'b011;
parameter OR = 3'b100, XOR = 3'b101, NOT = 3'b110;

always @(*) begin
        
    case (opcode)
    // Addition
    ADD: begin
        result = operand1 + operand2;
        overflow <= result[32];
    end

    // Subtraction
    SUB: begin
        result = operand1 - operand2;
        overflow <= result[32];
    end

    // Bitwise AND
    AND: begin
        result <= operand1 & operand2;
    end

    // Bitwise OR
    OR: begin
        result <= operand1 | operand2;
    end

    // Bitwise XOR
    XOR: begin
        result <= operand1 ^ operand2;
    end

    // Bitwise NOT
    NOT: begin
        result <= ~operand1;
    end

    // No valid opcode
    default: begin
        result <= 0;
        overflow <= 0;
    end

    endcase
end

endmodule

// Vflag: operand1[30] + operand2[30], does this carry?