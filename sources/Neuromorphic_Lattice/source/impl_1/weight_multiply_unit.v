module weight_multiply_unit #(
    parameter integer IN_SIZE     = 32,
    parameter integer SUM_WIDTH   = 16,
    parameter integer INDEX_WIDTH = 5
)(
    input  wire                          clk,
    input  wire                          reset,

    // Weight-memory loading interface
    input  wire                          weight_load_valid,
    input  wire [INDEX_WIDTH-1:0]        weight_load_addr,
    input  wire signed [7:0]             weight_load_data,

    // Sequential calculation interface
    input  wire                          step_enable,
    input  wire                          first_step,
    input  wire [INDEX_WIDTH-1:0]        input_index,
    input  wire                          signal_in,

    output wire signed [SUM_WIDTH-1:0]   sum_out
);

reg signed [7:0] weight_memory [0:IN_SIZE-1];

reg signed [SUM_WIDTH-1:0] accumulator;

wire signed [7:0] current_weight;
wire signed [SUM_WIDTH-1:0] extended_weight;
wire signed [SUM_WIDTH-1:0] selected_value;
wire signed [SUM_WIDTH-1:0] next_accumulator;


assign current_weight = weight_memory[input_index];

assign extended_weight = {
    {(SUM_WIDTH-8){current_weight[7]}},
    current_weight
};

assign selected_value =
    signal_in
        ? extended_weight
        : {SUM_WIDTH{1'b0}};

assign next_accumulator =
    first_step
        ? selected_value
        : accumulator + selected_value;

assign sum_out = accumulator;


always @(posedge clk) begin
    if (reset) begin
        accumulator <= 0;
    end else begin

        // Do not reset weight memory; it is filled before use.
        if (weight_load_valid) begin
            weight_memory[weight_load_addr] <= weight_load_data;
        end

        if (step_enable) begin
            accumulator <= next_accumulator;
        end
    end
end

endmodule