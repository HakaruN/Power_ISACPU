`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//Implements all DQ instructions in the PowerISE 3.0B
//////////////////////////////////////////////////////////////////////////////////
module DQFormatDecoder#( parameter opcodeWidth = 6, parameter regWidth = 5, parameter immWidth = 12, parameter instructionWidth = 32,
parameter signedImm = 1, parameter unsignedImm = 0, parameter regImm = 0, parameter regRead = 1, parameter regWrite = 2, parameter regReadWrite = 3,
parameter FXUnitCode = 0, parameter FPUnitCode = 1, parameter LdStUnitCode = 2, parameter BranchUnitCode = 3, parameter TrapUnitCode = 4//functional unit code/ID used for dispatch
)(
	//command in
	input wire clock_i,
	input wire enable_i,
	//data in
	input wire [0:instructionWidth-1] instruction_i,
	//command out
	output reg stall_o,
	//data out
	output reg [0:regWidth-1] reg1_o, reg2_o,
	output reg [0:1] reg1Use_o, reg2Use_o,//describes the operations to happen to the reg
	output reg [0:immWidth-1] imm_o,
	output reg immFormat_o,//0 = unsignedImm, 1 = signedImm (sign extended to 64b down the pipe)
	output reg bit_o,
	output reg [0:2] functionalUnitCode_o,
	output reg enable_o
	);

	always @(posedge clock_i)
	begin//TODO: Check if reg1 is odd or ==reg 2, if so then throw an error
		if(instruction_i[0:opcodeWidth-1] == 56 && enable_i == 1)
		begin $display("Load Quadword");
			reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15];
			reg1Use_o <= 
			imm_o <= instruction_i[16:27];
			enable_o <= 1; stall_o <= 0;
			functionalUnitCode_o <= LdStUnitCode;
		end
		else if(instruction_i[0:opcodeWidth-1] == 61 && enable_i == 1)
		begin
			case(instruction_i[29:31])
			1: begin $display("Load VSX Vector");
				reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15];
				imm_o <= instruction_i[16:27];
				bit_o <= instruction_i[28];
				enable_o <= 1; stall_o <= 0;
				functionalUnitCode_o <= LdStUnitCode;
			end
			2: begin $display("Store VSX Vector");
				reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15];
				imm_o <= instruction_i[16:27];
				bit_o <= instruction_i[28];
				enable_o <= 1; stall_o <= 0;
				functionalUnitCode_o <= LdStUnitCode;
			end
			endcase
		end
		else
		begin
			stall_o <= 0;
			enable_o <= 0;
			functionalUnitCode_o <= 0;
		end
	end	
endmodule
