//Single CA_Cell described as 2^(NEIGHBORHOOD+1)-to-1 multiplexer to allow easy expantion for NEIGHBORHOOD>2 cases
module CA_Cell(i_rst,i_clk,i_initial_value,i_sig,o_sig_cell);
//Parameters
parameter NEIGHBORHOOD=2;                          //Number of neuighboring cells
parameter RULE=30;                                 //Rule is described in a 2^(NEIGHBORHOOD+1) long vector (Default: 'Rule 30')

//Local parameters
localparam W_RULE = 2**(NEIGHBORHOOD+1);           //Rule width calculation
localparam C_RULE = RULE[W_RULE-1:0];              //Casting

//Input signals
input logic i_clk;                                 //CA_Cell is synchronized to the positive edge of 'i_clk' 
input logic i_rst;                                 //Active high logic
input logic i_initial_value;                       //Initial value of the one-dimensional grid. Applied when 'i_rst' is logic low
input logic [NEIGHBORHOOD:0] i_sig;                //NEIGHBORHOOD+1 bit long input signal

//Output signals
output logic o_sig_cell;                          //Cell output

//HDL code
always @(posedge i_clk or negedge i_rst)
  if (!i_rst) begin
    o_sig_cell<=i_initial_value;
  end 
  else begin
    o_sig_cell<=C_RULE[i_sig];
  end

endmodule
