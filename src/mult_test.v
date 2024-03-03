`timescale 1ns/1ns


module mult_test;
    // Parameters
    parameter CLK_PERIOD = 10; // Clock period in time units

    // Signals
    reg clk = 0;                // Clock signal
    reg rst = 1;                // Reset signal (active high)
    reg start;                  // Start signal
    reg [7:0] a;                // Input a
    reg [7:0] b;                // Input b
    wire busy;                  // Busy signal
    wire [15:0] result;         // Output result

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

    // Instantiate the mult module
    mult dut (
        .clk_i(clk),
        .rst_i(rst),
        .a_i(a),
        .b_i(b),
        .start_i(start),
        .busy_o(busy),
        .result_o(result)
    );

    // Clock generation
    always #((CLK_PERIOD/2)) clk = ~clk;

//       always @(posedge rdy) begin
//          $display("sqrt(%d) --> %d", value, result);
//          $finish;
//       end

    // Test cases
    initial begin
        // Test case 1
        a = 0;
        b = 0;
        start = 1;

        $display("Test1: waiting for result ");
        wait_while_busy();
        if (result !== 0) $display("Test case 1 failed: expected 0, got %d", result);
        else $display("Test case 1 passed");

        // reset the module
        rst = 1;
        #10;
        rst = 0;

        // Test case 2
        a = 1;
        b = 1;
        start = 1;
        $write("Test2: waiting for result ");
        wait_while_busy();
        if (result !== 1) $display("Test case 2 failed: expected 1, got %d", result);
        else $display("Test case 2 passed");

        // reset the module
        rst = 1;
        #10;
        rst = 0;

        // Test case 3
        a = 2;
        b = 2;
        start = 1;
        $write("Test3: waiting for result ");
        wait_while_busy();
        if (result !== 4) $display("Test case 3 failed: expected 4, got %d", result);
        else $display("Test case 3 passed");

        // reset the module
        rst = 1;
        #10;
        rst = 0;

        // Test case 4
        a = 64;
        b = 64;
        start = 1;
        $write("Test4: waiting for result ");
        wait_while_busy();
        if (result !== 4096) $display("Test case 4 failed: expected 4096, got %d", result);
        else $display("Test case 4 passed");

        // reset the module
        rst = 1;
        #10;
        rst = 0;

        // Test case 5
        a = 127;
        b = 127;
        start = 1;
        $write("Test4: waiting for result ");
        wait_while_busy();
        if (result !== 16129) $display("Test case 5 failed: expected 16129, got %d", result);
        else $display("Test case 5 passed");

        // Finish the simulation
        $finish;
    end
endmodule


