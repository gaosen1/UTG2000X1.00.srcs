`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/11 15:44:48
// Design Name: 
// Module Name: KEY_BOARD
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


module    KEY_BOARD(
            input   CLK_LOW,
            input   RST,
            
            input   [4:0]KEY_COL,
            output  [5:0]KEY_ROW,
            
            input   CODE_SWITCH_1,
            input   CODE_SWITCH_2,
            
            output  KEY_CODE_INT,
            output  reg [7:0]KEY_CODE_VALUE=8'd0
);
    
wire  KEY_INT;
wire  CODE_INT;
wire  [ 4:0]COLUM;
wire  [ 5:0]ROW;
wire  [ 1:0]KEY_STA;
wire  [ 5:0]KEY_VALUE;
wire  [ 7:0]CODE_SWITCH_VALUE;

assign  KEY_CODE_INT  =  KEY_INT  ||  CODE_INT;

always@(posedge CLK_LOW)
begin
    if(CODE_INT  ==  1'b1)
        KEY_CODE_VALUE  <=  CODE_SWITCH_VALUE;
    else if(KEY_INT  ==  1'b1)
        KEY_CODE_VALUE  <=  {KEY_STA,KEY_VALUE};
    else;
end

KEY_CTRL   u_KEY_CTRL(
            .CLK_LOW             ( CLK_LOW              ),
            .RST                 ( RST                  ),
            .KEY_COL             ( KEY_COL              ),
            .KEY_ROW             ( KEY_ROW              ),
            .KEY_INT             ( KEY_INT              ),
            .KEY_STA             ( KEY_STA              ),
            .COLUM               ( COLUM                ),
            .ROW                 ( ROW                  )
);

KEY_DATD_CHECK   u_KEY_DATD_CHECK(
            .CLK_LOW             ( CLK_LOW              ),
            .ROW                 ( ROW                  ),
            .COLUM               ( COLUM                ),
            .KEY_VALUE           ( KEY_VALUE            )
);

ROTAT_ENCODE   u_ROTAT_ENCODE(
            .CLK_LOW             ( CLK_LOW              ),
            .CODE_SWITCH_1       ( CODE_SWITCH_1        ),
            .CODE_SWITCH_2       ( CODE_SWITCH_2        ),
            .CODE_INT            ( CODE_INT             ),
            .CODE_SWITCH_VALUE   ( CODE_SWITCH_VALUE    )
);

endmodule
