//
// 
//            29 October MMXXIII PUBLIC DOMAIN by O'ksi'D
//
//        The authors disclaim copyright to this software.
//
// Anyone is free to copy, modify, publish, use, compile, sell, or
// distribute this software, either in source code form or as a
// compiled binary, for any purpose, commercial or non-commercial,
// and by any means.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES 
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT OF ANY PATENT, COPYRIGHT, TRADE SECRET OR OTHER
// PROPRIETARY RIGHT.  IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR 
// ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF 
// CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION 
// WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
// References:
// https://stackoverflow.com/questions/36610527/how-to-initialize-contents-of-inferred-block-ram-bram-in-verilog
//
module c5_ram #(
    parameter WIDTH = 32
) (
    input I_clk,
    input I_rst,
    input I_stb,
    input [3:0] I_we,
    input [31:0] I_adr,
    input [WIDTH-1:0] I_dat,
    output reg [WIDTH-1:0] O_dat
);

  `include "c5_parameters.v"

  reg [31:0] ram[0:((BSRAM_SIZE)-1)];
  reg initialized = 0;

  always @(posedge I_clk) begin
    if (I_rst) begin
      O_dat <= 0;
      initialized <= 0;
    end else begin
      if (I_stb && I_we != 0) begin
        if (I_we[0]) begin
          ram[I_adr[31:2]][7:0] <= I_dat[7:0];
        end
        if (I_we[1]) begin
          ram[I_adr[31:2]][15:8] <= I_dat[15:8];
        end
        if (I_we[2]) begin
          ram[I_adr[31:2]][23:16] <= I_dat[23:16];
        end
        if (I_we[3]) begin
          ram[I_adr[31:2]][31:24] <= I_dat[31:24];
        end
        if (I_adr == 0) begin
          initialized <= 1;
        end
      end

      O_dat <= ram[I_adr[31:2]];

      if (!initialized) begin
        case ({I_adr[31:2],2'd0})
          `include "c5_firmware.v"
          default: begin
          end
        endcase
      end
    end
  end

endmodule

