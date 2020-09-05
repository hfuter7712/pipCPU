`include "de.v"

//`timescale 1ns/1ps

module pip_CPU_tb();
  
  reg CLOCK_50;
  reg rst;
  
  initial begin
    CLOCK_50 = 1'b0;
    forever #10 CLOCK_50 = ~CLOCK_50;     //每10ns时钟信号翻转
  end
  //初始化重置，190ns后rst禁止(停止重置)
  initial begin
    rst = `RstEnable;
    #190 rst = `RstDisable;
    
    #4000 $stop;
  end
  
  pip_sopc pip_sopc0(
  .clk(CLOCK_50),
  .rst(rst)
  );
  
endmodule
