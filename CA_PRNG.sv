//Pseudo random number generator based on 1-D cellular automaton
module CA_PRNG(i_rst,i_clk,i_arr_initial_value,o_sig,o_rn);
//Parameters
parameter ARRAY_WIDTH=11;                                 //Width of the one-dimensional CA grid
parameter NEIGHBORHOOD=2;                                 //Number of neuighboring cells
parameter RULE=30;                                        //Rule is described in a 2^(NEIGHBORHOOD+1) long vector (Default: 'Rule 30')
parameter N=10;                                           //Random number width
parameter LOCATION=ARRAY_WIDTH/2;                         //Bit location for random number generation (input of the shift register)

//Input signals
input logic i_clk;                                        //CA_Cell is synchronized to the positive edge of 'i_clk' 
input logic i_rst;                                        //Active high logig
input logic [ARRAY_WIDTH-1:0] i_arr_initial_value;        //Initial value of the one-dimensional grid. Applied when 'i_rst' is logic low

//Output signals
output logic [ARRAY_WIDTH-1:0] o_sig;                     //ARRAY_WIDTH-bit Output word
output logic [N-1:0] o_rn;                                //N-bit random word

//HDL code
CA_Array #(.ARRAY_WIDTH(ARRAY_WIDTH),.RULE(RULE),.NEIGHBORHOOD(NEIGHBORHOOD)) m0(.i_rst(i_rst),
                                                                                 .i_clk(i_clk),
                                                                                 .i_arr_initial_value(i_arr_initial_value),
                                                                                 .o_sig(o_sig)
);

//N-bit Random number generation
always @(posedge i_clk or negedge i_rst)
  if (!i_rst)
    o_rn<='0;
  else
    o_rn<={o_sig[LOCATION],o_rn[N-1:1]};

endmodule
