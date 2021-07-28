`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
module LoadStoreUnit#(
parameter memoryBlockSize = 128, parameter numMemoryBlocks = 128,
parameter loadByte = 1, parameter loadHalfWord = 2, parameter loadWord = 3, parameter loadDoubleword = 4, parameter loadQuadWord = 5,
parameter storeByte = 1, parameter storeHalfWord = 2, parameter storeWord = 3, parameter storeDoubleWord = 4, parameter storeQuadWord = 5,
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
	input wire [0:2] functionalUnitCode_i,
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
	output reg [0:2] functionalUnitCode_o,
	output reg reg1WritebackEnable_o, reg2WritebackEnable_o,
	output reg [0:5] reg1WritebackAddress_o, reg2WritebackAddress_o,
	output reg [0:63] reg1WritebackVal_o, reg2WritebackVal_o
    );

	//as memory block size is 128 bits and if we have 128 blocks, we have 2KiB of D-memory
	//block = integer component of address / memoryBlockSize
	//offset in block = address % memoryBlockSize
	reg [0:memoryBlockSize - 1] dataMemory [0:numMemoryBlocks - 1];
	
	//load buffer (stage 2) (read memory block satage)
	reg [0:memoryBlockSize - 1] loadBlock; 
	reg isLoad;//this is essentially an enable flag
	reg [0:2] loadFormat;//indicates how many bytes to load eg: loadByte = 1, loadHalfWord = 2, loadWord = 3, loadDoubleword = 4, loadQuadWord = 5
	reg [0:addressSize-1] loadAddress; reg isUpdate;//if isUpdate then reg1addr = loaded data and the load address is writen to reg 2
	reg [0:5] reg1Address, reg2Address;
	reg isloadAlgebraic;
	
	//store buffer (stage 2) (update memory block stage)
	reg [0:memoryBlockSize - 1] storeBlock;
	reg isStore;//essentially a write enable
	reg [0:2] storeFormat;
	reg [0:addressSize-1] storeAddress;
	reg [0:addressSize-1] storeVal;
	
	//store buffer (stage 3) (commit stage)
	reg [0:memoryBlockSize - 1] commitBlock;
	reg isCommit;//essentiall a commit enable
	reg [0:addressSize-1] commitAddress;
	
	
	//first always block = first stage
	always @(posedge clock_i)
	begin
		functionalUnitCode_o <= LdStUnitCode;//as this output will never change so we set it here to allow the compiler to optimise it into hard logic
		if(reset_i == 1)
		begin
			loadBlock <= 0;
		end
		else if(reset_i == 0 && enable_i == 1 && functionalUnitCode_i == LdStUnitCode)
		begin
			if(instructionFormat_i == D)
			begin
				case(opCode_i)
					34: begin //Load Byte and Zero
						loadFormat <= loadByte;
						isLoad <= 1; isStore <= 0;//enable load, dissable store
						loadAddress <= operand2_i + imm_i;//calculate the address
						loadBlock <= dataMemory[(operand2_i + imm_i)/(memoryBlockSize/8)];//fetch the block from memory into this buffer
						isUpdate <= 0;
						reg1Address <= reg1Address_i; reg2Address <= reg2Address_i;
						isloadAlgebraic <= 0;
					end
					35: begin//Load Byte and Zero with Update
						loadFormat <= loadByte;
						isLoad <= 1; isStore <= 0;//enable load, dissable store
						loadAddress <= operand2_i + imm_i;//calculate the address
						loadBlock <= dataMemory[(operand2_i + imm_i)/(memoryBlockSize/8)];//fetch the block from memory into this buffer
						isUpdate <= 1;
						reg1Address <= reg1Address_i; reg2Address <= reg2Address_i;
						isloadAlgebraic <= 0;
					end
					40: begin //Load Halfword and Zero
						loadFormat <= loadHalfWord;
						isLoad <= 1; isStore <= 0;//enable load, dissable store
						loadAddress <= operand2_i + imm_i;//calculate the address
						loadBlock <= dataMemory[(operand2_i + imm_i)/(memoryBlockSize/8)];//fetch the block from memory into this buffer
						isUpdate <= 0;
						reg1Address <= reg1Address_i; reg2Address <= reg2Address_i;
						isloadAlgebraic <= 0;
					end
					41: begin //Load Halfword and Zero with Update
						loadFormat <= loadHalfWord;
						isLoad <= 1; isStore <= 0;//enable load, dissable store
						loadAddress <= operand2_i + imm_i;//calculate the address
						loadBlock <= dataMemory[(operand2_i + imm_i)/(memoryBlockSize/8)];//fetch the block from memory into this buffer
						isUpdate <= 1;
						reg1Address <= reg1Address_i; reg2Address <= reg2Address_i;
						isloadAlgebraic <= 0;
					end
					42: begin //Load Halfword Algebraic
						loadFormat <= loadHalfWord;
						isLoad <= 1; isStore <= 0;//enable load, dissable store
						loadAddress <= operand2_i + imm_i;//calculate the address
						loadBlock <= dataMemory[(operand2_i + imm_i)/(memoryBlockSize/8)];//fetch the block from memory into this buffer
						isUpdate <= 0;
						reg1Address <= reg1Address_i; reg2Address <= reg2Address_i;
						isloadAlgebraic <= 1;
					end
					43: begin //Load Halfword Algebraic with Update
						loadFormat <= loadHalfWord;
						isLoad <= 1; isStore <= 0;//enable load, dissable store
						loadAddress <= operand2_i + imm_i;//calculate the address
						loadBlock <= dataMemory[(operand2_i + imm_i)/(memoryBlockSize/8)];//fetch the block from memory into this buffer
						isUpdate <= 1;
						reg1Address <= reg1Address_i; reg2Address <= reg2Address_i;
						isloadAlgebraic <= 1;
					end
					32: begin //Load Word and Zero
						loadFormat <= loadWord;
						isLoad <= 1; isStore <= 0;//enable load, dissable store
						loadAddress <= operand2_i + imm_i;//calculate the address
						loadBlock <= dataMemory[(operand2_i + imm_i)/(memoryBlockSize/8)];//fetch the block from memory into this buffer
						isUpdate <= 0;
						reg1Address <= reg1Address_i; reg2Address <= reg2Address_i;
						isloadAlgebraic <= 0;
					end
					33: begin //Load Word and Zero with Update
						loadFormat <= loadWord;
						isLoad <= 1; isStore <= 0;//enable load, dissable store
						loadAddress <= operand2_i + imm_i;//calculate the address
						loadBlock <= dataMemory[(operand2_i + imm_i)/(memoryBlockSize/8)];//fetch the block from memory into this buffer
						isUpdate <= 1;
						reg1Address <= reg1Address_i; reg2Address <= reg2Address_i;
						isloadAlgebraic <= 0;
					end
					38: begin //Store Byte	
						storeBlock <= dataMemory[(operand2_i + imm_i)/(memoryBlockSize/8)];//This block is updated with the new byte and then writen to memory as a whole
						isLoad <= 0; isStore <= 1;//dissable load, enable store
						storeAddress <= operand2_i + imm_i;//calculate the address
						storeVal <= operand1_i;
						isUpdate <= 0;
						storeFormat <= storeByte;
					end
					39: begin //Store Byte with Update
						storeBlock <= dataMemory[(operand2_i + imm_i)/(memoryBlockSize/8)];//This block is updated with the new byte and then writen to memory as a whole
						isLoad <= 0; isStore <= 1;//dissable load, enable store
						storeAddress <= operand2_i + imm_i;//calculate the address
						storeVal <= operand1_i;
						isUpdate <= 1;
						storeFormat <= storeByte;
					end
					44: begin //Store Halfword
						storeBlock <= dataMemory[(operand2_i + imm_i)/(memoryBlockSize/8)];//This block is updated with the new byte and then writen to memory as a whole
						isLoad <= 0; isStore <= 1;//dissable load, enable store
						storeAddress <= operand2_i + imm_i;//calculate the address
						storeVal <= operand1_i;
						isUpdate <= 0;
						storeFormat <= storeHalfWord;
					end
					45: begin //Store Halfword with Update
						storeBlock <= dataMemory[(operand2_i + imm_i)/(memoryBlockSize/8)];//This block is updated with the new byte and then writen to memory as a whole
						isLoad <= 0; isStore <= 1;//dissable load, enable store
						storeAddress <= operand2_i + imm_i;//calculate the address
						storeVal <= operand1_i;
						isUpdate <= 1;
						storeFormat <= storeHalfWord;
					end
					36: begin //Store Word
						storeBlock <= dataMemory[(operand2_i + imm_i)/(memoryBlockSize/8)];//This block is updated with the new byte and then writen to memory as a whole
						isLoad <= 0; isStore <= 1;//dissable load, enable store
						storeAddress <= operand2_i + imm_i;//calculate the address
						storeVal <= operand1_i;
						isUpdate <= 0;
						storeFormat <= storeWord;
					end
					37: begin //Store Word with Update
						storeBlock <= dataMemory[(operand2_i + imm_i)/(memoryBlockSize/8)];//This block is updated with the new byte and then writen to memory as a whole
						isLoad <= 0; isStore <= 1;//dissable load, enable store
						storeAddress <= operand2_i + imm_i;//calculate the address
						storeVal <= operand1_i;
						isUpdate <= 1;
						storeFormat <= storeWord;
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
		else
		begin
		end
	end
	
	//this always is the second stage used for loads
	always @(posedge clock_i)
	begin
		if(isLoad == 1)//if we fetched a block last cycle
		begin
			case(loadFormat)
				//load 8 bits
				loadByte: begin 
					//set the first reg
					reg1WritebackEnable_o <= 1;
					reg1WritebackAddress_o <= reg1Address;
					reg1WritebackVal_o <= loadBlock[((loadAddress % 16) * 8)+:8];//load the byte into the writeback output
					if(isloadAlgebraic == 0)
					begin
						reg1WritebackVal_o[0:55] <= 56'h0;//zero extend
					end
					else
					begin
						reg1WritebackVal_o[0:55] <= loadBlock[loadAddress % (memoryBlockSize/8)] ? 56'hFFFFFFFFFFFFFF : 56'h0;//sign extend						
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
					reg1WritebackVal_o[63-:16] <= loadBlock[(loadAddress % (memoryBlockSize/8)*8)+:16];//load the byte into the writeback output
					if(isloadAlgebraic == 0)
					begin
						reg1WritebackVal_o[0:47] <= 48'h0;//zero extend
					end
					else
					begin
						reg1WritebackVal_o[0:47] <= loadBlock[loadAddress % (memoryBlockSize/8)] ? 48'hFFFFFFFFFFFF : 48'h0;//sign extend						
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
					reg1WritebackVal_o[63-:32] <= loadBlock[(loadAddress % (memoryBlockSize/8)*8)+:32];//load the byte into the writeback output
					if(isloadAlgebraic == 0)
					begin
						reg1WritebackVal_o[0:31] <= 32'h0;//zero extend
					end
					else
					begin
						reg1WritebackVal_o[0:31] <= loadBlock[loadAddress % (memoryBlockSize/8)] ? 32'hFFFFFFFF : 32'h0;//sign extend						
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
					reg1WritebackVal_o <= loadBlock[(loadAddress % (memoryBlockSize/8)*8)+:64];//load the byte into the writeback output
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
					reg1WritebackVal_o <= loadBlock[loadAddress+:64];//load the byte into the writeback output
					reg2WritebackVal_o <= loadBlock[(loadAddress+64)+:64];//load the byte into the writeback output				
					//NOTE: update is not supported with load quads. microcode must be implemented where this instruction 
					//completes as a loadDoubleWord followed by a loadDoubleWord with update					
				end
				
				default: begin
					reg1WritebackEnable_o <= 0;
					reg2WritebackEnable_o <= 0;
				end//throw error
			endcase		
		end
		else//if we didn't fetch a block last cycle
		begin
			reg1WritebackEnable_o <= 0; reg2WritebackEnable_o <= 0;
		end		
	end
	
	
	
	//this is the second stage used for stores, it is responsible for updating the storeBlock with the new data but does not commit the block back to memory
	always @(posedge clock_i)
	begin
		if(reset_i)
		begin
			isCommit <= 0;
		end
		else if(isStore == 1)
		begin
			commitAddress <= storeAddress;
			case(storeFormat)
				storeByte: 
				begin 
					commitBlock <= storeBlock; 
					commitBlock[(loadAddress % (memoryBlockSize/8)*8)+:8] <= storeVal[63-:8];
					isCommit <= 1;
				end//store 8b
				storeHalfWord: 
				begin 
					commitBlock <= storeBlock; 
					commitBlock[(loadAddress % (memoryBlockSize/8)*8)+:16] <= storeVal[63-:16];
					isCommit <= 1;
				end//store 16b
				storeWord: 
				begin
					commitBlock <= storeBlock; 
					commitBlock[(loadAddress % (memoryBlockSize/8)*8)+:32] <= storeVal[63-:32];
					isCommit <= 1;
				end//store 32b
				storeDoubleWord: 
				begin 
					commitBlock <= storeBlock; 
					commitBlock[(loadAddress % (memoryBlockSize/8)*8)+:64] <= storeVal[63-:64];
					isCommit <= 1;
				end//store 64b
				storeQuadWord:
				begin 
					isCommit <= 0; //TODO: Implement store quad words
				end
				default: 
				begin
					isCommit <= 0;//TODO: Throw error
				end
			endcase
		end
		else
		begin
			isCommit <= 0;
		end		
	end
	
	integer blockIdx = 0; 
	//stage 3 for stores, this is the commit stage.
	always @(posedge clock_i)
	begin
		//reset the data memory
		if(reset_i == 1)
		begin
			for(blockIdx = 0; blockIdx < 128; blockIdx = blockIdx + 1)
			begin
				dataMemory[blockIdx] <= 0;
			end
		end
		//commit's the block to memory
		else if(isCommit == 1)
		begin
			dataMemory[(commitAddress / memoryBlockSize)] <= commitBlock;
		end
	end

endmodule
