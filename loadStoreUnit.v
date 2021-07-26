`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
module LoadStoreUnit#(
parameter memoryBlockSize = 128, parameter numMemoryBlocks = 128,
parameter loadByte = 1, parameter loadHalfWord = 2, parameter loadWord = 3, parameter loadDoubleword = 4, parameter loadQuadWord = 5,
parameter storeByte = 1, parameter storeHalfWords = 2, parameter storeWords = 3, parameter storeDoubleWords = 4, parameter storeQuadWord = 5,
parameter addressSize = 64, parameter opcodeWidth = 6, parameter xOpCodeWidth = 10, parameter immWith = 16, parameter regWidth = 5, parameter numRegs = 2**regWidth, parameter formatIndexRange = 5,
parameter A = 1, parameter B = 2, parameter D = 3, parameter DQ = 4, parameter DS = 5, parameter DX = 6, parameter I = 7, parameter M = 8,
parameter MD = 9, parameter MDS = 10, parameter SC = 11, parameter VA = 12, parameter VC = 13, parameter VX = 14, parameter X = 15, parameter XFL = 16,
parameter XFX = 17, parameter XL = 18, parameter XO = 19, parameter XS = 20, parameter XX2 = 21, parameter XX3 = 22, parameter XX4 = 23, parameter Z22 = 24,
parameter Z23 = 25, parameter INVALID = 0,
parameter FXUnitCode = 0, parameter FPUnitCode = 1, parameter LdStUnitCode = 2, parameter BranchUnitCode = 3, parameter TrapUnitCode = 4//functional unit code/ID used for dispatch
)(
	//command
	input wire clock_i,
	input wire reset_i,
	input wire enable_i,
	//data in
	input wire [0:1] functionalUnitCode_i,
	input wire [0:63] instructionAddress_i,
	input wire [0:opcodeWidth-1] opCode_i,
	input wire [0:xOpCodeWidth-1] xOpCode_i,
	input wire xOpCodeEnabled_i,	
	input wire [0:formatIndexRange-1] instructionFormat_i,
	input wire [0:63] operand1_i, operand2_i, operand3_i,
	input wire [0:regWidth-1] reg1Address_i, reg2Address_i, reg3Address_i,
	input wire [0:immWith-1] imm_i,
	//command out
	output reg stall_o,
	//data out
	output reg outputEnable_o,
	output reg [0:1] functionalUnitCode_o,
	output reg reg1WritebackEnable_o, reg2WritebackEnable_o,
	output reg [0:5] reg1WritebackAddress_o, reg2WritebackAddress_o,
	output reg [0:63] reg1WritebackVal_o, reg2WritebackVal_o
    );

	//as memory block size is 128 bits and if we have 128 blocks, we have 2KiB of D-memory
	//block = integer component of address / memoryBlockSize
	//offset in block = address % memoryBlockSize
	reg [0:memoryBlockSize - 1] dataMemory [0:numMemoryBlocks - 1];
	
	//load buffer
	reg [0:memoryBlockSize - 1] fetchedBlock; reg isLoad;//this is essentially an enable flag
	reg [0:2] loadFormat;//indicates how many bytes to load eg: loadByte = 1, loadHalfWord = 2, loadWord = 3, loadDoubleword = 4, loadQuadWord = 5
	reg [0:addressSize-1] loadAddress; reg isUpdate;//if isUpdate then reg1addr = loaded data and the load address is writen to reg 2
	reg [0:5] reg1Address, reg2Address;
	reg isloadAlgebraic;
	
	//store buffer
	reg isStore;//essentially a write enable
	reg [0:2] storeFormat;
	reg [0:addressSize-1] storesAddress; reg isUpdate;
	reg [0:addressSize-1] storeVal;
	reg isIndexed;//means are we using an immediate or reg (1=reg)
	
	integer i;
	
	//first always block = first stage
	always @(posedge clock_i)
	begin
		functionalUnitCode_o <= LdStUnitCode;//as this output will never change we set it here to allow the compiler to optimise it into hard logic
		else if(reset_i == 0 && enable_i == 1 && functionalUnitCode_i == LdStUnitCode)
		begin
			outputEnable_o <= 1;
			if(instructionFormat_i == D)
			begin
				case(opCode_i)
					34: begin //Load Byte and Zero
						loadFormat <= loadByte;
						isLoad <= 1; isStore <= 0;//enable load, dissable store
						loadAddress <= operand2_i + imm_i;//calculate the address
						fetchedBlock <= dataMemory[(operand2_i + imm_i)/memoryBlockSize];//fetch the block from memory into this buffer
						isUpdate <= 0;
						reg1Address <= reg1Address_i; reg2Address <= reg2Address_i;
						isloadAlgebraic <= 0;
					end
					35: begin//Load Byte and Zero with Update
						loadFormat <= loadByte;
						isLoad <= 1; isStore <= 0;//enable load, dissable store
						loadAddress <= operand2_i + imm_i;//calculate the address
						fetchedBlock <= dataMemory[(operand2_i + imm_i)/memoryBlockSize];//fetch the block from memory into this buffer
						isUpdate <= 1;
						reg1Address <= reg1Address_i; reg2Address <= reg2Address_i;
						isloadAlgebraic <= 0;
					end
					40: begin //Load Halfword and Zero
						loadFormat <= loadHalfWord;
						isLoad <= 1; isStore <= 0;//enable load, dissable store
						loadAddress <= operand2_i + imm_i;//calculate the address
						fetchedBlock <= dataMemory[(operand2_i + imm_i)/memoryBlockSize];//fetch the block from memory into this buffer
						isUpdate <= 0;
						reg1Address <= reg1Address_i; reg2Address <= reg2Address_i;
						isloadAlgebraic <= 0;
					end
					41: begin //Load Halfword and Zero with Update
						loadFormat <= loadHalfWord;
						isLoad <= 1; isStore <= 0;//enable load, dissable store
						loadAddress <= operand2_i + imm_i;//calculate the address
						fetchedBlock <= dataMemory[(operand2_i + imm_i)/memoryBlockSize];//fetch the block from memory into this buffer
						isUpdate <= 1;
						reg1Address <= reg1Address_i; reg2Address <= reg2Address_i;
						isloadAlgebraic <= 0;
					end
					42: begin //Load Halfword Algebraic
						loadFormat <= loadHalfWord;
						isLoad <= 1; isStore <= 0;//enable load, dissable store
						loadAddress <= operand2_i + imm_i;//calculate the address
						fetchedBlock <= dataMemory[(operand2_i + imm_i)/memoryBlockSize];//fetch the block from memory into this buffer
						isUpdate <= 0;
						reg1Address <= reg1Address_i; reg2Address <= reg2Address_i;
						isloadAlgebraic <= 1;
					end
					43: begin //Load Halfword Algebraic with Update
						loadFormat <= loadHalfWord;
						isLoad <= 1; isStore <= 0;//enable load, dissable store
						loadAddress <= operand2_i + imm_i;//calculate the address
						fetchedBlock <= dataMemory[(operand2_i + imm_i)/memoryBlockSize];//fetch the block from memory into this buffer
						isUpdate <= 1;
						reg1Address <= reg1Address_i; reg2Address <= reg2Address_i;
						isloadAlgebraic <= 1;
					end
					32: begin //Load Word and Zero
						loadFormat <= loadWord;
						isLoad <= 1; isStore <= 0;//enable load, dissable store
						loadAddress <= operand2_i + imm_i;//calculate the address
						fetchedBlock <= dataMemory[(operand2_i + imm_i)/memoryBlockSize];//fetch the block from memory into this buffer
						isUpdate <= 0;
						reg1Address <= reg1Address_i; reg2Address <= reg2Address_i;
						isloadAlgebraic <= 0;
					end
					33: begin //Load Word and Zero with Update
						loadFormat <= loadWord;
						isLoad <= 1; isStore <= 0;//enable load, dissable store
						loadAddress <= operand2_i + imm_i;//calculate the address
						fetchedBlock <= dataMemory[(operand2_i + imm_i)/memoryBlockSize];//fetch the block from memory into this buffer
						isUpdate <= 1;
						reg1Address <= reg1Address_i; reg2Address <= reg2Address_i;
						isloadAlgebraic <= 0;
					end
					38: begin //Store Byte	
						fetchedBlock <= dataMemory[(operand2_i + imm_i)/memoryBlockSize];//This block is updated with the new byte and then writen to memory as a whole
						isLoad <= 0; isStore <= 1;//dissable load, enable store
						storeAddress <= operand2_i + imm_i;//calculate the address
						storeVal <= operand1_i;
						isUpdate <= 0;
						storeFormat <= storeByte;
						isIndexed <= 0;
					end
					39: begin //Store Byte with Update
						fetchedBlock <= dataMemory[(operand2_i + imm_i)/memoryBlockSize];//This block is updated with the new byte and then writen to memory as a whole
						isLoad <= 0; isStore <= 1;//dissable load, enable store
						storeAddress <= operand2_i + imm_i;//calculate the address
						storeVal <= operand1_i;
						isUpdate <= 1;
						storeFormat <= storeByte;
						isIndexed <= 0;
					end
					44: begin //Store Halfword
						fetchedBlock <= dataMemory[(operand2_i + imm_i)/memoryBlockSize];//This block is updated with the new byte and then writen to memory as a whole
						isLoad <= 0; isStore <= 1;//dissable load, enable store
						storeAddress <= operand2_i + imm_i;//calculate the address
						storeVal <= operand1_i;
						isUpdate <= 0;
						storeFormat <= storeHalfword;
						isIndexed <= 0;
					end
					45: begin //Store Halfword with Update
						fetchedBlock <= dataMemory[(operand2_i + imm_i)/memoryBlockSize];//This block is updated with the new byte and then writen to memory as a whole
						isLoad <= 0; isStore <= 1;//dissable load, enable store
						storeAddress <= operand2_i + imm_i;//calculate the address
						storeVal <= operand1_i;
						isUpdate <= 1;
						storeFormat <= storeHalfword;
						isIndexed <= 0;
					end
					36: begin //Store Word
						fetchedBlock <= dataMemory[(operand2_i + imm_i)/memoryBlockSize];//This block is updated with the new byte and then writen to memory as a whole
						isLoad <= 0; isStore <= 1;//dissable load, enable store
						storeAddress <= operand2_i + imm_i;//calculate the address
						storeVal <= operand1_i;
						isUpdate <= 0;
						storeFormat <= storeWord;
						isIndexed <= 0;
					end
					37: begin //Store Word with Update
						fetchedBlock <= dataMemory[(operand2_i + imm_i)/memoryBlockSize];//This block is updated with the new byte and then writen to memory as a whole
						isLoad <= 0; isStore <= 1;//dissable load, enable store
						storeAddress <= operand2_i + imm_i;//calculate the address
						storeVal <= operand1_i;
						isUpdate <= 1;
						storeFormat <= storeWord;
						isIndexed <= 0;
					end
					46: begin //Load Multiple Word
						/*Throw not implemented instruction*/
					end
					47: begin //Store Multiple Word
						/*Throw not implemented instruction*/
					end
					default: begin /*Throw invalid instruction*/ end
				endcase
			end
			else if(instructionFormat_i == DS)
			begin
				if(opCode_i == 58)//the loads
				begin
					case(xOpCode_i)
						0: begin end//Load Doubleword
						1: begin end//Load Doubleword with Update
						2: begin end//Load Word Algebraic
						default: begin /*Throw invalid instruction*/ end
					endcase
				end
				else if(opCode_i == 62)//the stores
				begin
					case(xOpCode_i)
						0: begin end//Store Doubleword
						1: begin end//Store Doubleword with Update
						2: begin end//Store Quadword
						default: begin /*Throw invalid instruction*/ end
					endcase
				end
				else
				begin
					//throw a invalid instruction exception
				end
			end
			else if(instructionFormat_i == DQ)
			begin
				if(opCode_i == 56)//load quadword
				begin
					
				end
				else
				begin
					//throw a invalid instruction exception
				end
			end
		end
	end
	
	//this always is the second stage used for loads
	always @(posedge clock_i)
	begin
		if(reset_i == 1)//if we're resetting
		begin
			fetchedBlock <= 0;
			outputEnable_o <= 0;
		end
		else if(isBlockFetched)//if we fetched a block last cycle
		begin
			case(loadFormat)
				//load 8 bits
				loadByte: begin 
					//set the first reg
					reg1WritebackEnable_o <= 1;
					reg1WritebackAddress_o <= reg1Address;
					reg1WritebackVal_o[63-:8] <= fetchedBlock[loadAddress % memoryBlockSize+:8];//load the byte into the writeback output
					if(isloadAlgebraic == 0)
					begin
						reg1WritebackVal_o[0:55] <= 56'h0;//zero extend
					end
					else
					begin
						reg1WritebackVal_o[0:55] <= fetchedBlock[loadAddress % memoryBlockSize] ? 56'hFFFFFFFFFFFFFF : 56'h0;//sign extend						
					end
					reg2WritebackEnable_o <= isUpdate;//set the reg2Enable is isUpdate
					if(isUpdate == 1)//if enable
					begin
						reg2WritebackAddress_o <= reg2Address;//set the writeback address on the second reg writeback port 
						reg2WritebackVal_o <= loadAddress;//if is update, the address we loaded from is writen to reg 2
					end
				end
				//load 16 bits
				loadHalfWord: begin
					reg1WritebackEnable_o <= 1;
					reg1WritebackAddress_o <= reg1Address;
					reg1WritebackVal_o[63-:16] <= fetchedBlock[loadAddress % memoryBlockSize+:16];//load the byte into the writeback output
					if(isloadAlgebraic == 0)
					begin
						reg1WritebackVal_o[0:47] <= 48'h0;//zero extend
					end
					else
					begin
						reg1WritebackVal_o[0:47] <= fetchedBlock[loadAddress % memoryBlockSize] ? 48'hFFFFFFFFFFFF : 48'h0;//sign extend						
					end					
					reg2WritebackEnable_o <= isUpdate;//set the reg2Enable is isUpdate
					if(isUpdate == 1)//if enable
					begin
						reg2WritebackAddress_o <= reg2Address;//set the writeback address on the second reg writeback port 
						reg2WritebackVal_o <= loadAddress;//if is update, the address we loaded from is writen to reg 2
					end
				end 
				//load 32 bits
				loadWord: begin
					reg1WritebackEnable_o <= 1;
					reg1WritebackAddress_o <= reg1Address;					
					reg1WritebackVal_o[63-:32] <= fetchedBlock[loadAddress % memoryBlockSize+:32];//load the byte into the writeback output
					if(isloadAlgebraic == 0)
					begin
						reg1WritebackVal_o[0:31] <= 32'h0;//zero extend
					end
					else
					begin
						reg1WritebackVal_o[0:31] <= fetchedBlock[loadAddress % memoryBlockSize] ? 32'hFFFFFFFF : 32'h0;//sign extend						
					end					
					reg2WritebackEnable_o <= isUpdate;//set the reg2Enable is isUpdate
					if(isUpdate == 1)//if enable
					begin
						reg2WritebackAddress_o <= reg2Address;//set the writeback address on the second reg writeback port 
						reg2WritebackVal_o <= loadAddress;//if is update, the address we loaded from is writen to reg 2
					end
				end
				//load 64 bits
				loadDoubleword: begin
					reg1WritebackEnable_o <= 1;
					reg1WritebackAddress_o <= reg1Address;
					reg1WritebackVal_o <= fetchedBlock[loadAddress % memoryBlockSize+:64];//load the byte into the writeback output
					reg2WritebackEnable_o <= isUpdate;//set the reg2Enable is isUpdate
					if(isUpdate == 1)//if enable
					begin
						reg2WritebackAddress_o <= reg2Address;//set the writeback address on the second reg writeback port 
						reg2WritebackVal_o <= loadAddress;//if is update, the address we loaded from is writen to reg 2
					end
				end
				//load 128 bits	
				loadQuadWord: begin
					reg1WritebackEnable_o <= 1;
					reg2WritebackEnable_o <= 1;
					reg1WritebackAddress_o <= reg1Address;
					reg2WritebackAddress_o <= reg1Address + 1;
					reg1WritebackVal_o <= fetchedBlock[loadAddress+:64];//load the byte into the writeback output
					reg2WritebackVal_o <= fetchedBlock[(loadAddress+64)+:64];//load the byte into the writeback output				
					//NOTE: update is not supported with load quads. microcode must be implemented where this instruction 
					//completes as a loadDoubleWord followed by a loadDoubleWord with update					
				end
				
				default: begin
					reg1WritebackEnable_o <= 0;
					reg2WritebackEnable_o <= 0;
					outputEnable_o <= 0;
				end//throw error
			endcase
			outputEnable_o <= 1;			
		end
		else//if we didn't fetch a block last cycle
		begin
			outputEnable_o <= 0;
		end		
	end
	
		

	reg [0:addressSize-1] storesAddress; reg isUpdate;
	reg [0:addressSize-1] storeVal;
	reg isIndexed;//means are we using an immediate or reg (1=reg)
	
	//this always is the second stage used for loads
	always @(posedge clock_i)
	begin
		if(reset_i)
		begin//reset the data memory
			for(i = 0; i < numMemoryBlocks; i = i + 1)
			begin
				dataMemory[i] <= 0;
			end
		end
		else if(isStore == 1)
		begin
			case(storeFormat)
				fetchedBlock[(storesAddress % memoryBlockSize)+:8] <= storeVal[63-:8];
				storeByte: begin dataMemory[storesAddress+:8] <= storeVal[63-:8]; end//store the lsB to memory
				storeHalfWords: begin end
				storeWords: begin end
				storeDoubleWords: begin end
				storeQuadWord: begin end
				default: begin end
			endcase
		end
		else
		begin
		end		
	end

endmodule
