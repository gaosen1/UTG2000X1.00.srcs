`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/12 15:42:30
// Design Name: 
// Module Name: AD9158_CMD
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
// `define  FPGA_CONFIG_AD9518

module   AD9518_CMD(
            input   CLK,
            input   RST,
            
            input   AD9518_CONFIG_EN,
            input   [23:0]AD9518_CONFIG_DATA,
            
            input   CONFIG_END,
            output  reg CONFIG_EN,
            output  reg [23:0]CONFIG_DATA
);

`ifdef  FPGA_CONFIG_AD9518 
////////////////////////////////////////////FPGA配置AD9518
reg   [ 5:0]  state=6'd0;
always@(posedge CLK)
begin
    if(RST  ==  1'b1)
        begin
            state   <=  6'd0;
            CONFIG_DATA  <=  24'd0;
            CONFIG_EN    <=  1'b0;
        end
    else
        if(CONFIG_END  ==  1'b1)
            begin   
                state   <=  state   +   1'b1;
                if(state  <  6'd55)
                   CONFIG_EN  <=  1'b0;
                else;
            end
        else
            case(state)
            6'd0 :  begin   CONFIG_DATA <=  24'h000018; CONFIG_EN    <=  1'b1;   end//000018"
            6'd1 :  begin   CONFIG_DATA <=  24'h000100; CONFIG_EN    <=  1'b1;   end//000100"
            6'd2 :  begin   CONFIG_DATA <=  24'h000210; CONFIG_EN    <=  1'b1;   end//000210"
            6'd3 :  begin   CONFIG_DATA <=  24'h000361; CONFIG_EN    <=  1'b1;   end//000363"
            6'd4 :  begin   CONFIG_DATA <=  24'h000400; CONFIG_EN    <=  1'b1;   end//000400"
            6'd5 :  begin   CONFIG_DATA <=  24'h00107C; CONFIG_EN    <=  1'b1;   end//00107C"
            6'd6 :  begin   CONFIG_DATA <=  24'h001101; CONFIG_EN    <=  1'b1;   end//001101"
            6'd7 :  begin   CONFIG_DATA <=  24'h001200; CONFIG_EN    <=  1'b1;   end//001200"
            6'd8 :  begin   CONFIG_DATA <=  24'h00130A; CONFIG_EN    <=  1'b1;   end//001308"
            6'd9 :  begin   CONFIG_DATA <=  24'h00140F; CONFIG_EN    <=  1'b1;   end//00140C"
            6'd10:  begin   CONFIG_DATA <=  24'h001500; CONFIG_EN    <=  1'b1;   end//001500"
            6'd11:  begin   CONFIG_DATA <=  24'h001605; CONFIG_EN    <=  1'b1;   end//001605"
            6'd12:  begin   CONFIG_DATA <=  24'h001700; CONFIG_EN    <=  1'b1;   end//001700"
            6'd13:  begin   CONFIG_DATA <=  24'h001807; CONFIG_EN    <=  1'b1;   end//001807"
            6'd14:  begin   CONFIG_DATA <=  24'h001900; CONFIG_EN    <=  1'b1;   end//001900"
            6'd15:  begin   CONFIG_DATA <=  24'h001A00; CONFIG_EN    <=  1'b1;   end//001A00"
            6'd16:  begin   CONFIG_DATA <=  24'h001B00; CONFIG_EN    <=  1'b1;   end//001B00"
            6'd17:  begin   CONFIG_DATA <=  24'h001C26; CONFIG_EN    <=  1'b1;   end//001C26"
            6'd18:  begin   CONFIG_DATA <=  24'h001D00; CONFIG_EN    <=  1'b1;   end//001D00"
            6'd19:  begin   CONFIG_DATA <=  24'h001E00; CONFIG_EN    <=  1'b1;   end//001E00"
            6'd20:  begin   CONFIG_DATA <=  24'h001F0E; CONFIG_EN    <=  1'b1;   end//001F0E"
            6'd21:  begin   CONFIG_DATA <=  24'h00A001; CONFIG_EN    <=  1'b1;   end//00A001"
            6'd22:  begin   CONFIG_DATA <=  24'h00A100; CONFIG_EN    <=  1'b1;   end//00A100"
            6'd23:  begin   CONFIG_DATA <=  24'h00A200; CONFIG_EN    <=  1'b1;   end//00A200"
            6'd24:  begin   CONFIG_DATA <=  24'h00A301; CONFIG_EN    <=  1'b1;   end//00A301"
            6'd25:  begin   CONFIG_DATA <=  24'h00A400; CONFIG_EN    <=  1'b1;   end//00A400"
            6'd26:  begin   CONFIG_DATA <=  24'h00A500; CONFIG_EN    <=  1'b1;   end//00A500"
            6'd27:  begin   CONFIG_DATA <=  24'h00A601; CONFIG_EN    <=  1'b1;   end//00A601"
            6'd28:  begin   CONFIG_DATA <=  24'h00A700; CONFIG_EN    <=  1'b1;   end//00A700"
            6'd29:  begin   CONFIG_DATA <=  24'h00A800; CONFIG_EN    <=  1'b1;   end//00A800"
            6'd30:  begin   CONFIG_DATA <=  24'h00A901; CONFIG_EN    <=  1'b1;   end//00A901"
            6'd31:  begin   CONFIG_DATA <=  24'h00AA00; CONFIG_EN    <=  1'b1;   end//00AA00"
            6'd32:  begin   CONFIG_DATA <=  24'h00AB00; CONFIG_EN    <=  1'b1;   end//00AB00"
            6'd33:  begin   CONFIG_DATA <=  24'h00F002; CONFIG_EN    <=  1'b1;   end//00F008"
            6'd34:  begin   CONFIG_DATA <=  24'h00F108; CONFIG_EN    <=  1'b1;   end//00F108"
            6'd35:  begin   CONFIG_DATA <=  24'h00F208; CONFIG_EN    <=  1'b1;   end//00F20A"
            6'd36:  begin   CONFIG_DATA <=  24'h00F308; CONFIG_EN    <=  1'b1;   end//00F30A"
            6'd37:  begin   CONFIG_DATA <=  24'h00F408; CONFIG_EN    <=  1'b1;   end//00F408"
            6'd38:  begin   CONFIG_DATA <=  24'h00F508; CONFIG_EN    <=  1'b1;   end//00F508"
            6'd39:  begin   CONFIG_DATA <=  24'h019000; CONFIG_EN    <=  1'b1;   end//019000"
            6'd40:  begin   CONFIG_DATA <=  24'h019180; CONFIG_EN    <=  1'b1;   end//019180"
            6'd41:  begin   CONFIG_DATA <=  24'h019200; CONFIG_EN    <=  1'b1;   end//019200"
            6'd42:  begin   CONFIG_DATA <=  24'h0193BB; CONFIG_EN    <=  1'b1;   end//0193BB"
            6'd43:  begin   CONFIG_DATA <=  24'h019480; CONFIG_EN    <=  1'b1;   end//019480"
            6'd44:  begin   CONFIG_DATA <=  24'h019500; CONFIG_EN    <=  1'b1;   end//019500"
            6'd45:  begin   CONFIG_DATA <=  24'h019600; CONFIG_EN    <=  1'b1;   end//019600"
            6'd46:  begin   CONFIG_DATA <=  24'h019780; CONFIG_EN    <=  1'b1;   end//019780"
            6'd47:  begin   CONFIG_DATA <=  24'h019800; CONFIG_EN    <=  1'b1;   end//019800"
            6'd48:  begin   CONFIG_DATA <=  24'h01A300; CONFIG_EN    <=  1'b1;   end//01A300"
            6'd49:  begin   CONFIG_DATA <=  24'h01E002; CONFIG_EN    <=  1'b1;   end//01E002"
            6'd50:  begin   CONFIG_DATA <=  24'h01E102; CONFIG_EN    <=  1'b1;   end//01E102"
            6'd51:  begin   CONFIG_DATA <=  24'h023000; CONFIG_EN    <=  1'b1;   end//023000"
            6'd52:  begin   CONFIG_DATA <=  24'h023100; CONFIG_EN    <=  1'b1;   end//023100"
            6'd53:  begin   CONFIG_DATA <=  24'h023200; CONFIG_EN    <=  1'b1;   end//023200"
            6'd54:  begin   CONFIG_DATA <=  24'h023201; CONFIG_EN    <=  1'b1;   end 
            // 6'd55:  begin   CONFIG_DATA <=  24'h001807; CONFIG_EN    <=  1'b1;   end 
            // 6'd56:  begin   CONFIG_DATA <=  24'h023201; CONFIG_EN    <=  1'b1;   end 
            // 6'd57:  begin   CONFIG_DATA <=  24'h001806; CONFIG_EN    <=  1'b1;   end 
            // 6'd58:  begin   CONFIG_DATA <=  24'h023201; CONFIG_EN    <=  1'b1;   end 
            default:;
            endcase
end
`else
////////////////////////////////////////////ARM配置AD9518
always@(posedge CLK)
begin
    if(RST  ==  1'b1)begin
        CONFIG_DATA  <=  24'd0;
        CONFIG_EN    <=  1'b0;               
    end
    else
        begin
            CONFIG_EN    <=  AD9518_CONFIG_EN;
            CONFIG_DATA  <=  AD9518_CONFIG_DATA;
        end
end
`endif

endmodule
