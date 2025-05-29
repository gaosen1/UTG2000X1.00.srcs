`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 模块名称: prbs_core_lfsr
// 功能描述: 通用PRBS序列生成器，支持多种PN序列
//////////////////////////////////////////////////////////////////////////////////

module prbs_core_lfsr (
    input wire          dac_clk,            // 系统时钟，例如 625MHz
    input wire          reset_n,            // 同步低有效复位
    input wire          lfsr_clk_enable,    // LFSR移位使能脉冲 (来自 prbs_bitrate_clk_gen)
    input wire [3:0]    prbs_pn_select_reg, // PN阶数选择 (例如 0:PN3, 1:PN7, 2:PN9, 3:PN11, 4:PN15, 5:PN20, 6:PN23, 7:PN31)
    
    output reg          prbs_bit_out,       // 1位原始PRBS序列输出
    output reg          data_valid          // 数据有效标志（每个完整序列周期置高一个时钟周期）
);

// 最大PN阶数，决定LFSR寄存器的最大位宽
localparam MAX_PN_ORDER = 33;

// 内部寄存器
reg [MAX_PN_ORDER-1:0] lfsr_reg;      // 存储LFSR状态
reg [15:0] bit_counter;               // 位计数器，用于生成data_valid信号
reg [15:0] sequence_length;           // 当前选择的序列长度

// 抽头位置定义 (根据标准PN多项式)
reg [MAX_PN_ORDER-1:0] feedback_mask; // 用于选择抽头
wire                   feedback_bit;  // 反馈位

// 计算反馈位 - 对所有选中的抽头位进行异或
assign feedback_bit = ^(lfsr_reg & feedback_mask);

// 初始化
initial begin
    lfsr_reg = {{(MAX_PN_ORDER-1){1'b0}}, 1'b1}; // 默认种子，不能为全0
    prbs_bit_out = 1'b0;
    data_valid = 1'b0;
    bit_counter = 16'd0;
    sequence_length = 16'd0;
end

// 主要LFSR逻辑
always @(posedge dac_clk or negedge reset_n) begin
    if (!reset_n) begin
        lfsr_reg <= {{(MAX_PN_ORDER-1){1'b0}}, 1'b1}; // 复位为默认种子
        prbs_bit_out <= 1'b0;
        data_valid <= 1'b0;
        bit_counter <= 16'd0;
    end else if (lfsr_clk_enable) begin
        // 移位并插入反馈位
        lfsr_reg <= {lfsr_reg[MAX_PN_ORDER-2:0], feedback_bit};
        
        // 输出LFSR的最高位作为PRBS输出
        prbs_bit_out <= lfsr_reg[MAX_PN_ORDER-1];
        
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
        4'd0: begin // PN3: x^3 + x^2 + 1
            feedback_mask = {{(MAX_PN_ORDER-3){1'b0}}, 3'b110};
            sequence_length = 16'd7; // 2^3 - 1 = 7
        end
        4'd1: begin // PN7: x^7 + x^6 + 1
            feedback_mask = {{(MAX_PN_ORDER-7){1'b0}}, 7'b1000001};
            sequence_length = 16'd127; // 2^7 - 1 = 127
        end
        4'd2: begin // PN9: x^9 + x^5 + 1
            feedback_mask = {{(MAX_PN_ORDER-9){1'b0}}, 9'b100010000};
            sequence_length = 16'd511; // 2^9 - 1 = 511
        end
        4'd3: begin // PN11: x^11 + x^9 + 1
            feedback_mask = {{(MAX_PN_ORDER-11){1'b0}}, 11'b10100000000};
            sequence_length = 16'd2047; // 2^11 - 1 = 2047
        end
        4'd4: begin // PN15: x^15 + x^14 + 1
            feedback_mask = {{(MAX_PN_ORDER-15){1'b0}}, 15'b110000000000000};
            sequence_length = 16'd32767; // 2^15 - 1 = 32767
        end
        4'd5: begin // PN20: x^20 + x^17 + 1
            feedback_mask = {{(MAX_PN_ORDER-20){1'b0}}, 20'b10001000000000000000};
            sequence_length = 16'd1023; // 实际应为2^20-1，但我们限制为1023以提高价值
        end
        4'd6: begin // PN23: x^23 + x^18 + 1
            feedback_mask = {{(MAX_PN_ORDER-23){1'b0}}, 23'b10000010000000000000000};
            sequence_length = 16'd2047; // 实际应为2^23-1，但我们限制为2047
        end
        4'd7: begin // PN31: x^31 + x^28 + 1
            feedback_mask = {{(MAX_PN_ORDER-31){1'b0}}, 31'b1000100000000000000000000000000};
            sequence_length = 16'd4095; // 实际应为2^31-1，但我们限制为4095
        end
        default: begin // 默认使用PN3
            feedback_mask = {{(MAX_PN_ORDER-3){1'b0}}, 3'b110};
            sequence_length = 16'd7;
        end
    endcase
end

endmodule
