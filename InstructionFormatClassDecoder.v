`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//This stage decodes what the instructions format is.
//There are 25 instrucion formats in total therefore 5 bits must be used to address them all (4 < log'base2 25 < 5)
//The formats are: A, B, D, DQ, DS, DX, I, M, MD, MDS, SC, VA, VC, VX, X, XFL, XFX, XL, XO, XS, XX2, XX3, XX4, Z22, Z23
//At this stage we cannot tell the exact format however as many share opcodes therefore we will identify the format class
//These are: B, D, DQ, DS, DX, MD, M, VA, X. This list may be incomplete however.
//////////////////////////////////////////////////////////////////////////////////
module InstructionFormatDecode#( parameter instructionWidth = 32, parameter addressSize = 64, opcodeWidth = 6, parameter formatIndexRange = 5,
parameter A = 1, parameter B = 2, parameter D = 3, parameter DQ = 4, parameter DS = 5, parameter DX = 6, parameter I = 7, parameter M = 8,
parameter MD = 9, parameter MDS = 10, parameter SC = 11, parameter VA = 12, parameter VC = 13, parameter VX = 14, parameter X = 15, parameter XFL = 16,
parameter XFX = 17, parameter XL = 18, parameter XO = 19, parameter XS = 20, parameter XX2 = 21, parameter XX3 = 22, parameter XX4 = 23, parameter Z22 = 24,
parameter Z23 = 25, parameter INVALID = 0
)(
	//command
	input wire clock_i,
	input wire enable_i,
	//data in
	input wire [0:instructionWidth-1] instruction_i,
	input wire [0:addressSize-1] address_i,
	//data out
	output reg [0:opcodeWidth-1] opCode_o,
	output reg [0:opcodeWidth-instructionWidth-1] payload_o,
	output reg [0:addressSize-1] address_o,
	output reg [0:formatIndexRange-1] instructionFormatClass_o,
	output reg enable_o
	);

	always @(posedge clock_i)
	begin
		if(enable_i == 1)
		begin
			//parse the opcode and address out
			opCode_o <= instruction_i[0:opcodeWidth-1];
			payload_o <= instruction_i[opcodeWidth:instructionWidth-1];
			address_o <= address_i;
			enable_o <= 1;
			//figure out the instruction format (This uses a table)
			case(instruction_i[0:opcodeWidth-1])//case on the opcode
				//D format
				34: instructionFormatClass_o <= 3;
				35: instructionFormatClass_o <= 3;
				40: instructionFormatClass_o <= 3;
				41: instructionFormatClass_o <= 3;
				42: instructionFormatClass_o <= 3;
				43: instructionFormatClass_o <= 3;
				32: instructionFormatClass_o <= 3;
				33: instructionFormatClass_o <= 3;
				38: instructionFormatClass_o <= 3;
				39: instructionFormatClass_o <= 3;
				44: instructionFormatClass_o <= 3;
				45: instructionFormatClass_o <= 3;
				36: instructionFormatClass_o <= 3;
				37: instructionFormatClass_o <= 3;
				46: instructionFormatClass_o <= 3;
				47: instructionFormatClass_o <= 3;
				14: instructionFormatClass_o <= 3;
				15: instructionFormatClass_o <= 3;
				12: instructionFormatClass_o <= 3;
				13: instructionFormatClass_o <= 3;
				8: instructionFormatClass_o <= 3;
				7: instructionFormatClass_o <= 3;
				11: instructionFormatClass_o <= 3;
				10: instructionFormatClass_o <= 3;
				3: instructionFormatClass_o <= 3;
				2: instructionFormatClass_o <= 3;
				28: instructionFormatClass_o <= 3;
				29: instructionFormatClass_o <= 3;
				24: instructionFormatClass_o <= 3;
				25: instructionFormatClass_o <= 3;
				26: instructionFormatClass_o <= 3;
				27: instructionFormatClass_o <= 3;
				//DS
				58: instructionFormatClass_o <= 5;
				62: instructionFormatClass_o <= 5;
				//DQ
				56: instructionFormatClass_o <= 4;
				//DX
				19: instructionFormatClass_o <= 6;
				//MD
				30: instructionFormatClass_o <= 9;
				//X
				31: instructionFormatClass_o <= 15;
				//M
				21: instructionFormatClass_o <= 8;
				23: instructionFormatClass_o <= 8;
				20: instructionFormatClass_o <= 8;
				//VA
				4: instructionFormatClass_o <= 12;
				default: instructionFormatClass_o <= 0;
			endcase
			
		end
		else
			enable_o <= 0;
	end

endmodule