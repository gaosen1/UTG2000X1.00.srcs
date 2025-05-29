`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 模块名称: prbs_modulator
// 功能描述: PRBS信号调制器，将PRBS位转换为DAC数值
//////////////////////////////////////////////////////////////////////////////////

module prbs_modulator (
    input wire          dac_clk,            // 主DAC时钟
    input wire          reset_n,            // 同步低有效复位
    input wire          prbs_bit_in,        // 输入的PRBS位
    input wire [7:0]    edge_time_config,   // 边沿过渡DAC周期数
    input wire [15:0]   amplitude_config,   // 幅度数字增益因子
    input wire [15:0]   dc_offset_config,   // 直流偏置数字值
    
    output reg [15:0]   dac_data_out        // 16位DAC数据输出
);

// 内部寄存器
reg          prbs_bit_reg;        // 寄存器化的PRBS位
reg          prev_prbs_bit;       // 上一个PRBS位
reg [7:0]    edge_counter;        // 边沿过渡计数器
reg          in_transition;       // 是否在过渡状态
reg [15:0]   high_level;          // 高电平值
reg [15:0]   low_level;           // 低电平值
reg [15:0]   current_target;      // 当前目标电平

// 计算高低电平值
always @(posedge dac_clk or negedge reset_n) begin
    if (!reset_n) begin
        high_level <= 16'h8000 + (amplitude_config >> 1);
        low_level <= 16'h8000 - (amplitude_config >> 1);
    end else begin
        // 高电平 = 中点(0x8000) + 幅度/2 + 直流偏置
        high_level <= 16'h8000 + (amplitude_config >> 1) + dc_offset_config;
        // 低电平 = 中点(0x8000) - 幅度/2 + 直流偏置
        low_level <= 16'h8000 - (amplitude_config >> 1) + dc_offset_config;
    end
end

// 检测位变化并处理过渡
always @(posedge dac_clk or negedge reset_n) begin
    if (!reset_n) begin
        prbs_bit_reg <= 1'b0;
        prev_prbs_bit <= 1'b0;
        edge_counter <= 8'd0;
        in_transition <= 1'b0;
        current_target <= 16'h8000; // 中点电平
        dac_data_out <= 16'h8000;   // 中点电平
    end else begin
        // 寄存器化输入位
        prbs_bit_reg <= prbs_bit_in;
        
        // 检测位变化
        if (prbs_bit_reg != prev_prbs_bit) begin
            prev_prbs_bit <= prbs_bit_reg;
            edge_counter <= 8'd0;
            in_transition <= 1'b1;
            
            // 设置目标电平
            current_target <= prbs_bit_reg ? high_level : low_level;
        end
        
        // 处理过渡
        if (in_transition) begin
            if (edge_counter < edge_time_config) begin
                edge_counter <= edge_counter + 8'd1;
                
                // 线性插值计算过渡值
                if (prbs_bit_reg) begin
                    // 从低到高的过渡
                    dac_data_out <= low_level + (((high_level - low_level) * edge_counter) / edge_time_config);
                end else begin
                    // 从高到低的过渡
                    dac_data_out <= high_level - (((high_level - low_level) * edge_counter) / edge_time_config);
                end
            end else begin
                // 过渡完成
                in_transition <= 1'b0;
                dac_data_out <= current_target;
            end
        end else begin
            // 稳定状态
            dac_data_out <= current_target;
        end
    end
end

endmodule
