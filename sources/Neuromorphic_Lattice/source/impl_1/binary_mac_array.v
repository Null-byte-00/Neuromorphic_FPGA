module weight_multiply_arry #(
	parameter IN_SIZE = 2,
	parameter OUT_SIZE = 3
)(
input wire clk,
input wire reset,
input wire [(8*IN_SIZE*OUT_SIZE) - 1:0] weights_in,
input wire [(IN_SIZE - 1):0] input_signals,output reg [((8*OUT_SIZE) -1):0] added_outputs
);

wire [7:0] weights [(IN_SIZE*OUT_SIZE) -1:0];
wire [7:0] unflatten_outputs[OUT_SIZE - 1:0];

// unflattening weights
genvar i;
generate
    for (i = 0; i < (IN_SIZE * OUT_SIZE); i = i + 1) begin : unflatten_weights
        assign weights[i] = weights_in[(i * 8) +: 8];
    end
endgenerate

genvar k;
generate
	for (k = 0; k < OUT_SIZE; k = k + 1) begin
		assign unflatten_outputs[k] = added_outputs[(k*8) +: 8];
	end
endgenerate

// creating the units
genvar j;
genvar z;
generate
	for (j = 0; j < OUT_SIZE; j = j + 1) begin
		for (z = 0; z < IN_SIZE; z = z + 1) begin
			binary_mac_unit mac (
				.clk (clk),
				.reset (reset),
				.weight (weights[z*j]),
				.signal_in (input_signals[z]),
				.out (unflatten_outputs[j])
			);
		end
	end
endgenerate
endmodule