`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   07:09:28 06/03/2021
// Design Name:   CacheHitMissCheck
// Module Name:   /home/hakaru/Projects/Verilog/PowerISA_CPU/CacheTagHitMissCheck_Test.v
// Project Name:  PowerISA_CPU
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: CacheHitMissCheck
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module CacheTagHitMissCheck_Test;

	// Inputs
	reg clock;
	reg enable;
	reg [0:50] fetchTag;
	reg [0:51] queriedTag;
	reg [0:7] index;
	reg [0:4] offset;
	reg cacheUpdate;

	// Outputs
	wire [0:50] newTag_o;
	wire [0:7] newIndex_o;
	wire [0:4] newOffset_o;
	wire isCacheMiss_o;
	wire [0:50] tag_o;
	wire [0:7] index_o;
	wire [0:4] offset_o;
	wire enable_o;

	// Instantiate the Unit Under Test (UUT)
	CacheHitMissCheck uut (
		//command
		.clock_i(clock), 
		.enable_i(enable), 
		//fetch in
		.fetchTag_i(fetchTag), 
		.queriedTag_i(queriedTag), 
		.index_i(index), 
		.offset_i(offset), 
		//cache miss in
		.isCacheMissResolved_i(cacheUpdate),
		//cache miss out
		.newTag_o(newTag_o), 
		.newIndex_o(newIndex_o), 
		.newOffset_o(newOffset_o), 
		.isCacheMiss_o(isCacheMiss_o), 
		//fetch out
		.tag_o(tag_o), 
		.index_o(index_o), 
		.offset_o(offset_o), 
		.enable_o(enable_o)
	);

	initial begin
		// Initialize Inputs
		clock = 0;
		enable = 0;
		fetchTag = 0;
		queriedTag = 0;
		index = 0;
		offset = 0;
		cacheUpdate = 0;
		#1;
		
		///
		//This test should result in the first tests two having cache hits and the next three having misses
		///
		
		enable = 1;
		$display("\n");
		//two with matching tags and valid bits
		index = 10;
		queriedTag = 52'b1_000000000000000000000000000000000000000000000000001;
		fetchTag = 1;		
		clock = 1;
		#1;
		clock = 0;
		#1;
		$display("isCacheMiss: ", isCacheMiss_o);
		$display("\n");
		
		index = 10;
		offset = 5;
		queriedTag = 52'b1_000000000000000000000000000000000000000000000000100;
		fetchTag = 4;
		clock = 1;
		#1;
		clock = 0;
		#1;
		$display("isCacheMiss: ", isCacheMiss_o);
		$display("\n");

		//One where the tags dont match but valid bit set - should cache miss
		index = 10;
		offset = 5;
		queriedTag = 52'b1_000000000000000000000000000000000000000000000000101;
		fetchTag = 4;
		clock = 1;
		#1;
		clock = 0;
		#1;
		cacheUpdate = 1;//clear the cache miss state
		$display("isCacheMiss: ", isCacheMiss_o);
		$display("\n");
		
		//One where the tags match but valid bit not set - should cache miss
		index = 10;
		offset = 5;
		queriedTag = 52'b0_000000000000000000000000000000000000000000000000100;
		fetchTag = 4;
		clock = 1;
		#1;
		clock = 0;
		#1;
		cacheUpdate = 1;//clear the cache miss state
		$display("isCacheMiss: ", isCacheMiss_o);
		$display("\n");
		
		//One where the tags dont match and no valid bit set - should cache miss
		index = 10;
		offset = 5;
		queriedTag = 52'b1_000000000000000000000000000000000000000000000000101;
		fetchTag = 4;
		clock = 1;
		#1;
		clock = 0;
		#1;
		cacheUpdate = 1;//clear the cache miss state
		$display("isCacheMiss: ", isCacheMiss_o);

	end
      
endmodule

