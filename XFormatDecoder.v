`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//NOTE: There may be an error in the ISA where there are two instructions both with opcodes 63 and Xopcodes of 846
//These instructions are: Floating Convert with round Signed Doubleword to Double-Precision format and Floating Convert with round Signed Doubleword to Single-Precision format
//////////////////////////////////////////////////////////////////////////////////
module XFormatDecoder#( parameter instructionWidth = 32, parameter addressSize = 64, parameter formatIndexRange = 5,
parameter A = 1, parameter B = 2, parameter D = 3, parameter DQ = 4, parameter DS = 5, parameter DX = 6, parameter I = 7, parameter M = 8,
parameter MD = 9, parameter MDS = 10, parameter SC = 11, parameter VA = 12, parameter VC = 13, parameter VX = 14, parameter X = 15, parameter XFL = 16,
parameter XFX = 17, parameter XL = 18, parameter XO = 19, parameter XS = 20, parameter XX2 = 21, parameter XX3 = 22, parameter XX4 = 23, parameter Z22 = 24,
parameter Z23 = 25, parameter INVALID = 0, parameter unsignedImm = 1, parameter signedImm = 2, parameter signedImmExt = 3,
parameter opcodeWidth = 6, parameter xOpCodeWidth = 10, parameter regWidth = 5
)(
	//command
	input wire clock_i,
	input wire enable_i,
	//data in
	input wire [0:instructionWidth-1] instruction_i,
	input wire [0:addressSize-1] address_i,
	//data out
	output reg [0:opcodeWidth-1] opcode_o,
	output reg [0:xOpCodeWidth-1] xOpcode_o,
	output reg [0:regWidth-1] reg1_o, reg2_o, reg3_o,
	output reg reg2ValOrZero_o,//indicates that if the register addr is zero, a zero litteral is to be used not reg zero
	output reg bit1_o,
	output reg enable_o
	);
	
always @(posedge clock_i)
begin
	if(enable_i == 1)
	begin
		opcode_o <= instruction_i[0:5];
		xOpcode_o <= instruction_i[21:30];
		bit1_o <= instruction_i[30];
		if(instruction_i[0:5] == 31)//check op opcode
		begin
			case(instruction_i[21:30])//check x opcode
				//FixedPoint instructions
				87: begin $display("Load Byte and Zero Indexed");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 1;
					enable_o <= 1;
				end
				119: begin $display("Load Byte and Zero with Update Indexed");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0;
					enable_o <= 1;
				end
				279: begin $display("Load Halfword and Zero Indexed");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 1;
					enable_o <= 1;
				end
				311: begin $display("Load Halfword and Zero with Update Indexed");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0;
					enable_o <= 1;
				end
				343: begin $display("Load Halfword Algebraic Indexed");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 1;			
					enable_o <= 1;
				end
				375: begin $display("Load Halfword Algebraic with Update Indexed");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0;		
					enable_o <= 1;
				end
				23: begin $display("Load Word and Zero Indexed");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 1; 				
					enable_o <= 1;
				end
				55: begin $display("Load Word and Zero with Update Indexed");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0;			
					enable_o <= 1;
				end
				341: begin $display("Load Word Algebraic Indexed");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 1;			
					enable_o <= 1;
				end
				373: begin $display("Load Word Algebraic with Update Indexed");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0;					
					enable_o <= 1;
				end
				21: begin $display("Load Doubleword Indexed");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 1;				
					enable_o <= 1;
				end
				53: begin $display("Load Doubleword with Update Indexed");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0;		
					enable_o <= 1;
				end
				215: begin $display("Store Byte Indexed");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 1; 				
					enable_o <= 1;
				end
				247: begin $display("Store Byte with Update Indexed");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0;			
					enable_o <= 1;
				end
				407: begin $display("Store Halfword Indexed");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 1;				
					enable_o <= 1;
				end
				439: begin $display("Store Halfword with Update Indexed");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0;				
					enable_o <= 1;
				end
				151: begin $display("Store Word Indexed");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 1;				
					enable_o <= 1;
				end
				183: begin $display("Store Word with Update Indexed");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0; 				
					enable_o <= 1;
				end
				149: begin $display("Store Doubleword Indexed");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 1;							
					enable_o <= 1;
				end
				181: begin $display("Store Doubleword with Update Indexed");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0;			 				
					enable_o <= 1;
				end
				790: begin $display("Load Halfword Byte-Reverse Indexed");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 1;			
					enable_o <= 1;
				end
				534: begin $display("Load Word Byte-Reverse Indexed");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 1;				
					enable_o <= 1;
				end
				918: begin $display("Store Halfword Byte-Reverse Indexed");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 1;			
					enable_o <= 1;
				end
				662: begin $display("Store Word Byte-Reverse Indexed");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 1;			
					enable_o <= 1;
				end
				532: begin $display("Load Doubleword Byte-Reverse Indexed");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 1;		
					enable_o <= 1;
				end
				660: begin $display("Store Doubleword Byte-Reverse Indexed");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 1;			
					enable_o <= 1;
				end
				597: begin $display("Load String Word Immediate");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 1;	 				
					enable_o <= 1;
				end
				533: begin $display("Load String Word Indexed");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 1;				
					enable_o <= 1;
				end
				725: begin $display("Store String Word Immediate");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 1;	
					enable_o <= 1;
				end
				661: begin $display("Store String Word Indexed");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 1;			
					enable_o <= 1;
				end
				779: begin $display("Modulo Signed Word");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0;			
					enable_o <= 1;
				end
				267: begin $display("Modulo Unsigned Word");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0; 				
					enable_o <= 1;
				end
				267: begin $display("Deliver A Random Number");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[14:15]; reg3_o <= 0; 
					reg2ValOrZero_o <= 0;				
					enable_o <= 1;
				end
				777: begin $display("Modulo Signed Doubleword");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0;		
					enable_o <= 1;
				end
				265: begin $display("Modulo Unsigned Doubleword");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0;				
					enable_o <= 1;
				end
				0: begin $display("Compare");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0;				
					enable_o <= 1;
				end
				32: begin $display("Compare Logical");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0;					
					enable_o <= 1;
				end
				192: begin $display("Compare Ranged Byte");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0;					
					enable_o <= 1;
				end
				224: begin $display("Compare Equal Byte");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0; 					
					enable_o <= 1;
				end
				4: begin $display("Trap Word");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0; 				
					enable_o <= 1;
				end
				68: begin $display("Trap Doubleword");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0; 					
					enable_o <= 1;
				end
				28: begin $display("AND");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0;			
					enable_o <= 1;
				end
				444: begin $display("OR");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0;				
					enable_o <= 1;
				end
				316: begin $display("XOR");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0; 			 				
					enable_o <= 1;
				end
				476: begin $display("NAND");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0; 						
					enable_o <= 1;
				end
				124: begin $display("NOR");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0; 						
					enable_o <= 1;
				end
				284: begin $display("Equivalent");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0; 							
					enable_o <= 1;
				end
				60: begin $display("AND with Complement");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0; 			 				
					enable_o <= 1;
				end
				412: begin $display("OR with Complement");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0; 			 				
					enable_o <= 1;
				end
				954: begin $display("Extend Sign Byte");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= 0; 
					reg2ValOrZero_o <= 0; 							
					enable_o <= 1;
				end
				922: begin $display("Extend Sign Halfword");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= 0; 
					reg2ValOrZero_o <= 0; 							
					enable_o <= 1;
				end
				26: begin $display("Count Leading Zeros Word");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= 0; 
					reg2ValOrZero_o <= 0; 			 				
					enable_o <= 1;
				end
				538: begin $display("Count Trailing Zeros Word");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= 0; 
					reg2ValOrZero_o <= 0; 						
					enable_o <= 1;
				end
				508: begin $display("Compare Bytes");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0; 				
					enable_o <= 1;
				end
				122: begin $display("Population Count Bytes");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= 0; 
					reg2ValOrZero_o <= 0; 							
					enable_o <= 1;
				end
				378: begin $display("Population Count Words");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= 0; 
					reg2ValOrZero_o <= 0; 						
					enable_o <= 1;
				end
				186: begin $display("Parity Doubleword");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= 0; 
					reg2ValOrZero_o <= 0; 					
					enable_o <= 1;
				end
				154: begin $display("Parity Word");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= 0; 
					reg2ValOrZero_o <= 0; 			 				
					enable_o <= 1;
				end
				986: begin $display("Extend Sign Word");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= 0; 
					reg2ValOrZero_o <= 0; 						
					enable_o <= 1;
				end
				506: begin $display("Population Count Doubleword");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= 0; 
					reg2ValOrZero_o <= 0; 					
					enable_o <= 1;
				end
				58: begin $display("Count Leading Zeros Doubleword");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= 0; 
					reg2ValOrZero_o <= 0; 			 				
					enable_o <= 1;
				end
				570: begin $display("Count Trailing Zeros Doubleword");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= 0; 
					reg2ValOrZero_o <= 0; 							
					enable_o <= 1;
				end
				252: begin $display("Bit Permute Doubleword");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0; 					
					enable_o <= 1;
				end
				24: begin $display("Shift Left Word");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0; 						
					enable_o <= 1;
				end
				536: begin $display("Shift Right Word");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0; 							
					enable_o <= 1;
				end
				824: begin $display("Shift Right Algebraic Word Immediate");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0; 			
					enable_o <= 1;
				end
				792: begin $display("Shift Right Algebraic Word");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0; 							
					enable_o <= 1;
				end
				27: begin $display("Shift Left Doubleword");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0; 						
					enable_o <= 1;
				end
				539: begin $display("Shift Right Doubleword");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0; 						
					enable_o <= 1;
				end
				794: begin $display("Shift Right Algebraic Doubleword");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0; 						
					enable_o <= 1;
				end
				282: begin $display("Convert Declets To Binary Coded Decimal");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= 0; 
					reg2ValOrZero_o <= 0; 						
					enable_o <= 1;
				end
				314: begin $display("Convert Binary Coded Decimal To Declets");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= 0; 
					reg2ValOrZero_o <= 0; 			
					enable_o <= 1;
				end
				51: begin $display("Move From VSR Doubleword");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= 0; 
					reg2ValOrZero_o <= 0; 			
					enable_o <= 1;
				end
				307: begin $display("Move From VSR Lower Doubleword");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= 0; 
					reg2ValOrZero_o <= 0; 			
					enable_o <= 1;
				end
				115: begin $display("Move From VSR Lower Doubleword");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= 0; 
					reg2ValOrZero_o <= 0; 			
					enable_o <= 1;
				end
				179: begin $display("Move To VSR Doubleword");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= 0; 
					reg2ValOrZero_o <= 0; 			
					enable_o <= 1;
				end
				211: begin $display("Move To VSR Word Algebraic");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= 0; 
					reg2ValOrZero_o <= 0; 			
					enable_o <= 1;
				end
				243: begin $display("Move To VSR Word and Zero");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= 0; 
					reg2ValOrZero_o <= 0; 				
					enable_o <= 1;
				end
				435: begin $display("Move To VSR Double Doubleword");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0; 				
					enable_o <= 1;
				end
				403: begin $display("Move To VSR Word & Splat");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0; 			
					enable_o <= 1;
				end
				576: begin $display("Move to CR from XER Extended");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0; 			
					enable_o <= 1;
				end
				128: begin $display("Set Boolean");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0; 			
					enable_o <= 1;
				end
				//Floating point instructions. Begin with "Load Floating-Point Single Indexed"
				535: begin $display("Load Floating-Point Single Indexed");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 1; 			
					enable_o <= 1;
				end
				567: begin $display("Load Floating-Point Single with Update Indexed");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0; 			
					enable_o <= 1;
				end	
				599: begin $display("Load Floating-Point Double Indexed");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 1; 			
					enable_o <= 1;
				end	
				631: begin $display("Load Floating-Point Double with Update Indexed");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0; 			
					enable_o <= 1;
				end
				887: begin $display("Load Floating-Point as Integer Word and Zero Indexed");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 1; 			
					enable_o <= 1;
				end	
				855: begin $display("Load Floating-Point as Integer Word Algebraic Indexed");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 1; 			
					enable_o <= 1;
				end
				663: begin $display("Store Floating-Point Single Indexed");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 1; 			
					enable_o <= 1;
				end	
				695: begin $display("Store Floating-Point Single with Update Indexed");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0; 			
					enable_o <= 1;
				end
				727: begin $display("Store Floating-Point Double Indexed");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 1; 			
					enable_o <= 1;
				end	
				759: begin $display("Store Floating-Point Double with Update Indexed");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0; 			
					enable_o <= 1;
				end
				983: begin $display("Store Floating-Point as Integer Word Indexed");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 1; 			
					enable_o <= 1;
				end	
				791: begin $display("Load Floating-Point Double Pair Indexed");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 1; 			
					enable_o <= 1;
				end
				919: begin $display("Store Floating-Point Double Pair Indexed");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 1; 			
					enable_o <= 1;
				end
			endcase
		end
		else if(instruction_i[0:5] == 63)
		begin
			case
				72: begin $display("Floating Move Register");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0; 			
					enable_o <= 1;
				end
				40: begin $display("Floating Negate");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0; 			
					enable_o <= 1;
				end
				264: begin $display("Floating Absolute Value");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0; 			
					enable_o <= 1;
				end
				8: begin $display("Floating Copy Sign");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0; 			
					enable_o <= 1;
				end
				136: begin $display("Floating Negative Absolute Value");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0; 			
					enable_o <= 1;
				end
				966: begin $display("Floating Merge Even Word");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0; 			
					enable_o <= 1;
				end
				838: begin $display("Floating Merge Odd Word");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0; 			
					enable_o <= 1;
				end
				128: begin $display("Floating Test for software Divide");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0; 			
					enable_o <= 1;
				end
				160: begin $display("Floating Test for software Square Root");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0; 			
					enable_o <= 1;
				end
				12: begin $display("Floating Round to Single-Precision");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0; 			
					enable_o <= 1;
				end
				814: begin $display("Floating Convert with round Double-Precision To Signed Doubleword format");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0; 			
					enable_o <= 1;
				end
				815: begin $display("Floating Convert with truncate Double-Precision To Signed Doubleword format");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0; 			
					enable_o <= 1;
				end
				942: begin $display("Floating Convert with round Double-Precision To Unsigned Doubleword format");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0;	
					enable_o <= 1;
				end
				943: begin $display("Floating Convert with truncate Double-Precision To Unsigned Doubleword format");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0;	
					enable_o <= 1;
				end
				14: begin $display("Floating Convert with round Double-Precision To Signed Word format");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0;	
					enable_o <= 1;
				end
				15: begin $display("Floating Convert with truncate Double-Precision To Signed Word fomat");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0;	
					enable_o <= 1;
				end
				142: begin $display("Floating Convert with round Double-Precision To Unsigned Word format");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0;	
					enable_o <= 1;
				end
				143: begin $display("Floating Convert with truncate Double-Precision To Unsigned Word format");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0;	
					enable_o <= 1;
				end
				846: begin $display("Floating Convert with round Signed Doubleword to Double-Precision format");//////ERROR IN ISA?
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0;	
					enable_o <= 1;
				end
				974: begin $display("Floating Convert with round Unsigned Doubleword to Double-Precision format");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0;	
					enable_o <= 1;
				end
				846: begin $display("Floating Convert with round Signed Doubleword to Single-Precision format");//////ERROR IN ISA?
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0;	
					enable_o <= 1;
				end
				974: begin $display("Floating Convert with round Unsigned Doubleword to Single-Precision format");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0;	
					enable_o <= 1;
				end
				392: begin $display("Floating Round to Integer Nearest");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0;	
					enable_o <= 1;
				end
				424: begin $display("Floating Round to Integer Toward Zero");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0;	
					enable_o <= 1;
				end
				456: begin $display("Floating Round to Integer Plus");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0;	
					enable_o <= 1;
				end
				488: begin $display("Floating Round to Integer Minus");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0;	
					enable_o <= 1;
				end
				0: begin $display("Floating Compare Unordered");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0;	
					enable_o <= 1;
				end
				32: begin $display("Floating Compare Ordered");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0;	
					enable_o <= 1;
				end
				///////Move From FPSCR [& Clear Enables | Lightweight | Control [& Set (DRN|RN) [Immediate]]] - page 170
				583: begin $display("Floating Compare Ordered");
					if(instruction_i[6:10])
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0;	
					enable_o <= 1;
				end
				64: begin $display("Move to Condition Register from FPSCR");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0;	
					enable_o <= 1;
				end
				134: begin $display("Move to Condition Register from FPSCR");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0;	
					enable_o <= 1;
				end
				70: begin $display("Move To FPSCR Bit 0");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0;	
					enable_o <= 1;
				end
				38: begin $display("Move To FPSCR Bit 1");
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0;	
					enable_o <= 1;
				end
				//Decimal floating point
			endcase
		end
	end
	else
		enable_o <= 0;
end
endmodule
