`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 模块名称: prbs_generator_top
// 功能描述: PRBS生成器顶层模块，包含位率时钟生成和PRBS序列生成
//////////////////////////////////////////////////////////////////////////////////

module prbs_generator_top (
    input wire          dac_clk,                // 主DAC时钟，例如 625MHz
    input wire          reset_n,                // 同步低有效复位
    input wire          CLK_LOW,                // 配置时钟
    input wire          CH_CONFIG_WE,           // 配置写使能
    input wire [7:0]    CH_CONFIG_ADDR,         // 配置地址
    input wire [7:0]    CH_CONFIG_DATA,         // 配置数据
    output wire         CH_LOAD_PROTECT_STATE,  // 通道保护状态
    
    // 输出信号
    output wire         prbs_valid,             // PRBS数据有效标志
    output wire         prbs_bit_out_debug,     // 调试用：PRBS位输出
    output wire [15:0]  prbs_dac_data,          // 16位DAC数据输出
    output wire [32:0]  lfsr_state_debug        // 调试用：LFSR寄存器状态
);

// 内部连接信号
wire        lfsr_clk_enable;  // 位率时钟使能信号
wire        prbs_bit_out;     // 原始PRBS位输出
wire        data_valid;       // 数据有效标志
wire [32:0] lfsr_state;       // LFSR寄存器状态，用于调试

// CHANNEL_REG_CONFIG 模块实例化
wire [4:0]    prbs_pn_select_reg;     // PN阶数选择
wire [31:0]   prbs_bit_rate_config_reg; // 位率NCO相位增量值
wire [7:0]    prbs_edge_time_config_reg; // 边沿过渡DAC周期数
wire [15:0]   prbs_amplitude_config_reg; // 幅度数字增益因子
wire [15:0]   prbs_dc_offset_config_reg; // 直流偏置数字值

CHANNEL_REG_CONFIG channel_config (
    .CLK_LOW(CLK_LOW),
    .reset_n(reset_n),
    .CH_CONFIG_WE(CH_CONFIG_WE),
    .CH_CONFIG_ADDR(CH_CONFIG_ADDR),
    .CH_CONFIG_DATA(CH_CONFIG_DATA),
    .CH_LOAD_PROTECT_STATE(CH_LOAD_PROTECT_STATE),
    .CH_ON_OFF(),  // 未使用
    .CH_CNT_ATTEN(), // 未使用
    .prbs_pn_select_reg(prbs_pn_select_reg),
    .prbs_bit_rate_config_reg(prbs_bit_rate_config_reg),
    .prbs_edge_time_config_reg(prbs_edge_time_config_reg),
    .prbs_amplitude_config_reg(prbs_amplitude_config_reg),
    .prbs_dc_offset_config_reg(prbs_dc_offset_config_reg)
);

// 位率时钟生成模块实例化
prbs_bitrate_clk_gen bitrate_gen (
    .dac_clk(dac_clk),
    .reset_n(reset_n),
    .prbs_bit_rate_config_reg(prbs_bit_rate_config_reg),
    .lfsr_clk_enable(lfsr_clk_enable)
);

// PRBS序列生成器模块实例化
prbs_core_lfsr prbs_core (
    .dac_clk(dac_clk),
    .reset_n(reset_n),
    .lfsr_clk_enable(lfsr_clk_enable),
    .prbs_pn_select_reg(prbs_pn_select_reg),
    .prbs_bit_out(prbs_bit_out),
    .data_valid(data_valid),
    .lfsr_state(lfsr_state)
);

// 边沿整形模块实例化 - 将PRBS位转换为带斜坡的DAC数值
wire [15:0] shaped_prbs_data;  // 整形后的PRBS数据
wire [1:0] edge_state_dbg;    // 边沿状态调试信号
wire [7:0] edge_counter_dbg;  // 边沿计数器调试信号

prbs_edge_shaper edge_shaper (
    .dac_clk(dac_clk),
    .reset_n(reset_n),
    .prbs_bit_out(prbs_bit_out),
    .lfsr_clk_enable(lfsr_clk_enable),
    .prbs_edge_time_config_reg(prbs_edge_time_config_reg),
    .shaped_prbs_data(shaped_prbs_data),
    .edge_state_dbg(edge_state_dbg),
    .edge_counter_dbg(edge_counter_dbg)
);

// 输出赋值
assign prbs_valid = data_valid;
assign prbs_bit_out_debug = prbs_bit_out;
assign lfsr_state_debug = lfsr_state;

// 将整形后的数据输出到DAC
assign prbs_dac_data = shaped_prbs_data;

endmodule
