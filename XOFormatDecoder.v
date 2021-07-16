`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//Parses all XO format instructions in the POWER ISA 3.0B instruction set
//////////////////////////////////////////////////////////////////////////////////
module XOFormatDecoder#( parameter opcodeWidth = 6, parameter xOpCodeWidth = 9, parameter regWidth = 5, parameter instructionWidth = 32,
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
	output reg [0:regWidth-1] reg1_o, reg2_o, reg3_o,
	output reg [0:xOpCodeWidth-1]xOpCode_o,
	output reg bit1_o, bit2_o,
	output reg [0:1] functionalUnitCode_o,
	output reg enable_o
	);

	always @(posedge clock_i)
	begin
		if((enable_i == 1) && (instruction_i[0:opcodeWidth-1] == 31))
		begin
			xOpCode_o <= instruction_i[22:30];
			bit1_o <= instruction_i[21]; bit2_o <= instruction_i[31];
			reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20];
			case(instruction_i[22+:xOpCodeWidth])
				266: begin $display("Add");	
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FXUnitCode;
				end
				40: begin $display("Subtract From");
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FXUnitCode;
				end
				10: begin $display("Add Carrying");
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FXUnitCode;
				end
				8: begin $display("Subtract From Carrying");
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FXUnitCode;
				end
				138: begin $display("Add Extended");
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FXUnitCode;
				end
				136: begin $display("Subtract From Extended");
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FXUnitCode;
				end
				234: begin $display("Add to Minus One Extended");
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FXUnitCode;
				end
				232: begin $display("Subtract From Minus One Extended");
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FXUnitCode;
				end
				200: begin $display("Subtract From Zero Extended");
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FXUnitCode;
				end
				202: begin $display("Add to Zero Extended");
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FXUnitCode;
				end
				104: begin $display("Negate");
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FXUnitCode;
				end
				235: begin $display("Multiply Low Word");
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FXUnitCode;
				end
				11: begin $display("Multiply High Word Unsigned");
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FXUnitCode;
				end
				491: begin $display("Divide Word");
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FXUnitCode;
				end
				459: begin $display("Divide Word Unsigned");
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FXUnitCode;
				end
				427: begin $display("Divide Word Extended");
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FXUnitCode;
				end
				395: begin $display("Divide Word Extended Unsigned");
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FXUnitCode;
				end
				233: begin $display("Multiply Low Doubleword");
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FXUnitCode;
				end
				73: begin $display("Multiply High Doubleword");
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FXUnitCode;
				end
				9: begin $display("Multiply High Doubleword Unsigned");
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FXUnitCode;
				end				
				489: begin $display("Divide Doubleword");
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FXUnitCode;
				end
				457: begin $display("Divide Doubleword Unsigned");
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FXUnitCode;
				end
				425: begin $display("Divide Doubleword Extended");
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FXUnitCode;
				end
				393: begin $display("Divide Doubleword Extended Unsigned");
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FXUnitCode;
				end
				74: begin $display("Add and Generate Sixes");
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FXUnitCode;
				end
			endcase
		end
		else
		begin
			enable_o <= 0;
			stall_o <= 0;
		end
	end

endmodule
