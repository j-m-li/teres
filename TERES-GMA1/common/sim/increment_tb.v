`timescale 1ns / 1ps

`define assert(a,
               b) if (a !== b) begin $display("assertion FAILED %h !== %h", a, b); $finish(1); end

module test_bench;

  reg clk;
  reg [31:0] a;
  reg [31:0] r;
  reg [31:0] c;

  t3_increment dut (
      .O_out(r),
      .I_a  (a)
  );

  initial begin
    $monitor("%t: %h = %h", $time, a, r);
    a = 32'b0000;
    #1 `assert(r, 32'b0001);
    a = 32'b0001;
    #1 `assert(r, 32'b0110);
    a = 32'b0110;
    #1 `assert(r, 32'b0100);
    a = 32'b0100_0000_0000_0000;
    #1 `assert(r, 32'b0100_0000_0000_0001);
    a = 32'b0101_0101_0101_0100;
    #1 `assert(r, 32'b0101_0101_0101_0101);
    a = 32'b0101;
    #1 `assert(r, 32'b01_1010);
    a = 32'b0101_0101;
    #1 `assert(r, 32'b01_1010_1010);
    a = 32'h1555_5555;
    #1 `assert(r, 32'h6aaa_aaaa);
    a = 32'b00_0101_0101_0101_0101;
    #1 `assert(r, 32'b01_1010_1010_1010_1010);

    #1 #1 $finish;
  end
  ;

  initial begin
    clk = 0;
    forever clk = #1 ~clk;
  end
endmodule
