`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
module DecodeUnit#( parameter instructionWidth = 32, parameter addressSize = 64, opcodeWidth = 6, parameter formatIndexRange = 5,
parameter A = 1, parameter B = 2, parameter D = 3, parameter DQ = 4, parameter DS = 5, parameter DX = 6, parameter I = 7, parameter M = 8,
parameter MD = 9, parameter MDS = 10, parameter SC = 11, parameter VA = 12, parameter VC = 13, parameter VX = 14, parameter X = 15, parameter XFL = 16,
parameter XFX = 17, parameter XL = 18, parameter XO = 19, parameter XS = 20, parameter XX2 = 21, parameter XX3 = 22, parameter XX4 = 23, parameter Z22 = 24,
parameter Z23 = 25, parameter INVALID = 0
)(
	//command	
	input wire clock_i,
	input wire reset_i,
	input wire enable_i,
	//data in
	input wire [0:instructionWidth-1] instruction_i,
	input wire [0:addressSize-1] instructionAddress_i
	);
	
	//Instruction format-class decoder
	wire [0:opcodeWidth-1] FormClassDecodeopCode;
	wire [0:opcodeWidth-instructionWidth-1] FormClassDecodePayload;
	wire [0:addressSize-1] FormClassDecodeAddress;
	wire [0:formatIndexRange-1] FormClassDecodeInstructionFormatClass;
	wire FormClassDecodeEnable;
	
	InstructionFormatClassDecode #( .instructionWidth(instructionWidth),  .addressSize(addressSize), .opcodeWidth(opcodeWidth),  .formatIndexRange(formatIndexRange),
 .A(A), .B(B), .D(D), .DQ(DQ), .DS(DS), .DX(DX), .I(I), .M(M), .MD(MD), .MDS(MDS), .SC(SC), .VA(VA), .VC(VC), .VX(VX), .X(X), .XFL(XFL),
 .XFX(XFX), .XL(XL), .XO(XO), .XS(XS), .XX2(XX2), .XX3(XX3), .XX4(XX4), .Z22(Z22), .Z23(Z23), .INVALID(INVALID) ) instructionFormatDecode
	(
	//command
	.clock_i(clock_i),
	.enable_i(enable_i),
	//data in
	.instruction_i(instruction_i),
	.address_i(instructionAddress_i),
	//output
	.opCode_o(FormClassDecodeopCode),
	.payload_o(FormClassDecodePayload),
	.address_o(FormClassDecodeAddress),
	.instructionFormatClass_o(FormClassDecodeInstructionFormatClass),
	.enable_o(FormClassDecodeEnable)
	);
	
	//instruction format decoder
	

endmodule
