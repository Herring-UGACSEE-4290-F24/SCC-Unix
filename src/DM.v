// Data Memory
module Data_Memory (
    clk, reset, MemWrite, MemRead, write_address, read_address, Write_data, MemData_out
);

input clk, reset, MemWrite, MemRead;
input [31:0] write_address, read_address, Write_data;
output [31:0] MemData_out;
integer  k;
reg [31:0] Data_Memory[65535:0];

always @(posedge clk)
begin
if (reset) begin
                    for (k = 0;k < 65536; k = k +1) begin
                        Data_Memory[k] <= 32'h00000000;
                    end 
            end

else if(MemWrite) begin
        Data_Memory[write_address[2:0]] <= Write_data;
        end

end
assign MemData_out = (MemRead) ? Data_Memory[read_address[2:0]] : 32'h00000000;
    
endmodule
