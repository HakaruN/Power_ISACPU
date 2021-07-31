`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//
//Implemented:
//I form instruction, B form instruction
//TODO:
//XL form instructions
//SC instructions
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
	input wire [0:63] operand1_i, operand2_i, operand3_i,
	input wire [0:regWidth-1] reg1Address_i, reg2Address_i, reg3Address_i,
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
	
	reg [32:addressWidth-1] conditionReg;//condition reg
	reg [0:addressWidth-1] linkReg;
	reg [0:addressWidth-1] PC;
	reg [0:addressWidth-1] countReg;//CRT
	reg [0:addressWidth-1] TargetAddrReg;
	
	always @(posedge clock_i)
	begin
		if(reset_i == 1)//if were resetting
		begin//set the PC to the resetVector
			PC <= resetVector;
		end
		else
		begin
			if(stall_i == 0 && enable_i == 1)
			begin
				
				//branch
				if(functionalUnitCode_i == I && opCode_i == 18)
				begin					
					//24 bit imm
					if(bit1_i == 1)//if AA == 1
					begin	
						//branch address is imm || 2'b00 sign extended
						if(is64Bit_i == 1)
						begin
							PC <= $signed({imm_i, 2'b00});
						end
						else//if 32b then top 32bits are zeroed out
						begin
							PC <= $signed({imm_i, 2'b00}) & 64'hFFFFFFFF;
						end
					end
					else
					begin
						//branch address is imm || 2'b00 sign extended + instructionAddr 
						if(is64Bit_i == 1)
						begin
							PC <= $signed({imm_i, 2'b00}) + instructionAddress_i;
						end
						else//if 32b then top 32bits are zeroed out
						begin
							PC <= ($signed({imm_i, 2'b00}) + instructionAddress_i) & 64'hFFFFFFFF;
						end
					end
					//set the link reg
					if(bit2_i == 1)
					begin
						//write the next instruction addr (instructionAddr + 4) to the LK reg
						linkReg <= instructionAddress_i + 4;
					end
				end
				
				//branch conditional
				else if(functionalUnitCode_i == B && opCode_i == 16)
				begin
					//condition reg bit to be tested = operand2_i + 32
					//operand1_i is the branch rules (figure 40 page 33)
					
					//set the link reg
					if(bit2_i == 1)
					begin
						//write the next instruction addr (instructionAddr + 4) to the LK reg
						linkReg <= instructionAddress_i + 4;
					end
				
					case(operand1_i[63-:5])
					0: begin //decrement the CTR then branch if the decremented CRT != 0 (0:63 in 64b mode and 32:63 in 32b mode) and CR[operand2_i] == 0														
						if((countReg - 1) != 0 && conditionReg[operand2_i + 32] == 0)
						begin
							if(bit1_i == 1)//if AA == 1
							begin
								if(is64Bit_i)
									PC <= ($signed({imm_i, 2'b00}));
								else
									PC <= $signed({imm_i, 2'b00}) & 64'hFFFFFFFF;//zero out top 32 bits
							end
							else//AA == 0
							begin
								if(is64Bit_i)
									PC <= $signed({imm_i, 2'b00}) + instructionAddress_i;
								else
									PC <= ($signed({imm_i, 2'b00}) + instructionAddress_i) & 64'hFFFFFFFF;//zero out top 32 bits
							end
						end
						countReg <= countReg - 1;//decrement the countReg
					end
						
					1: begin //decrement the CTR then branch if the decremented CRT == 0 (0:63 in 64b mode and 32:63 in 32b mode) and CR[operand2_i] == 0
						if((countReg - 1) == 0 && conditionReg[operand2_i + 32] == 0)
						begin
							if(bit1_i == 1)//if AA == 1
							begin
								if(is64Bit_i)
									PC <= ($signed({imm_i, 2'b00}));
								else
									PC <= $signed({imm_i, 2'b00}) & 64'hFFFFFFFF;//zero out top 32 bits
							end
							else//AA == 0
							begin
								if(is64Bit_i)
									PC <= $signed({imm_i, 2'b00}) + instructionAddress_i;
								else
									PC <= ($signed({imm_i, 2'b00}) + instructionAddress_i) & 64'hFFFFFFFF;//zero out top 32 bits
							end
						end
						countReg <= countReg - 1;//decrement the countReg
					end
						
						2: begin //branch if the CR[operand2_i] == 0
							if(conditionReg[operand2_i + 32] == 0)
							begin
								if(bit1_i == 1)//if AA == 1
								begin
									if(is64Bit_i)
										PC <= ($signed({imm_i, 2'b00}));
									else
										PC <= $signed({imm_i, 2'b00}) & 64'hFFFFFFFF;//zero out top 32 bits
								end
								else//AA == 0
								begin
									if(is64Bit_i)
										PC <= $signed({imm_i, 2'b00}) + instructionAddress_i;
									else
										PC <= ($signed({imm_i, 2'b00}) + instructionAddress_i) & 64'hFFFFFFFF;//zero out top 32 bits
								end
							end
						end
						
						3: begin //decrement the CTR then branch if the decremented CRT != 0 (0:63 in 64b mode and 32:63 in 32b mode) and CR[operand2_i] == 1
							if((countReg - 1) != 0 && conditionReg[operand2_i + 32] == 1)
							begin
								if(bit1_i == 1)//if AA == 1
								begin
									if(is64Bit_i)
										PC <= ($signed({imm_i, 2'b00}));
									else
										PC <= $signed({imm_i, 2'b00}) & 64'hFFFFFFFF;//zero out top 32 bits
								end
								else//AA == 0
								begin
									if(is64Bit_i)
										PC <= $signed({imm_i, 2'b00}) + instructionAddress_i;
									else
										PC <= ($signed({imm_i, 2'b00}) + instructionAddress_i) & 64'hFFFFFFFF;//zero out top 32 bits
								end
							end
							countReg <= countReg - 1;//decrement the countReg						
						end
						
						4: begin //decrement the CTR then branch if the decremented CRT == 0 (0:63 in 64b mode and 32:63 in 32b mode) and CR[operand2_i] == 1
							if((countReg - 1) == 0 && conditionReg[operand2_i + 32] == 1)
							begin
								if(bit1_i == 1)//if AA == 1
								begin
									if(is64Bit_i)
										PC <= ($signed({imm_i, 2'b00}));
									else
										PC <= $signed({imm_i, 2'b00}) & 64'hFFFFFFFF;//zero out top 32 bits
								end
								else//AA == 0
								begin
									if(is64Bit_i)
										PC <= $signed({imm_i, 2'b00}) + instructionAddress_i;
									else
										PC <= ($signed({imm_i, 2'b00}) + instructionAddress_i) & 64'hFFFFFFFF;//zero out top 32 bits
								end
							end
							countReg <= countReg - 1;//decrement the countReg
						end
						
						5: begin //branch if the CR[operand2_i] == 1
							if(conditionReg[operand2_i + 32] == 1)
							begin
								if(bit1_i == 1)//if AA == 1
								begin
									if(is64Bit_i)
										PC <= ($signed({imm_i, 2'b00}));
									else
										PC <= $signed({imm_i, 2'b00}) & 64'hFFFFFFFF;//zero out top 32 bits
								end
								else//AA == 0
								begin
									if(is64Bit_i)
										PC <= $signed({imm_i, 2'b00}) + instructionAddress_i;
									else
										PC <= ($signed({imm_i, 2'b00}) + instructionAddress_i) & 64'hFFFFFFFF;//zero out top 32 bits
								end
							end
						end
						
						6: begin //decrement the CTR then branch if the decremented CRT != 0 (0:63 in 64b mode and 32:63 in 32b mode)
							if((countReg - 1) != 0)
							begin
								if(bit1_i == 1)//if AA == 1
								begin
									if(is64Bit_i)
										PC <= ($signed({imm_i, 2'b00}));
									else
										PC <= $signed({imm_i, 2'b00}) & 64'hFFFFFFFF;//zero out top 32 bits
								end
								else//AA == 0
								begin
									if(is64Bit_i)
										PC <= $signed({imm_i, 2'b00}) + instructionAddress_i;
									else
										PC <= ($signed({imm_i, 2'b00}) + instructionAddress_i) & 64'hFFFFFFFF;//zero out top 32 bits
								end
							end
							countReg <= countReg - 1;//decrement the countReg
						end
						
						7: begin //decrement the CTR then branch if the decremented CRT == 0 (0:63 in 64b mode and 32:63 in 32b mode)
							if((countReg - 1) == 0)
							begin
								if(bit1_i == 1)//if AA == 1
								begin
									if(is64Bit_i)
										PC <= ($signed({imm_i, 2'b00}));
									else
										PC <= $signed({imm_i, 2'b00}) & 64'hFFFFFFFF;//zero out top 32 bits
								end
								else//AA == 0
								begin
									if(is64Bit_i)
										PC <= $signed({imm_i, 2'b00}) + instructionAddress_i;
									else
										PC <= ($signed({imm_i, 2'b00}) + instructionAddress_i) & 64'hFFFFFFFF;//zero out top 32 bits
								end
							end
							countReg <= countReg - 1;//decrement the countReg
						end
						
						8: begin
							//branch
							if(bit1_i == 1)//if AA == 1
							begin
								if(is64Bit_i)
									PC <= ($signed({imm_i, 2'b00}));
								else
									PC <= $signed({imm_i, 2'b00}) & 64'hFFFFFFFF;//zero out top 32 bits
							end
							else//AA == 0
							begin
								if(is64Bit_i)
									PC <= $signed({imm_i, 2'b00}) + instructionAddress_i;
								else
									PC <= ($signed({imm_i, 2'b00}) + instructionAddress_i) & 64'hFFFFFFFF;//zero out top 32 bits
							end
						end
						
					endcase
				end
				
				else if(functionalUnitCode_i == XL && opCode_i == 19)
				begin
					case(xOpCode_i)
						16: begin end
						528: begin end
						560: begin end
						257: begin end
						225: begin end
						449: begin end
						193: begin end
						33: begin end
						289: begin end
						129: begin end
						417: begin end
						0: begin end
					endcase
				end
				else if(functionalUnitCode_i == SC)
				begin
				
				end
				else
				begin
					PC <= PC + 1;
				end
			end
		end
		PC_o <= PC;
	end

endmodule
