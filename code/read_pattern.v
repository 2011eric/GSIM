`timescale 1ns/10ps
`define CYCLE 10
`define PATTERN1 "./pattern1.dat"
`define PATTERN2 "./pattern2.dat"
`define PATTERN3 "./pattern3.dat"
`define PATTERN4 "./pattern4.dat"
`define PATTERN5 "./pattern5.dat"

module testbench;


reg signed [15:0] pat_mem [0:15];
integer i;

initial begin
    $readmemh(`PATTERN1, pat_mem);
    $display("pattern 1 ==================");
    $display("[%d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d]"
    , pat_mem[0], pat_mem[1], pat_mem[2], pat_mem[3]
    , pat_mem[4], pat_mem[5], pat_mem[6], pat_mem[7]
    , pat_mem[8], pat_mem[9], pat_mem[10], pat_mem[11]
    , pat_mem[12], pat_mem[13], pat_mem[14], pat_mem[15]);


    $readmemh(`PATTERN2, pat_mem);
    $display("[%d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d]"
    , pat_mem[0], pat_mem[1], pat_mem[2], pat_mem[3]
    , pat_mem[4], pat_mem[5], pat_mem[6], pat_mem[7]
    , pat_mem[8], pat_mem[9], pat_mem[10], pat_mem[11]
    , pat_mem[12], pat_mem[13], pat_mem[14], pat_mem[15]);

    $readmemh(`PATTERN3, pat_mem);
    $display("[%d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d]"
    , pat_mem[0], pat_mem[1], pat_mem[2], pat_mem[3]
    , pat_mem[4], pat_mem[5], pat_mem[6], pat_mem[7]
    , pat_mem[8], pat_mem[9], pat_mem[10], pat_mem[11]
    , pat_mem[12], pat_mem[13], pat_mem[14], pat_mem[15]);

    $readmemh(`PATTERN4, pat_mem);
    $display("[%d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d]"
    , pat_mem[0], pat_mem[1], pat_mem[2], pat_mem[3]
    , pat_mem[4], pat_mem[5], pat_mem[6], pat_mem[7]
    , pat_mem[8], pat_mem[9], pat_mem[10], pat_mem[11]
    , pat_mem[12], pat_mem[13], pat_mem[14], pat_mem[15]);

    $readmemh(`PATTERN5, pat_mem);
    $display("[%d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d]"
    , pat_mem[0], pat_mem[1], pat_mem[2], pat_mem[3]
    , pat_mem[4], pat_mem[5], pat_mem[6], pat_mem[7]
    , pat_mem[8], pat_mem[9], pat_mem[10], pat_mem[11]
    , pat_mem[12], pat_mem[13], pat_mem[14], pat_mem[15]);
    #10;
    $finish;
end


endmodule


    