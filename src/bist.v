`timescale 1ns / 1ps


module bist(
    input  wire          clk,
    input  wire          rst,
    input  wire [7:0]      a,
    input  wire [7:0]      b,
    input  wire         test,
    input  wire input_mode,
    output reg  [15:0]   out
);

    localparam CHOOSE_MODE = 0,
               START_CALC = 1,
               START_CALC_2 = 2,
               WAIT_RES = 3,
               OUT_RESULT = 4,
               TEST = 5,
               INIT_ITER = 6,
               PRINT_CRC = 7,
               COMP_LFSR = 8,
               DEBUG_LFSR_RES = 9,
               TEST_START = 10,
               WAIT_TEST = 11,
               CALC_CRC = 12,
               CHECK_TEST_ITER = 13,
               SHOW_TEST_RES = 14;

    reg  [3:0] state;
    wire       flt_test;
    reg        flt_test_prev;
    reg        test_mode;
    reg        default_mode;
    wire       flt_default_mode;
    reg        flt_default_mode_prev;
    reg  [7:0] test_cnt;

    reg  dut_rst;
    reg  dut_start;
    wire dut_busy;

    reg  [7:0]  dut_a;
    reg  [7:0]  dut_b;
    wire [23:0] dut_y;

    reg sr_rst;
    reg lfsr_shift;
    reg crc_shift;
    reg crc_bit;

    reg  [7:0] lfsr1_init;
    reg  [7:0] lfsr2_init;
    wire [7:0] lfsr1_result;
    wire [7:0] lfsr2_result;
    wire [7:0] crc_result;

    reg [7:0] test_iteration;
    reg [3:0] result_bit;

    button button1(
        .clk(clk),
        .rst(rst),
        .in(test),
        .out(flt_test)
    );
    button button2(
        .clk(clk),
        .rst(rst),
        .in(input_mode),
        .out(flt_default_mode)
    );

    func dut(
        .clk_i(clk),
        .rst_i(dut_rst),
        .a_bi(dut_a),
        .b_bi(dut_b),
        .start_i(dut_start),
        .y_bo(dut_y),
        .busy_o(dut_busy)
    );

    lfsr lfsr1(
        .clk(clk),
        .rst(sr_rst),
        .init(lfsr1_init),
        .shift(lfsr_shift),
        .result(lfsr1_result)
    );

    lfsr2 lfsr2(
        .clk(clk),
        .rst(sr_rst),
        .init(lfsr2_init),
        .shift(lfsr_shift),
        .result(lfsr2_result)
    );

    crc8 crc(
        .clk(clk),
        .rst(sr_rst),
    .bit(crc_bit),
.shift(crc_shift),
.result(crc_result)
);

always @(posedge clk) begin
    flt_test_prev <= flt_test;
    flt_default_mode_prev <=flt_default_mode;

    if (rst) begin
        out <= 0;
        state <= CHOOSE_MODE;
        test_mode <= 0;
        default_mode<=0;
        test_cnt <= 0;
        dut_rst <= 1;
        dut_start <= 0;
        dut_a <= 0;
        dut_b <= 0;
        sr_rst <= 0;
        lfsr_shift <= 0;
        crc_shift <= 0;
        crc_bit <= 0;
        lfsr1_init <= 0;
        lfsr2_init <= 0;
        test_iteration <= 0;
        result_bit <= 0;
    end else begin
        case (state)
            CHOOSE_MODE:
                begin
                    dut_rst <= 0;
                    if (~flt_test_prev && flt_test) begin
                        state <= TEST;
                    end
                    if (~flt_default_mode_prev && flt_default_mode) begin
                        state <= START_CALC;
                    end
                end

            START_CALC:
                begin
                    dut_a <= a;
                    dut_b <= b;
                    dut_start <= 1;
                    state <= START_CALC_2;
                end

            START_CALC_2:
                begin
                    dut_start <= 0;
                    state <= WAIT_RES;
                end

            WAIT_RES:
                begin
                    if (~dut_busy) begin
                        state <= OUT_RESULT;
                    end
                end

            OUT_RESULT:
                begin
                    out[15:0] <= dut_y;
                    state <= CHOOSE_MODE;
                end

            TEST:  // test mode
                begin
                    test_cnt <= test_cnt + 1;
                    sr_rst <= 1;
                    lfsr1_init <= 2;
                    lfsr2_init <= 2;
                    state <= INIT_ITER;
                end

            INIT_ITER:
                begin
                    out[15:8] <= test_cnt;
                    sr_rst <= 0;
                    test_iteration <= 0;
                    state <= PRINT_CRC;
                end

            PRINT_CRC:
                begin
                    out[7:0] <= crc_result;
                    lfsr_shift <= 1;
                    dut_rst <= 1;
                    state <= COMP_LFSR;
                end

            COMP_LFSR:
                begin
                    lfsr_shift <= 0;
                    dut_rst <= 0;
                    state <= DEBUG_LFSR_RES;
                end

            DEBUG_LFSR_RES:
                begin
                    dut_a <= lfsr1_result;
                    dut_b <= lfsr2_result;
                    $display("%d %d",lfsr1_result, lfsr2_result);
                    dut_start <= 1;
                    state <= TEST_START;
                end

            TEST_START:
                begin
                    dut_start <= 0;
                    state <= WAIT_TEST;
                end

            WAIT_TEST:
                begin
                    if (~dut_busy) begin
                        result_bit <= 0;
                        state <= CALC_CRC;
                    end
                end

            CALC_CRC:
                begin
                    crc_shift <= 1;
                    crc_bit <= dut_y[result_bit];
                    result_bit <= result_bit + 1;

                    if (&result_bit) begin
                        state <= CHECK_TEST_ITER;
                    end
                end

            CHECK_TEST_ITER:
                begin
                    crc_shift <= 0;
                    test_iteration <= test_iteration + 1;

                    if (&test_iteration) begin
                        state <= SHOW_TEST_RES;
                    end else begin
                        state <= PRINT_CRC;
                    end
                end

            SHOW_TEST_RES:
                begin
                    out[7:0] <= crc_result;
                    dut_rst <= 1;
                    state <= CHOOSE_MODE;
                end
        endcase
    end
end

endmodule

