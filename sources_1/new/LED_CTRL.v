`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/18 10:20:45
// Design Name: 
// Module Name: LED_CTRL
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
/*---------------------------------------------------------------------
ARM_LED_DATA[4]为0时，FPGA控制外部灯流水点亮
ARM_LED_DATA[4]为1时，功能控制外部灯点亮
-------------------------------------------------------------------*/

module   LED_CTRL(
            input   CLK,
            input   [4:0]ARM_LED_DATA,
            
            output  CH1_LED,
            output  CH2_LED,
            output  SYNC_LED,
            output  MODE_LED
);

reg  [24:0]led_time=25'd0;
reg  [3:0]led_ctrl_w=4'b0111;
reg  [3:0]led_ctrl_w1=4'b1111;
reg  [3:0]led_cnt=4'd0;
assign  CH2_LED    =  led_ctrl_w1[3];
assign  CH1_LED    =  led_ctrl_w1[1];
assign  SYNC_LED   =  led_ctrl_w1[2];
assign  MODE_LED   =  led_ctrl_w1[0];

reg  arm_led_sel=1'b0;
reg  [3:0]arm_led_ctrl=4'b1111;
always@(posedge CLK)
begin
    arm_led_sel    <=  ARM_LED_DATA[4];
    arm_led_ctrl   <=  ARM_LED_DATA[3:0];
end

reg led_time_en=1'b0;
always @(posedge CLK) 
begin
    if(led_time  ==  25'd25000000)
        led_time_en  <= 1'b1;
    else
        led_time_en  <= 1'b0;
end

reg led_ctrl_en=1'b0;
always @(posedge CLK) 
begin
    if(led_time  ==  25'd1)
        led_ctrl_en  <= 1'b1;
    else
        led_ctrl_en  <= 1'b0;
end

always@(posedge CLK)
begin
    if(arm_led_sel  ==  1'b0)begin
        if(led_time_en == 1'b1)//
            led_time  <=  25'd0;
        else
            led_time  <=  led_time  +1'b1;
    end
    else;
end

reg led_cnt_en=1'b1;
always @(posedge CLK) 
begin
    if(led_cnt  < 4'd12)    
        led_cnt_en <=  1'b1;
    else
        led_cnt_en <=  1'b0;
end
    
always@(posedge CLK)
begin
    if(led_cnt_en == 1'b1 && led_time_en == 1'b1)
    // begin
    //     if(led_time_en == 1'b1)//
            led_cnt  <=  led_cnt  + 1'b1;
    //     else;
    // end
    else;
end
    
always@(posedge CLK)
begin
    if(led_cnt_en ==  1'b0)
        led_ctrl_w  <=  4'b0000;
    else if(led_ctrl_en  ==  1'b1)
        led_ctrl_w  <=  {led_ctrl_w[2:1],led_ctrl_w[3],1'b0};
    else;
end

always@(posedge CLK)
begin
    if(arm_led_sel  ==  1'b0)
        led_ctrl_w1  <=  led_ctrl_w;
    else
        led_ctrl_w1  <=  arm_led_ctrl;
end

endmodule