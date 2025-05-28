`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/29 09:14:02
// Design Name: 
// Module Name: UTG2000X_TOP_TB
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


module UTG2000X_TOP_TB( );

         reg    FPGA_REF_CLK;    // system clk 10MHz
         
         reg PLL_FPGA_CLK_P;  // pll clk 625MHz
         reg PLL_FPGA_CLK_N;
         wire FPGA_SYS_WORK;  // 上电状态灯
         // reg [2:0]HW_REV;    // 硬件版本
         //-------------------ARM通信接口
         reg   ARM_FPGA_nCS;
         // input  ARM_FPGA_CLK,
         // input  ARM_FPGA_NL,
         // input  ARM_FPGA_NWAIT,
         reg   ARM_FPGA_nWE;
         reg   ARM_FPGA_nOE;
         // input  ARM_FPGA_INIT,
         reg   [11:0]ARM_FPGA_ADDR;
         wire   [7:0]ARM_FPGA_DATA;
         
         //------------------- PLL配置接口
         // wire  PLL_nCS;
         // wire  PLL_SCLK;
         // wire  PLL_SDIO;
         // wire  PLL_REFCLK_SEL;
         // wire  PLL_HOLD_OVER;
         
         //------------------ 旋钮键盘灯接口
         // reg   [4:0]COLUMN;
         // wire  [5:0]ROW;
         // wire  KEY_CODE_INT;
         // reg   CODE_SWITCH_1;
         // reg   CODE_SWITCH_2;
         // wire  CH1_LED;
         // wire  CH2_LED;
         // wire  MODE_LED;
         // wire  SYNC_LED;
         // wire  POWER_LED;
         
         //----------------- 通道控制接口
         // reg   CH1_LOAD_PROTECT;
         // wire  CH1_ON_OFF;
         // wire  CH1_1_5;
         // wire  CH1_1_25;
         // wire  CH1_GAIN;
         // wire  CH1_1_16;
         
         // reg   CH2_LOAD_PROTECT;
         // wire  CH2_ON_OFF;
         // wire  CH2_1_5;
         // wire  CH2_1_25;
         // wire  CH2_GAIN;
         // wire  CH2_1_16;
         
         //----------------- AD9122配置接口
         // wire  AD9122_nCS,
         // wire  AD9122_SCLK,
         // wire  AD9122_SDIO,
         // output  AD9122_SDO,
         // wire  AD9122_nRESET,
         // input   AD9122_nIRQ,
         
         //--------------- 通道数据接口
         wire  CH_DAC_DCI_P;
         wire  CH_DAC_DCI_N;
         wire  [15:0]CH_DAC_DATA_P;
         wire  [15:0]CH_DAC_DATA_N;
         
         //-------------------- 直流偏移
         // wire CH_AUX_DAC_SCLK;
         // wire CH_AUX_DIN;
         // wire CH_AUX_nSYNC;
         
         //---------------- 同步通道接口
         // wire  CH_SYNC_CLK;
         // wire  [7:0]CH_SYNC_DATA;
         
         //----------------- 外部输入输出
         // wire  EXT_FSK_nOE;
         // reg   FSK_IN;
         // reg   COUNTER;
         // wire  EXT_TRIG_nOE;
         // wire  EXT_TRIG;
         // wire  EXT_IN_10M_nOE;
         // wire  EXT_OUT_10M_nOE;
         // reg   EXT_10M_INPUT;
         // wire  EXT_10M_OUTPUT;
         
         //----------------- 外部调制输入
         wire  ADC_nCS;
         wire  ADC_SCLK;
         reg   ADC_SDATA;
         
         //----------------- DDR3 接口
        //  wire   [15:0]ddr3_dq;
        //  wire   [1:0]ddr3_dqs_n;
        //  wire   [1:0]ddr3_dqs_p;
        // // Outputs
        //  wire  [12:0]ddr3_addr;
        //  wire  [2:0]ddr3_ba;
        //  wire  ddr3_ras_n;
        //  wire  ddr3_cas_n;
        //  wire  ddr3_we_n;
        //  wire  ddr3_reset_n;
        //  wire  [0:0]ddr3_ck_p;
        //  wire  [0:0]ddr3_ck_n;
        //  wire  [0:0]ddr3_cke;
        //  wire  [1:0]ddr3_dm;
        //  wire  [0:0]ddr3_odt;
        //  wire  init_calib_complete;
         


reg  [63:0]send_data2;
reg  [15:0]data;
reg  [7:0]arm_fpga_data_r;
wire  [7:0]recv_data;

assign  ARM_FPGA_DATA  = ARM_FPGA_nOE ? arm_fpga_data_r : 8'hzz;
assign  recv_data     = ~ARM_FPGA_nOE ? ARM_FPGA_DATA   : 8'hzz;


UTG2000X_TOP u_UTG2000X_TOP(
    .FPGA_REF_CLK        ( FPGA_REF_CLK        ),
    .PLL_FPGA_CLK_P      ( PLL_FPGA_CLK_P      ),
    .PLL_FPGA_CLK_N      ( PLL_FPGA_CLK_N      ),
    .FPGA_SYS_WORK       ( FPGA_SYS_WORK       ),
    // .HW_REV              ( HW_REV              ),
    .ARM_FPGA_nCS        ( ARM_FPGA_nCS        ),
    .ARM_FPGA_nWE        ( ARM_FPGA_nWE        ),
    .ARM_FPGA_nOE        ( ARM_FPGA_nOE        ),
    .ARM_FPGA_ADDR       ( ARM_FPGA_ADDR       ),
    .ARM_FPGA_DATA       ( ARM_FPGA_DATA       ),
    // .PLL_nCS             ( PLL_nCS             ),
    // .PLL_SCLK            ( PLL_SCLK            ),
    // .PLL_SDIO            ( PLL_SDIO            ),
    // .PLL_REFCLK_SEL      ( PLL_REFCLK_SEL      ),
    // .PLL_HOLD_OVER       ( PLL_HOLD_OVER       ),
    // .COLUMN              ( COLUMN              ),
    // .ROW                 ( ROW                 ),
    // .KEY_CODE_INT        ( KEY_CODE_INT        ),
    // .CODE_SWITCH_1       ( CODE_SWITCH_1       ),
    // .CODE_SWITCH_2       ( CODE_SWITCH_2       ),
    // .CH1_LED             ( CH1_LED             ),
    // .CH2_LED             ( CH2_LED             ),
    // .MODE_LED            ( MODE_LED            ),
    // .SYNC_LED            ( SYNC_LED            ),
    // .POWER_LED           ( POWER_LED           ),
    // .CH1_LOAD_PROTECT    ( CH1_LOAD_PROTECT    ),
    // .CH1_ON_OFF          ( CH1_ON_OFF          ),
    // .CH1_1_5             ( CH1_1_5             ),
    // .CH1_1_25            ( CH1_1_25            ),
    // .CH1_GAIN            ( CH1_GAIN            ),
    // .CH1_1_16            ( CH1_1_16            ),
    // .CH2_LOAD_PROTECT    ( CH2_LOAD_PROTECT    ),
    // .CH2_ON_OFF          ( CH2_ON_OFF          ),
    // .CH2_1_5             ( CH2_1_5             ),
    // .CH2_1_25            ( CH2_1_25            ),
    // .CH2_GAIN            ( CH2_GAIN            ),
    // .CH2_1_16            ( CH2_1_16            ),
    // .AD9122_nCS          ( AD9122_nCS          ),
    // .AD9122_SCLK         ( AD9122_SCLK         ),
    // .AD9122_SDIO         ( AD9122_SDIO         ),
    // .AD9122_nRESET       ( AD9122_nRESET       ),
    .CH_DAC_DCI_P        ( CH_DAC_DCI_P        ),
    .CH_DAC_DCI_N        ( CH_DAC_DCI_N        ),
    .CH_DAC_DATA_P       ( CH_DAC_DATA_P       ),
    .CH_DAC_DATA_N       ( CH_DAC_DATA_N       )
    // .CH_AUX_DAC_SCLK     ( CH_AUX_DAC_SCLK     ),
    // .CH_AUX_DIN          ( CH_AUX_DIN          ),
    // .CH_AUX_nSYNC        ( CH_AUX_nSYNC        ),
    // .CH_SYNC_CLK         ( CH_SYNC_CLK         ),
    // .CH_SYNC_DATA        ( CH_SYNC_DATA        ),
    // .EXT_FSK_nOE         ( EXT_FSK_nOE         ),
    // .FSK_IN              ( FSK_IN              ),
    // .COUNTER             ( COUNTER             ),
    // .EXT_TRIG_nOE        ( EXT_TRIG_nOE        ),
    // .EXT_TRIG            ( EXT_TRIG            ),
    // .EXT_IN_10M_nOE      ( EXT_IN_10M_nOE      ),
    // .EXT_OUT_10M_nOE     ( EXT_OUT_10M_nOE     ),
    // .EXT_10M_INPUT       ( EXT_10M_INPUT       ),
    // .EXT_10M_OUTPUT      ( EXT_10M_OUTPUT      ),
//     .ADC_nCS             ( ADC_nCS             ),
//     .ADC_SCLK            ( ADC_SCLK            ),
//     .ADC_SDATA           ( ADC_SDATA           )
    // .ddr3_dq             ( ddr3_dq             ),
    // .ddr3_dqs_n          ( ddr3_dqs_n          ),
    // .ddr3_dqs_p          ( ddr3_dqs_p          ),
    // .ddr3_addr           ( ddr3_addr           ),
    // .ddr3_ba             ( ddr3_ba             ),
    // .ddr3_ras_n          ( ddr3_ras_n          ),
    // .ddr3_cas_n          ( ddr3_cas_n          ),
    // .ddr3_we_n           ( ddr3_we_n           ),
    // .ddr3_reset_n        ( ddr3_reset_n        ),
    // .ddr3_ck_p           ( ddr3_ck_p           ),
    // .ddr3_ck_n           ( ddr3_ck_n           ),
    // .ddr3_cke            ( ddr3_cke            ),
    // .ddr3_dm             ( ddr3_dm             ),
    // .ddr3_odt            ( ddr3_odt            )
);

reg  CLK;

reg  [47:0]basic_freq1;
reg  [47:0]basic_freq2;

initial
begin
    FPGA_REF_CLK   =  1'b0;
    ARM_FPGA_nCS   =  1'b1;
    ARM_FPGA_nWE   =  1'b1;
    ARM_FPGA_nOE   =  1'b1;
    PLL_FPGA_CLK_P =  1'b1;
    PLL_FPGA_CLK_N =  1'b0;
    CLK            =  1'b0;

    basic_freq1           =  48'd9007199254740;
    basic_freq2           =  48'd9007199254740;

    #60000;
    fmc_send_cmd(12'h02D,8'hf); //打开通道
    fmc_send_cmd(12'h12D,8'hf); //打开通道

    fmc_send_cmd(12'h003,basic_freq1[ 7: 0]);
    fmc_send_cmd(12'h004,basic_freq1[15: 8]);
    fmc_send_cmd(12'h005,basic_freq1[23:16]);
    fmc_send_cmd(12'h006,basic_freq1[31:24]);
    fmc_send_cmd(12'h007,basic_freq1[39:32]);
    fmc_send_cmd(12'h008,basic_freq1[47:40]);
    fmc_send_cmd(12'h103,basic_freq2[ 7: 0]);
    fmc_send_cmd(12'h104,basic_freq2[15: 8]);
    fmc_send_cmd(12'h105,basic_freq2[23:16]);
    fmc_send_cmd(12'h106,basic_freq2[31:24]);
    fmc_send_cmd(12'h107,basic_freq2[39:32]);
    fmc_send_cmd(12'h108,basic_freq2[47:40]);
   
    fmc_send_cmd(12'h204,8'hf); //同步复位
    
    // 等待一段时间进行测试
    #100000;
    $display("\n继续PN3序列测试...");
    
    // 调整频率测试
    #100000;
    $display("\n测试不同频率的PN3序列...");
    basic_freq1 = 48'd4503599627370; // 降低频率
    fmc_send_cmd(12'h003,basic_freq1[ 7: 0]);
    fmc_send_cmd(12'h004,basic_freq1[15: 8]);
    fmc_send_cmd(12'h005,basic_freq1[23:16]);
    fmc_send_cmd(12'h006,basic_freq1[31:24]);
    fmc_send_cmd(12'h007,basic_freq1[39:32]);
    fmc_send_cmd(12'h008,basic_freq1[47:40]);


end

always  #50   FPGA_REF_CLK  =  ~FPGA_REF_CLK;
always  #0.8  PLL_FPGA_CLK_P = ~PLL_FPGA_CLK_P;
always  #0.8  PLL_FPGA_CLK_N = ~PLL_FPGA_CLK_N;
always  #0.4  CLK = ~CLK;

task fmc_send_cmd;//写入，频率为8M，模拟FMC通信
     input  [11:0]addr;
     input  [7:0]data;
     begin
        ARM_FPGA_nCS    <=  1'b0;
        ARM_FPGA_ADDR   <=  addr;
        #62.5;
        ARM_FPGA_nWE    <=  1'b0;
        arm_fpga_data_r  <=  data;
        #40;
        ARM_FPGA_nWE    <=  1'b1;
        #22.5;
        ARM_FPGA_nCS    <=  1'b1;
     end
endtask

task fmc_rec_cmd;//读取，频率为8M
     input  [11:0]addr;
     begin
        ARM_FPGA_nCS    <=  1'b0;
        ARM_FPGA_ADDR   <=  addr;
        #62.5;
        ARM_FPGA_nOE    <=  1'b0;
        #40;
        ARM_FPGA_nOE    <=  1'b1;
        #22.5;
        ARM_FPGA_nCS    <=  1'b1;
     end
endtask
reg [15:0]ch1_wave;

always@(posedge CH_DAC_DCI_N)
begin
     ch1_wave  <=   CH_DAC_DATA_P;
end
reg [15:0]ch2_wave;

always@(negedge CH_DAC_DCI_P)
begin
     ch2_wave  <=   CH_DAC_DATA_P;
end

// 添加监控信号
wire pn_data_out_ch1;
wire pn_data_out_ch2;
wire [2:0] pn_seed_ch1;
wire data_valid_ch1;
wire [31:0] rate_div_ch1;

// 监控PN3模块的信号和输出
initial begin
    // 使用force语句强制设置内部信号
    force u_UTG2000X_TOP.CH1_ON_OFF = 1'b1;
    $display("已强制设置CH1_ON_OFF为高电平");
    
    // 监控关键信号
    $monitor("Time=%t, pn_data_out_ch1=%b, pn_seed_ch1=%b, data_valid_ch1=%b, rate_div=%d", 
             $time, pn_data_out_ch1, pn_seed_ch1, data_valid_ch1, rate_div_ch1);
    
    // 直接设置rate_div为有效值
    #100;
    $display("设置rate_div为有效值...");
    force u_UTG2000X_TOP.pn3_generator_ch1.rate_div = 32'd1; // 设置为小值便于观察
    
    // 确保shift_reg和其他寄存器有初始值
    force u_UTG2000X_TOP.pn3_generator_ch1.shift_reg = 3'b001;
    force u_UTG2000X_TOP.pn3_generator_ch1.bit_counter = 2'b00;
    force u_UTG2000X_TOP.pn3_generator_ch1.rate_counter = 32'd0;
    
    // 重置一下信号来触发初始化
    force u_UTG2000X_TOP.CH1_SYNC = 1'b0;
    #100;
    force u_UTG2000X_TOP.CH1_SYNC = 1'b1;
    $display("重置完成，开始运行...");
end

// 将PN3模块的信号连接到测试平台
assign pn_data_out_ch1 = u_UTG2000X_TOP.pn_data_out_ch1;
assign pn_data_out_ch2 = u_UTG2000X_TOP.pn_data_out_ch2;
assign pn_seed_ch1 = u_UTG2000X_TOP.pn_seed_ch1;
assign data_valid_ch1 = u_UTG2000X_TOP.data_valid_ch1;
assign rate_div_ch1 = u_UTG2000X_TOP.pn3_generator_ch1.rate_div;

endmodule
