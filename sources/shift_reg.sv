`timescale 1ns / 1ps

module shift_reg #(parameter N = 12) (
    input wire clk,
    input wire rst,
    input wire en,
    input wire shift_en,
    input wire data_in,
    input wire send_result,
    output wire [N-1 : 0] data_out
    );
    
    reg [N-1:0] internal;
    reg [N-1:0] final_state; 
    
    always @(posedge clk) begin
        if (rst) begin
            internal <= {N{1'b0}};
        end else if (shift_en && en) begin
            internal <= {internal[N-2:0], data_in};
        end
        if (send_result == 1) begin
            final_state <= internal;
        end
    end
    
    assign data_out = final_state;
endmodule
