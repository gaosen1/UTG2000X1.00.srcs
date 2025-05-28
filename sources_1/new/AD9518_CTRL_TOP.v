`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/12 15:42:30
// Design Name: 
// Module Name: AD9518_CTRL_TOP
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


module   AD9518_CTRL_TOP(
            input   CLK,
            input   RST,

            input   AD9518_CONFIG_EN,
            input   [23:0]AD9518_CONFIG_DATA,

            output  AD9518_nCS,
            output  AD9518_SCLK,
            output  AD9518_SDIO
);

wire  CONFIG_END;
wire  CONFIG_EN;
wire  [23:0]CONFIG_DATA;

AD9518_CMD   u_AD9518_CMD(
            .CLK                   ( CLK                ),
            .RST                   ( RST                ),
            .AD9518_CONFIG_EN      ( AD9518_CONFIG_EN   ),
            .AD9518_CONFIG_DATA    ( AD9518_CONFIG_DATA ),
            .CONFIG_END            ( CONFIG_END         ),
            .CONFIG_EN             ( CONFIG_EN          ),
            .CONFIG_DATA           ( CONFIG_DATA        )
);

AD9518_CTRL   u_AD9518_CTRL(
            .CLK                   ( CLK                ),
            .CONFIG_END            ( CONFIG_END         ),
            .CONFIG_EN             ( CONFIG_EN          ),
            .CONFIG_DATA           ( CONFIG_DATA        ),
            .AD9518_nCS            ( AD9518_nCS         ),
            .AD9518_SCLK           ( AD9518_SCLK        ),
            .AD9518_SDIO           ( AD9518_SDIO        )
);

endmodule
