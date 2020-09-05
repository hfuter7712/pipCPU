`include "de.v"

module ALU(
  input wire rst,
  
  input wire[`AluOpBus] aluop_i,        //alu�����
  input wire[`AluSelBus] alusel_i,       //alu���������
  input wire[`RegBus] reg1_i,            //���������Դ������1
  input wire[`RegBus] reg2_i,           //���������Դ������2
  input wire[`RegAddrBus] wd_i,     //Ҫд��Ĵ����ĵ�ַ
  input wire wreg_i,                           //�Ƿ���д�����

  input wire[`RegBus] hi_i,               // HI��������
  input wire[`RegBus] lo_i,              // LO��������
  
  input wire[`RegBus] wb_hi_i,       //��д�ؽ׶δ�������hi_iֵ
  input wire[`RegBus] wb_lo_i,      //��д�ؽ׶δ�������lo_iֵ
  input wire wb_whilo_i,
  
  input wire[`RegBus] mem_hi_i,      //�ӷô�׶δ�������hi_iֵ
  input wire[`RegBus] mem_lo_i,      //�ӷô�׶δ�������hi_iֵ
  input wire mem_whilo_i,                //�ӷô�׶δ��������Ƿ�Ҫдhi,lo��־
  
  input wire[`DoubleRegBus] hilo_temp_i,    //��һ��ִ�����ڵõ��ĳ˷����
  input wire[1:0] cnt_i,                                      //��ǰ���ڵڼ���ʱ������

  input wire[`DoubleRegBus] div_result_i,     //��������Ľ��
  input wire div_ready_i,                     //���������Ƿ����
  
  input wire[`RegBus] link_address_i,         
  input wire is_in_delayslot_i,
  
  input wire[`RegBus] inst_i,                  //��ǰ����ִ�н׶ε�ָ��
  
  output wire[`AluOpBus] aluop_o,              //ִ�н׶ε�ָ��Ҫ���е�����������
  output wire[`RegBus] mem_addr_o,             //���أ��洢ָ���Ӧ�Ĵ洢����ַ
  output wire[`RegBus] reg2_o,                 //�洢ָ��Ҫ�洢�����ݵ�

  output reg[`RegBus] div_opdata1_o,          //������
  output reg[`RegBus] div_opdata2_o,          //����
  output reg div_start_o,                     //�Ƿ�ʼ��������
  output reg signed_div_o,                    //�Ƿ��з��ų���

  output reg[`DoubleRegBus] hilo_temp_o,  //��һ��ִ�����ڵõ��ĳ˷����
  output reg[1:0] cnt_o,                                     //��һ��ʱ�����ڴ���ִ�н׶εĵڼ���ʱ������
  
  output reg[`RegBus] hi_o,               
  output reg[`RegBus] lo_o,
  output reg whilo_o,
  
  output reg[`RegAddrBus] wd_o,    //Ҫд�����ݵļĴ�����ַ
  output reg wreg_o,                          //�Ƿ���д��Ĵ�������
  output reg[`RegBus] wdata_o,       //Ҫд�������
  output reg ex_stall
  );
  
  reg[`RegBus] logicout;                  //�߼�������
  reg[`RegBus] algcout;                   //����������
  reg[`RegBus] moveres;        
  reg[`RegBus] HI;                           
  reg[`RegBus] LO;
  
  wire ov_sum;                                  //����������
  wire[`RegBus] res_sum;                 //����ӷ����
  wire[`RegBus] res_sub;                
  wire[`RegBus] res_not;
  wire[`DoubleRegBus] res_mul_temp;     //��ʱ����˷����
  reg[`DoubleRegBus] res_mul;               //����˷����
  wire[`RegBus] reg1_i_mux;                    //����˷�����ĵ�һ��������
  wire[`RegBus] reg2_i_mux;                   //����˷�����ĵڶ���������
  wire reg1_eq_reg2;                              //��һ���������Ƿ���ڵڶ���������
  wire reg1_lt_reg2;                                //��һ���������Ƿ�С�ڵڶ���������
  
  reg[`DoubleRegBus] hilo_temp1;
  reg madd_msub_stall;
  
  
  //��������ΪSUB,SUBU����SLT���ͽ�reg2_i_mux��ʼ��Ϊ�䲹�룬֮��ֻҪ���üӷ���ز�������
 assign reg2_i_mux = ((aluop_i == `EXE_SUB_OP) || 
 (aluop_i == `EXE_SUBU_OP) || 
 (aluop_i == `EXE_SLT_OP)) ? (~reg2_i)+1 : reg2_i;
 
//������
 assign res_sum = reg1_i + reg2_i_mux;
 
  //����ж��Ƿ������ ��������������Ϊ������������������֮��Ϊ������������Ϊ���
 //�Ƿ�����ж�
 assign ov_sum = ((!reg1_i[31] && !reg2_i_mux[31] && res_sum[31])|| (reg1_i[31] && reg2_i_mux[31] && !res_sum[31]));
 
 //SLT��SLTU����������SLT�Ļ���Ҫ�жϷ��ţ������SLTU�޷��ŵĻ�ֱ�ӽ��бȽϾ�����
assign  reg1_lt_reg2 = (aluop_i == `EXE_SLT_OP) ? ((reg1_i[31] && !reg2_i[31]) || (!reg1_i[31] && !reg2_i[31] && res_sum[31]) || (reg1_i[31] && reg2_i[31] && res_sum[31])) : (reg1_i < reg2_i);
 
//ȡ���������CLO
 assign res_not = ~reg1_i;
 
 
 assign aluop_o = aluop_i;
 assign mem_addr_o = reg1_i + {{16{inst_i[15]}}, inst_i[15:0]};
 assign reg2_o = reg2_i;
  
  //����HI��LO������ǰ��
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
    `EXE_ADD_OP, `EXE_ADDU_OP, `EXE_ADDI_OP, `EXE_ADDIU_OP:begin            //���еļӷ������
      algcout <=res_sum;
    end
    `EXE_SUB_OP, `EXE_SUBU_OP:begin                                                                         //���еļ��������
        algcout <=res_sum;
    end
    `EXE_SLT_OP, `EXE_SLTU_OP:begin                                                                           //�Ƚ�����
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




//�˷������һ��Դ������      
assign reg1_i_mux = (((aluop_i==`EXE_MUL_OP) || (aluop_i==`EXE_MULT_OP)||(aluop_i == `EXE_MADD_OP) ||(aluop_i == `EXE_MSUB_OP)) && (reg1_i[31] == 1'b1)) ? (~reg1_i+1) : reg1_i;
//�˷�����ڶ���Դ������ 
assign reg2_i_mux = (((aluop_i==`EXE_MUL_OP) || (aluop_i==`EXE_MULT_OP)||(aluop_i == `EXE_MADD_OP) ||(aluop_i == `EXE_MSUB_OP)) && (reg2_i[31] == 1'b1)) ? (~reg2_i+1) : reg2_i;

assign res_mul_temp = reg1_i_mux * reg2_i_mux;

//�˷����ڴ���
always @ (*) begin
if(rst == `RstEnable) begin                     //���rstΪ0���������Ϊȫ0
 res_mul <={`ZeroWord, `ZeroWord};
 end else if((aluop_i == `EXE_MULT_OP) || (aluop_i == `EXE_MUL_OP)||(aluop_i == `EXE_MADD_OP) ||(aluop_i == `EXE_MSUB_OP))
 begin
 if(reg1_i[31] ^ reg2_i[31] == 1'b1) begin          //�������Դ���������Ų���ȣ�˵�����Ϊ������Ҫ�����ȡ��+1�����룩
 res_mul <= ~res_mul_temp +1;
 end else begin
 res_mul = res_mul_temp;                                    //��������Ϊ��ʱ���
 end
 end else begin
  res_mul = res_mul_temp;
  end
  end
  
  //MADD,MADDU,MSUB,MSUBUָ��
  always @(*) begin
  if(rst == `RstEnable) begin
  hilo_temp_o <={`ZeroWord, `ZeroWord};
  cnt_o <= 2'b00;
  madd_msub_stall <= `NotStop;
  end else begin
    case (aluop_i)
        `EXE_MADD_OP, `EXE_MADDU_OP : begin
            if(cnt_i == 2'b00)begin
                hilo_temp_o <= res_mul;                         //������������hilo_temp_o
                cnt_o <= 2'b01;                                         //������ɣ�������һ���׶�
                hilo_temp1 <={`ZeroWord, `ZeroWord};
                madd_msub_stall <= `Stop;                   //��ͣ
                end else if(cnt_i == 2'b01) begin          //����ڶ��׶�
                hilo_temp_o <={`ZeroWord, `ZeroWord};
                cnt_o <= 2'b10;                                         
                hilo_temp1 <= hilo_temp_i + {HI,LO};    //���ۼ�����
                 madd_msub_stall <= `NotStop;              //��Ϊ�����Ѿ���ɣ�����ͣ
                end
        end
        `EXE_MSUB_OP,`EXE_MSUBU_OP:begin
         if(cnt_i == 2'b00)begin
                hilo_temp_o <= ~res_mul + 1;                //��������ת��Ϊ����(���ڼ���)
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
    
   //��madd_msub_stallֵ���� ex_stall
  always @ (*) begin 
  ex_stall = madd_msub_stall || div_stall;
  end
        

//����HI,LO�Ĵ����ĺ�������
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
  
