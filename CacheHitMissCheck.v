`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    07:01:32 06/03/2021 
// Design Name: 
// Module Name:    CacheHitMissCheck 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module CacheHitMissCheck #( parameter offsetSize = 5, parameter indexSize = 8, parameter tagSize = 64 - (offsetSize + indexSize),
	parameter cachelineSize = 2**offsetSize, parameter numCachelines = 2**indexSize)(
	input wire clock_i,
	input wire enable_i,
	input wire [0:tagSize-1] fetchTag_i,
	input wire [0:tagSize] queriedTag_i,
	input wire [0:indexSize-1] index_i,
	input wire [0:offsetSize-1] offset_i,
	//cache miss output
	output reg [0:tagSize-1] newTag_o,
	output reg [0:indexSize-1] newIndex_o,
	output reg [0:offsetSize-1] newOffset_o,
	output reg isCacheMiss_o,
	//cache memory access output
	output reg [0:tagSize-1] tag_o,
	output reg [0:indexSize-1] index_o,
	output reg [0:offsetSize-1] offset_o,
	output reg enable_o
	);

	always @(posedge clock_i)
	begin
		if(enable_i == 1)
		begin			
			//	Check valid bit:							//check tags match	
			if(((queriedTag_i & 52'h8000000000000) > 0) && (queriedTag_i[1:tagSize] == fetchTag_i))
			begin//cache hit
				tag_o <= fetchTag_i;
				index_o <= index_i;
				offset_o <= offset_i;
				isCacheMiss_o <= 0;
				enable_o <= 1;
			end
			else//cache miss
			begin
				newTag_o <= fetchTag_i;
				newIndex_o <= index_i;
				newOffset_o <= offset_i;
				isCacheMiss_o <= 1;
				enable_o <= 0;
			end
		end
	end

endmodule
