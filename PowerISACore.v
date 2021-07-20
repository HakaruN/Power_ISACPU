`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
module PowerISACore#(parameter i_DatabusWidth = 32, parameter addressSize = 64, parameter iMemoryAddressSize = 16, parameter instructionSize = 32,
	parameter iCacheOffsetSize = 5, iCacheIndexSize = 8, iCacheTagSize = addressSize - (iCacheOffsetSize + iCacheIndexSize), parameter blockSize = 256,	
	parameter formatIndexRange = 5, parameter opcodeWidth = 6, parameter xOpCodeWidth = 10, parameter regWidth = 5, parameter immWidth = 16
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
	wire [0:1] decodeFunctionalUnitCode;
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
	.functionalUnitCode_o(decodeFunctionalUnitCode),
	.instructionFormat_o(decodeInstructionFormat)
	);


	//reg read output - exec unit input
	wire RegOutEnable;
	wire [0:63] RegOutOperand1, RegOutOperand2, RegOutOperand3;
	wire [0:regWidth-1] RegOutReg1Address, RegOutReg2Address, RegOutReg3Address;
	wire [0:immWith-1] RegOutImm;
	wire RegOutImmEnable;
	wire RegOutBit1, RegOutBit2;
	wire RegOutOperand1Enable, RegOutOperand2Enable, RegOutOperand3Enable, RegOutBit1Enable, RegOutBit2Enable;
	wire RegOutOperand1Writeback, RegOutOperand2Writeback, RegOutOperand3Writeback;
	wire [0:63] RegOutInstructionAddress;
	wire [0:opcodeWidth-1] RegOutOpCode;
	wire [0:xOpCodeWidth-1] RegOutXOpCode;
	wire RegOutXOpCodeEnabled;
	wire [0:1] RegOutFunctionalUnitCode;
	wire [0:formatIndexRange-1] RegOutInstructionFormat;
	wire RegOutis64Bit;

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
	 .functionalUnitCode_i(decodeFunctionalUnitCode),
    .instructionFormat_i(decodeInstructionFormat), 
	 //reg write in
    .reg1WritebackData_i(reg1WritebackData_i), 
    .reg2WritebackData_i(reg2WritebackData_i), 
    .reg1isWriteback_i(reg1isWriteback_i), 
    .reg2isWriteback_i(reg2isWriteback_i), 
    .stall_o(stall_o), 
    .enable_o(enable_o),	 
	 .is64Bit_i(),
	 //reg read out
	 .enable_o(RegOutEnable),
	 .is64Bit_o(RegOutis64Bit),
    .operand1_o(RegOutOperand1), .operand2_o(RegOutOperand2), .operand3_o(RegOutOperand3), 
	 .reg1Address_o(RegOutReg1Address), .reg2Address_o(RegOutReg2Address), .reg3Address_o(RegOutReg3Address),
	 .imm_o(RegOutImm), .immEnable_o(RegOutImmEnable),
    .bit1_o(RegOutBit1), .bit2_o(RegOutBit2), 
    .operand1Enable_o(RegOutOperand1Enable), .operand2Enable_o(RegOutOperand2Enable), .operand3Enable_o(RegOutOperand3Enable),
    .bit1Enable_o(RegOutBit1Enable), .bit2Enable_o(RegOutBit2Enable),
    .instructionAddress_o(RegOutInstructionAddress),
    .opCode_o(RegOutOpCode),
    .xOpCode_o(RegOutXOpCode),
    .xOpCodeEnabled_o(RegOutXOpCodeEnabled),
	 .functionalUnitCode_o(RegOutFunctionalUnitCode),
    .instructionFormat_o(RegOutInstructionFormat)
    );
	
	
	//exec units
	Execution #(
	.FXUnitCode(FXUnitCode), .FPUnitCode(FPUnitCode), .LdStUnitCode(LdStUnitCode), .BranchUnitCode(BranchUnitCode), .TrapUnitCode(TrapUnitCode))
	executionUnits(
		//command
		.clock_i(clock_i),
		.reset_i(reset_i),
		//from reg read
		.enable_i(RegOutEnable),
		.is64Bit_i(RegOutis64Bit),
		.functionalUnitCode_i(RegOutFunctionalUnitCode),
		.operand1_i(RegOutOperand1), .operand2_i(RegOutOperand2), .operand3_i(RegOutOperand3),
		.reg1Address_i(RegOutReg1Address), .reg2Address_i(RegOutReg2Address), .reg3Address_i(RegOutReg3Address),
		.imm_i(RegOutImm), .immEnable_i(RegOutImmEnable),
		.bit1_i(RegOutBit1), .bit2_i(RegOutBit2),
		.operand1Enable_i(RegOutOperand1Enable), .operand2Enable_i(RegOutOperand2Enable), .operand3Enable_i(RegOutOperand3Enable), .bit1Enable_i(RegOutBit1Enable), .bit2Enable_i(RegOutBit2Enable),
		.operand1Writeback_i(RegOutOperand1Writeback), .operand2Writeback_i(RegOutOperand2Writeback), .operand3Writeback_i(RegOutOperand3Writeback),
		.instructionAddress_i(RegOutInstructionAddress),
		.opCode_i(RegOutOpCode), .xOpCode_i(RegOutXOpCode),
		.xOpCodeEnabled_i(RegOutXOpCodeEnabled), instructionFormat_i(RegOutInstructionFormat)
		
	);


	//stall unit
	StallUnit stallUnit(
		//stall inputs
		.l1iCacheMissStall_i(isCacheMiss),
		.regFileStall_i(),//TODO: Implement a reg unit stall line
		//stall outputs
		.fetchFullStall_o(stallFullUnit),
		.fetchTagQueryStall_o(stallTagQuery)
	);
	
	//TODO implement exception unit

endmodule
