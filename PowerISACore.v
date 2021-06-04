`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
module PowerISACore#(parameter i_DatabusWidth = 32, parameter addressSize = 64, parameter iMemoryAddressSize = 16,
	parameter iCacheOffsetSize = 5, iCacheIndexSize = 8, iCacheBlockSize = addressSize - (offsetSize + indexSize)
	)(
	//command
	input wire clock_i,
	input wire reset_i,
	//I-memory updates (from memory)
	input wire [0:i_DatabusWidth-1] IBusUpdate_i,//data bus from memory
	input wire [0:addressSize-1] IAddress_i,//address where the data is to go (may not be needed)
	input wire IClock_i,//clock from memory to indicate data is on the bus
	//I-memory updates (from core)
	output wire [0:iMemoryAddressSize-1] IBusAddress_o,
	output wire enable_o
	
	
    );
	 
	 
	 


endmodule
