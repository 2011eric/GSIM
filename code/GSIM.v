`timescale 1ns/10ps
`include "PE.v"
module GSIM ( clk, reset, in_en, b_in, out_valid, x_out);
input   clk ;
input   reset ;
input   in_en;
output  out_valid;
input   [15:0]  b_in;
output  [31:0]  x_out;

parameter NR_ITERATION = 10;
parameter N = 16;

localparam S_IDLE = 3'd0, S_IN = 3'd1;

integer i;
reg [31:0] xn_r, xn_w [0:N-1];  /* FIFO for x */
reg [15:0] b_r, b_w [0:N-1];    /* FIFO for b */
reg [2:0] state_r, state_w;
reg [3:0] row_cnt_r, row_cnt_w;
reg [3:0] col_cnt_r, col_cnt_w;

/* 
 * This control signal indicate the FIFO should shift by 4, otherwise it should shift by 1
 * The scheme look like this:
 *     1. When we are reading the data into FIFO, shift by 1
 *     2. For each iteration, shift by 4
 *     3. After 4 iterations, shift the FIFO by 1
 */
reg shift_four, shift_one; 

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



always @(*) begin:state_logic
    state_w = state_r;
    case (state_r)
        S_IDLE: if (in_en) state_w = S_IN;
        S_IN: if (row_cnt_r == N-1) state_w = S_IDLE;
    endcase
end

always @(*) begin:counter_logic
    row_cnt_w = row_cnt_r;
    col_cnt_w = col_cnt_r;
    if (state_r == S_IN) begin
        row_cnt_w = row_cnt_r == N - 1 ? 0 : row_cnt_r + 1;
    end
end

always @(*) begin: fifo_b
    for (i = 0; i < N; i = i + 1) b_w[i] = b_r[i];
    if (shift_one) begin
        for (i = 0; i < N - 1; i = i + 1) begin
            b_w[i] = b_r[i+1];
        end
        b_w[N-1] = (state_r == S_IN) ? b_in : b_r[0];
    end 
end

//TODO: implement fifo for xn

endmodule


