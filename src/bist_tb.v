`timescale 1ns / 1ps

module bist_tb;

  reg clk = 1;
  reg rst;
  reg [7:0] a = 0;
  reg [7:0] b = 0;
  reg test = 0;
  wire [15:0] out;

  bist bist (
      .clk(clk),
      .rst(rst),
      .a(a),
      .b(b),
      .test(test),
      .out(out)
  );

  always begin
    #1 clk = !clk;
  end
  initial begin
    rst = 1;
    #20 rst = 0;
    #20 a = 8'h2;
    b = 8'h3;
    #200000 $display("Output: %d^3 + sqrt(%d) = %d", a, b, a, out);
    #20 test = 1;
    #350 test = 0;
    #250000 $display("Output: test %d, crc8 %b", out[15:8], out[7:0]);
    #20 test = 1;
    #350 test = 0;
    #100 a = 8'h8e;
    b = 8'hc2;
    #1000 $display("Output: %d^3 + sqrt(%d) = %d", a, b, a, out);
    #20 test = 1;
    #350 test = 0;
    #250000 $display("Output: test %d, crc8 %b", out[15:8], out[7:0]);
    #20 test = 1;
    #350 test = 0;

    $display("END");
  end
endmodule

