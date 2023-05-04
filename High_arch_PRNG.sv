//Instantiations of multiple CA-based PRNG
module High_arch_PRNG(i_rst,i_clk);
//Parameters
parameter ARRAY_WIDTH=51;                            //Width of the one-dimensional CA grid
parameter i_arr_initial_value={25'd0,1'b1,25'd0};    //Initial value of the one-dimensional grid. Applied when 'rst' is logic low
parameter NEIGHBORHOOD=2;                            //Number of neuighboring cells
parameter N=10;                                      //Random number width
parameter LOCATION=ARRAY_WIDTH/2;                    //Bit location for random number generation (input of the shift register)

//Input signals
input logic i_clk;                                   //CA_Cell is synchronized to the positive edge of 'i_clk' 
input logic i_rst;                                   //Active high logic

//Internal signals
logic [ARRAY_WIDTH-1:0] o_sig_0;                     //Output word - m0 PRNG
logic [N-1:0] o_rn_0;                                //N-bit random word

logic [ARRAY_WIDTH-1:0] o_sig_1;                     //Output word - m1 PRNG
logic [N-1:0] o_rn_1;                                //N-bit random word

logic [ARRAY_WIDTH-1:0] o_sig_2;                     //Output word - m2 PRNG
logic [N-1:0] o_rn_2;                                //N-bit random word

//HDL code
CA_PRNG #(.ARRAY_WIDTH(ARRAY_WIDTH),.RULE(30),.NEIGHBORHOOD(NEIGHBORHOOD),.N(10),.LOCATION(LOCATION)) m0(.i_rst(i_rst),
                                                                                                         .i_clk(i_clk),
                                                                                                         .i_arr_initial_value(i_arr_initial_value),
                                                                                                         .o_sig(o_sig_0),
                                                                                                         .o_rn(o_rn_0)
                                                                                                        );

CA_PRNG #(.ARRAY_WIDTH(ARRAY_WIDTH),.RULE(60),.NEIGHBORHOOD(NEIGHBORHOOD),.N(10),.LOCATION(LOCATION)) m1(.i_rst(i_rst),
                                                                                                         .i_clk(i_clk),
                                                                                                         .i_arr_initial_value(i_arr_initial_value),
                                                                                                         .o_sig(o_sig_1),
                                                                                                         .o_rn(o_rn_1)
                                                                                                        );

CA_PRNG #(.ARRAY_WIDTH(ARRAY_WIDTH),.RULE(150),.NEIGHBORHOOD(NEIGHBORHOOD),.N(10),.LOCATION(LOCATION)) m2(.i_rst(i_rst),
                                                                                                          .i_clk(i_clk),
                                                                                                          .i_arr_initial_value(i_arr_initial_value),
                                                                                                          .o_sig(o_sig_2),
                                                                                                          .o_rn(o_rn_2)
                                                                                                        );

endmodule
