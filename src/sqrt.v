// implements a simple square root algorithm
`timescale 1ns / 1ps

// использовать беззнаковые числа с разрядностью 8 бит
module sqrt (
    input clk_i,
    input rst_i,
    input [7:0] x_i,
    output ready_o,
    output reg [3:0] result_o
);
  // reg [3:0] result_o;
  reg  [7:0] acc2;

  // Keep track of which bit I'm working on.
  reg  [2:0] bitl;
  wire [3:0] _bit = 1 << bitl;
  wire [7:0] bit2 = 1 << (bitl << 1);

  // The output is ready when the bitl counter underflows.
  assign ready_o = bitl[1];

  wire [3:0] guess = result_o | _bit;
  wire [7:0] guess2 = acc2 + bit2 + ((result_o << bitl) << 1);

  initial begin
    result_o = 0;
    acc2 = 0;
    bitl = 3;
  end

  always @(rst_i or posedge clk_i)
    if (rst_i) begin
      result_o <= 0;
      acc2 <= 0;
      bitl <= 3;
    end else begin
      if (guess2 <= x_i) begin
        result_o <= guess;
        acc2 <= guess2;
      end
      bitl <= bitl - 1;
    end
endmodule

