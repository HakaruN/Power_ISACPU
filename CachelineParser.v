`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:25:59 06/03/2021 
// Design Name: 
// Module Name:    CachelineParser 
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
module CachelineParser #( parameter offsetSize = 5, parameter indexSize = 8, parameter tagSize = 64 - (offsetSize + indexSize),
	parameter cachelineSizeInBits = (2**offsetSize)*8, parameter parsePayloadSizeBits=32 )(
	//command
	input wire clock_i,
	//parse input
	input wire enable_i,
	input wire [0:cachelineSizeInBits-1] cacheline_i,
	input wire [0:tagSize-1] tag_i,
	input wire [0:indexSize-1] index_i,
	input wire [0:offsetSize-1] offset_i,
	//parse output
	output reg [0:parsePayloadSizeBits-1] fetchedPayload_o,//instruction or word
	output reg enable_o,
	output reg [0:tagSize-1] tag_o,
	output reg [0:indexSize-1] index_o,
	output reg [0:offsetSize-1] offset_o
    );
	 
	always @(posedge clock_i)
	begin
	
		enable_o <= enable_i;
		if(enable_i)
		begin
			tag_o <= tag_i;
			index_o <= index_i;
			offset_o <= offset_i;
		end
		fetchedPayload_o <= cacheline_i[offset_i*8+:parsePayloadSizeBits];
	end

endmodule
