`include "constants.vh"

module spike_array #(
	parameter SIZE = `NUM_OUTPUTS
) (	
	input wire clk,
	input wire reset,
	input wire [(SIZE*8)-1:0] ins,
	output wire [SIZE-1:0] spikes_out
);

wire [15:0] current_16 [SIZE-1:0];
wire [SIZE-1:0] neuron_outs;


genvar i;
generate
for (i = 0; i < SIZE; i = i + 1) begin
	assign current_16[i] = {{8{ins[(i*8)+7]}},ins[(i*8) +: 8]};
	
	spike_neuron sn (
		.clk (clk),
		.reset (reset),
		.input_current (current_16[i]),
		.spike_out (neuron_outs[i])
	);
end
endgenerate

assign spikes_out = neuron_outs;


endmodule