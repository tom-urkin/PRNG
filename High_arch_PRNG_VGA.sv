//Instantiations of multiple CA-based PRNG
module High_arch_PRNG_VGA(i_rst,i_rst_VGA,i_clk,o_red,o_gree,o_blue,hsync,vsync,VGA_blank_N,VGA_sync_N,clk_VGA);
//Parameters
parameter ARRAY_WIDTH=101;                              //Width of the one-dimensional CA grid
parameter i_arr_initial_value={50'd0,1'b1,50'd0};       //Initial value of the one-dimensional grid. Applied when 'rst' is logic low
parameter NEIGHBORHOOD=2;                               //Number of neuighboring cells
parameter N=10;                                         //Random number width
parameter LOCATION=ARRAY_WIDTH/2;                       //Bit location for random number generation (input of the shift register)

//Input signals
input logic i_clk;                                     //CA_Cell is synchronized to the positive edge of 'i_clk' 
input logic i_rst;                                     //Active high logic
input logic i_rst_VGA;                                 //Active high logic

//Output signals
output logic [7:0]  o_red;                             //
output logic [7:0]  o_green;                           //
output logic [7:0]  o_blue;                            //

output logic VGA_blank_N;                              //Tie to logic high (see ADV7123 video DAC datasheet)
output logic VGA_sync_N;                               //Tie to logic low (see ADV7123 video DAC datasheet)
output logic clk_VGA;                                  //25MHz clock

//Internal signals
logic [ARRAY_WIDTH-1:0] o_sig_0;                       //Output word - m0 PRNG
logic [N-1:0] o_rn_0;                                  //N-bit random word

logic [ARRAY_WIDTH-1:0] o_sig_1;                       //Output word - m1 PRNG
logic [N-1:0] o_rn_1;                                  //N-bit random word

logic [ARRAY_WIDTH-1:0] o_sig_2;                       //Output word - m2 PRNG
logic [N-1:0] o_rn_2;                                  //N-bit random word

logic [479:0] merged_output;                           //
logic [7:0] pic_array [639:0][479:0];                  //640X480 array of 8-bit words - maybe paramatrize it
logic [9:0] row_pointer;                               //
integer k;                                             //
integer j;                                             //

logic hsync;                                           //
logic vsync;                                           //

logic [9:0] next_x_cor;                                //
logic [9:0] next_y_cor;                                //
//HDL code

//Instantiating CA_PRNG modules
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

//Combining the PRNGs output vectors in a 1D array with 20 pixels between each segment
assign merged_output = {o_rn_0,{20'{1'b0}},o_rn_1,{20'{1'b0}},o_rn_2,{(480-3*ARRAY_WIDTH-2*20)'{1'b0}}};

//Saving the CA_PRNG outputs into a 640X480 8-bit cells formatted as follows:
//Array Format   {R,1/0}.......................{G,1/0}.......................{B,1/0}     || (0,0)        (0,439)    ||
//               {R,1/0}.......................{G,1/0}.......................{B,1/0}     ||                         ||
//               {R,1/0}.......................{G,1/0}.......................{B,1/0}     ||                         ||
//                  .                                                                    ||                         ||
//                  .                                                                    ||                         ||
//                  .                                                                    ||                         ||
//               {R,1/0}......................{G,1/0}........................{B,1/0}     || (639,0)      (630,439)  ||

always @(posedge i_clk or negedge i_rst)
    if (!i_rst) begin                                //Initializing the picture array [Is this how it is done?][]
        for (k=0; k<640; k=k+1)
            for (j=0; j<480; j++)
              pic_array[k][j]<=8'h00;
        row_pointer<=8'h00;                         //Points on the row
    end
    else begin                                      //Loading the array with the CA-based PRNG output vectors
        if (row_pointer<$bits(row_pointer)'(640)) begin
          row_pointer<=row_pointer+$bits(row_pointer)'(1);
          for (k=0; k<480; k=k+1)  
            pic_array[row_pointer][k]<={7'b0000000,merged_output[k]};  //Modify this to produce different colors
        end
    end

//Generating the VGA driver 25MHz clock
always @(posedge i_clk)
    clk_VGA<=1_clk;

//Instantiating the VGA driver
VGA_Driver m0(.i_rst(i_rst_VGA),
              .i_clk(clk_VGA),
              .i_color(pic_array[next_x_cor][next_y_cor]),
              .hsync(hsync),
              .vsync(vsync),
              .o_red(o_red),
              .o_blue(o_blue),
              .o_green(o_green),
              .next_x_cor(next_x_cor),
              .next_y_cor(next_y_cor)
             );

assign VGA_blank_N=1'b1;                              //Tie to logic high (see ADV7123 video DAC datasheet)
assign VGA_sync_N=1'b0;                               //Tie to logic low (see ADV7123 video DAC datasheet)

endmodule
