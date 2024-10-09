module Instruction_Mem (reset, read_address, instruction_out);

input reset;
input [31:0] read_address;
output reg [31:0] instruction_out;

reg [7:0] Memory [31:0];                // 32 mem. addresses that are 8-bits wide.

integer k;                              // For looping

always @(*) begin                       // Four 8-bit memory locations for 32-bit instructions
    instruction_out = {
        Memory[read_address],           // Accesses mem. at read_address
        Memory[read_address+1],
        Memory[read_address+2],
        Memory[read_address+3]
    };
end

always @(posedge reset)                 // Re-initialize mem. on reset

begin 
    for (k = 0; k < 32; k = k+1) begin  // For Loop from 0 to 31 arrays (32-bit)
        Memory[k] = 8'b00000000;        // 8-bit memory (8 width; h-hexa; b-binary; d-decimal; o-octal)
                                        // 00 (hexa), meaning 00000000 (binary), or 0 (decimal).
                                        // Ex., 8'hFF is 8-bits for 11111111 (binary) or 255 (decimal).
    end
end

endmodule 

