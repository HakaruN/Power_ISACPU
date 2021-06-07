`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//Implements all MD and MDS format instructions in the PowerISA 3.0B
//////////////////////////////////////////////////////////////////////////////////
module MDFormatDecoder#( parameter instructionWidth = 32, parameter addressSize = 64, parameter formatIndexRange = 5,
parameter A = 1, parameter B = 2, parameter D = 3, parameter DQ = 4, parameter DS = 5, parameter DX = 6, parameter I = 7, parameter M = 8,
parameter MD = 9, parameter MDS = 10, parameter SC = 11, parameter VA = 12, parameter VC = 13, parameter VX = 14, parameter X = 15, parameter XFL = 16,
parameter XFX = 17, parameter XL = 18, parameter XO = 19, parameter XS = 20, parameter XX2 = 21, parameter XX3 = 22, parameter XX4 = 23, parameter Z22 = 24,
parameter Z23 = 25, parameter INVALID = 0, parameter unsignedImm = 1, parameter signedImm = 2, parameter signedImmExt = 3,
parameter opcodeWidth = 6, parameter xOpCodeWidth = 10, parameter regWidth = 5, parameter immWidth = 16
)(
	//command
	input wire clock_i,
	input wire enable_i,
	//data in
	input wire [0:instructionWidth-1] instruction_i,
	input wire [0:addressSize-1] address_i,
	//data out
	output reg [0:opcodeWidth-1] opcode_o,
	output reg [0:regWidth-1] reg1_o, reg2_o, reg3_o,
	output reg reg2ValOrZero_o,//indicates that if the register addr is zero, a zero litteral is to be used not reg zero
	output reg [0:63] imm_o,
	output reg bit1_o, bit2_o,
	output reg enable_o
	);

always @(posedge clock_i)
begin
	if(enable_i == 1)
	begin
		if(instruction_i[0:opcodeWidth-1] == 30)
		begin
			opcode_o <= instruction_i[0:opcodeWidth-1];
			case(instruction_i[27:29])//check for MD format
				0: begin $display("Rotate Left Doubleword Immediate then Clear Left");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= 0;
					reg2ValOrZero_o <= 0;
					imm_o <= instruction_i[16:26];
					bit1_o <= instruction_i[30]; bit2_o <= instruction_i[31];
					enable_o <= 1;
				end
				1: begin $display("Rotate Left Doubleword Immediate then Clear Right");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= 0;
					reg2ValOrZero_o <= 0;
					imm_o <= instruction_i[16:26];
					bit1_o <= instruction_i[30]; bit2_o <= instruction_i[31];
					enable_o <= 1;
				end
				2: begin $display("Rotate Left Doubleword Immediate then Clear");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= 0;
					reg2ValOrZero_o <= 0;
					imm_o <= instruction_i[16:26];
					bit1_o <= instruction_i[30]; bit2_o <= instruction_i[31];
					enable_o <= 1;
				end
				3: begin $display("Rotate Left Doubleword Immediate then Mask Insert");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15];
					reg2ValOrZero_o <= 0;
					imm_o <= instruction_i[16:26];
					bit1_o <= instruction_i[30]; bit2_o <= instruction_i[31];
					enable_o <= 1;
				end
				default : enable_o <= 0;
			endcase
			//DONT USE DEFAULT IN ANY CASE/SWITCH BELOW
			case(instruction_i[27:30])//check for MDS format
				8: begin $display("Rotate Left Doubleword then Clear Left");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15];  reg3_o <= instruction_i[16:20];
					reg2ValOrZero_o <= 0;
					imm_o <= instruction_i[21:26];
					bit1_o <= instruction_i[31]; bit2_o <= 0;
					enable_o <= 1;
				end
				9: begin $display("Rotate Left Doubleword then Clear Right");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15];  reg3_o <= instruction_i[16:20];
					reg2ValOrZero_o <= 0;
					imm_o <= instruction_i[21:26];
					bit1_o <= instruction_i[31]; bit2_o <= 0;
					enable_o <= 1;
				end
			endcase			
		end
	end
	else
		enable_o <= 0;
end


endmodule
