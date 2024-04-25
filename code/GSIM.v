`timescale 1ns/10ps
`include "PE.v","Shreg.v"
module GSIM ( clk, reset, in_en, b_in, out_valid, x_out);
//----------------- port definition -----------------//
input   clk ;
input   reset ;
input   in_en;
output  out_valid;
input   [15:0]  b_in;
output  [31:0]  x_out;
//----------------- parameter definition -----------------//
parameter NR_ITERATION = 10;
parameter N = 16;
defparam b_shreg.WIDTH = 16;
defparam x_shreg.WIDTH = 32;
//----------------- fsm state definition -----------------//
localparam S_IDLE = 3'd0, S_IN = 3'd1, S_CALC = 3'd2, S_OUT = 3'd3;

//----------------- sequential signal definition -----------------//
// reg [31:0] xn_r, xn_w [0:N-1];  /* FIFO for x */
// reg [15:0] b_r, b_w [0:N-1];    /* FIFO for b */
reg [2:0] state_r, state_w;
reg [3:0] row_cnt_r, row_cnt_w;
reg [3:0] col_cnt_r, col_cnt_w;

//----------------- defining b_shreg's wire -----------------//
wire [15:0] b_shreg_out_1, b_shreg_out_2, b_shreg_out_3, b_shreg_out_4, b_shreg_out_5, b_shreg_out_6;
reg  [15:0] b_shreg_in_w, b_shreg_in_r;
reg  [1:0]  b_shreg_ctrl_w, b_shreg_ctrl_r;
reg         b_shreg_i_en_w, b_shreg_i_en_r;

//----------------- defining x_shreg's wire -----------------//
wire [31:0] x_shreg_out_1, x_shreg_out_2, x_shreg_out_3, x_shreg_out_4, x_shreg_out_5, x_shreg_out_6;
reg  [31:0] x_shreg_in_w, x_shreg_in_r;
reg  [1:0]  x_shreg_ctrl_w, x_shreg_ctrl_r;
reg         x_shreg_i_en_w, x_shreg_i_en_r;

/* 
 * This control signal indicate the FIFO should shift by 4, otherwise it should shift by 1
 * The scheme look like this:
 *     1. When we are reading the data into FIFO, shift by 1
 *     2. For each iteration, shift by 4
 *     3. After 4 iterations, shift the FIFO by 1
 */
reg [31:0] pe_in1, pe_in2, pe_in3, pe_in4, pe_in5, pe_in6 [0:N-1];
wire [31:0] pe_out;
reg [15:0] pe_b_in;

//----------------- calling submodule -----------------//
PE pe (
    .clk(clk), 
    .reset(reset), 
    .in_1(pe_in1), 
    .in_2(pe_in2), 
    .in_3(pe_in3), 
    .in_4(pe_in4), 
    .in_5(pe_in5), 
    .in_6(pe_in6), 
    .b(pe_b_in), 
    .out(pe_out)
);


Shreg b_shreg ( // TODO: connecting the wires
    .clk(clk), 
    .rst_n(reset), 
    .OUT1(b_shreg_out_1),
    .OUT2(b_shreg_out_2),
    .OUT3(b_shreg_out_3), 
    .OUT4(shreg_out_4), 
    .OUT5(b_shreg_out_5), 
    .OUT6(b_shreg_out_6), 
    .IN(b_shreg_in), 
    .ctrl(b_shreg_ctrl), // ctrl = 01 --> shift by 1, ctrl = 10 --> shift by 4, ctrl = 11 --> shift by 5
    .i_en(b_shreg_i_en)
);

Shreg x_shreg ( // TODO: connecting the wires
    .clk(clk), 
    .rst_n(reset), 
    .OUT1(x_shreg_out_1),
    .OUT2(x_shreg_out_2),
    .OUT3(x_shreg_out_3), 
    .OUT4(x_shreg_out_4), 
    .OUT5(x_shreg_out_5), 
    .OUT6(x_shreg_out_6), 
    .IN(x_shreg_in), 
    .ctrl(x_shreg_ctrl), // ctrl = 01 --> shift by 1, ctrl = 10 --> shift by 4, ctrl = 11 --> shift by 5
    .i_en(x_shreg_i_en)
);
//----------------- combinational part -----------------//
integer i;
always @(*) begin:
    state_w = state_r;
    row_cnt_w = row_cnt_r;
    col_cnt_w = col_cnt_r;
    b_shreg_i_en_w = 1'b0;
    x_shreg_i_en_w = 1'b0;
    case (state_r)
        S_IDLE: begin
            if (in_en) begin
                state_w = S_IN;
                b_shreg_in_w = b_in; // the b_shreg_in is the b[15]
                b_shreg_ctrl_w = 2'b01; // shift by 1
                row_cnt_w = 1;
            end
            else begin
                b_shreg_in = 0;
                b_shreg_ctrl = 2'b00;
                state_w = S_IDLE;
            end
        end
        S_IN: begin
            if(row_cnt_r == N-1) begin // if we have read all the b values
                state_w = S_CALC;
                row_cnt_w = 0;
                col_cnt_w = 0;
            end
            else begin
                state_w = S_IN;
                row_cnt_w = row_cnt_r + 1;
            end
        end
        S_CALC: begin
            if (row_cnt_r == N-1) begin
                state_w = S_IDLE;
                row_cnt_w = 0;
                col_cnt_w = col_cnt_r + 1;
            end
            else begin
                state_w = S_IN;
                row_cnt_w = row_cnt_r + 1;
                col_cnt_w = col_cnt_r;
            end
        end
    endcase
end

// always @(*) begin: fifo_b
//     for (i = 0; i < N; i = i + 1) b_w[i] = b_r[i]; // hold the input value
//     if (shift_one) begin
//         for (i = 0; i < N - 1; i = i + 1) begin
//             b_w[i] = b_r[i+1];
//         end
//         b_w[N-1] = (state_r == S_IN) ? b_in : b_r[0];
//     end 
// end

//TODO: implement fifo for xn


//----------------- sequential part -----------------//
always @(posedge clk or posedge reset) begin
    if (reset) begin
        state_r <= S_IDLE
        row_cnt_r <= 0;
        col_cnt_r <= 0;
        for (i = 0; i < N; i = i + 1) begin
            b_r[i] <= 0;
            xn_r[i] <= 0;
        end
    end else begin
        state_r <= state_w;
        row_cnt_r <= row_cnt_w;
        col_cnt_r <= col_cnt_w;
        for (i = 0; i < N; i = i + 1) begin
            b_r[i] <= b_w[i];
            xn_r[i] <= xn_w[i];
        end
    end
end

endmodule


module Shreg(out_1, out_2, out_3, out_4, out_5, out_6, in, ctrl, i_en);
        //parameterize
endmodule