// Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2020.2 (win64) Build 3064766 Wed Nov 18 09:12:45 MST 2020
// Date        : Wed May 28 12:27:23 2025
// Host        : DESKTOP-DRDSNT5 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               d:/IDM/Compressed/UTG2000X_FPGA_demo/UTG2000X_demo/UTG2000X1.00.srcs/sources_1/ip/dds_compiler_0/dds_compiler_0_stub.v
// Design      : dds_compiler_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a50tcsg324-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "dds_compiler_v6_0_20,Vivado 2020.1" *)
module dds_compiler_0(aclk, aclken, aresetn, s_axis_config_tvalid, 
  s_axis_config_tdata, m_axis_data_tvalid, m_axis_data_tdata)
/* synthesis syn_black_box black_box_pad_pin="aclk,aclken,aresetn,s_axis_config_tvalid,s_axis_config_tdata[47:0],m_axis_data_tvalid,m_axis_data_tdata[15:0]" */;
  input aclk;
  input aclken;
  input aresetn;
  input s_axis_config_tvalid;
  input [47:0]s_axis_config_tdata;
  output m_axis_data_tvalid;
  output [15:0]m_axis_data_tdata;
endmodule
