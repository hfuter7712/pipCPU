`include "de.v"
module ctrl(
	input wire rst,
	input wire stall_id,
	input wire stall_ex,
	output reg[5:0] stall
	);
	
	always @ (*) begin
	if(rst == `RstEnable) begin
	stall <= 6'b000000;
	end else if(stall_ex == `Stop) begin
	stall <= 6'b001111;
	end else if(stall_id == `Stop) begin
	stall <= 6'b000111;
	end else begin 
	stall <= 6'b000000;
	end
  end
 endmodule