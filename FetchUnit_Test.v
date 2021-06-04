`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   14:31:09 06/03/2021
// Design Name:   FetchUnit
// Module Name:   /home/hakaru/Projects/Verilog/PowerISA_CPU/FetchUnit_Test.v
// Project Name:  PowerISA_CPU
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: FetchUnit
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module FetchUnit_Test;

	// Inputs
	reg clock;
	reg reset;
	reg enable;
	reg [0:50] tag;
	reg [0:7] index;
	reg [0:4] offset;
	reg [0:50] newTag;
	reg [0:7] newIndex;
	reg [0:4] newOffset;
	reg [0:255] newCacheline;
	reg cacheUpdateEnable;
	reg flushPipeline;

	// Outputs
	wire [0:50] tag_o;
	wire [0:7] index_o;
	wire [0:4] offset_o;
	wire [0:31] fetchedInstruction_o;
	wire enable_o;
	wire [0:50] newTag_o;
	wire [0:7] newIndex_o;
	wire [0:4] newOffset_o;
	wire isCacheMiss_o;

	// Instantiate the Unit Under Test (UUT)
	FetchUnit uut (
		//control
		.clock_i(clock), 
		.reset_i(reset), 
		.flushPipleine_i(flushPipeline),
		//fetch input
		.enable_i(enable), 
		.tag_i(tag), 
		.index_i(index), 
		.offset_i(offset), 
		//cache update input
		.newTag_i(newTag), 
		.newIndex_i(newIndex), 
		.newOffset_i(newOffset), 
		.newCacheline_i(newCacheline), 
		.cacheUpdateEnable_i(cacheUpdateEnable),
		//fetch output
		.tag_o(tag_o), 
		.index_o(index_o), 
		.offset_o(offset_o), 
		.fetchedInstruction_o(fetchedInstruction_o), 
		.enable_o(enable_o), 
		//cache update output
		.newTag_o(newTag_o), 
		.newIndex_o(newIndex_o), 
		.newOffset_o(newOffset_o), 
		.isCacheMiss_o(isCacheMiss_o)
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
		newOffset = 0;
		newCacheline = 0;
		cacheUpdateEnable = 0;
		flushPipeline = 0;

		//reset
		reset = 1;
		clock = 1;
		#1;
		reset = 0;
		clock = 0;
		#1;
		
		////try to fetch an instruction that isn't in cache yet (ought to result in cache miss)
		enable = 1;
		tag = 5;
		index = 8;
		offset = 4;
		
		clock = 1;
		#1;
		clock = 0;
		#1;
		enable = 0;
		clock = 1;
		#1;
		clock = 0;//by this point the tag should have been queried from the tag memory
		#1;
		
		clock = 1;
		#1;
		clock = 0;//by this point the cache should be known to have had a miss
		#1;
		$display("Is cache miss: %b", isCacheMiss_o);
		$display("Cache looking for tag:%d, index %d and offset %d", newTag_o, newIndex_o, newOffset_o);
		
		//now that we've had a cache miss, we'll write it back
		newTag = tag;
		index = 0;
		newIndex = 8;
		newOffset = 0;
		newCacheline = 256'hFFFFFFFF_EEEEEEEE_DDDDDDDD_CCCCCCCC_BBBBBBBB_AAAAAAAA_99999999_88888888;
		cacheUpdateEnable = 1;
		clock = 1;
		#1;
		clock = 0;
		#1;
		cacheUpdateEnable = 0;
		/*
		clock = 1;
		#1;
		clock = 0;
		#1;
		*/
		
		newCacheline = 0;//REMEMBER: RESET THESE AFTER A CACHELINE UPDATE!!!!!!
		newIndex = 0;
		cacheUpdateEnable = 0;
		clock = 1;
		#1;
		clock = 0;//by this point the data should be available to be parsed
		#1;
		
		cacheUpdateEnable = 0;		
		clock = 1;
		#1;
		clock = 0;//by this point the data ought to be parsed and instruction available on the output
		#1;
		
		
		//flush pipeline first
		////Now that the cacheline has been loaded, lets fetch the next instruction
		flushPipeline = 1;
		clock = 1;
		#1;
		clock = 0;
		flushPipeline = 0;
		#1;
		
		enable = 1;
		tag = 5;
		index = 8;
		offset = 8;
		
		clock = 1;
		#1;
		clock = 0;
		#1;
		enable = 0;
		
		clock = 1;
		#1;
		clock = 0;//by this point the tag should have been queried from the tag memory
		#1;
		
		clock = 1;
		#1;
		clock = 0;
		#1;
		
		clock = 1;
		#1;
		clock = 0;
		#1;//by this point the cache should be known to have had a hit
		
		clock = 1;
		#1;
		clock = 0;//by this point the data should be available to be parsed
		#1;
		
		clock = 1;
		#1;
		clock = 0;
		#1;
		
		clock = 1;
		#1;
		clock = 0;//by this point the data ought to be parsed and instruction available on the output
		#1;
		
		
		$display("Starting sequential cacheline read test");
		////Now lets read a couple of instructions
		enable = 1;
		tag = 5;
		index = 8;
		offset = 0;		
		clock = 1;
		#1;
		clock = 0;
		#1;$display("");
		//enable = 0;
		
		
		enable = 1;
		tag = 5;
		index = 8;
		offset = 4;
		clock = 1;
		#1;
		clock = 0;
		#1;$display("");		
		
		enable = 1;
		tag = 5;
		index = 8;
		offset = 8;
		clock = 1;
		#1;
		clock = 0;
		#1;$display("");
		
		
		enable = 1;
		tag = 5;
		index = 8;
		offset = 16;
		clock = 1;
		#1;
		clock = 0;
		#1;$display("");
		
		
		enable = 1;
		tag = 5;
		index = 8;
		offset = 20;
		clock = 1;
		#1;
		clock = 0;
		#1;$display("");
				
		enable = 1;
		tag = 5;
		index = 8;
		offset = 24;
		clock = 1;
		#1;
		clock = 0;
		#1;$display("");
				
		enable = 1;
		tag = 5;
		index = 8;
		offset = 28;
		clock = 1;
		#1;
		clock = 0;
		#1;$display("");
		enable = 0;
		
		clock = 1;
		#1;
		clock = 0;
		#1;	$display("");	
		clock = 1;
		#1;
		clock = 0;
		
		#1;	$display("");	
		clock = 1;
		#1;
		clock = 0;
		#1;$display("");
		
		clock = 1;
		#1;
		clock = 0;
		#1;	$display("");	
		
		clock = 1;
		#1;
		clock = 0;
		#1;$display("");
		clock = 1;
		#1;
		clock = 0;
		#1;$display("");
		/*
		*/
	end
      
endmodule

