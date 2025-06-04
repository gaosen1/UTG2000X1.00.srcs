`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 模块名称: prbs_generator_tb
// 功能描述: PRBS生成器测试模块
//////////////////////////////////////////////////////////////////////////////////

module prbs_generator_tb();

// 时钟和复位信号
reg         dac_clk;
reg         reset_n;
reg         CLK_LOW;     // 配置时钟
reg         CH_CONFIG_WE; // 配置写使能
reg [7:0]   CH_CONFIG_ADDR; // 配置地址
reg [7:0]   CH_CONFIG_DATA; // 配置数据

// 配置寄存器值（用于写操作）
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
    .CLK_LOW(CLK_LOW),
    .CH_CONFIG_WE(CH_CONFIG_WE),
    .CH_CONFIG_ADDR(CH_CONFIG_ADDR),
    .CH_CONFIG_DATA(CH_CONFIG_DATA),
    .CH_LOAD_PROTECT_STATE(),
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

// 配置时钟生成 - 100MHz的时钟周期为10ns
initial begin
    CLK_LOW = 0;
    forever #5 CLK_LOW = ~CLK_LOW; // 半周期5ns
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
    bit_count = 0;
    sequence_count = 0;
    
    // 等待复位
    #100;
    reset_n = 1;
    
    // 等待时钟稳定
    #100;
    
    // 配置寄存器
    // PN序列选择
    prbs_pn_select_reg = 0; // 选择PN3序列
    CH_CONFIG_ADDR = 8'h00; // ADDR_PN_ORDER
    CH_CONFIG_DATA = prbs_pn_select_reg;
    CH_CONFIG_WE = 1;
    #10;
    CH_CONFIG_WE = 0;
    
    // 位率配置
    prbs_bit_rate_config_reg = 32'h02000000; // 位率设置 (总时钟的1/64)
    // 写入4个字节
    CH_CONFIG_ADDR = 8'h01; // ADDR_BIT_RATE_BYTE0
    CH_CONFIG_DATA = prbs_bit_rate_config_reg[7:0];
    CH_CONFIG_WE = 1;
    #10;
    CH_CONFIG_WE = 0;
    
    CH_CONFIG_ADDR = 8'h02; // ADDR_BIT_RATE_BYTE1
    CH_CONFIG_DATA = prbs_bit_rate_config_reg[15:8];
    CH_CONFIG_WE = 1;
    #10;
    CH_CONFIG_WE = 0;
    
    CH_CONFIG_ADDR = 8'h03; // ADDR_BIT_RATE_BYTE2
    CH_CONFIG_DATA = prbs_bit_rate_config_reg[23:16];
    CH_CONFIG_WE = 1;
    #10;
    CH_CONFIG_WE = 0;
    
    CH_CONFIG_ADDR = 8'h04; // ADDR_BIT_RATE_BYTE3
    CH_CONFIG_DATA = prbs_bit_rate_config_reg[31:24];
    CH_CONFIG_WE = 1;
    #10;
    CH_CONFIG_WE = 0;
    
    // 边沿过渡时间
    prbs_edge_time_config_reg = 8'd16; // 边沿过渡时间 - 16个时钟周期
    CH_CONFIG_ADDR = 8'h05; // ADDR_EDGE_TIME
    CH_CONFIG_DATA = prbs_edge_time_config_reg;
    CH_CONFIG_WE = 1;
    #10;
    CH_CONFIG_WE = 0;
    
    // 幅度配置
    prbs_amplitude_config_reg = 16'h8000; // 满幅度
    // 写入2个字节
    CH_CONFIG_ADDR = 8'h06; // ADDR_AMPLITUDE_BYTE0
    CH_CONFIG_DATA = prbs_amplitude_config_reg[7:0];
    CH_CONFIG_WE = 1;
    #10;
    CH_CONFIG_WE = 0;
    
    CH_CONFIG_ADDR = 8'h07; // ADDR_AMPLITUDE_BYTE1
    CH_CONFIG_DATA = prbs_amplitude_config_reg[15:8];
    CH_CONFIG_WE = 1;
    #10;
    CH_CONFIG_WE = 0;
    
    // 直流偏置
    prbs_dc_offset_config_reg = 16'h0000; // 无直流偏置
    // 写入2个字节
    CH_CONFIG_ADDR = 8'h08; // ADDR_DC_OFFSET_BYTE0
    CH_CONFIG_DATA = prbs_dc_offset_config_reg[7:0];
    CH_CONFIG_WE = 1;
    #10;
    CH_CONFIG_WE = 0;
    
    CH_CONFIG_ADDR = 8'h09; // ADDR_DC_OFFSET_BYTE1
    CH_CONFIG_DATA = prbs_dc_offset_config_reg[15:8];
    CH_CONFIG_WE = 1;
    #10;
    CH_CONFIG_WE = 0;
    
    $display("测试边沿整形模块: 初始边沿过渡时间 = %d 个时钟周期", prbs_edge_time_config_reg);
    
    // 等待配置生效
    #100;
    
    // 运行一段时间观察PN3序列
    #10000;
    
    // 切换到PN7序列
    prbs_pn_select_reg = 1;
    CH_CONFIG_ADDR = 8'h00; // ADDR_PN_ORDER
    CH_CONFIG_DATA = prbs_pn_select_reg;
    CH_CONFIG_WE = 1;
    #10;
    CH_CONFIG_WE = 0;
    #10000;
    
    // 调整位率
    prbs_bit_rate_config_reg = 32'h20000000; // 位率加倍
    // 写入4个字节
    CH_CONFIG_ADDR = 8'h01; // ADDR_BIT_RATE_BYTE0
    CH_CONFIG_DATA = prbs_bit_rate_config_reg[7:0];
    CH_CONFIG_WE = 1;
    #10;
    CH_CONFIG_WE = 0;
    
    CH_CONFIG_ADDR = 8'h02; // ADDR_BIT_RATE_BYTE1
    CH_CONFIG_DATA = prbs_bit_rate_config_reg[15:8];
    CH_CONFIG_WE = 1;
    #10;
    CH_CONFIG_WE = 0;
    
    CH_CONFIG_ADDR = 8'h03; // ADDR_BIT_RATE_BYTE2
    CH_CONFIG_DATA = prbs_bit_rate_config_reg[23:16];
    CH_CONFIG_WE = 1;
    #10;
    CH_CONFIG_WE = 0;
    
    CH_CONFIG_ADDR = 8'h04; // ADDR_BIT_RATE_BYTE3
    CH_CONFIG_DATA = prbs_bit_rate_config_reg[31:24];
    CH_CONFIG_WE = 1;
    #10;
    CH_CONFIG_WE = 0;
    $display("测试场景: 调整位率为原来的2倍");
    #10000;
    
    // 切换到PN9序列
    prbs_pn_select_reg = 2;
    CH_CONFIG_ADDR = 8'h00; // ADDR_PN_ORDER
    CH_CONFIG_DATA = prbs_pn_select_reg;
    CH_CONFIG_WE = 1;
    #10;
    CH_CONFIG_WE = 0;
    $display("测试场景: 切换到PN9序列");
    #10000;
    
    // 测试不同的边沿过渡时间
    prbs_edge_time_config_reg = 8'd8; // 减小边沿过渡时间，斜率变陡
    CH_CONFIG_ADDR = 8'h05; // ADDR_EDGE_TIME
    CH_CONFIG_DATA = prbs_edge_time_config_reg;
    CH_CONFIG_WE = 1;
    #10;
    CH_CONFIG_WE = 0;
    $display("测试场景: 调整边沿过渡时间 = %d 个时钟周期 (斜率变陡)", prbs_edge_time_config_reg);
    #5000;
    
    prbs_edge_time_config_reg = 8'd32; // 增加边沿过渡时间，斜率变缓
    CH_CONFIG_ADDR = 8'h05; // ADDR_EDGE_TIME
    CH_CONFIG_DATA = prbs_edge_time_config_reg;
    CH_CONFIG_WE = 1;
    #10;
    CH_CONFIG_WE = 0;
    $display("测试场景: 调整边沿过渡时间 = %d 个时钟周期 (斜率变缓)", prbs_edge_time_config_reg);
    #5000;
    
    // 测试边缘情况
    prbs_edge_time_config_reg = 8'd1; // 几乎是矩形波
    CH_CONFIG_ADDR = 8'h05; // ADDR_EDGE_TIME
    CH_CONFIG_DATA = prbs_edge_time_config_reg;
    CH_CONFIG_WE = 1;
    #10;
    CH_CONFIG_WE = 0;
    $display("测试场景: 边缘测试 - 边沿过渡时间 = %d (接近矩形波)", prbs_edge_time_config_reg);
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
