
//
//         21 Jully MMXXIV PUBLIC DOMAIN by JML
//
// The authors disclaim copyright and patents to this software.
//
// Anyone is free to copy, modify, publish, use, compile, sell, or
// distribute this software, either in source code form or as a
// compiled binary, for any purpose, commercial or non-commercial,
// and by any means.
// 
// The authors waive all rights to patents, both currently owned 
// by the authors or acquired in the future, that are necessarily 
// infringed by this software, relating to make, have made, repair,
// use, sell, import, transfer, distribute or configure hardware 
// or software in finished or intermediate form, whether by run, 
// manufacture, assembly, testing, compiling, processing, loading 
// or applying this software or otherwise.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES 
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT OF ANY PATENT, COPYRIGHT, TRADE SECRET OR OTHER
// PROPRIETARY RIGHT.  IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR 
// ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF 
// CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION 
// WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

// "Digital design and computer architecture" page 419
// "The RISC-V reader : An open architecture atlas" page 16

module c5_fetch (
    input I_clk,
    input I_rst,

    output [31:0] O_adr,
    output O_stb,
    input [31:0] I_instr,
    input I_stall_instr,

    input I_stall,
    input [31:0] I_pc_branch,
    input I_pc_src,

    output reg [31:0] O_instr,
    output [31:0] O_pc_plus_4

);

  `include "c5_parameters.v"

  wire [31:0] pc_;
  wire [31:0] pc_plus_4;
  reg  [31:0] pc_current;
  reg  [31:0] pc_fetched_plus_4;

  //assign O_pc_plus_4 = pc_plus_4;
  assign O_pc_plus_4 = pc_fetched_plus_4;
  assign O_adr = pc_current;

  assign pc_plus_4 = pc_current + 5'd4;
  assign pc_ = I_pc_src ? I_pc_branch : pc_plus_4;
  
  always @(posedge (I_clk)) begin
    if (I_rst) begin
      O_instr <= NOP;
    end else begin
      O_instr <= I_instr;
      if (I_stall || I_stall_instr) begin
        O_instr <= NOP;
      end
    end
  end

  always @(posedge (I_clk)) begin
    if (I_rst) begin
      pc_current <= 32'd0;
    end else begin
      pc_current <= pc_;
      pc_fetched_plus_4 <= pc_current;
      if (I_stall || I_stall_instr) begin
        pc_current <= pc_current;
      end
    end
  end

endmodule
