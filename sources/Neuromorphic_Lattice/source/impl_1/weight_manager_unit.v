`include "constants.vh"

module weight_manager_unit #(
    parameter integer NUM_WEIGHTS  = `NUM_INPUTS * `NUM_OUTPUTS,
    parameter integer INIT_ADDRESS = 0
)(
    input  wire                              clk,
    input  wire                              reset,
    input  wire [7:0]                        ram_data,

    output reg [`RAM_ADDRESS_WIDTH-1:0]       ram_addr,
    output wire                              write_enable,

    output reg [7:0]                         weight_data,
    output reg [`RAM_ADDRESS_WIDTH-1:0]       weight_index,
    output reg                               weight_valid,
    output reg                               weights_loaded
);

localparam [1:0] SET_ADDR = 2'd0;
localparam [1:0] WAIT_RAM = 2'd1;
localparam [1:0] CAPTURE  = 2'd2;
localparam [1:0] DONE     = 2'd3;

reg [1:0] state;
reg [`RAM_ADDRESS_WIDTH-1:0] read_index;


// This module never writes to RAM.
assign write_enable = 1'b0;


always @(posedge clk) begin
    if (reset) begin
        state          <= SET_ADDR;
        read_index     <= 0;
        ram_addr       <= INIT_ADDRESS;

        weight_data    <= 0;
        weight_index   <= 0;
        weight_valid   <= 0;
        weights_loaded <= 0;
    end else begin
        // Weight valid is a one-clock pulse.
        weight_valid <= 1'b0;

        case (state)

            SET_ADDR: begin
                ram_addr <= INIT_ADDRESS + read_index;
                state <= WAIT_RAM;
            end

            WAIT_RAM: begin
                // Wait for synchronous RAM output.
                state <= CAPTURE;
            end

            CAPTURE: begin
                weight_data  <= ram_data;
                weight_index <= read_index;
                weight_valid <= 1'b1;

                if (read_index == NUM_WEIGHTS - 1) begin
                    state <= DONE;
                end else begin
                    read_index <= read_index + 1'b1;
                    state <= SET_ADDR;
                end
            end

            DONE: begin
                /*
                 * The last weight_valid pulse is consumed by the
                 * layer memories when this state is entered.
                 */
                weights_loaded <= 1'b1;
            end

            default: begin
                state <= SET_ADDR;
            end

        endcase
    end
end

endmodule