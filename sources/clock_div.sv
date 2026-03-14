`timescale 1ns / 1ps

module clock_div(
    input wire clk,
    input wire rst,
    output reg en //"sclk" dla FPGA
    );
    
    reg [2:0] counter;
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter <= 0;
            en <= 0; 
        end else begin
            if (counter == 4) begin
                en <= 1;
                counter <= 0;
            end else begin
                en <= 0;
                counter <= counter + 1;
            end
        end
    end
    
endmodule
