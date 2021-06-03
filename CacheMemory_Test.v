`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   12:44:59 06/03/2021
// Design Name:   CacheMemory
// Module Name:   /home/hakaru/Projects/Verilog/PowerISA_CPU/CacheMemory_Test.v
// Project Name:  PowerISA_CPU
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: CacheMemory
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module CacheMemory_Test;

	// Inputs
	reg clock;
	reg reset;
	reg fetchEnable;
	reg [0:50] tag;
	reg [0:7] index;
	reg [0:4] offset;
	reg updateEnable;
	reg [0:255] newCacheline;
	reg [0:50] newTag;
	reg [0:7] newIndex;
	reg [0:4] newOffset;

	// Outputs
	wire [0:50] tag_o;
	wire [0:7] index_o;
	wire [0:4] offset_o;
	wire [0:255] cacheline_o;
	wire enable_o;

	// Instantiate the Unit Under Test (UUT)
	CacheMemory uut (
		//command
		.clock_i(clock), 
		.reset_i(reset), 
		//fetch input
		.fetchEnable_i(fetchEnable), 
		.tag_i(tag), 
		.index_i(index), 
		.offset_i(offset), 
		//update input
		.updateEnable_i(updateEnable), 
		.newCacheline_i(newCacheline), 
		.newTag_i(newTag),
		.newIndex_i(newIndex), 
		.newOffset_i(newOffset),
		//fetch/update output
		.tag_o(tag_o), 
		.index_o(index_o), 
		.offset_o(offset_o), 
		.cacheline_o(cacheline_o), 
		.enable_o(enable_o)
	);
	


	initial begin
		// Initialize Inputs
		clock = 0;
		reset = 0;
		fetchEnable = 0;
		tag = 0;
		index = 0;
		offset = 0;
		updateEnable = 0;
		newCacheline = 0;
		newTag = 0;
		newIndex = 0;
		newOffset = 0;
	
		//reset
		reset = 1;
		clock = 1;
		#1;
		reset = 0;
		clock = 1;
		
		//make two writes then two reads
		/*
		//Write to cacheline 0
		updateEnable = 1;
		newCacheline = 256'hFFFFFFFF_EEEEEEEE_DDDDDDDD_CCCCCCCC_BBBBBBBB_AAAAAAAA_99999999_88888888;
		newIndex = 0;
		clock = 1;
		#1;
		clock = 0;
		#1;
		//Write to cacheline 3
		newCacheline = 256'h88888888_99999999_AAAAAAAA_BBBBBBBB_CCCCCCCC_DDDDDDDD_EEEEEEEE_FFFFFFFF;
		newIndex = 3;
		clock = 1;
		#1;
		clock = 0;
		#1;
		
		//read from cacheline 0
		updateEnable = 0; fetchEnable = 1;
		newIndex = 0; index = 0;
		tag = 10; offset = 7;
		clock = 1;
		#1;
		clock = 0;
		#1;
		
		//read cacheline 3
		updateEnable = 0; fetchEnable = 1;
		newIndex = 0; index = 3;
		tag = 5; offset = 3;
		clock = 1;
		#1;
		clock = 0;
		#1;
		
		//one dry clock to empty the pipeline
		fetchEnable = 0;
		clock = 1;
		#1;
		clock = 0;
		#1;
		*/
		
		///Interleaved reads and writes
		//Write to cacheline 0
		updateEnable = 1; fetchEnable = 0;
		newCacheline = 256'hFFFFFFFF_EEEEEEEE_DDDDDDDD_CCCCCCCC_BBBBBBBB_AAAAAAAA_99999999_88888888;
		newIndex = 0;  index = 0;
		clock = 1;
		#1;
		clock = 0;
		#1;
		//read from cacheline 0
		updateEnable = 0; fetchEnable = 1;
		newIndex = 0; index = 0;
		tag = 55; offset = 7;
		clock = 1;
		#1;
		clock = 0;
		#1;
		//Write to cacheline 1
		updateEnable = 1; fetchEnable = 0;
		newCacheline = 256'h88888888_99999999_AAAAAAAA_BBBBBBBB_CCCCCCCC_DDDDDDDD_EEEEEEEE_FFFFFFFF;
		newIndex = 1;  index = 0;
		clock = 1;
		#1;
		clock = 0;
		#1;
		//read from cacheline 1
		updateEnable = 0; fetchEnable = 1;
		newIndex = 0; index = 1;
		tag = 123; offset = 4;
		clock = 1;
		#1;
		clock = 0;
		#1;
		
		//allow data to come out
		updateEnable = 0; fetchEnable = 0;
		newIndex = 0; index = 0;
		clock = 1;
		#1;
		clock = 0;
		#1;
		
	end
      
endmodule

