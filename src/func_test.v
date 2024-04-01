`timescale 1ns / 1ps

module func_test ();
  reg clk = 0;
  reg rst;
  reg start;

  reg [7:0] a_w;
  reg [7:0] b_w;
  wire clk_w;
  wire rst_w;
  wire start_w;

  wire busy_w;
  wire [15:0] out_w;

  func fn (
      .clk_i(clk_w),
      .rst_i(rst_w),
      .a_bi(a_w),
      .b_bi(b_w),
      .start_i(start_w),
      .busy_o(busy_w),
      .y_bo(out_w)
  );

  assign clk_w   = clk;
  assign rst_w   = rst;
  assign start_w = start;

  task run_test;
    input [3:0] iter;
    input [7:0] test_a;
    input [7:0] test_b;
    input [15:0] expected;
    begin
      a_w = test_a;
      b_w = test_b;
      #5 start = 1;
      clk = 1;
      #5 clk = 0;
      start = 0;
      while (busy_w) begin
        #5 clk = 1;
        #5 clk = 0;
      end
      if (out_w != expected) begin
        $display("Error Test %d; Input a: %d, b: %d; Expected: %d; Actual: %d", iter, test_a,
                 test_b, expected, out_w);
      end else begin
        $display("Correct Test %d; Input a: %d, b: %d; Expected: %d; Actual: %d", iter, test_a,
                 test_b, expected, out_w);

      end
    end
  endtask

  initial begin
    rst = 1;
    clk = 1;
    #5 clk = 0;
    rst = 0;

    // Run tests using the task
    run_test(0, 2, 10, 11);
    run_test(1, 16, 143, 4107);
    run_test(2, 0, 0, 0);
    run_test(3, 1, 1, 2);
    run_test(4, 2, 2, 9);
  end
endmodule

