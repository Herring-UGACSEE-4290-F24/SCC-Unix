module ID();

    input [31:0]    instruction;

    reg [1:0]        fld;           // 31-30
    reg              s;             // 29
    reg [3:0]        sld;           // 28-25
    reg [2:0]        alu_oc;        // 27-25
    reg [2:0]        dest_reg;      // 24-22
    reg [2:0]        mem_ptr_reg;   // 21-19
    reg [3:0]        br_ptr_reg;    // 24-21
    reg [15:0]       offset;        // 15-0
    reg [2:0]        src_reg;       // 24-22
    reg [15:0]       imm;           // 15-0
    reg [2:0]        op_1_reg;      // 21-19
    reg [2:0]        shift_amt_reg; // 21-19
    reg [2:0]        op_2_reg;      // 18-16
    reg [3:0]        cond_flags;    // 24-21


endmodule