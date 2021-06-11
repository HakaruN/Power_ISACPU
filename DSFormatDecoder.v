`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//Implements all Integer DS format instructions
//All output immediate optputs are to have 2 binary zeroes (2'b00) extended onto the right side before being sign extended to 64 bits.
//////////////////////////////////////////////////////////////////////////////////
module DSFormatDecoder#(parameter opcodeWidth = 6, parameter regWidth = 5, parameter immWidth = 14, parameter instructionWidth = 32
)(
	//command in
	input wire clock_i,
	input wire enable_i,
	//data in
	input wire [0:instructionWidth-1] instruction_i,
	//command out
	output reg stall_o,
	//data out
	output reg [0:regWidth-1] reg1_o, reg2_o,
	output reg reg2ValOrZero_o,//indicates that if the register addr is zero, a zero litteral is to be used not reg zero
	output reg [0:immWidth-1] imm_o,	
	output reg enable_o
	);
	
always @(posedge clock_i)
begin
	//Integer DS format instructions
	if(instruction_i[0:opcodeWidth-1] == 58 && enable_i == 1)
	begin
		reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15];
		imm_o <= instruction_i[16:29]; 
		case(instruction_i[30:31])		
			2: begin $display("Load Word Algebraic");				
				reg2ValOrZero_o <= 1;
				enable_o <= 1; stall_o <= 0;
			end
			0: begin $display("Load Doubleword");
				reg2ValOrZero_o <= 1;
				enable_o <= 1; stall_o <= 0;
			end
			1: begin $display("Load Doubleword with Update");
				reg2ValOrZero_o <= 0;
				enable_o <= 1; stall_o <= 0;
			end
			default begin $display("Invalid or unsupported instruction"); enable_o <= 0; end
		endcase
	end
	else if(instruction_i[0:opcodeWidth-1] == 62 && enable_i == 1)
	begin
		reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15];
		imm_o <= instruction_i[16:29];
		case(instruction_i[30:31])
			0: begin $display("Store Doubleword");
				reg2ValOrZero_o <= 1;
				enable_o <= 1; stall_o <= 0;
			end
			2: begin $display("Store Quadword");
				reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15];
				reg2ValOrZero_o <= 1;
				enable_o <= 1; stall_o <= 0;
			end
			1: begin $display("Store Doubleword with Update");
				reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15];
				reg2ValOrZero_o <= 0;
				enable_o <= 1; stall_o <= 0;
			end
			default begin $display("Invalid or unsupported instruction"); enable_o <= 0;  stall_o <= 0; end
		endcase
	end
	else
	begin
		enable_o <= 0;
		stall_o <= 0;
	end
end

endmodule
