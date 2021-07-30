`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//NOTE/TODO: For store quadword the decoder needs to implement operand1 for the first doubleword, operand 2 for the regOffset, imm for the immOffset and operand3 for the last doubleword
//////////////////////////////////////////////////////////////////////////////////
module LoadStoreUnit#(
parameter memoryBlockSize = 128, parameter numMemoryBlocks = 128,
parameter Byte = 1, parameter HalfWord = 2, parameter Word = 3, parameter DoubleWord = 4, parameter QuadWord = 5,
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
	output reg [0:regWidth-1] reg1WritebackAddress_o, reg2WritebackAddress_o,
	output reg [0:63] reg1WritebackVal_o, reg2WritebackVal_o
    );

	//as memory block size is 128 bits and if we have 128 blocks, we have 2KiB of D-memory
	//block = integer component of address / memoryBlockSize
	//offset in block = address % memoryBlockSize
	reg [0:memoryBlockSize - 1] dataMemory [0:numMemoryBlocks - 1];//128 16B blocks
	
	//load buffers
	reg enable1;
	reg [0:2] format1;
	reg isLoad1;
	reg [0:addressSize-1] address1;//address that have been generated to load from - needed if isUpdate to write the address back to a reg
	reg [0:6] blockAddress1;//the address of the block that were going to be loading from
	reg [0:3] blockIndex1;//the index of a particular byte within the block	
	reg [0:5] reg1Address1, reg2Address1;
	reg [0:memoryBlockSize-1] loadBlock1;
	reg isloadAlgebraic1, isUpdate1;
	reg [0:63] operand1_1, operand2_1, operand3_1;
	
	// stage 1
	always @(posedge clock_i)
	begin
		functionalUnitCode_o <= LdStUnitCode;//as this output will never change so we set it here to allow the compiler to optimise it into hard logic
		if(reset_i == 1)
		begin
			enable1 <= 0; isLoad1 <= 0;
		end
		else if((enable_i == 1) && (functionalUnitCode_i == LdStUnitCode))
		begin
			operand1_1 <= operand1_i; operand2_1 <= operand2_i; operand3_1 <= operand3_i;
			if(instructionFormat_i == D)
			begin
				case(opCode_i)
					34: begin //Load Byte and Zero
						blockAddress1 <= (operand2_i + imm_i) / 16;//the address of the block to load from (may not be needed)
						blockIndex1 <= (operand2_i + imm_i) % 16;//the index in the block to load
						address1 <= operand2_i + imm_i;//calculate the address
						loadBlock1 <= dataMemory[(operand2_i + imm_i) / 16];//the block from memory
						enable1 <= 1;
						format1 <= Byte;//were loading a byte
						isLoad1 <= 1;//enable load, dissable store						
						isUpdate1 <= 0;
						reg1Address1 <= reg1Address_i; reg2Address1 <= reg2Address_i;
						isloadAlgebraic1 <= 0;
					end
					35: begin//Load Byte and Zero with Update
						blockAddress1 <= (operand2_i + imm_i) / 16;//the address of the block to load from
						blockIndex1 <= (operand2_i + imm_i) % 16;//the index in the block to load
						address1 <= operand2_i + imm_i;//calculate the address
						loadBlock1 <= dataMemory[(operand2_i + imm_i) / 16];//the block from memory
						enable1 <= 1;
						format1 <= Byte;//were loading a byte
						isLoad1 <= 1;//enable load, dissable store						
						isUpdate1 <= 1;
						reg1Address1 <= reg1Address_i; reg2Address1 <= reg2Address_i;
						isloadAlgebraic1 <= 0;
					end
					40: begin //Load Halfword and Zero
						blockAddress1 <= (operand2_i + imm_i) / 16;//the address of the block to load from (may not be needed)
						blockIndex1 <= (operand2_i + imm_i) % 16;//the index in the block to load
						address1 <= operand2_i + imm_i;//calculate the address
						loadBlock1 <= dataMemory[(operand2_i + imm_i) / 16];//the block from memory
						enable1 <= 1;
						format1 <= HalfWord;//were loading a byte
						isLoad1 <= 1;//enable load, dissable store						
						isUpdate1 <= 0;
						reg1Address1 <= reg1Address_i; reg2Address1 <= reg2Address_i;
						isloadAlgebraic1 <= 0;
					end
					41: begin //Load Halfword and Zero with Update
						blockAddress1 <= (operand2_i + imm_i) / 16;//the address of the block to load from
						blockIndex1 <= (operand2_i + imm_i) % 16;//the index in the block to load
						address1 <= operand2_i + imm_i;//calculate the address
						loadBlock1 <= dataMemory[(operand2_i + imm_i) / 16];//the block from memory
						enable1 <= 1;
						format1 <= HalfWord;//were loading a byte
						isLoad1 <= 1;//enable load, dissable store						
						isUpdate1 <= 1;
						reg1Address1 <= reg1Address_i; reg2Address1 <= reg2Address_i;
						isloadAlgebraic1 <= 0;
					end
					42: begin //Load Halfword Algebraic
						blockAddress1 <= (operand2_i + imm_i) / 16;//the address of the block to load from (may not be needed)
						blockIndex1 <= (operand2_i + imm_i) % 16;//the index in the block to load
						address1 <= operand2_i + imm_i;//calculate the address
						loadBlock1 <= dataMemory[(operand2_i + imm_i) / 16];//the block from memory
						enable1 <= 1;
						format1 <= HalfWord;//were loading a byte
						isLoad1 <= 1;//enable load, dissable store						
						isUpdate1 <= 0;
						reg1Address1 <= reg1Address_i; reg2Address1 <= reg2Address_i;
						isloadAlgebraic1 <= 1;
					end
					43: begin //Load Halfword Algebraic with Update
						blockAddress1 <= (operand2_i + imm_i) / 16;//the address of the block to load from (may not be needed)
						blockIndex1 <= (operand2_i + imm_i) % 16;//the index in the block to load
						address1 <= operand2_i + imm_i;//calculate the address
						loadBlock1 <= dataMemory[(operand2_i + imm_i) / 16];//the block from memory
						enable1 <= 1;
						format1 <= HalfWord;//were loading a byte
						isLoad1 <= 1;//enable load, dissable store						
						isUpdate1 <= 1;
						reg1Address1 <= reg1Address_i; reg2Address1 <= reg2Address_i;
						isloadAlgebraic1 <= 1;
					end
					32: begin //Load Word and Zero
						blockAddress1 <= (operand2_i + imm_i) / 16;//the address of the block to load from
						blockIndex1 <= (operand2_i + imm_i) % 16;//the index in the block to load
						address1 <= operand2_i + imm_i;//calculate the address
						loadBlock1 <= dataMemory[(operand2_i + imm_i) / 16];//the block from memory
						enable1 <= 1;
						format1 <= Word;//were loading a byte
						isLoad1 <= 1;//enable load, dissable store						
						isUpdate1 <= 0;
						reg1Address1 <= reg1Address_i; reg2Address1 <= reg2Address_i;
						isloadAlgebraic1 <= 0;
					end
					33: begin //Load Word and Zero with Update
						blockAddress1 <= (operand2_i + imm_i) / 16;//the address of the block to load from
						blockIndex1 <= (operand2_i + imm_i) % 16;//the index in the block to load
						address1 <= operand2_i + imm_i;//calculate the address
						loadBlock1 <= dataMemory[(operand2_i + imm_i) / 16];//the block from memory
						enable1 <= 1;
						format1 <= Word;//were loading a byte
						isLoad1 <= 1;//enable load, dissable store						
						isUpdate1 <= 1;
						reg1Address1 <= reg1Address_i; reg2Address1 <= reg2Address_i;
						isloadAlgebraic1 <= 0;
					end
					
					38: begin //Store Byte	
						enable1 <= 1; isLoad1 <= 0;//were enabled and not loading, therefore storing
						format1 <= Byte;//storing a byte
						blockAddress1 <= (operand2_i + imm_i) / 16;//the address of the block to load from (may not be needed)
						address1 <= operand2_i + imm_i;//calculate the address
						blockAddress1 <= (operand2_i + imm_i) / 16;//the address of the block to load from
						blockIndex1 <= (operand2_i + imm_i) % 16;//the index in the block to load
						reg1Address1 <= reg1Address_i; reg2Address1 <= reg2Address_i;
						loadBlock1 <= dataMemory[(operand2_i + imm_i) / 16];//the block from memory
						isUpdate1 <= 0;
					end
					39: begin //Store Byte with Update
						enable1 <= 1; isLoad1 <= 0;//were enabled and not loading, therefore storing
						format1 <= Byte;//storing a byte
						blockAddress1 <= (operand2_i + imm_i) / 16;//the address of the block to load from (may not be needed)
						address1 <= operand2_i + imm_i;//calculate the address
						blockAddress1 <= (operand2_i + imm_i) / 16;//the address of the block to load from
						blockIndex1 <= (operand2_i + imm_i) % 16;//the index in the block to load
						reg1Address1 <= reg1Address_i; reg2Address1 <= reg2Address_i;
						loadBlock1 <= dataMemory[(operand2_i + imm_i) / 16];//the block from memory
						isUpdate1 <= 1;
					end
					44: begin //Store Halfword
						enable1 <= 1; isLoad1 <= 0;//were enabled and not loading, therefore storing
						format1 <= HalfWord;//storing a byte
						blockAddress1 <= (operand2_i + imm_i) / 16;//the address of the block to load from (may not be needed)
						address1 <= operand2_i + imm_i;//calculate the address
						blockAddress1 <= (operand2_i + imm_i) / 16;//the address of the block to load from
						blockIndex1 <= (operand2_i + imm_i) % 16;//the index in the block to load
						reg1Address1 <= reg1Address_i; reg2Address1 <= reg2Address_i;
						loadBlock1 <= dataMemory[(operand2_i + imm_i) / 16];//the block from memory
						isUpdate1 <= 0;
					end
					45: begin //Store Halfword with Update
						enable1 <= 1; isLoad1 <= 0;//were enabled and not loading, therefore storing
						format1 <= HalfWord;//storing a byte
						blockAddress1 <= (operand2_i + imm_i) / 16;//the address of the block to load from (may not be needed)
						address1 <= operand2_i + imm_i;//calculate the address
						blockAddress1 <= (operand2_i + imm_i) / 16;//the address of the block to load from
						blockIndex1 <= (operand2_i + imm_i) % 16;//the index in the block to load
						reg1Address1 <= reg1Address_i; reg2Address1 <= reg2Address_i;
						loadBlock1 <= dataMemory[(operand2_i + imm_i) / 16];//the block from memory
						isUpdate1 <= 1;
					end
					36: begin //Store Word
						enable1 <= 1; isLoad1 <= 0;//were enabled and not loading, therefore storing
						format1 <= Word;//storing a byte
						blockAddress1 <= (operand2_i + imm_i) / 16;//the address of the block to load from (may not be needed)
						address1 <= operand2_i + imm_i;//calculate the address
						blockAddress1 <= (operand2_i + imm_i) / 16;//the address of the block to load from
						blockIndex1 <= (operand2_i + imm_i) % 16;//the index in the block to load
						reg1Address1 <= reg1Address_i; reg2Address1 <= reg2Address_i;
						loadBlock1 <= dataMemory[(operand2_i + imm_i) / 16];//the block from memory
						isUpdate1 <= 0;
					end
					37: begin //Store Word with Update
						enable1 <= 1; isLoad1 <= 0;//were enabled and not loading, therefore storing
						format1 <= Word;//storing a byte
						blockAddress1 <= (operand2_i + imm_i) / 16;//the address of the block to load from (may not be needed)
						address1 <= operand2_i + imm_i;//calculate the address
						blockAddress1 <= (operand2_i + imm_i) / 16;//the address of the block to load from
						blockIndex1 <= (operand2_i + imm_i) % 16;//the index in the block to load
						reg1Address1 <= reg1Address_i; reg2Address1 <= reg2Address_i;
						loadBlock1 <= dataMemory[(operand2_i + imm_i) / 16];//the block from memory
						isUpdate1 <= 1;
					end
					46: begin //Load Multiple Word
						/*Throw not implemented instruction*/
					end
					47: begin //Store Multiple Word
						/*Throw not implemented instruction*/
					end
					default: begin /*Throw invalid instruction*/ enable1 <= 0; end
				endcase
			end				
		end
		else
		begin
			enable1 <= 0;
		end		
	end	

	
	integer i = 0;
	//store stage 2 to 3 buffers
	reg enable2;
	reg [0:addressSize-1] address2;//address that have been generated to store to
	reg [0:6] blockAddress2;//the address of the block that were going to be loading from
	reg [0:5] reg2Address2;
	reg isUpdate2;
	reg [0:63] operand1_2, operand2_2, operand3_2;	
	reg [0:memoryBlockSize-1] newBlock2;
	
	//load stage 2
	always @(posedge clock_i)
	begin
		if(reset_i == 1)
		begin
			reg1WritebackEnable_o <= 0; reg2WritebackEnable_o <= 0;
			for(i = 0; i < numMemoryBlocks; i = i + 1)
			begin
				dataMemory[i] <= 128'b0;//reset the memory to zeros
			end
		end
		else if(enable1 == 1 && isLoad1 == 1)
		begin
			if(format1 == Byte)
				begin 
					reg1WritebackEnable_o <= 1; reg2WritebackEnable_o <= isUpdate1;//set the writeback enables
					reg1WritebackAddress_o <= reg1Address1;
					if(isloadAlgebraic1 == 0) begin//(
						reg1WritebackVal_o[63-:8] <= loadBlock1[blockIndex1+:8]; reg1WritebackVal_o[0+:(64-8)] <= 0; end//zero extended
					else begin
						reg1WritebackVal_o <= $signed(loadBlock1[blockIndex1+:8]); end//sign extend
					if(isUpdate1 == 1) begin
						reg2WritebackVal_o <= address1;
						reg1WritebackAddress_o <= reg2Address1;
					end
				end	
			else if(format1 == HalfWord)
				begin 
					reg1WritebackEnable_o <= 1; reg2WritebackEnable_o <= isUpdate1;//set the writeback enables
					reg1WritebackAddress_o <= reg1Address1;
					if(isloadAlgebraic1 == 0) begin//(
						reg1WritebackVal_o[63-:16] <= loadBlock1[blockIndex1+:16]; reg1WritebackVal_o[0+:(64-16)] <= 0; end//zero extended
					else begin
						reg1WritebackVal_o <= $signed(loadBlock1[blockIndex1+:16]); end//sign extend
					if(isUpdate1 == 1) begin
						reg2WritebackVal_o <= address1;
						reg1WritebackAddress_o <= reg2Address1;
					end
				end					
			else if(format1 == Word)
				begin 
					reg1WritebackEnable_o <= 1; reg2WritebackEnable_o <= isUpdate1;//set the writeback enables
					reg1WritebackAddress_o <= reg1Address1;
					if(isloadAlgebraic1 == 0) begin//(
						reg1WritebackVal_o[63-:32] <= loadBlock1[blockIndex1+:32]; reg1WritebackVal_o[0+:(64-32)] <= 0; end//zero extended
					else begin
						reg1WritebackVal_o <= $signed(loadBlock1[blockIndex1+:32]); end//sign extend
					if(isUpdate1 == 1) begin
						reg2WritebackVal_o <= address1;
						reg1WritebackAddress_o <= reg2Address1;
					end
				end
			else if(format1 == DoubleWord)
				begin 
					reg1WritebackEnable_o <= 1; reg2WritebackEnable_o <= isUpdate1;//set the writeback enables
					reg1WritebackAddress_o <= reg1Address1;
					reg1WritebackVal_o <= loadBlock1[blockIndex1+:64];
					if(isUpdate1 == 1) begin
						reg2WritebackVal_o <= address1;
						reg1WritebackAddress_o <= reg2Address1;
					end
				end
			else if(format1 == QuadWord)
				begin 
					reg1WritebackEnable_o <= 1; reg2WritebackEnable_o <= 1;//set the writeback enables
					reg1WritebackAddress_o <= reg1Address1; reg1WritebackAddress_o <= reg1Address1 + 1;//reg pair
					reg1WritebackVal_o <= loadBlock1[blockIndex1+:64];
					reg2WritebackVal_o <= loadBlock1[(blockIndex1+64)+:64];
				end			
		end
		else
		begin
			reg1WritebackEnable_o <= 0; reg2WritebackEnable_o <= 0;
		end
		
		//store stage 3
		if(enable2 == 1)
		begin
			//perform the block write
			dataMemory[blockAddress2] <= newBlock2;
			if(isUpdate2 == 1)
			begin
				reg1WritebackEnable_o <= 1;
				reg1WritebackAddress_o <= reg2Address2;
				reg1WritebackVal_o <= address2;
			end
		end
	end
	
	//store stage 2
	always @(posedge clock_i)
	begin
		if((enable1 == 1) && (isLoad1 == 0))
		begin
			enable2 <= enable1;
			address2 <= address1;
			blockAddress2 <= blockAddress1;
			operand1_2 <= operand1_1; operand2_2 <= operand2_1; operand3_2 <= operand3_1;
			reg2Address2 <= reg2Address1;
			isUpdate2 <= isUpdate1;
			if(format1 == Byte) begin//write the byte to the new block
			newBlock2 <= loadBlock1; 
			case(blockIndex1)
				 0: begin newBlock2[(0*8)+:8]  <= operand1_1[63-:8]; end  1: begin newBlock2[(1*8)+:8]  <= operand1_1[63-:8];end 
				 2: begin newBlock2[(2*8)+:8]  <= operand1_1[63-:8]; end  3: begin newBlock2[(3*8)+:8]  <= operand1_1[63-:8];end
				 4: begin newBlock2[(4*8)+:8]  <= operand1_1[63-:8]; end  5: begin newBlock2[(5*8)+:8]  <= operand1_1[63-:8];end 
				 6: begin newBlock2[(6*8)+:8]  <= operand1_1[63-:8]; end  7: begin newBlock2[(7*8)+:8]  <= operand1_1[63-:8];end
				 8: begin newBlock2[(8*8)+:8]  <= operand1_1[63-:8]; end  9: begin newBlock2[(9*8)+:8]  <= operand1_1[63-:8];end 
				10: begin newBlock2[(10*8)+:8] <= operand1_1[63-:8]; end 11: begin newBlock2[(11*8)+:8] <= operand1_1[63-:8];end
				12: begin newBlock2[(12*8)+:8] <= operand1_1[63-:8]; end 13: begin newBlock2[(13*8)+:8] <= operand1_1[63-:8];end 
				14: begin newBlock2[(14*8)+:8] <= operand1_1[63-:8]; end 15: begin newBlock2[(15*8)+:8] <= operand1_1[63-:8];end
			endcase			
			end
			
			else if(format1 == HalfWord) begin//write the half word to the new block
			newBlock2 <= loadBlock1; 
			case(blockIndex1)
				 0: begin newBlock2[(0*8)+:16]  <= operand1_1[63-:16]; end 2: begin newBlock2[(2*8)+:16]  <= operand1_1[63-:16];end
				 4: begin newBlock2[(4*8)+:16]  <= operand1_1[63-:16]; end 6: begin newBlock2[(6*8)+:16]  <= operand1_1[63-:16];end
				 8: begin newBlock2[(8*8)+:16]  <= operand1_1[63-:16]; end 10: begin newBlock2[(10*8)+:16] <= operand1_1[63-:16];end
				12: begin newBlock2[(12*8)+:16] <= operand1_1[63-:16]; end 14: begin newBlock2[(14*8)+:16] <= operand1_1[63-:16];end
			endcase	
			end
			
			else if(format1 == Word) begin//write the word to the new block
			newBlock2 <= loadBlock1;
			case(blockIndex1)
				 0: begin newBlock2[(0*8)+:32]  <= operand1_1[63-:32]; end 4: begin newBlock2[(4*8)+:32]  <= operand1_1[63-:32];end
				 8: begin newBlock2[(8*8)+:32]  <= operand1_1[63-:32]; end 12: begin newBlock2[(12*8)+:32] <= operand1_1[63-:32];end
			endcase	
			end
			else if(format1 == DoubleWord) begin//write the double word to the new block
			newBlock2 <= loadBlock1;
			case(blockIndex1)
				 0: begin newBlock2[(0*8)+:64]  <= operand1_1; end 8: begin newBlock2[(8*8)+:64]  <= operand1_1;end
			endcase	
			end
			else if(format1 == QuadWord) begin//write the double word to the new block
			newBlock2[(0*8)+:64] <= operand2_1; newBlock2[(8*8)+:64] <= operand3_1;
			end
		end
	end
	



endmodule
