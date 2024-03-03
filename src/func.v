// module which implements function a^3 + root(2, b)
// Restrictions:
// - single mult unit
// - 2 sum units

module func (
    input [31:0] a,
    input [31:0] b,
    output [31:0] f
);

    wire [31:0] a3;
    wire [31:0] broot2;
    wire [31:0] f1;
    wire [31:0] f2;

    mult mult1 (a, a, a3);

    sum sum1 (a3, broot2, f1);
    sum sum2 (f1, a3, f2);

    assign f = f2;

endmodule
