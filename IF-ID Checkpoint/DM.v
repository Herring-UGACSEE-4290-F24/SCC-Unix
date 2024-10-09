// Data Memory
module Data_Memory (
    clk, reset, MemWrite, MemRead, read_address, Write_data, MemData_out
);

input clk, reset, MemWrite, MemRead;
input [31:0] read_address, Write_data;
output [31:0] MemData_out;
integer  k;
reg [7:0] Data_Memory[31:0];

always @(posedge reset)
begin
if (reset) begin
                    for (k = 0;k < 32; k = k +1) begin
                        Data_Memory[k] <= 8'h00;
                    end 
            end

else if(MemWrite) begin
        Data_Memory[read_address] <= Write_data;
        end

end
assign MemData_out = (MemRead) ? Data_Memory[read_address] : 8'h00;
    
endmodule
