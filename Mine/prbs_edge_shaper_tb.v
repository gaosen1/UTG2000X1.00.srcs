`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 模块名称: prbs_edge_shaper_tb
// 功能描述: prbs_edge_shaper模块的测试平台
//////////////////////////////////////////////////////////////////////////////////

module prbs_edge_shaper_tb;

// 测试参数
parameter CLK_PERIOD = 1.6; // 625MHz的周期为1.6ns

// 测试信号
reg         dac_clk;
reg         reset_n;
reg         prbs_bit_out;
reg         lfsr_clk_enable;
reg [7:0]   prbs_edge_time_config_reg;
reg [1:0]   filter_strength;

wire [15:0] shaped_prbs_data;
wire [1:0]  edge_state_dbg;
wire [7:0]  edge_counter_dbg;

// 用于记录和验证的变量
integer i;
reg [15:0] prev_value;
reg [15:0] current_value;
reg [15:0] step_diff;
reg [15:0] expected_step;
reg [15:0] max_diff;
reg [15:0] min_diff;
reg [15:0] total_diff;
real avg_diff;

// 实例化被测模块
prbs_edge_shaper dut (
    .dac_clk(dac_clk),
    .reset_n(reset_n),
    .prbs_bit_out(prbs_bit_out),
    .lfsr_clk_enable(lfsr_clk_enable),
    .prbs_edge_time_config_reg(prbs_edge_time_config_reg),
    .filter_strength(filter_strength),
    .shaped_prbs_data(shaped_prbs_data),
    .edge_state_dbg(edge_state_dbg),
    .edge_counter_dbg(edge_counter_dbg)
);

// 时钟生成
initial begin
    dac_clk = 0;
    forever #(CLK_PERIOD/2) dac_clk = ~dac_clk;
end

// 测试过程
initial begin
    // 初始化
    reset_n = 0;
    prbs_bit_out = 0;
    lfsr_clk_enable = 0;
    prbs_edge_time_config_reg = 8'd16; // 16个周期的边沿时间
    filter_strength = 2'b00; // 初始不使用滤波
    max_diff = 0;
    min_diff = 16'hFFFF;
    total_diff = 0;
    
    // 复位释放
    #(CLK_PERIOD*10);
    reset_n = 1;
    #(CLK_PERIOD*5);
    
    // 测试1: 无滤波的上升沿
    $display("测试1: 无滤波的上升沿");
    filter_strength = 2'b00;
    lfsr_clk_enable = 1;
    #(CLK_PERIOD);
    lfsr_clk_enable = 0;
    prbs_bit_out = 1;
    #(CLK_PERIOD*50);
    
    // 测试2: 弱滤波的下降沿
    $display("测试2: 弱滤波的下降沿");
    filter_strength = 2'b01;
    lfsr_clk_enable = 1;
    #(CLK_PERIOD);
    lfsr_clk_enable = 0;
    prbs_bit_out = 0;
    #(CLK_PERIOD*50);
    
    // 测试3: 中等滤波的上升沿
    $display("测试3: 中等滤波的上升沿");
    filter_strength = 2'b10;
    lfsr_clk_enable = 1;
    #(CLK_PERIOD);
    lfsr_clk_enable = 0;
    prbs_bit_out = 1;
    #(CLK_PERIOD*50);
    
    // 测试4: 强滤波的下降沿
    $display("测试4: 强滤波的下降沿");
    filter_strength = 2'b11;
    lfsr_clk_enable = 1;
    #(CLK_PERIOD);
    lfsr_clk_enable = 0;
    prbs_bit_out = 0;
    #(CLK_PERIOD*50);
    
    // 测试5: 快速变化的PRBS信号
    $display("测试5: 快速变化的PRBS信号");
    prbs_edge_time_config_reg = 8'd8; // 缩短边沿时间
    
    // 上升沿
    filter_strength = 2'b11; // 使用强滤波
    lfsr_clk_enable = 1;
    #(CLK_PERIOD);
    lfsr_clk_enable = 0;
    prbs_bit_out = 1;
    #(CLK_PERIOD*20);
    
    // 下降沿
    lfsr_clk_enable = 1;
    #(CLK_PERIOD);
    lfsr_clk_enable = 0;
    prbs_bit_out = 0;
    #(CLK_PERIOD*20);
    
    // 再次上升沿
    lfsr_clk_enable = 1;
    #(CLK_PERIOD);
    lfsr_clk_enable = 0;
    prbs_bit_out = 1;
    #(CLK_PERIOD*20);
    
    // 测试6: 非2的幂次的边沿时间配置（测试优化后的步长计算）
    $display("测试6: 非2的幂次的边沿时间配置 - 测试步长均匀性");
    prbs_edge_time_config_reg = 8'd10; // 10个周期的边沿时间（非2的幂次）
    filter_strength = 2'b00; // 不使用滤波以便观察原始步长
    
    // 准备记录步长
    max_diff = 0;
    min_diff = 16'hFFFF;
    total_diff = 0;
    
    // 上升沿
    lfsr_clk_enable = 1;
    #(CLK_PERIOD);
    lfsr_clk_enable = 0;
    prbs_bit_out = 0; // 确保从低电平开始
    #(CLK_PERIOD*5);
    
    // 记录初始值
    prev_value = shaped_prbs_data;
    
    // 触发上升沿并记录每个步长
    lfsr_clk_enable = 1;
    #(CLK_PERIOD);
    lfsr_clk_enable = 0;
    prbs_bit_out = 1;
    
    expected_step = 16'h7FFF / prbs_edge_time_config_reg;
    if ((16'h7FFF % prbs_edge_time_config_reg) != 0) begin
        expected_step = expected_step + 1;
    end
    $display("预期步长: %d", expected_step);
    
    // 记录10个周期内的步长变化
    for (i = 0; i < 10; i = i + 1) begin
        #(CLK_PERIOD);
        current_value = shaped_prbs_data;
        if (i > 0 && prev_value != current_value) begin
            step_diff = (current_value > prev_value) ? (current_value - prev_value) : (prev_value - current_value);
            $display("周期 %d: 从 %d 到 %d, 步长 = %d", i, prev_value, current_value, step_diff);
            
            if (step_diff > max_diff) max_diff = step_diff;
            if (step_diff < min_diff) min_diff = step_diff;
            total_diff = total_diff + step_diff;
        end
        prev_value = current_value;
    end
    
    // 计算平均步长
    avg_diff = total_diff / (prbs_edge_time_config_reg - 1);
    $display("步长统计: 最小=%d, 最大=%d, 平均=%.2f", min_diff, max_diff, avg_diff);
    $display("最大步长与最小步长的差异: %d", max_diff - min_diff);
    
    #(CLK_PERIOD*30);
    
    // 测试7: 边界条件测试 - 非常短的边沿时间
    $display("测试7: 边界条件测试 - 非常短的边沿时间");
    prbs_edge_time_config_reg = 8'd3; // 只有3个周期的边沿时间
    filter_strength = 2'b00; // 不使用滤波
    
    // 上升沿
    lfsr_clk_enable = 1;
    #(CLK_PERIOD);
    lfsr_clk_enable = 0;
    prbs_bit_out = 1;
    #(CLK_PERIOD*10);
    
    // 下降沿
    lfsr_clk_enable = 1;
    #(CLK_PERIOD);
    lfsr_clk_enable = 0;
    prbs_bit_out = 0;
    #(CLK_PERIOD*10);
    
    $display("测试完成");
    $finish;
end

// 监视输出
initial begin
    $monitor("Time=%t, prbs_bit=%b, filter_strength=%d, shaped_data=0x%h, state=%d, counter=%d",
             $time, prbs_bit_out, filter_strength, shaped_prbs_data, edge_state_dbg, edge_counter_dbg);
end

endmodule
