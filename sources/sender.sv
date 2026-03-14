`timescale 1ns / 1ps

module sender_fsm(
    input wire clk,
    input wire rst,
    input wire [7:0] char_one,
    input wire [7:0] char_dec,
    input wire [7:0] char_cen,
    input wire [7:0] char_mil,
    output reg [7:0] tx_data,
    output reg tx_start,
    input wire tx_done,
    input wire tx_busy
);

    reg [3:0] state;
    reg [25:0] delay_counter;

    localparam WAIT_TIME = 0;
    localparam SEND_ONE  = 1, WAIT_1   = 2;
    localparam SEND_DOT  = 3, WAIT_DOT = 4;
    localparam SEND_DEC  = 5, WAIT_2   = 6;
    localparam SEND_CEN  = 7, WAIT_3   = 8;
    localparam SEND_MIL  = 9, WAIT_4   = 10;
    localparam SEND_CR   = 11, WAIT_CR = 12;
    localparam SEND_LF   = 13, WAIT_LF = 14;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= WAIT_TIME;
            tx_start <= 0;
            delay_counter <= 0;
        end else begin
            case (state)
                WAIT_TIME: begin
                    tx_start <= 0;
                    
                    if (delay_counter == 20000000) begin
                        delay_counter <= 0;
                        state <= SEND_ONE;
                    end else begin
                        delay_counter <= delay_counter + 1;
                    end
                end
               
                SEND_ONE: begin
                    if (!tx_busy) begin
                        tx_data <= char_one;
                        tx_start <= 1;
                        state <= WAIT_1;
                    end
                end
                WAIT_1: begin
                    tx_start <= 0;
                    if (tx_done) state <= SEND_DOT;
                end
                
                SEND_DOT: begin
                    if (!tx_busy) begin
                        tx_data <= 8'h2E;
                        tx_start <= 1;
                        state <= WAIT_DOT;
                    end
                end
                WAIT_DOT: begin
                    tx_start <= 0;
                    if (tx_done) state <= SEND_DEC;
                end

                SEND_DEC: begin
                    if (!tx_busy) begin
                        tx_data <= char_dec;
                        tx_start <= 1;
                        state <= WAIT_2;
                    end
                end
                WAIT_2: begin
                    tx_start <= 0;
                    if (tx_done) state <= SEND_CEN;
                end

                SEND_CEN: begin
                    if (!tx_busy) begin
                        tx_data <= char_cen;
                        tx_start <= 1;
                        state <= WAIT_3;
                    end
                end
                WAIT_3: begin
                    tx_start <= 0;
                    if (tx_done) state <= SEND_MIL;
                end
                
                SEND_MIL: begin
                    if (!tx_busy) begin
                        tx_data <= char_mil;
                        tx_start <= 1;
                        state <= WAIT_4;
                    end
                end
                WAIT_4: begin
                    tx_start <= 0;
                    if (tx_done) state <= SEND_CR;
                end

                SEND_CR: begin
                    if (!tx_busy) begin
                        tx_data <= 8'h0D; 
                        tx_start <= 1;
                        state <= WAIT_CR;
                    end
                end
                WAIT_CR: begin
                    tx_start <= 0;
                    if (tx_done) state <= SEND_LF;
                end
               
                SEND_LF: begin
                    if (!tx_busy) begin
                        tx_data <= 8'h0A; 
                        tx_start <= 1;
                        state <= WAIT_LF;
                    end
                end
                WAIT_LF: begin
                    tx_start <= 0;
                    if (tx_done) state <= WAIT_TIME;
                end

            endcase
        end
    end
endmodule