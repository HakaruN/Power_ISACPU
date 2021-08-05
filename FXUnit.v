`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//Fixed point unit
//NOTE: By time an instruction has arived here, immediate values have already been extended and shifted
//and all vereg2orZeroes have been resolved
//
//General purpose registers are found in the register file (FX, FP). Fixed function registers are to be kept as part of the relevent execution unit
//as these likely require a zero cycle writeback latency. The exception is when the register is shared between units (condition register)
//
//This functional unit has a 2 cycle latency. The first cycle performs the arithmatic operation and the second cycle parses the result in a 
//writeback-able format. It finds carries and concatenates the first cycles output 128b register (required for 64b multiplication) down to 64 bits to be writen back
//////////////////////////////////////////////////////////////////////////////////
module FXUnit #(
parameter opcodeWidth = 6, parameter xOpCodeWidth = 10, parameter immWith = 24, parameter regWidth = 5, parameter numRegs = 2**regWidth, parameter formatIndexRange = 5,
parameter A = 1, parameter B = 2, parameter D = 3, parameter DQ = 4, parameter DS = 5, parameter DX = 6, parameter I = 7, parameter M = 8,
parameter MD = 9, parameter MDS = 10, parameter SC = 11, parameter VA = 12, parameter VC = 13, parameter VX = 14, parameter X = 15, parameter XFL = 16,
parameter XFX = 17, parameter XL = 18, parameter XO = 19, parameter XS = 20, parameter XX2 = 21, parameter XX3 = 22, parameter XX4 = 23, parameter Z22 = 24,
parameter Z23 = 25, parameter INVALID = 0,
parameter FXUnitCode = 0, parameter FPUnitCode = 1, parameter LdStUnitCode = 2, parameter BranchUnitCode = 3, parameter TrapUnitCode = 4//functional unit code/ID used for dispatch
)(
	//command
	input wire clock_i,
	input wire reset_i,
	input wire enable_i,
	//data in
	input wire [32:63] condReg_i,
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
	//outputs
	output reg [0:2] functionalUnitCode_o,
	output reg reg1WritebackEnable_o, reg2WritebackEnable_o,//reg2 enable condition reg writeEnable
	output reg [0:regWidth-1] reg1WritebackAddress_o, reg2WritebackAddress_o,//reg2 address is used to write back the condition reg bits
	output reg [0:63] reg1WritebackVal_o, reg2WritebackVal_o//reg2 val is overflow/underflow bits	
	);
	
	always @(posedge clock_i)
	begin
		functionalUnitCode_o <= FXUnitCode;
		if(enable_i == 1 && reset_i == 0 && functionalUnitCode_i == FXUnitCode)
		begin//if were enabled, not reset and the instruction is destin for us
			//is64Bit_o <= is64Bit_i;
			reg1WritebackEnable_o <= operand1Writeback_i;
			reg2WritebackEnable_o <= operand2Writeback_i;
			if(instructionFormat_i == D)
			begin
				case(opCode_i)
					14: begin reg1WritebackVal_o <= $signed(operand2_i + imm_i); reg1WritebackAddress_o <= reg1Address_i; end//Add Immediate - 16b signed add
					15: begin reg1WritebackVal_o <= $signed(operand2_i + imm_i); reg1WritebackAddress_o <= reg1Address_i; end//Add Immediate Shifted
					12: begin {reg2WritebackVal_o[0], reg1WritebackVal_o} <= {1'b0,operand2_i} + {1'b0,imm_i}; reg1WritebackAddress_o <= reg1Address_i; end//Add Immediate Carrying - specRegs altered: CA, CA32
					13: begin {reg2WritebackVal_o[0], reg1WritebackVal_o} <= {1'b0,operand2_i} + {1'b0,imm_i}; reg1WritebackAddress_o <= reg1Address_i; end//Add Immediate Carrying and Record - specRegs altered: CR0, CA, CA32
					8: begin reg1WritebackVal_o <= ((~operand2_i) + $signed(imm_i))+1; reg1WritebackAddress_o <= reg1Address_i; end//Subtract From Immediate Carrying
					7: begin reg1WritebackVal_o <= operand2_i * $signed(imm_i); end//Multiply Low Immediate
					11: 
					begin 
					end//Compare Immediate
					10: begin end//Compare Logical Immediate
					28: begin end//AND Immediate
					29: begin end//OR Immediate
					24: begin end//AND Immediate Shifted
					25: begin end//OR Immediate Shifted
					26: begin end//XOR Immediat
					27: begin end//XOR Immediate Shifted
					default: begin end
				endcase
			end
			else if(instructionFormat_i == DQ)
			begin
			
			end
			else if(instructionFormat_i == DS)
			begin
			
			end
			else if(instructionFormat_i == X)
			begin
			
			end
			else if(instructionFormat_i == MD)
			begin
			
			end
			else if(instructionFormat_i == XO)
			begin
				
			end
			else
			begin
				//unsupported instruction format
			end
			/*Must implement instruction format switching with if statements that use a nested case due to tool limitations (can't nest switches in switches)
			case(instructionFormat_i)
				D: begin end
				DQ: begin end
				DS: begin end
				X: begin end
				MD: begin end
				XO: begin end
				default: begin end
			endcase
			*/
		end
		else
		begin
			//else disable the functional unit
			reg1WritebackEnable_o <= 0; reg2WritebackEnable_o <= 0;
		end
	end

endmodule
