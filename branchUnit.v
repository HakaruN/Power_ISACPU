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
//NOTE: The branch unit makes no use about the hints given with branch instructions.
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
	output reg [0:addressWidth-1] PC_o
	);
	
	reg [0:addressWidth-1] PC;
	//Maybe these should be moved to the reg file
	reg [0:addressWidth-1] linkReg;//LKR
	reg [0:addressWidth-1] countReg;//CRT
	reg [0:addressWidth-1] TargetAddrReg;//TAR
	
	
	//stage 1 regs
	reg isConditional;//indicates if it's a conditional branch or unconditional branch
	reg [0:4] BO, BI;//BI specifies which CR bit to test, BO is used to resolve the branch as described in figure 40 of datasheet.
	reg [0:1] BH;
	reg [32:addressWidth-1] conditionRegVal;
	reg LK;
	reg [0:addressWidth-1] CIA1;
	reg [0:addressWidth-1] branchOffset;
	reg [0:addressWidth-1] currentCountReg;
	reg is64Bit1;
	
	//stage 1, parse the branch instruction and check if it's conditional or unconditional
	always @(posedge clock_i)
	begin
		if(stall_i == 0 && enable_i == 1 && reset_i == 0 && functionalUnitCode_i == BranchUnitCode)
		begin				
			//update CPU and instruction state
			CIA1 <= instructionAddress_i;
			is64Bit1 <= is64Bit_i;
			conditionRegVal <= condReg_i;	
			currentCountReg <= countReg;
			//unconditional branch
			if(instructionFormat_i == I && opCode_i == 18)
			begin					
				isConditional <= 0;//set instruction to be a unconditional branch
				//offset + the CIA * AA + instruction size. If AA == 0 then it's an absalute offset + 4 else it's relative
				branchOffset <= $signed({imm_i, 2'b00}) + (instructionAddress_i * bit1_i) + 4;
				LK <= bit2_i;
			end
			
			//branch conditional
			else if(instructionFormat_i == B && opCode_i == 16)
			begin
				isConditional <= 1;
				BO <= operand1_i; BI <= operand2_i + 32;
				branchOffset <= $signed({imm_i, 2'b00}) + (instructionAddress_i * bit1_i) + 4;
				LK <= bit2_i;					
			end
		
			else if(instructionFormat_i == XL && opCode_i == 19)
			begin
				case(xOpCode_i)
					16: begin//Branch Conditional to Link Register
						isConditional <= 1;
						BO <= operand1_i; BI <= operand2_i + 32; BH <= operand3_i;
						branchOffset <= {linkReg[0:61],2'b00};//offset to the link reg (4 Byte aligned)
						LK <= bit2_i;
					end
					528: begin//Branch Conditional to Count Register
						isConditional <= 1;
						BO <= operand1_i; BI <= operand2_i + 32; BH <= operand3_i;
						branchOffset <= {countReg[0:61],2'b00};//offset to the count reg (4 Byte aligned)
						LK <= bit2_i;
					end
					560: begin//Branch Conditional to TAR
						isConditional <= 1;
						BO <= operand1_i; BI <= operand2_i + 32; BH <= operand3_i;
						branchOffset <= {TargetAddrReg[0:61],2'b00};//offset to the TAR (4 Byte aligned)
						LK <= bit2_i;
					end
				endcase
			end
					/* TODO: Move to a Condition Register functional Unit
					conditionRegBitIdx_o <= operand1_i[63-:5];
					if(instructionFormat_i == XL && opCode_i == 19 && functionalUnitCode_i == CRUnitCode)
					begin
						conditionRegBitIdx_o <= operand1_i[63-:5];
						case(xOpCode_i)
						257: begin//condition reg AND
							conditionRegBit_o <= condReg_i[operand2_i[63-:5] & condReg_i[operand3_i[63-:5];
						end
						449: begin//condition reg OR
							conditionRegBit_o <= condReg_i[operand2_i[63-:5] | condReg_i[operand3_i[63-:5];
						end
						225: begin//condition reg NAND
							conditionRegBit_o <= condReg_i[operand2_i[63-:5] ~& condReg_i[operand3_i[63-:5];
						end

						193: begin//condition reg XOR 
							conditionRegBit_o <= condReg_i[operand2_i[63-:5] ^ condReg_i[operand3_i[63-:5];							
						end
						33: begin//condition reg NOR 
							conditionRegBit_o <= condReg_i[operand2_i[63-:5] ~| condReg_i[operand3_i[63-:5];	
						end
						129:begin//condition reg AND with Compliment
							conditionRegBit_o <= condReg_i[operand2_i[63-:5] & (~condReg_i[operand3_i[63-:5]);						
						end
						289: begin//condition reg Equivelent
							conditionRegBit_o <= ~(condReg_i[operand2_i[63-:5] ^ condReg_i[operand3_i[63-:5]);	
						end
						417: begin//condition reg OR with Compliment
							conditionRegBit_o <= condReg_i[operand2_i[63-:5] | (~condReg_i[operand3_i[63-:5]);
						end
						
						// This could be implemented in the reg file
						0: begin//move condition reg field
							//move one of the groups of 4 bits from one CR field to another
							//Operand 1 indicates the destination, operand 2 indicates the field to copy.
						end
						default: begin
							//Throw Error
						end
					end
					*/
			/*System call instructions not implemented
			else if(instructionFormat_i == SC)
			begin
			
			end
			*/
		end
	end

	//stage 2 output registers
	reg [0:addressWidth-1] CIA2;
	reg [0:addressWidth-1] branchOffset2;
	reg is64Bit2;
	reg doBranch;
	reg LK2;		
	reg [0:addressWidth-1] newCountReg;	
	
	//stage 2, resolves if a branch is to be taken or not
	always @(posedge clock_i)
	begin
		CIA2 <= CIA1;
		branchOffset2 <= branchOffset;
		LK2 <= LK;
		is64Bit2 <= is64Bit1;
		if(isConditional == 1)
		begin
			case(BO)//check the condition bits
				0: begin //decrement the CTR then branch if the decremented CRT != 0 (0:63 in 64b mode and 32:63 in 32b mode) and conditionRegVal[BI + 32] == 0														
					if((currentCountReg - 1) != 0 && conditionRegVal[BI + 32] == 0)
						doBranch <= 1;
					else
						doBranch <= 0;
					newCountReg <= currentCountReg - 1;//decrement the countReg
				end
					
				1: begin //decrement the CTR then branch if the decremented CRT == 0 (0:63 in 64b mode and 32:63 in 32b mode) and conditionRegVal[BI + 32] == 0
					if((currentCountReg - 1) == 0 && conditionRegVal[BI + 32] == 0)
						doBranch <= 1;
					else
						doBranch <= 0;						
					newCountReg <= currentCountReg - 1;//decrement the countReg
				end
						
				2: begin //branch if the conditionRegVal[BI + 32] == 0
					if(conditionRegVal[BI + 32] == 0)
						doBranch <= 1;
					else
						doBranch <= 0;
					newCountReg <= currentCountReg;
				end
						
				3: begin //decrement the CTR then branch if the decremented CRT != 0 (0:63 in 64b mode and 32:63 in 32b mode) and CR[BI + 32] == 1
					if((currentCountReg - 1) != 0 && conditionRegVal[BI + 32] == 1)
						doBranch <= 1;
					else
						doBranch <= 0;

					newCountReg <= currentCountReg - 1;//decrement the countReg						
				end
						
				4: begin //decrement the CTR then branch if the decremented CRT == 0 (0:63 in 64b mode and 32:63 in 32b mode) and CR[BI + 32] == 1
					if((currentCountReg - 1) == 0 && conditionRegVal[BI + 32] == 1)
						doBranch <= 1;
					else
						doBranch <= 0;

					newCountReg <= currentCountReg - 1;//decrement the countReg
				end
						
				5: begin //branch if the conditionRegVal[BI + 32] == 1
					if(conditionRegVal[BI + 32] == 1)
						doBranch <= 1;
					else
						doBranch <= 0;

				end
						
				6: begin //decrement the CTR then branch if the decremented CRT != 0 (0:63 in 64b mode and 32:63 in 32b mode)
					if((currentCountReg - 1) != 0)
						doBranch <= 1;
					else
						doBranch <= 0;

					newCountReg <= currentCountReg - 1;//decrement the countReg
				end
						
				7: begin //decrement the CTR then branch if the decremented CRT == 0 (0:63 in 64b mode and 32:63 in 32b mode)
					if((currentCountReg - 1) == 0)
						doBranch <= 1;
					else
						doBranch <= 0;

					newCountReg <= currentCountReg - 1;//decrement the countReg
				end
						
				8: begin
					//conditional unconditional-branch
					doBranch <= 1;
					newCountReg <= currentCountReg;//preserve the countReg
				end
				default: begin//no branch condition satisfied
					//throw error
				end					
			endcase
		end
		else//unconditonal branch instruction
		begin
			doBranch <= 1;
			newCountReg <= currentCountReg;//preserve the countReg
		end
	end
	
	

	//stage 3 commits the changes to the CPU state
	always @(posedge clock_i)
	begin
		if(reset_i == 1)
		begin
			PC <= resetVector;
			countReg <= 0;
			isBranching_o <= 0;
		end
		else			
		begin		
			PC_o <= PC;//set the PC output			
			if(LK2 == 1)//update link reg
				linkReg <= CIA2 + 4;			
			countReg <= newCountReg;//update the count reg
				
			if(doBranch == 1)//if taking a branch
			begin
				isBranching_o <= 1;
				if(is64Bit2)
					PC <= branchOffset2;
				else
					PC <= branchOffset2 & 64'hFFFFFFFF;//zero out top 32 bits;
			end
			else
			begin//not taking a branch
				isBranching_o <= 1;
				if(is64Bit2)
					PC <= CIA2 + 4;
				else
					PC <= (CIA2 + 4) & 64'hFFFFFFFF;//zero out top 32 bits;
			end
		end
	end

endmodule
