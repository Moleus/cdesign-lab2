`timescale 1ns / 1ps


module lfsr2(
    input  wire          clk,
    input  wire          rst,
    input  wire [7:0]   init,
    input  wire        shift,
    output wire [7:0] result
);

    reg [7:0] buffer;

    assign result = buffer;

    always @(posedge clk) begin
        if (rst) begin
            buffer <= init;
        end else if (shift) begin
            // y = 1 + x^2 + x^3 + x^7 + x^8

            buffer[0] <= 0;
            buffer[1] <= buffer[0];
            buffer[2] <= buffer[1] ^ buffer[7];
            buffer[3] <= buffer[2] ^ buffer[7];
            buffer[4] <= buffer[3];
            buffer[5] <= buffer[4];
            buffer[6] <= buffer[5];
            buffer[7] <= buffer[6] ^ buffer[7];
        end
    end
endmodule