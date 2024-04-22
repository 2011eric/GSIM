`timescale 1ns/10ps
`define CYCLE 10
`define PATTERN "./pattern1.dat"
`include "./PE.v"

module testbench;

reg clk, reset;
reg signed [31:0] in_1, in_2, in_3, in_4, in_5, in_6;
reg signed [15:0] b;
wire signed [37:0] out;

reg signed [15:0] pat_mem [0:15];

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
    in_1 = pat_mem[3]/32'sd20 ; // x4
    in_2 = 0;
    in_3 = pat_mem[2]/32'sd20; // x3
    in_4 = 0;
    in_5 = pat_mem[1]/32'sd20; // x2
    in_6 = 0;
    b = pat_mem[0]; // x1

    //FIXME Clarify the dependency, since the current input seems incorrect
    @(negedge clk);
    in_1 = pat_mem[4]/32'sd20;
    in_2 = 0;
    in_3 = pat_mem[3]/32'sd20;
    in_4 = 0;
    in_5 = pat_mem[2]/32'sd20;
    in_6 = pat_mem[0]/32'sd20;
    b = pat_mem[1]; // x2

    repeat(11) @(posedge clk);
    $finish;
end


endmodule


    