`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 模块名称: prbs_generator_tb
// 功能描述: PRBS生成器测试模块
//////////////////////////////////////////////////////////////////////////////////

module prbs_generator_tb();

// 时钟和复位信号
reg         dac_clk;
reg         reset_n;

// 配置寄存器
reg         prbs_mode_select;
reg [4:0]   prbs_pn_select_reg;
reg [31:0]  prbs_bit_rate_config_reg;
reg [7:0]   prbs_edge_time_config_reg;
reg [15:0]  prbs_amplitude_config_reg;
reg [15:0]  prbs_dc_offset_config_reg;

// 输出信号
wire        prbs_valid;
wire        prbs_bit_out_debug;
wire [15:0] prbs_dac_data;
wire [32:0] lfsr_state_debug;     // LFSR寄存器状态，用于调试

// 计数器和其他测试变量
integer     i;
integer     bit_count;
integer     sequence_count;

// 被测试模块实例化
prbs_generator_top uut (
    .dac_clk(dac_clk),
    .reset_n(reset_n),
    .prbs_mode_select(prbs_mode_select),
    .prbs_pn_select_reg(prbs_pn_select_reg),
    .prbs_bit_rate_config_reg(prbs_bit_rate_config_reg),
    .prbs_edge_time_config_reg(prbs_edge_time_config_reg),
    .prbs_amplitude_config_reg(prbs_amplitude_config_reg),
    .prbs_dc_offset_config_reg(prbs_dc_offset_config_reg),
    .prbs_valid(prbs_valid),
    .prbs_bit_out_debug(prbs_bit_out_debug),
    .prbs_dac_data(prbs_dac_data),
    .lfsr_state_debug(lfsr_state_debug)
);

// 时钟生成 - 625MHz的时钟周期为1.6ns
initial begin
    dac_clk = 0;
    forever #0.8 dac_clk = ~dac_clk; // 半周期0.8ns
end

// 注册波形文件
initial begin
    $dumpfile("prbs_sim.vcd");
    $dumpvars(0, prbs_generator_tb);
    $display("Starting simulation...");
end

// 测试过程
initial begin
    // 初始化
    reset_n = 0;
    prbs_mode_select = 1;  // 启用PRBS模式
    prbs_pn_select_reg = 0; // 选择PN5序列
    prbs_bit_rate_config_reg = 32'h10000000; // 位率设置 (约为625MHz/16)
    prbs_edge_time_config_reg = 8'd5; // 边沿过渡时间
    prbs_amplitude_config_reg = 16'h8000; // 满幅度
    prbs_dc_offset_config_reg = 16'h0000; // 无直流偏置
    bit_count = 0;
    sequence_count = 0;
    
    // 复位释放
    #100;
    reset_n = 1;
    
    // 运行一段时间观察PN3序列
    #10000;
    
    // 切换到PN7序列
    prbs_pn_select_reg = 1;
    #10000;
    
    // 调整位率
    prbs_bit_rate_config_reg = 32'h20000000; // 位率加倍
    #10000;
    
    // 切换到PN9序列
    prbs_pn_select_reg = 2;
    #10000;
    
    // 禁用PRBS模式
    prbs_mode_select = 0;
    #1000;
    
    // 重新启用PRBS模式
    prbs_mode_select = 1;
    #5000;
    
    // 结束仿真
    $finish;
end

// 监视PRBS位输出
always @(posedge dac_clk) begin
    if (reset_n && prbs_valid) begin
        $display("Time: %t, PRBS Bit: %b, DAC Data: %h", $time, prbs_bit_out_debug, prbs_dac_data);
        bit_count = bit_count + 1;
    end
end

// 监视序列完成信号
always @(posedge prbs_valid) begin
    if (reset_n) begin
        sequence_count = sequence_count + 1;
        $display("Time: %t, Sequence #%d completed", $time, sequence_count);
    end
end

endmodule
