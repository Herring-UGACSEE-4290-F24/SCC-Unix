/*
 * This module is the implementation for the Instruction Decoder.
 */

module ID(instruction);

    input [31:0]    instruction;    // Instruction passed in from Instruction Memory    


    reg [1:0]        fld;           // first-level-decode, bits 31-30
    reg              s;             // special single bit for data instructions, bits 29
    reg [3:0]        sld;           // single-level-decode, bits 28-25
    output reg [2:0] alu_oc;        // opcode for ALU, bits 27-25

    reg [2:0]        dest_reg;      // destination register, bits 24-22
    reg [2:0]        mem_ptr_reg;   // pointer register for memory instructions, bits 21-19
    reg [2:0]        br_ptr_reg;    // branch pointer, bits 24-22
    reg [15:0]       offset;        // offset, bits 15-0
    reg [2:0]        src_reg;       // register to store source address, bits 24-22
    reg [15:0]       imm;           // immediate value, bits 15-0
    reg [2:0]        op_1_reg;      // operand one, bits 21-19
    reg [2:0]        op_2_reg;      // operand two, bits 18-16    
    reg [2:0]        shift_amt_reg; // register that stores shift amount, bits 21-19
    reg [3:0]        cond_flags;    // condition flags for branching, bits 24-21

    /*
     * The following are the instructions defined as thier begining 7-bit encoding.
     * In our encoding, "Don't cares" are to be treated as 0s
     */
    parameter LOAD  = 'b1000000, STOR  = 'b1000001, MOV   = 'b0000000, MOVT  = 'b0000001, ADD   = 'b0010001;
    parameter ADDS  = 'b0011001, SUB   = 'b0010010, SUBS  = 'b0011010, AND   = 'b0010011, ANDS  = 'b0011011;
    parameter OR    = 'b0010100, ORS   = 'b0011100, XOR   = 'b0010101, XORS  = 'b0011101, LSL   = 'b0000001;
    parameter LSR   = 'b0000101, CLR   = 'b0000010, SET   = 'b0000011, ADD2  = 'b0110001, ADDS2 = 'b0111001;
    parameter SUB2  = 'b0110010, SUBS2 = 'b0111010, AND2  = 'b0110011, ANDS2 = 'b0111011, OR2   = 'b0110100;
    parameter ORS2  = 'b0111100, XOR2  = 'b0110101, XORS2 = 'b0111101, NOT   = 'b0110110, B     = 'b1100000;
    parameter Bcond = 'b1100001, BR    = 'b1100010, NOP   = 'b1100100, HALT  = 'b1101000;

    initial
    begin
        /*
         * The following statements will save each 
         * of the bit strings for possible parameters
         */
        fld =           instruction[31:30];
        s =             instruction[29];
        sld =           instruction[28:25];
        alu_oc =        instruction[27:25];
        dest_reg =      instruction[24:22];
        mem_ptr_reg =   instruction[21:19];
        br_ptr_reg =    instruction[24:21];
        offset =        instruction[15:0];
        src_reg =       instruction[24:22];
        imm =           instruction[15:0];
        op_1_reg =      instruction[21:19];
        op_2_reg =      instruction[18:16];
        shift_amt_reg = instruction[21:19];
        cond_flags =    instruction[24:21];

        /*
         * Case statement to check the most significant 7-bits 
         * Sets control signals according to the given instruction
         */

        //PLAN: make each instruction set EVERY output, even the unused ones to x
        case (instruction[31:25])
            LOAD: begin
                // destination register -> write address on register file
                // pointer register -> a read address on register file
                // enable read AND write on the register file
                // add offset to value read at pointer address
                // send sum to dataMem input address
                // enable read from dataMem pass into write_data on register file
            end
            STOR: begin
                // source register -> a read address on register file
                // pointer register -> other read address on register file
                // enable read on register file
                // add offset to value read from pointer register
                // send sum to dataMem input address
                // send value from source register to data_input on dataMem
                // enable write to dataMem
            end
            MOV: begin
                // destination register -> write address on register file
                // immediate -> write_data on register file
                // enable write on register file
                // TODO: figure out how to write to lower bytes
            end
            MOVT: begin
                // destination register -> write address on register file
                // immediate -> write_data on register file
                // enable write on register file
                // TODO: figure out how to explicitly write to upper bytes and not lower
            end
            ADD: begin
                // alu_oc -> ALU opcode input
                // op 1 register -> a read address on register file
                // immediate -> the ALU to be computed
                // destination register -> write address on register file
                // enable read and write on register
            end
            ADDS: begin
                // alu_oc -> ALU opcode input
                // op 1 register -> a read address on register file
                // immediate -> the ALU to be computed
                // destination register -> write address on register file
                // enable read and write on register
                // enable flags to be set
            end
            SUB: begin
                // alu_oc -> ALU opcode input
                // op 1 register -> a read address on register file
                // immediate -> the ALU to be computed
                // destination register -> write address on register file
                // enable read and write on register
            end
            SUBS: begin
                // alu_oc -> ALU opcode input
                // op 1 register -> a read address on register file
                // immediate -> the ALU to be computed
                // destination register -> write address on register file
                // enable read and write on register
                // enable flags to be set
            end
            AND: begin
                // alu_oc -> ALU opcode input
                // op 1 register -> a read address on register file
                // immediate -> the ALU to be computed
                // destination register -> write address on register file
                // enable read and write on register
            end
            ANDS: begin
                // alu_oc -> ALU opcode input
                // op 1 register -> a read address on register file
                // immediate -> the ALU to be computed
                // destination register -> write address on register file
                // enable read and write on register
                // enable flags to be set
            end
            OR: begin
                // alu_oc -> ALU opcode input
                // op 1 register -> a read address on register file
                // immediate -> the ALU to be computed
                // destination register -> write address on register file
                // enable read and write on register
            end
            ORS: begin
                // alu_oc -> ALU opcode input
                // op 1 register -> a read address on register file
                // immediate -> the ALU to be computed
                // destination register -> write address on register file
                // enable read and write on register
                // enable flags to be set
            end
            XOR: begin
                // alu_oc -> ALU opcode input
                // op 1 register -> a read address on register file
                // immediate -> the ALU to be computed
                // destination register -> write address on register file
                // enable read and write on register
            end
            XORS: begin
                // alu_oc -> ALU opcode input
                // op 1 register -> a read address on register file
                // immediate -> the ALU to be computed
                // destination register -> write address on register file
                // enable read and write on register
                // enable flags to be set
            end
            LSL: begin

            end
            LSR: begin

            end
            CLR: begin
                // destination register -> write address on register file
                // pass all 0's into write_data on register file
                // enable write on register file
            end
            SET: begin
                // destination register -> write address on register file
                // pass all 1's into write_data on register file
                // enable write on register file
            end
            ADD2: begin
                // alu_oc -> ALU opcode input
                // op 1 register -> a read address on register file
                // op 2 register -> other read address on register file
                // destination register -> write address on register file
                // enable read and write on register
            end
            ADDS2: begin
                // alu_oc -> ALU opcode input
                // op 1 register -> a read address on register file
                // op 2 register -> other read address on register file
                // destination register -> write address on register file
                // enable read and write on register
                // enable flags to be set
            end
            SUB2: begin
                // alu_oc -> ALU opcode input
                // op 1 register -> a read address on register file
                // op 2 register -> other read address on register file
                // destination register -> write address on register file
                // enable read and write on register
            end
            SUBS2: begin
                // alu_oc -> ALU opcode input
                // op 1 register -> a read address on register file
                // op 2 register -> other read address on register file
                // destination register -> write address on register file
                // enable read and write on register
                // enable flags to be set
            end
            AND2: begin
                // alu_oc -> ALU opcode input
                // op 1 register -> a read address on register file
                // op 2 register -> other read address on register file
                // destination register -> write address on register file
                // enable read and write on register
            end
            ANDS2: begin
                // alu_oc -> ALU opcode input
                // op 1 register -> a read address on register file
                // op 2 register -> other read address on register file
                // destination register -> write address on register file
                // enable read and write on register
                // enable flags to be set
            end
            OR2: begin
                // alu_oc -> ALU opcode input
                // op 1 register -> a read address on register file
                // op 2 register -> other read address on register file
                // destination register -> write address on register file
                // enable read and write on register
            end
            ORS2: begin
                // alu_oc -> ALU opcode input
                // op 1 register -> a read address on register file
                // op 2 register -> other read address on register file
                // destination register -> write address on register file
                // enable read and write on register
                // enable flags to be set
            end
            XOR2: begin
                // alu_oc -> ALU opcode input
                // op 1 register -> a read address on register file
                // op 2 register -> other read address on register file
                // destination register -> write address on register file
                // enable read and write on register
            end
            XORS2: begin
                // alu_oc -> ALU opcode input
                // op 1 register -> a read address on register file
                // op 2 register -> other read address on register file
                // destination register -> write address on register file
                // enable read and write on register
                // enable flags to be set
            end
            NOT: begin
                // alu_oc -> ALU opcode input
                // op 1 register -> a read address on register file
                // destination register -> write address on register file
                // enable read and write on register
                // enable flags to be set
            end
            B: begin

            end
            Bcond: begin

            end
            BR: begin

            end
            NOP: begin
                // Does nothing, literally!
            end
            HALT: begin
                
            end
            default:    $display("default case");
        endcase
    end

endmodule