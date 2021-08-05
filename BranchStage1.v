`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//first stage of the branch unit. This parses the inputs and figures out what needs to be done (kind of like a late stage decoder)
//////////////////////////////////////////////////////////////////////////////////
module BranchStage1#(
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
	input wire [0:addressWidth-1] countReg_i, linkReg_i, TargetAddrReg_i,
	//instruction data
	input wire [32:63] condReg_i,
	input wire [0:4] operand1_i, operand2_i,
	input wire [0:1] operand3_i,	
	input wire [0:immWith-1] imm_i,
	input wire Bit1_i, Bit2_i,
	input wire [0:2] functionalUnitCode_i,
	input wire [0:63] instructionAddress_i,
	input wire [0:opcodeWidth-1] opCode_i,
	input wire [0:xOpCodeWidth-1] xOpCode_i,
	input wire [0:formatIndexRange-1] instructionFormat_i,
	//data out
	output reg isConditional_o,
	output reg [0:4] BO_o,
	output reg [0:5] BI_o,
	output reg [0:1] BH_o,
	output reg [32:addressWidth-1] conditionRegVal_o,
	output reg LK_o,
	output reg [0:addressWidth-1] CIA_o,
	output reg [0:addressWidth-1] branchOffset_o,
	output reg [0:addressWidth-1] currentCountReg_o, currentCountRegMinusOne_o, 
	output reg is64Bit_o	
    );
	
	//stage 1, parse the branch instruction and check if it's conditional or unconditional
	always @(posedge clock_i)
	begin
		if(stall_i == 0 && enable_i == 1 && reset_i == 0 && functionalUnitCode_i == BranchUnitCode)
		begin				
			//update CPU and instruction state
			CIA_o <= instructionAddress_i;
			is64Bit_o <= is64Bit_i;
			conditionRegVal_o <= condReg_i;
			currentCountReg_o <= countReg_i; currentCountRegMinusOne_o <= countReg_i - 1;
			//unconditional branch
			if(instructionFormat_i == I && opCode_i == 18)
			begin					
				isConditional_o <= 0;//set instruction to be a unconditional branch
				//offset + the CIA * AA + instruction size. If AA == 0 then it's an absalute offset + 4 else it's relative
				branchOffset_o <= $signed({imm_i, 2'b00}) + (instructionAddress_i * Bit1_i) + 4;
				LK_o <= Bit2_i;
			end
			
			//branch conditional
			else if(instructionFormat_i == B && opCode_i == 16)
			begin
				isConditional_o <= 1;
				BO_o <= operand1_i; BI_o <= operand2_i + 32;
				branchOffset_o <= $signed({imm_i, 2'b00}) + (instructionAddress_i * Bit1_i) + 4;
				LK_o <= Bit2_i;					
			end
		
			else if(instructionFormat_i == XL && opCode_i == 19)
			begin
				case(xOpCode_i)
					16: begin//Branch Conditional to Link Register
						isConditional_o <= 1;
						BO_o <= operand1_i; BI_o <= operand2_i + 32; BH_o <= operand3_i;
						branchOffset_o <= {linkReg_i[0:61],2'b00};//offset to the link reg (4 Byte aligned)
						LK_o <= Bit2_i;
					end
					528: begin//Branch Conditional to Count Register
						isConditional_o <= 1;
						BO_o <= operand1_i; BI_o <= operand2_i + 32; BH_o <= operand3_i;
						branchOffset_o <= {countReg_i[0:61],2'b00};//offset to the count reg (4 Byte aligned)
						LK_o <= Bit2_i;
					end
					560: begin//Branch Conditional to TAR
						isConditional_o <= 1;
						BO_o <= operand1_i; BI_o <= operand2_i + 32; BH_o <= operand3_i;
						branchOffset_o <= {TargetAddrReg_i[0:61],2'b00};//offset to the TAR (4 Byte aligned)
						LK_o <= Bit2_i;
					end
				endcase
			end
					/* TODO: Move to a Condition Register functional Unit
					conditionRegBI_otIdx_o <= operand1_i[63-:5];
					if(instructionFormat_i == XL && opCode_i == 19 && functionalUnitCode_i == CRUnitCode)
					begin
						conditionRegBI_otIdx_o <= operand1_i[63-:5];
						case(xOpCode_i)
						257: begin//condition reg AND
							conditionRegBI_ot_o <= condReg_i[operand2_i[63-:5] & condReg_i[operand3_i[63-:5];
						end
						449: begin//condition reg OR
							conditionRegBI_ot_o <= condReg_i[operand2_i[63-:5] | condReg_i[operand3_i[63-:5];
						end
						225: begin//condition reg NAND
							conditionRegBI_ot_o <= condReg_i[operand2_i[63-:5] ~& condReg_i[operand3_i[63-:5];
						end

						193: begin//condition reg XOR 
							conditionRegBI_ot_o <= condReg_i[operand2_i[63-:5] ^ condReg_i[operand3_i[63-:5];							
						end
						33: begin//condition reg NOR 
							conditionRegBI_ot_o <= condReg_i[operand2_i[63-:5] ~| condReg_i[operand3_i[63-:5];	
						end
						129:begin//condition reg AND with Compliment
							conditionRegBI_ot_o <= condReg_i[operand2_i[63-:5] & (~condReg_i[operand3_i[63-:5]);						
						end
						289: begin//condition reg Equivelent
							conditionRegBI_ot_o <= ~(condReg_i[operand2_i[63-:5] ^ condReg_i[operand3_i[63-:5]);	
						end
						417: begin//condition reg OR with Compliment
							conditionRegBI_ot_o <= condReg_i[operand2_i[63-:5] | (~condReg_i[operand3_i[63-:5]);
						end
						
						// This could be implemented in the reg file
						0: begin//move condition reg field
							//move one of the groups of 4 BI_ots from one CR field to another
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
endmodule
