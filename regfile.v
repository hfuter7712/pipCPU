`include "de.v"
module regfile(
  input wire clk,
  input wire rst,
  
  input wire we,
  input wire[`RegAddrBus] waddr,    //write to where?
  input wire[`RegBus] wdata,        //data to write
  
  input wire re1,
  input wire[`RegAddrBus] raddr1,   //read where?
  output reg[`RegBus] rdata1,       //data to read
  
  input wire re2,
  input wire[`RegAddrBus] raddr2,
  output reg[`RegBus] rdata2
  );
  
  reg[`RegBus] regs[0:`RegNum-1];   //register group
  
   always @(posedge clk) begin
    if(rst == `RstDisable) begin
      if((we == `WriteEnable) && (waddr != `RegNumLog2'b0)) begin
        regs[waddr] <= wdata;
      end
    end
  end
  
  always @ (*) begin
    if(rst == `RstEnable) begin
      rdata1 <= `ZeroWord;
    end else if(raddr1 == `RegNumLog2'h0) begin
      rdata1 <= `ZeroWord;
    end else if((raddr1 == waddr) && (we == `WriteEnable)&&(re1 == `ReadEnable)) begin
      rdata1 <= wdata;
    end else if(re1 == `ReadEnable) begin
      rdata1 <= regs[raddr1];
    end else begin
      rdata1 <= `ZeroWord;
    end
  end
  
  
  always @ (*) begin
    if(rst == `RstEnable) begin
      rdata2 <= `ZeroWord;
    end else if(raddr2 == `RegNumLog2'h0) begin
      rdata2 <= `ZeroWord;
    end else if((raddr2 == waddr) && (we == `WriteEnable)&&(re2 == `ReadEnable)) begin
      rdata2 <= wdata;
    end else if(re2 == `ReadEnable) begin
      rdata2 <= regs[raddr2];
    end else begin
      rdata2 <= `ZeroWord;
    end
  end
endmodule
  
      