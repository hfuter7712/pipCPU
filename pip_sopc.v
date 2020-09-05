`include "de.v"
module pip_sopc(
  input wire clk,
  input wire rst
  );
  
  wire[`InstAddrBus] inst_addr;
  wire[`InstBus] inst;
  wire rom_ce;
  
  wire ram_ce;
  wire ram_we;
  wire[`DataAddrBus] ram_addr;
  wire[3:0] sel;
  wire[`DataBus] ram_data_o;
  wire[`DataBus] ram_data_i;
  
  pipCPU pipCPUo(
  .clk(clk),
  .rst(rst),
  .rom_data_i(inst),
  .rom_addr_o(inst_addr),
  .ram_data_i(ram_data_i),
  .ram_addr_o(ram_addr),
  .ram_data_o(ram_data_o),
  .ram_we_o(ram_we),
  .ram_sel_o(sel),
  .ram_ce_o(ram_ce),
  .rom_ce_o(rom_ce)
  );
  
  inst_rom inst_rom0(
  .ce(rom_ce),
  .addr(inst_addr),
  .inst(inst)
  );
  
  my_ram mr0(
  .clk(clk),
  .ce(ram_ce),
  .we(ram_we),
  .addr(ram_addr),
  .sel(sel),
  .data_i(ram_data_o),
  .data_o(ram_data_i)
  
  );
endmodule