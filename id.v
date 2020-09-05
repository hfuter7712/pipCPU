`include "de.v"
module id(
  input wire rst,
  input wire[`InstAddrBus] pc_i,
  input wire[`InstBus] inst_i,
  
  input wire[`RegBus] reg1_data_i,
  input wire[`RegBus] reg2_data_i,
  
  input wire ex_wreg_i,
  input wire[`RegBus] ex_wdata_i,
  input wire[`RegAddrBus] ex_wd_i,
  
  input wire mem_wreg_i,
  input wire[`RegBus] mem_wdata_i,
  input wire[`RegAddrBus] mem_wd_i,
  
  input wire whetherIn_Delayslot_i,
  
  output reg branch_flag_o,
  output reg[`RegBus] branch_target_address_o,
  output reg whetherIn_Delayslot_o,
  output reg[`RegBus]link_addr_o,
  output reg next_inst_delayslot_o,
  
  
  output reg reg1_read_o,
  output reg reg2_read_o,
  output reg[`RegAddrBus] reg1_addr_o,
  output reg[`RegAddrBus] reg2_addr_o,
  
  output reg[`AluOpBus] aluop_o,
  output reg[`AluSelBus] alusel_o,
  output reg[`RegBus] reg1_o,
  output reg[`RegBus] reg2_o,
  output reg[`RegAddrBus] wd_o,
  output reg wreg_o,
  output reg id_stall,
  
  output wire[`RegBus] inst_o
  );
  
  assign inst_o = inst_i;   
  
  wire[5:0] SpecialOp = inst_i[31:26];
  wire[4:0] RSop = inst_i[25:21];
  wire[4:0] RTop = inst_i[20:16];
  wire[4:0] RDop = inst_i[15:11];
  wire[4:0] op5 = inst_i[10:6];
  wire[5:0] INSop = inst_i[5:0];
  wire[15:0] Immop = inst_i[15:0];
  wire[25:0] instr_index = inst_i[25:0];
 
 
 //关于转移的变量定义
 wire[`RegBus] pc_plus_8;
 wire[`RegBus] pc_plus_4;
 
 wire[`RegBus] imm_sll2_signedext;
 
 assign pc_plus_8 = pc_i + 8;
 assign pc_plus_4 = pc_i + 4;
 
 assign imm_sll2_signedext = {{14{inst_i[15]}}, inst_i[15:0], 2'b00};
 

  reg[`RegBus] imm;
  reg instvalid;
  
  
 
  
  always @ (*) begin
    if(rst == `RstEnable) begin
      aluop_o <= `EXE_NOP_OP;
      alusel_o <= `EXE_RES_NOP;
      wd_o <= `NOPRegAddr;
      wreg_o <= `WriteDisable;
      instvalid <= `InstValid;
      reg1_read_o <= 1'b0;
      reg2_read_o <= 1'b0;
      reg1_addr_o <= `NOPRegAddr;
      reg2_addr_o <= `NOPRegAddr;
      imm <= 32'b0;
      
      link_addr_o <= `ZeroWord;
      branch_target_address_o <= `ZeroWord;
      branch_flag_o <= `NotBranch;
      next_inst_delayslot_o <= `NotInDelaySlot;
    end else begin
      aluop_o <= `EXE_NOP_OP;
      alusel_o <= `EXE_RES_NOP;
      wd_o <= RDop;
      wreg_o <= `WriteDisable;
      instvalid <= `InstInvalid;
      reg1_read_o <= 1'b0;
      reg2_read_o <= 1'b0;
      reg1_addr_o <= RSop;
      reg2_addr_o <= RTop;
      imm <= `ZeroWord;
       
      link_addr_o <= `ZeroWord;
      branch_target_address_o <= `ZeroWord;
      branch_flag_o <= `NotBranch;
      next_inst_delayslot_o <= `NotInDelaySlot;
      
      case(SpecialOp)
        `EXE_ORI: begin
          wreg_o <= `WriteEnable;
          aluop_o <= `EXE_OR_OP;
          alusel_o <= `EXE_RES_LOGIC;
          
          reg1_read_o <= 1'b1;
          reg2_read_o <= 1'b0;
          
          imm <= {16'b0 , Immop};
          
          wd_o <= RTop;
          instvalid <= `InstValid;
        end
        `EXE_ANDI: begin
          wreg_o <= `WriteEnable;
          aluop_o <= `EXE_AND_OP;
          alusel_o <= `EXE_RES_LOGIC;
          
          reg1_read_o <= 1'b1;
          reg2_read_o <= 1'b0;
          
          imm <= {16'b0 , Immop};
          
          wd_o <= RTop;
          instvalid <= `InstValid;
        end
        `EXE_XORI: begin
          wreg_o <= `WriteEnable;
          aluop_o <= `EXE_XOR_OP;
          alusel_o <= `EXE_RES_LOGIC;
          
          reg1_read_o <= 1'b1;
          reg2_read_o <= 1'b0;
          
          imm <= {16'b0 , Immop};
          
          wd_o <= RTop;
          instvalid <= `InstValid;
        end
        `EXE_LUI: begin
          wreg_o <= `WriteEnable;
          alusel_o <= `EXE_RES_LUI;
          
          reg1_read_o <= 1'b0;
          reg2_read_o <= 1'b0;
          
          imm <= {Immop,16'b0};
          
          wd_o <= RTop;
          instvalid <= `InstValid;
        end
        `EXE_PREF: begin
          aluop_o <= `EXE_SLL_OP;
          alusel_o <= `EXE_RES_SHIFT;
          reg1_read_o <= 1'b0;
          reg2_read_o <= 1'b0;
          instvalid <= `InstValid;   
        end
        
        `EXE_SPECIAL: begin
          case(INSop)
            `EXE_AND: begin
          wreg_o <= `WriteEnable;
          aluop_o <= `EXE_AND_OP;
          alusel_o <= `EXE_RES_LOGIC;
          
          reg1_read_o <= 1'b1;
          reg2_read_o <= 1'b1;
          
          wd_o <= RDop;
          instvalid <= `InstValid;   
        end
            `EXE_OR: begin
          wreg_o <= `WriteEnable;
          aluop_o <= `EXE_OR_OP;
          alusel_o <= `EXE_RES_LOGIC;
          reg1_read_o <= 1'b1;
          reg2_read_o <= 1'b1;
          
          wd_o <= RDop;
          instvalid <= `InstValid;   
        end
            `EXE_XOR: begin
          wreg_o <= `WriteEnable;
          aluop_o <= `EXE_XOR_OP;
          alusel_o <= `EXE_RES_LOGIC;
          reg1_read_o <= 1'b1;
          reg2_read_o <= 1'b1;
          
          wd_o <= RDop;
          instvalid <= `InstValid;   
        end
            `EXE_NOR: begin
          wreg_o <= `WriteEnable;
          aluop_o <= `EXE_NOR_OP;
          alusel_o <= `EXE_RES_LOGIC;
          reg1_read_o <= 1'b1;
          reg2_read_o <= 1'b1;
          
          wd_o <= RDop;
          instvalid <= `InstValid;   
        end
        `EXE_NOP: begin
          aluop_o <= `EXE_SLL_OP;
          alusel_o <= `EXE_RES_SHIFT;
          reg1_read_o <= 1'b0;
          reg2_read_o <= 1'b0;
          instvalid <= `InstValid;   
        end
        `EXE_SSNOP: begin
          aluop_o <= `EXE_SLL_OP;
          alusel_o <= `EXE_RES_SHIFT;
          reg1_read_o <= 1'b0;
          reg2_read_o <= 1'b0;
          instvalid <= `InstValid;   
        end
        `EXE_SYNC: begin
          aluop_o <= `EXE_SLL_OP;
          alusel_o <= `EXE_RES_SHIFT;
          reg1_read_o <= 1'b0;
          reg2_read_o <= 1'b0;
          instvalid <= `InstValid;   
        end
        `EXE_MOVN:begin
          aluop_o <= `EXE_MOVN_OP;
          if(reg2_o == `ZeroWord)begin
            wreg_o <= `WriteDisable;
          end else begin
          wreg_o <= `WriteEnable;
        end
          alusel_o <= `EXE_RES_MOVE;
          reg1_read_o <= 1'b1;
          reg2_read_o <= 1'b1;
          instvalid <= `InstValid;
        end
        `EXE_MOVZ:begin
          aluop_o <= `EXE_MOVZ_OP;
           if(reg2_o != `ZeroWord)begin
             wreg_o <= `WriteDisable;
          end else begin
          wreg_o <= `WriteEnable;
        end
          alusel_o <= `EXE_RES_MOVE;
          reg1_read_o <= 1'b1;
          reg2_read_o <= 1'b1;
          instvalid <= `InstValid;
        end
        `EXE_MFHI:begin
          aluop_o <= `EXE_MFHI_OP;
          wreg_o <= `WriteEnable;
          alusel_o <= `EXE_RES_MOVE;
          reg1_read_o <= 1'b0;
          reg2_read_o <= 1'b0;
          instvalid <= `InstValid;
        end
         `EXE_MTHI:begin
          aluop_o <= `EXE_MTHI_OP;
          alusel_o <= `EXE_RES_MOVE;
          reg1_read_o <= 1'b1;
          reg2_read_o <= 1'b0;
          instvalid <= `InstValid;
        end
         `EXE_MFLO:begin
          aluop_o <= `EXE_MFLO_OP;
          wreg_o <= `WriteEnable;
          alusel_o <= `EXE_RES_MOVE;
          reg1_read_o <= 1'b0;
          reg2_read_o <= 1'b0;
          instvalid <= `InstValid;
        end
         `EXE_MTLO:begin
          aluop_o <= `EXE_MTLO_OP;
          alusel_o <= `EXE_RES_MOVE;
          reg1_read_o <= 1'b1;
          reg2_read_o <= 1'b0;
          instvalid <= `InstValid;
        end
      endcase
    end
    `EXE_SHIFT: begin
        case(INSop)
          `EXE_SLL: begin
          wreg_o <= `WriteEnable;
          aluop_o <= `EXE_SLL_OP;
          alusel_o <= `EXE_RES_SHIFT;
          
          reg1_read_o <= 1'b1;
          reg2_read_o <= 1'b0;
          reg1_addr_o <= RTop;
          imm <= {27'b0 , op5};
          
          wd_o <= RDop;
         instvalid <= `InstValid;
        end
          `EXE_SRL: begin
          wreg_o <= `WriteEnable;
          aluop_o <= `EXE_SRL_OP;
          alusel_o <= `EXE_RES_SHIFT;
          reg1_addr_o <= RTop;
          reg1_read_o <= 1'b1;
          reg2_read_o <= 1'b0;
          
          imm <= {27'b0 , op5};
          wd_o <= RDop;
          instvalid <= `InstValid;
        end
        `EXE_SRA: begin
          wreg_o <= `WriteEnable;
          aluop_o <= `EXE_SRA_OP;
          alusel_o <= `EXE_RES_SHIFT;
          
          reg1_read_o <= 1'b1;
          reg2_read_o <= 1'b0;
          reg1_addr_o <= RTop;
          imm <= {27'b0 , op5};
          
          wd_o <= RDop;
          instvalid <= `InstValid;
        end
        `EXE_SLLV: begin
          wreg_o <= `WriteEnable;
          aluop_o <= `EXE_SLL_OP;
          alusel_o <= `EXE_RES_SHIFT;
          reg1_addr_o <= RTop;
          reg1_read_o <= 1'b1;
          reg2_read_o <= 1'b1;
          
          wd_o <= RDop;
          instvalid <= `InstValid;
        end
        `EXE_SRLV: begin
          wreg_o <= `WriteEnable;
          aluop_o <= `EXE_SRL_OP;
          alusel_o <= `EXE_RES_SHIFT;
          reg1_addr_o <= RTop;
          reg1_read_o <= 1'b1;
          reg2_read_o <= 1'b1;
          
          wd_o <= RDop;
          instvalid <= `InstValid;
        end
        `EXE_SRAV: begin
          wreg_o <= `WriteEnable;
          aluop_o <= `EXE_SRA_OP;
          alusel_o <= `EXE_RES_SHIFT;
          reg1_addr_o <= RTop;
          reg1_read_o <= 1'b1;
          reg2_read_o <= 1'b1;
          
          wd_o <= RDop;
          instvalid <= `InstValid;
        end
      endcase
    end
    //算术运算运算符部分
        `EXE_ADDI:begin                     //ADDI算符
             wreg_o <= `WriteEnable;
             aluop_o <= `EXE_ADDI_OP;
             alusel_o <= `EXE_RES_ALG;
             reg1_read_o <= 1'b1;
             reg2_read_o <= 1'b0;
              imm <= {16'b0 , Immop};
             wd_o <= RTop;
             instvalid <= `InstValid;
            end
            
            `EXE_ADDIU:begin                     //ADDI算符
             wreg_o <= `WriteEnable;
             aluop_o <= `EXE_ADDIU_OP;
             alusel_o <= `EXE_RES_ALG;
             reg1_read_o <= 1'b1;
             reg2_read_o <= 1'b0;
              imm <= {16'b0 , Immop};
             wd_o <= RTop;
             instvalid <= `InstValid;
            end
        `EXE_ALG:begin
          case(INSop)
            `EXE_ADD:begin                         //ADD算符
             wreg_o <= `WriteEnable;
             aluop_o <= `EXE_ADD_OP;
             alusel_o <= `EXE_RES_ALG;
             reg1_read_o <= 1'b1;
             reg2_read_o <= 1'b1;
             wd_o <= RDop;
             instvalid <= `InstValid;
            end
            
            
            `EXE_SUB:begin                          //SUB算符
             wreg_o <= `WriteEnable;
             aluop_o <= `EXE_SUB_OP;
             alusel_o <= `EXE_RES_ALG;
             reg1_read_o <= 1'b1;
             reg2_read_o <= 1'b1;
             wd_o <= RDop;
             instvalid <= `InstValid;
            end
            
            `EXE_SLT:begin                          //SLT算符
             wreg_o <= `WriteEnable;
             aluop_o <= `EXE_SLT_OP;
             alusel_o <= `EXE_RES_ALG;
             reg1_read_o <= 1'b1;
             reg2_read_o <= 1'b1;
             wd_o <= RDop;
             instvalid <= `InstValid;
            end

            
            `EXE_ADDU:begin                         //ADDU算符
             wreg_o <= `WriteEnable;
             aluop_o <= `EXE_ADDU_OP;
             alusel_o <= `EXE_RES_ALG;
             reg1_read_o <= 1'b1;
             reg2_read_o <= 1'b1;
             wd_o <= RDop;
             instvalid <= `InstValid;
            end
            
            `EXE_SUBU:begin                           //SUBU算符
             wreg_o <= `WriteEnable;
             aluop_o <= `EXE_SUBU_OP;
             alusel_o <= `EXE_RES_ALG;
             reg1_read_o <= 1'b1;
             reg2_read_o <= 1'b1;
             wd_o <= RDop;
             instvalid <= `InstValid;
            end
            
            `EXE_SLTU:begin                             //SLTU算符
             wreg_o <= `WriteEnable;
             aluop_o <= `EXE_SLTU_OP;
             alusel_o <= `EXE_RES_ALG;
             reg1_read_o <= 1'b1;
             reg2_read_o <= 1'b1;
             wd_o <= RDop;
             instvalid <= `InstValid;
            end
            
            `EXE_MUL:begin                              //MUL算符
               wreg_o <= `WriteEnable;
               aluop_o <= `EXE_MUL_OP;
             alusel_o <=  `EXE_RES_MUL;
             reg1_read_o <= 1'b1;
             reg2_read_o <= 1'b1;
             wd_o <= RDop;
             instvalid <= `InstValid;
            end
            
             `EXE_MULT:begin                              //MULT算符
               wreg_o <= `WriteDisable;
               aluop_o <= `EXE_MULT_OP;
             alusel_o <= `EXE_RES_MUL;
             reg1_read_o <= 1'b1;
             reg2_read_o <= 1'b1;
             instvalid <= `InstValid;
            end
            
             `EXE_MULTU:begin                              //MULTU算符
               wreg_o <= `WriteDisable;
               aluop_o <= `EXE_MULTU_OP;
             alusel_o <= `EXE_RES_MUL;
             reg1_read_o <= 1'b1;
             reg2_read_o <= 1'b1;
             instvalid <= `InstValid;
            end
            
             `EXE_DIV:begin                              //DIV算符
               wreg_o <= `WriteDisable;
               aluop_o <= `EXE_DIV_OP;
             reg1_read_o <= 1'b1;
             reg2_read_o <= 1'b1;
             instvalid <= `InstValid;
            end
            
             `EXE_DIVU:begin                              //DIVU算符
               wreg_o <= `WriteDisable;
               aluop_o <= `EXE_DIVU_OP;
             reg1_read_o <= 1'b1;
             reg2_read_o <= 1'b1;
             instvalid <= `InstValid;
            end
          endcase
           end
          `EXE_TWICE : begin
          case(INSop)
          `EXE_MADD:begin
            wreg_o <= `WriteDisable;
             aluop_o <= `EXE_MADD_OP;
             alusel_o <= `EXE_RES_TWICE;
             reg1_read_o <= 1'b1;
             reg2_read_o <= 1'b1;
             instvalid <= `InstValid;
          end
            `EXE_MADDU:begin
              wreg_o <= `WriteDisable;
             aluop_o <= `EXE_MADDU_OP;
             alusel_o <= `EXE_RES_TWICE;
             reg1_read_o <= 1'b1;
             reg2_read_o <= 1'b1;
             instvalid <= `InstValid;
          end
            `EXE_MSUB:begin
             wreg_o <= `WriteDisable;
             aluop_o <= `EXE_MSUB_OP;
             alusel_o <= `EXE_RES_TWICE;
             reg1_read_o <= 1'b1;
             reg2_read_o <= 1'b1;
             instvalid <= `InstValid;
          end
            `EXE_MSUBU:begin
             wreg_o <= `WriteDisable;
             aluop_o <= `EXE_MSUBU_OP;
             alusel_o <= `EXE_RES_TWICE;
             reg1_read_o <= 1'b1;
             reg2_read_o <= 1'b1;
             instvalid <= `InstValid;
          end
          endcase
          end
          
           `EXE_JUMP: begin
                case(INSop)
                    //jr指令不需要保存返回地址
                    `EXE_JR:begin
                         wreg_o <= `WriteDisable;
                         aluop_o <= `EXE_JR_OP;
                         alusel_o <= `EXE_RES_BRANCH;
                         reg1_read_o <= 1'b1;
                         reg2_read_o <= 1'b0;
                         link_addr_o <= `ZeroWord;
                         branch_target_address_o <=reg1_o;
                         branch_flag_o <= `Branch;
                         next_inst_delayslot_o <= `InDelaySlot;
                         instvalid <= `InstValid;
                         end
                    `EXE_JALR: begin
                         wreg_o <= `WriteEnable;
                         aluop_o <= `EXE_JALR_OP;
                         alusel_o <= `EXE_RES_BRANCH;
                         reg1_read_o <= 1'b1;
                         reg2_read_o <= 1'b0;
                         wd_o <= RDop;
                         link_addr_o <= pc_plus_8;
                         branch_target_address_o <=reg1_o;
                         branch_flag_o <= `Branch;
                         next_inst_delayslot_o <= `InDelaySlot;
                         instvalid <= `InstValid;       
                    end    
                endcase
            end
            `EXE_J: begin
                wreg_o <= `WriteDisable;
                aluop_o <= `EXE_J_OP;
                alusel_o <= `EXE_RES_BRANCH;
                reg1_read_o <= 1'b0;
                reg2_read_o <= 1'b0;
                link_addr_o <= `ZeroWord;
                branch_target_address_o <= {pc_plus_4[31:28], instr_index, 2'b00};
                branch_flag_o <= `Branch;
                next_inst_delayslot_o <= `InDelaySlot;
                instvalid <= `InstValid;
                end
             `EXE_JAL: begin
                wreg_o <= `WriteEnable;
                aluop_o <= `EXE_JAL_OP;
                alusel_o <= `EXE_RES_BRANCH;
                reg1_read_o <= 1'b0;
                reg2_read_o <= 1'b0;
                wd_o <= 5'b11111;
                link_addr_o <= pc_plus_8;
                branch_target_address_o <= {pc_plus_4[31:28], instr_index, 2'b00};
                branch_flag_o <= `Branch;
                next_inst_delayslot_o <= `InDelaySlot;
                instvalid <= `InstValid;
                end
             `EXE_BEQ: begin
                wreg_o <= `WriteDisable;
                aluop_o <= `EXE_BEQ_OP;
                alusel_o <= `EXE_RES_BRANCH;
                reg1_read_o <= 1'b1;
                reg2_read_o <= 1'b1;
                if(reg1_o == reg2_o) begin
                    branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
                    branch_flag_o <= `Branch;
                    next_inst_delayslot_o <= `InDelaySlot;  
                end
                instvalid <= `InstValid;
                end
             `EXE_BGTZ: begin
                wreg_o <= `WriteDisable;
                aluop_o <= `EXE_BGTZ_OP;
                alusel_o <= `EXE_RES_BRANCH;
                reg1_read_o <= 1'b1;
                reg2_read_o <= 1'b0;
                if((reg1_o[31] == 1'b0) && (reg1_o != `ZeroWord)) begin
                    branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
                    branch_flag_o <= `Branch;
                    next_inst_delayslot_o <= `InDelaySlot;  
                end
                instvalid <= `InstValid;
                end
                
             `EXE_BLEZ: begin
                wreg_o <= `WriteDisable;
                aluop_o <= `EXE_BLEZ_OP;
                alusel_o <= `EXE_RES_BRANCH;
                reg1_read_o <= 1'b1;
                reg2_read_o <= 1'b0;
                if((reg1_o[31] == 1'b1) && (reg1_o != `ZeroWord)) begin
                    branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
                    branch_flag_o <= `Branch;
                    next_inst_delayslot_o <= `InDelaySlot;  
                end
                instvalid <= `InstValid;
                end
             `EXE_BNE: begin
                wreg_o <= `WriteDisable;
                aluop_o <= `EXE_BLEZ_OP;
                alusel_o <= `EXE_RES_BRANCH;
                reg1_read_o <= 1'b1;
                reg2_read_o <= 1'b1;
                if(reg1_o != reg2_o) begin
                    branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
                    branch_flag_o <= `Branch;
                    next_inst_delayslot_o <= `InDelaySlot;  
                end
                instvalid <= `InstValid;
                end
             `EXE_LB: begin
             wreg_o <= `WriteEnable;
             aluop_o <= `EXE_LB_OP;
             alusel_o <= `EXE_RES_LOADSTORE;
             reg1_read_o <= 1'b1;
             reg2_read_o <= 1'b0;
             wd_o <= RTop;
             instvalid <= `InstValid;
             end
             
           
             
         
             
             
             `EXE_SB: begin
             wreg_o <= `WriteDisable;
             aluop_o <= `EXE_SB_OP;
             alusel_o <= `EXE_RES_LOADSTORE;
             reg1_read_o <= 1'b1;
             reg2_read_o <= 1'b1;
             instvalid <= `InstValid;
             end
             
           
             
             
             `EXE_REGIMM:begin
                case(RTop)
                `EXE_BLTZ:begin
                    wreg_o <= `WriteDisable;
                    aluop_o <= `EXE_BGEZAL_OP;
                    alusel_o <= `EXE_RES_BRANCH;
                    reg1_read_o <= 1'b1;
                    reg2_read_o <= 1'b0;
                    if(reg1_o[31] == 1'b1) begin
                        branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
                        branch_flag_o <= `Branch;
                        next_inst_delayslot_o <= `InDelaySlot;  
                    end
                    instvalid <= `InstValid;
                end
                `EXE_BGEZAL:begin
                    wreg_o <= `WriteEnable;
                    aluop_o <= `EXE_BGEZAL_OP;
                    alusel_o <= `EXE_RES_BRANCH;
                    reg1_read_o <= 1'b1;
                    reg2_read_o <= 1'b0;
                    link_addr_o <= pc_plus_8;
                    wd_o <= 5'b11111;
                    if(reg1_o[31] == 1'b0) begin
                        branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
                        branch_flag_o <= `Branch;
                        next_inst_delayslot_o <= `InDelaySlot;  
                    end
                    instvalid <= `InstValid;
                end
                `EXE_BLTZAL:begin
                    wreg_o <= `WriteEnable;
                    aluop_o <= `EXE_BLTZAL_OP;
                    alusel_o <= `EXE_RES_BRANCH;
                    reg1_read_o <= 1'b1;
                    reg2_read_o <= 1'b0;
                    link_addr_o <= pc_plus_8;
                    wd_o <= 5'b11111;
                    if(reg1_o[31] == 1'b1) begin
                        branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
                        branch_flag_o <= `Branch;
                        next_inst_delayslot_o <= `InDelaySlot;  
                    end
                    instvalid <= `InstValid;
                end  
                `EXE_BGEZ:begin
                    wreg_o <= `WriteDisable;
                    aluop_o <= `EXE_BGEZ_OP;
                    alusel_o <= `EXE_RES_BRANCH;
                    reg1_read_o <= 1'b1;
                    reg2_read_o <= 1'b0;
                    if(reg1_o[31] == 1'b0) begin
                        branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
                        branch_flag_o <= `Branch;
                        next_inst_delayslot_o <= `InDelaySlot;  
                    end
                    instvalid <= `InstValid;
                end   
                endcase
                
             end
             
                
        default:begin
        end
      endcase
    end
  end
   

    
    always @ (*) begin
      if(rst == `RstEnable) begin
        reg1_o <= `ZeroWord;
        end else if((reg1_read_o == 1'b1) && (ex_wreg_i == 1'b1)
        && (reg1_addr_o == ex_wd_i)) begin
          reg1_o <= ex_wdata_i;
        end else if((reg1_read_o == 1'b1) && (mem_wreg_i == 1'b1)
        &&(reg1_addr_o == mem_wd_i)) begin
          reg1_o <= mem_wdata_i;
      end else if(reg1_read_o == 1'b1) begin
        reg1_o <= reg1_data_i;
      end else if(reg1_read_o ==1'b0) begin
        reg1_o <= imm;
      end else begin
        reg1_o <= `ZeroWord;
      end
    end
    
    always @(*) begin
      if(rst == `RstEnable) begin
        reg2_o <= `ZeroWord;
      end else if((reg2_read_o == 1'b1) && (ex_wreg_i == 1'b1)
        && (reg2_addr_o == ex_wd_i)) begin
          reg2_o <= ex_wdata_i;
        end else if((reg2_read_o == 1'b1) && (mem_wreg_i == 1'b1)
        &&(reg2_addr_o == mem_wd_i)) begin
          reg2_o <= mem_wdata_i;
      end else if(reg2_read_o == 1'b1) begin
        reg2_o <= reg2_data_i;
      end else if(reg2_read_o ==1'b0) begin
        reg2_o <= imm;
      end else begin
        reg2_o <= `ZeroWord;
      end
    end
    
    //输出变量  whetherIn_Delayslot_o  表示当前译码阶段是否是延迟槽指令
   always @(*) begin
    if(rst == `RstEnable) begin
        whetherIn_Delayslot_o <= `NotInDelaySlot;
    end else begin
        whetherIn_Delayslot_o<= whetherIn_Delayslot_i;
    end
   end
   
  endmodule
      

      
      
  
  
  
