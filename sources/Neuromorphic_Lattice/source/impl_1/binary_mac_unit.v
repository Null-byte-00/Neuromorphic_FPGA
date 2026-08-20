module weight_multiply_unit (
input wire clk,
input wire reset,
input wire signed [7:0] weight,
input wire signal_in,
output reg signed [7:0] out
); 

reg signed [7:0] out_next;

always @(posedge clk) begin 
	if (reset) begin
		out <= 0;
		out_next <= 0;
	end
	
	out <= out_next;
	
	if (signal_in) begin
		out_next <=  out + weight;
	end else begin
		out_next <= out;
	end
end

endmodule