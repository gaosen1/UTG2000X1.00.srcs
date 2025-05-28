`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/15 10:18:31
// Design Name: 
// Module Name: ADCS7476_CTRL
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


module   ADCS7476_HCTRL(
            input   CLK_HIGH,
            input   RST,
            input   EXT_MOD_EN,
            
            output  reg ADCS7476_nCS,
            output  reg ADCS7476_SCLK,
            input   ADCS7476_SDATA,
            
            output  reg [15:0]EXT_MOD_DATA,
            output  reg [15:0]EXT_MOD_IDATA
);

localparam  IDLE        =  2'b00;
localparam  UP_POWER    =  2'b01;
localparam  ADC_SAMPLE  =  2'b10;
localparam  DOWN_POWER  =  2'b11;

reg   ext_mod_en_r=1'b0;
reg   start_en=1'b0;
reg   [8:0]state=9'd0;
reg   [1:0]adc_state=2'd0;
reg   uppower_en=1'b0;
reg   rst_state=1'b0;
reg   [11:0]recv_data=12'd0;
reg   [11:0]mod_data=12'd0;
(*KEEP = "TRUE"*)reg   [11:0]adc_data=12'd0;
reg   [11:0]adc_data_r=12'd0;
reg   [13:0]aout_r2=14'd0;
reg   [13:0]aout_r1=14'd0;
reg   [13:0]aout_rr1=14'd0;
reg   [13:0]aout_rr2=14'd0;
(*KEEP = "TRUE"*)reg   [13:0]aout_r=14'd0;
reg   [13:0]aout=14'd0;
wire  [32:0]aout_w;
reg   [17:0]int_vaule=18'd0;
reg   [15:0]aout_w_r=16'd0;

always@(posedge CLK_HIGH)
begin
    ext_mod_en_r  <=  EXT_MOD_EN;

    if(state  ==  9'd319  ||  rst_state  ==  1'b1)
        state  <=  9'd0;
    else if(uppower_en  ==  1'b1)
        state  <=  state  +  1'b1;
    else;
end

always@(posedge CLK_HIGH)
begin
    if(RST == 1'b1)begin
        adc_state   <=  IDLE;
        uppower_en  <=  1'b0;
        rst_state   <=  1'b1;
    end
    else
        case(adc_state)
        IDLE: begin
                uppower_en  <=  1'b0;
                rst_state   <=  1'b1;
                if(ext_mod_en_r  ==  1'b1)
                    adc_state  <=  UP_POWER;
                else
                    adc_state  <=  IDLE;
              end
        UP_POWER: begin //上电
                    uppower_en  <=  1'b1;
                    rst_state   <=  1'b0;
                    if(state  ==  9'd319)
                        adc_state  <=  ADC_SAMPLE;
                    else
                        adc_state  <=  UP_POWER;
                   end
        ADC_SAMPLE: begin //采样
                        if(ext_mod_en_r  ==  1'b0)begin
                            if(state  ==  9'd319)
                                adc_state  <=  DOWN_POWER;
                             else
                                adc_state  <=  ADC_SAMPLE;
                        end
                        else;
                    end
        DOWN_POWER: begin //停止
                    if(state  ==  9'd297)
                        adc_state  <=  IDLE;
                    else
                        adc_state  <=  DOWN_POWER;
                   end
        default:;
        endcase
end

reg cs_n=1'b0;
reg cs_n1=1'b0;
always@(posedge CLK_HIGH)
begin
    if(state  <  9'd255)
        cs_n <= 1'b1;
    else
        cs_n <= 1'b0;

    if(state  <  9'd73)
        cs_n1 <= 1'b1;
    else
        cs_n1 <= 1'b0;

    if(uppower_en  ==  1'b1)begin
        if(adc_state  ==  DOWN_POWER)begin
            if(cs_n1 == 1'b1)
                ADCS7476_nCS   <=  1'b0;
            else
                ADCS7476_nCS   <=  1'b1;
        end
        else
            begin
                if(cs_n == 1'b1)
                    ADCS7476_nCS   <=  1'b0;
                else
                    ADCS7476_nCS   <=  1'b1;
            end
    end
    else
        ADCS7476_nCS   <=  1'b1;
end

always@(posedge CLK_HIGH)
begin
    if(uppower_en  ==  1'b1)begin
        if(state[3]  ==  1'b0)
            ADCS7476_SCLK  <=  1'b1;
        else
            ADCS7476_SCLK  <=  1'b0;
    end
    else
        ADCS7476_SCLK   <=  1'b1;
end

always@(posedge CLK_HIGH)
begin
    case(state)     
    9'd73:   recv_data[11]   <=  ADCS7476_SDATA;
    9'd89:   recv_data[10]   <=  ADCS7476_SDATA;
    9'd105:  recv_data[9]    <=  ADCS7476_SDATA;
    9'd121:  recv_data[8]    <=  ADCS7476_SDATA;
    9'd137:  recv_data[7]    <=  ADCS7476_SDATA;
    9'd153:  recv_data[6]    <=  ADCS7476_SDATA;
    9'd169:  recv_data[5]    <=  ADCS7476_SDATA;
    9'd185:  recv_data[4]    <=  ADCS7476_SDATA;
    9'd201:  recv_data[3]    <=  ADCS7476_SDATA;
    9'd217:  recv_data[2]    <=  ADCS7476_SDATA;
    9'd233:  recv_data[1]    <=  ADCS7476_SDATA;
    9'd249:  recv_data[0]    <=  ADCS7476_SDATA;
    default:;
    endcase  
end

reg data_vaild=1'b0;
always@(posedge CLK_HIGH)
begin
    if(state  ==  9'd257)
        data_vaild <= 1'b1;
    else 
        data_vaild <= 1'b0;

    if(data_vaild == 1'b1)
        mod_data  <=  recv_data;
    else
        mod_data  <=  mod_data;
end

always@(posedge CLK_HIGH)
begin
    if(mod_data   <=  12'd520)
        adc_data_r  <=  12'd2568;
    else if(mod_data  >  12'd3590)
        adc_data_r  <=  12'd1542;
    else
        adc_data_r  <=  {~mod_data[11],mod_data[10:0]};
end
//----------------------------------------------------------------------
//
// Vtpm3 = 0.263*Vtpm1+3.08*0.53
//
// FPGA_DATA = 4*ADC_DATA +0.25*ADC_DATA+0.125ADC_DATA-8859;
//
// 量化
//-----------------------------------------------------------------------

always@(posedge CLK_HIGH)
begin
    if(adc_state  ==  ADC_SAMPLE)
        adc_data  <= adc_data_r;
    else
        adc_data  <=  12'd0;   
end

// always@(posedge CLK_HIGH)
// begin
    
//     aout_r <=  {adc_data,2'b00} +   {{2{adc_data[11]}},adc_data}    +   {{4{adc_data[11]}},adc_data[11:2]}+   {{6{adc_data[11]}},adc_data[11:4]};
// end
reg [13:0]aout_add1=14'd0;
reg [13:0]aout_add2=14'd0;
always@(posedge CLK_HIGH)
begin
    aout_add1 <= {adc_data,2'b00} +   {{2{adc_data[11]}},adc_data};
    aout_add2 <= {{4{adc_data[11]}},adc_data[11:2]} +   {{6{adc_data[11]}},adc_data[11:4]};
    aout_r    <= aout_add1 + aout_add2;
end
always@(posedge CLK_HIGH)
begin
    if(state  ==  9'd258)
        aout_r1  <=  aout_r;
    else;
    
    aout_rr1  <=  aout_r1;
    aout_rr2  <=  aout_rr1;
    
    if(state  ==  9'd260)
        aout_r2  <=  aout_r;
    else;
end

////////////////////////////(D-A)*B+c
always@(posedge CLK_HIGH)
begin//插值
    if(uppower_en  ==  1'b1)begin
        if(state  ==  9'd260)
            int_vaule  <=  18'd0;
        else
            int_vaule  <=  int_vaule  +18'd410;
    end
    else
        int_vaule  <=  18'd0;
end

ADC_INT_FIR  u_ADC_INT_FIR (
            .CLK        ( CLK_HIGH          ),      // input wire CLK_HIGH
            .CE         ( uppower_en        ),      // input wire CE
            // .SCLR       ( 1'b0              ),      // input wire SCLR
            .A          ( aout_rr2          ),      // input wire [13 : 0] A
            .B          ( int_vaule         ),      // input wire [17 : 0] B
            .C          ( {aout_rr2,17'd0}  ),      // input wire [30 : 0] C
            .D          ( aout_r2           ),      // input wire [13 : 0] D
            .P          ( aout_w            )       // output wire [32 : 0] P
);

reg high_r;
reg [15:0]aout_wr;
reg [15:0]aout_wrr;
always@(posedge CLK_HIGH)
begin
    aout_wrr  <=  aout_w[31:15];
    
    if(aout_wrr == 16'd32764)
        high_r <= 1'b1;
    else
        high_r <= 1'b0;

    // if(aout_wrr == 16'd32764)
    if(high_r == 1'b1)
        aout_wr  <= 16'd32767;
    else
        aout_wr  <= aout_wrr;
end

always@(posedge CLK_HIGH)
begin
    EXT_MOD_IDATA    <=  aout_wr;
    EXT_MOD_DATA     <=  {aout_r2,2'b0};
end

endmodule
