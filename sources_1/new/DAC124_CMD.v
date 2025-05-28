module   DAC124_CMD(
            input   CLK,
            input   RST,
            
            input   DAC124_CONFIG_EN,
            input   [15:0]DAC124_CONFIG_DATA,
            
            input   CONFIG_END,
            output  reg CONFIG_EN,
            output  reg [15:0]CONFIG_DATA
);

////////////////////////////////////////////FPGA配置AD9518
reg   [ 2:0]  state=3'd0;
always@(posedge CLK  or  negedge RST)
begin
    if(RST  ==  1'b0)
        begin
            state   <=  3'd0;
            CONFIG_DATA  <=  16'd0;
            CONFIG_EN    <=  1'b0;
        end
    else
        if(CONFIG_END  ==  1'b1)
            begin   
                state   <=  state   +   1'b1;
                if(state  <  3'd4)
                   CONFIG_EN  <=  1'b0;
                else;
            end
        else
            case(state)
            3'd0 :  begin   CONFIG_DATA <=  16'h4bb8; CONFIG_EN    <=  1'b1;   end//000018"
            3'd1 :  begin   CONFIG_DATA <=  16'h1bb8; CONFIG_EN    <=  1'b1;   end//000100"
            3'd2 :  begin   CONFIG_DATA <=  16'hCBB8; CONFIG_EN    <=  1'b1;   end//000100"
            3'd3 :  begin   CONFIG_DATA <=  16'h9bb8; CONFIG_EN    <=  1'b1;   end//000100"
            default:;
            endcase
end

endmodule
            