`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
module PowerISACore#(parameter i_DatabusWidth = 32, parameter addressSize = 64, parameter iMemoryAddressSize = 16, parameter instructionSize = 32,
parameter regImm = 0, parameter immWith = 24, parameter DImmWith = 16,
parameter iCacheOffsetSize = 5, iCacheIndexSize = 8, iCacheTagSize = addressSize - (iCacheOffsetSize + iCacheIndexSize), parameter blockSize = 256,	
parameter formatIndexRange = 5, parameter opcodeWidth = 6, parameter xOpCodeWidth = 10, parameter regWidth = 5, parameter immWidth = 16,
parameter FXUnitCode = 0, parameter FPUnitCode = 1, parameter LdStUnitCode = 2, parameter BranchUnitCode = 3, parameter TrapUnitCode = 4//functional unit code/ID used for dispatch
	)(
	//command
	input wire clock_i,
	input wire reset_i,
	//reg reads - these are there to stop the compiler optimising all of the hardware away
	input wire [0:4] regReadAddress_i,
	input wire regReadEnable_i,
	output wire [0:addressSize-1] regReadOutput_o,
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
	wire [0:addressSize-1] PC;//fetch Address
	
	
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
		.stallTagQuery_i(stallTagQuery),
		.stallFullUnit_i(stallFullUnit),
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
	//immediates
	wire [0:immWith-1] decodeImm;
	wire decodeImmEnable;
	//regs
	wire [0:regWidth-1] decodeReg1, decodeReg2, decodeReg3;
	wire [0:1] reg1Use, reg2Use, reg3Use;
	wire decodeReg1Enable, decodeReg2Enable, decodeReg3Enable;
	wire decodeReg3IsImmediate;
	//bits
	wire decodeBit1, decodeBit2;
	//instruction info
	wire decodeReg2ValOrZero;
	wire [0:addressSize-1] decodeInstructionAddress;
	wire [0:opcodeWidth-1] decodeOpCode;
	wire [0:xOpCodeWidth-1] decodeXOpcode;
	wire decodeXOpcodeEnable;
	wire [0:2] decodeFunctionalUnitCode;
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
	.reg2ValOrZero_o(decodeReg2ValOrZero),
	.instructionAddress_o(decodeInstructionAddress),
	.opCode_o(decodeOpCode),
	.xOpcode_o(decodeXOpcode),
	.xOpcodeEnable_o(decodeXOpcodeEnable),
	.functionalUnitCode_o(decodeFunctionalUnitCode),
	.instructionFormat_o(decodeInstructionFormat)
	);


	//reg read output - exec unit input
	wire RegOutEnable;
	wire [0:63] RegOutOperand1, RegOutOperand2, RegOutOperand3;
	wire [0:regWidth-1] RegOutReg1Address, RegOutReg2Address, RegOutReg3Address;
	wire [0:immWith-1] RegOutImm;
	wire RegOutBit1, RegOutBit2;
	wire RegOutOperand1Writeback, RegOutOperand2Writeback, RegOutOperand3Writeback;
	wire [0:63] RegOutInstructionAddress;
	wire [0:opcodeWidth-1] RegOutOpCode;
	wire [0:xOpCodeWidth-1] RegOutXOpCode;
	wire [0:2] RegOutFunctionalUnitCode;
	wire [0:formatIndexRange-1] RegOutInstructionFormat;
	wire RegOutis64Bit;
	wire [32:63] RegOutConditionReg;

	//functional unit outputs (reg writeback)
	wire ExecLoadStoreStallOut;
	wire ExecBranchStallOut;
	wire [0:2] ExecFunctionalUnitCodeOut;
	wire ExecReg1WritebackEnable, ExecReg2WritebackEnable;
	wire [0:regWidth-1] ExecReg1WritebackAddress, ExecReg2WritebackAddress;
	wire [0:63] ExecReg1WritebackVal, ExecReg2WritebackVal;
	wire ExecCondRegUpdateEnable;
	wire [32:63] ExecNewCRVal;
	
	
	//regfile stall
	wire regFileStallOut;
	
	//Register unit
	RegisterUnit registerUnit (
	.clock_i(clock_i), 
	.reset_i(reset_i), 
	//reg read in
	.enable_i(decodeEnable), 
		//immediate
	.imm_i(decodeImm), 
	.immEnable_i(decodeImmEnable), 
	.reg1_i(decodeReg1), .reg2_i(decodeReg2), .reg3_i(decodeReg3), 
		//bits
	.bit1_i(decodeBit1), .bit2_i(decodeBit2), 
		//regs
	.reg1Use_i(reg1Use), .reg2Use_i(reg2Use), .reg3Use_i(reg3Use), 
	.reg3IsImmediate_i(decodeReg3IsImmediate), 
	.reg2ValOrZero_i(decodeReg2ValOrZero), 
	.reg1Enable_i(decodeReg1Enable), .reg2Enable_i(decodeReg2Enable), .reg3Enable_i(decodeReg3Enable), 
	//instruction info
	.instructionAddress_i(decodeInstructionAddress), 
	.opCode_i(decodeOpCode), 
	.xOpcode_i(decodeXOpcode), 
	.xOpCodeEnabled_i(decodeXOpcodeEnable),
	.functionalUnitCode_i(decodeFunctionalUnitCode),
	.instructionFormat_i(decodeInstructionFormat), 
	.regReadAddress_i(regReadAddress_i),
	.regReadEnable_i(regReadEnable_i),
	.regReadOutput_o(regReadOutput_o),
	 //reg write in	
	 //.regWritebackFunctionalUnitCode_i(ExecFunctionalUnitCodeOut),
    .fxReg1WritebackData_i(ExecReg1WritebackVal), .fxReg2WritebackData_i(ExecReg2WritebackVal), 
    .fxReg1isWriteback_i(ExecReg1WritebackEnable), .fxReg2isWriteback_i(ExecReg2WritebackEnable), 
	 .fxReg1WritebackAddress_i(ExecReg1WritebackAddress), .fxReg2WritebackAddress_i(ExecReg2WritebackAddress),	 
	//condition reg update
	.condRegUpdateEnable_i(ExecCondRegUpdateEnable),
	.newCRVal_i(ExecNewCRVal),
	 //command out
    .stall_o(regFileStallOut), 
	 //reg read out
	 .enable_o(RegOutEnable),
	 .is64Bit_o(RegOutis64Bit),
    .operand1_o(RegOutOperand1), .operand2_o(RegOutOperand2), .operand3_o(RegOutOperand3), 
	 .reg1Address_o(RegOutReg1Address), .reg2Address_o(RegOutReg2Address), .reg3Address_o(RegOutReg3Address),
	 .imm_o(RegOutImm),
    .bit1_o(RegOutBit1), .bit2_o(RegOutBit2), 
    .instructionAddress_o(RegOutInstructionAddress),
    .opCode_o(RegOutOpCode),
    .xOpCode_o(RegOutXOpCode),
	 .functionalUnitCode_o(RegOutFunctionalUnitCode),
    .instructionFormat_o(RegOutInstructionFormat),
	 .conditionRegisterOutput_o(RegOutConditionReg)
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
		.imm_i(RegOutImm),
		.bit1_i(RegOutBit1), .bit2_i(RegOutBit2),
		.operand1Writeback_i(RegOutOperand1Writeback), .operand2Writeback_i(RegOutOperand2Writeback), .operand3Writeback_i(RegOutOperand3Writeback),
		.instructionAddress_i(RegOutInstructionAddress),
		.opCode_i(RegOutOpCode), .xOpCode_i(RegOutXOpCode),
		.instructionFormat_i(RegOutInstructionFormat),
		.condReg_i(RegOutConditionReg),
		//command out
		.loadStoreStall(ExecLoadStoreStallOut), .branchStall(ExecBranchStallOut),
		.isBranching_o(), .pc_o(PC),
		//reg writeback
		.functionalUnitCode_o(ExecFunctionalUnitCodeOut),
		.reg1WritebackEnable_o(ExecReg1WritebackEnable), .reg2WritebackEnable_o(ExecReg2WritebackEnable),
		.reg1WritebackAddress_o(ExecReg1WritebackAddress), .reg2WritebackAddress_o(ExecReg2WritebackAddress),
		.reg1WritebackVal_o(ExecReg1WritebackVal), .reg2WritebackVal_o(ExecReg2WritebackVal),
		.condRegUpdateEnable_o(ExecCondRegUpdateEnable),
		.newCRVal_o(ExecNewCRVal)
	);
	

	//stall unit
	StallUnit stallUnit(
		//control
		.clock_i(clock_i),
		//stall inputs
		.fetchCacheMissStall_i(isCacheMiss),
		.regFileStall_i(),//TODO: Implement a reg unit stall line
		//stall outputs
		.fetchFullStall_o(stallFullUnit),
		.fetchTagQueryStall_o(stallTagQuery)
	);
	
	//TODO implement exception unit
	//TODO implement flush unit

endmodule
