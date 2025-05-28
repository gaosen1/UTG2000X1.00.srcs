`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/12 15:42:30
// Design Name: 
// Module Name: AD9518_CTRL
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


module   AD9518_CTRL(
            input   CLK,

            input   CONFIG_EN,
            input   [23:0]CONFIG_DATA,
            
            output  reg CONFIG_END=1'b0,
            output  reg AD9518_nCS=1'b1,
            output  reg AD9518_SCLK=1'b1,
            output  reg AD9518_SDIO=1'b0
);

reg  config_en_r=1'b0;
reg  start_en=1'b0;
reg  [6:0]config_cnt=7'd0;

always@(posedge CLK)
begin
    config_en_r  <=  CONFIG_EN;
    
    if(CONFIG_EN ==  1'b1  &&  config_en_r  ==  1'b0)
        start_en  <=  1'b1;
    else
        start_en  <=  1'b0;
end

always@(posedge CLK)
begin
    if(start_en  ==  1'b1)
        config_cnt  <=  7'd95;
    else if(config_cnt  >  7'd0)
        config_cnt  <=  config_cnt  -   1'b1;
    else;
end


always@(posedge CLK)
begin
    if(config_cnt   ==  7'd1)
        CONFIG_END  <=  1'b1;
    else
        CONFIG_END  <=  1'b0;
end

always@(posedge CLK)
begin       
    if(start_en  ==  1'b1)
        AD9518_SCLK  <=  1'b1;
    else if(config_cnt[0]  ==  1'b1)
        AD9518_SCLK  <=  ~AD9518_SCLK;
    else;
end

always@(posedge CLK)
begin       
    if(config_cnt   >   7'd0)
        AD9518_nCS  <=  1'b0;
    else
        AD9518_nCS  <=  1'b1;
end

always@(posedge CLK)
begin       
    if(start_en  ==  1'b1)
        AD9518_SDIO  <=  1'b1;
    else if(config_cnt[0]    ==  1'b1)
        AD9518_SDIO  <=  CONFIG_DATA[config_cnt[6:2]];
    else;
end 

endmodule
