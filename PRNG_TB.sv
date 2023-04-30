`timescale 1ns/100ps
//PRNG TB
module PRNG_TB();

//Parameter declarations
parameter CLK_PERIOD = 20;                                                       //Clock period

//Internal signals declarations
logic rst;                                                                       //Active high logic
logic clk;                                                                       //Clock signal
integer k;
//PRNG instantiation
High_arch_PRNG h0(.i_rst(rst),.i_clk(clk));

//Initial blocks
initial begin
rst=0;
clk=0;
#1000
rst=1;

for(k=0; k<(100); k++)                                                          //Perform 100 itterations
  begin
    @(posedge clk);
    $display("RULE 30: %b RULE 60: %b RULE 150: %b. The random numbers are: %d %d %d", h0.o_sig_0,h0.o_sig_1,h0.o_sig_2,h0.o_rn_0, h0.o_rn_1, h0.o_rn_2);
  end
$finish;
end

//Clock generation
always
begin
#(CLK_PERIOD/2);
clk=~clk;
end

endmodule
