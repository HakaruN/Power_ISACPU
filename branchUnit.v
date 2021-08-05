`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//Implemented:
//This unit implements all branch instructions, it however does not implement the Condition register instructions
//or the system call instructions (as system calls are not implemented (yet))
//NOTE: Each branch instruction branches by the target offset + 4
//This unit operates a three stage pipeline
//The first stage parses the instruction, calculates branch offsets and resolves if the instruction is a conditional branch or not
//The second stage resolves the condition to see if the branch is to be taken or not
//The thirst stage commits the changes to the CPU state
//NOTE: 
//The branch unit makes no use about the hints given with branch instructions.
//There is an optimisation made to remove the repeated CountReg subtractions made in stage 2 where stage 1 generates two values of the 
//Count reg, one is the current value and the other is the current value decremented. This allows the second stage to use either where apropriate.
//This simpler hardware increased the theoretical clockrate of this unit on my FPGA from ~85Mhz to ~123Mhz
//////////////////////////////////////////////////////////////////////////////////
module BranchUnit#(
//operating parameters
parameter resetVector = 0,
//data widths
parameter immWith = 24, parameter regWidth = 5, parameter numRegs = 2**regWidth, parameter formatIndexRange = 5, parameter addressWidth = 64, parameter opcodeWidth = 6, parameter xOpCodeWidth = 10,
//functional unit codes
parameter FXUnitCode = 0, parameter FPUnitCode = 1, parameter LdStUnitCode = 2, parameter BranchUnitCode = 3, parameter TrapUnitCode = 4,
//Instruction formats
parameter A = 1, parameter B = 2, parameter D = 3, parameter DQ = 4, parameter DS = 5, parameter DX = 6, parameter I = 7, parameter M = 8,
parameter MD = 9, parameter MDS = 10, parameter SC = 11, parameter VA = 12, parameter VC = 13, parameter VX = 14, parameter X = 15, parameter XFL = 16,
parameter XFX = 17, parameter XL = 18, parameter XO = 19, parameter XS = 20, parameter XX2 = 21, parameter XX3 = 22, parameter XX4 = 23, parameter Z22 = 24,
parameter Z23 = 25, parameter INVALID = 0
)(
	//command
	input wire clock_i,
	input wire reset_i,
	input wire stall_i,
	input wire enable_i,
	//data in
	//registers
	input wire is64Bit_i,
	//instruction data
	input wire [32:63] condReg_i,
	input wire [0:4] operand1_i, operand2_i,
	input wire [0:1] operand3_i,	
	input wire [0:immWith-1] imm_i,
	input wire bit1_i, bit2_i,
	input wire [0:2] functionalUnitCode_i,
	input wire [0:63] instructionAddress_i,
	input wire [0:opcodeWidth-1] opCode_i,
	input wire [0:xOpCodeWidth-1] xOpCode_i,
	input wire [0:formatIndexRange-1] instructionFormat_i,
	//command out
	output reg isBranching_o,//tells the flush unit to flush the pipeline
	output reg [0:addressWidth-1] branchInstructionAddress_o,//this is used to tell branch prediction what the PC of the current branch instruction is
	output reg [0:addressWidth-1] PC_o
	);
	
	reg [0:addressWidth-1] PC;
	//Maybe these should be moved to the reg file
	reg [0:addressWidth-1] linkReg;//LKR
	reg [0:addressWidth-1] countReg;//CRT
	reg [0:addressWidth-1] TargetAddrReg;//TAR
	
	
	
	//Stage 1 outputs
	wire isConditional;
	wire [0:4] BO;
	wire [0:5] BI;
	wire [0:1] BH;
	wire [32:addressWidth-1] conditionRegVal;
	wire LK;
	wire [0:addressWidth-1] CIA;
	wire [0:addressWidth-1] branchOffset;
	wire [0:addressWidth-1] currentCountReg, currentCountRegMinusOne;
	wire is64Bit;	
	
	//Stage 1 of the branch unit
	BranchStage1 branchStage1(
	//command
	.clock_i(clock_i), .reset_i(reset_i),
	.stall_i(stall_i), .enable_i(enable_i),
	//Reg data in
	.is64Bit_i(is64Bit_i), 
	.countReg_i(countReg), .linkReg_i(linkReg), .TargetAddrReg_i(TargetAddrReg),
	//instruction data in
	.condReg_i(condReg_i),
	.operand1_i(operand1_i), .operand2_i(operand2_i),
	.operand3_i(operand3_i),
	.imm_i(imm_i),
	.Bit1_i(bit1_i), .Bit2_i(bit2_i),
	.functionalUnitCode_i(functionalUnitCode_i),
	.instructionAddress_i(instructionAddress_i),
	.opCode_i(opCode_i),
	.xOpCode_i(xOpCode_i),
	.instructionFormat_i(instructionFormat_i),
	//data out
	.isConditional_o(isConditional),
	.BO_o(BO), .BI_o(BI),
	.BH_o(BH),
	.conditionRegVal_o(conditionRegVal),
	.LK_o(LK),
	.CIA_o(CIA),
	.branchOffset_o(branchOffset),
	.currentCountReg_o(currentCountReg), .currentCountRegMinusOne_o(currentCountRegMinusOne), 
	.is64Bit_o(is64Bit)	
	);
		
	//stage 2 output
	wire [0:addressWidth-1] CIA2;
	wire [0:addressWidth-1] branchOffset2;
	wire is64Bit2;
	wire doBranch;
	wire LK2;		
	wire [0:addressWidth-1] newCountVal;		
	//stage 2
	BranchStage2 branchStage2(
	//input
	.clock_i(clock_i),
	//command out
	.isConditional_i(isConditional),
	.BO_i(BO),
	.BI_i(BI),
	.BH_i(BH),
	.conditionRegVal_i(conditionRegVal),
	.LK_i(LK),
	.CIA_i(CIA),
	.branchOffset_i(branchOffset),
	.currentCountReg_i(currentCountReg), .currentCountRegMinusOne_i(currentCountRegMinusOne), 
	.is64Bit_i(is64Bit),
	//output
	.CIA_o(CIA2),
	.branchOffset_o(branchOffset2),
	.is64Bit_o(is64Bit2),
	.doBranch_o(doBranch),
	.LK_o(LK2),	
	.newCountReg_o(newCountVal)
	);
	

	//stage 3 commits the changes to the CPU state
	always @(posedge clock_i)
	begin
		if(reset_i == 1)
		begin
			PC <= resetVector;
			countReg <= 0;
			linkReg <= 0;
		end
		else			
		begin		
			PC_o <= PC;//set the PC output			
			if(LK2 == 1)//update link reg
				linkReg <= CIA2 + 4;			
			countReg <= newCountVal;//update the count reg
				
			if(doBranch == 1)//if taking a branch
			begin
				branchInstructionAddress_o <= CIA2;
				isBranching_o <= 1;
				if(is64Bit2)
					PC <= branchOffset2;
				else
					PC <= branchOffset2 & 64'hFFFFFFFF;//zero out top 32 bits;
			end
			else
			begin//not taking a branch
				isBranching_o <= 0;
				if(is64Bit2)
					PC <= CIA2 + 4;
				else
					PC <= (CIA2 + 4) & 64'hFFFFFFFF;//zero out top 32 bits;
			end
		end
	end

endmodule
