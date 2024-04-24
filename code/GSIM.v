`timescale 1ns/10ps
`include "PE.v"
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
//----------------- fsm state definition -----------------//
localparam S_IDLE = 3'd0, S_IN = 3'd1;

//----------------- sequential signal definition -----------------//
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
reg [31:0] pe_in1, pe_in2, pe_in3, pe_in4, pe_in5, pe_in6 [0:N-1];
reg [31:0] pe_out;
reg [15:0] pe_b_in;
//----------------- calling submodule -----------------//
PE pe (.clk(clk), 
       .reset(reset), 
       .in_1(pe_in1), 
       .in_2(pe_in2), 
       .in_3(pe_in3), 
       .in_4(pe_in4), 
       .in_5(pe_in5), 
       .in_6(pe_in6), 
       .b(pe_b_in), 
       .out(pe_out));

//----------------- combinational part -----------------//
integer i;
always @(*) begin:
    state_w = state_r;
    row_cnt_w = row_cnt_r;
    col_cnt_w = col_cnt_r;
    for (i = 0; i < N; i = i + 1) b_w[i] = b_r[i]; // hold the input value
    case (state_r)
        S_IDLE: begin
            if (in_en) begin
                state_w = S_IN;
                b_w[0] = b_in; // reading the first b_in, next cycle should start the computation
                pe_b_in = b_r[0];
            end
            else begin
                state_w = S_IDLE;
            end
        end
        S_IN: begin // upon reading the first b_in, start the computation until recieving total 16 b_in
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

always @(*) begin: fifo_b
    for (i = 0; i < N; i = i + 1) b_w[i] = b_r[i]; // hold the input value
    if (shift_one) begin
        for (i = 0; i < N - 1; i = i + 1) begin
            b_w[i] = b_r[i+1];
        end
        b_w[N-1] = (state_r == S_IN) ? b_in : b_r[0];
    end 
end

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


