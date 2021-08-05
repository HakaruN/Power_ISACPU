`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//second stage branch unit
//////////////////////////////////////////////////////////////////////////////////
module BranchStage2#(
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
	//input
	input wire clock_i,
	//command out
	input wire isConditional_i,
	input wire [0:4] BO_i,
	input wire [0:5] BI_i,
	input wire [0:1] BH_i,
	input wire [32:addressWidth-1] conditionRegVal_i,
	input wire LK_i,
	input wire [0:addressWidth-1] CIA_i,
	input wire [0:addressWidth-1] branchOffset_i,
	input wire [0:addressWidth-1] currentCountReg_i, currentCountRegMinusOne_i, 
	input wire is64Bit_i,
	//output
	output reg [0:addressWidth-1] CIA_o,
	output reg [0:addressWidth-1] branchOffset_o,
	output reg is64Bit_o,
	output reg doBranch_o,
	output reg LK_o,	
	output reg [0:addressWidth-1] newCountReg_o
    );

	//stage 2, resolves if a branch is to be taken or not
	always @(posedge clock_i)
	begin
		CIA_o <= CIA_i;
		branchOffset_o <= branchOffset_i;
		LK_o <= LK_i;
		is64Bit_o <= is64Bit_i;
		if(isConditional_i == 1)
		begin
			//NOTE The value of BO encoded in the instruction is as described in figure 40, this is resolved in the decoder which
			//generates the integer values seen below.
			case(BO_i)//check the condition bits
				0: begin //decrement the CTR then branch if the decremented CRT != 0 (0:63 in 64b mode and 32:63 in 32b mode) and conditionRegVal[BI] == 0														
					if((currentCountRegMinusOne_i != 0) && (conditionRegVal_i[BI_i] == 0)) begin
						doBranch_o <= 1; end
					else begin
						doBranch_o <= 0; end
					newCountReg_o <= currentCountRegMinusOne_i;//decrement the countReg
				end					
				1: begin //decrement the CTR then branch if the decremented CRT == 0 (0:63 in 64b mode and 32:63 in 32b mode) and conditionRegVal[BI] == 0
					if((currentCountRegMinusOne_i == 0) && (conditionRegVal_i[BI_i] == 0)) begin
						doBranch_o <= 1; end
					else begin
						doBranch_o <= 0; end				
					newCountReg_o <= currentCountRegMinusOne_i;//decrement the countReg
				end						
				2: begin //branch if the conditionRegVal[BI] == 0
					if(conditionRegVal_i[BI_i] == 0) begin
						doBranch_o <= 1; end
					else begin
						doBranch_o <= 0; end
					newCountReg_o <= currentCountReg_i;
				end						
				3: begin //decrement the CTR then branch if the decremented CRT != 0 (0:63 in 64b mode and 32:63 in 32b mode) and CR[BI] == 1
					if((currentCountRegMinusOne_i != 0) && (conditionRegVal_i[BI_i] == 1)) begin
						doBranch_o <= 1; end
					else begin
						doBranch_o <= 0; end
					newCountReg_o <= currentCountRegMinusOne_i;//decrement the countReg						
				end						
				4: begin //decrement the CTR then branch if the decremented CRT == 0 (0:63 in 64b mode and 32:63 in 32b mode) and CR[BI] == 1
					if((currentCountRegMinusOne_i == 0) && (conditionRegVal_i[BI_i] == 1)) begin
						doBranch_o <= 1; end
					else begin
						doBranch_o <= 0; end
					newCountReg_o <= currentCountRegMinusOne_i;//decrement the countReg
				end						
				5: begin //branch if the conditionRegVal[BI] == 1
					if(conditionRegVal_i[BI_i] == 1) begin
						doBranch_o <= 1; end
					else begin
						doBranch_o <= 0; end
				end						
				6: begin //decrement the CTR then branch if the decremented CRT != 0 (0:63 in 64b mode and 32:63 in 32b mode)
					if(currentCountRegMinusOne_i != 0) begin
						doBranch_o <= 1; end
					else begin
						doBranch_o <= 0; end
					newCountReg_o <= currentCountRegMinusOne_i;//decrement the countReg
				end						
				7: begin //decrement the CTR then branch if the decremented CRT == 0 (0:63 in 64b mode and 32:63 in 32b mode)
					if(currentCountRegMinusOne_i == 0) begin
						doBranch_o <= 1; end
					else begin
						doBranch_o <= 0; end
					newCountReg_o <= currentCountRegMinusOne_i;//decrement the countReg
				end						
				8: begin
					//conditional unconditional-branch
					doBranch_o <= 1;
					newCountReg_o <= currentCountReg_i;//preserve the countReg
				end
				default: begin//no branch condition satisfied
					//throw error
				end					
			endcase
		end
		else//unconditonal branch instruction
		begin
			doBranch_o <= 1;
			newCountReg_o <= currentCountReg_i;//preserve the countReg
		end
	end

endmodule
