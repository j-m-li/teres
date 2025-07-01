module c5_decode (
    input I_clk,
    input I_rst,

    input I_stall,
    input [31:0] I_pc_plus_4,
    input [31:0] I_instr

);

  `include "c5_parameters.v"

reg [31:0] instr;
reg [31:0] pc_plus_4;

always @(posedge(I_clk)) begin
    if (I_rst) begin
        instr <= NOP;
        pc_plus_4 <= 32'd0;
    end else begin
        instr <= I_instr;
        pc_plus_4 <= I_pc_plus_4;
        if (I_stall) begin
            instr <= instr;
            pc_plus_4 <= pc_plus_4;
        end
    end
end

endmodule