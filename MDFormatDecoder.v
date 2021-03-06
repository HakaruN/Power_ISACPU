`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//Implements all MD and MDS format instructions in the PowerISA 3.0B
//////////////////////////////////////////////////////////////////////////////////
module MDFormatDecoder#(parameter opcodeWidth = 6, parameter regWidth = 5, parameter immWidth = 6, parameter instructionWidth = 32,
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
	output reg [0:regWidth-1] reg1_o, reg2_o, reg3_o,//reg 3 is implicitley an immediate value
	output reg [0:immWidth-1] imm_o,
	output reg bit1_o, bit2_o,
	output reg [0:2] functionalUnitCode_o,
	output reg enable_o
	);

always @(posedge clock_i)
begin
	if(enable_i == 1)
	begin
		if(instruction_i[0:opcodeWidth-1] == 30)
		begin
			reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20];
			bit1_o <= instruction_i[30]; bit2_o <= instruction_i[31];
			imm_o <= instruction_i[21:26];
			case(instruction_i[27:29])//check for MD format
				0: begin $display("Rotate Left Doubleword Immediate then Clear Left");				
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FXUnitCode;
				end
				1: begin $display("Rotate Left Doubleword Immediate then Clear Right");
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FXUnitCode;
				end
				2: begin $display("Rotate Left Doubleword Immediate then Clear");
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FXUnitCode;
				end
				3: begin $display("Rotate Left Doubleword Immediate then Mask Insert");
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FXUnitCode;
				end
				default : enable_o <= 0;
			endcase
			//DONT USE DEFAULT IN ANY CASE/SWITCH BELOW (either that or only use a default in the last case statement and none above)
			case(instruction_i[27:30])//check for MDS format
				8: begin $display("Rotate Left Doubleword then Clear Left");
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FXUnitCode;
				end
				9: begin $display("Rotate Left Doubleword then Clear Right");
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FXUnitCode;
				end
			endcase			
		end
	end
	else
	begin
		enable_o <= 0;
		stall_o <= 0;
	end
end


endmodule
