`include "de.v"
module if_id(
  input wire clk,
  input wire rst,
  input wire[`InstAddrBus] if_pc,    //ȡָ�׶ε�pc
  input wire[`InstBus] if_inst,           //ȡָ�׶ε�ָ��
   input wire[5:0] stall,                  //��ͣ����
  output reg[`InstAddrBus] id_pc, //����׶ε�pc
  output reg[`InstBus] id_inst          //����׶ε�pc
  
  );
  //�൱�ڽ�ȡָ�׶εĲ��ֲ������ݵ�����׶�
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
