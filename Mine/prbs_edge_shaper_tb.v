`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 模块名称: prbs_edge_shaper_tb
// 功能描述: PRBS边沿整形模块的测试台
//////////////////////////////////////////////////////////////////////////////////

module prbs_edge_shaper_tb();

    // 测试参数
    parameter CLK_PERIOD = 1.6; // 625MHz的时钟周期 (1.6ns)
    parameter SIM_TIME = 10000; // 仿真时间 (ns)
    
    // 时钟和复位
    reg dac_clk;
    reg reset_n;
    
    // 输入信号
    reg prbs_bit_out;            // 模拟PRBS输出位
    reg lfsr_clk_enable;         // LFSR时钟使能
    reg [7:0] prbs_edge_time_config_reg; // 边沿过渡配置
    
    // 输出信号
    wire [15:0] shaped_prbs_data;    // 整形后的输出数据
    wire [1:0] edge_state_dbg;       // 状态机状态
    wire [7:0] edge_counter_dbg;     // 边沿计数器
    
    // 实例化被测模块
    prbs_edge_shaper uut (
        .dac_clk(dac_clk),
        .reset_n(reset_n),
        .prbs_bit_out(prbs_bit_out),
        .lfsr_clk_enable(lfsr_clk_enable),
        .prbs_edge_time_config_reg(prbs_edge_time_config_reg),
        .shaped_prbs_data(shaped_prbs_data),
        .edge_state_dbg(edge_state_dbg),
        .edge_counter_dbg(edge_counter_dbg)
    );
    
    // 时钟生成
    initial begin
        dac_clk = 0;
        forever #(CLK_PERIOD/2) dac_clk = ~dac_clk;
    end
    
    // 低速PRBS时钟使能生成 (以10MHz速率模拟PRBS)
    reg [5:0] prbs_clk_div;
    always @(posedge dac_clk or negedge reset_n) begin
        if (!reset_n) begin
            prbs_clk_div <= 0;
            lfsr_clk_enable <= 0;
        end else begin
            prbs_clk_div <= prbs_clk_div + 1;
            lfsr_clk_enable <= (prbs_clk_div == 0) ? 1'b1 : 1'b0; // 625MHz/64 ≈ 10MHz
        end
    end
    
    // 测试序列
    initial begin
        // 初始化信号
        reset_n = 0;
        prbs_bit_out = 0;
        prbs_edge_time_config_reg = 8'd16; // 16个时钟周期的边沿过渡时间
        
        // 复位释放
        #100;
        reset_n = 1;
        #100;
        
        // 测试用例1: 简单的方波模式
        repeat (5) begin
            // 产生高电平
            @(posedge lfsr_clk_enable);
            prbs_bit_out = 1'b1;
            
            // 保持高电平一段时间
            repeat (5) @(posedge lfsr_clk_enable);
            
            // 产生低电平
            @(posedge lfsr_clk_enable);
            prbs_bit_out = 1'b0;
            
            // 保持低电平一段时间
            repeat (5) @(posedge lfsr_clk_enable);
        end
        
        // 测试用例2: 快速切换
        prbs_edge_time_config_reg = 8'd8; // 更短的边沿过渡时间
        repeat (10) begin
            @(posedge lfsr_clk_enable);
            prbs_bit_out = ~prbs_bit_out; // 每个PRBS时钟周期翻转
        end
        
        // 测试用例3: 更长的边沿过渡时间
        prbs_edge_time_config_reg = 8'd32;
        repeat (3) begin
            @(posedge lfsr_clk_enable);
            prbs_bit_out = 1'b1;
            repeat (10) @(posedge lfsr_clk_enable);
            prbs_bit_out = 1'b0;
            repeat (10) @(posedge lfsr_clk_enable);
        end
        
        // 测试用例4: 伪随机序列
        prbs_edge_time_config_reg = 8'd16;
        repeat (30) begin
            @(posedge lfsr_clk_enable);
            prbs_bit_out = $random; // 随机生成0或1
        end
        
        // 结束仿真
        #1000;
        $display("仿真完成!");
        $finish;
    end
    
    // 波形生成
    initial begin
        $dumpfile("edge_shaper_sim.vcd");
        $dumpvars(0, prbs_edge_shaper_tb);
    end
    
    // 状态机状态的ASCII文本表示
    reg [8*20:1] state_name;
    always @(*) begin
        case (edge_state_dbg)
            2'b00: state_name = "STEADY_LOW";
            2'b01: state_name = "RISING_EDGE";
            2'b10: state_name = "STEADY_HIGH";
            2'b11: state_name = "FALLING_EDGE";
            default: state_name = "UNKNOWN";
        endcase
    end
    
    // 监视输出
    initial begin
        $monitor("时间=%t, PRBS位=%b, 整形输出=%d, 状态=%s, 计数器=%d", 
                 $time, prbs_bit_out, shaped_prbs_data, state_name, edge_counter_dbg);
    end

endmodule
