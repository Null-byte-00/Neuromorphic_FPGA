`include "constants.vh"

module weight_manager_unit #(
	parameter NUM_WEIGHTS = `NUM_INPUTS*`NUM_OUTPUTS
)(
	input wire clk,
	input wire reset,
	input wire [7:0] ram_data,
	output reg [3:0] ram_addr,
	output reg write_enable,
	output reg [(8*NUM_WEIGHTS) - 1:0] weights_out
); 

reg read_mode = 1;
reg [3:0] current_addr = 0;
reg [3:0] next_addr = 0;
reg [3:0] weight_idx = 0;

always @(posedge clk) begin
	write_enable = 0;
	if (read_mode) begin
		ram_addr <= current_addr;
		next_addr <= current_addr + 1;
		weight_idx <= current_addr;
		read_mode <= 0;
	end else begin
		weights_out[(weight_idx*8) +: 8] <= ram_data;
		current_addr <= next_addr;
		read_mode <= 1;
	end
	if (reset) begin
		weights_out <= 0;
		current_addr <= 0;
		next_addr <= 0;
		weight_idx <= 0;
	end
end


endmodule