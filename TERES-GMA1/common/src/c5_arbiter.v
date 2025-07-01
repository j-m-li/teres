
// cpu_data cpu_instr display audio sdcard usb

module c5_arbiter #(
    parameter WIDTH = 3 // 3 is the minimum
) (
    input I_clk,
    input I_rst,
    input I_stall,
    input [WIDTH-1:0] I_request,
    output reg [WIDTH-1:0] O_grant
);

  `include "c5_parameters.v"

  reg [WIDTH-1:0] mask;
  reg [WIDTH-1:0] found;
  integer i;

  always @(posedge (I_clk)) begin
    if (I_rst) begin
      mask = 'b1;
      O_grant <= 0;
      found = 0;
    end else if (I_stall) begin
      mask = mask;
      O_grant <= mask;
      found = found;
    end else begin
      O_grant <= 0;
      if (found) begin
        mask = found;
      end else begin
        mask = 'b1;
      end
      found = 0;
      for (i = 0; i < WIDTH; i = i + 1) begin
        mask = {mask[WIDTH-2:0], mask[WIDTH-1]};
        if (!found && (mask & I_request)) begin
          O_grant <= mask;
          found = mask;
        end
      end
      
    end
  end

endmodule
