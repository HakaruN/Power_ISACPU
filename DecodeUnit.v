`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//Decodes the instructions, atm it supports:
//branch, fixed point
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
	input wire [0:addressSize-1] instructionAddress_i
	);
	
	
	

endmodule
