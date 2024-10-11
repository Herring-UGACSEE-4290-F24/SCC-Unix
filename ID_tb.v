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
    wire [31:0] write_data_s;
    wire write_data_sel_s;
    wire write_enable_s;


    ID dut (                          // instantiating ID
        .instruction (instruction_s),
        .read_addr1 (read_addr1_s),
        .read_addr2 (read_addr2_s),
        .value1 (value1_s),
        .value2 (value2_s),
        .write_addr (write_addr_s),
        .write_data (write_data_s),
        .write_data_sel (write_data_sel_s),
        .write_enable (write_enable_s)
    );

    Reg_File dut_2 (                  // instantiating Reg File
        .clk (clk_s),
        .read_addr1 (read_addr1_s),
        .read_addr2 (read_addr2_s),
        .write_addr (write_addr_s),
        .write_value_id (write_data_s),
        .write_data_sel (write_data_sel_s),
        .write_enable (write_enable_s),
        .value1 (value1_s),
        .value2 (value2_s)
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
     *      2 : MOVT R0, #0xEEEE
     *      3 : SET R1
     *      4 : CLR R2
     *      
     *      Reference for Encoding :
     *      -------------------------------------
     *      MOV     : [ 0x0000_FFFF ]
     *      MOVT    : [ 0x0200_EEEE ]
     *      SET     : [ 0x0640_0000 ]
     *      CLR     : [ 0x0480_0005 ]
    */
    initial begin
        $dumpvars(0, ID_tb);

        @(posedge clk_s);                   // 1
        #5 instruction_s = 'h0000_FFFF;

        @(posedge clk_s);                   // 2
        #5 instruction_s = 'h0200_EEEE;

        @(posedge clk_s);
        #5 instruction_s = 'h0640_0000;     // 3

        @(posedge clk_s);
        #5 instruction_s = 'h0480_0005;     // 4

        @(posedge clk_s);
        @(posedge clk_s);
        @(posedge clk_s);
        @(posedge clk_s);

        $finish;

    end

endmodule