`include "de.v"
module pc_reg(
  input wire clk,
  input wire rst,
  input wire[5:0] stall,                  //��ͣ����
  input wire branch_flag_i,
  input wire[`RegBus] branch_target_address_i,
  output reg[`InstAddrBus]pc,
  output reg ce
  
  );
  //��ÿ�������ض����м�飬һ����������ʹ��rstΪ������������
  always @ (posedge clk) begin
    if(rst == `RstEnable)begin
      ce <= `ChipDisable;
    end else begin
      ce <= `ChipEnable;
    end
  end
  //��ÿ�������ض����м�飬һ������ceΪChipDisable���̽�pc���㣬����ÿ�ν�pc+4
  always @ (posedge clk)begin
    if (ce == `ChipDisable) begin
      pc<= 32'h00000000;
    end else if(stall[0] == `NotStop) begin
        if(branch_flag_i == `Branch) begin
            pc <= branch_target_address_i;
         end else begin
      pc<=pc+4'h4;
      end
    end
  end
endmodule

    