`timescale 1ns / 1ps

`define assert(a, b) 	if (a !== b) begin $display("assertion FAILED %h !== %h", a, b); $finish(1); end

module test_bench;

  reg clk;
  reg [31:0] a;
  reg [31:0] b;
  wire [1:0] r;

  t3_compare dut (
      .O_out(r),
      .I_a  (a),
      .I_b  (b)
  );

  initial begin
    $monitor("%t: %h %h = %b", $time, a, b, r);
    a = 32'b0100;
    b = 32'b0100;  
    #1 `assert(r, 'b00);

    #1 a = 'b0000;
    #1 b = 'b0010;
    #1 `assert(r, 'b01);

    #1 a = 'b0000;
    #1 b = 'b0001;
    #1 `assert(r, 'b10);
   
    #1 a = 'b000001;
    #1 b = 'b000100;
    #1 `assert(r, 'b10)

    #1 a = 'b1010;
    #1 b = 'b0101;
    #1 `assert(r, 'b10)

    #1 a = 'b101010101010;
    #1 b = 'b001010101010;
    #1 `assert(r, 'b10)
   
    #1 a = 'b011010101010;
    #1 b = 'b001010101010;
    #1 `assert(r, 'b01)
   
    #1
    #1
    $finish;
  end
  ;

  initial begin
    clk = 0;
    forever clk = #1 ~clk;
  end
endmodule
