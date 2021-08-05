`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//This module is mearly a collection of the functional units, it has no logic of it's own
//the idea is that it just allows the functional units to be cleanly grouped
//////////////////////////////////////////////////////////////////////////////////
module Execution#(parameter addressSize = 64,
parameter regWidth = 5, parameter regImm = 0, parameter immWith = 24, parameter opcodeWidth = 6, parameter xOpCodeWidth = 10, parameter formatIndexRange = 5,
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
	input wire [0:2] functionalUnitCode_i,
	input wire [0:63] operand1_i, operand2_i, operand3_i,
	input wire [0:regWidth-1] reg1Address_i, reg2Address_i, reg3Address_i,
	input wire [0:immWith-1] imm_i,
	input wire bit1_i, bit2_i,
	input wire operand1Writeback_i, operand2Writeback_i, operand3Writeback_i,
	input wire [0:63] instructionAddress_i,
	input wire [0:opcodeWidth-1] opCode_i,
	input wire [0:xOpCodeWidth-1] xOpCode_i,
	input wire [0:formatIndexRange-1] instructionFormat_i,
	input wire [32:63] condReg_i,
	//command out
	output wire loadStoreStall, output wire branchStall, output wire isBranching_o,
	output wire [0:addressSize-1] pc_o,
	//reg writebacks
	output wire [0:2] functionalUnitCode_o,
	output wire reg1WritebackEnable_o, reg2WritebackEnable_o,
	output wire [0:regWidth-1] reg1WritebackAddress_o, reg2WritebackAddress_o,
	output wire [0:63] reg1WritebackVal_o, reg2WritebackVal_o,
	output wire condRegUpdateEnable_o,
	output wire [32:63] newCRVal_o
);
	
	wire FXOutputEnable;
	wire [0:2] FXFunctionalUnitCode;
	wire FXRegWritebackEnable, FXCondRegUpdateEnable;
	wire [0:regWidth-1] FXReg1WritebackAddress, FXCondRegBits;
	wire [0:addressSize-1] FXReg1WritebackValue, FXOverFlowUnderFlow;
	//FX (Integer) unit
	FXUnit fxunit(
		//command
		.clock_i(clock_i),
		.reset_i(reset_i),
		.enable_i(enable_i),
		//data in
		.condReg_i(condReg_i),
		.is64Bit_i(is64Bit_i),
		.functionalUnitCode_i(functionalUnitCode_i),
		.operand1_i(operand1_i), .operand2_i(operand2_i), .operand3_i(operand3_i),
		.reg1Address_i(reg1Address_i), .reg2Address_i(reg2Address_i), .reg3Address_i(reg3Address_i),
		.imm_i(imm_i),
		.bit1_i(bit1_i), .bit2_i(bit2_i),
		.operand1Writeback_i(operand1Writeback_i), .operand2Writeback_i(operand2Writeback_i), .operand3Writeback_i(operand3Writeback_i),
		.instructionAddress_i(instructionAddress_i),
		.opCode_i(opCode_i),
		.xOpCode_i(xOpCode_i),
		.instructionFormat_i(instructionFormat_i),
		//outputs
		.functionalUnitCode_o(FXFunctionalUnitCode),
		.reg1WritebackEnable_o(FXRegWritebackEnable), .reg2WritebackEnable_o(FXCondRegUpdateEnable),//reg2 enable condition reg writeEnable
		.reg1WritebackAddress_o(FXReg1WritebackAddress), .reg2WritebackAddress_o(FXCondRegBits),//reg2 address is used to write back the condition reg bits
		.reg1WritebackVal_o(FXReg1WritebackValue), .reg2WritebackVal_o(FXOverFlowUnderFlow)//reg2 val is overflow/underflow bits	
	);
	
	
	wire LSOutputEnable;
	wire [0:2] LSFunctionalUnitCode;
	wire LSReg1WritebackEnable, LSReg2WritebackEnable;
	wire [0:regWidth-1] LSReg1WritebackAddress, LSReg2WritebackAddress;
	wire [0:addressSize-1] LSReg1WritebackValue, LSReg2WritebackValue;
		
	//LoadStore unit
	LoadStoreUnit loadStoreUnit(
	//command
	.clock_i(clock_i),
	.reset_i(reset_i),
	.enable_i(enable_i),
	//data in
	.functionalUnitCode_i(functionalUnitCode_i),
	.opCode_i(opCode_i),
	.xOpCode_i(xOpCode_i),
	.instructionFormat_i(instructionFormat_i),
	.operand1_i(operand1_i), .operand2_i(operand2_i), .operand3_i(operand3_i),
	.reg1Address_i(reg1Address_i), .reg2Address_i(reg2Address_i),
	.imm_i(imm_i),
	//command out
	.stall_o(loadStoreStall),
	//data out
	.functionalUnitCode_o(LSFunctionalUnitCode),
	.reg1WritebackEnable_o(LSReg1WritebackEnable), .reg2WritebackEnable_o(LSReg2WritebackEnable),
	.reg1WritebackAddress_o(LSReg1WritebackAddress), .reg2WritebackAddress_o(LSReg2WritebackAddress),
	.reg1WritebackVal_o(LSReg1WritebackValue), .reg2WritebackVal_o(LSReg2WritebackValue)
	);
	
	BranchUnit branchUnit(
	//command
	.clock_i(clock_i),
	.reset_i(reset_i),
	.stall_i(),
	.enable_i(enable_i),
	//data in
	//registers
	.is64Bit_i(is64Bit_i),
	//instruction data
	.condReg_i(condReg_i),
	.operand1_i(operand1_i[0:4]), .operand2_i(operand2_i[0:4]), .operand3_i(operand3_i[0:1]),
	.imm_i(imm_i),
	.bit1_i(bit1_i), .bit2_i(bit2_i),
	.functionalUnitCode_i(functionalUnitCode_i),
	.instructionAddress_i(instructionAddress_i),
	.opCode_i(opCode_i),
	.xOpCode_i(xOpCode_i),
	.instructionFormat_i(instructionFormat_i),
	//data out
	.isBranching_o(isBranching_o),
	.PC_o(pc_o)
	);	
	
	//writeback merge queue
	WritebackMux writebackMux
	(
		//command
		.clock_i(clock_i),
		.reset_i(reset_i),
		//FX unit in
		.FXFunctionalUnitCode_i(FXFunctionalUnitCode),
		.FXRegWritebackEnable_i(FXRegWritebackEnable), .FXCondRegUpdateEnable_i(FXCondRegUpdateEnable),
		.FXReg1WritebackAddress_i(FXReg1WritebackAddress), .FXCondRegBits_i(FXCondRegBits),
		.FXReg1WritebackValue_i(FXReg1WritebackValue), .FXOverFlowUnderFlow_i(FXOverFlowUnderFlow),
		//LS unit in
		.LSFunctionalUnitCode_i(LSFunctionalUnitCode),
		.LSReg1WritebackEnable_i(LSReg1WritebackEnable), .LSReg2WritebackEnable_i(LSReg2WritebackEnable),
		.LSReg1WritebackAddress_i(LSReg1WritebackAddress), .LSReg2WritebackAddress_i(LSReg2WritebackAddress),
		.LSReg1WritebackValue_i(LSReg1WritebackValue), .LSReg2WritebackValue_i(LSReg2WritebackValue),
		//outputs
		.functionalUnitCode_o(functionalUnitCode_o),
		.reg1WritebackEnable_o(reg1WritebackEnable_o), .reg2WritebackEnable_o(reg2WritebackEnable_o),
		.reg1WritebackAddress_o(reg1WritebackAddress_o), .reg2WritebackAddress_o(reg2WritebackAddress_o),
		.reg1WritebackVal_o(reg1WritebackVal_o), .reg2WritebackVal_o(reg2WritebackVal_o)
	);
endmodule
