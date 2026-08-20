`include "constants.vh"

module network_tb (
input wire clk,
input wire [`NUM_INPUTS-1:0] network_inputs,
output reg [`NUM_OUTPUTS-1:0] network_outputs
);

reg do_reset = 1;
reg reset = 0;
wire [3:0] ram_addr_line;
wire [7:0] ram_output_line;
wire ram_write_enable;
wire [(`NUM_OUTPUTS*`NUM_INPUTS*8)-1:0] weight_line;
wire [(`NUM_OUTPUTS*8) - 1:0] wma_outputs;

wire [2:0] net_outs;
//wire [23:0] net_out_wire;

reg [7:0] ram_data_in = 0;

//assign net_out_wire = network_outputs;

weight_multiply_array wma (
	.clk (clk),
	.reset (reset),
	.added_outputs (wma_outputs),
	.weights_in (weight_line),
	.input_signals (network_inputs)
);

weight_manager_unit wmu (
	.clk (clk),
	.reset (reset),
	.ram_data (ram_output_line),
	.ram_addr (ram_addr_line),
	.write_enable (ram_write_enable),
	.weights_out (weight_line)
);

single_port_ram ram (
	.clk (clk),	
	.write_enable (ram_write_enable),
	.address (ram_addr_line),
	.data_in (ram_data_in),
	.data_out (ram_output_line)
);

spike_array sa (
	.clk(clk),
	.reset (reset),
	.ins (wma_outputs),
	.spikes_out (net_outs)
);


always @(posedge clk) begin 
	network_outputs = net_outs;
	if (do_reset) begin
		reset <= 1;
		do_reset <= 0;
	end else begin
		reset <= 0;
	end
end 

endmodule