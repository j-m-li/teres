
// https://homepage.cs.uiowa.edu/~dwjones/ternary/logic.shtml#inc
//
// - => 2'b10
// 0 => 2'b00
// + => 2'b01
// 

//////////////////////////////////////////////////////////
/// Monadic Operators
///

// Buffer
module t3_buf (
    input  [1:0] I_in,
    output [1:0] O_out
);

  assign O_out = I_in;

endmodule

// Negation
module t3_neg (
    input  [1:0] I_in,
    output [1:0] O_out
);

  assign O_out = {I_in[0], I_in[1]};

endmodule

// Increment
module t3_inc (
    input [1:0] I_in,
    output reg [1:0] O_out
);
  always @(*) begin
    case (I_in)
      2'b10:   O_out <= 2'b00;  /* - */
      2'b00:   O_out <= 2'b01;  /* 0 */
      default: O_out <= 2'b10;  /* + */
    endcase
  end
endmodule

// Decrement
module t3_dec (
    input [1:0] I_in,
    output reg [1:0] O_out
);
  always @(*) begin
    case (I_in)
      2'b10:   O_out <= 2'b01;  /* - */
      2'b00:   O_out <= 2'b10;  /* 0 */
      default: O_out <= 2'b00;  /* + */
    endcase
  end
endmodule


// Decoder: is false
module t3_is_false (
    input [1:0] I_in,
    output reg [1:0] O_out
);
  always @(*) begin
    case (I_in)
      2'b10:   O_out <= 2'b01;  /* - */
      2'b00:   O_out <= 2'b10;  /* 0 */
      default: O_out <= 2'b10;  /* + */
    endcase
  end
endmodule


// Decoder: is unknown
module t3_is_unknown (
    input [1:0] I_in,
    output reg [1:0] O_out
);
  always @(*) begin
    case (I_in)
      2'b10:   O_out <= 2'b10;  /* - */
      2'b00:   O_out <= 2'b01;  /* 0 */
      default: O_out <= 2'b10;  /* + */
    endcase
  end
endmodule

// Decoder: is true
module t3_is_true (
    input [1:0] I_in,
    output reg [1:0] O_out
);
  always @(*) begin
    case (I_in)
      2'b10:   O_out <= 2'b10;  /* - */
      2'b00:   O_out <= 2'b10;  /* 0 */
      default: O_out <= 2'b01;  /* + */
    endcase
  end
endmodule

// Decoder
module t3_decoder (
    input [1:0] I_in,
    output reg [1:0] O_false,
    output reg [1:0] O_unknown,
    output reg [1:0] O_true
);
  always @(*) begin
    O_false <= 2'b10;
    O_unknown <= 2'b10;
    O_true <= 2'b10;
    case (I_in)
      2'b10:   O_false <= 2'b01;  /* - */
      2'b00:   O_unknown <= 2'b01;  /* 0 */
      default: O_true <= 2'b01;  /* + */
    endcase
  end
endmodule

//Decoder: is not true
module t3_is_not_true (
    input [1:0] I_in,
    output reg [1:0] O_out
);
  always @(*) begin
    case (I_in)
      2'b10:   O_out <= 2'b01;  /* - */
      2'b00:   O_out <= 2'b01;  /* 0 */
      default: O_out <= 2'b10;  /* + */
    endcase
  end
endmodule

// Clamp down
module t3_clamp_down (
    input [1:0] I_in,
    output reg [1:0] O_out
);
  always @(*) begin
    case (I_in)
      2'b10:   O_out <= 2'b10;  /* - */
      2'b00:   O_out <= 2'b00;  /* 0 */
      default: O_out <= 2'b00;  /* + */
    endcase
  end
endmodule

// Clamp up
module t3_clamp_up (
    input [1:0] I_in,
    output reg [1:0] O_out
);
  always @(*) begin
    case (I_in)
      2'b10:   O_out <= 2'b00;  /* - */
      2'b00:   O_out <= 2'b00;  /* 0 */
      default: O_out <= 2'b01;  /* + */
    endcase
  end
endmodule

////////////////////////////////////////////////////////////////////
/// Diadic Operators
///

// Minimum
module t3_min (
    input [1:0] I_a,
    input [1:0] I_b,
    output reg [1:0] O_out
);
  always @(*) begin
    case ({
      I_a, I_b
    })
      4'b1010: O_out <= 2'b10;  /* - - */
      4'b1000: O_out <= 2'b10;  /* - 0 */
      4'b1001: O_out <= 2'b10;  /* - + */
      4'b0010: O_out <= 2'b10;  /* 0 - */
      4'b0000: O_out <= 2'b00;  /* 0 0 */
      4'b0001: O_out <= 2'b00;  /* 0 + */
      4'b0110: O_out <= 2'b10;  /* + - */
      4'b0100: O_out <= 2'b00;  /* + 0 */
      default: O_out <= 2'b01;  /* + + */
    endcase
  end
endmodule

// Maximum
module t3_max (
    input [1:0] I_a,
    input [1:0] I_b,
    output reg [1:0] O_out
);
  always @(*) begin
    case ({
      I_a, I_b
    })
      4'b1010: O_out <= 2'b10;  /* - - */
      4'b1000: O_out <= 2'b00;  /* - 0 */
      4'b1001: O_out <= 2'b01;  /* - + */
      4'b0010: O_out <= 2'b00;  /* 0 - */
      4'b0000: O_out <= 2'b00;  /* 0 0 */
      4'b0001: O_out <= 2'b01;  /* 0 + */
      4'b0110: O_out <= 2'b01;  /* + - */
      4'b0100: O_out <= 2'b01;  /* + 0 */
      default: O_out <= 2'b01;  /* + + */
    endcase
  end
endmodule

// Antimin
module t3_antimin (
    input [1:0] I_a,
    input [1:0] I_b,
    output reg [1:0] O_out
);
  always @(*) begin
    case ({
      I_a, I_b
    })
      4'b1010: O_out <= 2'b01;  /* - - */
      4'b1000: O_out <= 2'b01;  /* - 0 */
      4'b1001: O_out <= 2'b01;  /* - + */
      4'b0010: O_out <= 2'b01;  /* 0 - */
      4'b0000: O_out <= 2'b00;  /* 0 0 */
      4'b0001: O_out <= 2'b00;  /* 0 + */
      4'b0110: O_out <= 2'b01;  /* + - */
      4'b0100: O_out <= 2'b00;  /* + 0 */
      default: O_out <= 2'b10;  /* + + */
    endcase
  end
endmodule

// Antimax
module t3_antimax (
    input [1:0] I_a,
    input [1:0] I_b,
    output reg [1:0] O_out
);
  always @(*) begin
    case ({
      I_a, I_b
    })
      4'b1010: O_out <= 2'b01;  /* - - */
      4'b1000: O_out <= 2'b00;  /* - 0 */
      4'b1001: O_out <= 2'b10;  /* - + */
      4'b0010: O_out <= 2'b00;  /* 0 - */
      4'b0000: O_out <= 2'b00;  /* 0 0 */
      4'b0001: O_out <= 2'b10;  /* 0 + */
      4'b0110: O_out <= 2'b10;  /* + - */
      4'b0100: O_out <= 2'b10;  /* + 0 */
      default: O_out <= 2'b10;  /* + + */
    endcase
  end
endmodule

// Exclusive Or
module t3_xor (
    input [1:0] I_a,
    input [1:0] I_b,
    output reg [1:0] O_out
);
  always @(*) begin
    case ({
      I_a, I_b
    })
      4'b1010: O_out <= 2'b10;  /* - - */
      4'b1000: O_out <= 2'b00;  /* - 0 */
      4'b1001: O_out <= 2'b01;  /* - + */
      4'b0010: O_out <= 2'b00;  /* 0 - */
      4'b0000: O_out <= 2'b00;  /* 0 0 */
      4'b0001: O_out <= 2'b00;  /* 0 + */
      4'b0110: O_out <= 2'b01;  /* + - */
      4'b0100: O_out <= 2'b00;  /* + 0 */
      default: O_out <= 2'b10;  /* + + */
    endcase
  end
endmodule

// Sum
module t3_sum (
    input [1:0] I_a,
    input [1:0] I_b,
    output reg [1:0] O_out
);
  always @(*) begin
    case ({
      I_a, I_b
    })
      4'b1010: O_out <= 2'b01;  /* - - */
      4'b1000: O_out <= 2'b10;  /* - 0 */
      4'b1001: O_out <= 2'b00;  /* - + */
      4'b0010: O_out <= 2'b10;  /* 0 - */
      4'b0000: O_out <= 2'b00;  /* 0 0 */
      4'b0001: O_out <= 2'b01;  /* 0 + */
      4'b0110: O_out <= 2'b00;  /* + - */
      4'b0100: O_out <= 2'b01;  /* + 0 */
      default: O_out <= 2'b10;  /* + + */
    endcase
  end
endmodule

// Consensus
module t3_cons (
    input [1:0] I_a,
    input [1:0] I_b,
    output reg [1:0] O_out
);
  always @(*) begin
    case ({
      I_a, I_b
    })
      4'b1010: O_out <= 2'b10;  /* - - */
      4'b1000: O_out <= 2'b00;  /* - 0 */
      4'b1001: O_out <= 2'b00;  /* - + */
      4'b0010: O_out <= 2'b00;  /* 0 - */
      4'b0000: O_out <= 2'b00;  /* 0 0 */
      4'b0001: O_out <= 2'b00;  /* 0 + */
      4'b0110: O_out <= 2'b00;  /* + - */
      4'b0100: O_out <= 2'b00;  /* + 0 */
      default: O_out <= 2'b01;  /* + + */
    endcase
  end
endmodule

// Accept anything
module t3_any (
    input [1:0] I_a,
    input [1:0] I_b,
    output reg [1:0] O_out
);
  always @(*) begin
    case ({
      I_a, I_b
    })
      4'b1010: O_out <= 2'b10;  /* - - */
      4'b1000: O_out <= 2'b10;  /* - 0 */
      4'b1001: O_out <= 2'b00;  /* - + */
      4'b0010: O_out <= 2'b10;  /* 0 - */
      4'b0000: O_out <= 2'b00;  /* 0 0 */
      4'b0001: O_out <= 2'b01;  /* 0 + */
      4'b0110: O_out <= 2'b00;  /* + - */
      4'b0100: O_out <= 2'b01;  /* + 0 */
      default: O_out <= 2'b01;  /* + + */
    endcase
  end
endmodule


// Comparison: Equality
module t3_is_equal (
    input [1:0] I_a,
    input [1:0] I_b,
    output reg [1:0] O_out
);
  always @(*) begin
    O_out <= 2'b10;
    if (I_a == I_b) begin
      O_out <= 2'b01;
    end
  end
endmodule

//////////////////////////////////////////////////////
/// Addition and Increment
///

// Half adder
module t3_half_adder (
    input [1:0] I_a,
    input [1:0] I_c,
    output reg [1:0] O_out,
    output reg [1:0] O_c
);
  always @(*) begin
    O_c <= 2'b00;
    case ({
      I_a, I_c
    })
      4'b1010: begin  /* - - */
        O_out <= 2'b01;
        O_c   <= 2'b10;
      end
      4'b1000: O_out <= 2'b10;  /* - 0 */
      4'b1001: O_out <= 2'b00;  /* - + */
      4'b0010: O_out <= 2'b10;  /* 0 - */
      4'b0000: O_out <= 2'b00;  /* 0 0 */
      4'b0001: O_out <= 2'b00;  /* 0 + */
      4'b0110: O_out <= 2'b00;  /* + - */
      4'b0100: O_out <= 2'b01;  /* + 0 */
      default: begin  /* + + */
        O_out <= 2'b10;
        O_c   <= 2'b01;
      end
    endcase
  end
endmodule

// Full adder
module t3_full_adder (
    input [1:0] I_a,
    input [1:0] I_b,
    input [1:0] I_c,
    output reg [1:0] O_out,
    output reg [1:0] O_c
);
  always @(*) begin
    O_c   <= 2'b10;
    O_out <= 2'b10;
    case ({
      I_a, I_b, I_c
    })
      6'b000101: O_c <= 2'b01;  /* 0 + + */
      6'b010001: O_c <= 2'b01;  /* + 0 + */
      6'b010100: O_c <= 2'b01;  /* + + 0 */
      6'b010101: O_c <= 2'b01;  /* + + + */
      default: begin
        if (I_a == 2'b00 && I_b == 2'b00) begin
          O_c <= 2'b00;
        end else if (I_a == 2'b00 && I_c == 2'b00) begin
          O_c <= 2'b00;
        end else if (I_b == 2'b00 && I_c == 2'b00) begin
          O_c <= 2'b00;
        end else begin
          if (I_a == 2'b01 || I_b == 2'b01 || I_c == 2'b01) begin
            O_c <= 2'b00;
          end
        end
      end
    endcase
    case ({
      I_a, I_b, I_c
    })
      6'b101010: O_out <= 2'b00;  /* - - - */
      6'b101000: O_out <= 2'b01;
      6'b100010: O_out <= 2'b01;
      6'b100001: O_out <= 2'b00;
      6'b100100: O_out <= 2'b00;
      6'b100101: O_out <= 2'b01;
      6'b001010: O_out <= 2'b01;
      6'b001001: O_out <= 2'b00;
      6'b000000: O_out <= 2'b00;
      6'b000001: O_out <= 2'b01;
      6'b000110: O_out <= 2'b00;
      6'b000100: O_out <= 2'b01;
      6'b011000: O_out <= 2'b00;
      6'b000000: O_out <= 2'b00;
      6'b011000: O_out <= 2'b00;
      6'b011001: O_out <= 2'b01;
      6'b010010: O_out <= 2'b00;
      6'b010000: O_out <= 2'b01;
      6'b010110: O_out <= 2'b01;
      6'b010101: O_out <= 2'b00;
    endcase

  end
endmodule

////////////////////////////////////////////////
/// Compare two numbers
///

/*
  - => <
  0 => =
  + => >
 */
module t3_compare_x (
    input [1:0] I_a,
    input [1:0] I_b,
    output reg [1:0] O_out
);
  always @(*) begin
    case ({
      I_a, I_b
    })
      4'b1010: O_out <= 2'b10;  /* - - */
      4'b1000: O_out <= 2'b10;  /* - 0 */
      4'b1001: O_out <= 2'b01;  /* - + */
      4'b0010: O_out <= 2'b10;  /* 0 - */
      4'b0000: O_out <= 2'b00;  /* 0 0 */
      4'b0001: O_out <= 2'b01;  /* 0 + */
      4'b0110: O_out <= 2'b10;  /* + - */
      4'b0100: O_out <= 2'b01;  /* + 0 */
      default: O_out <= 2'b01;  /* + + */
    endcase
  end
endmodule

/*
  - => <
  0 => =
  + => >
 */
module t3_compare_y (
    input [1:0] I_a,
    input [1:0] I_b,
    output reg [1:0] O_out
);
  always @(*) begin
    case ({
      I_a, I_b
    })
      4'b1010: O_out <= 2'b00;  /* - - */
      4'b1000: O_out <= 2'b10;  /* - 0 */
      4'b1001: O_out <= 2'b10;  /* - + */
      4'b0010: O_out <= 2'b01;  /* 0 - */
      4'b0000: O_out <= 2'b00;  /* 0 0 */
      4'b0001: O_out <= 2'b10;  /* 0 + */
      4'b0110: O_out <= 2'b01;  /* + - */
      4'b0100: O_out <= 2'b01;  /* + 0 */
      default: O_out <= 2'b00;  /* + + */
    endcase
  end
endmodule

module t3_compare #(
    parameter WIDTH = 32
) (
    input [WIDTH-1:0] I_a,
    input [WIDTH-1:0] I_b,
    output [1:0] O_out
);
  //localparam STAGES = $clog2(WIDTH);
  //localparam POW = $pow(2, STAGES - 1);
  wire [WIDTH-1:0] c0;
  wire [(WIDTH/2)-1:0] c1;
  wire [(WIDTH/4)-1:0] c2;
  wire [(WIDTH/8)-1:0] c3;

  genvar i;
  genvar j;
  generate
    for (i = 0; i < WIDTH; i = i + 2) begin
      t3_compare_y uy (
          .I_a  (I_a[i+1:i]),
          .I_b  (I_b[i+1:i]),
          .O_out(c0[i+1:i])
      );
    end
  endgenerate
  generate
    for (i = 0; i < WIDTH; i = i + 4) begin
      t3_compare_x ux0 (
          .I_b  (c0[i+3:i+2]),
          .I_a  (c0[i+1:i]),
          .O_out(c1[(i/2)+1:(i/2)])
      );
    end
  endgenerate
  generate
    for (i = 0; i < WIDTH / 2; i = i + 4) begin
      t3_compare_x ux0 (
          .I_b  (c1[i+3:i+2]),
          .I_a  (c1[i+1:i]),
          .O_out(c2[(i/2)+1:(i/2)])
      );
    end
  endgenerate
  generate
    for (i = 0; i < WIDTH / 4; i = i + 4) begin
      t3_compare_x ux0 (
          .I_b  (c2[i+3:i+2]),
          .I_a  (c2[i+1:i]),
          .O_out(c3[(i/2)+1:(i/2)])
      );
    end
  endgenerate
  generate
    for (i = 0; i < WIDTH / 8; i = i + 4) begin
      t3_compare_x ux0 (
          .I_b  (c3[i+3:i+2]),
          .I_a  (c3[i+1:i]),
          .O_out(O_out)
      );
    end
  endgenerate
endmodule

////////////////////////////////////////
/// Carry lookahead
/// 

// Carry lookahead half adder
module t3_cl_half_adder (
    input [1:0] I_a,
    input [1:0] I_c,
    output reg [1:0] O_s,
    output reg [1:0] O_p
);
  always @(*) begin
    O_p <= I_a;
    case ({
      I_a, I_c
    })
      4'b1010: O_s <= 2'b01;  /* - - */
      4'b1000: O_s <= 2'b10;  /* - 0 */
      4'b1001: O_s <= 2'b00;  /* - + */
      4'b0010: O_s <= 2'b10;  /* 0 - */
      4'b0000: O_s <= 2'b00;  /* 0 0 */
      4'b0001: O_s <= 2'b01;  /* 0 + */
      4'b0110: O_s <= 2'b00;  /* + - */
      4'b0100: O_s <= 2'b01;  /* + 0 */
      default: O_s <= 2'b10;  /* + + */
    endcase
  end
endmodule

// Carry lookahed function x
module t3_cl_x (
    input  [1:0] I_p0,
    input  [1:0] I_p1,
    input  [1:0] I_c0,
    output [1:0] O_c1,
    output [1:0] O_p
);
  t3_cons uc (
      .I_a  (I_c0),
      .I_b  (I_p0),
      .O_out(O_c1)
  );
  t3_cons up (
      .I_a  (I_p1),
      .I_b  (I_p0),
      .O_out(O_p)
  );
endmodule

// Carry lookahed function y
module t3_cl_y (
    input  [1:0] I_p,
    input  [1:0] I_c,
    output [1:0] O_c
);
  t3_cons uy (
      .I_a  (I_c),
      .I_b  (I_p),
      .O_out(O_c)
  );
endmodule

// Increment 
module t3_increment #(
    parameter WIDTH = 32
) (
    input [WIDTH-1:0] I_a,
    output [WIDTH-1:0] O_out,
    output [1:0] O_carry
);
  wire [WIDTH-1:0] c;
  wire [WIDTH-1:0] p;
  wire [(WIDTH/2)-1:0] p00;
  wire [(WIDTH/4)-1:0] p01;
  wire [(WIDTH/8)-1:0] p02;
  wire [(WIDTH/16)-1:0] p03;

  assign c[1:0] = 2'b01;

  genvar i;
  generate
    for (i = 0; i < WIDTH; i = i + 2) begin
      t3_cl_half_adder ua (
          .I_a(I_a[i+1:i]),
          .I_c(c[i+1:i]),
          .O_p(p[i+1:i]),
          .O_s(O_out[i+1:i])
      );
    end
  endgenerate
  generate
    for (i = 0; i < WIDTH; i = i + 4) begin
      localparam j = i / 2;
      t3_cl_x ux1 (
          .I_p0(p[i+1:i]),
          .I_p1(p[i+3:i+2]),
          .I_c0(c[i+1:i]),
          .O_p (p00[j+1:j]),
          .O_c1(c[i+3:i+2])
      );
    end
  endgenerate

  generate
    for (i = 0; i < WIDTH; i = i + 8) begin
      localparam j = i / 4;
      localparam k = i / 2;
      t3_cl_x ux2 (
          .I_p0(p00[k+1:k]),
          .I_p1(p00[k+3:k+2]),
          .I_c0(c[i+1:i]),
          .O_p (p01[j+1:j]),
          .O_c1(c[i+5:i+4])
      );
    end
  endgenerate
  generate
    for (i = 0; i < WIDTH; i = i + 16) begin
      localparam j = i / 8;
      localparam k = i / 4;
      t3_cl_x ux3 (
          .I_p0(p01[k+1:k]),
          .I_p1(p01[k+3:k+2]),
          .I_c0(c[i+1:i]),
          .O_p (p02[j+1:j]),
          .O_c1(c[i+9:i+8])
      );
    end
  endgenerate
  generate
    for (i = 0; i < WIDTH; i = i + 32) begin
      localparam j = i / 16;
      localparam k = i / 8;
      t3_cl_x ux4 (
          .I_p0(p02[k+1:k]),
          .I_p1(p02[k+3:k+2]),
          .I_c0(c[i+1:i]),
          .O_p (p03[j+1:j]),
          .O_c1(c[i+17:i+16])
      );
    end

  endgenerate

  t3_cons uy (
      .I_a  (p03),
      .I_b  (c[1:0]),
      .O_out(O_carry)
  );
endmodule


// Addition
module t3_addition #(
    parameter WIDTH = 32
) (
    input [WIDTH-1:0] I_a,
    input [WIDTH-1:0] I_b,
    output [WIDTH-1:0] O_out,
    output [1:0] O_carry
);
  wire [WIDTH+1:0] c;

  assign c[1:0]  = 2'b00;
  assign O_carry = c[WIDTH+1:WIDTH];

  // FIXME ...
  genvar i;
  generate
    for (i = 0; i < WIDTH; i = i + 2) begin
      t3_full_adder ua (
          .I_a  (I_a[i+1:i]),
          .I_b  (I_b[i+1:i]),
          .I_c  (c[i+1:i]),
          .O_c  (c[i+3:i+2]),
          .O_out(O_out[i+1:i])
      );
    end
  endgenerate
endmodule
