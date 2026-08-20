module weight_multiply_unit (
    input  wire              clk,
    input  wire              reset,
    input  wire signed [7:0] weight,
    input  wire              signal_in,
    output reg  signed [7:0] out
);

always @(posedge clk or posedge reset) begin
    if (reset) begin
        out <= 0;
    end else begin
        if (signal_in)
            out <= weight;
        else
            out <= 0;
    end
end

endmodule