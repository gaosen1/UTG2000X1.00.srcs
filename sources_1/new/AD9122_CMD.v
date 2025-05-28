`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/12 14:23:14
// Design Name: 
// Module Name: AD9122_CMD
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
// `define  FPGA_CONFIG_AD9122

module   AD9122_CMD(
            input   CLK,
            input   RST,
            
            input   AD9122_CONFIG_EN,
            input   [15:0]AD9122_CONFIG_DATA,
            
            input   CONFIG_END,
            output  reg CONFIG_EN,
            output  reg [15:0]CONFIG_DATA
);

`ifdef  FPGA_CONFIG_AD9122 
////////////////////////////////////////////FPGA配置AD9122
reg   [ 4:0]  state=5'd0;
always@(posedge CLK)
begin
    if(RST  ==  1'b1)
        begin
            state   <=  5'd0;
            CONFIG_DATA <=  16'd0;
            CONFIG_EN    <=  1'b0;
        end
    else
        if(CONFIG_END   ==  1'b1)
            begin   
                state   <=  state   +   1'b1;
                if(state  <  5'd19)
                   CONFIG_EN <=  1'b0;
                else;
            end
        else
            case(state)
            5'd0 :  begin   CONFIG_DATA <=  16'h0020; CONFIG_EN    <=  1'b1;   end//0020
            5'd1 :  begin   CONFIG_DATA <=  16'h0000; CONFIG_EN    <=  1'b1;   end//0000
            5'd2 :  begin   CONFIG_DATA <=  16'h1048; CONFIG_EN    <=  1'b1;   end//1048
            5'd3 :  begin   CONFIG_DATA <=  16'h1600; CONFIG_EN    <=  1'b1;   end//1601
            5'd4 :  begin   CONFIG_DATA <=  16'h1705; CONFIG_EN    <=  1'b1;   end//1704
            5'd5 :  begin   CONFIG_DATA <=  16'h1BE0; CONFIG_EN    <=  1'b1;   end//1BE4
            5'd6 :  begin   CONFIG_DATA <=  16'h1C01; CONFIG_EN    <=  1'b1;   end//1C00
            5'd7 :  begin   CONFIG_DATA <=  16'h1D00; CONFIG_EN    <=  1'b1;   end//1D01
            5'd8 :  begin   CONFIG_DATA <=  16'h1E01; CONFIG_EN    <=  1'b1;   end//1E01
            5'd9 :  begin   CONFIG_DATA <=  16'h1803; CONFIG_EN    <=  1'b1;   end//1803
            // 5'd10:  begin   CONFIG_DATA <=  16'h1800; CONFIG_EN    <=  1'b1;   end//1803
            5'd11:  begin   CONFIG_DATA <=  16'h1800; CONFIG_EN    <=  1'b1;   end//1803
            5'd15:  begin   CONFIG_DATA <=  16'h40ff; CONFIG_EN    <=  1'b1;   end//4080
            5'd16:  begin   CONFIG_DATA <=  16'h4103; CONFIG_EN    <=  1'b1;   end//4103
            5'd17:  begin   CONFIG_DATA <=  16'h44ff; CONFIG_EN    <=  1'b1;   end//4480
            5'd18:  begin   CONFIG_DATA <=  16'h4503; CONFIG_EN    <=  1'b1;   end//4503
            default:;
            endcase
end
`else
////////////////////////////////////////////ARM配置AD9122
always@(posedge CLK)
begin
    if(RST  ==  1'b1)
        begin
            CONFIG_DATA  <=  16'd0;
            CONFIG_EN    <=  1'b0;               
        end
    else
        begin
            CONFIG_EN    <=  AD9122_CONFIG_EN;
            CONFIG_DATA  <=  AD9122_CONFIG_DATA;
        end
end
`endif

endmodule
