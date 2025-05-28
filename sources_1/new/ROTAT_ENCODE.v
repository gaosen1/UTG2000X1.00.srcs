`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/11 17:27:25
// Design Name: 
// Module Name: ROTAT_ENCODE
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


module   ROTAT_ENCODE(
            input   CLK_LOW,
            input   CODE_SWITCH_1,
            input   CODE_SWITCH_2,
            
            output  reg CODE_INT=1'b0,
            output  reg [7:0]CODE_SWITCH_VALUE=8'd0
);

reg           code_switch_1_r1=1'b0;
reg           code_switch_1_r2=1'b0;
reg           code_switch_2_r1=1'b0;
reg           code_switch_2_r2=1'b0;
reg   [15:0]  cnt_aeshake=16'd0;
reg   [15:0]  cnt_beshake=16'd0;
reg           code_switch_ap1=1'b0;
reg           code_switch_ap2=1'b0;
reg           code_switch_bp1=1'b0;
reg           code_switch_bp2=1'b0;
reg           code_switch_p=1'b0;
reg           turn_dir=1'b0;
reg   [9:0]   int_cnt=0;

/////////////////////////////////消抖
always@(posedge CLK_LOW)
begin 
    begin
      code_switch_1_r1   <=   CODE_SWITCH_1;
      code_switch_1_r2   <=   code_switch_1_r1;
      code_switch_2_r1   <=   CODE_SWITCH_2;
      code_switch_2_r2   <=   code_switch_2_r1;
    end
end

always@(posedge CLK_LOW)
begin
    if(code_switch_1_r1 == 1'b0 && code_switch_1_r2 == 1'b1)//检测到A相下降沿，开始计数消抖
        cnt_aeshake <= 16'd0;
    else
        if(code_switch_1_r1 == 1'b0)//检测A相为低电平时长
            if(cnt_aeshake < 16'd50_000) // 4ms 200_000
                cnt_aeshake <= cnt_aeshake +1'b1;
            else;
        else
            cnt_aeshake <= 16'd0;

    if(code_switch_2_r1 == 1'b0 && code_switch_2_r2 == 1'b1)//检测到B相下降沿，开始计数消抖
        cnt_beshake <= 16'd0;
    else
        if(code_switch_2_r1 == 1'b0)//检测A相为低电平时长
            if(cnt_beshake < 16'd50_000) // 4ms 200_000
                cnt_beshake <= cnt_beshake +1'b1;
            else;
        else
            cnt_beshake <= 16'd0;
end

///////////////////////////////////////输出边沿信号
always@(posedge CLK_LOW)
begin
    if(cnt_aeshake[15:14] == 2'b11)  // [17] == 1'b1
        code_switch_ap1 <= 1'b1;
    else
        code_switch_ap1 <= 1'b0;

    if(cnt_beshake[15:14] == 2'b11)
        code_switch_bp1 <= 1'b1;
    else
        code_switch_bp1 <= 1'b0;

    code_switch_ap2 <= code_switch_ap1;

    if(code_switch_ap2==1'b0 && code_switch_ap1 == 1'b1)//A相上升沿标志
        code_switch_p <= 1'b1;
    else
        code_switch_p <= 1'b0;
end

////////////////////////////////////转动方向判断
always@(posedge CLK_LOW)
begin 
    if(code_switch_p == 1'b1)
        if(code_switch_bp1 == 1'b0)
            turn_dir <= 1'b1; //右转
        else
            turn_dir <= 1'b0; //左转
    else;
end 

always@(posedge CLK_LOW)
begin
    begin
        if(code_switch_ap1  ==  1'b1    &&  code_switch_bp1 ==  1'b1)
            begin
                if(int_cnt  <   10'd1023)
                    int_cnt <=  int_cnt +   1'b1;
                else;
                
                if(int_cnt  ==  10'd1023)
                    CODE_INT    <=  1'b0;
                else
                    CODE_INT    <=  1'b1;           
            end
        else
            begin
                CODE_INT       <=  1'b0;
                int_cnt        <=  10'd0;
            end
    end     
end

always@(posedge CLK_LOW)
begin
    if(CODE_INT == 1'b1)
        if(turn_dir ==  1'b1)
            CODE_SWITCH_VALUE  <=  8'hF2;
        else
            CODE_SWITCH_VALUE  <=  8'hF1;
    else
        CODE_SWITCH_VALUE <= 8'h00;
end

endmodule

