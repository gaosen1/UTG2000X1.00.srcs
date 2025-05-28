`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/29 14:11:44
// Design Name: 
// Module Name: SHARE_CONFIG_REG
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
module SHARE_CONFIG_REG(
                       input   CLK_LOW,

                       input   [2:0]HW_REV,
                       input   SHARE_CONFIG_WE,
                       input   [7:0]SHARE_CONFIG_ADDR,
                       input   [7:0]SHARE_CONFIG_DATA,
                       input   [7:0]READ_REG_ADDR,
                       output  reg  [7:0]READ_BACK_DATA,
                       output  reg  CH1_SYNC,
                       output  reg  CH2_SYNC,
                       //---------------------------------按键
                       input   CH1_LOAD_PROTECT_STATE,  //通道1保护
                       input   CH2_LOAD_PROTECT_STATE,  //通道2保护
                       
                       input   INPUT_CLK_VALID,         //时钟有效
                       output  reg [4:0]LED_DATA=5'd0,  //LED[4]，“1”选择ARM，“0”上电跑马灯
                       output  reg BUZZER_EN=1'b0, 
                       output  reg BUZZER_SEL=1'b0,
                       input   [7:0]KEY_VALUE,          //键值
                       //--------------------------------------AD9518
                       output  reg AD9518_CONFIG_EN=1'b0,
                       output  reg [23:0]AD9518_CONFIG_DATA=24'd0,
                       //--------------------------------------AD9122
                       output  reg AD9122_CONFIG_EN=1'b0,
                       output  reg [15:0]AD9122_CONFIG_DATA=16'd0,
                       //--------------------------------------DAC124S
                       output  reg DAC124_CONFIG_EN=1'b0,
                       output  reg [15:0]DAC124_CONFIG_DATA=16'd0
       
);

reg [1:0]ch_sync_r=2'b0;

always @(posedge CLK_LOW) 
begin
    CH1_SYNC <= ~ch_sync_r[1];    
    CH2_SYNC <= ~ch_sync_r[0];    
end

always @(posedge CLK_LOW) 
begin
    case(READ_REG_ADDR[7:0])     
    8'hB0:  READ_BACK_DATA  <=  KEY_VALUE;
    8'hB1:  READ_BACK_DATA  <=  {8{INPUT_CLK_VALID}};
    8'hC0:  READ_BACK_DATA  <=  {5'd0,HW_REV};
    8'hC1:  READ_BACK_DATA  <=  8'b0000_0000;
    8'hC2:  READ_BACK_DATA  <=  8'b0000_0001;
    8'hC4:  begin
                if(CH1_LOAD_PROTECT_STATE    ==    1'b1)
                    READ_BACK_DATA[3:0]    <=    4'hA;
                else
                    READ_BACK_DATA[3:0]    <=    4'h6;
                
                if(CH2_LOAD_PROTECT_STATE    ==    1'b1)
                    READ_BACK_DATA[7:4]    <=    4'hA;
                else
                    READ_BACK_DATA[7:4]    <=    4'h6;
            end
    default:;
    endcase    
end

always@(posedge CLK_LOW)
begin
    if(SHARE_CONFIG_WE == 1'b1) 
        begin
            case(SHARE_CONFIG_ADDR[7:0])
    //--------------------------- begin----------------------------------------------------------------
            8'h01:  begin   AD9518_CONFIG_DATA[7 : 0]       <=  SHARE_CONFIG_DATA;   AD9518_CONFIG_EN    <=  1'b0;   end
            8'h02:          AD9518_CONFIG_DATA[15: 8]       <=  SHARE_CONFIG_DATA;
            8'h03:  begin   AD9518_CONFIG_DATA[23:16]       <=  SHARE_CONFIG_DATA;   AD9518_CONFIG_EN    <=  1'b1;   end
            8'h04:          ch_sync_r                       <=  SHARE_CONFIG_DATA[1:0];   
            8'h05:  begin   AD9122_CONFIG_DATA[7:0]         <=  SHARE_CONFIG_DATA;   AD9122_CONFIG_EN    <=  1'b0;   end
            8'h06:  begin   AD9122_CONFIG_DATA[15:8]        <=  SHARE_CONFIG_DATA;   AD9122_CONFIG_EN    <=  1'b1;   end
            8'h07:  begin   DAC124_CONFIG_DATA[7:0]         <=  SHARE_CONFIG_DATA;   DAC124_CONFIG_EN    <=  1'b0;   end
            8'h08:  begin   DAC124_CONFIG_DATA[15:8]        <=  SHARE_CONFIG_DATA;   DAC124_CONFIG_EN    <=  1'b1;   end
            8'h0A:          LED_DATA[4:0]                   <=  SHARE_CONFIG_DATA[4:0];
            8'h30:          BUZZER_SEL                      <=  SHARE_CONFIG_DATA[0];
            8'h31:          BUZZER_EN                       <=  SHARE_CONFIG_DATA[0];
    //---------------------------------------------------------------------------------------------------
            default: ;
        endcase
        end    
    else
        begin
            BUZZER_EN          <=  1'b0;
            ch_sync_r          <=  2'b00;
        end 
end
            
endmodule 
