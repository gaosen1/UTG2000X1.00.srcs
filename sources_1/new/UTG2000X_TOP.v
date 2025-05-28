`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/10 14:28:18
// Design Name: 
// Module Name: UTG2000X_TOP
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
module   UTG2000X_TOP(
         input   FPGA_REF_CLK,              // system clk 10MHz
         
         input   PLL_FPGA_CLK_P,            // pll clk 625MHz
         input   PLL_FPGA_CLK_N,
         
         output  FPGA_SYS_WORK,             // 上电状态灯，稳定“低电平”
         input   [2:0]HW_REV,               // 硬件版本
         //-------------------ARM通信接口
         input   ARM_FPGA_nCS,
         input   ARM_FPGA_nWE,
         input   ARM_FPGA_nOE,
         input   [11:0]ARM_FPGA_ADDR,
         inout   [7:0]ARM_FPGA_DATA,
         // input  ARM_FPGA_INIT,
         // input  ARM_FPGA_CLK,
         // input  ARM_FPGA_NL,
         // input  ARM_FPGA_NWAIT,
         
         //------------------- PLL配置接口
         output  PLL_nCS,
         output  PLL_SCLK,
         output  PLL_SDIO,
         output  PLL_REFCLK_SEL,
         output  PLL_HOLD_OVER,
         
         //------------------ 旋钮键盘灯蜂鸣器接口
         input   [4:0]COLUMN,
         output  [5:0]ROW,
         output  KEY_CODE_INT,
         input   CODE_SWITCH_1,
         input   CODE_SWITCH_2,
         output  CH1_LED,
         output  CH2_LED,
         output  MODE_LED,
         output  SYNC_LED,
         output  BUZZER_ON_OFF,
         
         //----------------- 通道控制接口
         input   CH1_LOAD_PROTECT,
         output  CH1_ON_OFF,
         output  CH1_ATT1_3,
         output  CH1_ATT1_10,
         output  CH1_ATT2_10,
         output  CH1_GAIN_5,
         
         input   CH2_LOAD_PROTECT,
         output  CH2_ON_OFF,
         output  CH2_ATT1_3,
         output  CH2_ATT1_10,
         output  CH2_ATT2_10,
         output  CH2_GAIN_5,
         
         //----------------- AD9122配置接口
         output  AD9122_nCS,
         output  AD9122_SCLK,
         output  AD9122_SDIO,
         output  AD9122_nRESET,
        //  input   AD9122_SDO,
         // input   AD9122_nIRQ,
         
         //--------------- 通道数据接口
         output  CH_DAC_DCI_P,
         output  CH_DAC_DCI_N,
         output  [15:0]CH_DAC_DATA_P,
         output  [15:0]CH_DAC_DATA_N,
         
         //-------------------- 直流偏移
         output  CH_AUX_DAC_SCLK,
         output  CH_AUX_DIN,
         output  CH_AUX_nSYNC,
         
         //---------------- 同步通道接口
        //  output  SYNC_SW,
        //  output  CH_SYNC_CLK,
        //  output  [7:0]CH_SYNC_DATA,
         
         //----------------- 外部输入输出
        //  output  EXT_FSK_nOE,
        //  input   FSK_IN,
        //  input   COUNTER,
        //  output  EXT_TRIG_nOE,
        //  output  EXT_TRIG,
         output  EXT_IN_10M_nOE,
         output  EXT_OUT_10M_nOE,
         input   EXT_10M_INPUT,
         output  EXT_10M_OUTPUT
         
         //----------------- 外部调制输入
        //  output  ADC_nCS,
        //  output  ADC_SCLK,
        //  input   ADC_SDATA,
         
         //----------------- DDR3 接口
        //  inout   [15:0]ddr3_dq,
        //  inout   [1:0]ddr3_dqs_n,
        //  inout   [1:0]ddr3_dqs_p,
        // // Outputs
        //  output  [12:0]ddr3_addr,
        //  output  [2:0]ddr3_ba,
        //  output  ddr3_ras_n,
        //  output  ddr3_cas_n,
        //  output  ddr3_we_n,
        //  output  ddr3_reset_n,
        //  output  [0:0]ddr3_ck_p,
        //  output  [0:0]ddr3_ck_n,
        //  output  [0:0]ddr3_cke,
        //  output  [1:0]ddr3_dm,
        //  output  [0:0]ddr3_odt
);

wire    FPGA_SYS_CLK;
wire    SYSTEM_RST;
wire    EXT_CLK_VALID;
wire    CLK_50M;
wire    CLK_LOW;
wire    CLK_HIGH_DAC;
wire    CLK_HIGH;
wire    PLL_LOCKED;
wire   [7:0]REG_BACK_DATA;
wire   [7:0]READ_REG_ADDR;
wire   CH1_CONFIG_WE;
wire   [7:0]CH1_CONFIG_ADDR;
wire   [7:0]CH1_CONFIG_DATA;
wire   CH2_CONFIG_WE;
wire   [7:0]CH2_CONFIG_ADDR;
wire   [7:0]CH2_CONFIG_DATA;
wire   SHARE_CONFIG_WE;
wire   [7:0]SHARE_CONFIG_ADDR;
wire   [7:0]SHARE_CONFIG_DATA;
wire   [15:0]DATA1_TO_DACm;
wire   [15:0]DATA2_TO_DACm;
wire   [7:0]KEY_CODE_VALUE;
wire   [7:0]READ_BACK_DATA;
wire   AD9518_CONFIG_EN;
wire   [23:0]AD9518_CONFIG_DATA;
wire   AD9122_CONFIG_EN;
wire   [15:0]AD9122_CONFIG_DATA;
wire   DAC124_CONFIG_EN;
wire   [15:0]DAC124_CONFIG_DATA;
wire   [4:0]ARM_LED_DATA;
wire   BUZZER_EN; 
wire   BUZZER_SEL;

wire   CH1_LOAD_PROTECT_STATE;
wire   CH2_LOAD_PROTECT_STATE;
wire   [3:0]CH1_CNT_ATTEN;
wire   [3:0]CH2_CNT_ATTEN;
wire   [47:0]CH1_STAND_FREQ_INC;
wire   [47:0]CH2_STAND_FREQ_INC;

wire   CH1_SYNC;
wire   CH2_SYNC;

assign      FPGA_SYS_WORK    =  ~PLL_LOCKED;
assign      PLL_REFCLK_SEL   =  EXT_CLK_VALID;
assign      PLL_HOLD_OVER    =  1'b1;
assign      EXT_IN_10M_nOE   =  1'b0;
assign      EXT_OUT_10M_nOE  =  1'b0;
assign      {CH1_ATT1_3,CH1_ATT1_10,CH1_ATT2_10,CH1_GAIN_5}  =CH1_CNT_ATTEN;
assign      {CH2_ATT1_3,CH2_ATT1_10,CH2_ATT2_10,CH2_GAIN_5}  =CH2_CNT_ATTEN;

//--------------------------------系统复位,复位时间1ms,高电平电平复位

BUFG   clkin1_buf(
                .O                      ( FPGA_SYS_CLK          ),
                .I                      ( FPGA_REF_CLK          )
);    

SYS_RST_GEN     u_SYS_RST_GEN(
                .CLK                    ( FPGA_SYS_CLK          ),
                .SYSTEM_RST             ( SYSTEM_RST            )
);

//---------------------------------时钟管理
CLOCK_MANAGE   u_CLOCK_MANAGE(
                .FPGA_SYS_CLK           ( FPGA_SYS_CLK          ),
                .PLL_FPGA_CLK_P         ( PLL_FPGA_CLK_P        ),
                .PLL_FPGA_CLK_N         ( PLL_FPGA_CLK_N        ),
                .EXT_10M_INPUT          ( EXT_10M_INPUT         ),
                .CLK_LOW                ( CLK_LOW               ),
                .CLK_LOW_ADC            ( CLK_LOW_ADC           ),
                .CLK_HIGH_DAC           ( CLK_HIGH_DAC          ),
                .DDR_REF_CLK            ( DDR_REF_CLK           ),
                .EXT_10M_OUT            ( EXT_10M_OUTPUT        ),
                .PLL_LOCKED             ( PLL_LOCKED            ),
                .CLK_HIGH               ( CLK_HIGH              ),
                .EXT_CLK_VALID          ( EXT_CLK_VALID         )
);

//-------------------------------ARM通信
INTFACE   u_INTFACE(
                .CLK_LOW                ( CLK_LOW               ),
                .ARM_FPGA_nCS           ( ARM_FPGA_nCS          ),
                .ARM_FPGA_nWE           ( ARM_FPGA_nWE          ),
                .ARM_FPGA_nOE           ( ARM_FPGA_nOE          ),
                .ARM_FPGA_ADDR          ( ARM_FPGA_ADDR         ),
                .ARM_FPGA_DATA          ( ARM_FPGA_DATA         ),
                .READ_BACK_DATA         ( READ_BACK_DATA        ),
                .READ_REG_ADDR          ( READ_REG_ADDR         ),
                .CH1_CONFIG_WE          ( CH1_CONFIG_WE         ),
                .CH1_CONFIG_ADDR        ( CH1_CONFIG_ADDR       ),
                .CH1_CONFIG_DATA        ( CH1_CONFIG_DATA       ),
                .CH2_CONFIG_WE          ( CH2_CONFIG_WE         ),
                .CH2_CONFIG_ADDR        ( CH2_CONFIG_ADDR       ),
                .CH2_CONFIG_DATA        ( CH2_CONFIG_DATA       ),
                .SHARE_CONFIG_WE        ( SHARE_CONFIG_WE       ),
                .SHARE_CONFIG_ADDR      ( SHARE_CONFIG_ADDR     ),
                .SHARE_CONFIG_DATA      ( SHARE_CONFIG_DATA     )
);

//------------------------------------硬件控制
HW_CTRL   u_HW_CTRL(
                .CLK_LOW                ( CLK_LOW               ),
                .CLK_HIGH               ( CLK_HIGH              ),
                .CLK_LOW_ADC            ( CLK_LOW_ADC           ),
                .RST                    ( SYSTEM_RST            ),
                .KEY_COL                ( COLUMN                ),
                .KEY_ROW                ( ROW                   ),
                .CODE_SWITCH_1          ( CODE_SWITCH_1         ),
                .CODE_SWITCH_2          ( CODE_SWITCH_2         ),
                .KEY_CODE_INT           ( KEY_CODE_INT          ),
                .KEY_CODE_VALUE         ( KEY_CODE_VALUE        ),
                .AD9518_CONFIG_EN       ( AD9518_CONFIG_EN      ),
                .AD9518_CONFIG_DATA     ( AD9518_CONFIG_DATA    ),
                .AD9518_nCS             ( PLL_nCS               ),
                .AD9518_SCLK            ( PLL_SCLK              ),
                .AD9518_SDIO            ( PLL_SDIO              ),
                .DAC124_CONFIG_EN       ( DAC124_CONFIG_EN      ),
                .DAC124_CONFIG_DATA     ( DAC124_CONFIG_DATA    ),
                .CH_AUX_DAC_SCLK        ( CH_AUX_DAC_SCLK       ),
                .CH_AUX_DIN             ( CH_AUX_DIN            ),
                .CH_AUX_nSYNC           ( CH_AUX_nSYNC          ),
                .AD9122_CONFIG_EN       ( AD9122_CONFIG_EN      ),
                .AD9122_CONFIG_DATA     ( AD9122_CONFIG_DATA    ),
                .AD9122_nCS             ( AD9122_nCS            ),
                .AD9122_SCLK            ( AD9122_SCLK           ),
                .AD9122_SDIO            ( AD9122_SDIO           ),
                .AD9122_nRESET          ( AD9122_nRESET         ),
                .EXT_MOD_EN             ( EXT_MOD_EN            ),
                .ADCS7476_nCS           ( ADC_nCS               ),
                .ADCS7476_SCLK          ( ADC_SCLK              ),
                .ADCS7476_SDATA         ( ADC_SDATA             ),
                .EXT_MOD_DATA           ( EXT_MOD_DATA          ),
                .EXT_MOD_IDATA          ( EXT_MOD_IDATA         ),
                .ARM_LED_DATA           ( ARM_LED_DATA          ),
                .CH1_LED                ( CH1_LED               ),
                .CH2_LED                ( CH2_LED               ),
                .SYNC_LED               ( SYNC_LED              ),
                .MODE_LED               ( MODE_LED              ),
                .BUZZER_EN              ( BUZZER_EN             ),
                .BUZZER_SEL             ( BUZZER_SEL            ),
                .BUZZER_ON_OFF          ( BUZZER_ON_OFF         )
);

//////////////////////////////////////////////////////////////通道寄存器
CHANNEL_REG_CONFIG u0_CHANNEL_REG_CONFIG(
                .CLK_LOW               ( CLK_HIGH               ),
                .CH_LOAD_PROTECT       ( CH1_LOAD_PROTECT       ),
                .CH_CONFIG_WE          ( CH1_CONFIG_WE          ),
                .CH_CONFIG_ADDR        ( CH1_CONFIG_ADDR        ),
                .CH_CONFIG_DATA        ( CH1_CONFIG_DATA        ),
                .CH_LOAD_PROTECT_STATE ( CH1_LOAD_PROTECT_STATE ),
                .STAND_FREQ_INC        ( CH1_STAND_FREQ_INC     ),
                .CH_ON_OFF             ( CH1_ON_OFF             ),
                .CH_CNT_ATTEN          ( CH1_CNT_ATTEN          )
);

CHANNEL_REG_CONFIG u1_CHANNEL_REG_CONFIG(
                .CLK_LOW               ( CLK_LOW                ),
                .CH_LOAD_PROTECT       ( CH2_LOAD_PROTECT       ),
                .CH_CONFIG_WE          ( CH2_CONFIG_WE          ),
                .CH_CONFIG_ADDR        ( CH2_CONFIG_ADDR        ),
                .CH_CONFIG_DATA        ( CH2_CONFIG_DATA        ),
                .CH_LOAD_PROTECT_STATE ( CH2_LOAD_PROTECT_STATE ),
                .STAND_FREQ_INC        ( CH2_STAND_FREQ_INC     ),
                .CH_ON_OFF             ( CH2_ON_OFF             ),
                .CH_CNT_ATTEN          ( CH2_CNT_ATTEN          )
);

    
//-----------------------------------------------------------共用寄存器
SHARE_CONFIG_REG u_SHARE_CONFIG_REG(
                .CLK_LOW                ( CLK_LOW                ),
                .SHARE_CONFIG_WE        ( SHARE_CONFIG_WE        ),
                .SHARE_CONFIG_ADDR      ( SHARE_CONFIG_ADDR      ),
                .SHARE_CONFIG_DATA      ( SHARE_CONFIG_DATA      ),
                .CH1_SYNC               ( CH1_SYNC               ),
                .CH2_SYNC               ( CH2_SYNC               ),
                .READ_REG_ADDR          ( READ_REG_ADDR          ),
                .CH1_LOAD_PROTECT_STATE ( CH1_LOAD_PROTECT_STATE ),
                .CH2_LOAD_PROTECT_STATE ( CH2_LOAD_PROTECT_STATE ),
                .HW_REV                 ( HW_REV                 ),
                .INPUT_CLK_VALID        ( EXT_CLK_VALID          ),
                .LED_DATA               ( ARM_LED_DATA           ),
                .BUZZER_EN              ( BUZZER_EN              ),
                .BUZZER_SEL             ( BUZZER_SEL             ),
                .KEY_VALUE              ( KEY_CODE_VALUE         ),
                .READ_BACK_DATA         ( READ_BACK_DATA         ),
                .AD9518_CONFIG_EN       ( AD9518_CONFIG_EN       ),
                .AD9518_CONFIG_DATA     ( AD9518_CONFIG_DATA     ),
                .AD9122_CONFIG_EN       ( AD9122_CONFIG_EN       ),
                .AD9122_CONFIG_DATA     ( AD9122_CONFIG_DATA     ),
                .DAC124_CONFIG_EN       ( DAC124_CONFIG_EN       ),
                .DAC124_CONFIG_DATA     ( DAC124_CONFIG_DATA     )
);

/*
//-----------------------------------------------------------正弦波生成
dds_compiler_0 dds_compiler_i (
                .aclk                   ( CLK_HIGH               ),  
                .aclken                 ( CH1_ON_OFF             ),  
                .aresetn                ( CH1_SYNC               ),  
                .s_axis_config_tvalid   ( 1'b1                   ),  
                .s_axis_config_tdata    ( CH1_STAND_FREQ_INC     ),  
                .m_axis_data_tvalid     (                        ),  
                .m_axis_data_tdata      ( DATA1_TO_DACm          )   
);

dds_compiler_0 dds_compiler_q (
                .aclk                   ( CLK_HIGH               ), 
                .aclken                 ( CH1_ON_OFF             ), 
                .aresetn                ( CH2_SYNC               ), 
                .s_axis_config_tvalid   ( 1'b1                   ), 
                .s_axis_config_tdata    ( CH2_STAND_FREQ_INC     ), 
                .m_axis_data_tvalid     (                        ), 
                .m_axis_data_tdata      ( DATA2_TO_DACm          )  
);
*/

// 添加PN3生成器模块
// 声明PN3输出信号
wire pn_data_out_ch1;
wire data_valid_ch1;
wire [2:0] pn_seed_ch1;

// 实例化通道1的PN3生成器
PN3_Generator pn3_generator_ch1 (
    .clk                    ( CLK_HIGH               ),
    .rst_n                  ( 1'b1                   ),
    .enable                 ( 1'b1                   ),
    .rate_div               ( 32'd1                  ),
    .pn_data_out            ( pn_data_out_ch1        ),
    .data_valid             ( data_valid_ch1         ),
    .pn_seed                ( pn_seed_ch1            )
);

// 将PN3输出转换为DAC格式
// 注意：这里将单比特PN序列扩展为DAC所需的多位数据
// 假设 DATA1_TO_DACm和DATA2_TO_DACm是16位宽
assign DATA1_TO_DACm = pn_data_out_ch1 ? 16'h7FFF : 16'h8000; // 1->最大正值，0->最小负值
assign DATA2_TO_DACm = pn_data_out_ch1 ? 16'h7FFF : 16'h8000; // 使用相同的输出


//---------------------------------数据转换输出
DAC_ODDR_OUT   u_DAC_ODDR_OUT(
                .data_out_from_device   ( {DATA1_TO_DACm,DATA2_TO_DACm}  ), // input [63:0] data_out_from_device
                .data_out_to_pins_p     ( CH_DAC_DATA_P                  ), // output [15:0] data_out_to_pins_p
                .data_out_to_pins_n     ( CH_DAC_DATA_N                  ), // output [15:0] data_out_to_pins_n
                .clk_to_pins_p          ( CH_DAC_DCI_P                   ), // output clk_to_pins_p
                .clk_to_pins_n          ( CH_DAC_DCI_N                   ), // output clk_to_pins_n
                .clk_in                 ( CLK_HIGH                       ), // input clk_in
                .clk_reset              ( ~PLL_LOCKED                    ), // input clk_reset
                .io_reset               ( ~PLL_LOCKED                    )  // input io_reset
); 
//                 .data_out_to_pins_n     ( CH_DAC_DATA_N                  ), // output [15:0] data_out_to_pins_n
//                 .clk_to_pins_p          ( CH_DAC_DCI_P                   ), // output clk_to_pins_p
//                 .clk_to_pins_n          ( CH_DAC_DCI_N                   ), // output clk_to_pins_n
//                 .clk_in                 ( CLK_HIGH                       ), // input clk_in
//                 .clk_reset              ( ~PLL_LOCKED                    ), // input clk_reset
//                 .io_reset               ( ~PLL_LOCKED                    )  // input io_reset
// ); 


endmodule
