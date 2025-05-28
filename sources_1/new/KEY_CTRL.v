`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/11 16:34:29
// Design Name: 
// Module Name: KEY_CTRL
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


module   KEY_CTRL(
            input   CLK_LOW,
            input   RST,
            
            input   [4:0]KEY_COL,
            output  reg [5:0]KEY_ROW,
            
            output  reg KEY_INT,
            output  reg [1:0]KEY_STA,
            output  reg [4:0]COLUM,
            output  reg [5:0]ROW
);
    
reg   [ 6:0]  refresh_key_cnt=7'd0;
reg           refresh_key=1'b0;
reg           scan_en=1'b1;
reg   [19:0]  n_delay_cnt=20'd0;
reg   [14:0]  p_delay_cnt=15'd0;
reg   [ 4:0]  colum_r=5'd0;
reg   [ 5:0]  row_r=6'd0;
reg   [ 9:0]  key_cnt=10'd0;
reg           key_int_r=1'b0;
reg           key_int_r1=1'b0;
reg           key_int_en=1'b0;

always@(posedge CLK_LOW)
begin
    if(refresh_key_cnt  ==  7'd99) //行扫描时间
        refresh_key_cnt  <=  1'b0;
    else
        refresh_key_cnt  <=  refresh_key_cnt  +1'b1;
end

always@(posedge CLK_LOW)
begin
    if(refresh_key_cnt  ==  7'd99)
         refresh_key  <=  1'b1;
    else
         refresh_key  <=  1'b0;
end

always@(posedge CLK_LOW)
begin
    if(KEY_COL  ==  5'b11111)
        scan_en  <=  1'b1;
    else
        scan_en  <=  1'b0;
end

always@(posedge CLK_LOW)
begin
    if(RST  ==  1'b1)
        KEY_ROW  <=  6'b111110;
    else 
        if(refresh_key  ==  1'b1  &&  scan_en  ==  1'b1) //行扫描
            KEY_ROW  <=  {KEY_ROW[4:0],KEY_ROW[5]};
        else;
end

always@(posedge CLK_LOW)
begin//按下消抖
    if(refresh_key  ==  1'b1)begin
        if(scan_en  ==  1'b0)begin
            if(n_delay_cnt  <  20'd750_000)// 2000ns*750_000 = 1.5s
                n_delay_cnt  <=  n_delay_cnt  +1'b1;
            else;
        end
        else
            begin
                if(p_delay_cnt  == 15'd7_500)//弹起消抖完成，按下消抖计数器归零
                        n_delay_cnt  <=  20'd0;
                else;
            end
    end
    else;
end

always@(posedge CLK_LOW)
begin
    if(refresh_key  ==  1'b1)begin
        if(n_delay_cnt  ==  20'd5_000)begin//按下消抖 10ms 保存键值
            colum_r <=  KEY_COL;
            row_r   <=  KEY_ROW;
        end
        else if(p_delay_cnt  ==  15'd6_000)begin//弹起之后，清除键值
            colum_r  <=  5'd0;
            row_r    <=  6'd0;
        end
        else;
    end
    else;
end

always@(posedge CLK_LOW)
begin //弹起消抖
    if(refresh_key  ==  1'b1)begin
        if(scan_en  ==  1'b1)begin
            if(p_delay_cnt  <   15'd7_500)// 2000ns*7_500 = 15 ms  
                p_delay_cnt <=  p_delay_cnt +   1'b1; 
            else;
        end
        else   
            p_delay_cnt <=  15'd0;      //按键按下时，弹起消抖计数器归零 
    end
    else;   
end

always@(posedge CLK_LOW)
begin
    if(refresh_key  ==  1'b1)begin
        if(n_delay_cnt  ==  20'd750_000)begin //如果按下时长等于或者大于1.5s，则为长按
            key_int_r <=    1'b1;
            KEY_STA   <=    2'b11;       //长按，键值高两位为高电平
            COLUM     <=    colum_r;
            ROW       <=    row_r  ;
        end
        else if(p_delay_cnt  ==  15'd5_000)begin //弹起消抖 10ms时判断按下时长
            key_int_r <=    1'b1;
            KEY_STA   <=    2'b00;                      
            COLUM     <=    colum_r;
            ROW       <=    row_r  ;
        end
        else
            key_int_r    <=  1'b0;
    end
    else;
end

always@(posedge CLK_LOW)
begin
    key_int_r1  <=  key_int_r;
    
    if(key_int_r  ==  1'b1  &&  key_int_r1  ==  1'b0)
        key_int_en  <=  1'b1;
    else if(key_cnt  ==  10'd200)
        key_int_en  <=  1'b0;
    else;

    if(key_int_en  ==  1'b1)begin
        if(key_cnt  <  10'd200)
            key_cnt  <=  key_cnt  +1'b1;
        else;
    end
    else
        key_cnt  <=  1'b0;

    KEY_INT  <=  key_int_en;
end


endmodule
