`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 模块名称: PN3_Generator
// 功能描述: 生成PN3序列数据
//////////////////////////////////////////////////////////////////////////////////

module PN3_Generator(
    input wire clk,                  // 时钟输入
    input wire rst_n,                // 低电平有效复位
    input wire enable,               // 使能信号
    input wire [31:0] rate_div,     // 频率分频系数
    output reg pn_data_out,          // PN3数据输出
    output reg data_valid,           // 数据有效标志
    output reg [2:0] pn_seed         // 当前PN序列种子
);

    // 参数定义
    parameter PN_LENGTH = 3;         // PN序列长度
    
    // 内部寄存器
    reg [2:0] shift_reg;             // 移位寄存器
    reg [1:0] bit_counter;           // 位计数器
    reg [31:0] rate_counter;         // 频率计数器
    
    // 初始化
    initial begin
        shift_reg = 3'b001;     // 初始种子设置为001
        bit_counter = 0;
        rate_counter = 0;
        data_valid = 0;
        pn_seed = 3'b001;
        pn_data_out = 0;
    end
    
    // PN3序列生成器
    function [2:0] next_pn;
        input [2:0] current;
        begin
            // PN3序列的反馈多项式: x^3 + x^2 + 1
            next_pn = {current[1:0], current[2] ^ current[0]};
        end
    endfunction
    
    // 初始化和复位逻辑
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // 复位所有寄存器
            shift_reg <= 3'b001;     // 初始种子设置为001
            bit_counter <= 0;
            rate_counter <= 0;
            data_valid <= 0;
            pn_seed <= 3'b001;
            pn_data_out <= 0;
        end
        else if (enable) begin
            // 频率控制
            if (rate_counter >= rate_div) begin
                rate_counter <= 0;
                
                // 生成新的PN位
                pn_data_out <= shift_reg[2];  // 输出当前最高位
                shift_reg <= next_pn(shift_reg);
                pn_seed <= shift_reg;
                
                // 更新状态
                bit_counter <= bit_counter + 1;
                if (bit_counter == PN_LENGTH-1) begin
                    bit_counter <= 0;
                    data_valid <= 1;
                end
                else begin
                    data_valid <= 0;
                end
            end
            else begin
                rate_counter <= rate_counter + 1;
            end
        end
        else begin
            // 禁用时复位
            shift_reg <= 3'b001;
            bit_counter <= 0;
            rate_counter <= 0;
            data_valid <= 0;
            pn_data_out <= 0;
        end
    end

endmodule
