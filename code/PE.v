/*
 *  out = (b + (in_1 + in_2) - 6 * (in_3 + in_4) + 13 * (in_5 + in_6)) / 20
 *
 */
module PE (input clk, 
           input reset,
           input signed [33:0] in_1, in_2, in_3, in_4, in_5, in_6,
           input signed [15:0] b,
           output reg [37:0] out);
    
reg signed [32:0] s1_adder [0:2];
reg signed [35:0] s1_mul6;
reg signed [36:0] s1_mul13;

reg signed [32:0] s1_reg0_r, s1_reg0_w;
reg signed [35:0] s1_reg1_r, s1_reg1_w;
reg signed [36:0] s1_reg2_r, s1_reg2_w;

reg signed [37:0] s2_adder;
reg signed [37:0] s2_reg0_r, s2_reg0_w;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        s1_reg0_r <= 0;
        s1_reg1_r <= 0;
        s1_reg2_r <= 0;
        s2_reg0_r <= 0;
    end else begin
        s1_reg0_r <= s1_reg0_w;
        s1_reg1_r <= s1_reg1_w;
        s1_reg2_r <= s1_reg2_w;
        s2_reg0_r <= s2_reg0_w;
    end
end

always @(*) begin:stage1
    s1_adder[0] = in_1 + in_2;
    s1_adder[1] = in_3 + in_4;
    s1_adder[2] = in_5 + in_6;
    s1_mul6 = $signed(s1_adder[1] << 1) + $signed(s1_adder[1] << 2);
    s1_mul13 = $signed(s1_adder[2] << 3) + $signed(s1_adder[2] << 2) + $signed(s1_adder[2] << 1);
    s1_reg0_w = s1_adder[0];
    s1_reg1_w = s1_mul6;
    s1_reg2_w = s1_mul13;
end

always @(*) begin:stage2
    s2_adder = b + s1_reg0_r - s1_reg1_r + s1_reg2_r;
    s2_reg0_w = s2_adder;
end

assign out = s2_reg0_r;

endmodule