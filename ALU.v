`include "de.v"

module ALU(
  input wire rst,
  
  input wire[`AluOpBus] aluop_i,        //alu运算符
  input wire[`AluSelBus] alusel_i,       //alu运算符类型
  input wire[`RegBus] reg1_i,            //参与运算的源操作数1
  input wire[`RegBus] reg2_i,           //参与运算的源操作数2
  input wire[`RegAddrBus] wd_i,     //要写入寄存器的地址
  input wire wreg_i,                           //是否有写入操作

  input wire[`RegBus] hi_i,               // HI的输入数
  input wire[`RegBus] lo_i,              // LO的输入数
  
  input wire[`RegBus] wb_hi_i,       //从写回阶段传回来的hi_i值
  input wire[`RegBus] wb_lo_i,      //从写回阶段传回来的lo_i值
  input wire wb_whilo_i,
  
  input wire[`RegBus] mem_hi_i,      //从访存阶段传回来的hi_i值
  input wire[`RegBus] mem_lo_i,      //从访存阶段传回来的hi_i值
  input wire mem_whilo_i,                //从访存阶段传回来的是否要写hi,lo标志
  
  input wire[`DoubleRegBus] hilo_temp_i,    //第一个执行周期得到的乘法结果
  input wire[1:0] cnt_i,                                      //当前处于第几个时钟周期

  input wire[`DoubleRegBus] div_result_i,     //除法运算的结果
  input wire div_ready_i,                     //除法运算是否结束
  
  input wire[`RegBus] link_address_i,         
  input wire is_in_delayslot_i,
  
  input wire[`RegBus] inst_i,                  //当前处于执行阶段的指令
  
  output wire[`AluOpBus] aluop_o,              //执行阶段的指令要进行的运算子类型
  output wire[`RegBus] mem_addr_o,             //加载，存储指令对应的存储器地址
  output wire[`RegBus] reg2_o,                 //存储指令要存储的数据等

  output reg[`RegBus] div_opdata1_o,          //被除数
  output reg[`RegBus] div_opdata2_o,          //除数
  output reg div_start_o,                     //是否开始除法运算
  output reg signed_div_o,                    //是否有符号除法

  output reg[`DoubleRegBus] hilo_temp_o,  //第一个执行周期得到的乘法结果
  output reg[1:0] cnt_o,                                     //下一个时钟周期处于执行阶段的第几个时钟周期
  
  output reg[`RegBus] hi_o,               
  output reg[`RegBus] lo_o,
  output reg whilo_o,
  
  output reg[`RegAddrBus] wd_o,    //要写入数据的寄存器地址
  output reg wreg_o,                          //是否有写入寄存器操作
  output reg[`RegBus] wdata_o,       //要写入的数据
  output reg ex_stall
  );
  
  reg[`RegBus] logicout;                  //逻辑运算结果
  reg[`RegBus] algcout;                   //算术运算结果
  reg[`RegBus] moveres;        
  reg[`RegBus] HI;                           
  reg[`RegBus] LO;
  
  wire ov_sum;                                  //保存溢出情况
  wire[`RegBus] res_sum;                 //保存加法结果
  wire[`RegBus] res_sub;                
  wire[`RegBus] res_not;
  wire[`DoubleRegBus] res_mul_temp;     //临时保存乘法结果
  reg[`DoubleRegBus] res_mul;               //保存乘法结果
  wire[`RegBus] reg1_i_mux;                    //保存乘法运算的第一个操作数
  wire[`RegBus] reg2_i_mux;                   //保存乘法运算的第二个操作数
  wire reg1_eq_reg2;                              //第一个操作数是否等于第二个操作数
  wire reg1_lt_reg2;                                //第一个操作数是否小于第二个操作数
  
  reg[`DoubleRegBus] hilo_temp1;
  reg madd_msub_stall;
  
  
  //如果运算符为SUB,SUBU或者SLT，就将reg2_i_mux初始化为其补码，之后只要调用加法相关操作即可
 assign reg2_i_mux = ((aluop_i == `EXE_SUB_OP) || 
 (aluop_i == `EXE_SUBU_OP) || 
 (aluop_i == `EXE_SLT_OP)) ? (~reg2_i)+1 : reg2_i;
 
//计算结果
 assign res_sum = reg1_i + reg2_i_mux;
 
  //如何判断是否溢出？ 如果两个正数相加为负数，或者两个负数之和为正数，即可视为溢出
 //是否溢出判断
 assign ov_sum = ((!reg1_i[31] && !reg2_i_mux[31] && res_sum[31])|| (reg1_i[31] && reg2_i_mux[31] && !res_sum[31]));
 
 //SLT与SLTU运算符，如果SLT的话需要判断符号，而如果SLTU无符号的话直接进行比较就行了
assign  reg1_lt_reg2 = (aluop_i == `EXE_SLT_OP) ? ((reg1_i[31] && !reg2_i[31]) || (!reg1_i[31] && !reg2_i[31] && res_sum[31]) || (reg1_i[31] && reg2_i[31] && res_sum[31])) : (reg1_i < reg2_i);
 
//取反用于算符CLO
 assign res_not = ~reg1_i;
 
 
 assign aluop_o = aluop_i;
 assign mem_addr_o = reg1_i + {{16{inst_i[15]}}, inst_i[15:0]};
 assign reg2_o = reg2_i;
  
  //关于HI和LO的数据前推
  always @(*) begin
    if(rst == `RstEnable) begin
      HI <= `ZeroWord;
      LO <= `ZeroWord;
    end else if(mem_whilo_i == `WriteEnable) begin
      HI <= mem_hi_i;
      LO <= mem_lo_i;
    end else if(wb_whilo_i == `WriteEnable) begin
      HI <= wb_hi_i;
      LO <= wb_lo_i;
    end else begin
      HI <= hi_i;
      LO <= lo_i;
    end
  end
  
  
  always @(*) begin
  if(rst == `RstEnable)begin
    moveres <= `ZeroWord;
  end else begin
    moveres <= `ZeroWord;
    case(aluop_i)
      `EXE_MOVN_OP:begin
        moveres <= reg1_i;
      end
      `EXE_MOVZ_OP:begin
        moveres <= reg1_i;
      end
      `EXE_MFHI_OP:begin
        moveres <= HI;
      end
      `EXE_MFLO_OP:begin
        moveres <= LO;
      end
      default:begin
      end
    endcase
  end
end
  
  always @ (*) begin
    if(rst == `RstEnable) begin
      logicout <= `ZeroWord;
    end else begin
    case(alusel_i)
    `EXE_RES_BRANCH: begin
        wdata_o <= link_address_i;
        end
    `EXE_RES_LOGIC: begin
      case(aluop_i)
        `EXE_OR_OP : begin
          logicout <= reg1_i | reg2_i;
        end
        `EXE_AND_OP : begin
          logicout <= reg1_i & reg2_i;
        end
        `EXE_XOR_OP : begin
          logicout <= reg1_i ^ reg2_i;
        end
        `EXE_NOR_OP : begin
          logicout <= ~(reg1_i | reg2_i);
        end
        default: begin
          logicout <= `ZeroWord;
        end
      endcase   // case(aluop_i)
       wdata_o <= logicout;
    end  // `EXE_RES_LOGIC: begin
    `EXE_RES_SHIFT:begin
      case(aluop_i)
        `EXE_SLL_OP:begin
          logicout <= reg1_i << reg2_i;
        end
        `EXE_SRL_OP:begin
          logicout <= reg1_i >> reg2_i;
        end
        `EXE_SRA_OP:begin
          if(reg1_i[31:31] == 1'b1) begin
          logicout <= (reg1_i >> reg2_i) | (32'hfffffff << (32 - reg2_i));
        end 
      else begin
        logicout <= (reg1_i >> reg2_i);
      end
    end
  endcase
  wdata_o <= logicout;
end
`EXE_RES_ALG:begin
  case(aluop_i)
    `EXE_ADD_OP, `EXE_ADDU_OP, `EXE_ADDI_OP, `EXE_ADDIU_OP:begin            //所有的加法运算符
      algcout <=res_sum;
    end
    `EXE_SUB_OP, `EXE_SUBU_OP:begin                                                                         //所有的减法运算符
        algcout <=res_sum;
    end
    `EXE_SLT_OP, `EXE_SLTU_OP:begin                                                                           //比较运算
      algcout <= reg1_lt_reg2 ;
    end  
  endcase
   wd_o <= wd_i;
  if(((aluop_i == `EXE_ADD_OP) || (aluop_i == `EXE_ADDI_OP) || (aluop_i == `EXE_SUB_OP))&& (ov_sum == 1'b1)) begin
    wreg_o <= `WriteDisable;
    end else begin
    wreg_o <= wreg_i;
  end
  wdata_o <= algcout;
end
`EXE_RES_MOVE:begin
  wdata_o = moveres;
end

 
    `EXE_RES_LUI: begin
      wdata_o <= reg1_i;
    end
    default:  begin
    wdata_o <= `ZeroWord;
    end
  endcase // case(alusel_i)
end         //end else begin
end        //always @ (*) begin




//乘法运算第一个源操作数      
assign reg1_i_mux = (((aluop_i==`EXE_MUL_OP) || (aluop_i==`EXE_MULT_OP)||(aluop_i == `EXE_MADD_OP) ||(aluop_i == `EXE_MSUB_OP)) && (reg1_i[31] == 1'b1)) ? (~reg1_i+1) : reg1_i;
//乘法运算第二个源操作数 
assign reg2_i_mux = (((aluop_i==`EXE_MUL_OP) || (aluop_i==`EXE_MULT_OP)||(aluop_i == `EXE_MADD_OP) ||(aluop_i == `EXE_MSUB_OP)) && (reg2_i[31] == 1'b1)) ? (~reg2_i+1) : reg2_i;

assign res_mul_temp = reg1_i_mux * reg2_i_mux;

//乘法后期处理
always @ (*) begin
if(rst == `RstEnable) begin                     //如果rst为0将结果设置为全0
 res_mul <={`ZeroWord, `ZeroWord};
 end else if((aluop_i == `EXE_MULT_OP) || (aluop_i == `EXE_MUL_OP)||(aluop_i == `EXE_MADD_OP) ||(aluop_i == `EXE_MSUB_OP))
 begin
 if(reg1_i[31] ^ reg2_i[31] == 1'b1) begin          //如果两个源操作数符号不相等，说明结果为负数，要将结果取反+1（求补码）
 res_mul <= ~res_mul_temp +1;
 end else begin
 res_mul = res_mul_temp;                                    //否则结果就为临时结果
 end
 end else begin
  res_mul = res_mul_temp;
  end
  end
  
  //MADD,MADDU,MSUB,MSUBU指令
  always @(*) begin
  if(rst == `RstEnable) begin
  hilo_temp_o <={`ZeroWord, `ZeroWord};
  cnt_o <= 2'b00;
  madd_msub_stall <= `NotStop;
  end else begin
    case (aluop_i)
        `EXE_MADD_OP, `EXE_MADDU_OP : begin
            if(cnt_i == 2'b00)begin
                hilo_temp_o <= res_mul;                         //将计算结果赋给hilo_temp_o
                cnt_o <= 2'b01;                                         //计算完成，进入下一个阶段
                hilo_temp1 <={`ZeroWord, `ZeroWord};
                madd_msub_stall <= `Stop;                   //暂停
                end else if(cnt_i == 2'b01) begin          //进入第二阶段
                hilo_temp_o <={`ZeroWord, `ZeroWord};
                cnt_o <= 2'b10;                                         
                hilo_temp1 <= hilo_temp_i + {HI,LO};    //乘累加运算
                 madd_msub_stall <= `NotStop;              //因为运算已经完成，不暂停
                end
        end
        `EXE_MSUB_OP,`EXE_MSUBU_OP:begin
         if(cnt_i == 2'b00)begin
                hilo_temp_o <= ~res_mul + 1;                //将运算结果转化为补码(便于减法)
                cnt_o <= 2'b01;
                hilo_temp1 <={`ZeroWord, `ZeroWord};
                madd_msub_stall <= `Stop;
                end else if(cnt_i == 2'b01) begin
                hilo_temp_o <={`ZeroWord, `ZeroWord};
                cnt_o <= 2'b10;
                hilo_temp1 <= hilo_temp_i + {HI,LO};
        
                 madd_msub_stall <= `NotStop;
                end
        end
        default: begin
         hilo_temp_o <={`ZeroWord, `ZeroWord};
         cnt_o <= 2'b00;
         madd_msub_stall <= `NotStop;
         end
         endcase
  end
  end
  

  
  
  always @ (*) begin
  wd_o <= wd_i;
    case(alusel_i)
    `EXE_RES_MUL: begin
        wdata_o <= res_mul[31:0];
        end
        endcase
    end
    
    reg div_stall;
    
    always @ (*) begin
    if(rst == `RstEnable) begin
        div_stall <= `NotStop;
        div_opdata1_o <= `ZeroWord;
        div_opdata2_o <= `ZeroWord;
        div_start_o <= `DivStop;
        signed_div_o <= 1'b0;
        end else begin
        div_stall <= `NotStop;
        div_opdata1_o <= `ZeroWord;
        div_opdata2_o <= `ZeroWord;
        div_start_o <= `DivStop;
        signed_div_o <= 1'b0;
        case(aluop_i)
            `EXE_DIV_OP: begin
                if(div_ready_i == `DivResultNotReady) begin
                    div_stall <= `Stop;
                    div_opdata1_o <= reg1_i;
                    div_opdata2_o <= reg2_i;
                    div_start_o <= `DivStart;
                    signed_div_o <= 1'b1;
                 end else if(div_ready_i == `DivResultReady) begin
                    div_stall <= `NotStop;
                    div_opdata1_o <= reg1_i;
                    div_opdata2_o <= reg2_i;
                    div_start_o <= `DivStop;
                    signed_div_o <= 1'b1;
                  end else begin
                    div_stall <= `NotStop;
                    div_opdata1_o <= `ZeroWord;
                    div_opdata2_o <= `ZeroWord;
                    div_start_o <= `DivStop;
                    signed_div_o <= 1'b0;
                   end
               end
            `EXE_DIVU_OP: begin
                if(div_ready_i == `DivResultNotReady) begin
                    div_stall <= `Stop;
                    div_opdata1_o <= reg1_i;
                    div_opdata2_o <= reg2_i;
                    div_start_o <= `DivStart;
                    signed_div_o <= 1'b0;
                 end else if(div_ready_i == `DivResultReady) begin
                    div_stall <= `NotStop;
                    div_opdata1_o <= reg1_i;
                    div_opdata2_o <= reg2_i;
                    div_start_o <= `DivStop;
                    signed_div_o <= 1'b0;
                  end else begin
                    div_stall <= `NotStop;
                    div_opdata1_o <= `ZeroWord;
                    div_opdata2_o <= `ZeroWord;
                    div_start_o <= `DivStop;
                    signed_div_o <= 1'b0;
                   end
               end
              default: begin 
              end
              endcase     
    end
    end
    
   //将madd_msub_stall值赋给 ex_stall
  always @ (*) begin 
  ex_stall = madd_msub_stall || div_stall;
  end
        

//关于HI,LO寄存器的后续处理
always @(*) begin
  if(rst == `RstEnable)begin
    whilo_o <= `WriteDisable;
    hi_o <= `ZeroWord;
    lo_o <= `ZeroWord;
    end else if((aluop_i == `EXE_MSUB_OP) || (aluop_i == `EXE_MSUBU_OP)) begin
   whilo_o <= `WriteEnable;
    hi_o <=hilo_temp1[63:32];
    lo_o <= hilo_temp1[31:0];
    end else if((aluop_i == `EXE_MADD_OP) || (aluop_i == `EXE_MADDU_OP)) begin
   whilo_o <= `WriteEnable;
    hi_o <=hilo_temp1[63:32];
    lo_o <= hilo_temp1[31:0];
   end else if((aluop_i == `EXE_MULT_OP) || (aluop_i == `EXE_MULTU_OP)) begin
   whilo_o <= `WriteEnable;
    hi_o <=res_mul[63:32];
    lo_o <= res_mul[31:0];
   end else if((aluop_i == `EXE_DIV_OP) || (aluop_i == `EXE_DIVU_OP)) begin
   whilo_o <= `WriteEnable;
    hi_o <=div_result_i[63:32];
    lo_o <= div_result_i[31:0];
  end else if(aluop_i == `EXE_MTHI_OP) begin
    whilo_o <= `WriteEnable;
    hi_o <= reg1_i;
    lo_o <= LO;
  end else if(aluop_i == `EXE_MTLO_OP) begin
    whilo_o <= `WriteEnable;
    hi_o <= HI;
    lo_o <= reg1_i; 
  end else begin
    whilo_o <= `WriteDisable;
    hi_o <= `ZeroWord;
    lo_o <= `ZeroWord;
  end
end 

  always @ (*) begin
    wd_o <= wd_i;
    wreg_o <= wreg_i;
end
endmodule
  
