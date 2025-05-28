`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/10 19:04:06
// Design Name: 
// Module Name: SYS_RST_GEN
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
//////////////////////////////////////////////////////////////////////////////
module   SYS_RST_GEN(
         input   CLK,
         
         output  reg SYSTEM_RST=1'b1
);

reg  [13:0]rst_cnt=14'd0;

always@(posedge CLK)
begin
    if(rst_cnt  <  14'd10_000)//仿真用60us  10_000 10_000
        rst_cnt  <=  rst_cnt  +1'b1;
    else;
end

always@(posedge CLK)
begin
    if(rst_cnt  ==  14'd10_000)
        SYSTEM_RST  <=  1'b0;
    else
        SYSTEM_RST  <=  1'b1;
end

endmodule
