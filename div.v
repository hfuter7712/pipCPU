`include "de.v"

//div����ʹ�����̷���һ��Ҫ����32��
module div(
    input wire clk,
    input wire rst,
    
    input wire signed_div_i,
    input wire[31:0] opdata1_i,
    input wire[31:0] opdata2_i,
    input wire start_i,
    input wire annul_i,
    
    output reg[63:0] result_o,
    output reg ready_o
);
    wire[32:0] div_temp;
    reg[5:0] cnt;              //���̷����е��Ĳ��裬��cnt=32ʱ����ʾ���̷�����
    reg[64:0] dividend;       
     //dividend�ĵ�32λ�Ǳ��������м�������k�ε���������ʱ��dividend[k:0]����ľ��ǵ�ǰ�õ����м��� ��dividend[31:k+1]����ľ��Ǳ������л�û�в������������  
    //dividend��ÿ�ε����ı�����
    reg[1:0] state;
    reg[31:0] divisor;
    reg[31:0] temp_op1;
    reg[31:0] temp_op2;
    
    assign div_temp = {1'b0, dividend[63:32]} - {1'b0,divisor};     //��ʱ�洢�������
    
    always@ (posedge clk) begin
    if(rst==`RstEnable) begin
    state <= `DivFree;                  //����״̬ΪDivFree
    ready_o <= `DivResultNotReady;
    result_o <= {`ZeroWord, `ZeroWord};
    end else begin
        case(state)
        //����ģ����У�DivFree
        `DivFree: begin
            if(start_i == `DivStart && annul_i == 1'b0) begin
                if(opdata2_i == `ZeroWord) begin    //����Ϊ0ʱ������״̬ΪDivByZero
                    state <= `DivByZero;
                end else begin                       //��������ΪDivOn
                    state <= `DivOn;
                    cnt<= 6'b000000;
                    //���ݱ��������ţ����������������Ϊ���ţ���ȡ�䲹�룬����ͬ��
                    if(signed_div_i == 1'b1 && opdata1_i[31] == 1'b1) begin
                        temp_op1 = ~opdata1_i+1;       
                    end else begin
                        temp_op1 = opdata1_i;          
                    end
                    if(signed_div_i == 1'b1 && opdata2_i[31] == 1'b1) begin
                        temp_op2 = ~opdata2_i+1;
                    end else begin
                        temp_op2 = opdata2_i;
                    end
                    dividend <= {`ZeroWord, `ZeroWord};
                    dividend[32:1] <= temp_op1;
                    divisor <= temp_op2;          //���ñ�����
                 end
               end else begin
                ready_o <= `DivResultNotReady;
                result_o <= {`ZeroWord, `ZeroWord};
               end
             end
             //����Ϊ0���������,DivByZero��ֱ�ӽ�dividend����Ϊ0�����ҽ�state����Ϊ����DivEnd
         `DivByZero : begin
            dividend <= {`ZeroWord, `ZeroWord};
            state <= `DivEnd;
         end
         //������������������DivOn
         `DivOn: begin
         //�����ź�annul_iΪ1����ʾ������ȡ���������㣬��DIVģ��ֱ�ӻص�DivFree״̬
            if(annul_i == 1'b0) begin
            //�ڲ�����ֵ����32֮ǰ����ִ��
                if(cnt != 6'b100000) begin
                //���div_temp[32]Ϊ1�����ʾ���С��0����dividend����һλ�������ͽ���������û�в�����������λ�ӵ���һ�ε����ı������У�ͬʱ��0׷�ӵ��м���
                    if(div_temp[32] == 1'b1) begin
                        dividend <= {dividend[63:0] , 1'b0};
                    end else begin
                        dividend <= {div_temp[31:0] , dividend[31:0], 1'b1};
                    end
                    cnt <= cnt+1;   //�׶μ�һ
                 end else begin
                    if((signed_div_i == 1'b1) && ((opdata1_i[31] ^ opdata2_i[31]) == 1'b1)) begin
                        dividend[31:0] <= (~dividend[31:0] +1);
                    end
                    if((signed_div_i == 1'b1) && ((opdata1_i[31] ^ dividend[64]) == 1'b1)) begin
                        dividend[64:33] <=(~dividend[64:33] +1);
                    end
                    state<= `DivEnd;
                    cnt<= 6'b000000;
                  end
               end else begin
                state<= `DivFree;
               end
            end
          //�����������DivEnd
          `DivEnd : begin
            result_o <= {dividend[64:33], dividend[31:0]};
            ready_o <= `DivResultReady;
            if(start_i == `DivStop) begin
                state <= `DivFree;
                ready_o <= `DivResultNotReady;
                result_o <= {`ZeroWord, `ZeroWord};
              end
            end
          endcase
         end
        end
endmodule
                           
    

