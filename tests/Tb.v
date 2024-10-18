`timescale 1ns/1ns

/*
 * This is the testbench module for Instruction Decoder of the SCC Unix Group
*/
module ID_tb();
    /*
     * defining inputs
    */
    reg clk_s;
    reg [31:0] instruction_s;
 
    /*
     * defining outputs 
    */
    wire [2:0] read_addr1_s;
    wire [2:0] read_addr2_s;
    wire [31:0] value1_s;
    wire [31:0] value2_s;
    wire [2:0] write_addr_s;
    wire [31:0] write_data_alu_s;
    wire [31:0] write_data_id_s;
    wire write_data_sel_s;
    wire write_enable_s;

    wire [2:0] alu_oc_s;
    wire [31:0] operand2_s;
    wire ir_op_s;
    
    wire [31:0] re_cpsr_s;
    wire [31:0] wr_cpsr_data_s;
    wire  wr_cpsr_s;

    ID dut (                            // instantiating ID
        .instruction (instruction_s),
        .read_addr1 (read_addr1_s),
        .read_addr2 (read_addr2_s),
        .value1 (value1_s),
        .value2 (value2_s),
        .write_addr (write_addr_s),
        .write_data (write_data_id_s),
        .write_data_sel (write_data_sel_s),
        .wr_cpsr (wr_cpsr_s),
        .write_enable (write_enable_s),
        .operand2 (operand2_s),
        .ir_op (ir_op_s),
        .opcode (alu_oc_s)
    );

    Reg_File dut_2 (                    // instantiating Reg File
        .clk (clk_s),
        .read_addr1 (read_addr1_s),
        .read_addr2 (read_addr2_s),
        .write_addr (write_addr_s),
        .write_value_alu (write_data_alu_s),
        .write_value_id (write_data_id_s),
        .write_data_sel (write_data_sel_s),
        .write_enable (write_enable_s),
        .value1 (value1_s),
        .value2 (value2_s)
    );

    Reg_File_2 dut_3 (
        .wr_cpsr_data (wr_cpsr_data_s),
        .wr_cpsr (wr_cpsr_s),
        .clk (clk_s),
        .re_cpsr (re_cpsr_s)
    );
    

    EXE dut_4 (                         // instantiating EXE
        .value1 (value1_s),
        .value2 (value2_s),
        .immediate (operand2_s),
        .alu_oc (alu_oc_s),
        .ir_op (ir_op_s),
        .result (write_data_alu_s),
        .wr_cpsr_val (wr_cpsr_data_s)
    );

    always begin                        // setting up clock
        clk_s = 0;
        #10;
        clk_s = 1;
        #10;
    end


    /*
     * Beginning of Testbench.
     * ------------------------------------------
     * Test Cases :
     *        :
     *      1 : CLR  R0             -> 'b00000100000000000000000000000000
     *        : CLR  R1             -> 'b00000100010000000000000000000000
     *        : ADDS R0, R0, #0     -> 'b00110010000000000000000000000000
     *        : SUBS R0, R0, #1     -> 'b00110100000000000000000000000001
     *        : MOV  R0, #0xFFFF    -> 'b00000000000000001111111111111111
     *        : MOVT R0, #0xFFFF    -> 'b00000010000000001111111111111111
     *        : ADDS R0, R0, #1     -> 'b00110010000000000000000000000001
     *        :
     *      2 : CLR  R0             -> 'b00000100000000000000000000000000
     *        : CLR  R1             -> 'b00000100010000000000000000000000
     *        : MOV  R0, #1         -> 'b00000000000000000000000000000001
     *        : LSL  R0, R0, #1     -> 'b00000010000000000000000000000001
     *        : LSR  R0, R0, #1     -> 'b00001010000000000000000000000001
     *        :
     */
    initial begin
        $dumpvars(0, ID_tb);

        @(posedge clk_s);
        #5 instruction_s = 'b00000100000000000000000000000000;

        @(posedge clk_s);
        #5 instruction_s = 'b00000100010000000000000000000000;
        
        @(posedge clk_s);
        #5 instruction_s = 'b00110010000000000000000000000000;
        
        @(posedge clk_s);
        #5 instruction_s = 'b00110100000000000000000000000001;
        
        @(posedge clk_s);
        #5 instruction_s = 'b00000000000000001111111111111111;
        
        @(posedge clk_s);
        #5 instruction_s = 'b00000010000000001111111111111111;

        @(posedge clk_s);
        #5 instruction_s = 'b00110010000000000000000000000001;


        @(posedge clk_s);
        #5 instruction_s = 'b00000100000000000000000000000000;

        @(posedge clk_s);
        #5 instruction_s = 'b00000100010000000000000000000000;
        
        @(posedge clk_s);
        #5 instruction_s = 'b00000000000000000000000000000001;
        
        @(posedge clk_s);
        #5 instruction_s = 'b00000010000000000000000000000001;
        
        @(posedge clk_s);
        #5 instruction_s = 'b00001010000000000000000000000001;
        
        @(posedge clk_s);
        @(posedge clk_s);  

        $finish;

    end

endmodule

/*
 * Remind Herring about how Branch Predict is defined as NOP in the document, shouldn't be that way.
 * BR instruction can just 0 out the lowest 2 bits to be 4 byte alligned.
 */