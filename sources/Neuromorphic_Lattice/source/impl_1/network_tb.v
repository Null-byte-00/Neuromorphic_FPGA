`include "constants.vh"

module network_tb #(
    parameter integer HIDDEN_SIZE = 20,
    parameter integer INIT_ADDRESS = 0
)(
    input  wire                       clk,
    input  wire                       reset,
    input  wire [`NUM_INPUTS-1:0]     network_inputs,

    output wire [`NUM_OUTPUTS-1:0]    network_outputs,
    output wire                       weights_loaded
);

localparam integer LAYER1_NUM_WEIGHTS =
    `NUM_INPUTS * HIDDEN_SIZE;

localparam integer LAYER2_NUM_WEIGHTS =
    HIDDEN_SIZE * `NUM_OUTPUTS;

localparam integer TOTAL_NUM_WEIGHTS =
    LAYER1_NUM_WEIGHTS + LAYER2_NUM_WEIGHTS;


// Ram

wire [`RAM_ADDRESS_WIDTH-1:0] ram_addr_line;
wire [7:0] ram_output_line;
wire ram_write_enable;

wire [7:0] ram_data_in;

assign ram_data_in = 8'd0;


// weight storage

wire [(8*TOTAL_NUM_WEIGHTS)-1:0] all_weights;

wire [(8*LAYER1_NUM_WEIGHTS)-1:0] layer1_weights;
wire [(8*LAYER2_NUM_WEIGHTS)-1:0] layer2_weights;


// First section contains input-to-hidden weights
assign layer1_weights =
    all_weights[0 +: (8*LAYER1_NUM_WEIGHTS)];

// Second section contains hidden-to-output weights
assign layer2_weights =
    all_weights[
        (8*LAYER1_NUM_WEIGHTS)
        +: (8*LAYER2_NUM_WEIGHTS)
    ];


// load weights

weight_manager_unit #(
    .NUM_WEIGHTS  (TOTAL_NUM_WEIGHTS),
    .INIT_ADDRESS (INIT_ADDRESS)
) wmu (
    .clk            (clk),
    .reset          (reset),
    .ram_data       (ram_output_line),
    .ram_addr       (ram_addr_line),
    .write_enable   (ram_write_enable),
    .weights_out    (all_weights),
    .weights_loaded (weights_loaded)
);


// ram

single_port_ram ram (
    .clk          (clk),
    .write_enable (ram_write_enable),
    .address      (ram_addr_line),
    .data_in      (ram_data_in),
    .data_out     (ram_output_line)
);



wire computation_reset;

assign computation_reset = reset | ~weights_loaded;


// layer 1

wire [(16*HIDDEN_SIZE)-1:0] layer1_currents;
wire [HIDDEN_SIZE-1:0] hidden_spikes;


weight_multiply_array #(
    .IN_SIZE  (`NUM_INPUTS),
    .OUT_SIZE (HIDDEN_SIZE)
) layer1_wma (
    .clk           (clk),
    .reset         (computation_reset),
    .weights_in    (layer1_weights),
    .input_signals (network_inputs),
    .added_outputs (layer1_currents),
	.weights_loaded(weights_loaded)
);


spike_array #(
    .SIZE (HIDDEN_SIZE)
) hidden_neurons (
    .clk        (clk),
    .reset      (computation_reset),
    .ins        (layer1_currents),
    .spikes_out (hidden_spikes)
);


// layer 2

wire [(16*`NUM_OUTPUTS)-1:0] layer2_currents;
wire [`NUM_OUTPUTS-1:0] output_spikes;


weight_multiply_array #(
    .IN_SIZE  (HIDDEN_SIZE),
    .OUT_SIZE (`NUM_OUTPUTS)
) layer2_wma (
    .clk           (clk),
    .reset         (computation_reset),
    .weights_in    (layer2_weights),
    .input_signals (hidden_spikes),
    .added_outputs (layer2_currents),
	.weights_loaded(weights_loaded)
);


spike_array #(
    .SIZE (`NUM_OUTPUTS)
) output_neurons (
    .clk        (clk),
    .reset      (computation_reset),
    .ins        (layer2_currents),
    .spikes_out (output_spikes)
);


assign network_outputs = output_spikes;

endmodule