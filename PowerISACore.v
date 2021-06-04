`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
module PowerISACore#(parameter i_DatabusWidth = 32, parameter addressSize = 64, parameter iMemoryAddressSize = 16, parameter instructionSize = 32,
	parameter iCacheOffsetSize = 5, iCacheIndexSize = 8, iCacheTagSize = addressSize - (iCacheOffsetSize + iCacheIndexSize), parameter blockSize = 256
	)(
	//command
	input wire clock_i,
	input wire reset_i,
	//I-memory updates (from memory)
	input wire IMemClock_i,
	input wire IMemEnable_i,
	input wire [0:i_DatabusWidth-1]IMemDataBus_i,
	output wire [0:i_DatabusWidth-1]IMemDataBus_o,
	output wire [0:iMemoryAddressSize-1] IMemAddressBus_o,
	output wire IMEMisWriteOperation_o,
	output wire IMemMakeRequest_o
	);
	
	//pipeline state
	wire [0:addressSize-1] memoryRequestAddress;//when a cache miss happens, this gets the address to fetch from
	wire isCacheMiss;
	reg flushPipeline;	
	reg fetchEnable;//enable signal to the fetch unit - NOTE: the enable must be zero when isCacheMiss == 1
	reg [0:addressSize-1] PC;//fetch Address
	
	//memory controller out
	wire [0:blockSize-1] memoryReadBlock;//the block that came from memory
	wire [0:addressSize-1] memoryReadAddress;//the address that was read from memory (or written to actually maybe)
	wire memoryBlockValid;//when the block out is complete, this goes high. Its the out enable of the MCU
	wire isMemoryEngaged;//Allows the core to know if there is a memory request already happening.	
	MemoryController IMemoryController (
		//command
		.clock_i(clock_i), 
		.reset_i(reset_i), 
		//from core - memory request
		.address_i(memoryRequestAddress), 
		.data_i(),
		.requestEnable_i(isCacheMiss), 
		.isMemWrite_i(),
		//to core - block write to core
		.block_o(memoryReadBlock), 
		.blockAddress_o(memoryReadAddress), 
		.blockOutEnable_o(memoryBlockValid), 
		.isMemoryEngaged_o(isMemoryEngaged), 
		//from mem - word write from memory
		.memEnable_i(IMemEnable_i), 
		.memoryClock_i(IMemClock_i), 
		.memoryDataBus_i(IMemDataBus_i), 
		//to memory - read and write requests
		.memoryDataBus_o(IMemDataBus_o),
		//command pins:
		.address_o(IMemAddressBus_o), 
		.isWrite_o(IMEMisWriteOperation_o), 
		.memoryMakeRequest_o(IMemMakeRequest_o)
	);
	 
	//Fetch unit:
	wire [0:addressSize-1] fetchedInstructionAddress;
	wire [0:instructionSize-1] fetchedInstruction;
	wire fetchEnable_o;
	FetchUnit fetchUnit (
		//control
		.clock_i(clock_i), 
		.reset_i(reset_i), 
		.flushPipeline_i(flushPipeline),
		//fetch input
		.enable_i(fetchEnable), 
		.address_i(PC), 
		//cache update input
		.newAddress_i(memoryReadAddress), 
		.newCacheline_i(memoryReadBlock), 
		.cacheUpdateEnable_i(memoryBlockValid),
		//fetch output
		.fetchedInstructionAddress_o(fetchedInstructionAddress),
		.fetchedInstruction_o(fetchedInstruction), 
		.enable_o(fetchEnable_o), 
		//cache update output
		.newAddress_o(memoryRequestAddress), 
		.isCacheMiss_o(isCacheMiss)
	);


endmodule
