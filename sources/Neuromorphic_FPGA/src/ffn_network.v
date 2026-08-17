// simple network with sift bsed decay

module ffn_22_netwok #(
    parameter w1 = 8'sd5,
    parameter w2 = 8'sd6,
    parameter w3 = 8'sd7,
    parameter w4 = 8'sd8,
    parameter threshold = 11'sd50,
    parameter beta_shift = 3
)(
    input wire clk,
    input wire reset,
    input wire  in1,
    input wire in2,
    output reg out1,
    output reg out2
);

reg signed [9:0] u1;
reg signed [9:0] u2;

wire signed [10:0] u1_new;
wire signed [10:0] u2_new;

wire signed [10:0] u1_decayed;
wire signed [10:0] u2_decayed;

// u1: 10 bit to 11 bit
// w1,w3: 8 bit to 11 bit
assign u1_new = {u1[9],u1} + (in1 ? {{3{w1[7]}}, w1} : 11'sd0) + (in2 ? {{3{w3[7]}}, w3} : 11'sd0) - ({u1[9],u1} >> beta_shift);
assign u2_new = {u2[9],u2} + (in2 ? {{3{w2[7]}}, w2} : 11'sd0) + (in2 ? {{3{w4[7]}}, w4} : 11'sd0) - ({u1[9],u1} >> beta_shift);


//assign u1_sum = $signed(u1) + $signed(w1);
//assign u1_sum = $signed(u1) + $signed(w1);

always @(posedge clk) begin
    
     if (reset) begin
        u1   <= 10'sd0;
        u2   <= 10'sd0;
        out1 <= 1'b0;
        out2 <= 1'b0;
     end

    // calculating potentils
    if ($signed(u1_new) < $signed(threshold)) begin
        out1 <= 0;
        u1 <= u1_new[9:0];
    end

    if ($signed(u1_new) >= $signed(threshold)) begin
        out1 <= 1;
        u1 <= 10'sd0;
    end

    if ($signed(u2_new) < $signed(threshold)) begin
        out2 <= 0;
        u2 <= u2_new[9:0];
    end

    if ($signed(u2_new) >= $signed(threshold)) begin
        out2 <= 1;
        u2 <= 10'sd0;
    end
    
end



endmodule