`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//Implements all DQ instructions in the PowerISE 3.0B
//////////////////////////////////////////////////////////////////////////////////
module DQFormatDecoder#( parameter opcodeWidth = 6, parameter regWidth = 5, parameter immWidth = 12, parameter instructionWidth = 32
)(
	//command
	input wire clock_i,
	input wire enable_i,
	//data in
	input wire [0:instructionWidth-1] instruction_i,
	//data out
	output reg [0:regWidth-1] reg1_o, reg2_o,
	output reg [0:immWidth-1] imm_o,
	output reg bit_o,
	output reg enable_o
	);

	always @(posedge clock_i)
	begin
		if(instruction_i[0:opcodeWidth-1] == 56 && enable_i == 1)
		begin $display("Load Quadword");
			reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15];
			imm_o <= instruction_i[16:27];
			enable_o <= 1;
		end
		else if(instruction_i[0:opcodeWidth-1] == 61 && enable_i == 1)
		begin
			case(instruction_i[29:31])
			1: begin $display("Load VSX Vector");
				reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15];
				imm_o <= instruction_i[16:27];
				bit_o <= instruction_i[28];
				enable_o <= 1;
			end
			2: begin $display("Store VSX Vector");
				reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15];
				imm_o <= instruction_i[16:27];
				bit_o <= instruction_i[28];
				enable_o <= 1;
			end
			endcase
		end
		else
			enable_o <= 0;
	end

endmodule
