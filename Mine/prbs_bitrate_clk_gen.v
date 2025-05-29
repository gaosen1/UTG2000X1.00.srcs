module prbs_bitrate_clk_gen (
    input wire          dac_clk,            // 主DAC时钟，例如 625MHz
    input wire          reset_n,            // 同步低有效复位
    input wire [31:0]   prbs_bit_rate_config_reg, // 32位NCO相位增量 (来自 CHANNEL_REG_CONFIG)

    output wire         lfsr_clk_enable     // 在每个PRBS比特周期开始时产生一个dac_clk周期的脉冲
);

// NCO 累加器位宽
localparam NCO_ACCUMULATOR_BITS = 32;

reg [NCO_ACCUMULATOR_BITS-1:0] phase_accumulator;
reg                             lfsr_clk_enable_reg;

// 用于检测相位溢出的信号
wire current_msb;
wire next_msb;
wire [NCO_ACCUMULATOR_BITS-1:0] next_phase;

// 使用assign语句进行赋值
assign next_phase = phase_accumulator + prbs_bit_rate_config_reg;
assign current_msb = phase_accumulator[NCO_ACCUMULATOR_BITS-1];
assign next_msb = next_phase[NCO_ACCUMULATOR_BITS-1];

// NCO 累加器
always @(posedge dac_clk or negedge reset_n) begin
    if (!reset_n) begin
        phase_accumulator   <= {NCO_ACCUMULATOR_BITS{1'b0}};
        lfsr_clk_enable_reg <= 1'b0;
    end else begin
        // 累加相位增量
        phase_accumulator <= phase_accumulator + prbs_bit_rate_config_reg;

        // 检测溢出（MSB跳变）产生使能脉冲
        // 当从0变成1时产生脉冲
        if (current_msb == 1'b0 && next_msb == 1'b1) begin
            lfsr_clk_enable_reg <= 1'b1; // 产生一个时钟周期的脉冲
        end else begin
            lfsr_clk_enable_reg <= 1'b0;
        end
    end
end

assign lfsr_clk_enable = lfsr_clk_enable_reg;

endmodule
