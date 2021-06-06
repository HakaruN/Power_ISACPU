`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
module InstructionFormatDecoder #( parameter instructionWidth = 32, parameter addressSize = 64, parameter formatIndexRange = 5,
parameter A = 1, parameter B = 2, parameter D = 3, parameter DQ = 4, parameter DS = 5, parameter DX = 6, parameter I = 7, parameter M = 8,
parameter MD = 9, parameter MDS = 10, parameter SC = 11, parameter VA = 12, parameter VC = 13, parameter VX = 14, parameter X = 15, parameter XFL = 16,
parameter XFX = 17, parameter XL = 18, parameter XO = 19, parameter XS = 20, parameter XX2 = 21, parameter XX3 = 22, parameter XX4 = 23, parameter Z22 = 24,
parameter Z23 = 25, parameter INVALID = 0,
parameter opcodeWidth = 6, parameter xOpCodeWidth = 10, parameter regWidth = 5, parameter immWidth = 16
)(
	//command
	input wire clock_i,
	input wire enable_i,
	//data in
	input wire [0:opcodeWidth-1] opCode_i,
	input wire [opcodeWidth:instructionWidth-1] payload_i,
	input wire [0:addressSize-1] address_i,
	input wire [0:formatIndexRange-1] instructionFormatClass_i,
	//command out
	output reg enable_o,
	//data out
	output reg [0:opcodeWidth-1] opCode_o,
	output reg [0:xOpCodeWidth-1] xOpCode_o,
	output reg [0:addressSize-1] address_o,
	output reg [0:formatIndexRange-1] instructionFormat_o,
	//decoded outputs
	output reg [0:regWidth-1] reg1_o, reg2_o, reg3_o,//can use up to three registers (so far, may change with more supported instructions)
	output reg [0:immWidth-1] imm_o,
	output reg bit1_o, bit2_o
	);
	
	always @(posedge clock_i)
	begin
		if(enable_i == 1) 
		begin
			if(instructionFormatClass_i != 0)
			begin
				//pass data through
				enable_o <= 1;
				opCode_o <= opCode_i;
				address_o <= address_i;
				//parse the format
				case(instructionFormatClass_i)
					D: begin
						$display("D format instruction");
						instructionFormat_o <= D;
						reg1_o <=  payload_i[6:10]; reg2_o <=  payload_i[11:15]; imm_o <= payload_i[16:31];
					end
					DS: begin
						$display("DS format instruction");
						instructionFormat_o <= DS;
						reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; imm_o <= payload_i[16:29]; xOpCode_o <= payload_i[30:31];
					end
					DQ: begin
						$display("DQ format instruction");
						instructionFormat_o <= DQ;
						reg1_o <= payload_i[6:10]; reg2_o <= (payload_i[6:10] + 1); reg3_o <= payload_i[11:15]; imm_o <= payload_i[16:27];
					end
					DX: begin
						$display("DX format instruction");
						instructionFormat_o <= DX;
						reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; imm_o <= {payload_i[16:25], payload_i[11:15], payload_i[31]}; xOpCode_o <= payload_i[26:30];
					end
					MD: begin//MD format class contains both MD and MDS formats, these need seperating here
						reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20]; imm_o <= payload_i[21:26]; 
						if(payload_i[27:30] == 9 || payload_i[27:30] == 9)
						begin//MDS
							$display("MDS format instruction");
							instructionFormat_o <= MDS;
							xOpCode_o <= payload_i[27:30];
							bit1_o <= payload_i[31];
						end
						else
						begin//MD
							$display("MD format instruction");
							instructionFormat_o <= MD;
							xOpCode_o <= payload_i[27:29];
							bit1_o <= payload_i[30]; bit2_o <= payload_i[31];
						end
					end
					
					
				endcase
			end
			else
			begin
				$display("ERROR: Instruction format is invalid");
				//TODO: Write out error, throw exception
				enable_o <= 0;
			end
		end
		else
			enable_o <= 0;
	end
	



endmodule
