`timescale 1ns / 1ps

`define assert(a,
               b) if (a !== b) begin $display("assertion FAILED %h !== %h", a, b); $finish(1); end

module test_bench;

  `include "../common/src/cod5_parameters.v"

  reg clk;
  reg [31:0] a;
  reg [31:0] b;
  reg [5:0] f;
  reg [31:0] r;

  cod5_alu dut (
      .O_out(r),
      .I_a(a),
      .I_b(b),
      .I_func(f)
  );

  initial begin
    $monitor("%t: %h + %h = %h", $time, a, b, r);
    a = 32'b0000;
    b = 32'b0001;
    f = ALU_OP_ADD;
    #1 `assert(r, 32'b0001);
 
    b = 32'b0001;
    #1 `assert(r, 32'b0001);
    b = 32'b0010;
    a = 32'b0100;
    #1 `assert(r, 32'b0110);
    
    a = 32'b0001;
    b = 32'b0001;
    f = ALU_OP_SHFT;
    #1 `assert(r, 32'b0100);
    b = 32'b0100;
    #1 `assert(r, 32'b0100_0000);
    b = 32'b0110;
    #1 `assert(r, 32'b0001_0000);
    b = 32'b010000;
    #1 `assert(r, 32'b0100_0000_0000_0000_0000);
    a = 32'haaaaaaaa;
    b = 32'b000110;
    #1 `assert(r, 32'haaaa_aaa0);

    a = 32'b0001;
    b = 32'b0001;
    f = ALU_OP_SLT;
    #1 `assert(r, 32'h0);
    b = 32'b0110;
    f = ALU_OP_SLT;
    #1 `assert(r, 32'h1);
    b = 32'b0010;
    f = ALU_OP_SLT;
    #1 `assert(r, 32'h0);


    #1 #1 $finish;
  end
  ;

  initial begin
    clk = 0;
    forever clk = #1 ~clk;
  end
endmodule
