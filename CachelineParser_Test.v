`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   13:35:43 06/03/2021
// Design Name:   CachelineParser
// Module Name:   /home/hakaru/Projects/Verilog/PowerISA_CPU/CachelineParser_Test.v
// Project Name:  PowerISA_CPU
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: CachelineParser
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module CachelineParser_Test;

	// Inputs
	reg clock;
	reg enable;
	reg [0:255] cacheline;
	reg [0:50] tag;
	reg [0:7] index;
	reg [0:4] offset;

	// Outputs
	wire [0:31] fetchedPayload_o;
	wire enable_o;
	wire [0:50] tag_o;
	wire [0:7] index_o;
	wire [0:4] offset_o;

	// Instantiate the Unit Under Test (UUT)
	CachelineParser uut (
		.clock_i(clock), 
		.enable_i(enable), 
		.cacheline_i(cacheline), 
		.tag_i(tag), 
		.index_i(index), 
		.offset_i(offset), 
		.fetchedPayload_o(fetchedPayload_o), 
		.enable_o(enable_o), 
		.tag_o(tag_o), 
		.index_o(index_o), 
		.offset_o(offset_o)
	);

	initial begin
		// Initialize Inputs
		clock = 0;
		enable = 0;
		cacheline = 0;
		tag = 0;
		index = 0;
		offset = 0;
		#1;
		
		//parse one cacheline
		cacheline = 256'hFFFFFFFF_EEEEEEEE_DDDDDDDD_CCCCCCCC_BBBBBBBB_AAAAAAAA_99999999_88888888;
		tag = 10;
		index = 15;
		offset = 4;
		enable = 1;		
		clock = 1;
		#1;
		clock = 0;
		#1;
		
		//then another
		cacheline = 256'h88888888_99999999_AAAAAAAA_BBBBBBBB_CCCCCCCC_DDDDDDDD_EEEEEEEE_FFFFFFFF;
		tag = 12;
		index = 3;
		offset = 16;
		enable = 1;		
		clock = 1;
		#1;
		clock = 0;
		#1;
		
		//disable enable and see if it does anything (it shouldnt)
		cacheline = 256'h11111111_22222222_33333333_44444444_55555555_66666666_77777777_88888888;
		tag = 1;
		index = 2;
		offset = 4;
		enable = 0;		
		clock = 1;
		#1;
		clock = 0;
		#1;
	end
      
endmodule

