`timescale 1ns/10ps
`include "PE.v"
`include "shreg.v"
module GSIM ( clk, reset, in_en, b_in, out_valid, x_out);
//----------------- port definition -----------------//
input   clk ;
input   reset ;
input   in_en;
output  out_valid;
input   [15:0]  b_in;
output  [31:0]  x_out;
//----------------- parameter definition -----------------//
parameter NR_ITERATION = 80;
parameter N = 16;
defparam bshreg.BIT_WIDTH = 16;
defparam xshreg.BIT_WIDTH = 32;
//----------------- fsm state definition -----------------//
localparam S_IDLE = 3'd0, S_IN = 3'd1, S_CALC = 3'd2, S_WAIT = 3'd3, S_OUT = 3'd4;

//----------------- sequential signal definition -----------------//
// reg [31:0] xn_r, xn_w [0:N-1];  /* FIFO for x */
// reg [15:0] b_r, b_w [0:N-1];    /* FIFO for b */
reg [2:0] state_r, state_w;
reg [4:0] row_cnt_r, row_cnt_w;
reg [6:0] iter_cnt_w, iter_cnt_r;
reg out_valid_w, out_valid_r;

//----------------- defining b_shreg's wire -----------------//
wire [15:0] b_shreg_out_0, b_shreg_out_1, b_shreg_out_2, b_shreg_out_3, b_shreg_out_4, b_shreg_out_5, b_shreg_out_6;
reg  [15:0] b_shreg_in_w, b_shreg_in_r;
reg  [1:0]  b_shreg_ctrl_w, b_shreg_ctrl_r;
reg         b_shreg_i_en_w, b_shreg_i_en_r;

//----------------- defining x_shreg's wire -----------------//
wire [31:0] x_shreg_out_0, x_shreg_out_1, x_shreg_out_2, x_shreg_out_3, x_shreg_out_4, x_shreg_out_5, x_shreg_out_6;
reg  [31:0] x_shreg_in_w, x_shreg_in_r;
reg         x_shreg_i_en_w, x_shreg_i_en_r;


wire [31:0] pe_in1, pe_in2, pe_in3, pe_in4, pe_in5, pe_in6;
wire [31:0] pe_out;
wire [15:0] pe_b_in;
reg         pe_i_en_w, pe_i_en_r;

`ifdef DEBUG
wire [15:0] out_tmp, pe_in1_tmp, pe_in2_tmp, pe_in3_tmp, pe_in4_tmp, pe_in5_tmp, pe_in6_tmp;
assign out_tmp = pe_out[31:16];
assign pe_in1_tmp = pe_in1[31:16];
assign pe_in2_tmp = pe_in2[31:16];
assign pe_in3_tmp = pe_in3[31:16];
assign pe_in4_tmp = pe_in4[31:16];
assign pe_in5_tmp = pe_in5[31:16];
assign pe_in6_tmp = pe_in6[31:16];
`endif
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


shreg bshreg ( // TODO: connecting the wires
    .clk(clk), 
    .rst_n(reset), 
    .OUT0(b_shreg_out_0),
    .OUT1(b_shreg_out_1),
    .OUT2(b_shreg_out_2),
    .OUT3(b_shreg_out_3), 
    .OUT4(b_shreg_out_4), 
    .OUT5(b_shreg_out_5), 
    .OUT6(b_shreg_out_6), 
    .IN(b_shreg_in_r),
    .ctrl(b_shreg_ctrl_r), // ctrl = 01 --> shift by 1, ctrl = 10 --> shift by 4, ctrl = 11 --> shift by 5
    .i_en(b_shreg_i_en_r)
);

shreg xshreg ( // TODO: connecting the wires
    .clk(clk), 
    .rst_n(reset), 
    .OUT0(x_shreg_out_0),
    .OUT1(x_shreg_out_1),
    .OUT2(x_shreg_out_2),
    .OUT3(x_shreg_out_3), 
    .OUT4(x_shreg_out_4), 
    .OUT5(x_shreg_out_5), 
    .OUT6(x_shreg_out_6), 
    .IN(x_shreg_in_w), 
    .ctrl(b_shreg_ctrl_r), // ctrl = 01 --> shift by 1, ctrl = 10 --> shift by 4, ctrl = 11 --> shift by 5, same as b_shreg
    .i_en(x_shreg_i_en_r)
);

//----------------- connecting the wires -----------------//
assign pe_in1 = ((state_r == S_CALC) && row_cnt_r != 1 && row_cnt_r != 5 && row_cnt_r != 9 && pe_i_en_r) ? x_shreg_out_1 : 0; // 13
assign pe_in2 = ((state_r == S_CALC) && row_cnt_r != 16 && row_cnt_r != 12 && row_cnt_r != 8 && pe_i_en_r) ? x_shreg_out_2 : 0; // 3
assign pe_in3 = ((state_r == S_CALC) && row_cnt_r != 1 && row_cnt_r != 5 && pe_i_en_r) ? x_shreg_out_3 : 0; // 14
assign pe_in4 = ((state_r == S_CALC) && row_cnt_r != 16 && row_cnt_r != 12 && pe_i_en_r) ? x_shreg_out_4 : 0; // 2
assign pe_in5 = ((state_r == S_CALC) && row_cnt_r != 1 && pe_i_en_r) ? x_shreg_out_5 : 0; // 15
assign pe_in6 = ((state_r == S_CALC) && row_cnt_r != 16 && pe_i_en_r) ? x_shreg_out_6 : 0; // 1
assign pe_b_in = (state_r == S_CALC && pe_i_en_r) ? b_shreg_out_0 : 0;

assign x_out = x_shreg_out_0;
assign out_valid = out_valid_r;
//----------------- combinational part -----------------//
integer i;
always @(*) begin
    state_w = state_r;
    row_cnt_w = row_cnt_r;
    iter_cnt_w = iter_cnt_r;
    b_shreg_i_en_w = 1'b0;
    x_shreg_i_en_w = 1'b0;
    b_shreg_ctrl_w = 2'b00;
    b_shreg_in_w = 0;
    x_shreg_in_w = 0;
    pe_i_en_w = 1'b0;
    out_valid_w = 1'b0;
    case (state_r)
        S_IDLE: begin
            if (in_en) begin
                state_w = S_IN;
                b_shreg_in_w = b_in; // the b_shreg_in is the b[15]
                b_shreg_ctrl_w = 2'b01; // shift by 1
                b_shreg_i_en_w = 1'b1;
                row_cnt_w = 1;
            end
            else begin
                state_w = S_IDLE;
                b_shreg_in_w = 0;
                b_shreg_ctrl_w = 2'b00;
                b_shreg_i_en_w = 1'b0;
                row_cnt_w = row_cnt_r;
            end
        end
        S_IN: begin
            if(row_cnt_r[4]) begin // if we have read all the b values
                state_w = S_CALC;
                b_shreg_in_w = b_in;
                b_shreg_ctrl_w = 2'b00;
                b_shreg_i_en_w = 1'b0; 
                row_cnt_w = 0;
                iter_cnt_w = 0;
            end
            else begin
                state_w = S_IN;
                b_shreg_in_w = b_in;
                b_shreg_ctrl_w = 2'b01;
                b_shreg_i_en_w = 1'b1;
                row_cnt_w = row_cnt_r + 1;
                iter_cnt_w = iter_cnt_r;
            end
        end
        S_CALC: begin
            pe_i_en_w = 1'b1;
            b_shreg_ctrl_w = ((row_cnt_r[0] && row_cnt_r[1])) ? 2'b11 : 2'b10;
            x_shreg_in_w = pe_out;
            if (row_cnt_r == N) begin
                state_w = S_WAIT;
                x_shreg_i_en_w = 1'b1;
                row_cnt_w = 1;
                iter_cnt_w = iter_cnt_r;
            end
            else begin
                state_w = S_CALC;
                x_shreg_i_en_w = (row_cnt_r >= 4'd3)? 1'b1 : 1'b0 ;
                row_cnt_w = row_cnt_r + 1;
                iter_cnt_w = iter_cnt_r;
            end
        end
        S_WAIT: begin
            if(iter_cnt_r == NR_ITERATION-1 && (row_cnt_r[0] && row_cnt_r[1])) begin
                b_shreg_ctrl_w = 2'b01;
                state_w = S_OUT;
                row_cnt_w = 1;
                iter_cnt_w = 0;
                out_valid_w = 1'b1;
            end
            else begin
                b_shreg_ctrl_w = 2'b10;
                x_shreg_in_w = pe_out;
                out_valid_w = 1'b0;
                if (row_cnt_r[0] && row_cnt_r[1]) begin
                    state_w = S_CALC;
                    row_cnt_w = 1;
                    iter_cnt_w = iter_cnt_r + 1;
                    pe_i_en_w = 1'b1;
                    x_shreg_i_en_w = 1'b0;
                end
                else begin
                    state_w = S_WAIT;
                    row_cnt_w = row_cnt_r + 1;
                    iter_cnt_w = iter_cnt_r;
                    pe_i_en_w = 1'b0;
                    x_shreg_i_en_w = 1'b1;
                end
            end
        end
        S_OUT: begin
            if(row_cnt_r[4]) begin 
                state_w = S_IDLE;
                row_cnt_w = 0;
                iter_cnt_w = 0;
                out_valid_w = 1'b1;
                b_shreg_ctrl_w = 2'b00;
            end
            else begin
                state_w = S_OUT;
                row_cnt_w = row_cnt_r + 1;
                iter_cnt_w = iter_cnt_r;
                out_valid_w = 1'b1;
                b_shreg_ctrl_w = 2'b01;
            end
        end
    endcase
end


//----------------- sequential part -----------------//
always @(posedge clk or posedge reset) begin
    if (reset) begin
        state_r <= S_IDLE;
        row_cnt_r <= 0;
        iter_cnt_r <= 0;
        b_shreg_i_en_r <= 1'b0;
        x_shreg_i_en_r <= 1'b0;
        b_shreg_ctrl_r <= 2'b00;
        b_shreg_in_r <= 0; 
        x_shreg_in_r <= 0;
        out_valid_r <= 0;
        pe_i_en_r <= 0;
    end else begin
        state_r <= state_w;
        row_cnt_r <= row_cnt_w;
        iter_cnt_r <= iter_cnt_w;
        b_shreg_i_en_r <= b_shreg_i_en_w;
        x_shreg_i_en_r <= x_shreg_i_en_w;
        b_shreg_ctrl_r <= b_shreg_ctrl_w;
        b_shreg_in_r <= b_shreg_in_w;
        x_shreg_in_r <= x_shreg_in_w;
        out_valid_r <= out_valid_w;
        pe_i_en_r <= pe_i_en_w;
    end
end
endmodule
