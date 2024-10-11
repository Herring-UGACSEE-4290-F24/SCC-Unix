/*
 * This module is the implementation for the Instruction Decoder.
 */

module ID(instruction, read_addr1, read_addr2, value1, value2, write_addr, write_data, write_data_sel, write_enable, alu_oc, operand2, ir_op);

    input [31:0]    instruction;    // Instruction passed in from Instruction Memory    

//   FOR CONTROLLING REG_FILE SIGNALS  //
// =================================== //
// These signals will control what     //
// data gets read and written to       //
// the reg_file for the instruction    //
// being decoded.                      //
// - - - - - - - - - - - - - - - - - - //
    output reg [2:0]    read_addr1;    // First address to read from
    output reg [2:0]    read_addr2;    // Second address to read from
    input [31:0]        value1;        // Value at first address' reg
    input [31:0]        value2;        // Value at second address' reg
    output reg [2:0]    write_addr;    // Address to write to
    output reg [31:0]   write_data;    // Data to write at address
    output reg          write_data_sel;// Determines if value being written to regs is from alu result or elsewhere
    output reg          write_enable;  // Enable writing data to address
// =================================== //

// FOR SENDING CONTROLS AND VALUES TO ALU //
// ====================================== //
// These are either values for the ALU to //
// operate on, or are control lines that  //
// will change muxes that provide the val //
// that the ALU uses.                     //
// - - - - - - - - - - - - - - - - - - -  //
    output reg [2:0]  opcode;             // Opcode for the ALU
    output reg [31:0] operand2;           // The second operand field of the ALU
    output reg        ir_op;              // Instruction/Register operand (control bit)
// ====================================== //

// BITFIELD AGRUMENT SPLITTING //
// =========================== //
// This just grabs each of the //
// arguments in the bit fields //
// in the instruction encoding //
// - - - - - - - - - - - - - - //
    wire [1:0]        fld;           // first-level-decode, bits 31-30
    wire              s;             // special single bit for data instructions, bits 29
    wire [3:0]        sld;           // single-level-decode, bits 28-25
    wire [2:0]        alu_oc;        // opcode for ALU, bits 27-25

    wire [2:0]        dest_reg;      // destination register, bits 24-22
    wire [2:0]        mem_ptr_reg;   // pointer register for memory instructions, bits 21-19
    wire [2:0]        br_ptr_reg;    // branch pointer, bits 24-22
    wire [15:0]       offset;        // offset, bits 15-0
    wire [2:0]        src_reg;       // register to store source address, bits 24-22
    wire [15:0]       imm;           // immediate value, bits 15-0
    wire [2:0]        op_1_reg;      // operand one, bits 21-19
    wire [2:0]        op_2_reg;      // operand two, bits 18-16    
    wire [2:0]        shift_amt_reg; // register that stores shift amount, bits 21-19
    wire [3:0]        cond_flags;    // condition flags for branching, bits 24-21
// =========================== //

    /*
     * The following are the (34) instructions defined as thier begining 7-bit encoding.
     * In our encoding, "Don't cares" are to be treated as 0s. // DOUBLE CHECK WITH ASSEMBLER
     * 
     * NOTE that B and BR should never be seen in the ID, they should be handled in IF.
     */
    parameter LOAD  = 'b1000000, STOR  = 'b1000001, MOV   = 'b0000000, MOVT  = 'b0000001, ADD   = 'b0010001;
    parameter ADDS  = 'b0011001, SUB   = 'b0010010, SUBS  = 'b0011010, AND   = 'b0010011, ANDS  = 'b0011011;
    parameter OR    = 'b0010100, ORS   = 'b0011100, XOR   = 'b0010101, XORS  = 'b0011101, LSL   = 'b0000001;
    parameter LSR   = 'b0000101, CLR   = 'b0000010, SET   = 'b0000011, ADD2  = 'b0110001, ADDS2 = 'b0111001;
    parameter SUB2  = 'b0110010, SUBS2 = 'b0111010, AND2  = 'b0110011, ANDS2 = 'b0111011, OR2   = 'b0110100;
    parameter ORS2  = 'b0111100, XOR2  = 'b0110101, XORS2 = 'b0111101, NOT   = 'b0110110, B     = 'b1100000;
    parameter Bcond = 'b1100001, BR    = 'b1100010, NOP   = 'b1100100, HALT  = 'b1101000;

    /*
     * The following statements will save each 
     * of the bit strings for possible parameters
     */
    assign fld =           instruction[31:30];
    assign s =             instruction[29];
    assign sld =           instruction[28:25];
    assign alu_oc =        instruction[27:25];
    assign dest_reg =      instruction[24:22];
    assign mem_ptr_reg =   instruction[21:19];
    assign br_ptr_reg =    instruction[24:21];
    assign offset =        instruction[15:0];
    assign src_reg =       instruction[24:22];
    assign imm =           instruction[15:0];
    assign op_1_reg =      instruction[21:19];
    assign op_2_reg =      instruction[18:16];
    assign shift_amt_reg = instruction[21:19];
    assign cond_flags =    instruction[24:21];

    always @(*)
    begin

        // Set every important control line to 0 (?)
        // -> then an instruction can set it's controls how it needs
        // -> avoids write_enable being left high (very bad)
        write_enable = 0;

        /*
         * Case statement to check the most significant 7-bits 
         * Sets control signals according to the given instruction
         */

        // PLAN: make each instruction set EVERY output, even the unused ones to x
        // DATA MUXES ARE NOT TO BE IN THE ID
        // MAYBE change regs to wires with assign statements; REMEMBER THIS IS A SINGLE-CYCLE that means that instruction comes in and
        //   is completed within 1 clock cycle
        case (instruction[31:25])
            LOAD: begin
                // destination register -> write address on register file
                // pointer register -> a read address on register file
                // enable write on the register file
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
                read_addr1 = dest_reg;                  // destination register -> read address on register file
                write_addr = dest_reg;                  // destination register -> write address on register file
                write_data[31:16] = value1[31:16];      // copy value from most significant 2 bytes to remain constant
                write_data[15:0] = imm[15:0];           // immediate -> write_data on register file, stores into the least significant 2 bytes
                write_data_sel = 0;                     // write a value originating from the ID
                write_enable = 1;                       // enable write on register file
            end
            MOVT: begin
                read_addr1 = dest_reg;                  // destination register -> read address on register file
                write_addr = dest_reg;                  // destination register -> write address on register file
                write_data[15:0] = value1[15:0];        // copy value from least significant 2 bytes to remain constant
                write_data[31:16] = imm[15:0];          // immediate -> write_data on register file, stores into the most significant 2 bytes
                write_data_sel = 0;                     // write a value originating from the ID
                write_enable = 1;                       // enable write on register file
            end
            ADD: begin
                // alu_oc -> ALU opcode input | ALREADY ASSIGNED IN WIRE STATEMENTS
                read_addr1 = op_1_reg;                  // op 1 register -> a read address on register file
                operand2 = imm;                         // immediate -> the ALU to be computed
                ir_op = 0;                              // to mux: makes ALU take imm operand
                write_addr = dest_reg;                  // destination register -> write address on register file
                write_data_sel = 1;                     // write a value originating from the ALU
                write_enable = 1;                       // enable write on register
            end
            ADDS: begin
                // alu_oc -> ALU opcode input | ALREADY ASSIGNED IN WIRE STATEMENTS
                // op 1 register -> a read address on register file
                // immediate -> the ALU to be computed
                // destination register -> write address on register file
                // enable write on register
                // enable flags to be set
            end
            SUB: begin
                // alu_oc -> ALU opcode input | ALREADY ASSIGNED IN WIRE STATEMENTS
                read_addr1 = op_1_reg;                  // op 1 register -> a read address on register file
                operand2 = imm;                         // immediate -> the ALU to be computed
                ir_op = 0;                              // to mux: makes ALU take imm operand
                write_addr = dest_reg;                  // destination register -> write address on register file
                write_data_sel = 1;                     // write a value originating from the ALU
                write_enable = 1;                       // enable write on register
            end
            SUBS: begin
                // alu_oc -> ALU opcode input | ALREADY ASSIGNED IN WIRE STATEMENTS
                // op 1 register -> a read address on register file
                // immediate -> the ALU to be computed
                // destination register -> write address on register file
                // enable write on register
                // enable flags to be set
            end
            AND: begin
                // alu_oc -> ALU opcode input | ALREADY ASSIGNED IN WIRE STATEMENTS
                read_addr1 = op_1_reg;                  // op 1 register -> a read address on register file
                operand2 = imm;                         // immediate -> the ALU to be computed
                ir_op = 0;                              // to mux: makes ALU take imm operand
                write_addr = dest_reg;                  // destination register -> write address on register file
                write_data_sel = 1;                     // write a value originating from the ALU
                write_enable = 1;                       // enable write on register
            end
            ANDS: begin
                // alu_oc -> ALU opcode input | ALREADY ASSIGNED IN WIRE STATEMENTS
                // op 1 register -> a read address on register file
                // immediate -> the ALU to be computed
                // destination register -> write address on register file
                // enable write on register
                // enable flags to be set
            end
            OR: begin
                // alu_oc -> ALU opcode input | ALREADY ASSIGNED IN WIRE STATEMENTS
                read_addr1 = op_1_reg;                  // op 1 register -> a read address on register file
                operand2 = imm;                         // immediate -> the ALU to be computed
                ir_op = 0;                              // to mux: makes ALU take imm operand
                write_addr = dest_reg;                  // destination register -> write address on register file
                write_data_sel = 1;                     // write a value originating from the ALU
                write_enable = 1;                       // enable write on register
            end
            ORS: begin
                // alu_oc -> ALU opcode input | ALREADY ASSIGNED IN WIRE STATEMENTS
                // op 1 register -> a read address on register file
                // immediate -> the ALU to be computed
                // destination register -> write address on register file
                // enable write on register
                // enable flags to be set
            end
            XOR: begin
                // alu_oc -> ALU opcode input | ALREADY ASSIGNED IN WIRE STATEMENTS
                read_addr1 = op_1_reg;                  // op 1 register -> a read address on register file
                operand2 = imm;                         // immediate -> the ALU to be computed
                ir_op = 0;                              // to mux: makes ALU take imm operand
                write_addr = dest_reg;                  // destination register -> write address on register file
                write_data_sel = 1;                     // write a value originating from the ALU
                write_enable = 1;                       // enable write on register
            end
            XORS: begin
                // alu_oc -> ALU opcode input | ALREADY ASSIGNED IN WIRE STATEMENTS
                // op 1 register -> a read address on register file
                // immediate -> the ALU to be computed
                // destination register -> write address on register file
                // enable write on register
                // enable flags to be set
            end
            LSL: begin

            end
            LSR: begin

            end
            CLR: begin
                write_addr = dest_reg;                  // destination register -> write address on register file
                write_data = {32{1'b0}};                // pass all 0's into write_data on register file
                write_data_sel = 0;                     // write a value originating from the ID
                write_enable = 1;                       // enable write on register file
            end
            SET: begin
                write_addr = dest_reg;                  // destination register -> write address on register file
                write_data = {32{1'b1}};                // pass all 1's into write_data on register file
                write_data_sel = 0;                     // write a value originating from the ID
                write_enable = 1;                       // enable write on register file
            end
            ADD2: begin
                // alu_oc -> ALU opcode input | ALREADY ASSIGNED IN WIRE STATEMENTS
                read_addr1 = op_1_reg;                  // op 1 register -> a read address on register file
                read_addr2 = op_2_reg;                  // op 2 register -> other read address on register file
                ir_op = 1;                              // to mux: makes ALU take imm operand
                write_addr = dest_reg;                  // destination register -> write address on register file
                write_data_sel = 1;                     // write a value originating from the ALU
                write_enable = 1;                       // enable write on register
            end
            ADDS2: begin
                // alu_oc -> ALU opcode input | ALREADY ASSIGNED IN WIRE STATEMENTS
                // op 1 register -> a read address on register file
                // op 2 register -> other read address on register file
                // destination register -> write address on register file
                // enable write on register
                // enable flags to be set
            end
            SUB2: begin
                // alu_oc -> ALU opcode input | ALREADY ASSIGNED IN WIRE STATEMENTS
                read_addr1 = op_1_reg;                  // op 1 register -> a read address on register file
                read_addr2 = op_2_reg;                  // op 2 register -> other read address on register file
                ir_op = 1;                              // to mux: makes ALU take imm operand
                write_addr = dest_reg;                  // destination register -> write address on register file
                write_data_sel = 1;                     // write a value originating from the ALU
                write_enable = 1;                       // enable write on register
            end
            SUBS2: begin
                // alu_oc -> ALU opcode input | ALREADY ASSIGNED IN WIRE STATEMENTS
                // op 1 register -> a read address on register file
                // op 2 register -> other read address on register file
                // destination register -> write address on register file
                // enable write on register
                // enable flags to be set
            end
            AND2: begin
                // alu_oc -> ALU opcode input | ALREADY ASSIGNED IN WIRE STATEMENTS
                read_addr1 = op_1_reg;                  // op 1 register -> a read address on register file
                read_addr2 = op_2_reg;                  // op 2 register -> other read address on register file
                ir_op = 1;                              // to mux: makes ALU take imm operand
                write_addr = dest_reg;                  // destination register -> write address on register file
                write_data_sel = 1;                     // write a value originating from the ALU
                write_enable = 1;                       // enable write on register
            end
            ANDS2: begin
                // alu_oc -> ALU opcode input | ALREADY ASSIGNED IN WIRE STATEMENTS
                // op 1 register -> a read address on register file
                // op 2 register -> other read address on register file
                // destination register -> write address on register file
                // enable write on register
                // enable flags to be set
            end
            OR2: begin
                // alu_oc -> ALU opcode input | ALREADY ASSIGNED IN WIRE STATEMENTS
                read_addr1 = op_1_reg;                  // op 1 register -> a read address on register file
                read_addr2 = op_2_reg;                  // op 2 register -> other read address on register file
                ir_op = 1;                              // to mux: makes ALU take imm operand
                write_addr = dest_reg;                  // destination register -> write address on register file
                write_data_sel = 1;                     // write a value originating from the ALU
                write_enable = 1;                       // enable write on register
            end
            ORS2: begin
                // alu_oc -> ALU opcode input | ALREADY ASSIGNED IN WIRE STATEMENTS
                // op 1 register -> a read address on register file
                // op 2 register -> other read address on register file
                // destination register -> write address on register file
                // enable write on register
                // enable flags to be set
            end
            XOR2: begin
                // alu_oc -> ALU opcode input | ALREADY ASSIGNED IN WIRE STATEMENTS
                read_addr1 = op_1_reg;                  // op 1 register -> a read address on register file
                read_addr2 = op_2_reg;                  // op 2 register -> other read address on register file
                ir_op = 1;                              // to mux: makes ALU take imm operand
                write_addr = dest_reg;                  // destination register -> write address on register file
                write_data_sel = 1;                     // write a value originating from the ALU
                write_enable = 1;                       // enable write on register
            end
            XORS2: begin
                // alu_oc -> ALU opcode input | ALREADY ASSIGNED IN WIRE STATEMENTS
                // op 1 register -> a read address on register file
                // op 2 register -> other read address on register file
                // destination register -> write address on register file
                // enable write on register
                // enable flags to be set
            end
            NOT: begin
                // alu_oc -> ALU opcode input | ALREADY ASSIGNED IN WIRE STATEMENTS
                read_addr1 = op_1_reg;                  // op 1 register -> a read address on register file
                write_addr = dest_reg;                  // destination register -> write address on register file
                write_data_sel = 1;                     // write a value originating from the ALU
                write_enable = 1;                       // enable write on register
            end
            B: begin
                // This should never reach this module
            end
            Bcond: begin

            end
            BR: begin
                // This should never reach this module
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

/*
 * Apparantly, ID is not supposed to have any muxes
 * -> this would require NO data busses inside of this bad boi
 * -> so every output would have to be a selection bit/bus to a mux on the outside???
 * Genuinely so frustrating
 * ANYWAY, this may have to be semi/completely redesigned so.. that's cool.
 *
 * Also need to remember that the ALU has to take either a value from the imm field or the registers
 * -> controlled by a mux on the input | Can use muxes in the EXE.v and feed into the ALU component (?)
 */