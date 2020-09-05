`include "de.v"
module pc_reg(
  input wire clk,
  input wire rst,
  input wire[5:0] stall,                  //暂停序列
  input wire branch_flag_i,
  input wire[`RegBus] branch_target_address_i,
  output reg[`InstAddrBus]pc,
  output reg ce
  
  );
  //在每个上升沿都进行检查，一旦发现重置使能rst为真则立即重置
  always @ (posedge clk) begin
    if(rst == `RstEnable)begin
      ce <= `ChipDisable;
    end else begin
      ce <= `ChipEnable;
    end
  end
  //在每个上升沿都进行检查，一旦发现ce为ChipDisable立刻将pc归零，否则每次将pc+4
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

    