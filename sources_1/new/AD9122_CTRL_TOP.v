`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/12 14:22:45
// Design Name: 
// Module Name: AD9122_CTRL_TOP
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


module   AD9122_CTRL_TOP(
            input   CLK,
            input   RST,

            input   AD9122_CONFIG_EN,
            input   [15:0]AD9122_CONFIG_DATA,
            
            output  AD9122_nCS,
            output  AD9122_SCLK,
            output  AD9122_SDIO,
            // input   AD9122_SDO,
            // output  [7:0]READ_AD9122,
            output  AD9122_nRESET
            
);

wire  CONFIG_END;
wire  CONFIG_EN;
wire  [15:0]CONFIG_DATA;

AD9122_CMD   u_AD9122_CMD(
            .CLK                   ( CLK                ),
            .RST                   ( RST                ),
            .AD9122_CONFIG_EN      ( AD9122_CONFIG_EN   ),
            .AD9122_CONFIG_DATA    ( AD9122_CONFIG_DATA ),
            .CONFIG_END            ( CONFIG_END         ),
            .CONFIG_EN             ( CONFIG_EN          ),
            .CONFIG_DATA           ( CONFIG_DATA        )
);

AD9122_CTRL   u_AD9122_CTRL(
            .CLK                   ( CLK                ),
            .CONFIG_END            ( CONFIG_END         ),
            .CONFIG_EN             ( CONFIG_EN          ),
            .CONFIG_DATA           ( CONFIG_DATA        ),
            .AD9122_nCS            ( AD9122_nCS         ),
            .AD9122_SCLK           ( AD9122_SCLK        ),
            .AD9122_SDIO           ( AD9122_SDIO        ),
            // .AD9122_SDO            ( AD9122_SDO         ),
            // .READ_AD9122           ( READ_AD9122        ),
            .AD9122_nRESET         ( AD9122_nRESET      )
);


endmodule
