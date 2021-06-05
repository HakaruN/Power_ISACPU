`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
module DecodeUnit#( parameter instructionWidth = 32, parameter addressSize = 64
)(
	//command	
	input wire clock_i,
	input wire reset_i,
	input wire enable_i,
	//data in
	input wire [0:instructionWidth-1] instruction_i,
	input wire [0:addressSize-1] instructionAddress_i
	);
	
	always @(posedge clock_i)
	begin
		
	end
	

endmodule
