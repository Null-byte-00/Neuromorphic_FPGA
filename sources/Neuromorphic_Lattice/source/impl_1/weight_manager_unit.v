`include "constants.vh"

module weight_manager_unit #(
    parameter NUM_WEIGHTS = `NUM_INPUTS * `NUM_OUTPUTS,
	parameter INIT_ADDRESS = 0
)(
    input  wire                              clk,
    input  wire                              reset,
    input  wire [7:0]                        ram_data,

    output reg [`RAM_ADDRESS_WIDTH-1:0]       ram_addr,
    output reg                               write_enable,
    output reg [(8*NUM_WEIGHTS)-1:0]         weights_out,
    output reg                               weights_loaded
);

localparam [1:0] SET_ADDR = 2'd0;
localparam [1:0] WAIT_RAM = 2'd1;
localparam [1:0] CAPTURE  = 2'd2;
localparam [1:0] DONE     = 2'd3;

reg [1:0] state;
reg [`RAM_ADDRESS_WIDTH-1:0] weight_idx;

always @(posedge clk) begin
    if (reset) begin
        state          <= SET_ADDR;
        ram_addr       <= INIT_ADDRESS;
        weight_idx     <= 0;
        weights_out    <= 0;
        write_enable   <= 0;
        weights_loaded <= 0;
    end else begin
        write_enable <= 0;

        case (state)

            SET_ADDR: begin
                ram_addr <= INIT_ADDRESS + weight_idx;
                state <= WAIT_RAM;
            end

            WAIT_RAM: begin
                state <= CAPTURE;
            end

            CAPTURE: begin
                weights_out[(weight_idx * 8) +: 8] <= ram_data;

                if (weight_idx == NUM_WEIGHTS - 1) begin
                    weights_loaded <= 1;
                    state <= DONE;
                end else begin
                    weight_idx <= weight_idx + 1'b1;
                    state <= SET_ADDR;
                end
            end

            DONE: begin
                weights_loaded <= 1;
            end

            default: begin
                state <= SET_ADDR;
            end

        endcase
    end
end

endmodule