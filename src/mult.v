`timescale 1ns/1ns

module mult(
    input clk_i,
    input rst_i,

    input [7:0] a_i,
    input [7:0] b_i,
    input start_i,

    output busy_o,
    output reg [15:0] result_o
);

    localparam S_IDLE = 1'b0;
    localparam S_CALC = 1'b1;

    reg [2:0] current_bit_index;
    wire is_last_step;
    wire [7:0] part_sum;
    wire [15:0] shifted_part_sum;
    reg [7:0] a, b;
    reg [15:0] part_result;
    reg state;

    assign is_last_step = (current_bit_index == 3'b111);
    // Let's break down the expression {8{b[ctr]}}:
    // b[ctr] suggests that b is an array or vector of signals, and ctr is being used to index into this array.
    // 8{} denotes replication. It replicates whatever is inside the braces 8 times.
    assign part_sum = a & {8{b[current_bit_index]}};
    assign shifted_part_sum = {{8{1'b0}}, part_sum} << current_bit_index;
    assign busy_o = state;

    always @(posedge clk_i) begin
        if (rst_i) begin
            current_bit_index <= 0;
            part_result <= 0;
            result_o <= 0;

            state <= S_IDLE;
        end else begin
            case (state)
                S_IDLE: begin
                    if (start_i) begin
                        state <= S_CALC;
                        a <= a_i;
                        b <= b_i;
                    end
                end
                S_CALC: begin
                    if (is_last_step) begin
                        state <= S_IDLE;
                        result_o <= part_result + shifted_part_sum;
                    end

                    part_result <= part_result + shifted_part_sum;
                    current_bit_index <= current_bit_index + 1;
                end
            endcase
        end
    end
endmodule
