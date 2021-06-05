`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//16b address bus takes the index (8b) and bottom of the tag (8bs) and returns a 256b block. This gives us a 16MiB memory range from a 16b bus
//as the 65k addresses are actually block addresses and not byte addresses
//Memory operations are a two step process, first the commands are sent to the memory (address, isWrite, memoryMakeRequest is strobed)
//After that the transactions will begin. Each transaction is a 32 bit (databusWidth) read or write and will take 8 transactions for the operation to complete
//////////////////////////////////////////////////////////////////////////////////
module MemoryController #(parameter offsetSize = 5, parameter indexSize = 8, parameter tagSize = 64 - (offsetSize + indexSize),
parameter databusWidth = 32, parameter iMemoryAddressSize = 16, 
	parameter addressBits = 59, parameter addressSize = 64, parameter blockSize = 256)(
	//command
	input clock_i,
	input reset_i,
	//from core - memory request
	input wire [0:addressSize-1] address_i,//address to read or write from
	input wire [0:blockSize-1] data_i,//data bus from CPU to go to memory, does nothing if reading
	input wire requestEnable_i,//enable signal from CPU telling
	input wire isMemWrite_i,//CPU telling the MCU that the operation is a write operation, if its not write then its read
	//to core - block write to core
	output reg [0:blockSize-1] block_o,//block to go to the CPU/cache
	output reg [0:addressSize-1] blockAddress_o,//address to go back to the CPU/cache
	output reg blockOutEnable_o,//enable signal indicating that the block out is ready
	output reg isMemoryEngaged_o,//tells the CPU the memory is currently transacting data	
	//from mem - word write from memory
	input wire memEnable_i,//enable signal coming in from the memory
	input wire memoryClock_i,//clock coming in from the memory
	input wire [0:databusWidth-1] memoryDataBus_i,//data bus from the memory
	//to memory - read and write requests
	output wire [0:databusWidth-1] memoryDataBus_o,//data bus to the memory
	//command pins:
	output reg [0:iMemoryAddressSize-1] address_o,//the address to read or write
	output reg isWrite_o,//tells the memory if were doing a read or write request
	output reg memoryMakeRequest_o//strobe on the command transfer so the memory knows the data on the commands pins is a request. Stays low during data transfer
);
	//MCU state:
	reg isWrite;//tells the MCU if the block is a read or write operation
	//reg isBlockValid;//if set then the blockIndex is pointing to an index in the memoryBlockBuffer, else not
	reg [0:3] blockIndex;//the index into the transfer block that the MCU is currently at	
	reg isMemoryEngaged;//If the memory is engaged we cant make new memory requests	
	reg [0:addressSize-1] operatingAddress;//stores the address that is being operated on
	reg [0:blockSize-1] memoryBlockWriteBuffer;//buffer that stores the data going to or coming from memory
	reg [0:blockSize-1] memoryBlockReadBuffer;//buffer that stores the data going to or coming from memory
	reg [0:databusWidth-1] dataBusWriteRegister;//holds the word going onto the data bus
	wire [0:databusWidth-1] dataBusReadRegister;//holds the word coming off the databus

	 
	MemoryReadQueue memoryReadQueue (//memory to CPU
		//memory side
		.wr_clk(memoryClock_i),//memory clock		
		.rst(reset_i),
		.wr_en(memEnable_i),//memory write enable to the FIFO
		.din(memoryDataBus_i),//memory databus into the FIFO
		.full(), // output full
		.empty(), // output empty
		//MCUs side
		.rd_clk(clock_i),
		.rd_en(isMemoryEngaged && (~isWrite)),
		.dout(dataBusReadRegister)
	);
	
	MemoryWriteQueue memoryWriteQueue (//CPU to memory
		//MCU side
		.wr_clk(clock_i),
		.rst(reset_i),		
		.wr_en(isWrite),
		.din(dataBusWriteRegister),
		.full(), // output full
		.empty(), // output empty
		//memory side
		.rd_clk(memoryClock_i),
		.rd_en(memEnable_i),
		.dout(memoryDataBus_o)		
	);
	
	always @(posedge clock_i)
	begin
		//stage 1
		if(requestEnable_i == 1)
		begin
			$display("Memory operation requested from CPU");
			$display("Memory block requested: %b, isWrite: %b", address_i[(addressSize-offsetSize)-:iMemoryAddressSize], isMemWrite_i);
			///tell the memory of the request:
			//Memory operations:			
			address_o <= (address_i[(addressSize-offsetSize)-:iMemoryAddressSize]);//16b address bus takes the index (8b) and bottom of the tag (8bs) and returns a 256b block. This gives us a 16MiB memory range
			isWrite_o <= isMemWrite_i;//tell memory if were doing a read or write
			memoryMakeRequest_o <= 1;//tell the memory were doing a request
			//MCU state operations:
			isWrite <= isMemWrite_i;//update our state on if were reading or writing
			//isBlockValid <= 1;//update our state indicating were working on a valid block	
			blockIndex <= 0;//start operating from the begining of the block
			isMemoryEngaged <= 1;//update our state saying the memory is engaged
			isMemoryEngaged_o <= 1;//update the CPU state saying the memory is engaged
			operatingAddress <= address_i;//update our address buffer so we know what address to write back to (only really needed if this is a read)
			memoryBlockWriteBuffer <= data_i;//because we could be writing to memory, we'll put the data to write in the buffer
		end
		else
		begin
			memoryMakeRequest_o <= 0;
		end
		
		//stage 2
		if(isMemoryEngaged == 1)//were doing a memory operation)
		begin
			$display("Memory is engaged");
			$display("Working on block index: %d", blockIndex);
			blockIndex <= blockIndex + 1;//increment the block index so next time the block index will point to the next word
			if(isWrite == 1)//if were writing
			begin//write to the queue
				$display("Writing %h to memory at address %h", memoryBlockWriteBuffer[(0 * databusWidth)+:databusWidth], operatingAddress[(addressSize-offsetSize)-:iMemoryAddressSize]);
				case(blockIndex)//put the word from the fetch buffer indicated by the blockIndex into the dataBusRegister (input of the write queue)
					0:dataBusWriteRegister <= memoryBlockWriteBuffer[(0 * databusWidth)+:databusWidth];
					1:dataBusWriteRegister <= memoryBlockWriteBuffer[(1 * databusWidth)+:databusWidth];
					2:dataBusWriteRegister <= memoryBlockWriteBuffer[(2 * databusWidth)+:databusWidth];
					3:dataBusWriteRegister <= memoryBlockWriteBuffer[(3 * databusWidth)+:databusWidth];
					4:dataBusWriteRegister <= memoryBlockWriteBuffer[(4 * databusWidth)+:databusWidth];
					5:dataBusWriteRegister <= memoryBlockWriteBuffer[(5 * databusWidth)+:databusWidth];
					6:dataBusWriteRegister <= memoryBlockWriteBuffer[(6 * databusWidth)+:databusWidth];
					7:dataBusWriteRegister <= memoryBlockWriteBuffer[(7 * databusWidth)+:databusWidth];
				endcase
			end
			else//were reading
			begin//read from queue
				$display("Reading %h from memory at address %h", dataBusReadRegister, operatingAddress[(addressSize-offsetSize)-:iMemoryAddressSize]);
				case(blockIndex)//put the word in the dataBusRegister indicated by the blockIndex into the fetch buffer (input of the read queue)
					0:memoryBlockReadBuffer[(0 * databusWidth)+:databusWidth] <= dataBusReadRegister;
					1:memoryBlockReadBuffer[(1 * databusWidth)+:databusWidth] <= dataBusReadRegister;
					2:memoryBlockReadBuffer[(2 * databusWidth)+:databusWidth] <= dataBusReadRegister;
					3:memoryBlockReadBuffer[(3 * databusWidth)+:databusWidth] <= dataBusReadRegister;
					4:memoryBlockReadBuffer[(4 * databusWidth)+:databusWidth] <= dataBusReadRegister;
					5:memoryBlockReadBuffer[(5 * databusWidth)+:databusWidth] <= dataBusReadRegister;
					6:memoryBlockReadBuffer[(6 * databusWidth)+:databusWidth] <= dataBusReadRegister;
					7:memoryBlockReadBuffer[(7 * databusWidth)+:databusWidth] <= dataBusReadRegister;
				endcase
				$display("Reading at block index %d", blockIndex);
			end
			
			if((blockIndex == 4'b1000))//were at the end of the block, lets finnish up
			begin
				$display("Memory operation complete");
				//isBlockValid <= 0;//unset block valid
				isMemoryEngaged <= 0;
				blockOutEnable_o <= 1;
				block_o <= memoryBlockReadBuffer;
				blockIndex <= 0;
				blockAddress_o <= operatingAddress;
			end
		end
	end

	
endmodule
