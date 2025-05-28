`timescale 1ns/1ps
/*-------------------------------------------------
Create Time:  
Design Name:  wang
Function:  蜂鸣器驱动控制
---------------------------------------------------*/
module   BUZZER_CTRL(
                     input   CLK_LOW,
                     input   BUZZER_EN,
                     input   BUZZER_SEL,
                     output  reg BUZZER_ON_OFF=1'b0
);

reg  [7:0] BUZZER_TIME=8'd16;
reg  [7:0] buzzer_timer=8'd0;
reg  buzzer_en_r=1'b0;
reg  cnt_en=1'b0;
reg  [13:0] cnt_clk=14'd0;

always@(posedge CLK_LOW)
begin
    case(BUZZER_SEL)
        1'b0: BUZZER_TIME  <=  8'd4;    //4个周期    短响
        1'b1: BUZZER_TIME  <=  8'd255;  //255个周期  长响
    endcase
end

always@(posedge CLK_LOW) 
begin
    buzzer_en_r  <=  BUZZER_EN;
    if(BUZZER_EN  ==  1'b1  &&  buzzer_en_r  ==  1'b0)
        cnt_en  <=  1'b1; 
    else if(buzzer_timer  ==  BUZZER_TIME)
        cnt_en  <=  1'b0;
    else;
end

always@(posedge CLK_LOW)
begin
    if(cnt_en  ==  1'b1)begin
        if(cnt_clk  ==  14'd12499)//控制频率 5k:10000*20 = 200000ns 4k:12500*20=250000ns
            cnt_clk  <=  14'd0;
        else   
            cnt_clk  <=  cnt_clk  +1'b1;
    end
    else
        cnt_clk  <=  14'd0;
end

always@(posedge CLK_LOW)
begin
    if(buzzer_timer  <  BUZZER_TIME)begin
        if(cnt_clk  ==  14'd12499)
            buzzer_timer  <=  buzzer_timer  +1'b1;
        else;
    end
    else
        buzzer_timer  <=  5'd0;
end

always@(posedge CLK_LOW)
begin
    if(cnt_clk  ==  14'd1)//5k:2 5002 4K:1 6251
        BUZZER_ON_OFF  <=  1'b1;
    else if(cnt_clk  ==  14'd6251)
        BUZZER_ON_OFF  <=  1'b0;
    else;
end

endmodule
