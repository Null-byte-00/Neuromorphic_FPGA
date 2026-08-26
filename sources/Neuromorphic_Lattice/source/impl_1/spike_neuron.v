module spike_neuron #(
    parameter signed [31:0] threshold = 32'sd120,
    parameter integer beta_shift = 3
)(
    input  wire               clk,
    input  wire               reset,
    input  wire               enable,
    input  wire signed [15:0] input_current,
    output reg                spike_out
);

reg signed [31:0] potential;wire signed [31:0] potential_new;
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
    end else if (enable) begin
        if (potential_decayed >= threshold) begin
            spike_out <= 1;
            potential <= 0;
        end else begin
            spike_out <= 0;
            potential <= potential_decayed;
        end
    end else begin
        // Preserve potential between completed network timesteps.
        spike_out <= 0;
    end
end


endmodule