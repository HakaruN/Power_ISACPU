`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//This module is mearly a collection of the functional units, it has no logic of it's own
//the idea is that it just allows the functional units to be cleanly grouped
//////////////////////////////////////////////////////////////////////////////////
module Execution#(
parameter regWidth = 5, parameter regImm = 0, parameter immWith = 16, parameter opcodeWidth = 6, parameter xOpCodeWidth = 10, parameter formatIndexRange = 5,
parameter A = 1, parameter B = 2, parameter D = 3, parameter DQ = 4, parameter DS = 5, parameter DX = 6, parameter I = 7, parameter M = 8,
parameter MD = 9, parameter MDS = 10, parameter SC = 11, parameter VA = 12, parameter VC = 13, parameter VX = 14, parameter X = 15, parameter XFL = 16,
parameter XFX = 17, parameter XL = 18, parameter XO = 19, parameter XS = 20, parameter XX2 = 21, parameter XX3 = 22, parameter XX4 = 23, parameter Z22 = 24,
parameter Z23 = 25, parameter INVALID = 0,
parameter FXUnitCode = 0, parameter FPUnitCode = 1, parameter LdStUnitCode = 2, parameter BranchUnitCode = 3, parameter TrapUnitCode = 4//functional unit code/ID used for dispatch
)(
	//command
	input wire clock_i,
	input wire reset_i,
	//from reg read
	input wire enable_i,
	input wire is64Bit_i,
	input wire [0:1] functionalUnitCode_i,
	input wire [0:63] operand1_i, operand2_i, operand3_i,
	input wire [0:regWidth-1] reg1Address_i, reg2Address_i, reg3Address_i,
	input wire [0:immWith-1] imm_i,
	input wire immEnable_i,
	input wire bit1_i, bit2_i,
	input wire operand1Enable_i, operand2Enable_i, operand3Enable_i, bit1Enable_i, bit2Enable_i,
	input wire operand1Writeback_i, operand2Writeback_i, operand3Writeback_i,
	input wire [0:63] instructionAddress_i,
	input wire [0:opcodeWidth-1] opCode_i,
	input wire [0:xOpCodeWidth-1] xOpCode_i,
	input wire xOpCodeEnabled_i,
	input wire [0:formatIndexRange-1] instructionFormat_i,
	//command out
	output wire loadStoreStall, output wire branchStall,
	//reg writebacks
	output wire [0:1] functionalUnitCode_o,
	output wire reg1WritebackEnable_o, reg2WritebackEnable_o,
	output wire [0:5] reg1WritebackAddress_o, reg2WritebackAddress_o,
	output wire [0:63] reg1WritebackVal_o, reg2WritebackVal_o
);
	
	FXUnit fxunit(
		//command
		.clock_i(clock_i),
		.reset_i(reset_i),
		.enable_i(enable_i),
		//data in
		.is64Bit_i(is64Bit_i),
		.functionalUnitCode_i(functionalUnitCode_i),
		.operand1_i(operand1_i), .operand2_i(operand2_i), .operand3_i(operand3_i),
		.reg1Address_i(reg1Address_i), .reg2Address_i(reg2Address_i), .reg3Address_i(reg3Address_i),
		.imm_i(imm_i),
		.immEnable_i(immEnable_i),
		.bit1_i(bit1_i), .bit2_i(bit2_i),
		.operand1Enable_i(operand1Enable_i), .operand2Enable_i(operand2Enable_i), .operand3Enable_i(operand3Enable_i), .bit1Enable_i(bit1Enable_i), .bit2Enable_i(bit2Enable_i),
		.operand1Writeback_i(operand1Writeback_i), .operand2Writeback_i(operand2Writeback_i), .operand3Writeback_i(operand3Writeback_i),
		.instructionAddress_i(instructionAddress_i),
		.opCode_i(opCode_i),
		.xOpCode_i(xOpCode_i),
		.xOpCodeEnabled_i(xOpCodeEnabled_i),	
		.instructionFormat_i(instructionFormat_i),
		//outputs
		.conditionRegWriteEnable_o(),//tells the reg file to update the CR at writeback with the instruction
		.outputEnable_o(),
		.overflow_o(),
		.conditionRegisterBits_o(),
		.is64Bit_o(),
		.regWritebackAddress_o(),
		.regWritebackVal_o(),
		.functionalUnitCode_o()
	);
	
	LoadStoreUnit loadStoreUnit(
	//command
	.clock_i(clock_i),
	.reset_i(reset_i),
	.enable_i(enable_i),
	//data in
	.functionalUnitCode_i(functionalUnitCode_i),
	.instructionAddress_i(instructionAddress_i),
	.opCode_i(opCode_i),
	.xOpCode_i(xOpCode_i),
	.xOpCodeEnabled_i(xOpCodeEnabled_i),	
	.instructionFormat_i(instructionFormat_i),
	.operand1_i(operand1_i), .operand2_i(operand2_i), .operand3_i(operand3_i),
	.reg1Address_i(reg1Address_i), .reg2Address_i(reg2Address_i), .reg3Address_i(reg3Address_i),
	.imm_i(imm_i),
	//command out
	.stall_o(loadStoreStall),
	//data out
	.outputEnable_o(),
	.functionalUnitCode_o(),
	.reg1WritebackEnable_o(), .reg2WritebackEnable_o(),
	.reg1WritebackAddress_o(), .reg2WritebackAddress_o(),
	.reg1WritebackVal_o(), .reg2WritebackVal_o()
	);



endmodule
