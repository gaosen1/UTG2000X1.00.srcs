`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/12 10:37:25
// Design Name: 
// Module Name: DAC124S_CTRL
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


module   DAC124S_CTRL(
            input   CLK,
            
            input   DAC124_CONFIG_EN,
            input   [15:0]DAC124_CONFIG_DATA,

            output  reg CH_AUX_DAC_SCLK,
            output  reg CH_AUX_DIN,
            output  reg CH_AUX_nSYNC
);

reg   config_en_r=1'b0;
reg   start_en=1'b0;
reg   [5:0]config_cnt=6'd0;

always@(posedge CLK)
begin
    config_en_r  <=  DAC124_CONFIG_EN;
    
    if(DAC124_CONFIG_EN ==  1'b1    &&  config_en_r  ==  1'b0)
        start_en  <=  1'b1;
    else
        start_en  <=  1'b0;
end

always@(posedge CLK)
begin
    if(start_en  ==  1'b1)
        config_cnt      <=  6'd63;
    else
        if(config_cnt   >   6'd0)
            config_cnt  <=  config_cnt  -   1'b1;
        else;
end

always@(posedge CLK)
begin       
    if(config_cnt   >   6'd0)
        CH_AUX_nSYNC  <=  1'b0;
    else
        CH_AUX_nSYNC  <=  1'b1;
end

always@(posedge CLK)
begin       
    if(start_en  ==  1'b1)
        CH_AUX_DIN  <=  1'b1;
    else
        if(config_cnt[0]    ==  1'b1)
            CH_AUX_DIN  <=  DAC124_CONFIG_DATA[config_cnt[5:2]];
        else;
end 

always@(posedge CLK)
begin
    CH_AUX_DAC_SCLK  <=  config_cnt[1];
end

endmodule
