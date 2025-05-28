
// file: CLOCK_HIGH.v
// 
// (c) Copyright 2008 - 2013 Xilinx, Inc. All rights reserved.
// 
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
// 
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
// 
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
// 
//----------------------------------------------------------------------------
// User entered comments
//----------------------------------------------------------------------------
// None
//
//----------------------------------------------------------------------------
//  Output     Output      Phase    Duty Cycle   Pk-to-Pk     Phase
//   Clock     Freq (MHz)  (degrees)    (%)     Jitter (ps)  Error (ps)
//----------------------------------------------------------------------------
// DDR_REF_CLK__200.00000______0.000______50.0_______87.408_____76.196
// CLK_LOW_ADC__50.00000______0.000______50.0______114.853_____76.196
// EXT_10M_OUT__10.00000______0.000______50.0______158.060_____76.196
// CLK_HIGH__312.50000______0.000______50.0_______80.069_____76.196
// CLK_HIGH_DAC__625.00000_____45.000______50.0_______69.880_____76.196
//
//----------------------------------------------------------------------------
// Input Clock   Freq (MHz)    Input Jitter (UI)
//----------------------------------------------------------------------------
// __primary_____________625____________0.010

`timescale 1ps/1ps

module CLOCK_HIGH_clk_wiz 

 (// Clock in ports
  // Clock out ports
  output        DDR_REF_CLK,
  output        CLK_LOW_ADC,
  output        EXT_10M_OUT,
  output        CLK_HIGH,
  output        CLK_HIGH_DAC,
  // Status and control signals
  output        locked,
  input         clk_in1_p,
  input         clk_in1_n
 );
  // Input buffering
  //------------------------------------
wire clk_in1_CLOCK_HIGH;
wire clk_in2_CLOCK_HIGH;
  IBUFDS clkin1_ibufgds
   (.O  (clk_in1_CLOCK_HIGH),
    .I  (clk_in1_p),
    .IB (clk_in1_n));




  // Clocking PRIMITIVE
  //------------------------------------

  // Instantiation of the MMCM PRIMITIVE
  //    * Unused inputs are tied off
  //    * Unused outputs are labeled unused

  wire        DDR_REF_CLK_CLOCK_HIGH;
  wire        CLK_LOW_ADC_CLOCK_HIGH;
  wire        EXT_10M_OUT_CLOCK_HIGH;
  wire        CLK_HIGH_CLOCK_HIGH;
  wire        CLK_HIGH_DAC_CLOCK_HIGH;
  wire        clk_out6_CLOCK_HIGH;
  wire        clk_out7_CLOCK_HIGH;

  wire [15:0] do_unused;
  wire        drdy_unused;
  wire        psdone_unused;
  wire        locked_int;
  wire        clkfbout_CLOCK_HIGH;
  wire        clkfbout_buf_CLOCK_HIGH;
  wire        clkfboutb_unused;
    wire clkout0b_unused;
   wire clkout1b_unused;
   wire clkout2b_unused;
   wire clkout3b_unused;
  wire        clkout5_unused;
  wire        clkout6_unused;
  wire        clkfbstopped_unused;
  wire        clkinstopped_unused;

  MMCME2_ADV
  #(.BANDWIDTH            ("OPTIMIZED"),
    .CLKOUT4_CASCADE      ("FALSE"),
    .COMPENSATION         ("ZHOLD"),
    .STARTUP_WAIT         ("FALSE"),
    .DIVCLK_DIVIDE        (2),
    .CLKFBOUT_MULT_F      (4.000),
    .CLKFBOUT_PHASE       (0.000),
    .CLKFBOUT_USE_FINE_PS ("FALSE"),
    .CLKOUT0_DIVIDE_F     (6.250),
    .CLKOUT0_PHASE        (0.000),
    .CLKOUT0_DUTY_CYCLE   (0.5),
    .CLKOUT0_USE_FINE_PS  ("FALSE"),
    .CLKOUT1_DIVIDE       (25),
    .CLKOUT1_PHASE        (0.000),
    .CLKOUT1_DUTY_CYCLE   (0.5),
    .CLKOUT1_USE_FINE_PS  ("FALSE"),
    .CLKOUT2_DIVIDE       (125),
    .CLKOUT2_PHASE        (0.000),
    .CLKOUT2_DUTY_CYCLE   (0.5),
    .CLKOUT2_USE_FINE_PS  ("FALSE"),
    .CLKOUT3_DIVIDE       (4),
    .CLKOUT3_PHASE        (0.000),
    .CLKOUT3_DUTY_CYCLE   (0.5),
    .CLKOUT3_USE_FINE_PS  ("FALSE"),
    .CLKOUT4_DIVIDE       (2),
    .CLKOUT4_PHASE        (45.000),
    .CLKOUT4_DUTY_CYCLE   (0.500),
    .CLKOUT4_USE_FINE_PS  ("FALSE"),
    .CLKIN1_PERIOD        (1.600))
  mmcm_adv_inst
    // Output clocks
   (
    .CLKFBOUT            (clkfbout_CLOCK_HIGH),
    .CLKFBOUTB           (clkfboutb_unused),
    .CLKOUT0             (DDR_REF_CLK_CLOCK_HIGH),
    .CLKOUT0B            (clkout0b_unused),
    .CLKOUT1             (CLK_LOW_ADC_CLOCK_HIGH),
    .CLKOUT1B            (clkout1b_unused),
    .CLKOUT2             (EXT_10M_OUT_CLOCK_HIGH),
    .CLKOUT2B            (clkout2b_unused),
    .CLKOUT3             (CLK_HIGH_CLOCK_HIGH),
    .CLKOUT3B            (clkout3b_unused),
    .CLKOUT4             (CLK_HIGH_DAC_CLOCK_HIGH),
    .CLKOUT5             (clkout5_unused),
    .CLKOUT6             (clkout6_unused),
     // Input clock control
    .CLKFBIN             (clkfbout_buf_CLOCK_HIGH),
    .CLKIN1              (clk_in1_CLOCK_HIGH),
    .CLKIN2              (1'b0),
     // Tied to always select the primary input clock
    .CLKINSEL            (1'b1),
    // Ports for dynamic reconfiguration
    .DADDR               (7'h0),
    .DCLK                (1'b0),
    .DEN                 (1'b0),
    .DI                  (16'h0),
    .DO                  (do_unused),
    .DRDY                (drdy_unused),
    .DWE                 (1'b0),
    // Ports for dynamic phase shift
    .PSCLK               (1'b0),
    .PSEN                (1'b0),
    .PSINCDEC            (1'b0),
    .PSDONE              (psdone_unused),
    // Other control and status signals
    .LOCKED              (locked_int),
    .CLKINSTOPPED        (clkinstopped_unused),
    .CLKFBSTOPPED        (clkfbstopped_unused),
    .PWRDWN              (1'b0),
    .RST                 (1'b0));

  assign locked = locked_int;
// Clock Monitor clock assigning
//--------------------------------------
 // Output buffering
  //-----------------------------------

  BUFG clkf_buf
   (.O (clkfbout_buf_CLOCK_HIGH),
    .I (clkfbout_CLOCK_HIGH));






  BUFG clkout1_buf
   (.O   (DDR_REF_CLK),
    .I   (DDR_REF_CLK_CLOCK_HIGH));


  BUFG clkout2_buf
   (.O   (CLK_LOW_ADC),
    .I   (CLK_LOW_ADC_CLOCK_HIGH));

  BUFG clkout3_buf
   (.O   (EXT_10M_OUT),
    .I   (EXT_10M_OUT_CLOCK_HIGH));

  BUFG clkout4_buf
   (.O   (CLK_HIGH),
    .I   (CLK_HIGH_CLOCK_HIGH));

  BUFG clkout5_buf
   (.O   (CLK_HIGH_DAC),
    .I   (CLK_HIGH_DAC_CLOCK_HIGH));



endmodule
