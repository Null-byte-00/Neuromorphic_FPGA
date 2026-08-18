module weight_multiplier_unit (
input wire clk,
input wire reset,
input wire signed [7:0] weight,
input wire signal_in,
output reg signed [7:0] out
); 

always @(posedge clk) begin 
	if (reset) begin
		out <= 0;
	end
	
	if (signal_in) begin
		out <= weight;
	end else begin
		out <= 0;
	end
end

endmodule