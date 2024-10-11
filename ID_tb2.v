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


    ID dut (                            // instantiating ID
        .instruction (instruction_s),
        .read_addr1 (read_addr1_s),
        .read_addr2 (read_addr2_s),
        .value1 (value1_s),
        .value2 (value2_s),
        .write_addr (write_addr_s),
        .write_data (write_data_id_s),
        .write_data_sel (write_data_sel_s),
        .write_enable (write_enable_s),
        .operand2 (operand2_s),
        .ir_op (ir_op_s),
        .alu_oc (alu_oc_s)
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

    EXE dut_3 (                         // instantiating EXE
        .value1 (value1_s),
        .value2 (value2_s),
        .immediate (operand2_s),
        .alu_oc (alu_oc_s),
        .ir_op (ir_op_s),
        .result (write_data_alu_s)
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
     *      1 : MOV R0,  #0xFFFF 
     *        :     
     *      2 : MOVT R0, #0xEEEE
     *        :
     *      3 : SET R1
     *        :
     *      4 : CLR R2
     *        :
     *      5 : CLR R0              -> 0x0400_0000
     *        : CLR R1              -> 0x0440_0000
     *        : CLR R2              -> 0x0480_0000
     *        : CLR R3              -> 0x04C0_0000
     *        : CLR R4              -> 0x0500_0000
     *        : CLR R5              -> 0x0540_0000
     *        : CLR R6              -> 0x0580_0000
     *        : CLR R7              -> 0x05C0_0000
     *        :
     *      6 : MOV R1, #0x1        -> 0x0040_0001
     *        : ADD R0, R0, #0x1    -> 0x2200_0001
     *        : ADD R0, R0, R1      -> 0x6201_0000
     *        :
     *      7 : SUB R0, R0, #0x1    -> 0x2400_0001
     *        : SUB R0, R0, R0      -> 0x6400_0000
     *        :
     *      8 : MOV R0, #0xF        -> 0x0000_000F
     *        : AND R0, R0, #0x6    -> 0x04C0_0006
     *        : MOV R1, #0x2        -> 0x0040_0002
     *        : AND R0, R0, R1      -> 0x7601_0000
     *        :
     *      9 : OR R0, R0, #0xF     -> 0x2800_000F
     *        : OR R1, R0, #0x10    -> 0x2840_0010
     *        : OR R1, R0, R1       -> 0x6841_0000
     *        :
     *     10 : XOR R0, R0, R1      -> 0x6A01_0000
     *        : XOR R0, R0, #F      -> 0x2A00_000F
     *        :
     *     11 : NOT R0, R0          -> 0x6C00_0000
     *      
     *      Reference for Encoding :
     *      -------------------------------------
     *      MOV     : [ 0x0000_FFFF ]
     *      MOVT    : [ 0x0200_EEEE ]
     *      SET     : [ 0x0640_0000 ]
     *      CLR     : [ 0x0480_0000 ]
    */
    initial begin
        $dumpvars(0, ID_tb);

        @(posedge clk_s);                   // 1
        #5 instruction_s = 'h0000_FFFF;     // MOV R0,  #0xFFFF

        @(posedge clk_s);                   // 2
        #5 instruction_s = 'h0200_EEEE;     // MOVT R0, #0xEEEE

        @(posedge clk_s);                   // 3
        #5 instruction_s = 'h0640_0000;     // SET R1

        @(posedge clk_s);                   // 4
        #5 instruction_s = 'h0480_0000;     // CLR R2

        // ================================ // 5
        @(posedge clk_s);
        #5 instruction_s = 'h0400_0000;

        @(posedge clk_s);
        #5 instruction_s = 'h0440_0000;

        @(posedge clk_s);
        #5 instruction_s = 'h0480_0000;

        @(posedge clk_s);
        #5 instruction_s = 'h04C0_0000;

        @(posedge clk_s);
        #5 instruction_s = 'h0500_0000;

        @(posedge clk_s);
        #5 instruction_s = 'h0540_0000;

        @(posedge clk_s);
        #5 instruction_s = 'h0580_0000;

        @(posedge clk_s);
        #5 instruction_s = 'h05C0_0000;
        // ================================ // 6
        @(posedge clk_s);
        #5 instruction_s = 'h0040_0001;

        @(posedge clk_s);
        #5 instruction_s = 'h2200_0001;

        @(posedge clk_s);
        #5 instruction_s = 'h6201_0000;
        // ================================ // 7
        @(posedge clk_s);
        #5 instruction_s = 'h2400_0001;

        @(posedge clk_s);
        #5 instruction_s = 'h6400_0000;
        // ================================ // 8
        @(posedge clk_s);
        #5 instruction_s = 'h0000_000F;

        @(posedge clk_s);
        #5 instruction_s = 'h04C0_0006;

        @(posedge clk_s);
        #5 instruction_s = 'h0040_0002;

        @(posedge clk_s);
        #5 instruction_s = 'h7601_0000;
        // ================================ // 9
        @(posedge clk_s);
        #5 instruction_s = 'h2800_000F;

        @(posedge clk_s);
        #5 instruction_s = 'h2840_0010;

        @(posedge clk_s);
        #5 instruction_s = 'h6841_0000;
        // ================================ // 10
        @(posedge clk_s);
        #5 instruction_s = 'h6A01_0000;

        @(posedge clk_s);
        #5 instruction_s = 'h2A00_000F;
        // ================================ // 11
        @(posedge clk_s);
        #5 instruction_s = 'h6C00_0000;
        // ================================ //

        @(posedge clk_s);

        $finish;

    end

endmodule