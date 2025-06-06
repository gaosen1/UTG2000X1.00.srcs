`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 模块名称: prbs_generator_top
// 功能描述: PRBS生成器顶层模块，包含位率时钟生成和PRBS序列生成
//////////////////////////////////////////////////////////////////////////////////

module prbs_generator_top (
    input wire          dac_clk,                // 主DAC时钟，例如 625MHz
    input wire          reset_n,                // 同步低有效复位
    input wire          CH_LOAD_PROTECT_STATE,  // 通道保护状态
    // Configuration inputs (previously from internal CHANNEL_REG_CONFIG)
    input wire [3:0]    prbs_pn_select_in,
    input wire [31:0]   prbs_bit_rate_config_in,
    input wire [7:0]    prbs_edge_time_config_in,
    input wire [1:0]    filter_strength,          // 滤波器强度控制 (0=不滤波, 1=弱, 2=中, 3=强)
    
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

// CHANNEL_REG_CONFIG module is now instantiated externally.
// Configuration values are provided as inputs to this top module.

// 位率时钟生成模块实例化
prbs_bitrate_clk_gen bitrate_gen (
    .dac_clk(dac_clk),
    .reset_n(reset_n),
    .prbs_bit_rate_config_reg(prbs_bit_rate_config_in),
    .lfsr_clk_enable(lfsr_clk_enable)
);

// PRBS序列生成器模块实例化
prbs_core_lfsr prbs_core (
    .dac_clk(dac_clk),
    .reset_n(reset_n),
    .lfsr_clk_enable(lfsr_clk_enable),
    .prbs_pn_select_reg(prbs_pn_select_in),
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
    .prbs_edge_time_config_reg(prbs_edge_time_config_in),
    .filter_strength(filter_strength),
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

// 当通道保护激活时，DAC 输出置零
// assign prbs_dac_data = CH_LOAD_PROTECT_STATE ? 16'h0000 : shaped_prbs_data;

endmodule
