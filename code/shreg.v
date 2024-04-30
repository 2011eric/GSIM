module shreg #(
    parameter BIT_WIDTH = 32
)(
    input clk,
    input rst_n,
    input [2:0] ctrl, // 100 --> shift2
    input i_en, //assert when x15 is taking input (this may be redundant if we take input every cycle)
    input [BIT_WIDTH-1: 0] IN, IN2,
    output [BIT_WIDTH-1: 0] OUT0, OUT1, OUT2, OUT3, OUT4, OUT5, OUT6, OUT2_0, OUT2_1, OUT2_2, OUT2_3, OUT2_4, OUT2_5, OUT2_6
);
    integer i;
    reg [BIT_WIDTH-1: 0] MEM_r [0: 15];
    reg [BIT_WIDTH-1: 0] MEM_w [0: 15];
    
    //parameter
    localparam SH0 = 3'b000;
    localparam SH2 = 3'b100;
    localparam SH1 = 3'b001;
    localparam SH4 = 3'b010;
    localparam SH5 = 3'b011;

    //output assignment
    assign OUT0 = MEM_r[0];
    assign OUT1 = MEM_r[13];
    assign OUT2 = MEM_r[3];
    assign OUT3 = MEM_r[14];
    assign OUT4 = MEM_r[2];
    assign OUT5 = MEM_r[15];
    assign OUT6 = MEM_r[1];

    assign OUT2_0 = MEM_r[2];
    assign OUT2_1 = MEM_r[15];
    assign OUT2_2 = MEM_r[5];
    assign OUT2_3 = MEM_r[0];
    assign OUT2_4 = MEM_r[4];
    assign OUT2_5 = MEM_r[1];
    assign OUT2_6 = MEM_r[3];


    always @(*) begin
        //default
        for (i=0; i < 16; i = i+1) begin
            MEM_w[i] = MEM_r[i];
        end
        case(ctrl) 
        SH0: begin
            if(i_en) begin
                MEM_w[15] = IN;
                for (i = 0; i < 15; i = i+1) begin
                    MEM_w[i] = MEM_r[i];
                end
            end
            else begin
                for (i = 0; i < 16; i = i+1) begin
                    MEM_w[i] = MEM_r[i];
                end
            end
        end
        SH1: begin
            if(i_en) begin
                MEM_w[15] = IN;
                MEM_w[14] = MEM_r[15];
                for (i = 0; i < 15; i = i+1) begin
                    MEM_w[i] = MEM_r[i+1];
                end
            end
            else begin
                MEM_w[15] = MEM_r[0];
                for (i = 0; i < 15; i = i+1) begin
                    MEM_w[i] = MEM_r[i+1];
                end
            end
        end
        SH2: begin
            MEM_w[14] = MEM_r[0];
            MEM_w[15] = MEM_r[1];
            for (i = 0; i < 14; i = i+1) begin
                MEM_w[i] = MEM_r[i+2];
            end
        end
        SH4: begin
            if(i_en) begin
                MEM_w[12] = MEM_r[0];
                MEM_w[13] = MEM_r[1];
                MEM_w[14] = MEM_r[2];
                MEM_w[15] = IN;
                for (i = 2; i < 12; i = i+1) begin
                    MEM_w[i] = MEM_r[i+4];
                end
                MEM_w[1] = IN2;
                MEM_w[0] = MEM_r[4];
            end
            else begin
                MEM_w[12] = MEM_r[0];
                MEM_w[13] = MEM_r[1];
                MEM_w[14] = MEM_r[2];
                MEM_w[15] = MEM_r[3];
                for (i = 0; i < 12; i = i+1) begin
                    MEM_w[i] = MEM_r[i+4];
                end
            end
        end
        SH5: begin
            if(i_en) begin
                MEM_w[11] = MEM_r[0];
                MEM_w[12] = MEM_r[1];
                MEM_w[13] = MEM_r[2];
                MEM_w[14] = MEM_r[3];
                MEM_w[15] = IN;
                for (i = 2; i < 11; i = i+1) begin
                    MEM_w[i] = MEM_r[i+5];
                end
                MEM_w[1] = IN2;
                MEM_w[0] = MEM_r[5];
            end
            else begin
                MEM_w[11] = MEM_r[0];
                MEM_w[12] = MEM_r[1];
                MEM_w[13] = MEM_r[2];
                MEM_w[14] = MEM_r[3];
                MEM_w[15] = MEM_r[4];
                for (i = 0; i < 11; i = i+1) begin
                    MEM_w[i] = MEM_r[i+5];
                end
            end
        end
        endcase
    end

    always@ (posedge clk or posedge rst_n) begin
        if(rst_n) begin
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
