`timescale 1ns / 1ns

`define assert(a, b) \
	if (a !== b) begin \
		$display("assertion FAILED %h !== %h", a, b); \
		$finish; \
	end

module test_bench;

  `include "c5_parameters.v"

  wire tx;
  reg rx;

  reg I_clk;
  reg I_rst;
  reg [31:0] gpio;

 c5_soc dut (
    .I_clk(I_clk),
    .I_rst(I_rst),

    .O_cyc(),  // valid bus cycle
    .O_stb(),  // strobe == chip select
    .O_we(),  // write enable
    .I_stall(1'b0),  // wait a cycle
    .I_ack(1'b1),  // operation complete
    .I_dat(32'd0), // data from external memory
    .O_adr(), // data address
    .O_dat(), // data to external memeory

    .I_uart_rx(1'b0),
    .O_uart_tx(),

    .IO_gpio(gpio),

    .O_spi_mosi(),
    .I_spi_miso(1'b0),
    .O_spi_sck(),
    .O_spi_cs_sdcard(),
    .O_spi_cs_ext1(),
    .O_spi_cs_ext2(),

    .IO_usb_dp(),
    .IO_usb_dn(),

    .O_tmds_clk_p(),
    .O_tmds_clk_n(),
    .O_tmds_data_p(),
    .O_tmds_data_n(),
    .I_clk_pixel(1'b0),
    .I_clk_pixel_x5(1'b0)
);

  //$display("bob %h.", {I_adr[31:2], 2'd0});
  wire [7:0] uart;
  assign uart = gpio[7:0];

  initial begin
    $display("START");
    $monitor("%t: %c %h", $time, uart, gpio);
    I_rst = 1;
   
    #100 I_rst = 0;

    #100 `assert(I_rst, 'd0);

    #500 $finish;
  end

  initial begin
    I_clk = 0;
    #5 forever I_clk = #5 ~I_clk;
  end


endmodule
