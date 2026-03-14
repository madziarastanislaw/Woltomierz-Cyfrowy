`timescale 1ns / 1ps

module transcoder(
    input wire [11:0] data_in,
    output wire [7:0] char_one, //10^0
    output wire [7:0] char_dec, //10^-1
    output wire [7:0] char_cen, //10^-2
    output wire [7:0] char_mil  //10^-3
    );
    
    wire [31:0] voltage;
    
    assign voltage = (data_in * 32'd3300) >> 12;
    
    wire [3:0] digit_one;
    wire [3:0] digit_dec;
    wire [3:0] digit_cen;
    wire [3:0] digit_mil;
    
    
    assign digit_one = voltage / 1000;
    assign digit_dec = (voltage % 1000) / 100;
    assign digit_cen = (voltage % 100) / 10;
    assign digit_mil = (voltage % 10); 

    assign char_one = {4'h3, digit_one};
    assign char_dec = {4'h3, digit_dec};
    assign char_cen = {4'h3, digit_cen};
    assign char_mil = {4'h3, digit_mil};
    
endmodule
