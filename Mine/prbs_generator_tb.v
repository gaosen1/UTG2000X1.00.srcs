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
    prbs_pn_select_reg = 0; // 选择PN3序列
    prbs_bit_rate_config_reg = 32'h40000000; // 位率设置 (总时钟的1/4)
    prbs_edge_time_config_reg = 8'd2; // 边沿过渡时间 - 2个时钟周期，更陡的斜率
    prbs_amplitude_config_reg = 16'h8000; // 满幅度
    prbs_dc_offset_config_reg = 16'h0000; // 无直流偏置
    bit_count = 0;
    sequence_count = 0;
    
    $display("测试边沿整形模块: 初始边沿过渡时间 = %d 个时钟周期", prbs_edge_time_config_reg);
    
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
    $display("测试场景: 调整位率为原来的2倍");
    #10000;
    
    // 切换到PN9序列
    prbs_pn_select_reg = 2;
    $display("测试场景: 切换到PN9序列");
    #10000;
    
    // 测试不同的边沿过渡时间
    prbs_edge_time_config_reg = 8'd8; // 减小边沿过渡时间，斜率变陡
    $display("测试场景: 调整边沿过渡时间 = %d 个时钟周期 (斜率变陡)", prbs_edge_time_config_reg);
    #5000;
    
    prbs_edge_time_config_reg = 8'd32; // 增加边沿过渡时间，斜率变缓
    $display("测试场景: 调整边沿过渡时间 = %d 个时钟周期 (斜率变缓)", prbs_edge_time_config_reg);
    #5000;
    
    // 测试边缘情况
    prbs_edge_time_config_reg = 8'd1; // 几乎是矩形波
    $display("测试场景: 边缘测试 - 边沿过渡时间 = %d (接近矩形波)", prbs_edge_time_config_reg);
    #5000;
    
    // 禁用PRBS模式
    prbs_mode_select = 0;
    $display("测试场景: 禁用PRBS模式");
    #1000;
    
    // 重新启用PRBS模式
    prbs_mode_select = 1;
    $display("测试场景: 重新启用PRBS模式");
    #5000;
    
    // 结束仿真
    $display("仿真完成");
    $finish;
end

// 监视PRBS位输出和边沿整形状态
wire [1:0] edge_state = uut.edge_state_dbg;  // 获取边沿状态调试信号
wire [7:0] edge_counter = uut.edge_counter_dbg;  // 获取边沿计数器调试信号

// 定义状态机状态的ASCII文本表示
reg [31:0] state_name;
always @(*) begin
    case(edge_state)
        2'b00: state_name = "LOW ";  // S_STEADY_LOW
        2'b01: state_name = "RISE";  // S_RISING_EDGE
        2'b10: state_name = "HIGH";  // S_STEADY_HIGH
        2'b11: state_name = "FALL";  // S_FALLING_EDGE
        default: state_name = "????";
    endcase
end

// 保存上一个状态和计数器值
reg [1:0] prev_edge_state;
reg [7:0] prev_edge_counter;

always @(posedge dac_clk) begin
    if (!reset_n) begin
        prev_edge_state <= 2'b00;
        prev_edge_counter <= 8'd0;
    end else if (prbs_valid) begin
        // 当状态变化或者计数器变化时输出详细信息
        if (edge_state != prev_edge_state || edge_counter != prev_edge_counter) begin
            $display("Time: %t, PRBS Bit: %b, DAC Data: %h, State: %s, Counter: %d", 
                     $time, prbs_bit_out_debug, prbs_dac_data, state_name, edge_counter);
        end
        bit_count = bit_count + 1;
        prev_edge_state <= edge_state;
        prev_edge_counter <= edge_counter;
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
