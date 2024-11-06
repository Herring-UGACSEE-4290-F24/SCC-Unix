/*
 * This module is the implementation for the Instruction Decoder.
 */

module ID(instruction, reset, halt_flag, read_addr1, read_addr2, reg1_val, reg2_val, write_addr, write_data, write_data_sel, write_enable, wr_cpsr, data_addr, data_val, data_read, data_write, data_out, opcode, operand2, ir_op, re_cpsr_val, re_pc_val, id_pc_val, wr_pc, branch);

    input [31:0]        instruction;   // Instruction passed in from Instruction Memory 
    input               reset;         // Resets all main control lines
    output reg          halt_flag;     // Will halt the SCC

    //   FOR CONTROLLING REG_FILE SIGNALS  //
    // =================================== //
    // These signals will control what     //
    // data gets read and written to       //
    // the reg_file for the instruction    //
    // being decoded.                      //
    // - - - - - - - - - - - - - - - - - - //
    output reg [2:0]    read_addr1;        // First address to read from
    output reg [2:0]    read_addr2;        // Second address to read from
    input [31:0]        reg1_val;          // Value at first address' reg
    input [31:0]        reg2_val;          // Value at second address' reg
    output reg [2:0]    write_addr;        // Address to write to
    output reg [31:0]   write_data;        // Data to write at address
    output reg          write_data_sel;    // Determines if value being written to regs is from alu result or elsewhere
    output reg          write_enable;      // Enable writing data to address
    output reg          wr_cpsr;           // Enable writing to the cpsr
    // =================================== //

    // FOR CONTROLLING IM/DM BUSSES AND SIGNALS //
    // ======================================== //
    output reg [31:0]  data_addr;               // Controls the address of the data memory
    input [31:0]       data_val;                // Value from memory
    output reg         data_read;               // Enables reading to the data memory
    output reg         data_write;              // Enables writing to data memory
    output reg [31:0]  data_out;                // Value to write to data memory
    // ======================================== //

    // FOR SENDING CONTROLS AND VALUES TO ALU //
    // ====================================== //
    // These are either values for the ALU to //
    // operate on, or are control lines that  //
    // will change muxes that provide the val //
    // that the ALU uses.                     //
    // - - - - - - - - - - - - - - - - - - -  //
    output reg [2:0]    opcode;               // Opcode for the ALU
    output reg [31:0]   operand2;             // The second operand field of the ALU
    output reg          ir_op;                // Instruction/Register operand (control bit)
    // ====================================== //

    // FOR BRANCH CONTROLLING //
    // ====================== //
    input [31:0]        re_cpsr_val;          // Reads in the cpsr value
    reg                 branch_condition;     // Holds if the branch condition has been met
    input [31:0]        re_pc_val;            // Reads in the pc value
    reg [31:0]          b_offset;             // Holds the offset for branches
    output reg [31:0]   id_pc_val;            // Value to write to the pc
    output reg          wr_pc;                // Enable line to store into pc
    output reg          branch;               // Tells IF when a branch is happening
    // ====================== //

    // BITFIELD AGRUMENT SPLITTING //
    // =========================== //
    // This just grabs each of the //
    // arguments in the bit fields //
    // in the instruction encoding //
    // - - - - - - - - - - - - - - //
    wire [1:0]        fld;         // first-level-decode, bits 31-30
    wire              s;           // special single bit for data instructions, bits 29
    wire [3:0]        sld;         // single-level-decode, bits 28-25
    wire [2:0]        alu_oc;      // opcode for ALU, bits 27-25
    wire [2:0]        dest_reg;    // destination register, bits 24-22
    wire [2:0]        mem_ptr_reg; // pointer register for memory instructions, bits 21-19
    wire [2:0]        br_ptr_reg;  // branch pointer, bits 24-22
    wire [15:0]       offset;      // offset, bits 15-0
    wire [2:0]        src_reg;     // register to store source address, bits 24-22
    wire [15:0]       imm;         // immediate value, bits 15-0
    wire [2:0]        op_1_reg;    // operand one, bits 21-19
    wire [2:0]        op_2_reg;    // operand two, bits 18-16    
    wire [2:0]        shift_reg;   // register that holds value for shifting, bits 21-19
    wire [3:0]        cond_flags;  // condition flags for branching, bits 24-21
    // =========================== //

    /*
     * The following are the (34) instructions defined as thier begining 7-bit encoding.
     * In our encoding, "Don't cares" are to be treated as 0s. // DOUBLE CHECK WITH ASSEMBLER
     */
    parameter LOAD  = 'b1000000, STOR  = 'b1000001, MOV   = 'b0000000, MOVT  = 'b0000001, ADD   = 'b0010001;
    parameter ADDS  = 'b0011001, SUB   = 'b0010010, SUBS  = 'b0011010, AND   = 'b0010011, ANDS  = 'b0011011;
    parameter OR    = 'b0010100, ORS   = 'b0011100, XOR   = 'b0010101, XORS  = 'b0011101, LSL   = 'b0000100;
    parameter LSR   = 'b0000101, CLR   = 'b0000010, SET   = 'b0000011, ADD2  = 'b0110001, ADDS2 = 'b0111001;
    parameter SUB2  = 'b0110010, SUBS2 = 'b0111010, AND2  = 'b0110011, ANDS2 = 'b0111011, OR2   = 'b0110100;
    parameter ORS2  = 'b0111100, XOR2  = 'b0110101, XORS2 = 'b0111101, NOT   = 'b0110110, B     = 'b1100000;
    parameter Bcond = 'b1100001, BR    = 'b1100010, NOP   = 'b1100100, HALT  = 'b1101000;

    /*
     * The following are the possible conditionals that can be used.
     */
    parameter EQ = 'b0000, NE = 'b0001, CS = 'b0010, CC = 'b0011;
    parameter MI = 'b0100, PL = 'b0101, VS = 'b0110, VC = 'b0111;
    parameter HI = 'b1000, LS = 'b1001, GE = 'b1010, LT = 'b1011;

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
    assign br_ptr_reg =    instruction[24:22];
    assign offset =        instruction[15:0];
    assign src_reg =       instruction[24:22];
    assign imm =           instruction[15:0];
    assign op_1_reg =      instruction[21:19];
    assign op_2_reg =      instruction[18:16];
    assign shift_reg =     instruction[21:19];
    assign cond_flags =    instruction[24:21];

    always @(reset) begin
        write_enable = 0;
        data_write = 0;
        wr_cpsr = 0;
        wr_pc = 0;
        branch_condition = 0;
        halt_flag = 0;
    end

    always @(*) begin

        /*
         * Calculating the b_offset value for branch instructions
         */
        b_offset[31:16] = {16{instruction[15]}};          // Duplicates the msb (sign extension)
        b_offset[15:0] = instruction[15:0];               // Copying the immediate value

        // Set every important control line to 0 (?)
        // -> then an instruction can set it's controls how it needs
        // -> avoids write_enable being left high (very bad)
        write_enable = 0;
        data_write = 0;
        wr_cpsr = 0;
        branch_condition = 0;
        branch = 0;

        /*
         * Case statement to decide whether a branch should be taken
         */
        if (instruction[31:25] == 7'b1100001) begin
            case(cond_flags)
                EQ: begin
                    if (re_cpsr_val[30] == 1) begin
                        branch_condition = 1;
                    end
                end
                NE: begin
                    if (re_cpsr_val[30] == 0) begin
                        branch_condition = 1;
                    end
                end
                CS: begin
                    if (re_cpsr_val[29] == 1) begin
                        branch_condition = 1;
                    end
                end
                CC: begin
                    if (re_cpsr_val[29] == 0) begin
                        branch_condition = 1;
                    end
                end
                MI: begin
                    if (re_cpsr_val[31] == 1) begin
                        branch_condition = 1;
                    end
                end
                PL: begin
                    if (re_cpsr_val[31] == 0) begin
                        branch_condition = 1;
                    end
                end
                VS: begin
                    if (re_cpsr_val[28] == 1) begin
                        branch_condition = 1;
                    end
                end
                VC: begin
                    if (re_cpsr_val[28] == 0) begin
                        branch_condition = 1;
                    end
                end
                HI: begin
                    if (re_cpsr_val[30] == 0 && re_cpsr_val[29] == 1) begin
                        branch_condition = 1;
                    end
                end
                LS: begin
                    if (~(re_cpsr_val[30] == 0 && re_cpsr_val[29] == 1)) begin
                        branch_condition = 1;
                    end
                end
                GE: begin
                    if (re_cpsr_val[31] == re_cpsr_val[30]) begin
                        branch_condition = 1;
                    end
                end
                LT: begin
                    if (re_cpsr_val[31] != re_cpsr_val[30]) begin
                        branch_condition = 1;
                    end
                end
                default: begin
                    branch_condition = 0;
                end
            endcase
        end

        /*
         * Case statement to check the most significant 7-bits 
         * Sets control signals according to the given instruction
         */
        case (instruction[31:25])
            LOAD: begin
                write_addr = dest_reg;                  // destination register -> write address on register file
                read_addr1 = mem_ptr_reg;               // pointer register -> a read address on register file
                data_addr = reg1_val + imm;             // add offset to value read at pointer address and send sum to dataMem input address
                data_read = 1;                          // enable read from dataMem pass into write_data on register file
                write_data = data_val;                  // write value from DM to the register
                write_data_sel = 0;                     // makes value come from the ID
                write_enable = 1;                       // enable write on the register file
            end
            STOR: begin
                read_addr1 = src_reg;                   // source register -> a read address on register file
                read_addr2 = mem_ptr_reg;               // pointer register -> other read address on register file
                data_addr = reg2_val + imm;             // add offset to value read from pointer register + send sum to dataMem input address
                data_out = reg1_val;                    // send value from source register to data_input on dataMem
                data_write = 1;                         // enable write to dataMem
            end
            MOV: begin
                read_addr1 = dest_reg;                  // destination register -> read address on register file
                write_addr = dest_reg;                  // destination register -> write address on register file
                write_data[31:16] = reg1_val[31:16];    // copy value from most significant 2 bytes to remain constant
                write_data[15:0] = imm[15:0];           // immediate -> write_data on register file, stores into the least significant 2 bytes
                write_data_sel = 0;                     // write a value originating from the ID
                write_enable = 1;                       // enable write on register file
            end
            MOVT: begin
                read_addr1 = dest_reg;                  // destination register -> read address on register file
                write_addr = dest_reg;                  // destination register -> write address on register file
                write_data[15:0] = reg1_val[15:0];      // copy value from least significant 2 bytes to remain constant
                write_data[31:16] = imm[15:0];          // immediate -> write_data on register file, stores into the most significant 2 bytes
                write_data_sel = 0;                     // write a value originating from the ID
                write_enable = 1;                       // enable write on register file
            end
            ADD: begin
                opcode = alu_oc;                        // alu_oc -> ALU opcode input
                read_addr1 = op_1_reg;                  // op 1 register -> a read address on register file
                operand2 = imm;                         // immediate -> the ALU to be computed
                ir_op = 0;                              // to mux: makes ALU take imm operand
                write_addr = dest_reg;                  // destination register -> write address on register file
                write_data_sel = 1;                     // write a value originating from the ALU
                write_enable = 1;                       // enable write on register
            end
            ADDS: begin
                opcode = alu_oc;                        // alu_oc -> ALU opcode input
                read_addr1 = op_1_reg;                  // op 1 register -> a read address on register file
                operand2 = imm;                         // immediate -> the ALU to be computed
                ir_op = 0;                              // to mux: makes ALU take imm operand
                write_addr = dest_reg;                  // destination register -> write address on register file
                write_data_sel = 1;                     // write a value originating from the ALU
                write_enable = 1;                       // enable write on register
                wr_cpsr = 1;                            // enable write to cpsr
            end
            SUB: begin
                opcode = alu_oc;                        // alu_oc -> ALU opcode input
                read_addr1 = op_1_reg;                  // op 1 register -> a read address on register file
                operand2 = imm;                         // immediate -> the ALU to be computed
                ir_op = 0;                              // to mux: makes ALU take imm operand
                write_addr = dest_reg;                  // destination register -> write address on register file
                write_data_sel = 1;                     // write a value originating from the ALU
                write_enable = 1;                       // enable write on register
            end
            SUBS: begin
                opcode = alu_oc;                        // alu_oc -> ALU opcode input
                read_addr1 = op_1_reg;                  // op 1 register -> a read address on register file
                operand2 = imm;                         // immediate -> the ALU to be computed
                ir_op = 0;                              // to mux: makes ALU take imm operand
                write_addr = dest_reg;                  // destination register -> write address on register file
                write_data_sel = 1;                     // write a value originating from the ALU
                write_enable = 1;                       // enable write on register
                wr_cpsr = 1;                            // enable write to cpsr
            end
            AND: begin
                opcode = alu_oc;                        // alu_oc -> ALU opcode input
                read_addr1 = op_1_reg;                  // op 1 register -> a read address on register file
                operand2 = imm;                         // immediate -> the ALU to be computed
                ir_op = 0;                              // to mux: makes ALU take imm operand
                write_addr = dest_reg;                  // destination register -> write address on register file
                write_data_sel = 1;                     // write a value originating from the ALU
                write_enable = 1;                       // enable write on register
            end
            ANDS: begin
                opcode = alu_oc;                        // alu_oc -> ALU opcode input
                read_addr1 = op_1_reg;                  // op 1 register -> a read address on register file
                operand2 = imm;                         // immediate -> the ALU to be computed
                ir_op = 0;                              // to mux: makes ALU take imm operand
                write_addr = dest_reg;                  // destination register -> write address on register file
                write_data_sel = 1;                     // write a value originating from the ALU
                write_enable = 1;                       // enable write on register
                wr_cpsr = 1;                            // enable write to cpsr
            end
            OR: begin
                opcode = alu_oc;                        // alu_oc -> ALU opcode input
                read_addr1 = op_1_reg;                  // op 1 register -> a read address on register file
                operand2 = imm;                         // immediate -> the ALU to be computed
                ir_op = 0;                              // to mux: makes ALU take imm operand
                write_addr = dest_reg;                  // destination register -> write address on register file
                write_data_sel = 1;                     // write a value originating from the ALU
                write_enable = 1;                       // enable write on register
            end
            ORS: begin
                opcode = alu_oc;                        // alu_oc -> ALU opcode input
                read_addr1 = op_1_reg;                  // op 1 register -> a read address on register file
                operand2 = imm;                         // immediate -> the ALU to be computed
                ir_op = 0;                              // to mux: makes ALU take imm operand
                write_addr = dest_reg;                  // destination register -> write address on register file
                write_data_sel = 1;                     // write a value originating from the ALU
                write_enable = 1;                       // enable write on register
                wr_cpsr = 1;                            // enable write to cpsr
            end
            XOR: begin
                opcode = alu_oc;                        // alu_oc -> ALU opcode input
                read_addr1 = op_1_reg;                  // op 1 register -> a read address on register file
                operand2 = imm;                         // immediate -> the ALU to be computed
                ir_op = 0;                              // to mux: makes ALU take imm operand
                write_addr = dest_reg;                  // destination register -> write address on register file
                write_data_sel = 1;                     // write a value originating from the ALU
                write_enable = 1;                       // enable write on register
            end
            XORS: begin
                opcode = alu_oc;                        // alu_oc -> ALU opcode input
                read_addr1 = op_1_reg;                  // op 1 register -> a read address on register file
                operand2 = imm;                         // immediate -> the ALU to be computed
                ir_op = 0;                              // to mux: makes ALU take imm operand
                write_addr = dest_reg;                  // destination register -> write address on register file
                write_data_sel = 1;                     // write a value originating from the ALU
                write_enable = 1;                       // enable write on register
                wr_cpsr = 1;                            // enable write to cpsr
            end
            LSL: begin
                read_addr1 = shift_reg;                 // shift_reg -> a read address on register file
                write_addr = dest_reg;                  // dest_reg -> a write address on register file
                write_data_sel = 0;                     // data written comes from ID
                write_data = reg1_val << imm;           // write the returned value with a bit-shift
                write_enable = 1;                       // enable write on register
            end
            LSR: begin
                read_addr1 = shift_reg;                 // shift_reg -> a read address on register file
                write_addr = dest_reg;                  // dest_reg -> a write address on register file
                write_data_sel = 0;                     // data written comes from ID
                write_data = reg1_val >> imm;           // write the returned value with a bit-shift
                write_enable = 1;                       // enable write on register
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
                opcode = alu_oc;                        // alu_oc -> ALU opcode input
                read_addr1 = op_1_reg;                  // op 1 register -> a read address on register file
                read_addr2 = op_2_reg;                  // op 2 register -> other read address on register file
                ir_op = 1;                              // to mux: makes ALU take imm operand
                write_addr = dest_reg;                  // destination register -> write address on register file
                write_data_sel = 1;                     // write a value originating from the ALU
                write_enable = 1;                       // enable write on register
            end
            ADDS2: begin
                opcode = alu_oc;                        // alu_oc -> ALU opcode input
                read_addr1 = op_1_reg;                  // op 1 register -> a read address on register file
                read_addr2 = op_2_reg;                  // op 2 register -> other read address on register file
                ir_op = 1;                              // to mux: makes ALU take imm operand
                write_addr = dest_reg;                  // destination register -> write address on register file
                write_data_sel = 1;                     // write a value originating from the ALU
                write_enable = 1;                       // enable write on register
                wr_cpsr = 1;                            // enable write to cpsr
            end
            SUB2: begin
                opcode = alu_oc;                        // alu_oc -> ALU opcode input
                read_addr1 = op_1_reg;                  // op 1 register -> a read address on register file
                read_addr2 = op_2_reg;                  // op 2 register -> other read address on register file
                ir_op = 1;                              // to mux: makes ALU take imm operand
                write_addr = dest_reg;                  // destination register -> write address on register file
                write_data_sel = 1;                     // write a value originating from the ALU
                write_enable = 1;                       // enable write on register
            end
            SUBS2: begin
                opcode = alu_oc;                        // alu_oc -> ALU opcode input
                read_addr1 = op_1_reg;                  // op 1 register -> a read address on register file
                read_addr2 = op_2_reg;                  // op 2 register -> other read address on register file
                ir_op = 1;                              // to mux: makes ALU take imm operand
                write_addr = dest_reg;                  // destination register -> write address on register file
                write_data_sel = 1;                     // write a value originating from the ALU
                write_enable = 1;                       // enable write on register
                wr_cpsr = 1;                            // enable write to cpsr
            end
            AND2: begin
                opcode = alu_oc;                        // alu_oc -> ALU opcode input
                read_addr1 = op_1_reg;                  // op 1 register -> a read address on register file
                read_addr2 = op_2_reg;                  // op 2 register -> other read address on register file
                ir_op = 1;                              // to mux: makes ALU take imm operand
                write_addr = dest_reg;                  // destination register -> write address on register file
                write_data_sel = 1;                     // write a value originating from the ALU
                write_enable = 1;                       // enable write on register
            end
            ANDS2: begin
                opcode = alu_oc;                        // alu_oc -> ALU opcode input
                read_addr1 = op_1_reg;                  // op 1 register -> a read address on register file
                read_addr2 = op_2_reg;                  // op 2 register -> other read address on register file
                ir_op = 1;                              // to mux: makes ALU take imm operand
                write_addr = dest_reg;                  // destination register -> write address on register file
                write_data_sel = 1;                     // write a value originating from the ALU
                write_enable = 1;                       // enable write on register
                wr_cpsr = 1;                            // enable write to cpsr
            end
            OR2: begin
                opcode = alu_oc;                        // alu_oc -> ALU opcode input
                read_addr1 = op_1_reg;                  // op 1 register -> a read address on register file
                read_addr2 = op_2_reg;                  // op 2 register -> other read address on register file
                ir_op = 1;                              // to mux: makes ALU take imm operand
                write_addr = dest_reg;                  // destination register -> write address on register file
                write_data_sel = 1;                     // write a value originating from the ALU
                write_enable = 1;                       // enable write on register
            end
            ORS2: begin
                opcode = alu_oc;                        // alu_oc -> ALU opcode input
                read_addr1 = op_1_reg;                  // op 1 register -> a read address on register file
                read_addr2 = op_2_reg;                  // op 2 register -> other read address on register file
                ir_op = 1;                              // to mux: makes ALU take imm operand
                write_addr = dest_reg;                  // destination register -> write address on register file
                write_data_sel = 1;                     // write a value originating from the ALU
                write_enable = 1;                       // enable write on register
                wr_cpsr = 1;                            // enable write to cpsr
            end
            XOR2: begin
                opcode = alu_oc;                        // alu_oc -> ALU opcode input
                read_addr1 = op_1_reg;                  // op 1 register -> a read address on register file
                read_addr2 = op_2_reg;                  // op 2 register -> other read address on register file
                ir_op = 1;                              // to mux: makes ALU take imm operand
                write_addr = dest_reg;                  // destination register -> write address on register file
                write_data_sel = 1;                     // write a value originating from the ALU
                write_enable = 1;                       // enable write on register
            end
            XORS2: begin
                opcode = alu_oc;                        // alu_oc -> ALU opcode input
                read_addr1 = op_1_reg;                  // op 1 register -> a read address on register file
                read_addr2 = op_2_reg;                  // op 2 register -> other read address on register file
                ir_op = 1;                              // to mux: makes ALU take imm operand
                write_addr = dest_reg;                  // destination register -> write address on register file
                write_data_sel = 1;                     // write a value originating from the ALU
                write_enable = 1;                       // enable write on register
                wr_cpsr = 1;                            // enable write to cpsr
            end
            NOT: begin
                opcode = alu_oc;                        // alu_oc -> ALU opcode input
                read_addr1 = op_1_reg;                  // op 1 register -> a read address on register file
                write_addr = dest_reg;                  // destination register -> write address on register file
                write_data_sel = 1;                     // write a value originating from the ALU
                write_enable = 1;                       // enable write on register
            end
            B: begin
                id_pc_val = re_pc_val + b_offset;       // write the value of the program counter + offset to pc
            end
            Bcond: begin
                if (branch_condition) begin             // if condition (set in EXE) is met
                    branch = 1;
                    id_pc_val = re_pc_val + b_offset;   // write the value of the program counter + offset to pc
                    branch_condition = 0;
                end else begin
                    id_pc_val = re_pc_val + 4;
                end
            end
            BR: begin
                read_addr1 = br_ptr_reg;                // br_ptr_reg -> read address on reg file
                id_pc_val = reg1_val + b_offset;        // write the value of the program counter + offset to pc
            end
            NOP: begin
                                                        // Does nothing, literally!
            end
            HALT: begin
                halt_flag = 1;                          // Will send a signal that prevents the clock from updating
            end
            default:    $display("default case");
        endcase
    end

endmodule