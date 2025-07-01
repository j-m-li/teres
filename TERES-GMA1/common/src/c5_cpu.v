module c5_cpu #(
    parameter WIDTH = 32
) (
    input I_clk,  // clock
    input I_rst,  // reset
    output O_cyc,  // valid bus cycle
    output O_stb,  // strobe == chip select
    output [3:0] O_we,  // write enable
    input I_stall,  // wait a cycle
    input I_ack,  // operation complete
    input [31:0] I_dat,
    output reg [31:0] O_adr,
    output reg [31:0] O_dat,

    output reg [31:0] O_adr_instr,
    output O_stb_instr,
    input [31:0] I_dat_instr,
    input I_stall_instr,

    input I_interrupt
);

  `include "c5_parameters.v"

  wire stall_f;
  wire [31:0] instr_f;
  wire [31:0] pc_plus_4_f;

  wire [31:0] pc_branch_d;
  wire pc_src_d;
  
  
  // FETCH
  assign O_stb_instr = 1;
  assign stall_f = I_stall_instr;

  c5_fetch f (
      .I_clk(I_clk),
      .I_rst(I_rst),

      .O_adr(O_adr_instr),
      .O_stb(O_stb_instr),
      .I_instr(I_dat_instr),
      .I_stall_instr(I_stall_instr),

      .I_stall(stall_f),
      .I_pc_branch(pc_branch_d),
      .I_pc_src(pc_src_d),

      .O_instr(instr_f),
      .O_pc_plus_4(pc_plus_4_f)
  );

`ifdef DEBUG
always @(posedge(I_clk)) begin
    $display("I %h %h %d", pc_plus_4_f, instr_f, stall_f);
end
`endif 

// DECODE
assign pc_src_d = 0;
assign pc_branch_d = 0;

assign O_stb = 1;

endmodule
