`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/11 15:41:24
// Design Name: 
// Module Name: HW_CTRL
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


module   HW_CTRL(
            input   CLK_LOW,
            input   CLK_HIGH,
            input   CLK_LOW_ADC,
            input   RST,
            /////////////////////////////键盘旋钮
            input   [4:0]KEY_COL,
            output  [5:0]KEY_ROW,
            input   CODE_SWITCH_1,
            input   CODE_SWITCH_2,
            output  KEY_CODE_INT,
            output  [7:0]KEY_CODE_VALUE,
            ////////////////////////////////PLL控制
            input   AD9518_CONFIG_EN,
            input   [23:0]AD9518_CONFIG_DATA,
            output  AD9518_nCS,
            output  AD9518_SCLK,
            output  AD9518_SDIO,
            /////////////////////////////dac124直流控制
            input   DAC124_CONFIG_EN,
            input   [15:0]DAC124_CONFIG_DATA,
            output  CH_AUX_DAC_SCLK,
            output  CH_AUX_DIN,
            output  CH_AUX_nSYNC,
            ////////////////////////////AD9122配置
            input   AD9122_CONFIG_EN,
            input   [15:0]AD9122_CONFIG_DATA,
            output  AD9122_nCS,
            output  AD9122_SCLK,
            output  AD9122_SDIO,
            output  AD9122_nRESET,
            // input   AD9122_SDO,
            // output  [7:0]READ_AD9122,
            ////////////////////////////ADCS7476外部调制采样
            input   EXT_MOD_EN,
            input   ADCS7476_SDATA,
            output  ADCS7476_nCS,
            output  ADCS7476_SCLK,
            output  [15:0]EXT_MOD_DATA,
            output  [15:0]EXT_MOD_IDATA,
            ///////////////////////////LED灯控制
            input   [4:0]ARM_LED_DATA,
            output  CH1_LED,
            output  CH2_LED,
            output  SYNC_LED,
            output  MODE_LED,
            /////////////////////////蜂鸣器控制
            input   BUZZER_EN,
            input   BUZZER_SEL,
            output  BUZZER_ON_OFF
            
);

KEY_BOARD   U_KEY_BOARD(
           .CLK_LOW                 ( CLK_LOW             ),
           .RST                     ( RST                 ),
           .KEY_COL                 ( KEY_COL             ),
           .KEY_ROW                 ( KEY_ROW             ),
           .CODE_SWITCH_1           ( CODE_SWITCH_1       ),
           .CODE_SWITCH_2           ( CODE_SWITCH_2       ),
           .KEY_CODE_INT            ( KEY_CODE_INT        ),
           .KEY_CODE_VALUE          ( KEY_CODE_VALUE      )
);

AD9518_CTRL_TOP   u_AD9518_CTRL_TOP(
           .CLK                     ( CLK_LOW             ),
           .RST                     ( RST                 ),
           .AD9518_CONFIG_EN        ( AD9518_CONFIG_EN    ),
           .AD9518_CONFIG_DATA      ( AD9518_CONFIG_DATA  ),
           .AD9518_nCS              ( AD9518_nCS          ),
           .AD9518_SCLK             ( AD9518_SCLK         ),
           .AD9518_SDIO             ( AD9518_SDIO         )
);

DAC124S_CTRL   u_DAC124S_CTRL(
           .CLK                     ( CLK_LOW             ),
           .DAC124_CONFIG_EN        ( DAC124_CONFIG_EN    ),
           .DAC124_CONFIG_DATA      ( DAC124_CONFIG_DATA  ),
           .CH_AUX_DAC_SCLK         ( CH_AUX_DAC_SCLK     ),
           .CH_AUX_DIN              ( CH_AUX_DIN          ),
           .CH_AUX_nSYNC            ( CH_AUX_nSYNC        )
);

AD9122_CTRL_TOP   u_AD9122_CTRL_TOP(
           .CLK                     ( CLK_LOW             ),
           .RST                     ( RST                 ),
           .AD9122_CONFIG_EN        ( AD9122_CONFIG_EN    ),
           .AD9122_CONFIG_DATA      ( AD9122_CONFIG_DATA  ),
           .AD9122_nCS              ( AD9122_nCS          ),
           .AD9122_SCLK             ( AD9122_SCLK         ),
           .AD9122_SDIO             ( AD9122_SDIO         ),
         //   .AD9122_SDO              ( AD9122_SDO          ),
         //   .READ_AD9122             ( READ_AD9122         ),
           .AD9122_nRESET           ( AD9122_nRESET       )
);

ADCS7476_HCTRL   u_ADCS7476_HCTRL(
           .CLK_HIGH                ( CLK_HIGH            ),
           .RST                     ( RST                 ),
           .EXT_MOD_EN              ( EXT_MOD_EN          ),
           .ADCS7476_nCS            ( ADCS7476_nCS        ),
           .ADCS7476_SCLK           ( ADCS7476_SCLK       ),
           .ADCS7476_SDATA          ( ADCS7476_SDATA      ),
           .EXT_MOD_DATA            ( EXT_MOD_DATA        ),
           .EXT_MOD_IDATA           ( EXT_MOD_IDATA       )
);

LED_CTRL   u_LED_CTRL(
           .CLK                     ( CLK_LOW             ),
           .ARM_LED_DATA            ( ARM_LED_DATA        ),
           .CH1_LED                 ( CH1_LED             ),
           .CH2_LED                 ( CH2_LED             ),
           .SYNC_LED                ( SYNC_LED            ),
           .MODE_LED                ( MODE_LED            )
);

BUZZER_CTRL u_BUZZER_CTRL(
           .CLK_LOW                 ( CLK_LOW             ),
           .BUZZER_EN               ( BUZZER_EN           ),
           .BUZZER_SEL              ( BUZZER_SEL          ),
           .BUZZER_ON_OFF           ( BUZZER_ON_OFF       )
);

endmodule
