`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//This module is the instruction cache's instrucion memory module that perform's cacheline reads
//It implements a single port memory which may not be written to and read from at the same time
//The fetchEnable signal is used to perform a lookup whereas the updateEnable is used to write new cachelines into the cache
//This memory has a two cycle latency for read and a one cycle latency for writest he latency may be covered up becaues the
//reads and writes are pipelined so one read or write per cycle is possible including alternating writes and reads.
//NOTE: When writing; index_i must be set to zero and when reading newIndex_i must be set to zero. Failiure will cause
//accessed address to be (index_i | newIndex_i)
//Also when reading; updateEnable_i must be set to zero and when writing fetchEnable_i must be set to zero as this will
//result in undefined behaviour due to timing errors.
//////////////////////////////////////////////////////////////////////////////////
module CacheMemory #( parameter offsetSize = 5, parameter indexSize = 8, parameter tagSize = 64 - (offsetSize + indexSize),
	parameter cachelineSizeInBits = (2**offsetSize)*8, parameter numCachelines = 2**indexSize)(
	//command
	input wire clock_i,
	input wire reset_i,
	//fetch in
	input wire fetchEnable_i,
	input wire [0:tagSize-1] tag_i,
	input wire [0:indexSize-1] index_i,
	input wire [0:offsetSize-1] offset_i,
	//cach update in
	input wire updateEnable_i,
	input wire [0:cachelineSizeInBits-1] newCacheline_i,
	input wire [0:indexSize-1] newIndex_i,
	//fetch out
	output reg [0:tagSize-1] tag_o,
	output reg [0:indexSize-1] index_o,
	output reg [0:offsetSize-1] offset_o,
	output wire [0:cachelineSizeInBits-1] cacheline_o,
	output reg enable_o
	);
	 
	//bypass buffer
	reg [0:tagSize-1] bypassTag;
	reg [0:indexSize-1] bypassIndex;
	reg [0:offsetSize-1] bypassOffset;
	reg bypassEnable;
	
	//cache memory
	L1I_Memory l1I_Memory (
	.clka(clock_i),
	.rsta(reset_i),
	.wea(updateEnable_i),
	.addra(newIndex_i | index_i),
	.dina(newCacheline_i),
	.douta(cacheline_o)
	);
	
	always @(posedge clock_i)
	begin	
		//update buffers
		bypassEnable <= fetchEnable_i;
		if((fetchEnable_i == 1) && (updateEnable_i == 0))//if were fetching and not updating
		begin			
			bypassTag <= tag_i;
			bypassIndex <= index_i;
			bypassOffset <= offset_i;
		end
		else if((fetchEnable_i == 0) && (updateEnable_i == 1))//if were updating and not fetching
			$display("Writing to instruction L1I cache");
		else if((fetchEnable_i == 1) && (updateEnable_i == 1))
			$display("TIMING ERROR: Instruction cache memory canot read and write at the same time (collision is possible)");
			
		//write out buffers
		if(bypassEnable == 1)
		begin
			tag_o <= bypassTag;
			index_o <= bypassIndex;
			offset_o <= bypassOffset;
			enable_o <= bypassEnable;
		end
		else
			enable_o <= 0;		
	end
	 
endmodule
