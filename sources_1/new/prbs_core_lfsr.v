`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 模块名称: prbs_core_lfsr
// 功能描述: 通用PRBS序列生成器，支持多种PN序列
//////////////////////////////////////////////////////////////////////////////////

module prbs_core_lfsr (
    input wire          dac_clk,            // 系统时钟，例如 625MHz
    input wire          reset_n,            // 同步低有效复位
    input wire          lfsr_clk_enable,    // LFSR移位使能脉冲 (来自 prbs_bitrate_clk_gen)
    input wire [4:0]    prbs_pn_select_reg, // PN阶数选择 (0:PN3, 1:PN5, 2:PN7, 3:PN9, 4:PN11, 5:PN15, 6:PN17, 7:PN23, 8:PN31, 9:PN13, 10:PN19, 11:PN21, 12:PN25, 13:PN27, 14:PN29)
    
    output reg          prbs_bit_out,       // 1位原始PRBS序列输出
    output reg          data_valid,         // 数据有效标志（每个完整序列周期置高一个时钟周期）
    output [MAX_PN_ORDER-1:0] lfsr_state     // 输出当前LFSR寄存器状态，用于调试
);

// 最大PN阶数，决定LFSR寄存器的最大位宽
localparam MAX_PN_ORDER = 33;

// 内部寄存器
reg [MAX_PN_ORDER-1:0] lfsr_reg;      // 存储LFSR状态
reg [31:0] bit_counter;               // 位计数器，用于生成data_valid信号
reg [31:0] sequence_length;           // 当前选择的序列长度

// 将当前LFSR状态输出到lfsr_state端口
assign lfsr_state = lfsr_reg;

// 抽头位置定义 (根据标准PN多项式)
reg [MAX_PN_ORDER-1:0] feedback_mask; // 用于选择抽头
wire                   feedback_bit;  // 反馈位

// 计算反馈位 - 对选中的抽头位进行异或
// 注意：我们使用标准的左移反馈移位寄存器(LFSR)实现
// 反馈位计算取决于多项式的具体形式
assign feedback_bit = ^(lfsr_reg & feedback_mask);

// 初始化
initial begin
    lfsr_reg = {{(MAX_PN_ORDER-1){1'b0}}, 1'b1}; // 默认种子，不能为全0
    prbs_bit_out = 1'b0;
    data_valid = 1'b0;
    bit_counter = 32'd0;
    sequence_length = 32'd0;
end

// 主要LFSR逻辑
always @(posedge dac_clk or negedge reset_n) begin
    if (!reset_n) begin
        lfsr_reg <= {{(MAX_PN_ORDER-1){1'b0}}, 1'b1}; // 复位为默认种子
        prbs_bit_out <= 1'b0;
        data_valid <= 1'b0;
        bit_counter <= 32'd0;
    end else if (lfsr_clk_enable) begin
        // 移位并插入反馈位
        case (prbs_pn_select_reg)
            5'd0: begin // PN3: x^3 + x + 1
                lfsr_reg <= {{(MAX_PN_ORDER-3){1'b0}}, feedback_bit, lfsr_reg[2:1]}; // 左移: 新的反馈位到D0，原D0到D1，原D1到D2
            end
            5'd1: begin // PN5: x^5 + x^2 + 1
                lfsr_reg <= {{(MAX_PN_ORDER-5){1'b0}}, feedback_bit, lfsr_reg[4:1]}; // 左移
            end
            5'd2: begin // PN7: x^7 + x^3 + 1
                lfsr_reg <= {{(MAX_PN_ORDER-7){1'b0}}, feedback_bit, lfsr_reg[6:1]}; // 左移
            end
            5'd3: begin // PN9: x^9 + x^4 + 1
                lfsr_reg <= {{(MAX_PN_ORDER-9){1'b0}}, feedback_bit, lfsr_reg[8:1]}; // 左移
            end
            5'd4: begin // PN11: x^11 + x^2 + 1
                lfsr_reg <= {{(MAX_PN_ORDER-11){1'b0}}, feedback_bit, lfsr_reg[10:1]}; // 左移
            end
            5'd5: begin // PN13: x^13 + x^4 + x^3 + x + 1
                lfsr_reg <= {{(MAX_PN_ORDER-13){1'b0}}, feedback_bit, lfsr_reg[12:1]}; // 左移
            end
            5'd6: begin // PN15: x^15 + x + 1
                lfsr_reg <= {{(MAX_PN_ORDER-15){1'b0}}, feedback_bit, lfsr_reg[14:1]}; // 左移
            end
            5'd7: begin // PN17: x^17 + x^3 + 1
                lfsr_reg <= {{(MAX_PN_ORDER-17){1'b0}}, feedback_bit, lfsr_reg[16:1]}; // 左移
            end
            5'd8: begin // PN19: x^19 + x^5 + x^2 + x + 1
                lfsr_reg <= {{(MAX_PN_ORDER-19){1'b0}}, feedback_bit, lfsr_reg[18:1]}; // 左移
            end
            5'd9: begin // PN21: x^21 + x^2 + 1
                lfsr_reg <= {{(MAX_PN_ORDER-21){1'b0}}, feedback_bit, lfsr_reg[20:1]}; // 左移
            end
            5'd10: begin // PN23: x^23 + x^5 + 1
                lfsr_reg <= {{(MAX_PN_ORDER-23){1'b0}}, feedback_bit, lfsr_reg[22:1]}; // 左移
            end
            5'd11: begin // PN25: x^25 + x^3 + 1
                lfsr_reg <= {{(MAX_PN_ORDER-25){1'b0}}, feedback_bit, lfsr_reg[24:1]}; // 左移
            end
            5'd12: begin // PN27: x^27 + x^5 + x^2 + x + 1
                lfsr_reg <= {{(MAX_PN_ORDER-27){1'b0}}, feedback_bit, lfsr_reg[26:1]}; // 左移
            end
            5'd13: begin // PN29: x^29 + x^2 + 1
                lfsr_reg <= {{(MAX_PN_ORDER-29){1'b0}}, feedback_bit, lfsr_reg[28:1]}; // 左移
            end
            5'd14: begin // PN31: x^31 + x^3 + 1
                lfsr_reg <= {{(MAX_PN_ORDER-31){1'b0}}, feedback_bit, lfsr_reg[30:1]}; // 左移
            end
            default: begin // 默认使用PN3
                lfsr_reg <= {{(MAX_PN_ORDER-3){1'b0}}, feedback_bit, lfsr_reg[2:1]}; // 左移
            end
        endcase
        
        // 输出LFSR的最高位作为PRBS输出
        prbs_bit_out <= lfsr_reg[0];
        
        // 位计数器逻辑，用于生成data_valid信号
        if (bit_counter >= sequence_length - 1) begin
            bit_counter <= 16'd0;
            data_valid <= 1'b1;
        end else begin
            bit_counter <= bit_counter + 16'd1;
            data_valid <= 1'b0;
        end
    end else begin
        data_valid <= 1'b0; // 当lfsr_clk_enable为低时，data_valid也为低
    end
end

// 根据 prbs_pn_select_reg 选择反馈多项式（抽头掩码）和序列长度
always @(*) begin
    case (prbs_pn_select_reg)
        5'd0: begin // PN3: x^3 + x + 1 (本原多项式)
            feedback_mask = {{(MAX_PN_ORDER-3){1'b0}}, 3'b101}; // 位2和位0反馈
            sequence_length = 32'd7; // 2^3 - 1 = 7
        end
        5'd1: begin // PN5: x^5 + x^2 + 1 (本原多项式)
            feedback_mask = {{(MAX_PN_ORDER-5){1'b0}}, 5'b01001}; // 位4和位1反馈
            sequence_length = 32'd31; // 2^5 - 1 = 31
        end
        5'd2: begin // PN7: x^7 + x^3 + 1 (本原多项式)
            feedback_mask = {{(MAX_PN_ORDER-7){1'b0}}, 7'b0010001}; // 位3和位0反馈
            sequence_length = 32'd127; // 2^7 - 1 = 127
        end
        5'd3: begin // PN9: x^9 + x^4 + 1 (本原多项式)
            feedback_mask = {{(MAX_PN_ORDER-9){1'b0}}, 9'b000100001}; // 位4和位0反馈
            sequence_length = 32'd511; // 2^9 - 1 = 511
        end
        5'd4: begin // PN11: x^11 + x^2 + 1 (本原多项式)
            feedback_mask = {{(MAX_PN_ORDER-11){1'b0}}, 11'b01000000001}; // 位2和位0反馈
            sequence_length = 32'd2047; // 2^11 - 1 = 2047
        end
        5'd5: begin // PN13: x^13 + x^4 + x^3 + x + 1 (本原多项式)
            feedback_mask = {{(MAX_PN_ORDER-13){1'b0}}, 13'b1011000000001}; // 位4、位3、位1和位0反馈
            sequence_length = 32'd8191; // 2^13 - 1 = 8191
        end
        5'd6: begin // PN15: x^15 + x + 1 (本原多项式)
            feedback_mask = {{(MAX_PN_ORDER-15){1'b0}}, 15'b100000000000001}; // 位1和位0反馈
            sequence_length = 32'd32767; // 2^15 - 1 = 32767
        end
        5'd7: begin // PN17: x^17 + x^3 + 1 (本原多项式)
            feedback_mask = {{(MAX_PN_ORDER-17){1'b0}}, 17'b00100000000000001}; // 位3和位0反馈
            sequence_length = 32'd131071; // 2^17 - 1 = 131071
        end
        5'd8: begin // PN19: x^19 + x^5 + x^2 + x + 1 (本原多项式)
            feedback_mask = {{(MAX_PN_ORDER-19){1'b0}}, 19'b1100100000000000001}; // 位5、位2、位1和位0反馈
            sequence_length = 32'd524287; // 2^19 - 1 = 524287
        end
        5'd9: begin // PN21: x^21 + x^2 + 1 (本原多项式)
            feedback_mask = {{(MAX_PN_ORDER-21){1'b0}}, 21'b010000000000000000001}; // 位2和位0反馈
            sequence_length = 32'd2097151; // 2^21 - 1 = 2097151
        end
        5'd10: begin // PN23: x^23 + x^5 + 1 (本原多项式)
            feedback_mask = {{(MAX_PN_ORDER-23){1'b0}}, 23'b00001000000000000000001}; // 位5和位0反馈
            sequence_length = 32'd8388607; // 2^23 - 1 = 8388607
        end
        5'd11: begin // PN25: x^25 + x^3 + 1 (本原多项式)
            feedback_mask = {{(MAX_PN_ORDER-25){1'b0}}, 25'b0010000000000000000000001}; // 位3和位0反馈
            sequence_length = 32'd33554431; // 2^25 - 1 = 33554431
        end
        5'd12: begin // PN27: x^27 + x^5 + x^2 + x + 1 (本原多项式)
            feedback_mask = {{(MAX_PN_ORDER-27){1'b0}}, 27'b110010000000000000000000001}; // 位5、位2、位1和位0反馈
            sequence_length = 32'd134217727; // 2^27 - 1 = 134217727
        end
        5'd13: begin // PN29: x^29 + x^2 + 1 (本原多项式)
            feedback_mask = {{(MAX_PN_ORDER-29){1'b0}}, 29'b01000000000000000000000000001}; // 位2和位0反馈
            sequence_length = 32'd536870911; // 2^29 - 1 = 536870911
        end
        5'd14: begin // PN31: x^31 + x^3 + 1 (本原多项式)
            feedback_mask = {{(MAX_PN_ORDER-31){1'b0}}, 31'b0010000000000000000000000000001}; // 位3和位0反馈
            sequence_length = 32'd2147483647; // 2^31 - 1 = 2147483647
        end
        default: begin // 默认使用PN3
            feedback_mask = {{(MAX_PN_ORDER-3){1'b0}}, 3'b011}; // 位1和位0反馈
            sequence_length = 32'd7; // 2^3 - 1 = 7
        end
    endcase
end

endmodule
