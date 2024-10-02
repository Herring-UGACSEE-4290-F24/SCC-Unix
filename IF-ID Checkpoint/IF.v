module IF(clk, b_relAddr, b_absAddr, b_cond, b_abs, pc);

    input               clk;            // Clock signal
    input               b_cond;         // Branch Condition Status
    input               b_abs;          // Branch is Absolute or not
    input [15:0]        b_relAddr;      // Amount to branch relative to current PC
    input [31:0]        b_absAddr;      // Address to branch to on absolute branch (to value in register)

    output reg [31:0]   pc;             // Program Counter: points to an address in instruction memory

    always @(posedge clk)
    begin

        if (b_cond)
        begin
            if (b_abs)
            begin
                pc = b_absAddr;
            end else
            begin
                pc = pc + (4 * b_relAddr);
            end
        end else
        begin
            pc = pc + 4;
        end

    end

endmodule