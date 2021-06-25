`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
module PowerISACore#(parameter i_DatabusWidth = 32, parameter addressSize = 64, parameter iMemoryAddressSize = 16, parameter instructionSize = 32,
	parameter iCacheOffsetSize = 5, iCacheIndexSize = 8, iCacheTagSize = addressSize - (iCacheOffsetSize + iCacheIndexSize), parameter blockSize = 256,	
	parameter formatIndexRange = 5, parameter opcodeWidth = 6, parameter xOpCodeWidth = 10, parameter regWidth = 5
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
	wire stallTagQuery;
	wire stallFullUnit;
	FetchUnit fetchUnit (
		//control
		.clock_i(clock_i), 
		.reset_i(reset_i), 
		.flushPipeline_i(flushPipeline),
		.tagQueryStall_i(stallTagQuery),
		.fetchUnitStall_i(stallFullUnit),
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
	
	
	
	//decode
	//decode output
	wire [0:5] decodeStall;
	wire decodeEnable;
	wire [0:63] decodeImm;
	wire decodeImmEnable;
	wire [0:regWidth-1] decodeReg1, decodeReg2, decodeReg3;
	wire [0:1] reg1Use, reg2Use, reg3Use;
	wire decodeReg1Enable, decodeReg2Enable, decodeReg3Enable;
	wire decodeReg3IsImmediate;
	wire decodeBit1, decodeBit2;
	wire decodeBit1Enabled, decodeBit2Enabled;
	wire decodeReg2ValOrZero;
	wire [0:addressSize-1] decodeInstructionAddress;
	wire [0:opcodeWidth-1] decodeOpCode;
	wire [0:xOpCodeWidth-1] decodeXOpcode;
	wire decodeXOpCodeEnabled;
	wire [0:formatIndexRange-1] decodeInstructionFormat;
	DecodeUnit #(
	.instructionWidth(instructionSize), .addressSize(addressSize), .formatIndexRange(formatIndexRange),
	.opcodeWidth(opcodeWidth), .xOpCodeWidth(xOpCodeWidth), .regWidth(regWidth))
	decodeUnit
	(
	//command in
	.clock_i(clock_i),
	.enable_i(fetchEnable_o),
	//data in
	.instruction_i(fetchedInstruction),
	.instructionAddress_i(fetchedInstructionAddress),
	//command out
	.stall_o(decodeStall),
	//data out
	.enable_o(decodeEnable),
	.imm_o(decodeImm),
	.immEnable_o(decodeImmEnable),
	.reg1_o(decodeReg1), .reg2_o(decodeReg2), .reg3_o(decodeReg3),
	.reg1Use_o(reg1Use), .reg2Use_o(reg2Use), .reg3Use_o(reg3Use),
	.reg1Enable_o(decodeReg1Enable), .reg2Enable_o(decodeReg2Enable), .reg3Enable_o(decodeReg3Enable),
	.reg3IsImmediate_o(decodeReg3IsImmediate),
	.bit1_o(decodeBit1), .bit2_o(decodeBit2),
	.bit1Enabled_o(decodeBit1Enabled), .bit2Enabled_o(decodeBit2Enabled),
	.reg2ValOrZero_o(decodeReg2ValOrZero),
	.instructionAddress_o(decodeInstructionAddress),
	.opCode_o(decodeOpCode),
	.xOpcode_o(decodeXOpcode),
	.xOpCodeEnabled_o(decodeXOpCodeEnabled),
	.instructionFormat_o(decodeInstructionFormat)
	);
	

	//Register unit
	RegisterUnit registerUnit (
    .clock_i(clock_i), 
    .reset_i(reset_i), 
	 //reg read in
    .enable_i(decodeEnable), 
    .imm_i(decodeImm), 
    .reg1_i(decodeReg1), .reg2_i(decodeReg2), .reg3_i(decodeReg3), 
    .bit1_i(decodeBit1), .bit2_i(decodeBit2), 
    .immEnable_i(decodeImmEnable), 
    .reg1Enable_i(decodeReg1Enable), .reg2Enable_i(decodeReg2Enable), .reg3Enable_i(decodeReg3Enable), 
    .bit1Enable_i(decodeBit1Enabled), .bit2Enable_i(decodeBit2Enabled), 
    .reg1Use_i(reg1Use), .reg2Use_i(reg2Use), .reg3Use_i(reg3Use), 
    .reg3IsImmediate_i(decodeReg3IsImmediate), 
    .reg2ValOrZero_i(decodeReg2ValOrZero), 
    .instructionAddress_i(decodeInstructionAddress), 
    .opCode_i(decodeOpCode), 
    .xOpcode_i(decodeXOpcode), 
    .xOpCodeEnabled_i(decodeXOpCodeEnabled), 
    .instructionFormat_i(decodeInstructionFormat), 
	 //reg write in
    .reg1WritebackData_i(reg1WritebackData_i), 
    .reg2WritebackData_i(reg2WritebackData_i), 
    .reg1isWriteback_i(reg1isWriteback_i), 
    .reg2isWriteback_i(reg2isWriteback_i), 
    .stall_o(stall_o), 
    .enable_o(enable_o), 
	 //reg read out
    .operand1_o(operand1_o), 
    .operand2_o(operand2_o), 
    .operand3_o(operand3_o), 
    .bit1_o(bit1_o), 
    .bit2_o(bit2_o), 
    .operand1Enable_o(operand1Enable_o), 
    .operand2Enable_o(operand2Enable_o), 
    .operand3Enable_o(operand3Enable_o), 
    .bit1Enable_o(bit1Enable_o), 
    .bit2Enable_o(bit2Enable_o), 
    .instructionAddress_o(instructionAddress_o), 
    .opCode_o(opCode_o), 
    .xOpCode_o(xOpCode_o), 
    .xOpCodeEnabled_o(xOpCodeEnabled_o), 
    .instructionFormat_o(instructionFormat_o)
    );

	//stall unit
	StallUnit stallUnit(
		//stall inputs
		.l1iCacheMissStall_i(isCacheMiss),
		.regFileStall_i(),
		//stall outputs
		.fetchFullStall_o(stallFullUnit),
		.fetchTagQueryStall_o(stallTagQuery)
	);

endmodule
