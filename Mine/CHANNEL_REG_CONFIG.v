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
            input   reset_n,                      // 同步低有效复位
             
            input   CH_LOAD_PROTECT,
            input   CH_CONFIG_WE,
            input   [7:0]CH_CONFIG_ADDR,
            input   [7:0]CH_CONFIG_DATA,
            //---------------------------------配置参数
            output  reg CH_LOAD_PROTECT_STATE,               
            output  reg [47:0]STAND_FREQ_INC,
            output  reg CH_ON_OFF,
            output  reg [3:0]CH_CNT_ATTEN,
            
            // PRBS 相关的输出寄存器值
            output  reg [3:0]    prbs_pn_select_reg,      // PN阶数选择 (例如 0-12 对应 PN3-PN33)
            output  reg [31:0]   prbs_bit_rate_config_reg,// 位率NCO相位增量值
            output  reg [7:0]    prbs_edge_time_config_reg,// 边沿过渡DAC周期数
            output  reg [15:0]   prbs_amplitude_config_reg,// 幅度数字增益因子
            output  reg [15:0]   prbs_dc_offset_config_reg // 直流偏置数字值
);

reg  freq_updata=1'b0;
reg  [47:0]stand_freq_inc_reg=48'd0;
reg  ch_on_off_reg=1'b0;
reg  CH_LOAD_PROTECT_CLR=1'b1;
reg  ch_load_protect_reg=1'b0;
reg  [14:0]ch_delay_cnt=15'd0;
reg  ch_safe_check_fall=1'b0;
reg  prbs_config_update=1'b0; // PRBS配置更新标志

// PRBS 相关的内部寄存器
// 用于缓存多字节数据的各个字节
reg [7:0] prbs_bit_rate_bytes[3:0]; // 0:LSB, 3:MSB
reg [7:0] prbs_amplitude_bytes[1:0];
reg [7:0] prbs_dc_offset_bytes[1:0];

// -----------------------------------------------------------------------------
// 定义PRBS寄存器地址偏移
// -----------------------------------------------------------------------------
localparam ADDR_PN_ORDER         = 8'h00; // PN序列阶数
localparam ADDR_BIT_RATE_BYTE0   = 8'h01; // 位率配置 (4字节)
localparam ADDR_BIT_RATE_BYTE1   = 8'h02;
localparam ADDR_BIT_RATE_BYTE2   = 8'h03;
localparam ADDR_BIT_RATE_BYTE3   = 8'h04;
localparam ADDR_EDGE_TIME        = 8'h05; // 边沿过渡时间
localparam ADDR_AMPLITUDE_BYTE0  = 8'h06; // 幅度配置 (2字节)
localparam ADDR_AMPLITUDE_BYTE1  = 8'h07;
localparam ADDR_DC_OFFSET_BYTE0  = 8'h08; // 直流偏置配置 (2字节)
localparam ADDR_DC_OFFSET_BYTE1  = 8'h09;

always@(posedge CLK_LOW)
begin
    if(ch_safe_check_fall     ==  1'b1)
        CH_LOAD_PROTECT_CLR   <=  1'b0;
    else;

    if(CH_CONFIG_WE  ==  1'b1)begin
        case(CH_CONFIG_ADDR)
        // 原有DDS相关寄存器
        // 8'h03:  stand_freq_inc_reg[7 : 0]      <=  CH_CONFIG_DATA;
        // 8'h04:  stand_freq_inc_reg[15: 8]      <=  CH_CONFIG_DATA;
        // 8'h05:  stand_freq_inc_reg[23:16]      <=  CH_CONFIG_DATA;
        // 8'h06:  stand_freq_inc_reg[31:24]      <=  CH_CONFIG_DATA;
        // 8'h07:  stand_freq_inc_reg[39:32]      <=  CH_CONFIG_DATA;
        // 8'h08:  begin stand_freq_inc_reg[47:40]       <=  CH_CONFIG_DATA; freq_updata  <=  1'b1; end
        // 8'h2D:  ch_on_off_reg                  <=  CH_CONFIG_DATA[0];
        // 8'h31:  CH_CNT_ATTEN                   <=  CH_CONFIG_DATA[3:0];
        // 8'h5A:  CH_LOAD_PROTECT_CLR            <=  CH_CONFIG_DATA[0];
        
        // PRBS相关寄存器
        ADDR_PN_ORDER:          prbs_pn_select_reg <= CH_CONFIG_DATA[3:0]; // PN阶数是4位
        ADDR_BIT_RATE_BYTE0:    begin prbs_bit_rate_bytes[0] <= CH_CONFIG_DATA; prbs_config_update <= 1'b1; end
        ADDR_BIT_RATE_BYTE1:    begin prbs_bit_rate_bytes[1] <= CH_CONFIG_DATA; prbs_config_update <= 1'b1; end
        ADDR_BIT_RATE_BYTE2:    begin prbs_bit_rate_bytes[2] <= CH_CONFIG_DATA; prbs_config_update <= 1'b1; end
        ADDR_BIT_RATE_BYTE3:    begin prbs_bit_rate_bytes[3] <= CH_CONFIG_DATA; prbs_config_update <= 1'b1; end
        ADDR_EDGE_TIME:         prbs_edge_time_config_reg <= CH_CONFIG_DATA;
        ADDR_AMPLITUDE_BYTE0:   begin prbs_amplitude_bytes[0] <= CH_CONFIG_DATA; prbs_config_update <= 1'b1; end
        ADDR_AMPLITUDE_BYTE1:   begin prbs_amplitude_bytes[1] <= CH_CONFIG_DATA; prbs_config_update <= 1'b1; end
        ADDR_DC_OFFSET_BYTE0:   begin prbs_dc_offset_bytes[0] <= CH_CONFIG_DATA; prbs_config_update <= 1'b1; end
        ADDR_DC_OFFSET_BYTE1:   begin prbs_dc_offset_bytes[1] <= CH_CONFIG_DATA; prbs_config_update <= 1'b1; end
        
        default:;
        endcase
    end
    else
        begin
            freq_updata   <=  1'b0;
            prbs_config_update <= 1'b0;
    end
end


always@(posedge CLK_LOW)
begin
    if(freq_updata ==  1'b1)
        STAND_FREQ_INC   <= stand_freq_inc_reg;
    else if(prbs_config_update == 1'b1) begin
        prbs_bit_rate_config_reg <= {prbs_bit_rate_bytes[3], prbs_bit_rate_bytes[2],
                                    prbs_bit_rate_bytes[1], prbs_bit_rate_bytes[0]}; // 组合成32位
        prbs_amplitude_config_reg <= {prbs_amplitude_bytes[1], prbs_amplitude_bytes[0]}; // 组合成16位
        prbs_dc_offset_config_reg <= {prbs_dc_offset_bytes[1], prbs_dc_offset_bytes[0]}; // 组合成16位
        prbs_config_update <= 1'b0;
    end
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


// 组合多字节PRBS寄存器
always @(posedge CLK_LOW or negedge reset_n) begin
    if (!reset_n) begin
        prbs_bit_rate_config_reg <= 32'h0;
        prbs_amplitude_config_reg <= 16'h0;
        prbs_dc_offset_config_reg <= 16'h0;
    end else begin
        prbs_bit_rate_config_reg <= {prbs_bit_rate_bytes[3], prbs_bit_rate_bytes[2],
                                    prbs_bit_rate_bytes[1], prbs_bit_rate_bytes[0]}; // 组合成32位
        prbs_amplitude_config_reg <= {prbs_amplitude_bytes[1], prbs_amplitude_bytes[0]}; // 组合成16位
        prbs_dc_offset_config_reg <= {prbs_dc_offset_bytes[1], prbs_dc_offset_bytes[0]}; // 组合成16位
    end
end

// 初始化PRBS相关寄存器
always @(posedge CLK_LOW or negedge reset_n) begin
    if (!reset_n) begin
        prbs_config_update <= 1'b0;
        prbs_pn_select_reg <= 4'h0;
        prbs_bit_rate_config_reg <= 32'h02000000; // 位率设置 (总时钟的1/64)
        prbs_edge_time_config_reg <= 8'h0;
        prbs_amplitude_config_reg <= 16'h0;
        prbs_dc_offset_config_reg <= 16'h0;
        
        prbs_bit_rate_bytes[0] <= 8'h0;
        prbs_bit_rate_bytes[1] <= 8'h0;
        prbs_bit_rate_bytes[2] <= 8'h0;
        prbs_bit_rate_bytes[3] <= 8'h0;
        prbs_amplitude_bytes[0] <= 8'h0;
        prbs_amplitude_bytes[1] <= 8'h0;
        prbs_dc_offset_bytes[0] <= 8'h0;
        prbs_dc_offset_bytes[1] <= 8'h0;
    end
end

endmodule
