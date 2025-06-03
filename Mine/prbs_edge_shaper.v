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

// 输出调试信号
assign edge_state_dbg = current_state;
assign edge_counter_dbg = edge_counter;

// PRBS边沿检测
always @(posedge dac_clk or negedge reset_n) begin
    if (!reset_n) begin
        prbs_bit_prev <= 1'b0;
    end else if (lfsr_clk_enable) begin
        prbs_bit_prev <= prbs_bit_out;
    end
end

wire prbs_rising_edge = lfsr_clk_enable && (prbs_bit_out && !prbs_bit_prev);
wire prbs_falling_edge = lfsr_clk_enable && (!prbs_bit_out && prbs_bit_prev);

// 计算步长 - 使用移位代替除法以节省资源
always @(*) begin
    if (prbs_edge_time_config_reg == 8'd0) begin
        step_size = DAC_MAX;  // 设置为最大值，实现瞬时跳变
    end else if (prbs_edge_time_config_reg == 8'd1) begin
        step_size = DAC_MAX;  // 只需1个周期，直接跳到最大值
    end else if (prbs_edge_time_config_reg == 8'd2) begin
        step_size = DAC_MAX >> 1;  // 最大值的一半
    end else if (prbs_edge_time_config_reg == 8'd4) begin
        step_size = DAC_MAX >> 2;  // 最大值的四分之一
    end else if (prbs_edge_time_config_reg == 8'd8) begin
        step_size = DAC_MAX >> 3;  // 最大值的八分之一
    end else if (prbs_edge_time_config_reg == 8'd16) begin
        step_size = DAC_MAX >> 4;  // 最大值的十六分之一
    end else if (prbs_edge_time_config_reg == 8'd32) begin
        step_size = DAC_MAX >> 5;  // 最大值的三十二分之一
    end else if (prbs_edge_time_config_reg == 8'd64) begin
        step_size = DAC_MAX >> 6;  // 最大值的六十四分之一
    end else if (prbs_edge_time_config_reg == 8'd128) begin
        step_size = DAC_MAX >> 7;  // 最大值的一百二十八分之一
    end else begin
        // 对于非2的幂次，使用近似值
        step_size = (DAC_MAX + (prbs_edge_time_config_reg >> 1)) / prbs_edge_time_config_reg;
    end
end

// 状态机和计数器
always @(posedge dac_clk or negedge reset_n) begin
    if (!reset_n) begin
        current_state <= S_STEADY_LOW;
        edge_counter <= 8'h0;
        current_dac_value <= DAC_MIN;
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
                
                // 防止溢出
                if (current_dac_value + step_size > DAC_MAX || edge_counter >= prbs_edge_time_config_reg - 1) begin
                    current_dac_value <= DAC_MAX;
                end else begin
                    current_dac_value <= current_dac_value + step_size;
                end
            end
            
            S_STEADY_HIGH: begin
                current_dac_value <= DAC_MAX;
                edge_counter <= 8'h0;
            end
            
            S_FALLING_EDGE: begin
                edge_counter <= edge_counter + 8'h1;
                
                // 防止下溢
                if (current_dac_value < step_size || edge_counter >= prbs_edge_time_config_reg - 1) begin
                    current_dac_value <= DAC_MIN;
                end else begin
                    current_dac_value <= current_dac_value - step_size;
                end
            end
        endcase
        
        // 更新输出
        shaped_prbs_data <= current_dac_value;
    end
end

// 状态转换逻辑
always @(*) begin
    next_state = current_state; // 默认保持当前状态
    
    case (current_state)
        S_STEADY_LOW: begin
            // 当检测到上升沿或PRBS为高时进入上升边沿状态
            if (lfsr_clk_enable && prbs_bit_out == 1'b1) 
                next_state = S_RISING_EDGE;
        end
        
        S_RISING_EDGE: begin
            // 完成边沿过渡
            if (edge_counter >= prbs_edge_time_config_reg - 1) begin
                // 检查是否需要立即开始下降
                if (lfsr_clk_enable && prbs_bit_out == 1'b0)
                    next_state = S_FALLING_EDGE;
                else
                    next_state = S_STEADY_HIGH;
            end
        end
        
        S_STEADY_HIGH: begin
            // 当检测到下降沿或PRBS为低时进入下降边沿状态
            if (lfsr_clk_enable && prbs_bit_out == 1'b0)
                next_state = S_FALLING_EDGE;
        end
        
        S_FALLING_EDGE: begin
            // 完成边沿过渡
            if (edge_counter >= prbs_edge_time_config_reg - 1) begin
                // 检查是否需要立即开始上升
                if (lfsr_clk_enable && prbs_bit_out == 1'b1)
                    next_state = S_RISING_EDGE;
                else
                    next_state = S_STEADY_LOW;
            end
        end
    endcase
end

endmodule
