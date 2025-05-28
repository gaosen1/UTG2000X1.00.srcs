`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/18 11:15:18
// Design Name: 
// Module Name: CHANNEL_REG_CONFIG
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


module CHANNEL_REG_CONFIG(
            input   CLK_LOW, 
             
            input   CH_LOAD_PROTECT,
            input   CH_CONFIG_WE,
            input   [7:0]CH_CONFIG_ADDR,
            input   [7:0]CH_CONFIG_DATA,
            //---------------------------------配置参数
            output  reg CH_LOAD_PROTECT_STATE,               
            output  reg [47:0]STAND_FREQ_INC,
            output  reg CH_ON_OFF,
            output  reg [3:0]CH_CNT_ATTEN      
);

reg  freq_updata=1'b0;
reg  [47:0]stand_freq_inc_reg=48'd0;
reg  ch_on_off_reg=1'b0;
reg  CH_LOAD_PROTECT_CLR=1'b1;
reg  ch_load_protect_reg=1'b0;
reg  [14:0]ch_delay_cnt=15'd0;
reg  ch_safe_check_fall=1'b0;

always@(posedge CLK_LOW)
begin
    if(ch_safe_check_fall     ==  1'b1)
        CH_LOAD_PROTECT_CLR   <=  1'b0;
    else;

    if(CH_CONFIG_WE  ==  1'b1)begin
        case(CH_CONFIG_ADDR)
        8'h03:  stand_freq_inc_reg[7 : 0]      <=  CH_CONFIG_DATA;
        8'h04:  stand_freq_inc_reg[15: 8]      <=  CH_CONFIG_DATA;
        8'h05:  stand_freq_inc_reg[23:16]      <=  CH_CONFIG_DATA;
        8'h06:  stand_freq_inc_reg[31:24]      <=  CH_CONFIG_DATA;
        8'h07:  stand_freq_inc_reg[39:32]      <=  CH_CONFIG_DATA;
        8'h08:  begin stand_freq_inc_reg[47:40]       <=  CH_CONFIG_DATA; freq_updata  <=  1'b1; end
        8'h2D:  ch_on_off_reg                  <=  CH_CONFIG_DATA[0];
        8'h31:  CH_CNT_ATTEN                   <=  CH_CONFIG_DATA[3:0];
        8'h5A:  CH_LOAD_PROTECT_CLR            <=  CH_CONFIG_DATA[0];
        default:;
        endcase
    end
    else
        begin
            freq_updata   <=  1'b0;
        end
end


always@(posedge CLK_LOW)
begin
    if(freq_updata ==  1'b1)
        STAND_FREQ_INC   <= stand_freq_inc_reg;
    else;
end


////////////////////////////////////////////////////////通道保护
always@(posedge CLK_LOW)
begin
    ch_load_protect_reg  <=  CH_LOAD_PROTECT;
    if(CH_LOAD_PROTECT  ==  1'b0  &&  ch_load_protect_reg  ==  1'b1)
        ch_safe_check_fall <=  1'b1;
    else
        ch_safe_check_fall <=  1'b0;
   
    if(ch_safe_check_fall  ==  1'b1)       
        ch_delay_cnt   <=  15'd0;
    else if(CH_LOAD_PROTECT   ==  1'b0)begin
        if(ch_delay_cnt    <   15'd24999)
            ch_delay_cnt   <=  ch_delay_cnt   +   1'b1;
        else;
    end
    else
        ch_delay_cnt  <=  15'd0;
   
    if(ch_delay_cnt[14:13]    ==  2'b11)
        CH_LOAD_PROTECT_STATE  <=  1'b1;
    else if(CH_LOAD_PROTECT_CLR  ==  1'b1)
        CH_LOAD_PROTECT_STATE  <=  1'b0;
    else;
end

always@(posedge CLK_LOW)
begin
    if(CH_LOAD_PROTECT_STATE  ==  1'b1)
        CH_ON_OFF  <=  1'b0;
    else if(ch_on_off_reg ==  1'b1)
        CH_ON_OFF  <=  1'b1;
    else
        CH_ON_OFF  <=  1'b0;
end 


endmodule
