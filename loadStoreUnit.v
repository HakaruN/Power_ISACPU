`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//NOTE/TODO: For store quadword the decoder needs to implement operand1 for the first doubleword, operand 2 for the regOffset, imm for the immOffset and operand3 for the last doubleword
//////////////////////////////////////////////////////////////////////////////////
module LoadStoreUnit#(
parameter memoryBlockSize = 128, parameter numMemoryBlocks = 128,
parameter Byte = 0, parameter HalfWord = 1, parameter Word = 2, parameter DoubleWord = 3, parameter QuadWord = 4,
parameter addressSize = 64, parameter opcodeWidth = 6, parameter xOpCodeWidth = 10, parameter immWith = 24, parameter regWidth = 5, parameter numRegs = 2**regWidth, parameter formatIndexRange = 5,
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
	//input wire [0:63] instructionAddress_i,
	input wire [0:opcodeWidth-1] opCode_i,
	input wire [0:xOpCodeWidth-1] xOpCode_i,
	input wire [0:formatIndexRange-1] instructionFormat_i,
	input wire [0:63] operand1_i, operand2_i, operand3_i,
	input wire [0:regWidth-1] reg1Address_i, reg2Address_i,// reg3Address_i,
	input wire [0:immWith-1] imm_i,
	//command out
	output reg stall_o,
	//data out
	output reg [0:2] functionalUnitCode_o,
	output reg reg1WritebackEnable_o, reg2WritebackEnable_o,
	output reg [0:regWidth-1] reg1WritebackAddress_o, reg2WritebackAddress_o,
	output reg [0:63] reg1WritebackVal_o, reg2WritebackVal_o
    );
	 
	//stage 1 buffers
	//reg isEngaged;
	reg stage1Enable;
	reg isStore;//if ==1, its a load else it's a store
	reg [0:63] operand1_1, /*operand2_1,*/ operand3_1;
	//reg [0:immWith-1] imm_1;
	reg [0:regWidth-1] reg1Address_1, reg2Address_1;
	reg [0:2] loadStoreFormat1;
	reg isUpdate1, isAlgebraic1;
	reg [0:addressSize-1] address1;//address that have been generated to load from - needed if isUpdate to write the address back to a reg
	reg [0:6] blockAddress1;//the address of the block that were going to be loading from
	reg [0:3] blockIndex1;//the index of a particular byte within the block
	
	//Perform the instruction parse
	always @(posedge clock_i)
	begin
		if(reset_i == 1)
		begin
			//isEngaged <= 0;
			stall_o <= 0;
		end
		else if(enable_i == 1 && functionalUnitCode_i == LdStUnitCode)
		begin
			//isEngaged <= 1;
			stall_o <= 1;
			if(instructionFormat_i == D) begin			
				operand1_1 <= operand1_i; /*operand2_1 <= operand2_i;*/ operand3_1 <= operand3_i;//imm_1 <= imm_i;
				reg1Address_1 <= reg1Address_i; reg2Address_1 <= reg2Address_i;
				address1 <= operand2_i + imm_i; //calculate the address to load/store from/to
				blockAddress1 <= (operand2_i + imm_i) / 16;//the address of the block to load from (may not be needed)
				blockIndex1 <= (operand2_i + imm_i) % 16;//the index in the block to load
			case(opCode_i)//parse D format Load/Stores
				32: begin //Load Word and Zero
					stage1Enable <= 1; isStore <= 0; isUpdate1 <= 0;	isAlgebraic1 <= 0; loadStoreFormat1 <= Word;
				end
				33: begin //Load Word and Zero with Update
					stage1Enable <= 1; isStore <= 0; isUpdate1 <= 1;	isAlgebraic1 <= 0; loadStoreFormat1 <= Word;
				end
				34: begin //Load Byte and Zero
					stage1Enable <= 1; isStore <= 0; isUpdate1 <= 0;	isAlgebraic1 <= 0; loadStoreFormat1 <= Byte;
				end
				35: begin //Load Byte and Zero with Update
					stage1Enable <= 1; isStore <= 0; isUpdate1 <= 1;	isAlgebraic1 <= 0; loadStoreFormat1 <= Byte;
				end
				36: begin //Store Word
					stage1Enable <= 1; isStore <= 1; isUpdate1 <= 0;	isAlgebraic1 <= 0; loadStoreFormat1 <= Word;
				end
				37: begin //Store Word with Update
					stage1Enable <= 1; isStore <= 1; isUpdate1 <= 1;	isAlgebraic1 <= 0; loadStoreFormat1 <= Word;
				end
				38: begin //Store Byte
					stage1Enable <= 1; isStore <= 1; isUpdate1 <= 0;	isAlgebraic1 <= 0; loadStoreFormat1 <= Byte;
				end
				39: begin //Store Byte with Update
					stage1Enable <= 1; isStore <= 1; isUpdate1 <= 1;	isAlgebraic1 <= 0; loadStoreFormat1 <= Byte;
				end
				40: begin //Load Halfword and Zero
					stage1Enable <= 1; isStore <= 0; isUpdate1 <= 0;	isAlgebraic1 <= 0; loadStoreFormat1 <= HalfWord;
				end
				41: begin //Load Halfword and Zero with Update
					stage1Enable <= 1; isStore <= 0; isUpdate1 <= 1;	isAlgebraic1 <= 0; loadStoreFormat1 <= HalfWord;
				end
				42: begin //Load Halfword Algebraic
					stage1Enable <= 1; isStore <= 0; isUpdate1 <= 0;	isAlgebraic1 <= 1; loadStoreFormat1 <= HalfWord;
				end
				43: begin //Load Halfword Algebraic with Update	
					stage1Enable <= 1; isStore <= 0; isUpdate1 <= 1;	isAlgebraic1 <= 1; loadStoreFormat1 <= HalfWord;
				end			
				44: begin //Store Halfword
					stage1Enable <= 1; isStore <= 1; isUpdate1 <= 0;	isAlgebraic1 <= 0; loadStoreFormat1 <= HalfWord;
				end
				45: begin //Store Halfword with Update	
					stage1Enable <= 1; isStore <= 1; isUpdate1 <= 1;	isAlgebraic1 <= 0; loadStoreFormat1 <= HalfWord;
				end			
				default: begin stage1Enable <= 0; end//invalid instruction				
			endcase end
			
			else if(instructionFormat_i == X && opCode_i == 31) begin
			operand1_1 <= operand1_i; /*operand2_1 <= operand2_i;*/ operand3_1 <= operand3_i;
			reg1Address_1 <= reg1Address_i; reg2Address_1 <= reg2Address_i;
			address1 <= operand2_i + operand3_i; //calculate the address to load/store from/to
			blockAddress1 <= (operand2_i + operand3_i) / 16;//the address of the block to load from (may not be needed)
			blockIndex1 <= (operand2_i + operand3_i) % 16;//the index in the block to load
			case(xOpCode_i)//parse X format Load/Stores
				87: begin //Load Byte and Zero Indexed
					stage1Enable <= 1; isStore <= 0; isUpdate1 <= 0; isAlgebraic1 <= 0; loadStoreFormat1 <= Byte;
				end
				119: begin //Load Byte and Zero with Update Indexed
					stage1Enable <= 1; isStore <= 0; isUpdate1 <= 1; isAlgebraic1 <= 0; loadStoreFormat1 <= Byte;
				end
				279: begin //Load Halfword and Zero Indexed
					stage1Enable <= 1; isStore <= 0; isUpdate1 <= 0; isAlgebraic1 <= 0; loadStoreFormat1 <= HalfWord;
				end
				311: begin //Load Halfword and Zero with Update Indexed
					stage1Enable <= 1; isStore <= 0; isUpdate1 <= 1; isAlgebraic1 <= 0; loadStoreFormat1 <= HalfWord;
				end
				343: begin //Load Halfword Algebraic Indexed
					stage1Enable <= 1; isStore <= 0; isUpdate1 <= 0; isAlgebraic1 <= 1; loadStoreFormat1 <= HalfWord;
				end
				375: begin //Load Halfword Algebraic with Update Indexed
					stage1Enable <= 1; isStore <= 0; isUpdate1 <= 1; isAlgebraic1 <= 0; loadStoreFormat1 <= HalfWord;
				end
				23: begin //Load Word and Zero Indexed
					stage1Enable <= 1; isStore <= 0; isUpdate1 <= 0; isAlgebraic1 <= 0; loadStoreFormat1 <= Word;
				end
				55: begin //Load Word and Zero with Update Indexed
					stage1Enable <= 1; isStore <= 0; isUpdate1 <= 1; isAlgebraic1 <= 0; loadStoreFormat1 <= Word;
				end
				341: begin //Load Word Algebraic Indexed
					stage1Enable <= 1; isStore <= 0; isUpdate1 <= 0; isAlgebraic1 <= 1; loadStoreFormat1 <= Word;
				end
				373: begin //Load Word Algebraic with Update Indexed
					stage1Enable <= 1; isStore <= 0; isUpdate1 <= 1; isAlgebraic1 <= 1; loadStoreFormat1 <= Word;
				end
				21: begin //Load Doubleword Indexed
					stage1Enable <= 1; isStore <= 0; isUpdate1 <= 0; isAlgebraic1 <= 1; loadStoreFormat1 <= DoubleWord;
				end
				53: begin //Load Doubleword with Update Indexed
					stage1Enable <= 1; isStore <= 0; isUpdate1 <= 1; isAlgebraic1 <= 1; loadStoreFormat1 <= DoubleWord;
				end
				215: begin //Store Byte Indexed
					stage1Enable <= 1; isStore <= 1; isUpdate1 <= 0; isAlgebraic1 <= 0; loadStoreFormat1 <= Byte;
				end
				247: begin //Store Byte with Update Indexed
					stage1Enable <= 1; isStore <= 1; isUpdate1 <= 1; isAlgebraic1 <= 0; loadStoreFormat1 <= Byte;
				end
				407: begin //Store Halfword Indexed
					stage1Enable <= 1; isStore <= 1; isUpdate1 <= 0; isAlgebraic1 <= 0; loadStoreFormat1 <= HalfWord;
				end
				439: begin //Store Halfword with Update Indexed
					stage1Enable <= 1; isStore <= 1; isUpdate1 <= 1; isAlgebraic1 <= 0; loadStoreFormat1 <= HalfWord;
				end
				151: begin //Store Word Indexed
					stage1Enable <= 1; isStore <= 1; isUpdate1 <= 0; isAlgebraic1 <= 0; loadStoreFormat1 <= Word;
				end
				183: begin //Store Word with Update Indexed
					stage1Enable <= 1; isStore <= 1; isUpdate1 <= 1; isAlgebraic1 <= 0; loadStoreFormat1 <= Word;
				end
				149: begin //Store Doubleword Indexed
					stage1Enable <= 1; isStore <= 1; isUpdate1 <= 0; isAlgebraic1 <= 0; loadStoreFormat1 <= DoubleWord;
				end
				181: begin //Store Doubleword with Update Indexed
					stage1Enable <= 1; isStore <= 1; isUpdate1 <= 1; isAlgebraic1 <= 0; loadStoreFormat1 <= DoubleWord;
				end
				/*
				87: begin //Load Halfword Byte-Reverse Indexed
				end
				87: begin //Load Word Byte-Reverse Indexed
				end
				87: begin //Store Halfword Byte-Reverse Indexed
				end
				87: begin //Store Word Byte-Reverse Indexed
				end
				*/
			endcase end
			/*
			else if(instructionFormat_i == DS) begin
			case(opCode_i)//parse DS format Load/Stores
			
			endcase end
			else if(instructionFormat_i == DQ) begin
			case(opCode_i)//parse DQ format Load/Stores
			
			endcase end
			*/
			else
			begin
				stage1Enable <= 0;
				//TODO: Unsupported instruction
			end
		end
		
	 end
	 
	//as memory block size is 128 bits and if we have 128 blocks, we have 2KiB of D-memory
	//block = integer component of address / memoryBlockSize
	//offset in block = address % memoryBlockSize
	reg [0:memoryBlockSize - 1] dataMemory [0:numMemoryBlocks - 1];//128 16B blocks

	//These registers bypas the reading of memory
	reg stage2Enable;
	reg [0:memoryBlockSize - 1] readBlock;
	reg [0:6] blockAddress2; reg [0:3] blockIndex2; reg [0:addressSize-1] address2; reg isStore2;
	reg [0:63] operand1_2, /*operand2_2,*/ operand3_2;
	reg [0:regWidth-1] reg1Address_2, reg2Address_2;
	reg [0:2] loadStoreFormat2;
	reg isUpdate2, isAlgebraic2;
	
	//perform memory read to fetch the block
	always @(posedge clock_i)
	begin
		stage2Enable <= stage1Enable;
		if(stage1Enable == 1)
		begin
			//mem read
			readBlock <= dataMemory[blockAddress1];//get the block out of memory
			//pass through
			operand1_2 <= operand1_1; /*operand2_2 <= operand2_1;*/ operand3_2 <= operand3_1;//pass through operands
			address2 <= address1; blockAddress2 <= blockAddress1; blockIndex2 <= blockIndex1;//pass through the address, block and index
			reg1Address_2 <= reg1Address_1; reg2Address_2 <= reg2Address_1;//pass through the reg addresses
			loadStoreFormat2 <= loadStoreFormat1;//pass through the format
			isUpdate2 <= isUpdate1; isAlgebraic2 <= isAlgebraic1;
			isStore2 <= isStore;
		end
	end
	
	
	reg stage3Enable;
	reg [0:memoryBlockSize - 1] writeBlock;
	reg [0:6] blockAddress3; 
	//reg [0:3] blockIndex3;
	reg [0:addressSize-1] address3; reg isStore3;
	//reg [0:63] operand2_3;
	reg [0:regWidth-1] reg1Address_3, reg2Address_3;
	reg [0:2] loadStoreFormat3;
	reg isUpdate3, isAlgebraic3;
	//block parser
	always @(posedge clock_i)
	begin
		stage3Enable <= stage2Enable;
		if(stage2Enable == 1)
		begin
			//operand2_3 <= operand2_2;
			address3 <= address2; blockAddress3 <= blockAddress2;// blockIndex3 <= blockIndex2;
			reg1Address_3 <= reg1Address_2; reg2Address_3 <= reg2Address_2;
			loadStoreFormat3 <= loadStoreFormat2;
			isUpdate3 <= isUpdate2; isAlgebraic3 <= isAlgebraic2;
			isStore3 <= isStore2;
			if(isStore2 == 1)//store operation
			begin
				if(loadStoreFormat2 == Byte) begin//write the byte to the new block
				writeBlock <= readBlock; 
				case(blockIndex2)
					 0: begin writeBlock[(0*8)+:8]  <= operand1_2[63-:8]; end  1: begin writeBlock[(1*8)+:8]  <= operand1_2[63-:8];end 
					 2: begin writeBlock[(2*8)+:8]  <= operand1_2[63-:8]; end  3: begin writeBlock[(3*8)+:8]  <= operand1_2[63-:8];end
					 4: begin writeBlock[(4*8)+:8]  <= operand1_2[63-:8]; end  5: begin writeBlock[(5*8)+:8]  <= operand1_2[63-:8];end 
					 6: begin writeBlock[(6*8)+:8]  <= operand1_2[63-:8]; end  7: begin writeBlock[(7*8)+:8]  <= operand1_2[63-:8];end
					 8: begin writeBlock[(8*8)+:8]  <= operand1_2[63-:8]; end  9: begin writeBlock[(9*8)+:8]  <= operand1_2[63-:8];end 
					10: begin writeBlock[(10*8)+:8] <= operand1_2[63-:8]; end 11: begin writeBlock[(11*8)+:8] <= operand1_2[63-:8];end
					12: begin writeBlock[(12*8)+:8] <= operand1_2[63-:8]; end 13: begin writeBlock[(13*8)+:8] <= operand1_2[63-:8];end 
					14: begin writeBlock[(14*8)+:8] <= operand1_2[63-:8]; end 15: begin writeBlock[(15*8)+:8] <= operand1_2[63-:8];end
				endcase			
				end
				
				else if(loadStoreFormat2 == HalfWord) begin//write the half word to the new block
				writeBlock <= readBlock; 
				case(blockIndex2)
					 0: begin writeBlock[(0*8)+:16]  <= operand1_2[63-:16]; end 2: begin writeBlock[(2*8)+:16]  <= operand1_2[63-:16];end
					 4: begin writeBlock[(4*8)+:16]  <= operand1_2[63-:16]; end 6: begin writeBlock[(6*8)+:16]  <= operand1_2[63-:16];end
					 8: begin writeBlock[(8*8)+:16]  <= operand1_2[63-:16]; end 10: begin writeBlock[(10*8)+:16] <= operand1_2[63-:16];end
					12: begin writeBlock[(12*8)+:16] <= operand1_2[63-:16]; end 14: begin writeBlock[(14*8)+:16] <= operand1_2[63-:16];end
				endcase	
				end
				
				else if(loadStoreFormat2 == Word) begin//write the word to the new block
				writeBlock <= readBlock;
				case(blockIndex2)
					 0: begin writeBlock[(0*8)+:32] <= operand1_2[63-:32]; end 4: begin writeBlock[(4*8)+:32]  <= operand1_2[63-:32];end
					 8: begin writeBlock[(8*8)+:32] <= operand1_2[63-:32]; end 12: begin writeBlock[(12*8)+:32] <= operand1_2[63-:32];end
				endcase	
				end
				else if(loadStoreFormat2 == DoubleWord) begin//write the double word to the new block
				writeBlock <= readBlock;
				case(blockIndex2)
					 0: begin writeBlock[(0*8)+:64] <= operand1_2; end 8: begin writeBlock[(8*8)+:64] <= operand1_2;end
				endcase	
				end
				else if(loadStoreFormat2 == QuadWord) begin//write the double word to the new block
					writeBlock[(0*8)+:64] <= operand1_2; writeBlock[(8*8)+:64] <= operand3_2;
				end
			end
			else
			begin//load operation
				if(loadStoreFormat2 == Byte) begin//write the byte to the new block
					case(blockIndex2)
						 0: begin writeBlock <= readBlock[(0*8)+:8]; end  1: begin writeBlock <= readBlock[(1*8)+:8];end 
						 2: begin writeBlock <= readBlock[(2*8)+:8]; end  3: begin writeBlock <= readBlock[(3*8)+:8];end
						 4: begin writeBlock <= readBlock[(4*8)+:8]; end  5: begin writeBlock <= readBlock[(5*8)+:8];end 
						 6: begin writeBlock <= readBlock[(6*8)+:8]; end  7: begin writeBlock <= readBlock[(7*8)+:8];end
						 8: begin writeBlock <= readBlock[(8*8)+:8]; end  9: begin writeBlock <= readBlock[(9*8)+:8];end 
						10: begin writeBlock <= readBlock[(10*8)+:8]; end 11: begin writeBlock <= readBlock[(11*8)+:8];end
						12: begin writeBlock <= readBlock[(12*8)+:8]; end 13: begin writeBlock <= readBlock[(13*8)+:8];end 
						14: begin writeBlock <= readBlock[(14*8)+:8]; end 15: begin writeBlock <= readBlock[(15*8)+:8];end
					endcase			
				end
				else if(loadStoreFormat2 == HalfWord) begin//write the half word to the new block
					case(blockIndex2)
						 0: begin writeBlock <= readBlock[(0*8)+:16]; end 2: begin writeBlock <= readBlock[(2*8)+:16];end
						 4: begin writeBlock <= readBlock[(4*8)+:16]; end 6: begin writeBlock <= readBlock[(6*8)+:16];end
						 8: begin writeBlock <= readBlock[(8*8)+:16]; end 10: begin writeBlock <= readBlock[(10*8)+:16];end
						12: begin writeBlock <= readBlock[(12*8)+:16]; end 14: begin writeBlock <= readBlock[(14*8)+:16];end
					endcase	
				end
				else if(loadStoreFormat2 == Word) begin//write the word to the new block
					case(blockIndex2)
						 0: begin writeBlock <= readBlock[(0*8)+:32]; end 4: begin writeBlock <= readBlock[(4*8)+:32];end
						 8: begin writeBlock <= readBlock[(8*8)+:32]; end 12: begin writeBlock <= readBlock[(12*8)+:32];end
					endcase	
				end
				else if(loadStoreFormat2 == DoubleWord) begin//write the double word to the new block
					case(blockIndex2)
						 0: begin writeBlock <= readBlock[(0*8)+:64]; end 8: begin writeBlock <= readBlock[(8*8)+:64];end
					endcase	
				end
				else if(loadStoreFormat2 == QuadWord) begin//write the Quadword to the new block
					writeBlock <= readBlock;
				end
				else
				begin
					//Throw invalid load store format
				end
			end
		end
	end
	

	integer i = 0;
	//instruction completion (data output and memory writeback)
	always @(posedge clock_i)
	begin
		if(reset_i == 1)
		begin
			for( i = 0; i < numMemoryBlocks; i = i + 1)
			begin
				dataMemory [i] <= 0;
			end
		end
		else if(stage3Enable == 1)
		begin
			if(isUpdate3 == 1)//if were updating, write the address to reg 2 (Note there is no loadQuadword with update)
			begin
				reg2WritebackEnable_o <= 1;
				reg2WritebackAddress_o <= reg2Address_3;
				reg2WritebackVal_o <= address3;
			end
			else//else disable reg 2 writeback
			begin
				reg2WritebackEnable_o <= 0;
			end	
				
			if(isStore3 == 1)//store
			begin
				dataMemory[blockAddress3] <= writeBlock;//store to memory
				reg1WritebackEnable_o <= 0;//dissable reg1 writeback
			end
			else//load
			begin
				reg1WritebackEnable_o <= 1;//perform the load
				reg1WritebackAddress_o <= reg1Address_3;
				if(isAlgebraic3 == 1)
				begin
					reg1WritebackVal_o <= $signed(writeBlock[127-:64]);//write the 64lsbs to the reg
				end
				else
				begin
					reg1WritebackVal_o <= writeBlock[127-:64];//write the 64lsbs to the reg
				end
				
				if(loadStoreFormat3 == QuadWord)//if were loading a quad word, the first 64 bits goes to reg 1, the last 64 bits goes to (reg 1)+1
				begin
					reg2WritebackEnable_o <= 1;
					reg2WritebackAddress_o <= reg1Address_3 + 1;
					reg2WritebackVal_o <= writeBlock[63-:64];//write the 64msbs to the next reg
				end			
			end					
		end
		functionalUnitCode_o <= LdStUnitCode;//always have the output as this code
	end
	
endmodule
