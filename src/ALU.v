// Module declaration
module ALU(operand1, operand2, opcode, res_out, overflow);

// ALU inputs
input [2:0] opcode;
input [32:0] operand1; 
input [3:0] operand2;

// ALU outputs
reg [32:0] result;
output [31:0] res_out;
output reg overflow;

// ALU Operation Commands //
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
    ADD: begin // Addition
        result = operand1 + operand2;
    end

    SUB: begin // Subtraction
        result = operand1 - operand2;
    end

    AND: begin // Bitwise AND
        result <= operand1 & operand2;
    end

    OR: begin // Bitwise OR
        result <= operand1 | operand2;
    end

    XOR: begin // Bitwise XOR
        result <= operand1 ^ operand2;
    end

    NOT: begin // Bitwise NOT
        result <= ~operand1;
    end

    default: begin // No valid opcode
        result <= 0;
        overflow <= 0;
    end

    endcase

    res_out = result[31:0];
    overflow = result[31:0];

end

endmodule

// Vflag: operand1[30] + operand2[30], does this carry?