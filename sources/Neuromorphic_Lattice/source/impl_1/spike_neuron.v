module spike_neuron #(
	parameter signed threshold = 32'sd100,
	parameter integer beta_shift = 8
)(
	input clk,
	input reset,
	input wire signed [15:0] input_current,
	output reg spike_out
);

reg signed [31:0] potential = 0;wire signed [31:0] potential_new;
wire signed [31:0] potential_decayed;
wire signed [31:0] input_current_extended;

assign input_current_extended =
    $signed({{16{input_current[15]}}, input_current});

assign potential_new =
    potential + input_current_extended;

assign potential_decayed =
    potential_new - (potential_new >>> beta_shift);



always @(posedge clk) begin
	if (reset) begin
		potential <= 0;
		spike_out <= 0;
	end else begin
		if (potential_decayed >= threshold) begin
			spike_out <= 1;
			potential <= 0;
		end else begin
			spike_out <= 0;
			potential <= potential_decayed;
		end
	end
end


endmodule