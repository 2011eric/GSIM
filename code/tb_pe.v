`timescale 1ns/10ps
`define CYCLE 10
`define PATTERN "./pattern1.dat"
`include "./PE.v"

module testbench;

reg clk, reset;
reg [33:0] in_1, in_2, in_3, in_4, in_5, in_6;
reg [15:0] b;
wire [37:0] out;

reg [15:0] pat_mem [0:15];

always #(`CYCLE/2) clk = ~clk;

initial begin
    $readmemh(`PATTERN, pat_mem);
    $fsdbDumpfile("PE.fsdb");
    $fsdbDumpvars(0, DUT, "+mda");
end

PE DUT(.clk(clk), 
       .reset(reset),
       .in_1(in_1), .in_2(in_2), .in_3(in_3), .in_4(in_4), .in_5(in_5), .in_6(in_6),
       .b(b),
       .out(out)
);

initial begin
    clk = 0;
    @(negedge clk) reset = 1;
    @(negedge clk) reset = 0;
    in_1 = pat_mem[3]; // x4
    in_2 = 0;
    in_3 = pat_mem[2]; // x3
    in_4 = 0;
    in_5 = pat_mem[1]; // x2
    in_6 = 0;
    b = pat_mem[0]/20; // x1

    repeat(3) @(posedge clk);
    $finish;
end


endmodule


    