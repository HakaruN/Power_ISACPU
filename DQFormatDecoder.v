`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//Implements all DQ instructions in the PowerISE 3.0B
//////////////////////////////////////////////////////////////////////////////////
module DQFormatDecoder#( parameter instructionWidth = 32, parameter addressSize = 64, parameter formatIndexRange = 5,
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
	output reg bit_o,
	output reg enable_o
	);

	always @(posedge clock_i)
	begin
		if(instruction_i[0:opcodeWidth-1] == 56 && enable_i == 1)
		begin $display("Load Quadword");
			reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15];
			reg2ValOrZero_o <= 1;
			imm_o <= $signed({instruction_i[16:27], 4'b0000});
			opcode_o <= instruction_i[0:opcodeWidth-1];
			enable_o <= 1;
		end
		else if(instruction_i[0:opcodeWidth-1] == 61 && enable_i == 1)
		begin
			case(instruction_i[29:31])
			1: begin $display("Load VSX Vector");
				reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15];
				reg2ValOrZero_o <= 1;
				imm_o <= $signed({instruction_i[16:27], 4'b0000});
				bit_o <= instruction_i[28];
				opcode_o <= instruction_i[0:opcodeWidth-1];
				enable_o <= 1;
			end
			2: begin $display("Store VSX Vector");
				reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15];
				reg2ValOrZero_o <= 1;
				imm_o <= $signed({instruction_i[16:27], 4'b0000});
				bit_o <= instruction_i[28];
				opcode_o <= instruction_i[0:opcodeWidth-1];
				enable_o <= 1;
			end
			endcase
		end
		else
			enable_o <= 0;
	end

endmodule
