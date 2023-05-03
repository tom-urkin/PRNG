//VGA Driver
module VGA_Driver(i_rst,i_clk,i_color,hsync,vsync,o_red,o_blue,o_green,next_x_cor,next_y_cor);
//Parameters
parameter ACTIVE_HORIZONTAL = 640;                     //
parameter ACTIVE_VERTICAL = 480;                       //

parameter H_LEN_FRONT_PORCH=16;                        //
parameter H_LEN_SYNC_PULSE=96;                         //
parameter H_LEN_BACK_PORCH=48;                         //

parameter V_LEN_FRONT_PORCH=10;                        //
parameter V_LEN_SYNC_PULSE=2;                          //
parameter V_LEN_BACK_PORCH=33;                         //

parameter W_COLOR=8;                                   //

//Local parameters
localparam TOTAL_HORIZONTAL = ACTIVE_HORIZONTAL+H_LEN_FRONT_PORCH+H_LEN_SYNC_PULSE+H_LEN_BACK_PORCH;           //Default : 800
localparam TOTAL_VERTICAL = ACTIVE_VERTICAL+V_LEN_FRONT_PORCH+V_LEN_SYNC_PULSE+V_LEN_BACK_PORCH;               //Default : 525

//FSM states
localparam IDLE=0;                                     //IDLE state
localparam ACTIVE=1;                                   //ACTIVE
localparam FRONT_PORCH_H=2;                            //Horizontal front porch phase
localparam SYNC_H=3;                                   //Horizontal sync phase
localparam BACK_PORCH_H=4;                             //Horizontal back porch phase
localparam FRONT_PORCH_V=5;                            //Vertical front porch phase
localparam SYNC_V=6;                                   //Vertial sync phase
localparam BACK_PORCH_V=7;                             //Vertical back porch phase

//Input signals
input logic i_rst;
input logic i_clk;
input logic [W_COLOR-1:0] i_color;                     // Check the FPGA manualu [?]

//Output signals
output logic hsync;                                    //
output logic vsync;                                    //
output logic [W_COLOR-1:0] o_red;                      //Input of the DAC in the VGA connector (converts into an analog signal between 0V-0.7V)
output logic [W_COLOR-1:0] o_green;                    //Input of the DAC in the VGA connector (converts into an analog signal between 0V-0.7V)
output logic [W_COLOR-1:0] o_blue;                     //Input of the DAC in the VGA connector (converts into an analog signal between 0V-0.7V)

output logic [9:0] next_x_cor;                         //X Coordinates of the next pixel. If ACTIVE_HORIZONTAL exceeds 1023, this width should be properly modified
output logic [9:0] next_y_cor;                         //Y Coordinates of the next pixel. If ACTIVE_VERTICAL exceeds 1023, this width should be properly modified

//Internal signals
logic [9:0] count_h;                                   //Resets at 800. If TOTAL_HORIZONTAL exceeds 1023, this width should be properly modified
logic [9:0] count_v;                                   //Resets at 525. If TOTAL_VERTICAL exceeds 1023, this width should be properly modified
logic [2:0] state;                                     //Current FSM state (7 states - 3 bits)
logic [2:0] next_state;                                //Next FSM state (7 states - 3 bits)

//HDL code

//FSM logic
always @(*)
  case (state)
    IDLE: next_state = (i_rst==1'b0) ? IDLE : ACTIVE;

    ACTIVE: next_state = (count_h<$bits(count_h)'(ACTIVE_HORIZONTAL-1)) ? ACTIVE : FRONT_PORCH_H;

    FRONT_PORCH_H : (count_h<$bits(count_h)'(ACTIVE_HORIZONTAL+H_LEN_FRONT_PORCH-1)) ? FRONT_PORCH_H : SYNC_H;

    SYNC_H : (count_h<$bits(count_h)'(ACTIVE_HORIZONTAL+H_LEN_FRONT_PORCH+H_LEN_SYNC_PULSE-1)) ? SYNC_H : BACK_PORCH_H;

    BACK_PORCH_H :  (count_h<$bits(count_h)'(TOTAL_HORIZONTAL-1)) ? BACK_PORCH_H : (count_v<$bits(count_v)'(ACTIVE_VERTICAL-1)) ? ACTIVE : FRONT_PORCH_V;

    FRONT_PORCH_V : (count_v<$bits(count_v)'(ACTIVE_VERTICAL+V_LEN_FRONT_PORCH-1)) ? FRONT_PORCH_V : SYNC_V;

    SYNC_V : (count_v<$bits(count_v)'(ACTIVE_VERTICAL+V_LEN_FRONT_PORCH+V_LEN_SYNC_PULSE-1)) ? SYNC_V : BACK_PORCH_V;

    BACK_PORCH_V : (count_v<$bits(count_v)'(TOTAL_VERTICAL-1)) ? BACK_PORCH_V : ACTIVE;
  endcase

//FSM next state calculation
always @(posedge i_clk or negedge i_rst)
  if (!i_rst)
    state<=IDLE;
  else
    state<=next_state;

//
always @(posedge i_clk or negedge i_rst)
  if (!i_rst) begin
    count_h<=1'b0;
    count_v<=1'b0;
    o_red<=$bits(o_red)'(0);
    o_green<=$bits(o_green)'(0);
    o_blue<=$bits(o_blue)'(0);
  end
  else if (state==IDLE) begin
    count_h<=1'b0;
    count_v<=1'b0;
    o_red<=$bits(o_red)'(0);
    o_green<=$bits(o_green)'(0);
    o_blue<=$bits(o_blue)'(0);
  end
  else if (state==ACTIVE) begin                //count_h is zero upon entering this state
    hsync<=1'b1;
    vsync<=1'b1;
    count_h<=count_h+$bits(count_h)'(1);
    o_red<={i_color[7:5],5'd0};
    o_blue<={i_color[1:0],6'd0};
    o_green<={i_color[4:2],5'd0};
  end
  else if (state==FRONT_PORCH_H) begin
    count_h<=count_h+$bits(count_h)'(1);
    o_red<=$bits(o_red)'(0);
    o_green<=$bits(o_green)'(0);
    o_blue<=$bits(o_blue)'(0);
  end
  else if (state==SYNC_H) begin
    hsync<=1'b0;
    count_h<=count_h+$bits(count_h)'(1);  
  end
  else if (state==BACK_PORCH_H) begin         //hsync must be continiously produced! make sure
    hsync<=1'b1;
    if (count_h==$bits(count_h)'(TOTAL_HORIZONTAL-1)) begin
      count_h<=1'b0;
      count_v<=count_v+$bits(count_v)'(1)
    end
    else 
      count_h<=count_h+$bits(count_h)'(1);  
  end 
  else if (state==FRONT_PORCH_V) begin
    o_red<=$bits(o_red)'(0);
    o_green<=$bits(o_green)'(0);
    o_blue<=$bits(o_blue)'(0);
    vsync<=1'b1;
    hsync<=(count_h<$bits(count_h)'(ACTIVE_HORIZONTAL+H_LEN_FRONT_PORCH)) ? 1'b1 : (count_h<$bits(count_h)'(ACTIVE_HORIZONTAL+H_LEN_FRONT_PORCH+H_LEN_SYNC_PULSE)) ? 1'b0 : 1'b1;
    if (count_h==TOTAL_HORIZONTAL-1) begin
      count_h<='0; 
      count_v<=count_v+$bits(count_v)'(1);
    else
      count_h<=count_h+$bits(count_h)'(1); 
    end
  end
  else if (state==SYNC_V) begin
    vsync<=1'b0;
    hsync<=(count_h<$bits(count_h)'(ACTIVE_HORIZONTAL+H_LEN_FRONT_PORCH)) ? 1'b1 : (count_h<$bits(count_h)'(ACTIVE_HORIZONTAL+H_LEN_FRONT_PORCH+H_LEN_SYNC_PULSE)) ? 1'b0 : 1'b1;
    if (count_h==TOTAL_HORIZONTAL-1) begin
      count_h<='0; 
      count_v<=count_v+$bits(count_v)'(1);
    end 
      count_h<=count_h+$bits(count_h)'(1);
  end
  else if (state==BACK_PORCH_V) begin
    vsync<=1'b1;
    hsync<=(count_h<$bits(count_h)'(ACTIVE_HORIZONTAL+H_LEN_FRONT_PORCH)) ? 1'b1 : (count_h<$bits(count_h)'(ACTIVE_HORIZONTAL+H_LEN_FRONT_PORCH+H_LEN_SYNC_PULSE)) ? 1'b0 : 1'b1;
    if (count_h==TOTAL_HORIZONTAL-1) begin
      count_h<='0; 
      count_v<=count_v+$bits(count_v)'(1);
    end 
      count_h<=count_h+$bits(count_h)'(1);
  end

//Next cycle pixel coordinates 
assign next_x_cor = (count_h<ACTIVE_HORIZONTAL) ? count_h : $bits(next_x_cor)'(0);
assign next_y_cor = (count_v<ACTIVE_VERTICAL) ? count_v : $bits(next_y_cor)'(0);
endmodule
