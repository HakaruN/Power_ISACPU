`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//This unit takes in the fetched instruction (in parallel with other decode units) and checks to see if the instruction is a D foramat isntruction
//Supports all D format instructions (im pretty sure, could be some D format vector instructions, vector instructions arn't supported)
//////////////////////////////////////////////////////////////////////////////////
module DFormatDecoder#( parameter instructionWidth = 32, parameter addressSize = 64, parameter formatIndexRange = 5,
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
	output reg [0:regWidth-1] reg1_o, reg2_o,
	output reg reg2ValOrZero_o,//indicates that if the register addr is zero, a zero litteral is to be used not reg zero
	output reg [0:63] imm_o,
	output reg enable_o
	);

always @(posedge clock_i)
begin
	if(enable_i == 1)
	begin
		case(instruction_i[0:opcodeWidth-1])//switch on the opcode
		//fixed point D format instructions
			34: begin $display("Load Byte and Zero");
				reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15];
				imm_o <= $signed(instruction_i[16:31]); reg2ValOrZero_o <= 1;
				opcode_o <= instruction_i[0:opcodeWidth-1];
				enable_o <= 1;
			end
			35: begin $display("Load Byte and Zero with Update");
				reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15];
				imm_o <= instruction_i[16:31]; reg2ValOrZero_o <= 0;
				opcode_o <= instruction_i[0:opcodeWidth-1];
				enable_o <= 1;
			end
			40: begin $display("Load Halfword and Zero");
				reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15];
				imm_o <= $signed(instruction_i[16:31]); reg2ValOrZero_o <= 1;
				opcode_o <= instruction_i[0:opcodeWidth-1];
				enable_o <= 1;
			end
			41: begin $display("Load Halfword and Zero with Update");
				reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15];
				imm_o <= $signed(instruction_i[16:31]); reg2ValOrZero_o <= 0;
				opcode_o <= instruction_i[0:opcodeWidth-1];
				enable_o <= 1;
			end
			42: begin $display("Load Halfword Algebraic");
				reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15];
				imm_o <= $signed(instruction_i[16:31]); reg2ValOrZero_o <= 1;
				opcode_o <= instruction_i[0:opcodeWidth-1];
				enable_o <= 1;
			end
			43: begin $display("Load Halfword Algebraic with Update");
				reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15];
				imm_o <= $signed(instruction_i[16:31]); reg2ValOrZero_o <= 0;
				opcode_o <= instruction_i[0:opcodeWidth-1];
				enable_o <= 1;
			end
			32: begin $display("Load Word and Zero");
				reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15];
				imm_o <= $signed(instruction_i[16:31]); reg2ValOrZero_o <= 1;
				opcode_o <= instruction_i[0:opcodeWidth-1];
				enable_o <= 1;
			end
			33: begin $display("Load Word and Zero with Update");
				reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15];
				imm_o <= $signed(instruction_i[16:31]); reg2ValOrZero_o <= 0;
				opcode_o <= instruction_i[0:opcodeWidth-1];
				enable_o <= 1;
			end
			38: begin $display("Store Byte");
				reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15];
				imm_o <= $signed(instruction_i[16:31]); reg2ValOrZero_o <= 1;
				opcode_o <= instruction_i[0:opcodeWidth-1];
				enable_o <= 1;
			end
			39: begin $display("Store Byte with Update");
				reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15];
				imm_o <= $signed(instruction_i[16:31]); reg2ValOrZero_o <= 0;
				opcode_o <= instruction_i[0:opcodeWidth-1];
				enable_o <= 1;
			end
			44: begin $display("Store Halfword");
				reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15];
				imm_o <= $signed(instruction_i[16:31]); reg2ValOrZero_o <= 1;
				opcode_o <= instruction_i[0:opcodeWidth-1];
				enable_o <= 1;
			end
			45: begin $display("Store Halfword with Update");
				reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15];
				imm_o <= $signed(instruction_i[16:31]); reg2ValOrZero_o <= 0;
				opcode_o <= instruction_i[0:opcodeWidth-1];
				enable_o <= 1;
			end
			36: begin $display("Store Word");
				reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15];
				imm_o <= $signed(instruction_i[16:31]); reg2ValOrZero_o <= 1;
				opcode_o <= instruction_i[0:opcodeWidth-1];
				enable_o <= 1;
			end
			37: begin $display("Store Word with Update");
				reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15];
				imm_o <= $signed(instruction_i[16:31]); reg2ValOrZero_o <= 0;
				opcode_o <= instruction_i[0:opcodeWidth-1];
				enable_o <= 1;
			end
			46: begin $display("Load Multiple Word");
				reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15];
				imm_o <= $signed(instruction_i[16:31]); reg2ValOrZero_o <= 1;
				opcode_o <= instruction_i[0:opcodeWidth-1];
				enable_o <= 1;
			end
			47: begin $display("Store Multiple Word");
				reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15];
				imm_o <= $signed(instruction_i[16:31]); reg2ValOrZero_o <= 1;
				opcode_o <= instruction_i[0:opcodeWidth-1];
				enable_o <= 1;
			end
			14: begin $display("Add Immediate");
				reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15];
				imm_o <= instruction_i[16:31]; reg2ValOrZero_o <= 1;
				opcode_o <= instruction_i[0:opcodeWidth-1];
				enable_o <= 1;
			end
			15: begin $display("Add Immediate Shifted");
				reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15];
				imm_o <= {instruction_i[16:31], 16'h0000}; reg2ValOrZero_o <= 1;
				opcode_o <= instruction_i[0:opcodeWidth-1];
				enable_o <= 1;
			end
			12: begin $display("Add Immediate Carrying");
				reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15];
				opcode_o <= instruction_i[0:opcodeWidth-1];
				imm_o <= instruction_i[16:31];reg2ValOrZero_o <= 0;
				enable_o <= 1;
			end
			13: begin $display("Add Immediate Carrying and Record");
				reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15];
				opcode_o <= instruction_i[0:opcodeWidth-1];
				imm_o <= instruction_i[16:31]; reg2ValOrZero_o <= 0;
				enable_o <= 1;
			end
			8: begin $display("Subtract From Immediate Carrying");
				reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15];
				imm_o <= $signed(instruction_i[16:31]); reg2ValOrZero_o <= 0;
				opcode_o <= instruction_i[0:opcodeWidth-1];
				enable_o <= 1;
			end
			7: begin $display("Multiply Low Immediate");
				reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15];
				imm_o <= $signed(instruction_i[16:31]); reg2ValOrZero_o <= 0;
				opcode_o <= instruction_i[0:opcodeWidth-1];
				enable_o <= 1;
			end
			11: begin $display("Compare Immediate");
				reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15];
				imm_o <= $signed(instruction_i[16:31]); reg2ValOrZero_o <= 0;
				opcode_o <= instruction_i[0:opcodeWidth-1];
				enable_o <= 1;
			end
			10: begin $display("Compare Logical Immediate");
				reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15];
				imm_o <= {48'h0000_0000_0000,instruction_i[16:31]}; reg2ValOrZero_o <= 0;
				opcode_o <= instruction_i[0:opcodeWidth-1];
				enable_o <= 1;
			end
			3: begin $display("Trap Word Immediate");
				reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15];
				imm_o <= $signed(instruction_i[16:31]); reg2ValOrZero_o <= 0;
				opcode_o <= instruction_i[0:opcodeWidth-1];
				enable_o <= 1;
			end
			2: begin $display("Trap Doubleword Immediate");
				reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15];
				imm_o <= $signed(instruction_i[16:31]); reg2ValOrZero_o <= 0;
				opcode_o <= instruction_i[0:opcodeWidth-1];
				enable_o <= 1;
			end
			28: begin $display("AND Immediate");
				reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15];
				imm_o <= {48'h0000_0000_0000,instruction_i[16:31]}; reg2ValOrZero_o <= 0;
				opcode_o <= instruction_i[0:opcodeWidth-1];
				enable_o <= 1;
			end
			29: begin $display("OR Immediate");
				reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15];
				imm_o <= {48'h0000_0000_0000,instruction_i[16:31]}; reg2ValOrZero_o <= 0;
				opcode_o <= instruction_i[0:opcodeWidth-1];
				enable_o <= 1;
			end
			24: begin $display("AND Immediate Shifted");
				reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15];
				imm_o <= {32'h0000_0000,instruction_i[16:31], 16'h0000}; reg2ValOrZero_o <= 0;
				opcode_o <= instruction_i[0:opcodeWidth-1];
				enable_o <= 1;
			end
			25: begin $display("OR Immediate Shifted");
				reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15];
				imm_o <= {32'h0000_0000,instruction_i[16:31], 16'h0000}; reg2ValOrZero_o <= 0;
				opcode_o <= instruction_i[0:opcodeWidth-1];
				enable_o <= 1;
			end
			26: begin $display("XOR Immediat");
				reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15];
				imm_o <= {48'h0000_0000_0000,instruction_i[16:31]}; reg2ValOrZero_o <= 0;
				opcode_o <= instruction_i[0:opcodeWidth-1];
				enable_o <= 1;
			end
			27: begin $display("XOR Immediate Shifted");
				reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15];
				imm_o <= {48'h0000_0000_0000,instruction_i[16:31]}; reg2ValOrZero_o <= 0;
				opcode_o <= instruction_i[0:opcodeWidth-1];
				enable_o <= 1;
			end
		//floating point D format instructions
			48: begin $display("Load Floating-Point Single");
				reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15];
				imm_o <= $signed(instruction_i[16:31]); reg2ValOrZero_o <= 1;
				opcode_o <= instruction_i[0:opcodeWidth-1];
				enable_o <= 1;
			end
			49: begin $display("Load Floating-Point Single with Update");
				reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15];
				imm_o <= $signed(instruction_i[16:31]); reg2ValOrZero_o <= 0;
				opcode_o <= instruction_i[0:opcodeWidth-1];
				enable_o <= 1;
			end
			50: begin $display("Load Floating-Point Double");
				reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15];
				imm_o <= $signed(instruction_i[16:31]); reg2ValOrZero_o <= 1;
				opcode_o <= instruction_i[0:opcodeWidth-1];
				enable_o <= 1;
			end
			51: begin $display("Load Floating-Point Double with Update");
				reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15];
				imm_o <= $signed(instruction_i[16:31]); reg2ValOrZero_o <= 0;
				opcode_o <= instruction_i[0:opcodeWidth-1];
				enable_o <= 1;
			end
			
			52	: begin $display("Load Floating-Point Single");
				reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15];
				imm_o <= $signed(instruction_i[16:31]); reg2ValOrZero_o <= 1;
				opcode_o <= instruction_i[0:opcodeWidth-1];
				enable_o <= 1;
			end
			53: begin $display("Store Floating-Point Single with Update");
				reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15];
				imm_o <= $signed(instruction_i[16:31]); reg2ValOrZero_o <= 0;
				opcode_o <= instruction_i[0:opcodeWidth-1];
				enable_o <= 1;
			end
			54: begin $display("Store Floating-Point Double");
				reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15];
				imm_o <= $signed(instruction_i[16:31]); reg2ValOrZero_o <= 1;
				opcode_o <= instruction_i[0:opcodeWidth-1];
				enable_o <= 1;
			end
			55: begin $display("Store Floating-Point Double with Update");
				reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15];
				imm_o <= $signed(instruction_i[16:31]);reg2ValOrZero_o <= 0;
				opcode_o <= instruction_i[0:opcodeWidth-1];
				enable_o <= 1;
			end
			default: enable_o <= 0;
		endcase
	end
	else
		enable_o <= 0;
end


endmodule
