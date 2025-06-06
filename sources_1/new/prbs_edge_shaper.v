`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 模块名称: prbs_edge_shaper
// 功能描述: 将1位PRBS信号整形为多位带斜坡的信号
//////////////////////////////////////////////////////////////////////////////////

module prbs_edge_shaper (
    input wire          dac_clk,                  // 主DAC时钟，例如 625MHz
    input wire          reset_n,                  // 同步低有效复位
    input wire          prbs_bit_out,             // 1位原始PRBS序列 (来自 prbs_core_lfsr)
    input wire          lfsr_clk_enable,          // PRBS移位使能 (指示 prbs_bit_out 可能变化)
    input wire [7:0]    prbs_edge_time_config_reg,// 边沿过渡DAC周期数 (Nedge_cycles)
    input wire [1:0]    filter_strength,          // 滤波器强度控制 (0=不滤波, 1=弱, 2=中, 3=强)
    
    output reg  [15:0]  shaped_prbs_data,         // 16位整形后的PRBS数据
    output wire [1:0]   edge_state_dbg,           // 输出当前状态(调试用)
    output wire [7:0]   edge_counter_dbg          // 输出边沿计数器(调试用)
);

// 参数定义
parameter OUTPUT_WIDTH = 16;               // 输出位宽
parameter DAC_MAX = 16'h7FFF;              // 最大输出值 (32767)
parameter DAC_MIN = 16'h0000;              // 最小输出值 (0)

// 边沿状态机
localparam S_STEADY_LOW  = 2'b00;
localparam S_RISING_EDGE = 2'b01;
localparam S_STEADY_HIGH = 2'b10;
localparam S_FALLING_EDGE= 2'b11;

// 内部寄存器
reg [1:0] current_state, next_state;
reg [7:0] edge_counter;          // 计数边沿过渡周期
reg [15:0] current_dac_value;    // 当前DAC输出值
reg [15:0] step_size;            // 每步的数字增量/减量
reg prbs_bit_prev;               // 前一个PRBS位值

// 滤波器寄存器 - 移动平均滤波器
reg [15:0] filter_buffer [0:3];  // 4点移动平均缓冲区
reg [15:0] filtered_value;       // 滤波后的值

// 输出调试信号
assign edge_state_dbg = current_state;
assign edge_counter_dbg = edge_counter;

// PRBS边沿检测
always @(posedge dac_clk or negedge reset_n) begin
    if (!reset_n) begin
        prbs_bit_prev <= 1'b0;
    end else begin
        // 每个时钟周期都检查PRBS位变化，但保留对lfsr_clk_enable的感知
        prbs_bit_prev <= prbs_bit_out;
    end
end

// 检测边沿，使用两种检测方式
wire prbs_bit_changed = prbs_bit_out != prbs_bit_prev;
wire prbs_rising_edge = prbs_bit_out && !prbs_bit_prev;
wire prbs_falling_edge = !prbs_bit_out && prbs_bit_prev;

// 记录最近一次lfsr_clk_enable的状态
reg lfsr_clk_enable_occurred;
always @(posedge dac_clk or negedge reset_n) begin
    if (!reset_n) begin
        lfsr_clk_enable_occurred <= 1'b0;
    end else begin
        if (lfsr_clk_enable)
            lfsr_clk_enable_occurred <= 1'b1;
        else if (prbs_bit_changed)
            lfsr_clk_enable_occurred <= 1'b0;
    end
end

// 计算步长 - 优化为更精确的计算，确保均匀过渡
always @(*) begin
    if (prbs_edge_time_config_reg == 8'd0 || prbs_edge_time_config_reg == 8'd1) begin
        step_size = DAC_MAX;  // 设置为最大值，实现瞬时跳变
    end else begin
        // 精确计算步长，避免累积误差
        // 使用乘法和除法确保均匀分布，对于FPGA综合工具会优化为常数
        step_size = DAC_MAX / prbs_edge_time_config_reg;
        
        // 如果不能整除，稍微调整步长以确保最后一步正好达到目标值
        if ((DAC_MAX % prbs_edge_time_config_reg) != 0) begin
            // 步长略微调大，确保不会超过总周期数
            step_size = step_size + 1;
        end
    end
end

// 状态机和计数器
always @(posedge dac_clk or negedge reset_n) begin
    if (!reset_n) begin
        current_state <= S_STEADY_LOW;
        edge_counter <= 8'h0;
        current_dac_value <= DAC_MIN;
        
        // 初始化滤波器缓冲区
        filter_buffer[0] <= DAC_MIN;
        filter_buffer[1] <= DAC_MIN;
        filter_buffer[2] <= DAC_MIN;
        filter_buffer[3] <= DAC_MIN;
        filtered_value <= DAC_MIN;
        shaped_prbs_data <= DAC_MIN;
    end else begin
        current_state <= next_state;
        
        // 更新DAC值和计数器
        case (current_state)
            S_STEADY_LOW: begin
                current_dac_value <= DAC_MIN;
                edge_counter <= 8'h0;
            end
            
            S_RISING_EDGE: begin
                edge_counter <= edge_counter + 8'h1;
                
                // 优化边界条件处理
                if (edge_counter >= prbs_edge_time_config_reg - 1) begin
                    // 最后一个周期，确保精确到达最大值
                    current_dac_value <= DAC_MAX;
                end else begin
                    // 计算当前应达到的精确值，避免累积误差
                    // 对于每个时钟周期，我们计算应该达到的精确值
                    current_dac_value <= DAC_MIN + ((edge_counter + 1) * step_size);
                    
                    // 防止溢出
                    if (current_dac_value > DAC_MAX) begin
                        current_dac_value <= DAC_MAX;
                    end
                end
            end
            
            S_STEADY_HIGH: begin
                current_dac_value <= DAC_MAX;
                edge_counter <= 8'h0;
            end
            
            S_FALLING_EDGE: begin
                edge_counter <= edge_counter + 8'h1;
                
                // 优化边界条件处理
                if (edge_counter >= prbs_edge_time_config_reg - 1) begin
                    // 最后一个周期，确保精确到达最小值
                    current_dac_value <= DAC_MIN;
                end else begin
                    // 计算当前应达到的精确值，避免累积误差
                    // 对于每个时钟周期，我们计算应该达到的精确值
                    current_dac_value <= DAC_MAX - ((edge_counter + 1) * step_size);
                    
                    // 防止下溢
                    if (current_dac_value > DAC_MAX) begin  // 检查下溢（无符号数下溢会变成很大的值）
                        current_dac_value <= DAC_MIN;
                    end
                end
            end
        endcase
        
        // 移动平均滤波器实现
        filter_buffer[0] <= filter_buffer[1];
        filter_buffer[1] <= filter_buffer[2];
        filter_buffer[2] <= filter_buffer[3];
        filter_buffer[3] <= current_dac_value;
        
        // 根据滤波强度选择不同的滤波算法
        case (filter_strength)
            2'b00: begin
                // 不滤波
                filtered_value <= current_dac_value;
            end
            2'b01: begin
                // 弱滤波 - 最近两个值的平均
                filtered_value <= (filter_buffer[3] + filter_buffer[2]) >> 1;
            end
            2'b10: begin
                // 中等滤波 - 最近三个值的平均
                filtered_value <= (filter_buffer[3] + filter_buffer[2] + filter_buffer[1]) / 3;
            end
            2'b11: begin
                // 强滤波 - 四点移动平均
                filtered_value <= (filter_buffer[3] + filter_buffer[2] + filter_buffer[1] + filter_buffer[0]) >> 2;
            end
        endcase
        
        // 更新输出
        shaped_prbs_data <= filtered_value;
    end
end

// 状态转换逻辑
always @(*) begin
    next_state = current_state; // 默认保持当前状态
    
    case (current_state)
        S_STEADY_LOW: begin
            // 当检测到上升沿或PRBS为高时进入上升边沿状态
            // 当出现上升沿，或者在lfsr_clk_enable后检测到高电平时转换
            if (prbs_rising_edge || (lfsr_clk_enable_occurred && prbs_bit_out == 1'b1)) 
                next_state = S_RISING_EDGE;
        end
        
        S_RISING_EDGE: begin
            // 完成边沿过渡
            if (edge_counter >= prbs_edge_time_config_reg - 1) begin
                // 检查是否需要立即开始下降
                if (prbs_falling_edge || (lfsr_clk_enable_occurred && prbs_bit_out == 1'b0))
                    next_state = S_FALLING_EDGE;
                else
                    next_state = S_STEADY_HIGH;
            end
        end
        
        S_STEADY_HIGH: begin
            // 当检测到下降沿或PRBS为低时进入下降边沿状态
            if (prbs_falling_edge || (lfsr_clk_enable_occurred && prbs_bit_out == 1'b0))
                next_state = S_FALLING_EDGE;
        end
        
        S_FALLING_EDGE: begin
            // 完成边沿过渡
            if (edge_counter >= prbs_edge_time_config_reg - 1) begin
                // 检查是否需要立即开始上升
                if (prbs_rising_edge || (lfsr_clk_enable_occurred && prbs_bit_out == 1'b1))
                    next_state = S_RISING_EDGE;
                else
                    next_state = S_STEADY_LOW;
            end
        end
    endcase
end

endmodule
