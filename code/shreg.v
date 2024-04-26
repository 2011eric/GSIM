module shreg #(
    parameter BIT_WIDTH = 32
)(
    input clk,
    input rst_n,
    input [1:0]ctrl,
    input load, //assert when x15 is taking input (this may be redundant if we take input every cycle)
    input [BIT_WIDTH-1: 0] IN,
    output [BIT_WIDTH-1: 0] OUT1, OUT2, OUT3, OUT4, OUT5, OUT6
);
    integer i;
    reg [BIT_WIDTH-1: 0] MEM_r [0: 15], MEM_w [0:15];
    
    //parameter
    localparam SH1 = 2'b00;
    localparam SH4 = 2'b01;
    localparam SH5 = 2'b10;

    //output assignment
    assign OUT1 = MEM_r[13];
    assign OUT2 = MEM_r[3];
    assign OUT3 = MEM_r[14];
    assign OUT4 = MEM_r[2];
    assign OUT5 = MEM_r[15];
    assign OUT6 = MEM_r[1];


    always @(*) begin
        //default
        for (i=0; i < 16; i = i+1) begin
            MEM_w[i] = MEM_r[i];
        end
        case(ctrl) 
        SH1: begin
            MEM_w[15] = MEM_r[0];
            for (i = 0; i < 15; i = i+1) begin
                MEM_w[i] = MEM_r[i+1];
            end
        end
        SH4: begin
            MEM_w[12] = MEM_r[0];
            MEM_w[13] = MEM_r[1];
            MEM_w[14] = MEM_r[2];
            MEM_w[15] = MEM_r[3];
            for (i = 0; i < 12; i = i+1) begin
                MEM_w[i] = MEM_r[i+4];
            end
        end
        SH5: begin
            MEM_w[11] = MEM_r[0];
            MEM_w[12] = MEM_r[1];
            MEM_w[13] = MEM_r[2];
            MEM_w[14] = MEM_r[3];
            MEM_w[15] = MEM_r[4];
            for (i = 0; i < 11; i = i+1) begin
                MEM_w[i] = MEM_r[i+5];
            end
        end
        endcase
        if (load) MEM_w[15] = IN;
    end

    always@ (posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            for (i=0; i < 16; i = i+1) begin
                MEM_r[i] <= 0;
            end
        end
        else begin
            for (i=0; i < 16; i = i+1) begin
                MEM_r[i] <= MEM_w [i];
            end
        end
    end
endmodule