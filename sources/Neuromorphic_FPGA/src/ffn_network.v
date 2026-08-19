// simple network with sift bsed decay 
// made to run on tang nano 9k

module ffn_22_netwok #(
    parameter w1 = 8'sd4,
    parameter w2 = 8'sd3,
    parameter w3 = 8'sd2,
    parameter w4 = 8'sd5,
    parameter threshold = 10'sd50,
    parameter beta_shift = 4
)(
    input wire sys_clk,
//    input wire reset,
    input wire  in1,
    input wire in2,
    output reg out1,
    output reg out2
);



reg signed [9:0] u1;
reg signed [9:0] u2;

reg [24:0] count;
reg tick;

wire signed [10:0] u1_new;
wire signed [10:0] u2_new;

wire signed [10:0] u1_decayed;
wire signed [10:0] u2_decayed;
wire clk;

// u1: 10 bit to 11 bit
// w1,w3: 8 bit to 11 bit
assign u1_new = {u1[9],u1} + (in1 ? {{3{w1[7]}}, w1} : 11'sd0) + (in2 ? {{3{w3[7]}}, w3} : 11'sd0) - ({u1[9],u1} >> beta_shift);
assign u2_new = {u2[9],u2} + (in2 ? {{3{w2[7]}}, w2} : 11'sd0) + (in2 ? {{3{w4[7]}}, w4} : 11'sd0) - ({u1[9],u1} >> beta_shift);
assign clk = tick;

//assign u1_sum = $signed(u1) + $signed(w1);
//assign u1_sum = $signed(u1) + $signed(w1);

reg reset = 1;

reg u1_reset = 0;
reg u2_reset = 0;

//reg signed [9:0] u1_next = 10'sd0;
//reg signed [9:0] u2_next = 10'sd0;

always @(posedge sys_clk) begin
        if (count == 25'd27000000 - 1) begin
            count <= 25'd0;
            tick  <= 1'b1; // Active for 1 cycle of 27MHz
        end else begin
            count <= count + 1'b1;
            tick  <= 1'b0;
        end
end

always @(posedge clk) begin
    
     if (reset) begin
        u1   <= 10'sd0;
        u2   <= 10'sd0;
        out1 <= 1'b0;
        out2 <= 1'b0;
        reset = 0;
     end


    // calculating potentils
    if ($signed(u1_new) < $signed(threshold)) begin
        u1 <= u1_new[9:0];
        out1 <= 0;
    end

    if ($signed(u1_new) >= $signed(threshold)) begin
        out1 <= 1;
        if (u1_reset) begin
            u1 <= u1_new[9:0] - threshold;
            u1_reset <= 0;
        end else begin
            u1 <= u1_new[9:0];
            out1 <= 0;
            u1_reset <= 1;
        end
    end

    if ($signed(u2_new) < $signed(threshold)) begin
        u2 <= u2_new[9:0];
        out2 <= 0;
    end

    if ($signed(u2_new) >= $signed(threshold)) begin
        out2 <= 1;
        if (u2_reset) begin
            u2 <= u2_new[9:0] - threshold;
            u2_reset <= 0;
        end else begin
            u2 <= u2_new[9:0];
            out2 <= 0;
            u2_reset <= 1;
        end
    end
    
end



endmodule