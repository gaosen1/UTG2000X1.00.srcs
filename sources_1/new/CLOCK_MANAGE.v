`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/10 19:18:34
// Design Name: 
// Module Name: CLOCK_MANAGE
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module   CLOCK_MANAGE(
        input  FPGA_SYS_CLK,
        input  PLL_FPGA_CLK_P,
        input  PLL_FPGA_CLK_N,
        input  EXT_10M_INPUT,
        // input  EXT_10M_IN_SEL,

        output  CLK_LOW,
        output  CLK_LOW_ADC,
        output  CLK_HIGH_DAC,
        output  DDR_REF_CLK,
        output  EXT_10M_OUT,
        output  PLL_LOCKED,
        output  CLK_HIGH,
        output  reg EXT_CLK_VALID=1'b0
);

// reg  ext_10m_in_sel_r=1'b0;
// reg  [15:0]pll_rst_cnt=16'd0;
// reg  [7:0]pll_rst_cnt1=8'd0;
// reg  pll_rst=1'b0;
// reg  int_pll_rst=1'b0;
// reg  ext_pll_rst=1'b0;

CLOCK_LOW   u_CLOCK_LOW(
            .clk_out1  ( CLK_LOW        ),       // output clk_out1
            // .locked    (                ),
            .clk_in1   ( FPGA_SYS_CLK   )        // input clk_in1
);

// always@(posedge CLK_LOW)
// begin
//     ext_10m_in_sel_r  <=  EXT_CLK_VALID;
//     if(ext_10m_in_sel_r  ==  1'b0 && EXT_CLK_VALID  ==  1'b1)
//         pll_rst_cnt  <=  16'h0;
//     else
//         if(ext_10m_in_sel_r  ==  1'b1)
//             if(pll_rst_cnt < 16'hffff)
//                 pll_rst_cnt  <=  pll_rst_cnt +1'b1;
//             else;
//         else;

//     if(ext_10m_in_sel_r  ==  1'b1 && EXT_CLK_VALID  ==  1'b0)
//         pll_rst_cnt1  <=  16'h0;
//     else
//         if(ext_10m_in_sel_r  ==  1'b0)
//             if(pll_rst_cnt1  < 16'hffff)
//                 pll_rst_cnt1  <=  pll_rst_cnt1 +1'b1;
//             else;
//         else;
// end

// always@(posedge CLK_LOW)
// begin
//     if(pll_rst_cnt1  ==  16'h0)
//         int_pll_rst  <=  1'b1;
//     else
//         if(pll_rst_cnt1 == 16'hffff)
//             int_pll_rst  <=  1'b0;
//         else;

//     if(pll_rst_cnt  ==  16'h0)
//         ext_pll_rst  <=  1'b1;
//     else
//         if(pll_rst_cnt == 16'hffff)
//             ext_pll_rst  <=  1'b0;
//         else;

//     pll_rst  <= int_pll_rst || int_pll_rst; 
// end

// always@(posedge CLK_LOW)
// begin
    // ext_10m_in_sel_r  <=  EXT_CLK_VALID;

    // if(pll_rst_cnt1 < 8'd100)
    //     if(pll_rst_cnt  <  16'd50000)
    //         pll_rst_cnt  <=  pll_rst_cnt  +1'b1;
    //     else;
    // else;

    // if(ext_10m_in_sel_r  ^  EXT_CLK_VALID  ==  1'b1)
    //     pll_rst_cnt1  <=  16'd0;
    // else if(pll_rst_cnt1 < 8'd100)
    //     if(pll_rst_cnt  ==  16'd50000)
    //         pll_rst_cnt1 <= pll_rst_cnt1 +1'b1;
    //     else;
    // else;

// end

// always@(posedge CLK_LOW)
// begin
    // if(pll_rst_cnt1  ==  8'd0)
    //     pll_rst  <=  1'b1;
    // else if(pll_rst_cnt1  ==  8'd100)
    //     pll_rst  <=  1'b0;
    // else;
// end

// DDR_REF_CLK__200.00000______0.000______50.0_______87.408_____76.196
// CLK_LOW_ADC__50.00000______0.000______50.0______114.853_____76.196
// EXT_10M_OUT__10.00000______0.000______50.0______158.060_____76.196
// CLK_HIGH__312.50000______0.000______50.0_______80.069_____76.196
// CLK_HIGH_DAC__625.00000______45.00______50.0_______69.880_____76.196
CLOCK_HIGH   u_CLOCK_HIGH(           
            .DDR_REF_CLK    ( DDR_REF_CLK           ),     // output DDR_REF_CLK
            .CLK_LOW_ADC    ( CLK_LOW_ADC           ),     // output CLK_LOW_ADC
            .EXT_10M_OUT    ( EXT_10M_OUT           ),     // output EXT_10M_OUT
            .CLK_HIGH       ( CLK_HIGH              ),     // output CLK_HIGH
            .CLK_HIGH_DAC   ( CLK_HIGH_DAC          ),     // output CLK_HIGH_DAC

            // .reset          ( 1'b0                  ),     // input reset
            .locked         ( PLL_LOCKED            ),     // output locked
            .clk_in1_p      ( PLL_FPGA_CLK_P        ),     // input clk_in1_p
            .clk_in1_n      ( PLL_FPGA_CLK_N        )      // input clk_in1_n
);

reg  [15:0]refresh_clk_cnt=16'd0;
reg  ext_clk_cnt_rst=1'b0;
reg  ext_clk_cnt_rst1=1'b0;
reg  ext_clk_cnt_rst2=1'b0;
reg  [13:0]ext_clk_cnt=14'd0;

always@(posedge CLK_LOW)
begin
    refresh_clk_cnt  <=  refresh_clk_cnt +1'b1;
    
    if(refresh_clk_cnt  ==  16'hffff)
        ext_clk_cnt_rst  <=  1'b1;
    else
        ext_clk_cnt_rst  <=  1'b0;

    ext_clk_cnt_rst1  <=  ext_clk_cnt_rst;
    ext_clk_cnt_rst2  <=  ext_clk_cnt_rst1;
end

always@(posedge EXT_10M_INPUT or posedge ext_clk_cnt_rst2)
begin
    if(ext_clk_cnt_rst2  ==  1'b1)
        ext_clk_cnt  <=  14'd0;
    else if(ext_clk_cnt  <  14'h3fff)
        ext_clk_cnt  <=  ext_clk_cnt  +1'b1;
    else;
end

always@(posedge CLK_LOW)
begin
    if(ext_clk_cnt_rst  ==  1'b1)begin
        if(ext_clk_cnt[13:9]  ==  5'h19)
            EXT_CLK_VALID  <=  1'b1;
        else
            EXT_CLK_VALID  <=  1'b0;
    end
    else;
end


endmodule
