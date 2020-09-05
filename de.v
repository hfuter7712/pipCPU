

//**** instruction about define ****
`define EXE_ORI 6'b001101
`define EXE_ANDI 6'b101101
`define EXE_XORI 6'b101110
`define EXE_LUI 6'b101111
`define EXE_PREF 6'b111011
//���������
`define EXE_SPECIAL 6'b000001
`define EXE_AND 6'b101001
`define EXE_OR 6'b101010
`define EXE_XOR 6'b101011
`define EXE_NOR 6'b101100
`define EXE_NOP 6'b000000
`define EXE_SSNOP 6'b000001
`define EXE_SYNC 6'b000011
//����MOVָ��
`define EXE_MOVN 6'b010000
`define EXE_MOVZ 6'b010001
`define EXE_MFHI 6'b010010
`define EXE_MFLO 6'b010011
`define EXE_MTHI 6'b010100
`define EXE_MTLO 6'b010101
//��������ָ��
`define EXE_ALG 6'b000011
`define EXE_ADD 6'b000001
`define EXE_ADDU 6'b000010
`define EXE_SUB 6'b000011
`define EXE_SUBU 6'b000100
`define EXE_SLT 6'b000101
`define EXE_SLTU 6'b000110
//�������ӷ���CLO,CLZָ��
`define EXE_ADDI 6'b000111
`define EXE_ADDIU 6'b001000
`define EXE_CLZ 6'b001001
`define EXE_CLO 6'b001010
//�˷�ָ��
`define EXE_MULT 6'b001011
`define EXE_MULTU 6'b001100
`define EXE_MUL 6'b001101

`define EXE_DIV 6'b001110
`define EXE_DIVU 6'b001111

//��λָ��
`define EXE_SHIFT 6'b000010
`define EXE_SLL 6'b110001
`define EXE_SRL 6'b110010
`define EXE_SRA 6'b110011
`define EXE_SLLV 6'b110100
`define EXE_SRLV 6'b110101
`define EXE_SRAV 6'b110110

//Ҫ�����������ָ��
`define EXE_TWICE 6'b000110
`define EXE_MADD 6'b111001
`define EXE_MADDU 6'b111010
`define EXE_MSUB 6'b111011
`define EXE_MSUBU 6'b111100

//��תָ��
`define EXE_JUMP 6'b010001
`define EXE_JR 6'b000001
`define EXE_JALR 6'b000010


`define EXE_J 6'b001011
`define EXE_JAL 6'b001100

`define EXE_BGTZ 6'b001110
`define EXE_BLEZ 6'b001111
`define EXE_BNE 6'b010000
`define EXE_BEQ 6'b010010

//REGIMM��
`define EXE_REGIMM 6'b010011
`define EXE_BLTZ 5'b00001
`define EXE_BLTZAL 5'b00010
`define EXE_BGEZ 5'b00011
`define EXE_BGEZAL 6'b00100


//�ô�ָ��
`define EXE_LB 6'b010100

`define EXE_SB 6'b011001








//Aluop
`define EXE_OR_OP 8'b00101011
`define EXE_AND_OP 8'b00101100
`define EXE_XOR_OP 8'b00101101
`define EXE_NOR_OP 8'b00101110

`define EXE_SLL_OP 8'b00110000
`define EXE_SRL_OP 8'b00110001
`define EXE_SRA_OP 8'b00110010

`define EXE_MOVN_OP 8'b01000000
`define EXE_MOVZ_OP 8'b01000001
`define EXE_MFHI_OP 8'b01000010
`define EXE_MFLO_OP 8'b01000011
`define EXE_MTHI_OP 8'b01000100
`define EXE_MTLO_OP 8'b01000101

`define EXE_NOP_OP 8'b00000001

`define EXE_ADD_OP 8'b00001100
`define EXE_ADDU_OP 8'b00000010
`define EXE_SUB_OP 8'b00000011
`define EXE_SUBU_OP 8'b00000100
`define EXE_SLT_OP 8'b00000101
`define EXE_SLTU_OP 8'b00000110

`define EXE_ADDI_OP 8'b00000111
`define EXE_ADDIU_OP 8'b00001000

`define EXE_MUL_OP 8'b00001001
`define EXE_MULT_OP 8'b00001010
`define EXE_MULTU_OP 8'b00001011


`define EXE_MADD_OP 8'b00001101
`define EXE_MADDU_OP 8'b00001110
`define EXE_MSUB_OP 8'b00001111
`define EXE_MSUBU_OP 8'b00010000

`define EXE_DIV_OP 8'b00010001
`define EXE_DIVU_OP 8'b00010010

`define EXE_JR_OP 8'b00010011
`define EXE_JALR_OP 8'b00010100

`define EXE_J_OP 8'b00010101
`define EXE_JAL_OP 8'b00010110

`define EXE_BGTZ_OP 8'b00010111
`define EXE_BLEZ_OP 8'b00011000
`define EXE_BNE_OP 8'b00011001
`define EXE_BEQ_OP 8'b00011010

//REGIMM��
`define EXE_BLTZ_OP 8'b00011011
`define EXE_BLTZAL_OP 8'b00011100
`define EXE_BGEZ_OP 8'b00011101
`define EXE_BGEZAL_OP 8'b00011110

`define EXE_LB_OP 8'b00011111

`define EXE_SB_OP 8'b00100100





//AluSel
`define EXE_RES_LOGIC 4'b0001
`define EXE_RES_LUI 4'b0010 
`define EXE_RES_SHIFT 4'b0011
`define EXE_RES_MOVE 4'b0100
`define EXE_RES_ALG 4'b0101
`define EXE_RES_MUL 4'b0110
`define EXE_RES_TWICE 4'b0111
`define EXE_RES_BRANCH 4'b1000
`define EXE_RES_LOADSTORE 4'b1001
`define EXE_RES_NOP 4'b0000







///**** global define ****
`define RstEnable 1'b1                   //����ʹ���ź�
`define RstDisable 1'b0                  //���ý�ֹ�źţ�disabled)
`define ZeroWord 32'h00000000    //һ��32byte ��0�֣�ȫ��0)
`define WriteEnable 1'b1                //дʹ���ź�
`define WriteDisable 1'b0               //��ֹд�ź�
`define ReadEnable 1'b1                 //��ʹ���ź�
`define ReadDisable 1'b0                //��ֹ���ź�
`define AluOpBus 7:0                      //Alu���������
`define AluSelBus 3:0                       //Alu���������
`define InstValid 1'b0                      //ָ����Ч
`define InstInvalid 1'b1                    //ָ����Ч
`define True_v 1'b1                         //�߼���
`define False_v 1'b0                        //�߼���
`define ChipEnable 1'b1                 //Ƭʹ���ź�
`define ChipDisable 1'b0                //Ƭ��ֹ�ź�




// **** define about IR ROM ****
`define InstAddrBus 31:0
`define InstBus 31:0
`define InstMemNum 128
`define InstMemNumLog2 17


// **** define about common register Regfile ***
`define RegAddrBus 4:0
`define RegBus 31:0
`define RegWidth 32
`define DoubleRegWidth 64
`define DoubleRegBus 63:0
`define RegNum 32
`define RegNumLog2 5
`define NOPRegAddr 5'b0000

`define Stop 1'b1
`define NotStop 1'b0


//div
`define DivFree 2'b00
`define DivByZero 2'b01
`define DivOn 2'b10
`define DivEnd 2'b11
`define DivResultReady 1'b1
`define DivResultNotReady 1'b0
`define DivStart 1'b1
`define DivStop 1'b0



//�غ�ת�Ƶ�һЩ�궨�� 
`define Branch 1'b1             //ת��
`define NotBranch 1'b0          //��ת��
`define InDelaySlot 1'b1       //���ӳٲ���
`define NotInDelaySlot 1'b0    //�����ӳٲ���  


//����RAM��һЩ����   
`define DataAddrBus 31:0    //��ַ���߿��
`define DataBus 31:0        //�������߿��
`define DataMemNum 1024   //RAM�Ĵ�С����λΪ�֣��˴���1K word
`define DataMemNumLog2 17   //ʵ��ʹ�õĵ�ַ���
`define ByteWidth 7:0   //һ���ֽڵĿ��

