`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/11 17:17:05
// Design Name: 
// Module Name: KEY_DATD_CHECK
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


module   KEY_DATD_CHECK(
            input   CLK_LOW,
            input   [5:0]ROW,
            input   [4:0]COLUM,
            
            output  reg [5:0]KEY_VALUE=6'd0
);

reg  [5:0]  key_value_temp=6'd0;

always@(posedge CLK_LOW)
begin
    case(ROW)
    6'b111110:  key_value_temp[2:0]  <=  3'b001    ;//row1
    6'b111101:  key_value_temp[2:0]  <=  3'b010    ;//row2
    6'b111011:  key_value_temp[2:0]  <=  3'b011    ;//row3
    6'b110111:  key_value_temp[2:0]  <=  3'b100    ;//row4
    6'b101111:  key_value_temp[2:0]  <=  3'b101    ;//row5
    6'b011111:  key_value_temp[2:0]  <=  3'b110    ;//row6
    default:    key_value_temp[2:0]  <=  3'b000    ;//null
    endcase
end

always@(posedge CLK_LOW)
begin
    case(COLUM)
    5'b11110:   key_value_temp[5:3]  <=  3'b001    ;//colum1
    5'b11101:   key_value_temp[5:3]  <=  3'b010    ;//colum2
    5'b11011:   key_value_temp[5:3]  <=  3'b011    ;//colum3
    5'b10111:   key_value_temp[5:3]  <=  3'b100    ;//colum4
    5'b01111:   key_value_temp[5:3]  <=  3'b101    ;//colum5
    default:    key_value_temp[5:3]  <=  3'b000    ;//null 
    endcase
end

always@(posedge CLK_LOW)
begin
     KEY_VALUE   <=  key_value_temp;
end

endmodule
