`include "de.v"
module if_id(
  input wire clk,
  input wire rst,
  input wire[`InstAddrBus] if_pc,    //取指阶段的pc
  input wire[`InstBus] if_inst,           //取指阶段的指令
   input wire[5:0] stall,                  //暂停序列
  output reg[`InstAddrBus] id_pc, //译码阶段的pc
  output reg[`InstBus] id_inst          //译码阶段的pc
  
  );
  //相当于将取指阶段的部分参数传递到译码阶段
  always @(posedge clk) begin
    if(rst == `RstEnable || (stall[1] == `Stop && stall[2] == `NotStop))begin
      id_pc <= `ZeroWord;
      id_inst <= `ZeroWord;
    end else if(stall[1] == `NotStop) begin
      id_pc <= if_pc;
      id_inst <= if_inst;
    end
  end
endmodule
