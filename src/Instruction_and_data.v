module Instruction_and_data(mem_Clk, instruction_memory_en, instruction_memory_a, data_memory_a, data_memory_read, data_memory_write, data_memory_out_v, instruction_memory_v, data_memory_in_v);

input wire mem_Clk;
input wire instruction_memory_en;
input wire [31:0] instruction_memory_a;
input wire [31:0] data_memory_a;
input wire data_memory_read;
input wire data_memory_write;
input wire [31:0] data_memory_out_v;
output reg [31:0] instruction_memory_v;
output reg [31:0] data_memory_in_v;

integer i;
integer file;

reg [7:0] memory [0:(2**16)-1] ; //Maximum array to hold both instruction and data memory

initial begin
  $readmemh("output.mem", memory);
  $dumpvars(0, memory[0], memory[1], memory[2], memory[3], memory[4], memory[5], memory[6], memory[7]); 
end

always @(instruction_memory_en) begin
  if (~instruction_memory_en) begin
        
  end
end

always @(negedge instruction_memory_en) begin
  // Open a file for writing
  file = $fopen("scc_dump.csv", "w");
  if (file == 0) begin
    $display("Error: Could not open file.");
    $finish;
  end

  // Write header for CSV file
  $fwrite(file, "Address,Value\n");

  // Write memory contents to the CSV file
  for (i = 0; i < (2**16)-1; i = i + 4) begin
    $fwrite(file, "0x%8h,0x%2h%2h%2h%2h\n", i, memory[i], memory[i+1], memory[i+2], memory[i+3]);
  end

  // Close the file
  $fclose(file);

  $display("Memory contents dumped to memory_dump.csv");
  $finish;
end
   
always @(instruction_memory_a) begin
  if(instruction_memory_en)begin //Grabs 32 bit instruction
    instruction_memory_v[31:24] <= memory[instruction_memory_a];
    instruction_memory_v[23:16] <= memory[instruction_memory_a+1];
    instruction_memory_v[15:8] <= memory[instruction_memory_a+2];
    instruction_memory_v[7:0] <= memory[instruction_memory_a+3];
  end

  else if (~instruction_memory_en) begin //When low the SCC program pauses until set back to high which continues fetching instructions
    instruction_memory_v <= 'hFFFFFFFF;
  end
end

always @(data_memory_a) begin
  if(data_memory_read) begin //Load instruction
    data_memory_in_v[31:24] <=memory[data_memory_a];
    data_memory_in_v[23:16] <=memory[data_memory_a+1];
    data_memory_in_v[15:8] <=memory[data_memory_a+2];
    data_memory_in_v[7:0] <=memory[data_memory_a+3];
  end
end

always @(mem_Clk) begin
  if(data_memory_write) begin //Store instruction
    memory[data_memory_a] <= data_memory_out_v[31:24];
    memory[data_memory_a+1] <= data_memory_out_v[23:16];
    memory[data_memory_a+2] <= data_memory_out_v[15:8];
    memory[data_memory_a+3] <= data_memory_out_v[7:0];
    data_memory_in_v <= 'bx;
  end
end
endmodule
