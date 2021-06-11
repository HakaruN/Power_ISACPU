`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
module RegisterUnit #(parameter instructionWidth = 32, parameter addressSize = 64, parameter formatIndexRange = 5,
parameter opcodeWidth = 6, parameter xOpCodeWidth = 10, parameter immWith = 16, parameter regWidth = 5, parameter formatIndexRange = 5,
parameter A = 1, parameter B = 2, parameter D = 3, parameter DQ = 4, parameter DS = 5, parameter DX = 6, parameter I = 7, parameter M = 8,
parameter MD = 9, parameter MDS = 10, parameter SC = 11, parameter VA = 12, parameter VC = 13, parameter VX = 14, parameter X = 15, parameter XFL = 16,
parameter XFX = 17, parameter XL = 18, parameter XO = 19, parameter XS = 20, parameter XX2 = 21, parameter XX3 = 22, parameter XX4 = 23, parameter Z22 = 24,
parameter Z23 = 25, parameter INVALID = 0 )(
	//command in
	input wire clock_i,
	input wire resset_i,
	//data in (reg read)
	input wire enable_i,
	input wire [0:immWith-1] imm_i,
	input wire [0:regWidth-1] reg1_i, reg2_i, reg3_i,
	input wire bit1_i, bit2_i,
	input wire immEnable_i, reg1Enable_i, reg2Enable_i, reg3Enable_i, bit1Enabled_i, bit2Enabled_i,
	input wire [0:1] reg1Use_i, reg2Use_i, reg3Use_i,
	input wire reg3IsImmediate_i,
	input wire reg2ValOrZero_i,
	input wire [0:addressSize-1] instructionAddress_i,
	input wire [0:opcodeWidth-1] opCode_i,
	input wire [0:xOpCodeWidth-1] xOpcode_o,
	input wire xOpCodeEnabled_i,
	input wire [0:formatIndexRange-1] instructionFormat_i
	//data in (reg writeback)
	//data out (reg read)
	
    );


endmodule
