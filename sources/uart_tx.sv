`timescale 1ns / 1ps

module uart_tx #(
    parameter CLOCK_FREQ = 100000000,
    parameter BAUD_RATE  = 9600
)(
    input wire clk,
    input wire rst,
    input wire start,
    input wire [7:0] data,
    output reg tx,
    output wire busy,
    output reg done
);

    localparam CLKS_PER_BIT = CLOCK_FREQ / BAUD_RATE;
    localparam IDLE = 0;
    localparam START_BIT = 1;
    localparam DATA_BITS = 2;
    localparam STOP_BIT = 3;

    reg [2:0] state = IDLE;
    reg [13:0] clk_count = 0;
    reg [2:0] bit_index = 0;
    reg [7:0] data_saved = 0;

    assign busy = (state != IDLE);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            tx <= 1;
            done <= 0;
            clk_count <= 0;
            bit_index <= 0;
        end else begin
            case (state)
                IDLE: begin
                    tx <= 1;
                    done <= 0;
                    clk_count <= 0;
                    bit_index <= 0;
                    if (start == 1) begin
                        data_saved <= data;
                        state <= START_BIT;
                    end
                end
                
                START_BIT: begin
                    tx <= 0;
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count <= 0;
                        state <= DATA_BITS;
                    end
                end
                
                DATA_BITS: begin
                    tx <= data_saved[bit_index];
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count <= 0;
                        if (bit_index < 7) begin
                            bit_index <= bit_index + 1;
                        end else begin
                            bit_index <= 0;
                            state <= STOP_BIT;
                        end
                    end
                end
                
                STOP_BIT: begin
                    tx <= 1;
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count <= 0;
                        done <= 1;
                        state <= IDLE;
                    end
                end
            endcase
        end
    end
endmodule