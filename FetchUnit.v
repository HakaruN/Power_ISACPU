`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//
//////////////////////////////////////////////////////////////////////////////////
module FetchUnit #( parameter offsetSize = 5, parameter indexSize = 8, parameter tagSize = 64 - (offsetSize + indexSize), parameter addressSize = 64,
	parameter cachelineSize = 2**offsetSize, cachelineSizeBits = 2**offsetSize*8, parameter numCachelines = 2**indexSize, parameter parsePayloadSizeBits=32)(
	//command
	input wire clock_i,
	input wire reset_i,
	input wire flushPipeline_i,
	//fetch in
	input wire enable_i,
	input wire [0:addressSize-1] address_i,
	//cache update in
	input wire [0:addressSize-1] newAddress_i,
	input wire [0:cachelineSizeBits-1] newCacheline_i,
	input wire cacheUpdateEnable_i,	
	//fetch out
	output wire [0:addressSize-1] fetchedInstructionAddress_o,
	output wire [0:parsePayloadSizeBits-1] fetchedInstruction_o,
	output wire enable_o,
	//cache update out
	output wire [0:addressSize-1] newAddress_o,
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
		.flushPipeline_i(flushPipeline_i),
		//fetch in
		.fetchEnable_i(enable_i), 
		.tag_i(address_i[(offsetSize + indexSize)+:tagSize]), 
		.index_i(address_i[offsetSize+:indexSize]), 
		.offset_i(address_i[0+:offsetSize]), 
		//cache update in - if a cache miss comes back to write into the cache it comes in here
		.newTag_i(newAddress_i[(offsetSize + indexSize)+:tagSize]), 
		.newIndex_i(newAddress_i[offsetSize+:indexSize]), 
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
		.flushPipeline_i(flushPipeline_i),
		//fetch input
		.queriedTag_i(tagQueryQueriedTagOut), 
		.fetchTag_i(tagQueryFetchedTagOut), 
		.index_i(tagQueryIndexOut), 
		.offset_i(tagQueryOffsetOut), 
		//cache miss inputs - allows a cache miss' state in this stage to be cleared
		.isCacheMissResolved_i(cacheUpdateEnable_i),
		//cache update output (if cache miss memory request comes from here) - goes out to core		
		.newTag_o(newAddress_o[(offsetSize + indexSize)+:tagSize]), 
		.newIndex_o(newAddress_o[offsetSize+:indexSize]), 
		.newOffset_o(newAddress_o[0+:offsetSize]), 
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
		.flushPipeline_i(flushPipeline_i),
		//fetch input
		.fetchEnable_i(CacheHitMissEnableOut), 
		.tag_i(CacheHitMissTagOut), 
		.index_i(CacheHitMissIndexOut), 
		.offset_i(CacheHitMissOffsetOut), 
		//cache update input - if a cache miss comes back to write into the cache it comes in here
		.updateEnable_i(cacheUpdateEnable_i), 
		.newCacheline_i(newCacheline_i), 
		.newTag_i(newAddress_i[(offsetSize + indexSize)+:tagSize]), 
		.newIndex_i(newAddress_i[offsetSize+:indexSize]), 
		.newOffset_i(newAddress_i[0+:offsetSize]),
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
		.flushPipeline_i(flushPipeline_i),
		//fetch in
		.enable_i(cacheMemoryEnableOut), 
		.cacheline_i(cacheMemoryCachelineOut), 
		.tag_i(cacheMemoryTagOut), 
		.index_i(cacheMemoryIndexOut), 
		.offset_i(cacheMemoryOffsetOut), 
		//fetch out
		.fetchedPayload_o(fetchedInstruction_o), 
		.enable_o(enable_o), 
		.tag_o(fetchedInstructionAddress_o[(offsetSize + indexSize)+:tagSize]), 
		.index_o(fetchedInstructionAddress_o[offsetSize+:indexSize]), 
		.offset_o(fetchedInstructionAddress_o[0+:offsetSize])
	);

endmodule
