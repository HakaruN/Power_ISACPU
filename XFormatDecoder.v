`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//NOTE: There may be an error in the ISA where there are two instructions both with opcodes 63 and Xopcodes of 846
//These instructions are: Floating Convert with round Signed Doubleword to Double-Precision format and Floating Convert with round Signed Doubleword to Single-Precision format
//////////////////////////////////////////////////////////////////////////////////
module XFormatDecoder#( parameter opcodeWidth = 6, parameter xOpCodeWidth = 10, parameter regWidth = 5, parameter instructionWidth = 32,
parameter FXUnitCode = 0, parameter FPUnitCode = 1, parameter LdStUnitCode = 2, parameter BranchUnitCode = 3, parameter TrapUnitCode = 4//functional unit code/ID used for dispatch
)(
	//command in
	input wire clock_i,
	input wire enable_i,
	//data in
	input wire [0:instructionWidth-1] instruction_i,
	//command out
	output reg stall_o,
	//data out
	output reg [0:xOpCodeWidth-1] xOpcode_o,
	output reg [0:regWidth-1] reg1_o, reg2_o, reg3_o,
	output reg reg2ValOrZero_o,//indicates that if the register addr is zero, a zero litteral is to be used not reg zero
	output reg bit1_o,
	output reg [0:2] functionalUnitCode_o,
	output reg enable_o
	);
	
always @(posedge clock_i)
begin
	if(enable_i == 1)
	begin
		if(instruction_i[0:5] == 31)//check op opcode
		begin			
			xOpcode_o <= instruction_i[21:30];
			bit1_o <= instruction_i[31];
			reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
			case(instruction_i[21:30])//check x opcode
				//FixedPoint instructions
				87: begin $display("Load Byte and Zero Indexed");
					reg2ValOrZero_o <= 1;
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= LdStUnitCode;
				end
				119: begin $display("Load Byte and Zero with Update Indexed");
					reg2ValOrZero_o <= 0;
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= LdStUnitCode;
				end
				279: begin $display("Load Halfword and Zero Indexed"); 
					reg2ValOrZero_o <= 1;
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= LdStUnitCode;
				end
				311: begin $display("Load Halfword and Zero with Update Indexed");
					reg2ValOrZero_o <= 0;
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= LdStUnitCode;
				end
				343: begin $display("Load Halfword Algebraic Indexed");
					reg2ValOrZero_o <= 1;			
					enable_o <= 1; stall_o <= 0;
				end
				375: begin $display("Load Halfword Algebraic with Update Indexed");
					reg2ValOrZero_o <= 0;		
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= LdStUnitCode;
				end
				23: begin $display("Load Word and Zero Indexed");
					reg2ValOrZero_o <= 1; 				
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= LdStUnitCode;
				end
				55: begin $display("Load Word and Zero with Update Indexed");
					reg2ValOrZero_o <= 0;			
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= LdStUnitCode;
				end
				341: begin $display("Load Word Algebraic Indexed");
					reg2ValOrZero_o <= 1;			
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= LdStUnitCode;
				end
				373: begin $display("Load Word Algebraic with Update Indexed");
					reg2ValOrZero_o <= 0;					
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= LdStUnitCode;
				end
				21: begin $display("Load Doubleword Indexed");
					reg2ValOrZero_o <= 1;				
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= LdStUnitCode;
				end
				53: begin $display("Load Doubleword with Update Indexed");
					reg2ValOrZero_o <= 0;		
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= LdStUnitCode;
				end
				215: begin $display("Store Byte Indexed");
					reg2ValOrZero_o <= 1; 				
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= LdStUnitCode;
				end
				247: begin $display("Store Byte with Update Indexed");
					reg2ValOrZero_o <= 0;			
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= LdStUnitCode;
				end
				407: begin $display("Store Halfword Indexed");
					reg2ValOrZero_o <= 1;				
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= LdStUnitCode;
				end
				439: begin $display("Store Halfword with Update Indexed");
					reg2ValOrZero_o <= 0;				
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= LdStUnitCode;
				end
				151: begin $display("Store Word Indexed");
					reg2ValOrZero_o <= 1;				
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= LdStUnitCode;
				end
				183: begin $display("Store Word with Update Indexed");
					reg2ValOrZero_o <= 0; 				
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= LdStUnitCode;
				end
				149: begin $display("Store Doubleword Indexed");
					reg2ValOrZero_o <= 1;							
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= LdStUnitCode;
				end
				181: begin $display("Store Doubleword with Update Indexed");
					reg2ValOrZero_o <= 0;			 				
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= LdStUnitCode;
				end
				790: begin $display("Load Halfword Byte-Reverse Indexed");
					reg2ValOrZero_o <= 1;			
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= LdStUnitCode;
				end
				534: begin $display("Load Word Byte-Reverse Indexed");
					reg2ValOrZero_o <= 1;				
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= LdStUnitCode;
				end
				918: begin $display("Store Halfword Byte-Reverse Indexed");
					reg2ValOrZero_o <= 1;			
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= LdStUnitCode;
				end
				662: begin $display("Store Word Byte-Reverse Indexed");
					reg2ValOrZero_o <= 1;			
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= LdStUnitCode;
				end
				532: begin $display("Load Doubleword Byte-Reverse Indexed");
					reg2ValOrZero_o <= 1;		
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= LdStUnitCode;
				end
				660: begin $display("Store Doubleword Byte-Reverse Indexed");
					reg2ValOrZero_o <= 1;			
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= LdStUnitCode;
				end
				597: begin $display("Load String Word Immediate");
					reg2ValOrZero_o <= 1;	 				
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= LdStUnitCode;
				end
				533: begin $display("Load String Word Indexed");
					reg2ValOrZero_o <= 1;				
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= LdStUnitCode;
				end
				725: begin $display("Store String Word Immediate");
					reg2ValOrZero_o <= 1;	
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= LdStUnitCode;
				end
				661: begin $display("Store String Word Indexed");
					reg2ValOrZero_o <= 1;			
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= LdStUnitCode;
				end
				779: begin $display("Modulo Signed Word");
					reg2ValOrZero_o <= 0;			
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FXUnitCode;
				end
				267: begin $display("Modulo Unsigned Word");
					reg2ValOrZero_o <= 0; 				
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FXUnitCode;
				end
				755: begin $display("Deliver A Random Number");
					reg2ValOrZero_o <= 0;				
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FXUnitCode;
				end
				777: begin $display("Modulo Signed Doubleword");
					reg2ValOrZero_o <= 0;		
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FXUnitCode;
				end
				265: begin $display("Modulo Unsigned Doubleword");
					reg2ValOrZero_o <= 0;				
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FXUnitCode;
				end
				0: begin $display("Compare");
					reg2ValOrZero_o <= 0;				
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FXUnitCode;
				end
				32: begin $display("Compare Logical");
					reg2ValOrZero_o <= 0;					
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FXUnitCode;
				end
				192: begin $display("Compare Ranged Byte");
					reg2ValOrZero_o <= 0;					
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FXUnitCode;
				end
				224: begin $display("Compare Equal Byte");
					reg2ValOrZero_o <= 0; 					
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FXUnitCode;
				end
				4: begin $display("Trap Word");
					reg2ValOrZero_o <= 0; 				
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= TrapUnitCode;
				end
				68: begin $display("Trap Doubleword");
					reg2ValOrZero_o <= 0; 					
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= TrapUnitCode;
				end
				28: begin $display("AND");
					reg2ValOrZero_o <= 0;			
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FXUnitCode;
				end
				444: begin $display("OR");
					reg2ValOrZero_o <= 0;				
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FXUnitCode;
				end
				316: begin $display("XOR");
					reg2ValOrZero_o <= 0; 			 				
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FXUnitCode;
				end
				476: begin $display("NAND");
					reg2ValOrZero_o <= 0; 						
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FXUnitCode;
				end
				124: begin $display("NOR");
					reg2ValOrZero_o <= 0; 						
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FXUnitCode;
				end
				284: begin $display("Equivalent");
					reg2ValOrZero_o <= 0; 							
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FXUnitCode;
				end
				60: begin $display("AND with Complement");
					reg2ValOrZero_o <= 0; 			 				
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FXUnitCode;
				end
				412: begin $display("OR with Complement");
					reg2ValOrZero_o <= 0; 			 				
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FXUnitCode;
				end
				954: begin $display("Extend Sign Byte");
					reg2ValOrZero_o <= 0; 							
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FXUnitCode;
				end
				922: begin $display("Extend Sign Halfword");
					reg2ValOrZero_o <= 0; 							
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FXUnitCode;
				end
				26: begin $display("Count Leading Zeros Word");
					reg2ValOrZero_o <= 0; 			 				
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FXUnitCode;
				end
				538: begin $display("Count Trailing Zeros Word");
					reg2ValOrZero_o <= 0; 						
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FXUnitCode;
				end
				508: begin $display("Compare Bytes");
					reg2ValOrZero_o <= 0; 				
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FXUnitCode;
				end
				122: begin $display("Population Count Bytes");
					reg2ValOrZero_o <= 0; 							
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FXUnitCode;
				end
				378: begin $display("Population Count Words");
					reg2ValOrZero_o <= 0; 						
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FXUnitCode;
				end
				186: begin $display("Parity Doubleword");
					reg2ValOrZero_o <= 0; 					
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FXUnitCode;
				end
				154: begin $display("Parity Word");
					reg2ValOrZero_o <= 0; 			 				
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FXUnitCode;
				end
				986: begin $display("Extend Sign Word");
					reg2ValOrZero_o <= 0; 						
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FXUnitCode;
				end
				506: begin $display("Population Count Doubleword");
					reg2ValOrZero_o <= 0; 					
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FXUnitCode;
				end
				58: begin $display("Count Leading Zeros Doubleword");
					reg2ValOrZero_o <= 0; 			 				
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FXUnitCode;
				end
				570: begin $display("Count Trailing Zeros Doubleword");
					reg2ValOrZero_o <= 0; 							
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FXUnitCode;
				end
				252: begin $display("Bit Permute Doubleword");
					reg2ValOrZero_o <= 0; 					
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FXUnitCode;
				end
				24: begin $display("Shift Left Word");
					reg2ValOrZero_o <= 0; 						
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FXUnitCode;	
				end
				536: begin $display("Shift Right Word");
					reg2ValOrZero_o <= 0; 							
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FXUnitCode;
				end
				824: begin $display("Shift Right Algebraic Word Immediate");
					reg2ValOrZero_o <= 0; 			
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FXUnitCode;
				end
				792: begin $display("Shift Right Algebraic Word");
					reg2ValOrZero_o <= 0; 							
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FXUnitCode;
				end
				27: begin $display("Shift Left Doubleword");
					reg2ValOrZero_o <= 0; 						
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FXUnitCode;
				end
				539: begin $display("Shift Right Doubleword");
					reg2ValOrZero_o <= 0; 						
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FXUnitCode;
				end
				794: begin $display("Shift Right Algebraic Doubleword");
					reg2ValOrZero_o <= 0; 						
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FXUnitCode;
				end
				282: begin $display("Convert Declets To Binary Coded Decimal");
					reg2ValOrZero_o <= 0; 						
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FXUnitCode;
				end
				314: begin $display("Convert Binary Coded Decimal To Declets");
					reg2ValOrZero_o <= 0; 			
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FXUnitCode;
				end
				51: begin $display("Move From VSR Doubleword");
					reg2ValOrZero_o <= 0; 			
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FXUnitCode;
				end
				307: begin $display("Move From VSR Lower Doubleword");
					reg2ValOrZero_o <= 0; 			
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FXUnitCode;
				end
				115: begin $display("Move From VSR Lower Doubleword");
					reg2ValOrZero_o <= 0; 			
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FXUnitCode;
				end
				179: begin $display("Move To VSR Doubleword");
					reg2ValOrZero_o <= 0; 			
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FXUnitCode;
				end
				211: begin $display("Move To VSR Word Algebraic");
					reg2ValOrZero_o <= 0; 			
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FXUnitCode;
				end
				243: begin $display("Move To VSR Word and Zero");
					reg2ValOrZero_o <= 0; 				
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FXUnitCode;
				end
				435: begin $display("Move To VSR Double Doubleword");
					reg2ValOrZero_o <= 0; 				
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FXUnitCode;
				end
				403: begin $display("Move To VSR Word & Splat");
					reg2ValOrZero_o <= 0; 			
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FXUnitCode;
				end
				576: begin $display("Move to CR from XER Extended"); 
					reg2ValOrZero_o <= 0; 			
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FXUnitCode;
				end
				128: begin $display("Set Boolean");
					reg2ValOrZero_o <= 0; 			
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FXUnitCode;
				end
				//Floating point instructions. Begin with "Load Floating-Point Single Indexed"
				535: begin $display("Load Floating-Point Single Indexed");
					reg2ValOrZero_o <= 1; 			
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= LdStUnitCode;
				end
				567: begin $display("Load Floating-Point Single with Update Indexed");
					reg2ValOrZero_o <= 0; 			
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= LdStUnitCode;
				end	
				599: begin $display("Load Floating-Point Double Indexed");
					reg2ValOrZero_o <= 1; 			
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= LdStUnitCode;
				end	
				631: begin $display("Load Floating-Point Double with Update Indexed");
					reg2ValOrZero_o <= 0; 			
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= LdStUnitCode;
				end
				887: begin $display("Load Floating-Point as Integer Word and Zero Indexed");
					reg2ValOrZero_o <= 1; 			
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= LdStUnitCode;
				end	
				855: begin $display("Load Floating-Point as Integer Word Algebraic Indexed");
					reg2ValOrZero_o <= 1; 			
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= LdStUnitCode;
				end
				663: begin $display("Store Floating-Point Single Indexed");
					reg2ValOrZero_o <= 1; 			
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= LdStUnitCode;
				end	
				695: begin $display("Store Floating-Point Single with Update Indexed");
					reg2ValOrZero_o <= 0; 			
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= LdStUnitCode;
				end
				727: begin $display("Store Floating-Point Double Indexed");
					reg2ValOrZero_o <= 1; 			
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= LdStUnitCode;
				end	
				759: begin $display("Store Floating-Point Double with Update Indexed");
					reg2ValOrZero_o <= 0; 			
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= LdStUnitCode;
				end
				983: begin $display("Store Floating-Point as Integer Word Indexed");
					reg2ValOrZero_o <= 1; 			
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= LdStUnitCode;
				end	
				791: begin $display("Load Floating-Point Double Pair Indexed");
					reg2ValOrZero_o <= 1; 			
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= LdStUnitCode;
				end
				919: begin $display("Store Floating-Point Double Pair Indexed");
					reg2ValOrZero_o <= 1; 			
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= LdStUnitCode;
				end
			endcase
		end
		else if(instruction_i[0:5] == 63)
		begin
			xOpcode_o <= instruction_i[21:30];
			bit1_o <= instruction_i[30];
			reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
			case(instruction_i[21:30])//check the Xopcode
				72: begin $display("Floating Move Register");
					reg2ValOrZero_o <= 0; 			
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FPUnitCode;
				end
				40: begin $display("Floating Negate");
					reg2ValOrZero_o <= 0; 			
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FPUnitCode;
				end
				264: begin $display("Floating Absolute Value");
					reg2ValOrZero_o <= 0; 			
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FPUnitCode;
				end
				8: begin $display("Floating Copy Sign");
					reg2ValOrZero_o <= 0; 			
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FPUnitCode;
				end
				136: begin $display("Floating Negative Absolute Value");
					reg2ValOrZero_o <= 0; 			
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FPUnitCode;
				end
				966: begin $display("Floating Merge Even Word");
					reg2ValOrZero_o <= 0; 			
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FPUnitCode;
				end
				838: begin $display("Floating Merge Odd Word");
					reg2ValOrZero_o <= 0; 			
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FPUnitCode;
				end
				128: begin $display("Floating Test for software Divide");
					reg2ValOrZero_o <= 0; 			
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FPUnitCode;
				end
				160: begin $display("Floating Test for software Square Root");
					reg2ValOrZero_o <= 0; 			
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FPUnitCode;
				end
				12: begin $display("Floating Round to Single-Precision");
					reg2ValOrZero_o <= 0; 			
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FPUnitCode;
				end
				814: begin $display("Floating Convert with round Double-Precision To Signed Doubleword format");
					reg2ValOrZero_o <= 0; 			
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FPUnitCode;
				end
				815: begin $display("Floating Convert with truncate Double-Precision To Signed Doubleword format");
					reg2ValOrZero_o <= 0; 			
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FPUnitCode;
				end
				942: begin $display("Floating Convert with round Double-Precision To Unsigned Doubleword format");
					reg2ValOrZero_o <= 0;	
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FPUnitCode;
				end
				943: begin $display("Floating Convert with truncate Double-Precision To Unsigned Doubleword format");
					reg2ValOrZero_o <= 0;	
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FPUnitCode;
				end
				14: begin $display("Floating Convert with round Double-Precision To Signed Word format");
					reg2ValOrZero_o <= 0;	
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FPUnitCode;
				end
				15: begin $display("Floating Convert with truncate Double-Precision To Signed Word fomat");
					reg2ValOrZero_o <= 0;	
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FPUnitCode;
				end
				142: begin $display("Floating Convert with round Double-Precision To Unsigned Word format");
					reg2ValOrZero_o <= 0;	
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FPUnitCode;
				end
				143: begin $display("Floating Convert with truncate Double-Precision To Unsigned Word format");
					reg2ValOrZero_o <= 0;	
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FPUnitCode;
				end
				846: begin $display("Floating Convert with round Signed Doubleword to Double-Precision format");//////ERROR IN ISA?
					reg2ValOrZero_o <= 0;	
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FPUnitCode;
				end
				974: begin $display("Floating Convert with round Unsigned Doubleword to Double-Precision format");
					reg2ValOrZero_o <= 0;	
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FPUnitCode;
				end
				846: begin $display("Floating Convert with round Signed Doubleword to Single-Precision format");//////ERROR IN ISA?
					reg2ValOrZero_o <= 0;	
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FPUnitCode;
				end
				392: begin $display("Floating Round to Integer Nearest");
					reg2ValOrZero_o <= 0;	
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FPUnitCode;
				end
				424: begin $display("Floating Round to Integer Toward Zero");
					reg2ValOrZero_o <= 0;	
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FPUnitCode;
				end
				456: begin $display("Floating Round to Integer Plus");
					reg2ValOrZero_o <= 0;	
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FPUnitCode;
				end
				488: begin $display("Floating Round to Integer Minus");
					reg2ValOrZero_o <= 0;	
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FPUnitCode;
				end
				0: begin $display("Floating Compare Unordered");
					reg2ValOrZero_o <= 0;	
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FPUnitCode;
				end
				32: begin $display("Floating Compare Ordered");
					reg2ValOrZero_o <= 0;	
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FPUnitCode;
				end
				///////Move From FPSCR [& Clear Enables | Lightweight | Control [& Set (DRN|RN) [Immediate]]] - page 170
				583: begin $display("Floating Compare Ordered");
					if(instruction_i[6:10])
					reg2ValOrZero_o <= 0;	
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FPUnitCode;
				end
				64: begin $display("Move to Condition Register from FPSCR");
					reg2ValOrZero_o <= 0;	
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FPUnitCode;
				end
				134: begin $display("Move to Condition Register from FPSCR");
					reg2ValOrZero_o <= 0;	
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FPUnitCode;
				end
				70: begin $display("Move To FPSCR Bit 0");
					reg2ValOrZero_o <= 0;	
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FPUnitCode;
				end
				38: begin $display("Move To FPSCR Bit 1");
					reg2ValOrZero_o <= 0;	
					enable_o <= 1; stall_o <= 0;
					functionalUnitCode_o <= FPUnitCode;
				end
				//Decimal floating point
			endcase
		end
		else if(instruction_i[0:5] == 59)
		begin
			xOpcode_o <= instruction_i[21:30];
			bit1_o <= instruction_i[30];
			reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
			case(instruction_i[21:30])//check the Xopcode
				974: begin $display("Floating Convert with round Unsigned Doubleword to Single-Precision format");
					reg2ValOrZero_o <= 0;	
					enable_o <= 1;
					stall_o <= 0;
					functionalUnitCode_o <= FPUnitCode;
				end
			endcase
		end
	end
	else
	begin
		enable_o <= 0;
		stall_o <= 0;
	end
end
endmodule
