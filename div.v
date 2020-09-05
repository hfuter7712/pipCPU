`include "de.v"

//div除法使用试商法，一共要进行32次
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
    reg[5:0] cnt;              //试商法进行到的步骤，当cnt=32时，表示试商法结束
    reg[64:0] dividend;       
     //dividend的低32位是被除数和中间结果，第k次迭代结束的时候dividend[k:0]保存的就是当前得到的中间结果 ，dividend[31:k+1]保存的就是被除数中还没有参与运算的数据  
    //dividend是每次迭代的被减数
    reg[1:0] state;
    reg[31:0] divisor;
    reg[31:0] temp_op1;
    reg[31:0] temp_op2;
    
    assign div_temp = {1'b0, dividend[63:32]} - {1'b0,divisor};     //临时存储除法结果
    
    always@ (posedge clk) begin
    if(rst==`RstEnable) begin
    state <= `DivFree;                  //设置状态为DivFree
    ready_o <= `DivResultNotReady;
    result_o <= {`ZeroWord, `ZeroWord};
    end else begin
        case(state)
        //除法模块空闲，DivFree
        `DivFree: begin
            if(start_i == `DivStart && annul_i == 1'b0) begin
                if(opdata2_i == `ZeroWord) begin    //除数为0时，设置状态为DivByZero
                    state <= `DivByZero;
                end else begin                       //否则设置为DivOn
                    state <= `DivOn;
                    cnt<= 6'b000000;
                    //根据被除数符号，来处理，如果被除数为符号，则取其补码，除数同理
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
                    divisor <= temp_op2;          //设置被除数
                 end
               end else begin
                ready_o <= `DivResultNotReady;
                result_o <= {`ZeroWord, `ZeroWord};
               end
             end
             //除数为0的特殊情况,DivByZero，直接将dividend设置为0，并且将state设置为结束DivEnd
         `DivByZero : begin
            dividend <= {`ZeroWord, `ZeroWord};
            state <= `DivEnd;
         end
         //除法运算正在运行中DivOn
         `DivOn: begin
         //输入信号annul_i为1，表示处理器取消除法运算，则DIV模块直接回到DivFree状态
            if(annul_i == 1'b0) begin
            //在步骤数值到达32之前持续执行
                if(cnt != 6'b100000) begin
                //如果div_temp[32]为1，则表示结果小于0，将dividend左移一位，这样就将被除数还没有参与运算的最高位加到下一次迭代的被减数中，同时将0追加到中间结果
                    if(div_temp[32] == 1'b1) begin
                        dividend <= {dividend[63:0] , 1'b0};
                    end else begin
                        dividend <= {div_temp[31:0] , dividend[31:0], 1'b1};
                    end
                    cnt <= cnt+1;   //阶段加一
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
          //除法运算结束DivEnd
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
                           
    

