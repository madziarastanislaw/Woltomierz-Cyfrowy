`timescale 1ns / 1ps

module spi_master #(parameter N = 12) (
    input wire clk,
    input wire rst,
    input wire miso,
    output reg sclk,
    output reg cs,
    output wire [N-1:0] data_out
    );
    
    localparam RESET = 0;
    localparam START = 1;
    localparam READING = 2;
    
    reg [1:0] state = 0;
    reg [4:0] bit_count;
    logic shift_en;
    logic send_result = 0;
    wire en;
    
    
    clock_div ClkDiv (.clk(clk), .rst(rst), .en(en));
    shift_reg ShReg (.clk(clk), .rst(rst), .en(en), .shift_en(shift_en), .data_in(miso), .data_out(data_out), .send_result(send_result));
        
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= RESET;
        end else if (en) begin
            if (state == RESET) begin
                sclk <= 1;
                cs <= 1;
                shift_en <= 0;
                bit_count <= 0;
                send_result <= 0;
                state <= START;
            end else if (state == START) begin
                cs <= 0;
                state <= READING;
            end else if (state == READING) begin
                sclk <= ~sclk;
                if (sclk == 0) begin
                    shift_en <= 1;
                end else begin
                    shift_en <= 0;
                    if (bit_count == 15) begin
                        cs <= 1;
                        send_result <= 1;
                        state <= RESET;
                    end else begin
                        bit_count <= bit_count + 1;
                    end
                end
            end
        end
    end              
           
    
endmodule
