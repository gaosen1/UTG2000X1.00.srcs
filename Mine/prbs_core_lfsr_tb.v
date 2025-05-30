`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 模块名称: prbs_core_lfsr_tb
// 功能描述: PRBS核心生成器测试模块
//////////////////////////////////////////////////////////////////////////////////

module prbs_core_lfsr_tb();

// 时钟和复位信号
reg         dac_clk;
reg         reset_n;

// 控制信号
reg         lfsr_clk_enable;
reg [4:0]   prbs_pn_select_reg; // 0:PN3, 1:PN5, 2:PN7, 3:PN9, 4:PN11, 5:PN13, 6:PN15, 7:PN17, 8:PN19, 9:PN21, 10:PN23, 11:PN25, 12:PN27, 13:PN29, 14:PN31

// 输出信号
wire        prbs_bit_out;
wire        data_valid;
wire [32:0] lfsr_state;     // LFSR寄存器状态，用于调试

// 计数器和其他测试变量
integer     i;
integer     bit_count;
integer     one_count;
integer     zero_count;

// 被测试模块实例化
prbs_core_lfsr uut (
    .dac_clk(dac_clk),
    .reset_n(reset_n),
    .lfsr_clk_enable(lfsr_clk_enable),
    .prbs_pn_select_reg(prbs_pn_select_reg),
    .prbs_bit_out(prbs_bit_out),
    .data_valid(data_valid),
    .lfsr_state(lfsr_state)
);

// 时钟生成 - 625MHz的时钟周期为1.6ns
initial begin
    dac_clk = 0;
    forever #0.8 dac_clk = ~dac_clk; // 半周期0.8ns
end

// 测试过程
initial begin
    // 注册波形文件
    $dumpfile("prbs_core_lfsr_sim.vcd");
    $dumpvars(0, prbs_core_lfsr_tb);
    $display("Starting PRBS core LFSR simulation...");
    
    // 初始化
    reset_n = 0;
    lfsr_clk_enable = 0;
    prbs_pn_select_reg = 0; // 选择PN5序列
    bit_count = 0;
    one_count = 0;
    zero_count = 0;
    
    // 复位释放
    #10;
    reset_n = 1;
    #10;
    
    // 测试PN5序列
    $display("Testing PN5 sequence...");
    prbs_pn_select_reg = 'd1;
    
    // 生成100个PRBS位
    for (i = 0; i < 100; i = i + 1) begin
        lfsr_clk_enable = 1;
        #1.6; // 一个时钟周期
        lfsr_clk_enable = 0;
        #1.6; // 等待一个时钟周期
        
        // 统计输出
        bit_count = bit_count + 1;
        if (prbs_bit_out)
            one_count = one_count + 1;
        else
            zero_count = zero_count + 1;
        
        // 打印输出
        $display("Bit %d: PRBS=%b, Data Valid=%b, LFSR State=%b (Decimal=%d)", 
                 i, prbs_bit_out, data_valid, lfsr_state[4:0], lfsr_state[4:0]);
    end
    
    // 显示统计结果
    $display("PN5 Statistics: Total bits: %d, Ones: %d, Zeros: %d", bit_count, one_count, zero_count);
    
    // 观察PN5序列的完整周期
    $display("\nObserving complete PN5 sequence cycle...");
    $display("--------------------------------------------");
    $display("Clock | LFSR State | PRBS Output | Data Valid");
    $display("--------------------------------------------");
    
    // 重置并观察PN5的完整周期（应为31个状态）
    reset_n = 0;
    #10;
    reset_n = 1;
    #10;
    
    // 生成35个时钟周期，足够观察PN5的完整周期
    for (i = 0; i < 35; i = i + 1) begin
        $display("%4d | %b (%3d) | %b | %b", 
                 i, lfsr_state[4:0], lfsr_state[4:0], prbs_bit_out, data_valid);
        
        lfsr_clk_enable = 1;
        #1.6; // 一个时钟周期
        lfsr_clk_enable = 0;
        #1.6; // 等待一个时钟周期
    end
    
    $display("--------------------------------------------");
    $display("PN5 sequence cycle observation complete");
    
    // 结束仿真
    #10;
    $finish;
end

// 监视data_valid信号
always @(posedge data_valid) begin
    if (reset_n) begin
        $display("Time: %t, Sequence completed, PN type: %d", $time, prbs_pn_select_reg);
    end
end

endmodule
