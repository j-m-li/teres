// RS232 UART
//            4 May MMXXIII PUBLIC DOMAIN by O'ksi'D
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
// https://en.wikipedia.org/wiki/RS-232
//

module uart #(parameter 
	CLOCK_HZ = 48000000, 
	BAUDRATE = 115200
	) (
	input I_clk, // clock
	input I_rst, // reset
    input I_cyc, // valid bus cycle
	input I_stb, // strobe == chip select
	input I_we,  // write enable  
    output reg O_ack,   // operation complete
    input [7:0] I_dat,
	output reg [7:0] O_dat,

	
    output reg O_data_ready,
    output reg O_busy_write,
    input I_in_pin,
	output reg O_out_pin
);

wire [16:0] period;
localparam  [31:0] CLOCK_PERIOD = CLOCK_HZ / BAUDRATE;
assign period = CLOCK_PERIOD[16:0];

always @(posedge I_clk) begin
	if (I_rst) begin
		O_ack <= 0;
    end else begin
		O_ack <= I_stb;
    end
end

// TX
reg [3:0] out_state;
reg [16:0] out_cnt;
reg [8:0] out_shift;

always @(posedge I_clk) begin
	if (I_rst) begin
		out_shift <= 9'b111111111;
		out_state <= 0;
		out_cnt <= 0;
		O_out_pin <= 1;
		O_busy_write <= 1;
	end else if (out_state != 0) begin
		out_cnt <= out_cnt + 1'b1;
		O_out_pin <= out_shift[0];
		if (out_cnt == period) begin
			if (out_state == 4'd12) begin
				out_state <= 0;
			end else if (out_state == 4'd11) begin
				out_cnt <= 0;
				out_state <= out_state + 1'b1;
				O_busy_write <= 0;
			end else begin
				out_cnt <= 0;
				out_shift <= {1'b1, out_shift[8:1]};
				out_state <= out_state + 1'b1;
			end
		end
	end else if (I_stb && I_we) begin
		out_state <= 4'd1;
		out_cnt <= 0;
		O_busy_write <= 1;
		out_shift <= {I_dat[7:0], 1'b0};
//		$display("TX: %h", I_data_out[7:0]);
	end else begin
		O_busy_write <= 0;
		out_shift <= 9'b111111111;
	end
end

// RX 
wire [16:0] half;
assign half = {1'b0, period[16:1]};

reg [7:0] in_buffer;
reg [7:0] in_shift;
reg in_p0;
reg in_p1;
reg [3:0] in_state;
reg [16:0] in_cnt;

always @(posedge I_clk) begin
	if (I_rst) begin
		in_state <= 4'd0;
		in_cnt <= 0;
		O_data_ready <= 0;
		in_shift <= 0;
		in_p1 <= 0;
		O_dat <= 0;
		in_p0 <= 0;
	end else begin
		in_p0 <= I_in_pin;
		in_p1 <= in_p0;
		in_cnt <= in_cnt + 1'b1;
		if (in_state == 1) begin
			if (in_cnt == half) begin
				if (~I_in_pin) begin
					in_cnt <= 0;
					in_state <= 2;
				end else begin
					in_state <= 0;
				end
			end else begin
				if (I_in_pin) begin
					in_state <= 0;
				end
			end
		end else if (in_state == 10) begin 
			if (in_cnt == period) begin
				if (I_in_pin) begin
					O_data_ready <= 1;
					O_dat <= in_shift;
				end
				in_state <= 0;
			end
		end else if (in_state != 0) begin
			if (in_cnt == period) begin
				in_cnt <= 0;
				in_state <= in_state + 1'b1;
				in_shift = {I_in_pin, in_shift[7:1]};
			end
		end else begin
			if (~in_p0 & in_p1) begin
				in_state <= 1;
				in_cnt <= 0;
			end
		end
		if (I_stb && !I_we && O_data_ready) begin
			O_data_ready <= 0;
		end
	end
end

endmodule

