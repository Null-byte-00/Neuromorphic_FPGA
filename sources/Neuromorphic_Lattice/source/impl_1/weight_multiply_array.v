`include "constants.vh"

module weight_multiply_array #(
    parameter integer IN_SIZE   = `NUM_INPUTS,
    parameter integer OUT_SIZE  = `NUM_OUTPUTS,
    parameter integer SUM_WIDTH = 16
)(
    input  wire                              clk,
    input  wire                              reset,

    // Sequential weight-loading stream
    input  wire                              weight_load_valid,
    input  wire signed [7:0]                 weight_load_data,
    output reg                               weights_loaded,

    // Calculation control
    input  wire                              start,
    input  wire [IN_SIZE-1:0]                input_signals,

    output wire [(SUM_WIDTH*OUT_SIZE)-1:0]    added_outputs,
    output reg                               busy,
    output reg                               done
);


/*
 * Verilog-compatible ceiling log2 function.
 */
function integer clog2;
    input integer value;
    integer i;
    begin
        value = value - 1;

        for (i = 0; value > 0; i = i + 1)
            value = value >> 1;

        if (i == 0)
            clog2 = 1;
        else
            clog2 = i;
    end
endfunction


localparam integer IN_INDEX_WIDTH  = clog2(IN_SIZE);
localparam integer OUT_INDEX_WIDTH = clog2(OUT_SIZE);


// Weight-loading position
reg [IN_INDEX_WIDTH-1:0]  load_input_index;
reg [OUT_INDEX_WIDTH-1:0] load_output_index;


// Calculation state
reg [IN_SIZE-1:0]         latched_inputs;
reg [IN_INDEX_WIDTH-1:0]  input_index;

wire current_input_signal;
wire first_step;

assign current_input_signal = latched_inputs[input_index];
assign first_step = (input_index == 0);


// One accumulator/weight memory per output
wire signed [SUM_WIDTH-1:0] unit_sums [0:OUT_SIZE-1];
wire [OUT_SIZE-1:0] unit_load_valid;


genvar output_number;
generate
    for (
        output_number = 0;
        output_number < OUT_SIZE;
        output_number = output_number + 1
    ) begin : GEN_OUTPUT_UNITS

        /*
         * Only the currently selected output unit stores the
         * incoming weight.
         */
        assign unit_load_valid[output_number] =
            weight_load_valid
            && !weights_loaded
            && (load_output_index == output_number);

        weight_multiply_unit #(
            .IN_SIZE     (IN_SIZE),
            .SUM_WIDTH   (SUM_WIDTH),
            .INDEX_WIDTH (IN_INDEX_WIDTH)
        ) unit (
            .clk               (clk),
            .reset             (reset),

            .weight_load_valid (unit_load_valid[output_number]),
            .weight_load_addr  (load_input_index),
            .weight_load_data  (weight_load_data),

            .step_enable       (busy),
            .first_step        (first_step),
            .input_index       (input_index),
            .signal_in         (current_input_signal),

            .sum_out           (unit_sums[output_number])
        );

        assign added_outputs[
            (output_number * SUM_WIDTH) +: SUM_WIDTH
        ] = unit_sums[output_number];

    end
endgenerate


always @(posedge clk) begin
    if (reset) begin
        load_input_index  <= 0;
        load_output_index <= 0;
        weights_loaded    <= 0;

        latched_inputs    <= 0;
        input_index       <= 0;
        busy              <= 0;
        done              <= 0;
    end else begin
        done <= 1'b0;

        /*
         * Weights arrive sequentially:
         *
         * output 0, input 0
         * output 0, input 1
         * ...
         * output 1, input 0
         * ...
         */
        if (weight_load_valid && !weights_loaded) begin
            if (load_input_index == IN_SIZE - 1) begin
                load_input_index <= 0;

                if (load_output_index == OUT_SIZE - 1) begin
                    weights_loaded <= 1'b1;
                end else begin
                    load_output_index <= load_output_index + 1'b1;
                end
            end else begin
                load_input_index <= load_input_index + 1'b1;
            end
        end


        /*
         * Start a new vector calculation.
         *
         * The first weight is processed on the next clock.
         */
        if (start && weights_loaded && !busy) begin
            latched_inputs <= input_signals;
            input_index    <= 0;
            busy           <= 1'b1;
        end else if (busy) begin

            if (input_index == IN_SIZE - 1) begin
                busy <= 1'b0;
                done <= 1'b1;
            end else begin
                input_index <= input_index + 1'b1;
            end

        end
    end
end

endmodule