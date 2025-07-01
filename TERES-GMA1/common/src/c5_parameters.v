`define DEBUG

localparam [31:0] FRAMEBUFFER0 = 32'h00030000;
localparam [31:0] FRAMEBUFFER1 = 32'h00060000;

localparam [5:0]  BSRAM_DEPTH = 7;
localparam [31:0] BSRAM_SIZE = (1 << BSRAM_DEPTH);

localparam [31:0] UART_ADR = 32'h80000000;
localparam [31:0] UART_FAULT = 32'h00008000;

localparam [31:0] NOP = 32'h00000013;