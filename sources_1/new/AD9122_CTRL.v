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


module   AD9122_CTRL(
            input   CLK,

            input   CONFIG_EN,
            input   [15:0]CONFIG_DATA,

            output  reg CONFIG_END,
            output  reg AD9122_nCS,
            output  reg AD9122_SCLK,
            output  reg AD9122_SDIO,     
            // input   AD9122_SDO,   
            // output  reg [7:0]READ_AD9122,  
            output  AD9122_nRESET
);

reg         config_en_r=1'b0;
reg         start_en=1'b0;
reg  [5:0]  config_cnt=6'd0;


assign   AD9122_nRESET  =  1'b1;
// always@(posedge CLK )
// begin
//     if(RST  ==  1'b0)
//         AD9122_nRESET  <=  1'b0;
//     else
//         AD9122_nRESET  <=  1'b1;
// end

always@(posedge CLK)
begin
    config_en_r  <=  CONFIG_EN;
    
    if(CONFIG_EN ==  1'b1  && config_en_r  ==  1'b0)
        start_en  <=  1'b1;
    else
        start_en  <=  1'b0;
end

always@(posedge CLK)
begin
    if(start_en  ==  1'b1)
        config_cnt      <=  6'd63;
    else if(config_cnt  >   6'd0)
        config_cnt  <=  config_cnt  -   1'b1;
    else;
end


always@(posedge CLK)
begin
    if(config_cnt  ==  6'd1)
        CONFIG_END  <=  1'b1;
    else
        CONFIG_END  <=  1'b0;
end

always@(posedge CLK)
begin       
    if(start_en  ==  1'b1)
        AD9122_SCLK  <=  1'b1;
    else if(config_cnt[0]  ==  1'b1)
        AD9122_SCLK <=  ~AD9122_SCLK;
    else;
end

always@(posedge CLK)
begin       
    if(config_cnt   >   6'd0)
        AD9122_nCS <=  1'b0;
    else
        AD9122_nCS <=  1'b1;
end

always@(posedge CLK)
begin       
    if(start_en  ==  1'b1)
        AD9122_SDIO <=  1'b1;
    else if(config_cnt[0]  ==  1'b1)
        AD9122_SDIO <=  CONFIG_DATA[config_cnt[5:2]];
    else;
end 

// (*Mark_debug = "true" *)reg [7:0] read_ad9122_data;
// always@(posedge CLK)
// begin       
//     case(config_cnt)
//     6'd30: read_ad9122_data[7] <=  AD9122_SDO;
//     6'd26: read_ad9122_data[6] <=  AD9122_SDO;
//     6'd22: read_ad9122_data[5] <=  AD9122_SDO;
//     6'd18: read_ad9122_data[4] <=  AD9122_SDO;
//     6'd14: read_ad9122_data[3] <=  AD9122_SDO;
//     6'd10: read_ad9122_data[2] <=  AD9122_SDO;
//     6'd6:  read_ad9122_data[1] <=  AD9122_SDO;
//     6'd2:  read_ad9122_data[0] <=  AD9122_SDO;
//     endcase

//     READ_AD9122 <= read_ad9122_data;
// end 

endmodule