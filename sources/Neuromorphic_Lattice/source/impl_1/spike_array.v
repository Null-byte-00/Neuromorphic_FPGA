`include "constants.vh"

module spike_array #(
    parameter SIZE = `NUM_OUTPUTS
)(
    input  wire                 clk,
    input  wire                 reset,
    input  wire [(SIZE*16)-1:0] ins,
    output wire [SIZE-1:0]      spikes_out
);

wire signed [15:0] current_16 [0:SIZE-1];
wire [SIZE-1:0] neuron_outs;

genvar i;
generate
    for (i = 0; i < SIZE; i = i + 1) begin : GEN_NEURONS

        assign current_16[i] =
            $signed(ins[(i * 16) +: 16]);

        spike_neuron sn (
            .clk           (clk),
            .reset         (reset),
            .input_current (current_16[i]),
            .spike_out     (neuron_outs[i])
        );

    end
endgenerate

assign spikes_out = neuron_outs;

endmodule