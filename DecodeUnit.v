`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//Decodes the instructions, atm it supports:
//branch, fixed point
//Stage one consists of parallel stage one decoders which all take the fetched instruction and attempt to decode based on their specific format
//Each decoder has unique ouptputs that is specific to the decoder's format.
//Stage two takes in the decoders outputs, applies implicit operations based on the format (sign extention, bit concatinations etc) and multiplexes the output
//to the next pipeline stage
//////////////////////////////////////////////////////////////////////////////////
module DecodeUnit#( parameter instructionWidth = 32, parameter addressSize = 64, parameter formatIndexRange = 5,
parameter A = 1, parameter B = 2, parameter D = 3, parameter DQ = 4, parameter DS = 5, parameter DX = 6, parameter I = 7, parameter M = 8,
parameter MD = 9, parameter MDS = 10, parameter SC = 11, parameter VA = 12, parameter VC = 13, parameter VX = 14, parameter X = 15, parameter XFL = 16,
parameter XFX = 17, parameter XL = 18, parameter XO = 19, parameter XS = 20, parameter XX2 = 21, parameter XX3 = 22, parameter XX4 = 23, parameter Z22 = 24,
parameter Z23 = 25, parameter INVALID = 0,
parameter opcodeWidth = 6, parameter xOpCodeWidth = 10, parameter regWidth = 5, parameter immWidth = 16
)(
	//command	
	input wire clock_i,
	input wire reset_i,
	input wire enable_i,
	//data in
	input wire [0:instructionWidth-1] instruction_i,
	input wire [0:addressSize-1] instructionAddress_i,
	//data out
	output wire [0:opcodeWidth-1] opCode,
	output wire [0:regWidth-1] reg1, reg2, reg3, reg4,
	output wire reg2ValOrZero,
	output wire bit1, bit2,
	output wire [0:63] imm,
	//output enables
	output wire DFormatEnable, DSormatEnable, DQormatEnable, XFormatEnable
	);

	///Stage 1 - parallel decoders:
	//D format instruction decoder
	DFormatDecoder
	dFormatDecoder(
	//command
	.clock_i(clock_i),
	.enable_i(enable_i),
	//data in
	.instruction_i(instruction_i),
	.address_i(instructionAddress_i),
	//data out
	.opcode_o(opCode),
	.reg1_o(reg1), .reg2_o(reg2),
	.reg2ValOrZero_o(reg2ValOrZero),
	.imm_o(imm),
	.enable_o(DFormatEnable)
	);
	
	//DQ format instruction decoder
	DQFormatDecoder
	dQFormatDecoder(
	//command
	.clock_i(clock_i),
	.enable_i(enable_i),
	//data in
	.instruction_i(instruction_i),
	.address_i(instructionAddress_i),
	//data out
	.opcode_o(opCode),
	.reg1_o(reg1), .reg2_o(reg2),
	.reg2ValOrZero_o(reg2ValOrZero),
	.imm_o(imm),
	.bit_o(bit1),
	.enable_o(DQormatEnable)
	);
	
	//DS format instruction decoder
	DSFormatDecoder
	dSFormatDecoder(
	//command
	.clock_i(clock_i),
	.enable_i(enable_i),
	//data in
	.instruction_i(instruction_i),
	.address_i(instructionAddress_i),
	//data out
	.opcode_o(opCode),
	.reg1_o(reg1), .reg2_o(reg2),
	.reg2ValOrZero_o(reg2ValOrZero),
	.imm_o(imm),
	.enable_o(DSFormatEnableO)
	);
	
	//X format instruction decoder
	XFormatDecoder
	xFormatDecoder(
	//command
	.clock_i(clock_i),
	.enable_i(enable_i),
	//data in
	.instruction_i(instruction_i),
	.address_i(instructionAddress_i),
	//data out
	.opcode_o(opCode),
	.reg1_o(reg1), .reg2_o(reg2), .reg3_o(reg3),
	.reg2ValOrZero_o(reg2ValOrZero),
	.imm_o(imm),
	.bit1_o(bit1), .bit2_o(bit2),
	.enable_o(XFormatEnable)
	);
	
	//Stage 2 - decoder output mux
	


endmodule
