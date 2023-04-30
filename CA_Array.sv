//1D CA-Based array
module CA_Array(i_rst,i_clk,i_arr_initial_value,o_sig);
//Parameters
parameter ARRAY_WIDTH=11;                            //Width of the one-dimensional CA grid
parameter NEIGHBORHOOD=2;                            //Number of neuighboring cells
parameter RULE=30;                                   //Rule is described in a 2^(NEIGHBORHOOD+1) long vector (Default: 'Rule 30')

//Input signals
input logic i_clk;                                   //CA_Array is synchronized to the positive edge of 'i_clk' 
input logic i_rst;                                   //Active high logic
input logic [ARRAY_WIDTH-1:0] i_arr_initial_value;   //Array reset value

//Output signals
output logic [ARRAY_WIDTH-1:0] o_sig;               //Output word

//HDL code

//Generating the 1D array
genvar i;
generate
  for (i=0; i<ARRAY_WIDTH; i=i+1) begin : CA_array_gen
  if (i==0)
    CA_Cell #(.NEIGHBORHOOD(NEIGHBORHOOD),.RULE(RULE)) u0 (.i_rst(i_rst),.i_clk(i_clk),.i_initial_value(i_arr_initial_value[i]),.i_sig({o_sig[i+1],o_sig[i],o_sig[ARRAY_WIDTH-1]}),.o_sig_cell(o_sig[i]));
  else if (i==ARRAY_WIDTH-1)
    CA_Cell #(.NEIGHBORHOOD(NEIGHBORHOOD),.RULE(RULE)) u0 (.i_rst(i_rst),.i_clk(i_clk),.i_initial_value(i_arr_initial_value[i]),.i_sig({o_sig[0],o_sig[i],o_sig[i-1]}),.o_sig_cell(o_sig[i]));
  else
    CA_Cell #(.NEIGHBORHOOD(NEIGHBORHOOD),.RULE(RULE)) u0 (.i_rst(i_rst),.i_clk(i_clk),.i_initial_value(i_arr_initial_value[i]),.i_sig({o_sig[i+1],o_sig[i],o_sig[i-1]}),.o_sig_cell(o_sig[i]));
  end
endgenerate

endmodule