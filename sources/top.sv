`timescale 1ns / 1ps

module top #(parameter N = 12) (
input wire clk,
input wire rst,
input wire miso,
output wire sclk,
output wire cs,
output wire [7:0] leds,
output wire uart_txd
);

wire [N-1:0] internal;

wire [7:0] char_1, char_2, char_3, char_4;
wire [7:0] tx_byte;
wire tx_start_sig;
wire tx_done_sig;
wire tx_busy_sig;


spi_master SPI_M (
.clk(clk),
.rst(rst),
.miso(miso),
.sclk(sclk),
.cs(cs),
.data_out(internal)
);

 transcoder TRC (
 .data_in(internal),
 .char_one(char_1),
 .char_dec(char_2),
 .char_cen(char_3),
 .char_mil(char_4)
 );
 
 sender_fsm SENDER(
 .clk(clk),
 .rst(rst),
 .char_one(char_1),
 .char_dec(char_2),
 .char_cen(char_3),
 .char_mil(char_4),
 .tx_data(tx_byte),
 .tx_start(tx_start_sig),
 .tx_done(tx_done_sig),
 .tx_busy(tx_busy_sig)
 );
 
 uart_tx UART(
 .clk(clk),
 .rst(rst),
 .start(tx_start_sig),
 .data(tx_byte),
 .tx(uart_txd),
 .busy(tx_busy_sig),
 .done(tx_done_sig)
 );
 

assign leds = internal[11:4];

endmodule