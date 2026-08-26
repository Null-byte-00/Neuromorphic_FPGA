`include "constants.vh"

module network_tb #(
    parameter integer HIDDEN_SIZE = `HIDDEN_SIZE,
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


wire [7:0] streamed_weight;
wire [`RAM_ADDRESS_WIDTH-1:0] streamed_weight_index;
wire streamed_weight_valid;
wire manager_weights_loaded;

wire layer1_load_valid;
wire layer2_load_valid;

wire layer1_weights_loaded;
wire layer2_weights_loaded;


assign layer1_load_valid =
    streamed_weight_valid
    && (streamed_weight_index < LAYER1_NUM_WEIGHTS);

assign layer2_load_valid =
    streamed_weight_valid
    && (streamed_weight_index >= LAYER1_NUM_WEIGHTS);


assign weights_loaded =
    manager_weights_loaded
    && layer1_weights_loaded
    && layer2_weights_loaded;


weight_manager_unit #(
    .NUM_WEIGHTS  (TOTAL_NUM_WEIGHTS),
    .INIT_ADDRESS (INIT_ADDRESS)
) wmu (
    .clk            (clk),
    .reset          (reset),
    .ram_data       (ram_output_line),

    .ram_addr       (ram_addr_line),
    .write_enable   (ram_write_enable),

    .weight_data    (streamed_weight),
    .weight_index   (streamed_weight_index),
    .weight_valid   (streamed_weight_valid),
    .weights_loaded (manager_weights_loaded)
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


reg layer1_start;
reg layer2_start;

wire layer1_busy;
wire layer2_busy;

wire layer1_done;
wire layer2_done;

weight_multiply_array #(
    .IN_SIZE   (`NUM_INPUTS),
    .OUT_SIZE  (HIDDEN_SIZE),
    .SUM_WIDTH (16)
) layer1_wma (
    .clk               (clk),
    .reset             (reset),

    .weight_load_valid (layer1_load_valid),
    .weight_load_data  (streamed_weight),
    .weights_loaded    (layer1_weights_loaded),

    .start             (layer1_start),
    .input_signals     (network_inputs),

    .added_outputs     (layer1_currents),
    .busy              (layer1_busy),
    .done              (layer1_done)
);

spike_array #(
    .SIZE(HIDDEN_SIZE)
) hidden_neurons (
    .clk        (clk),
    .reset      (reset),
    .enable     (layer1_done),
    .ins        (layer1_currents),
    .spikes_out (hidden_spikes)
);


// layer 2

wire [(16*`NUM_OUTPUTS)-1:0] layer2_currents;
wire [`NUM_OUTPUTS-1:0] output_spikes;


weight_multiply_array #(
    .IN_SIZE   (HIDDEN_SIZE),
    .OUT_SIZE  (`NUM_OUTPUTS),
    .SUM_WIDTH (16)
) layer2_wma (
    .clk               (clk),
    .reset             (reset),

    .weight_load_valid (layer2_load_valid),
    .weight_load_data  (streamed_weight),
    .weights_loaded    (layer2_weights_loaded),

    .start             (layer2_start),
    .input_signals     (hidden_spikes),

    .added_outputs     (layer2_currents),
    .busy              (layer2_busy),
    .done              (layer2_done)
);


spike_array #(
    .SIZE(`NUM_OUTPUTS)
) output_neurons (
    .clk        (clk),
    .reset      (reset),
    .enable     (layer2_done),
    .ins        (layer2_currents),
    .spikes_out (output_spikes)
);


localparam [1:0] WAIT_WEIGHTS = 2'd0;
localparam [1:0] WAIT_LAYER1  = 2'd1;
localparam [1:0] WAIT_LAYER2  = 2'd2;

reg [1:0] control_state;

always @(posedge clk) begin
    if (reset) begin
        control_state <= WAIT_WEIGHTS;
        layer1_start  <= 1'b0;
        layer2_start  <= 1'b0;
    end else begin
        // Default: start signals are one-clock pulses.
        layer1_start <= 1'b0;
        layer2_start <= 1'b0;

        case (control_state)

            WAIT_WEIGHTS: begin
                if (weights_loaded) begin
                    layer1_start  <= 1'b1;
                    control_state <= WAIT_LAYER1;
                end
            end

            WAIT_LAYER1: begin
                if (layer1_done) begin
                    layer2_start  <= 1'b1;
                    control_state <= WAIT_LAYER2;
                end
            end

            WAIT_LAYER2: begin
                if (layer2_done) begin
                    layer1_start  <= 1'b1;
                    control_state <= WAIT_LAYER1;
                end
            end

            default: begin
                control_state <= WAIT_WEIGHTS;
            end

        endcase
    end
end

assign network_outputs = output_spikes;

endmodule