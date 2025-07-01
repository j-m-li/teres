module c5_soc (
    input I_clk,
    input I_rst,

    output O_cyc,  // valid bus cycle
    output O_stb,  // strobe == chip select
    output [3:0] O_we,  // write enable
    input I_stall,  // wait a cycle
    input I_ack,  // operation complete
    input [31:0] I_dat,  // data from external memory
    output reg [31:0] O_adr,  // data address
    output reg [31:0] O_dat,  // data to external memeory

    input  I_uart_rx,
    output O_uart_tx,

    inout [31:0] IO_gpio,

    output O_spi_mosi,
    input  I_spi_miso,
    output O_spi_sck,
    output O_spi_cs_sdcard,
    output O_spi_cs_ext1,
    output O_spi_cs_ext2,


    inout IO_usb_dp,
    inout IO_usb_dn,

    output O_tmds_clk_p,
    output O_tmds_clk_n,
    output [2:0] O_tmds_data_p,
    output [2:0] O_tmds_data_n,
    input I_clk_pixel,
    input I_clk_pixel_x5
);

  `include "c5_parameters.v"

  reg [31:0] beam_address;
  reg display_fill;
  wire display_sync;
  wire display_read;
  wire [31:0] display_data;
  wire display_empty;

  display u0_display (
      .I_clk(I_clk),
      .I_rst_n(!I_rst),
      .I_clk_pixel(I_clk_pixel),
      .I_clk_pixel_x5(I_clk_pixel_x5),
      .O_sync(display_sync),
      .O_read(display_read),
      .I_data(display_data),
      .I_empty(display_empty),

      .O_tmds_clk_p (O_tmds_clk_p),
      .O_tmds_clk_n (O_tmds_clk_n),
      .O_tmds_data_p(O_tmds_data_p),
      .O_tmds_data_n(O_tmds_data_n)
  );

  reg display_write;
  reg [31:0] display_data_in;
  wire display_full;
  wire display_half_full;

  async_fifo #(
      .DATA_WIDTH(32),
      .POINTER_WIDTH(5)
  ) fifo_inst (
      .I_write_clk  (I_clk),
      .I_write_rst_n(!I_rst && !display_sync),
      .I_cmd_write  (display_write),
      //.I_write_data(display_data_in),
      .I_write_data (32'h77777777),
      .O_write_full (display_full),

      .O_half_full(display_half_full),

      .I_read_clk  (I_clk_pixel),
      .I_read_rst_n(!I_rst && !display_sync),
      .I_cmd_read  (display_read),
      .O_read_data (display_data),
      .O_read_empty(display_empty)
  );

  reg interrupt;
  wire [31:0] adr_data;
  wire [3:0] we_data;
  wire [31:0] dat_out_data;
  reg [31:0] dat_in_data;
  wire stb_data;
  wire stall_data;

  reg bsram_enable;
  wire [31:0] ram_data_r;

  assign cpu_pause = 0;

  wire [31:0] adr_instr;
  reg [31:0] dat_in_instr;
  wire stb_instr;
  wire stall_instr;

  c5_cpu u1_cpu (
      .I_clk(I_clk),
      .I_rst(I_rst),
      .I_interrupt(interrupt),

      .O_adr(adr_data),
      .O_we(we_data),
      .O_dat(dat_out_data),
      .O_stb(stb_data),
      .I_dat(dat_in_data),
      .I_stall(stall_data),

      .O_adr_instr  (adr_instr),
      .O_stb_instr  (stb_instr),
      .I_dat_instr  (dat_in_instr),
      .I_stall_instr(stall_instr)
  );


  // fast internal ram	
  reg stb_bsram;
  reg [3:0] we_bsram;
  wire [31:0] dat_out_bsram;
  reg [31:0] dat_in_bsram;
  reg [31:0] adr_bsram;

  c5_ram u2_bsram (
      .I_clk(I_clk),
      .I_rst(I_rst),
      .I_stb(stb_bsram),
      .I_we (we_bsram),
      .I_adr(adr_bsram),
      .I_dat(dat_in_bsram),
      .O_dat(dat_out_bsram)
  );


  wire [7:0] uart_data_r;
  wire uart_busy_write;
  wire uart_data_ready;
  wire uart_ack;
  reg [3:0] uart_we;
  reg uart_stb;
  reg [7:0] uart_data_w;

  assign IO_gpio = {20'd0, beat, O_uart_tx, !uart_data_ready, uart_busy_write, uart_data_w};

  reg beat;
  reg [31:0] cnt;
  always @(posedge I_clk) begin
    cnt <= cnt + 1'b1;
    if (cnt >= 48_000_000) begin
      cnt  <= 32'd0;
      beat <= !beat;
    end

  end

  uart u3_uart (
      .I_clk(I_clk),
      .I_rst(I_rst),
      .I_dat(uart_data_w),
      .O_dat(uart_data_r),
      .O_ack(uart_ack),
      .I_cyc(1'b1),
      .I_stb(uart_stb),
      .I_we (uart_we[0]),

      .I_in_pin(I_uart_rx),
      .O_out_pin(O_uart_tx),
      .O_busy_write(uart_busy_write),
      .O_data_ready(uart_data_ready)
  );

  //assign O_uart_tx = I_uart_rx;


  always @(posedge I_clk) begin
    interrupt <= 0;
    if (uart_data_ready) begin
      interrupt <= 1;
    end
  end

  // bus arbiter
  reg [31:0] dat_in_bus;
  reg [31:0] dat_out_bus;
  reg [31:0] adr_bus;
  reg [3:0] we_bus;
  reg stb_bus;
  reg stall_bus;
  wire [2:0] request;
  wire [2:0] grant;

  assign request[0]  = stb_instr;
  assign stall_instr = stb_instr & (!grant[0] | stall_bus);
  assign request[1]  = stb_data;
  assign stall_data  = stb_data & (!grant[1] | stall_bus);
  assign request[2] = 0;
  
  c5_arbiter #(
      .WIDTH(3)
  ) arbiter (
      .I_clk(I_clk),
      .I_rst(I_rst),
      .I_stall(stall_bus),
      .I_request(request),
      .O_grant(grant)
  );

  always @(*) begin
    case (grant)
      'b1: begin
        dat_out_bus <= 0;
        dat_in_instr <= dat_in_bus;
        adr_bus <= adr_instr;
        we_bus <= 0;
        stb_bus <= stb_instr;
      end
      'b10: begin
        dat_in_data <= dat_in_bus;
        dat_out_bus <= dat_out_data;
        adr_bus <= adr_data;
        we_bus <= we_data;
        stb_bus <= stb_data;
      end
      default: begin
        dat_out_bus <= 0;
        adr_bus <= 0;
        we_bus <= 0;
        stb_bus <= 0;
      end
    endcase
  end

  always @(*) begin
    dat_in_bus <= 0;
    stall_bus <= 0;
    we_bsram <= 0;
    stb_bsram <= 0;
    uart_we <= 0;
    uart_stb <= 0;
    uart_data_w <= 8'd32;
    
    if (adr_bus < BSRAM_SIZE) begin
      adr_bsram = adr_bus;
      stb_bsram  <= 1;
      dat_in_bus <= dat_out_bsram;
    end else if (adr_bus == UART_ADR) begin
      if (we_bus) begin
        if (!uart_busy_write) begin
          uart_we <= 1;
          uart_stb <= 1;
          uart_data_w <= dat_out_bus[7:0];
        end
      end else begin
        if (uart_data_ready) begin
          dat_in_bus <= {24'd0, uart_data_r};
          uart_stb   <= 1;
        end else begin
          dat_in_bus <= UART_FAULT;
        end
      end
    end else begin
      //stall_bus <= 1;
    end
  end
endmodule

