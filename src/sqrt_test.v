`timescale 1ns/1ns

module sqrt_test;
    parameter CLK_PERIOD = 10; // Clock period in time units

    // Signals
    reg clk = 0;                // Clock signal
    reg rst = 1;                // Reset signal (active high)
    reg start;                  // Start signal
    reg [7:0] a;                // Input a
    wire busy;                  // Busy signal
    wire [3:0] result;         // Output result

    task wait_while_busy;
        #10;
        begin
            while (busy) begin
                #1;
                $write(".");
            end
            $display(" done!");
        end
    endtask

    // Instantiate the sqrt module
    sqrt s(
        .clk_i(clk),
        .rst_i(rst),
        .a_i(a),
        .start_i(start),
        .busy_o(busy),
        .y_bo(result)
    );

    // Clock generation
    always #((CLK_PERIOD/2)) clk = ~clk;

    // Test cases
    initial begin
        // Test case 1
        a = 9;
        start = 1;

        $display("Test1: waiting for result ");
        wait_while_busy();
        if (result !== 3) $display("Test case 1 failed: expected 0, got %d", result);
        else $display("Test case 1 passed");
    end
endmodule


