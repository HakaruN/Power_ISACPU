`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//
//////////////////////////////////////////////////////////////////////////////////
module FetchUnit #( parameter offsetSize = 5, parameter indexSize = 8, parameter tagSize = 64 - (offsetSize + indexSize),
	parameter cachelineSize = 2**offsetSize, cachelineSizeBits = 2**offsetSize*8, parameter numCachelines = 2**indexSize, parameter parsePayloadSizeBits=32)(
	//command
	input wire clock_i,
	input wire reset_i,
	//fetch in
	input wire enable_i,
	input wire [0:tagSize-1] tag_i,
	input wire [0:indexSize-1] index_i,
	input wire [0:offsetSize-1] offset_i,
	//cache update in
	input wire [0:tagSize-1] newTag_i,
	input wire [0:indexSize-1] newIndex_i,
	input wire [0:offsetSize-1] newOffset_i,
	input wire [0:cachelineSizeBits-1] newCacheline_i,
	input wire cacheUpdateEnable_i,	
	//fetch out
	output wire [0:tagSize-1] tag_o,
	output wire [0:indexSize-1] index_o,
	output wire [0:offsetSize-1] offset_o,
	output wire [0:parsePayloadSizeBits-1] fetchedInstruction_o,
	output wire enable_o,
	//cache update out
	output wire [0:tagSize-1] newTag_o,
	output wire [0:indexSize-1] newIndex_o,
	output wire [0:offsetSize-1] newOffset_o,
	output wire isCacheMiss_o
    );

	wire [0:tagSize]tagQueryQueriedTagOut;
	wire [0:tagSize-1]tagQueryFetchedTagOut;
	wire [0:indexSize-1]tagQueryIndexOut;
	wire [0:offsetSize-1]tagQueryOffsetOut;
	wire tagQueryEnableOut;
	
	//Stage 1
	CacheTagQuery
	cacheTagQuery(
		//command
		.clock_i(clock_i), 
		.reset_i(reset_i), 
		//fetch in
		.fetchEnable_i(enable_i), 
		.tag_i(tag_i), 
		.index_i(index_i), 
		.offset_i(offset_i), 
		//cache update in - if a cache miss comes back to write into the cache it comes in here
		.newTag_i(newTag_i), 
		.newIndex_i(newIndex_i), 
		.updateEnable_i(cacheUpdateEnable_i), 
		//fetch output
		.queriedTag_o(tagQueryQueriedTagOut), 
		.tag_o(tagQueryFetchedTagOut), 		
		.index_o(tagQueryIndexOut), 
		.offset_o(tagQueryOffsetOut), 
		.enable_o(tagQueryEnableOut)
	);
	
	wire [0:tagSize-1]CacheHitMissTagOut;
	wire [0:indexSize-1]CacheHitMissIndexOut;
	wire [0:offsetSize-1]CacheHitMissOffsetOut;
	wire CacheHitMissEnableOut;

	
	//Stage 2 
	CacheHitMissCheck 
	cacheHitMissCheck (
		//command
		.clock_i(clock_i), 
		.enable_i(tagQueryEnableOut), 
		//fetch input
		.queriedTag_i(tagQueryQueriedTagOut), 
		.fetchTag_i(tagQueryFetchedTagOut), 
		.index_i(tagQueryIndexOut), 
		.offset_i(tagQueryOffsetOut), 
		//cache update output (if cache miss memory request comes from here) - goes out to core
		.newTag_o(newTag_o), 
		.newIndex_o(newIndex_o), 
		.newOffset_o(newOffset_o), 
		.isCacheMiss_o(isCacheMiss_o), 
		//fetch output
		.tag_o(CacheHitMissTagOut), 
		.index_o(CacheHitMissIndexOut), 
		.offset_o(CacheHitMissOffsetOut), 
		.enable_o(CacheHitMissEnableOut)
	);
	
	wire [0:tagSize-1]cacheMemoryTagOut;
	wire [0:indexSize-1]cacheMemoryIndexOut;
	wire [0:offsetSize-1]cacheMemoryOffsetOut;
	wire [0:cachelineSizeBits-1] cacheMemoryCachelineOut;
	wire cacheMemoryEnableOut;

	//stage 3
	CacheMemory 
	cacheMemory (
		//command
		.clock_i(clock_i), 
		.reset_i(reset_i), 
		//fetch input
		.fetchEnable_i(CacheHitMissEnableOut), 
		.tag_i(CacheHitMissTagOut), 
		.index_i(CacheHitMissIndexOut), 
		.offset_i(CacheHitMissOffsetOut), 
		//cache update input - if a cache miss comes back to write into the cache it comes in here
		.updateEnable_i(cacheUpdateEnable_i), 
		.newCacheline_i(newCacheline_i), 
		.newTag_i(newTag_i),
		.newIndex_i(newIndex_i), 
		.newOffset_i(newOffset_i),
		//fetch output
		.tag_o(cacheMemoryTagOut), 
		.index_o(cacheMemoryIndexOut), 
		.offset_o(cacheMemoryOffsetOut), 
		.cacheline_o(cacheMemoryCachelineOut), 
		.enable_o(cacheMemoryEnableOut)
	);
	
	//stage 4
	CachelineParser
	cachelineParser (
		//command
		.clock_i(clock_i), 
		//fetch in
		.enable_i(cacheMemoryEnableOut), 
		.cacheline_i(cacheMemoryCachelineOut), 
		.tag_i(cacheMemoryTagOut), 
		.index_i(cacheMemoryIndexOut), 
		.offset_i(cacheMemoryOffsetOut), 
		//fetch out
		.fetchedPayload_o(fetchedInstruction_o), 
		.enable_o(enable_o), 
		.tag_o(tag_o), 
		.index_o(index_o), 
		.offset_o(offset_o)
	);

endmodule
