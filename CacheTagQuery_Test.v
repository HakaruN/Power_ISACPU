`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   05:00:06 06/03/2021
// Design Name:   CacheTagQuery
// Module Name:   /home/hakaru/Projects/Verilog/PowerISA_CPU/CacheTagQuery_Test.v
// Project Name:  PowerISA_CPU
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: CacheTagQuery
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module CacheTagQuery_Test;

	// Inputs
	reg clock;
	reg reset;
	reg enable;
	reg [0:50] tag;
	reg [0:7] index;
	reg [0:4] offset;
	reg [0:50] newTag;
	reg [0:7] newIndex;
	reg cacheUpdateEnable;

	// Outputs
	wire [0:50] tag_o;
	wire [0:51] queriedTag_o;
	wire [0:7] index_o;
	wire [0:4] offset_o;
	wire enable_o;

	// Instantiate the Unit Under Test (UUT)
	CacheTagQuery uut (
		.clock_i(clock), 
		.reset_i(reset), 
		.fetchEnable_i(enable), 
		.tag_i(tag), 
		.index_i(index), 
		.offset_i(offset), 
		.newTag_i(newTag), 
		.newIndex_i(newIndex), 
		.updateEnable_i(cacheUpdateEnable), 
		.tag_o(tag_o), 
		.queriedTag_o(queriedTag_o), 
		.index_o(index_o), 
		.offset_o(offset_o), 
		.enable_o(enable_o)
	);

	initial begin
		// Initialize Inputs
		clock = 0;
		reset = 0;
		enable = 0;
		tag = 0;
		index = 0;
		offset = 0;
		newTag = 0;
		newIndex = 0;
		cacheUpdateEnable = 0;

		//reset
		clock = 1;
		reset = 1;
		#1;
		clock = 0;
		reset = 0;
		#1;
		
		///Pipelined writes then reads
		
		//write two items to the memory
		newTag = 1;
		newIndex = 8'd5;
		cacheUpdateEnable = 1;
		clock = 1;
		#1;		
		clock = 0;//by this point the first data should be latched into the memory's registers
		#1;
		newTag = 4;
		newIndex = 8'd10;
		clock = 1;
		#1;		
		clock = 0;//by this point the first data should be in the memory's memory and the second in the registers
		#1;	
		cacheUpdateEnable = 0;//stop writing to the registers
		
		//try to read the two data's back
		enable = 1;
		newIndex = 0;//Have to reset the new index back to zero when reading and index to zero when writing
		tag = 1;
		index = 8'd5;
		offset = 10;			
		clock = 1;
		#1;
		clock = 0;//by this point the bypass buffers should have the data bypassed data and the 
		// data from memory should be in the memory's registers but the data isn't on the output yet
		#1;			
		tag = 4;
		index = 8'd10;		
		clock = 1;
		#1;
		clock = 0;//by this point the first data should be on the outputs and second one buffered
		#1;
		$display("%b", queriedTag_o);
		
		enable = 0;
		clock = 1;
		#1;
		clock = 0;//by this point the second data should be on the outputs
		#1;
		$display("%b", queriedTag_o);
		clock = 1;
		#1;
		clock = 0;//by this point the enable out should have gone low
		#1;
		
		///Interleaved writes and reads
		/*
		//write:
		enable = 0;
		cacheUpdateEnable = 1;		
		newTag = 1;
		index = 8'd0;
		newIndex = 8'd5;
		clock = 1;
		#1;		
		clock = 0;
		#1;
		
		//read:
		enable = 1;
		cacheUpdateEnable = 0;
		tag = 1;
		index = 8'd5;
		newIndex = 8'd0;
		offset = 10;			
		clock = 1;
		#1;
		clock = 0;
		#1;
		enable = 0;
		clock = 1;
		#1;
		clock = 0;
		#1;
		
		//write:
		enable = 0;
		cacheUpdateEnable = 1;		
		newTag = 6;
		index = 8'd0;
		newIndex = 8'd10;
		clock = 1;
		#1;		
		clock = 0;
		#1;
		
		//read:
		enable = 1;
		cacheUpdateEnable = 0;
		tag = 6;
		index = 8'd10;
		newIndex = 8'd0;
		offset = 10;			
		clock = 1;
		#1;
		clock = 0;
		#1;
		
		//allow data to come out
		enable = 0;
		clock = 1;
		#1;
		clock = 0;
		#1;
		*/
	end
      
endmodule

