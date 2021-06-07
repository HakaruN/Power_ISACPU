`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//Implements all Integer DS format instructions
//////////////////////////////////////////////////////////////////////////////////
module DSFormatDecoder#( parameter instructionWidth = 32, parameter addressSize = 64, parameter formatIndexRange = 5,
parameter A = 1, parameter B = 2, parameter D = 3, parameter DQ = 4, parameter DS = 5, parameter DX = 6, parameter I = 7, parameter M = 8,
parameter MD = 9, parameter MDS = 10, parameter SC = 11, parameter VA = 12, parameter VC = 13, parameter VX = 14, parameter X = 15, parameter XFL = 16,
parameter XFX = 17, parameter XL = 18, parameter XO = 19, parameter XS = 20, parameter XX2 = 21, parameter XX3 = 22, parameter XX4 = 23, parameter Z22 = 24,
parameter Z23 = 25, parameter INVALID = 0, parameter unsignedImm = 1, parameter signedImm = 2, parameter signedImmExt = 3,
parameter opcodeWidth = 6, parameter xOpCodeWidth = 10, parameter regWidth = 5, parameter immWidth = 16
)(
	//command
	input wire clock_i,
	input wire enable_i,
	//data in
	input wire [0:instructionWidth-1] instruction_i,
	input wire [0:addressSize-1] address_i,
	//data out
	output reg [0:opcodeWidth-1] opcode_o,
	output reg [0:regWidth-1] reg1_o, reg2_o,
	output reg reg2ValOrZero_o,//indicates that if the register addr is zero, a zero litteral is to be used not reg zero
	output reg [0:63] imm_o,
	output reg enable_o
	);
	
always @(posedge clock_i)
begin
	opcode_o <= instruction_i[0:opcodeWidth-1];
	//Integer DS format instructions
	if(instruction_i[0:opcodeWidth-1] == 58 && enable_i == 1)
	begin
		case(instruction_i[30:31])
			2: begin $display("Load Word Algebraic");
				reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15];
				imm_o <= $signed({instruction_i[16:29], 2'b00}); reg2ValOrZero_o <= 1;
				enable_o <= 1;
			end
			0: begin $display("Load Doubleword");
				reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15];
				imm_o <= $signed({instruction_i[16:29], 2'b00}); reg2ValOrZero_o <= 1;
				enable_o <= 1;
			end
			1: begin $display("Load Doubleword with Update");
				reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15];
				imm_o <= $signed({instruction_i[16:29], 2'b00}); reg2ValOrZero_o <= 0;
				enable_o <= 1;
			end
			default begin $display("Invalid or unsupported instruction"); enable_o <= 0; end
		endcase
	end
	else if(instruction_i[0:opcodeWidth-1] == 62 && enable_i == 1)
	begin
		case(instruction_i[30:31])
			0: begin $display("Store Doubleword");
				reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15];
				imm_o <= $signed({instruction_i[16:29], 2'b00}); reg2ValOrZero_o <= 1;
				enable_o <= 1;
			end
			2: begin $display("Store Quadword");
				reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15];
				imm_o <= $signed({instruction_i[16:29], 2'b00}); reg2ValOrZero_o <= 1;
				enable_o <= 1;
			end
			1: begin $display("Store Doubleword with Update");
				reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15];
				imm_o <= $signed({instruction_i[16:29], 2'b00}); reg2ValOrZero_o <= 0;
				enable_o <= 1;
			end
			default begin $display("Invalid or unsupported instruction"); enable_o <= 0; end
		endcase
	end
	else
		enable_o <= 0;
end

endmodule
