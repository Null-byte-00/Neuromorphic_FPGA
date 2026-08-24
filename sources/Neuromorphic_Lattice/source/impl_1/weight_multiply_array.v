`include "constants.vh"

module weight_multiply_array #(
    parameter IN_SIZE  = `NUM_INPUTS,
    parameter OUT_SIZE = `NUM_OUTPUTS
)(
    input  wire                              clk,
    input  wire                              reset,
    input  wire [(8*IN_SIZE*OUT_SIZE)-1:0]   weights_in,
    input  wire [IN_SIZE-1:0]                input_signals,
    output reg  [(16*OUT_SIZE)-1:0]          added_outputs
);

localparam integer NUM_UNITS = IN_SIZE * OUT_SIZE;

wire signed [7:0] weights      [0:NUM_UNITS-1];
wire signed [7:0] unit_outputs [0:NUM_UNITS-1];


// Unflatten weights
genvar i;
generate
    for (i = 0; i < NUM_UNITS; i = i + 1) begin : GEN_WEIGHTS
        assign weights[i] =
            $signed(weights_in[(i * 8) +: 8]);
    end
endgenerate


// Create one unit for every input-output connection
genvar j;
genvar z;
generate
    for (j = 0; j < OUT_SIZE; j = j + 1) begin : GEN_OUTPUT
        for (z = 0; z < IN_SIZE; z = z + 1) begin : GEN_INPUT

            weight_multiply_unit wmu (
                .clk       (clk),
                .reset     (reset),
                .weight    (weights[(j * IN_SIZE) + z]),
                .signal_in (input_signals[z]),
                .out       (unit_outputs[(j * IN_SIZE) + z])
            );

        end
    end
endgenerate


// Sum the active weights for each output
integer k;
integer n;

always @(*) begin
    added_outputs = 0;

    for (k = 0; k < OUT_SIZE; k = k + 1) begin
        for (n = 0; n < IN_SIZE; n = n + 1) begin
            added_outputs[(k * 16) +: 16] =
                $signed(added_outputs[(k * 16) +: 16])
                +
                $signed({
                    {8{unit_outputs[(k * IN_SIZE) + n][7]}},
                    unit_outputs[(k * IN_SIZE) + n]
                });
        end
    end
end

endmodule