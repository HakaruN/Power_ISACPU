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
parameter opcodeWidth = 6, parameter xOpCodeWidth = 10, parameter immWith = 16, parameter regWidth = 5, parameter numRegs = 2**regWidth, parameter formatIndexRange = 5,
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
	//outputs
	output reg conditionRegWriteEnable_o,//tells the reg file to update the CR at writeback with the instruction
	output reg outputEnable_o,
	output reg overflow_o,
	output reg [0:3] conditionRegisterBits_o,
	output reg is64Bit_o,
	output reg [0:5] regWritebackAddress_o,
	output reg [0:63] regWritebackVal_o,
	output reg [0:1] functionalUnitCode_o
	);
	
	reg [0:63] FXExceptionRegister;//as this is the 64 bit exception register for the fx unit (page 45)
	//[0:31] reserved
	//[32] summary overflow (SO)
	//[33] overflow (OV)
	//[34] carry (CA)
	//[35:43] reserved
	//[44] overflow32 (OV32)
	//[45] carry32 (CA32)
	//[46:56] reserved
	//[57:63] This field specifies the number of bytes to be transferred by a load string index or store string indexed instruction	
	
	always @(posedge clock_i)
	begin
		functionalUnitCode_o <= FXUnitCode;
		if(enable_i == 1 && reset_i == 0 && functionalUnitCode_i == FXUnitCode)
		begin//if were enabled, not reset and the instruction is destin for us
			outputEnable_o <= 1;
			is64Bit_o <= is64Bit_i;
			if(instructionFormat_i == D)
			begin
				case(opCode_i)
					14: begin regWritebackVal_o <= $signed(operand2_i + imm_i); regWritebackAddress_o <= reg1Address_i; conditionRegWriteEnable_o <= 0; end//Add Immediate - 16b signed add
					15: begin regWritebackVal_o <= $signed(operand2_i + imm_i); regWritebackAddress_o <= reg1Address_i; conditionRegWriteEnable_o <= 0; end//Add Immediate Shifted
					12: begin {overflow_o, regWritebackVal_o} <= {1'b0,operand2_i} + {1'b0,imm_i}; regWritebackAddress_o <= reg1Address_i; conditionRegWriteEnable_o <= 0; end//Add Immediate Carrying - specRegs altered: CA, CA32
					13: begin {overflow_o, regWritebackVal_o} <= {1'b0,operand2_i} + {1'b0,imm_i}; regWritebackAddress_o <= reg1Address_i; conditionRegWriteEnable_o <= 1; end//Add Immediate Carrying and Record - specRegs altered: CR0, CA, CA32
					8: begin regWritebackVal_o <= ((~operand2_i) + $signed(imm_i))+1; regWritebackAddress_o <= reg1Address_i; end//Subtract From Immediate Carrying
					7: begin regWritebackVal_o <= operand2_i * $signed(imm_i); end//Multiply Low Immediate
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
			outputEnable_o <= 0;
		end
	end

endmodule