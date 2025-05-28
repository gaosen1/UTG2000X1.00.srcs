`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/11 13:02:55
// Design Name: 
// Module Name: INTFACE
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


module   INTFACE(
            input   CLK_LOW,
            
            ////////////////////////////FMC_port
            input   ARM_FPGA_nCS,
            input   ARM_FPGA_nWE,
            input   ARM_FPGA_nOE,
            input   [11:0]ARM_FPGA_ADDR,
            inout   [7:0]ARM_FPGA_DATA,
            
            input   [7:0]READ_BACK_DATA,
            output  reg [7:0]READ_REG_ADDR,
            ////////////////////////////////////////write config data
           output  reg CH1_CONFIG_WE,
           output  reg [7:0]CH1_CONFIG_ADDR,
           output  reg [7:0]CH1_CONFIG_DATA,
        
            output  reg CH2_CONFIG_WE,
            output  reg [7:0]CH2_CONFIG_ADDR,
            output  reg [7:0]CH2_CONFIG_DATA,
        
            output  reg SHARE_CONFIG_WE,
            output  reg [7:0]SHARE_CONFIG_ADDR,
            output  reg [7:0]SHARE_CONFIG_DATA
);

reg   [7:0]FPGA_ARM_DATA=8'd0;
reg   arm_fpga_ncs_r1=1'b1;
reg   arm_fpga_ncs_r2=1'b1;
reg   arm_fpga_nwe_r1=1'b1;
reg   arm_fpga_nwe_r2=1'b1;
reg   arm_fpga_nwe_r3=1'b1;
reg   arm_fpga_nwe_r4=1'b1;
reg   arm_fpga_noe_r1=1'b1;
reg   arm_fpga_noe_r2=1'b1;
reg   [3:0]arm_addr_sel_r1=4'd0;
reg   [3:0]arm_addr_sel_r2=4'd0;
reg   [7:0]arm_fpga_addr_r1=8'd0;
reg   [7:0]arm_fpga_addr_r2=8'd0;
reg   [7:0]arm_fpga_data_r1=8'd0;
reg   [7:0]arm_fpga_data_r2=8'd0;
reg   ddr3_ncs_r1=1'b1;
reg   ddr3_ncs_r2=1'b1;
reg   ddr3_nwe_r1=1'b1;
reg   ddr3_nwe_r2=1'b1;
reg   ddr3_nwe_r3=1'b1;
reg   ddr3_nwe_r4=1'b1;
reg   [3:0]ddr3_addr_sel_r1=4'd0;
reg   [3:0]ddr3_addr_sel_r2=4'd0;
reg   [7:0]ddr3_addr_r1=8'd0;
reg   [7:0]ddr3_addr_r2=8'd0;
reg   [7:0]ddr3_data_r1=8'd0;
reg   [7:0]ddr3_data_r2=8'd0;

assign   ARM_FPGA_DATA  =  (~(arm_fpga_ncs_r2  |  arm_fpga_noe_r2))  ?  FPGA_ARM_DATA  :  8'hzz;
////////////////////////////////////////////////////write config data
always@(posedge CLK_LOW)
begin
    arm_fpga_ncs_r1  <=  ARM_FPGA_nCS;
    arm_fpga_ncs_r2  <=  arm_fpga_ncs_r1;
    
    arm_fpga_nwe_r1  <=  ARM_FPGA_nWE;
    arm_fpga_nwe_r2  <=  arm_fpga_nwe_r1;
    arm_fpga_nwe_r3  <=  arm_fpga_nwe_r2;
    arm_fpga_nwe_r4  <=  arm_fpga_nwe_r3;
    
    arm_fpga_noe_r1  <=  ARM_FPGA_nOE;
    arm_fpga_noe_r2  <=  arm_fpga_noe_r1;
    
    arm_addr_sel_r1  <=  ARM_FPGA_ADDR[11:8];
    arm_addr_sel_r2  <=  arm_addr_sel_r1;
    
    arm_fpga_addr_r1  <=  ARM_FPGA_ADDR[7:0];
    arm_fpga_addr_r2  <=  arm_fpga_addr_r1;
    
    arm_fpga_data_r1  <=  ARM_FPGA_DATA;
    arm_fpga_data_r2  <=  arm_fpga_data_r1;
end

always@(posedge CLK_LOW)
begin
    if(arm_fpga_ncs_r2  ==  1'b0)begin
        case(arm_addr_sel_r2)
        4'd0: CH1_CONFIG_WE    <=  (~arm_fpga_nwe_r3)  &  arm_fpga_nwe_r4;
        4'd1: CH2_CONFIG_WE    <=  (~arm_fpga_nwe_r3)  &  arm_fpga_nwe_r4;
        4'd2: SHARE_CONFIG_WE  <=  (~arm_fpga_nwe_r3)  &  arm_fpga_nwe_r4;
        default: begin
                    CH1_CONFIG_WE    <=  1'b0;
                    CH2_CONFIG_WE    <=  1'b0;
                    SHARE_CONFIG_WE  <=  1'b0;
                 end
        endcase
    end
    else
        begin
           CH1_CONFIG_WE    <=  1'b0;
           CH2_CONFIG_WE    <=  1'b0;
           SHARE_CONFIG_WE  <=  1'b0;
        end
end

always@(posedge CLK_LOW)
begin
    CH1_CONFIG_ADDR      <=  arm_fpga_addr_r2;
    CH1_CONFIG_DATA      <=  arm_fpga_data_r2;
    
    CH2_CONFIG_ADDR      <=  arm_fpga_addr_r2;
    CH2_CONFIG_DATA      <=  arm_fpga_data_r2;
    
    SHARE_CONFIG_ADDR    <=  arm_fpga_addr_r2;
    SHARE_CONFIG_DATA    <=  arm_fpga_data_r2;
    
    READ_REG_ADDR        <=  arm_fpga_addr_r2;
    FPGA_ARM_DATA        <=  READ_BACK_DATA;
end
    

endmodule
