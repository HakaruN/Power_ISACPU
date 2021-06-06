`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
module InstructionFormatDecoder #( parameter instructionWidth = 32, parameter addressSize = 64, opcodeWidth = 6, parameter formatIndexRange = 5,
parameter A = 1, parameter B = 2, parameter D = 3, parameter DQ = 4, parameter DS = 5, parameter DX = 6, parameter I = 7, parameter M = 8,
parameter MD = 9, parameter MDS = 10, parameter SC = 11, parameter VA = 12, parameter VC = 13, parameter VX = 14, parameter X = 15, parameter XFL = 16,
parameter XFX = 17, parameter XL = 18, parameter XO = 19, parameter XS = 20, parameter XX2 = 21, parameter XX3 = 22, parameter XX4 = 23, parameter Z22 = 24,
parameter Z23 = 25, parameter INVALID = 0
)(
	//command
	input wire clock_i,
	input wire enable_i,
	//data in
	input wire [0:opcodeWidth-1] opCode_i,
	input wire [0:opcodeWidth-instructionWidth-1] payload_i,
	input wire [0:addressSize-1] address_i,
	input wire [0:formatIndexRange-1] instructionFormatClass_i,
	//data out
	output reg [0:opcodeWidth-1] opCode_o,
	output reg [0:addressSize-1] address_o
	output reg [0:formatIndexRange-1] instructionFormat_o,
	
	always @(posedge clock_i)
	begin
		if(enable_i == 1) 
		begin
			if(instructionFormatClass_i != 0)
			begin
				//pass data through
				enable_i <= 1;
				opCode_o <= opCode_i;
				address_o <= address_i;
				//parse the format
				case(instructionFormatClass_i)
				//D - All D format instructions have a unique opcode
				3: instructionFormat_o <= 3;
				endcase
			end
			else
			begin
				$display("ERROR: Instruction format is invalid");
				//TODO: Write out error, throw exception
				enable_i <= 0;
			end
		end
		else
			enable_i <= 0;
	end
	
);


endmodule
