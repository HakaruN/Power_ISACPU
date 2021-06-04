`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

module MemoryController_Test;

	// Inputs
	reg CPUClock;
	reg MEMClock;
	reg reset;
	reg [0:63] address;
	reg [0:255] data;
	reg requestEnable;
	reg isMemWrite;
	reg memEnable;
	reg [0:31] memoryDataBus;


	// Outputs
	wire [0:255] block_o;
	wire [0:63] blockAddress_o;
	wire blockOutEnable_o;
	wire isMemoryEngaged_o;
	wire [0:15] address_o;
	wire [0:31] memoryDataBus_o;
	wire isWrite_o;
	wire memoryMakeRequest_o;

	// Instantiate the Unit Under Test (UUT)
	MemoryController uut (
		//command
		.clock_i(CPUClock), 
		.reset_i(reset), 
		//from core - memory request
		.address_i(address), 
		.data_i(data),
		.requestEnable_i(requestEnable), 
		.isMemWrite_i(isMemWrite),		
		//to core - block write to core
		.block_o(block_o), 
		.blockAddress_o(blockAddress_o), 
		.blockOutEnable_o(blockOutEnable_o), 
		.isMemoryEngaged_o(isMemoryEngaged_o), 
		//from mem - word write from memory
		.memEnable_i(memEnable), 
		.memoryClock_i(MEMClock), 
		.memoryDataBus_i(memoryDataBus), 
		//to memory - read and write requests
		.memoryDataBus_o(memoryDataBus_o),
		//command pins:
		.address_o(address_o), 
		.isWrite_o(isWrite_o), 
		.memoryMakeRequest_o(memoryMakeRequest_o)
	);
	
	
	//make a memory
	reg [0:255] memory [0:255];//256k blocks of 256b
	integer i;
	initial begin
		// Initialize Inputs
		CPUClock = 0;
		MEMClock = 0;
		reset = 0;
		address = 0;
		requestEnable = 0;
		memEnable = 0;
		memoryDataBus = 0;
		data = 0;
		isMemWrite = 0;
		

		//init the memory
		for(i = 0; i < 1000; i = i + 1)
			memory[i] = 256'hFFFFFFFF_EEEEEEEE_DDDDDDDD_CCCCCCCC_BBBBBBBB_AAAAAAAA_99999999_88888888;
			
		//reset
		reset = 1;
		CPUClock = 1;
		#1;
		reset = 0;
		CPUClock = 0;
		#1;
		
		//make a read request for some data
		address = 64'b_00000011_00001;
		requestEnable = 1;
		
		CPUClock = 1;
		#1;
		CPUClock = 0;
		#1;
	end
	
	/*
	output reg [0:iMemoryAddressSize-1] address_o,
	output reg [0:databusWidth-1] data_o,
	output reg isWrite_o,
	output reg memoryMakeRequest_o
	*/
	
	//be the memory
	reg [0:15] blockAddress;
	reg isWriteRequest;
	reg [0:31] dataBusData;
	reg [0:2] cyclesLeft;
	reg isProcessingRequest;
	always @(posedge MEMClock)
	begin		
		if(memoryMakeRequest_o == 1)//take a request
		begin//memory request
			blockAddress <= address_o;//take the address from the bus
			isWriteRequest <= isWrite_o;//take the iswrite bit from the bus
			dataBusData <= memoryDataBus_o;//take the data from the bus
			cyclesLeft <= 3'b0;//set the num cycles left to 0 (8 cycles in toats,0:7, counts up to 7)
			isProcessingRequest <= 1;//set the processing flag
		end	
		
		if(isProcessingRequest == 1)//process the request
		begin
			memEnable <= 1;
			cyclesLeft <= cyclesLeft + 1;
			if(isWriteRequest == 1)//if writing to memory
			begin
				memory[blockAddress] <= memoryDataBus_o;
			end
			else//else reading from memory
			begin
				memoryDataBus <= memory[blockAddress];
			end
			
			if(cyclesLeft == 3'b111)//if were on the last cycle
			begin
				cyclesLeft <= 0;
				isProcessingRequest <= 0;
				isMemWrite <= 0;
				memEnable <= 0;
			end
		end
		
		/*
			input wire memEnable_i,
	input wire memoryClock_i,
	input wire [0:databusWidth-1] memoryDataBus_i,
		*/
		
	end
      
endmodule

