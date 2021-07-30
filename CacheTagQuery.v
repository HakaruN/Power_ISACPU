`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//This module is a tag querying module that perform's tag lookups on direct mapped caches
//It implements a single port memory which may not be written to and read from at the same time
//The fetchEnable signal is used to perform a lookup whereas the  updateEnable is used to write new tags into the cache
//NOTE: a write automatically sets the valid bit
//This memory has a two cycle latency for read and a one cycle latency for writest he latency may be covered up becaues the
//reads and writes are pipelined so one read or write per cycle is possible including alternating writes and reads.
//NOTE: When writing; index_i must be set to zero and when reading newIndex_i must be set to zero. Failiure will cause
//accessed address to be (index_i | newIndex_i)
//Also when reading; updateEnable_i must be set to zero and when writing fetchEnable_i must be set to zero as this will
//result in undefined behaviour due to timing errors.
//////////////////////////////////////////////////////////////////////////////////
module CacheTagQuery #( parameter offsetSize = 5, parameter indexSize = 8, parameter tagSize = 64 - (offsetSize + indexSize),
	parameter cachelineSize = 2**offsetSize, parameter numCachelines = 2**indexSize)(
	//command
	input wire clock_i,
	input wire reset_i,
	input wire fetchEnable_i,
	input wire flushPipeline_i,
	input wire tagQueryStall_i,
	input wire fetchUnitStall_i,
	//fetch input
	input wire [0:tagSize-1] tag_i,
	input wire [0:indexSize-1] index_i,
	input wire [0:offsetSize-1] offset_i,
	//cache update input
	input wire [0:tagSize-1] newTag_i,
	input wire [0:indexSize-1] newIndex_i,
	input wire updateEnable_i,
	//fetch output
	output reg [0:tagSize-1] tag_o,
	output wire [0:tagSize] queriedTag_o,
	output reg [0:indexSize-1] index_o,
	output reg [0:offsetSize-1] offset_o,
	output reg enable_o
	);
	
	//bypass registers
	//the bypass reg's hold data for a cycle whilst the tag memory is read. The data is then writen out with the query result
	reg [0:tagSize-1] bypassTag;
	reg [0:indexSize-1] bypassIndex;
	reg [0:offsetSize-1] bypassOffset;
	reg bypassEnable;
	
	
	//tag memory
	tagMemory l1I_TagMem (
		.clka(clock_i),
		.rsta(reset_i),
		.ena(fetchEnable_i | updateEnable_i),
		.wea(updateEnable_i),
		.addra(newIndex_i | index_i),//															 V: TAG:
		.dina((newTag_i | 52'h8000000000000)),//set the valid bit to 1 - //1__0_0000000000_0000000000_0000000000_0000000000_0000000000
		.douta(queriedTag_o)
	);
	
	
	always @(posedge clock_i)
	begin	
	
		if(flushPipeline_i == 1)
		begin
			//$display("Stage 1 flushing pipeline");
			bypassTag <= 0;
			bypassIndex <= 0;
			bypassOffset <= 0;
			bypassEnable <= 0;
			tag_o <= 0;
			index_o <= 0;
			offset_o <= 0;
			enable_o <= 0;
		end
		else
		begin
			//update buffers
			bypassEnable <= fetchEnable_i;
			if((fetchEnable_i == 1) && (updateEnable_i == 0) && (tagQueryStall_i == 0) && (fetchUnitStall_i == 0))//check if enabled, not updating and not stalled
			begin
				bypassTag <= tag_i;
				bypassIndex <= index_i;
				bypassOffset <= offset_i;
				//$display("Stage 1 updating fetch buffers");
			end
			else if((fetchEnable_i == 0) && (updateEnable_i == 1))
			begin
				//$display("Writing to tag memory");			
			end
			if((fetchEnable_i == 1) && (updateEnable_i == 1))
			begin
				//TODO throw an error
				//$display("TIMING ERROR: Tag memory canot read and write at the same time (collision is possible)");
			end
			
			//write out buffers
			if(bypassEnable == 1)
			begin
				tag_o <= bypassTag;
				index_o <= bypassIndex;
				offset_o <= bypassOffset;
				enable_o <= bypassEnable;
				//$display("Stage 1 writing out buffers");
			end
			else
				enable_o <= 0;
		end
	end
	


endmodule
