`include "de.v"
module pipCPU(
  input wire clk,
  input wire rst,
  
  input wire[`RegBus] rom_data_i,
  output wire[`RegBus] rom_addr_o,
  
  input wire[`RegBus] ram_data_i,
  output wire[`RegBus] ram_addr_o,
  output wire[`RegBus] ram_data_o,
  output wire ram_we_o,
  output wire[3:0] ram_sel_o,
  output wire ram_ce_o,
  
  output wire rom_ce_o
  );
  
  wire[`InstAddrBus] pc;
  wire[`InstAddrBus] id_pc_i;
  wire[`InstBus] id_inst_i;
  
  wire[`AluOpBus] id_aluop_o;   //id阶段的运算符aluop
  wire[`AluSelBus] id_alusel_o;  //id阶段的运算符类型alusel
  wire[`RegBus] id_reg1_o;        //id时期的第一个源操作数
  wire[`RegBus] id_reg2_o;       //id时期的第二个源操作数
  wire id_wreg_o;                       //是否有要写入的寄存器
  wire[`RegAddrBus] id_wd_o;//写入寄存器地址
  
  wire[`AluOpBus] ex_aluop_i;   //ex阶段的运算符aluop
  wire[`AluSelBus] ex_alusel_i;   //ex阶段的运算符alusel
  wire[`RegBus] ex_reg1_i;         //ex阶段的第一个源操作数
  wire[`RegBus] ex_reg2_i;         //ex阶段的第二个源操作数
  wire ex_wreg_i;                        
  wire[`RegAddrBus] ex_wd_i; 
  
  wire[`RegBus] ex_lo_i;             
  wire[`RegBus] ex_hi_i;
  wire ex_whilo_i;
  
   wire[`RegBus] ex_lo_o;
  wire[`RegBus] ex_hi_o;
  wire ex_whilo_o;
  
  wire ex_wreg_o;
  wire[`RegAddrBus] ex_wd_o;
  wire[`RegBus] ex_wdata_o;
  
  wire mem_wreg_i;
  wire[`RegAddrBus] mem_wd_i;
  wire[`RegBus] mem_wdata_i;
  
  wire[`RegBus] mem_lo_i;
  wire[`RegBus] mem_hi_i;
  wire mem_whilo_i;
  
   wire[`RegBus] mem_lo_o;
  wire[`RegBus] mem_hi_o;
  wire mem_whilo_o;
  
  wire mem_wreg_o;
  wire[`RegAddrBus] mem_wd_o;
  wire[`RegBus] mem_wdata_o;
  
  wire wb_wreg_i;
  wire[`RegAddrBus] wb_wd_i;
  wire[`RegBus] wb_wdata_i;
  
  wire[`RegBus] wb_lo_i;
  wire[`RegBus] wb_hi_i;
  wire wb_whilo_i;
  
  wire[`RegBus] wb_lo_o;
  wire[`RegBus] wb_hi_o;
  wire wb_whilo_o;
  
  wire reg1_read;
  wire reg2_read;
  wire[`RegBus] reg1_data;
  wire[`RegBus] reg2_data;
  wire[`RegAddrBus] reg1_addr;
  wire[`RegAddrBus] reg2_addr;
  
  wire stall_id;
  wire stall_ex;
  wire[5:0] stall;
  
  wire[`DoubleRegBus] hilo_temp;
  wire[1:0] cnt;
  
  wire[`DoubleRegBus] hilo_temp2;
  wire[1:0] cnt2;
  
  
  wire signed_div;
  wire[31:0] div_opdata1;
  wire[31:0] div_opdata2;
  wire div_start;
  wire annul_i;
    
   wire[63:0] div_result;
   wire div_ready;
   
   
   wire branch_flag;
   wire[`RegBus] branch_target_address;
   wire whetherIn_Delayslot;
   wire next_inst_delayslot;
   
   wire [`RegBus] id_link_addr;
   wire id_is_in_delayslot;
   wire id_next_inst_in_delayslot;
   
   
   wire [`RegBus] ex_link_addr;
   wire ex_is_in_delayslot;
   wire ex_next_inst_in_delayslot;
   
   wire[`InstBus] id_ex_inst;
   wire[`InstBus] ex_inst;
   
   wire[`AluOpBus] ex_mem_aluop;
   wire[`RegBus] ex_mem_addr;
   wire[`RegBus] ex_mem_reg2;
   
   wire[`AluOpBus] mem_aluop;
   wire[`RegBus] mem_addr;
   wire[`RegBus] mem_reg2;
  
  pc_reg pc_reg0(
  .clk(clk), .rst(rst),.stall(stall),
  .branch_flag_i(branch_flag),.branch_target_address_i(branch_target_address),
   .pc(pc), .ce(rom_ce_o)
);  


  assign rom_addr_o = pc;
  
  if_id if_id0(
    .clk(clk), .rst(rst), .if_pc(pc),
    .if_inst(rom_data_i), .stall(stall),
     .id_pc(id_pc_i),
    .id_inst(id_inst_i)
    );
    
    
    
   id id0( 
    .rst(rst), .pc_i(id_pc_i), .inst_i(id_inst_i),
    .reg1_data_i(reg1_data), .reg2_data_i(reg2_data),
    .ex_wreg_i(ex_wreg_o),.ex_wdata_i(ex_wdata_o), .ex_wd_i(ex_wd_o),
    .mem_wreg_i(mem_wreg_o),.mem_wdata_i(mem_wdata_o),.mem_wd_i(mem_wd_o),
    
    .whetherIn_Delayslot_i(ex_next_inst_in_delayslot), 
    .branch_flag_o(branch_flag), .branch_target_address_o(branch_target_address), .whetherIn_Delayslot_o(),
    .link_addr_o(id_link_addr), .next_inst_delayslot_o(id_next_inst_in_delayslot),
    
    .reg1_read_o(reg1_read), .reg2_read_o(reg2_read),
    .reg1_addr_o(reg1_addr), .reg2_addr_o(reg2_addr),
    
    .aluop_o(id_aluop_o), .alusel_o(id_alusel_o),
    .reg1_o(id_reg1_o), .reg2_o(id_reg2_o),
    .wd_o(id_wd_o), .wreg_o(id_wreg_o),
    . id_stall(stall_id),
    
    .inst_o(id_ex_inst)
    
    );
  
  
  regfile regfile1(
  .clk(clk), .rst(rst),
  .we(wb_wreg_i), .waddr(wb_wd_i),
  .wdata(wb_wdata_i), .re1(reg1_read),
  .raddr1(reg1_addr), .rdata1(reg1_data),
  .re2(reg2_read), .raddr2(reg2_addr),
  .rdata2(reg2_data)
  );
  
  
  id_ex id_ex0(
  .clk(clk),
  .rst(rst),
  .id_aluop(id_aluop_o),
  .id_alusel(id_alusel_o),
  .id_reg1(id_reg1_o),
  .id_reg2(id_reg2_o),
  .id_wd(id_wd_o),
  .id_wreg(id_wreg_o),
  .stall(stall),
  
  .id_link_address(id_link_addr),
  .id_is_in_delayslot(id_is_in_delayslot),
  .next_inst_in_delayslot_i(id_next_inst_in_delayslot),
  .id_inst(id_ex_inst),
  .ex_inst(ex_inst),
  
  .ex_link_address(ex_link_addr),
  .ex_is_in_delayslot(ex_is_in_delayslot),
  .is_in_delayslot_o(ex_next_inst_in_delayslot),

  .ex_aluop(ex_aluop_i),
  .ex_alusel(ex_alusel_i),
  .ex_reg1(ex_reg1_i),
  .ex_reg2(ex_reg2_i),
  .ex_wd(ex_wd_i),
  .ex_wreg(ex_wreg_i)
  );

  ALU ALU0(
  .rst(rst),
  .aluop_i(ex_aluop_i), .alusel_i(ex_alusel_i),
  .reg1_i(ex_reg1_i), .reg2_i(ex_reg2_i),
  .wd_i(ex_wd_i), .wreg_i(ex_wreg_i),
  
  .hi_i(ex_hi_i), .lo_i(ex_lo_i),
  .wb_hi_i(wb_hi_o), .wb_lo_i(wb_lo_o), .wb_whilo_i(wb_whilo_o),
  .mem_hi_i(mem_hi_o), .mem_lo_i(mem_lo_o), .mem_whilo_i(mem_whilo_o),
  .hilo_temp_i(hilo_temp), .cnt_i(cnt),
  
  .div_result_i(div_result),.div_ready_i(div_ready),
  
  .link_address_i(ex_link_addr),.is_in_delayslot_i(ex_next_inst_in_delayslot),
 
  .inst_i(ex_inst),
  .aluop_o(ex_mem_aluop),
  .mem_addr_o(ex_mem_addr),
  .reg2_o(ex_mem_reg2), 

  
  .div_opdata1_o(div_opdata1),.div_opdata2_o(div_opdata2),
  .div_start_o(div_start),.signed_div_o(signed_div),
  
  .hilo_temp_o(hilo_temp2), .cnt_o(cnt2),
  .hi_o(ex_hi_o), .lo_o(ex_lo_o), .whilo_o(ex_whilo_o),
  
 
  .wd_o(ex_wd_o), .wreg_o(ex_wreg_o),
  .wdata_o(ex_wdata_o),
  .ex_stall(stall_ex)
  );
  
  ex_mem ex_mem0(
  .clk(clk),
  .rst(rst),
  .ex_wd(ex_wd_o),
  .ex_wreg(ex_wreg_o),
  .ex_wdata(ex_wdata_o),
  .ex_hi(ex_hi_o),
  .ex_lo(ex_lo_o),
  .ex_whilo(ex_whilo_o),
  .stall(stall),
  .hilo_i(hilo_temp2),.cnt_i(cnt2),
  
  .ex_aluop(ex_mem_aluop),
  .ex_mem_addr(ex_mem_addr),
  .ex_reg2(ex_mem_reg2),
  
  .mem_aluop(mem_aluop),
  .mem_mem_addr(mem_addr),
  .mem_reg2(mem_reg2),
  
  .hilo_o(hilo_temp),.cnt_o(cnt),
  
  .mem_wd(mem_wd_i),
  .mem_wreg(mem_wreg_i),
  .mem_wdata(mem_wdata_i),
  .mem_whilo(mem_whilo_i),
  .mem_hi(mem_hi_i),
  .mem_lo(mem_lo_i)
  );
  
  
  mem mem0(
  .rst(rst),

  .wd_i(mem_wd_i), .wreg_i(mem_wreg_i),
  .wdata_i(mem_wdata_i),
  .hi_i(mem_hi_i), .lo_i(mem_lo_i),
  .whilo_i(mem_whilo_i),
  
  .aluop_i(mem_aluop),
  .mem_addr_i(mem_addr),
  .reg2_i(mem_reg2),
  .mem_data_i(ram_data_i),
  
  .mem_addr_o(ram_addr_o),
  .mem_we_o(ram_we_o),
  .mem_sel_o(ram_sel_o),
  .mem_data_o(ram_data_o),
  .mem_ce_o(ram_ce_o),
  
  .wd_o(mem_wd_o),  .wreg_o(mem_wreg_o),
  .wdata_o(mem_wdata_o),
  .hi_o(mem_hi_o),
  .lo_o(mem_lo_o),
  .whilo_o(mem_whilo_o)
  );
  
  mem_wb mem_wb0(
  .clk(clk),
  .rst(rst),
  .mem_wd(mem_wd_o), .mem_wreg(mem_wreg_o),
  .mem_wdata(mem_wdata_o),
  .mem_hi(mem_hi_o),
  .mem_lo(mem_lo_o),
  .mem_whilo(mem_whilo_o),
  .stall(stall),
  
  .wb_wd(wb_wd_i), .wb_wreg(wb_wreg_i),
  .wb_wdata(wb_wdata_i),
  .wb_hi(wb_hi_i),
  .wb_lo(wb_lo_i),
  .wb_whilo(wb_whilo_i)
  );
  
  hilo_reg hr1(
  .clk(clk),
  .rst(rst),
  .we(wb_whilo_i), .hi_i(wb_hi_i), .lo_i(wb_lo_i),
  .hi_o(ex_hi_i),.lo_o(ex_lo_i)
  );
  
  ctrl _ct1(
  .rst(rst),
  .stall_id(stall_id),
  .stall_ex(stall_ex),
  .stall(stall)
  );

   
   
div div0(
 .clk(clk),
 .rst(rst),
 
 .signed_div_i(signed_div),
 .opdata1_i(div_opdata1),
 .opdata2_i(div_opdata2),
 .start_i(div_start),
 .annul_i(1'b0),
 
 .result_o(div_result),
 .ready_o(div_ready)
 );
endmodule
  
  
  

  
  
  