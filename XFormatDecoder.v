`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
module XFormatDecoder#( parameter instructionWidth = 32, parameter addressSize = 64, parameter formatIndexRange = 5,
parameter A = 1, parameter B = 2, parameter D = 3, parameter DQ = 4, parameter DS = 5, parameter DX = 6, parameter I = 7, parameter M = 8,
parameter MD = 9, parameter MDS = 10, parameter SC = 11, parameter VA = 12, parameter VC = 13, parameter VX = 14, parameter X = 15, parameter XFL = 16,
parameter XFX = 17, parameter XL = 18, parameter XO = 19, parameter XS = 20, parameter XX2 = 21, parameter XX3 = 22, parameter XX4 = 23, parameter Z22 = 24,
parameter Z23 = 25, parameter INVALID = 0, parameter unsignedImm = 1, parameter signedImm = 2, parameter signedImmExt = 3,
parameter opcodeWidth = 6, parameter xOpCodeWidth = 10, parameter regWidth = 5, parameter immWidth = 16
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
	output reg [0:63] imm_o,
	output reg bit1_o, bit2_o,
	output reg enable_o
	);
	
always @(posedge clock_i)
begin
	if(enable_i == 1)
	begin
		if(instruction_i[0:5] == 31)//check p opcode
		begin			
			case(instruction_i[21:30])//check x opcode
				//FixedPoint instructions
				87: begin $display("Load Byte and Zero Indexed");
					opcode_o <= instruction_i[0:5];
					xOpcode_o <= instruction_i[21:30];
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 1; imm_o <= 0;		
					bit1_o <= 0; bit2_o <= 0;
					enable_o <= 1;
				end
				119: begin $display("Load Byte and Zero with Update Indexed");
					opcode_o <= instruction_i[0:5];
					xOpcode_o <= instruction_i[21:30];
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0; imm_o <= 0;			
					bit1_o <= 0; bit2_o <= 0;				
					enable_o <= 1;
				end
				279: begin $display("Load Halfword and Zero Indexed");
					opcode_o <= instruction_i[0:5];
					xOpcode_o <= instruction_i[21:30];
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 1; imm_o <= 0;		
					bit1_o <= 0; bit2_o <= 0;					
					enable_o <= 1;
				end
				311: begin $display("Load Halfword and Zero with Update Indexed");
					opcode_o <= instruction_i[0:5];
					xOpcode_o <= instruction_i[21:30];
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0; imm_o <= 0;			
					bit1_o <= 0; bit2_o <= 0;				
					enable_o <= 1;
				end
				343: begin $display("Load Halfword Algebraic Indexed");
					opcode_o <= instruction_i[0:5];
					xOpcode_o <= instruction_i[21:30];
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 1; imm_o <= 0;		
					bit1_o <= 0; bit2_o <= 0;					
					enable_o <= 1;
				end
				375: begin $display("Load Halfword Algebraic with Update Indexed");
					opcode_o <= instruction_i[0:5];
					xOpcode_o <= instruction_i[21:30];
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0; imm_o <= 0;			
					bit1_o <= 0; bit2_o <= 0;				
					enable_o <= 1;
				end
				23: begin $display("Load Word and Zero Indexed");
					opcode_o <= instruction_i[0:5];
					xOpcode_o <= instruction_i[21:30];
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 1; imm_o <= 0;			
					bit1_o <= 0; bit2_o <= 0;				
					enable_o <= 1;
				end
				55: begin $display("Load Word and Zero with Update Indexed");
					opcode_o <= instruction_i[0:5];
					xOpcode_o <= instruction_i[21:30];
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0; imm_o <= 0;			
					bit1_o <= 0; bit2_o <= 0;				
					enable_o <= 1;
				end
				341: begin $display("Load Word Algebraic Indexed");
					opcode_o <= instruction_i[0:5];
					xOpcode_o <= instruction_i[21:30];
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 1; imm_o <= 0;			
					bit1_o <= 0; bit2_o <= 0;				
					enable_o <= 1;
				end
				373: begin $display("Load Word Algebraic with Update Indexed");
					opcode_o <= instruction_i[0:5];
					xOpcode_o <= instruction_i[21:30];
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0; imm_o <= 0;		
					bit1_o <= 0; bit2_o <= 0;					
					enable_o <= 1;
				end
				21: begin $display("Load Doubleword Indexed");
					opcode_o <= instruction_i[0:5];
					xOpcode_o <= instruction_i[21:30];
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 1; imm_o <= 0;			
					bit1_o <= 0; bit2_o <= 0;				
					enable_o <= 1;
				end
				53: begin $display("Load Doubleword with Update Indexed");
					opcode_o <= instruction_i[0:5];
					xOpcode_o <= instruction_i[21:30];
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0; imm_o <= 0;			
					bit1_o <= 0; bit2_o <= 0;				
					enable_o <= 1;
				end
				215: begin $display("Store Byte Indexed");
					opcode_o <= instruction_i[0:5];
					xOpcode_o <= instruction_i[21:30];
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 1; imm_o <= 0;			
					bit1_o <= 0; bit2_o <= 0;				
					enable_o <= 1;
				end
				247: begin $display("Store Byte with Update Indexed");
					opcode_o <= instruction_i[0:5];
					xOpcode_o <= instruction_i[21:30];
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0; imm_o <= 0;			
					bit1_o <= 0; bit2_o <= 0;				
					enable_o <= 1;
				end
				407: begin $display("Store Halfword Indexed");
					opcode_o <= instruction_i[0:5];
					xOpcode_o <= instruction_i[21:30];
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 1; imm_o <= 0;			
					bit1_o <= 0; bit2_o <= 0;				
					enable_o <= 1;
				end
				439: begin $display("Store Halfword with Update Indexed");
					opcode_o <= instruction_i[0:5];
					xOpcode_o <= instruction_i[21:30];
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0; imm_o <= 0;			
					bit1_o <= 0; bit2_o <= 0;				
					enable_o <= 1;
				end
				151: begin $display("Store Word Indexed");
					opcode_o <= instruction_i[0:5];
					xOpcode_o <= instruction_i[21:30];
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 1; imm_o <= 0;			
					bit1_o <= 0; bit2_o <= 0;				
					enable_o <= 1;
				end
				183: begin $display("Store Word with Update Indexed");
					opcode_o <= instruction_i[0:5];
					xOpcode_o <= instruction_i[21:30];
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0; imm_o <= 0;			
					bit1_o <= 0; bit2_o <= 0;				
					enable_o <= 1;
				end
				149: begin $display("Store Doubleword Indexed");
					opcode_o <= instruction_i[0:5];
					xOpcode_o <= instruction_i[21:30];
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 1; imm_o <= 0;			
					bit1_o <= 0; bit2_o <= 0;				
					enable_o <= 1;
				end
				181: begin $display("Store Doubleword with Update Indexed");
					opcode_o <= instruction_i[0:5];
					xOpcode_o <= instruction_i[21:30];
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0; imm_o <= 0;			
					bit1_o <= 0; bit2_o <= 0;				
					enable_o <= 1;
				end
				790: begin $display("Load Halfword Byte-Reverse Indexed");
					opcode_o <= instruction_i[0:5];
					xOpcode_o <= instruction_i[21:30];
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 1; imm_o <= 0;			
					bit1_o <= 0; bit2_o <= 0;				
					enable_o <= 1;
				end
				534: begin $display("Load Word Byte-Reverse Indexed");
					opcode_o <= instruction_i[0:5];
					xOpcode_o <= instruction_i[21:30];
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 1; imm_o <= 0;			
					bit1_o <= 0; bit2_o <= 0;				
					enable_o <= 1;
				end
				918: begin $display("Store Halfword Byte-Reverse Indexed");
					opcode_o <= instruction_i[0:5];
					xOpcode_o <= instruction_i[21:30];
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 1; imm_o <= 0;			
					bit1_o <= 0; bit2_o <= 0;				
					enable_o <= 1;
				end
				662: begin $display("Store Word Byte-Reverse Indexed");
					opcode_o <= instruction_i[0:5];
					xOpcode_o <= instruction_i[21:30];
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 1; imm_o <= 0;				
					bit1_o <= 0; bit2_o <= 0;			
					enable_o <= 1;
				end
				532: begin $display("Load Doubleword Byte-Reverse Indexed");
					opcode_o <= instruction_i[0:5];
					xOpcode_o <= instruction_i[21:30];
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 1; imm_o <= 0;			
					bit1_o <= 0; bit2_o <= 0;				
					enable_o <= 1;
				end
				660: begin $display("Store Doubleword Byte-Reverse Indexed");
					opcode_o <= instruction_i[0:5];
					xOpcode_o <= instruction_i[21:30];
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 1; imm_o <= 0;			
					bit1_o <= 0; bit2_o <= 0;				
					enable_o <= 1;
				end
				597: begin $display("Load String Word Immediate");
					opcode_o <= instruction_i[0:5];
					xOpcode_o <= instruction_i[21:30];
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 1; imm_o <= 0;			
					bit1_o <= 0; bit2_o <= 0;		
					bit1_o <= 0; bit2_o <= 0;				
					enable_o <= 1;
				end
				533: begin $display("Load String Word Indexed");
					opcode_o <= instruction_i[0:5];
					xOpcode_o <= instruction_i[21:30];
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 1; imm_o <= 0;			
					bit1_o <= 0; bit2_o <= 0;				
					enable_o <= 1;
				end
				725: begin $display("Store String Word Immediate");
					opcode_o <= instruction_i[0:5];
					xOpcode_o <= instruction_i[21:30];
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 1; imm_o <= 0;			
					bit1_o <= 0; bit2_o <= 0;				
					enable_o <= 1;
				end
				661: begin $display("Store String Word Indexed");
					opcode_o <= instruction_i[0:5];
					xOpcode_o <= instruction_i[21:30];
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 1; imm_o <= 0;			
					bit1_o <= 0; bit2_o <= 0;				
					enable_o <= 1;
				end
				779: begin $display("Modulo Signed Word");
					opcode_o <= instruction_i[0:5];
					xOpcode_o <= instruction_i[21:30];
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0; imm_o <= 0;			
					bit1_o <= 0; bit2_o <= 0;				
					enable_o <= 1;
				end
				267: begin $display("Modulo Unsigned Word");
					opcode_o <= instruction_i[0:5];
					xOpcode_o <= instruction_i[21:30];
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0; imm_o <= 0;			
					bit1_o <= 0; bit2_o <= 0;				
					enable_o <= 1;
				end
				267: begin $display("Deliver A Random Number");
					opcode_o <= instruction_i[0:5];
					xOpcode_o <= instruction_i[21:30];
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[14:15]; reg3_o <= 0; 
					reg2ValOrZero_o <= 0; imm_o <= 0;		
					bit1_o <= 0; bit2_o <= 0;					
					enable_o <= 1;
				end
				777: begin $display("Modulo Signed Doubleword");
					opcode_o <= instruction_i[0:5];
					xOpcode_o <= instruction_i[21:30];
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0; imm_o <= 0;			
					bit1_o <= 0; bit2_o <= 0;				
					enable_o <= 1;
				end
				265: begin $display("Modulo Unsigned Doubleword");
					opcode_o <= instruction_i[0:5];
					xOpcode_o <= instruction_i[21:30];
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0; imm_o <= 0;			
					bit1_o <= 0; bit2_o <= 0;				
					enable_o <= 1;
				end
				0: begin $display("Compare");
					opcode_o <= instruction_i[0:5];
					xOpcode_o <= instruction_i[21:30];
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0; imm_o <= 0;			
					bit1_o <= 0; bit2_o <= 0;				
					enable_o <= 1;
				end
				32: begin $display("Compare Logical");
					opcode_o <= instruction_i[0:5];
					xOpcode_o <= instruction_i[21:30];
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0; imm_o <= 0;		
					bit1_o <= 0; bit2_o <= 0;					
					enable_o <= 1;
				end
				192: begin $display("Compare Ranged Byte");
					opcode_o <= instruction_i[0:5];
					xOpcode_o <= instruction_i[21:30];
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0; imm_o <= 0;		
					bit1_o <= 0; bit2_o <= 0;					
					enable_o <= 1;
				end
				224: begin $display("Compare Equal Byte");
					opcode_o <= instruction_i[0:5];
					xOpcode_o <= instruction_i[21:30];
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0; imm_o <= 0;		
					bit1_o <= 0; bit2_o <= 0;					
					enable_o <= 1;
				end
				4: begin $display("Trap Word");
					opcode_o <= instruction_i[0:5];
					xOpcode_o <= instruction_i[21:30];
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0; imm_o <= 0;			
					bit1_o <= 0; bit2_o <= 0;				
					enable_o <= 1;
				end
				68: begin $display("Trap Doubleword");
					opcode_o <= instruction_i[0:5];
					xOpcode_o <= instruction_i[21:30];
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0; imm_o <= 0;		
					bit1_o <= 0; bit2_o <= 0;					
					enable_o <= 1;
				end
				28: begin $display("AND");
					opcode_o <= instruction_i[0:5];
					xOpcode_o <= instruction_i[21:30];
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0; imm_o <= 0;			
					bit1_o <= instruction_i[31]; bit2_o <= 0;				
					enable_o <= 1;
				end
				444: begin $display("OR");
					opcode_o <= instruction_i[0:5];
					xOpcode_o <= instruction_i[21:30];
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0; imm_o <= 0;			
					bit1_o <= instruction_i[31]; bit2_o <= 0;				
					enable_o <= 1;
				end
				316: begin $display("XOR");
					opcode_o <= instruction_i[0:5];
					xOpcode_o <= instruction_i[21:30];
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0; imm_o <= 0;			
					bit1_o <= instruction_i[31]; bit2_o <= 0;				
					enable_o <= 1;
				end
				476: begin $display("NAND");
					opcode_o <= instruction_i[0:5];
					xOpcode_o <= instruction_i[21:30];
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0; imm_o <= 0;			
					bit1_o <= instruction_i[31]; bit2_o <= 0;				
					enable_o <= 1;
				end
				124: begin $display("NOR");
					opcode_o <= instruction_i[0:5];
					xOpcode_o <= instruction_i[21:30];
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0; imm_o <= 0;			
					bit1_o <= instruction_i[31]; bit2_o <= 0;				
					enable_o <= 1;
				end
				284: begin $display("Equivalent");
					opcode_o <= instruction_i[0:5];
					xOpcode_o <= instruction_i[21:30];
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0; imm_o <= 0;			
					bit1_o <= instruction_i[31]; bit2_o <= 0;				
					enable_o <= 1;
				end
				60: begin $display("AND with Complement");
					opcode_o <= instruction_i[0:5];
					xOpcode_o <= instruction_i[21:30];
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0; imm_o <= 0;			
					bit1_o <= instruction_i[31]; bit2_o <= 0;				
					enable_o <= 1;
				end
				412: begin $display("OR with Complement");
					opcode_o <= instruction_i[0:5];
					xOpcode_o <= instruction_i[21:30];
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0; imm_o <= 0;			
					bit1_o <= instruction_i[31]; bit2_o <= 0;				
					enable_o <= 1;
				end
				954: begin $display("Extend Sign Byte");
					opcode_o <= instruction_i[0:5];
					xOpcode_o <= instruction_i[21:30];
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= 0; 
					reg2ValOrZero_o <= 0; imm_o <= 0;			
					bit1_o <= instruction_i[31]; bit2_o <= 0;				
					enable_o <= 1;
				end
				922: begin $display("Extend Sign Halfword");
					opcode_o <= instruction_i[0:5];
					xOpcode_o <= instruction_i[21:30];
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= 0; 
					reg2ValOrZero_o <= 0; imm_o <= 0;			
					bit1_o <= instruction_i[31]; bit2_o <= 0;				
					enable_o <= 1;
				end
				26: begin $display("Count Leading Zeros Word");
					opcode_o <= instruction_i[0:5];
					xOpcode_o <= instruction_i[21:30];
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= 0; 
					reg2ValOrZero_o <= 0; imm_o <= 0;			
					bit1_o <= instruction_i[31]; bit2_o <= 0;				
					enable_o <= 1;
				end
				538: begin $display("Count Trailing Zeros Word");
					opcode_o <= instruction_i[0:5];
					xOpcode_o <= instruction_i[21:30];
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= 0; 
					reg2ValOrZero_o <= 0; imm_o <= 0;			
					bit1_o <= instruction_i[31]; bit2_o <= 0;				
					enable_o <= 1;
				end
				508: begin $display("Compare Bytes");
					opcode_o <= instruction_i[0:5];
					xOpcode_o <= instruction_i[21:30];
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0; imm_o <= 0;			
					bit1_o <= 0; bit2_o <= 0;				
					enable_o <= 1;
				end
				122: begin $display("Population Count Bytes");
					opcode_o <= instruction_i[0:5];
					xOpcode_o <= instruction_i[21:30];
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= 0; 
					reg2ValOrZero_o <= 0; imm_o <= 0;			
					bit1_o <= 0; bit2_o <= 0;				
					enable_o <= 1;
				end
				378: begin $display("Population Count Words");
					opcode_o <= instruction_i[0:5];
					xOpcode_o <= instruction_i[21:30];
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= 0; 
					reg2ValOrZero_o <= 0; imm_o <= 0;			
					bit1_o <= 0; bit2_o <= 0;				
					enable_o <= 1;
				end
				186: begin $display("Parity Doubleword");
					opcode_o <= instruction_i[0:5];
					xOpcode_o <= instruction_i[21:30];
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= 0; 
					reg2ValOrZero_o <= 0; imm_o <= 0;			
					bit1_o <= 0; bit2_o <= 0;				
					enable_o <= 1;
				end
				154: begin $display("Parity Word");
					opcode_o <= instruction_i[0:5];
					xOpcode_o <= instruction_i[21:30];
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= 0; 
					reg2ValOrZero_o <= 0; imm_o <= 0;			
					bit1_o <= 0; bit2_o <= 0;				
					enable_o <= 1;
				end
				986: begin $display("Extend Sign Word");
					opcode_o <= instruction_i[0:5];
					xOpcode_o <= instruction_i[21:30];
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= 0; 
					reg2ValOrZero_o <= 0; imm_o <= 0;			
					bit1_o <= instruction_i[31]; bit2_o <= 0;				
					enable_o <= 1;
				end
				506: begin $display("Population Count Doubleword");
					opcode_o <= instruction_i[0:5];
					xOpcode_o <= instruction_i[21:30];
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= 0; 
					reg2ValOrZero_o <= 0; imm_o <= 0;			
					bit1_o <= instruction_i[31]; bit2_o <= 0;				
					enable_o <= 1;
				end
				58: begin $display("Count Leading Zeros Doubleword");
					opcode_o <= instruction_i[0:5];
					xOpcode_o <= instruction_i[21:30];
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= 0; 
					reg2ValOrZero_o <= 0; imm_o <= 0;			
					bit1_o <= instruction_i[31]; bit2_o <= 0;				
					enable_o <= 1;
				end
				570: begin $display("Count Trailing Zeros Doubleword");
					opcode_o <= instruction_i[0:5];
					xOpcode_o <= instruction_i[21:30];
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= 0; 
					reg2ValOrZero_o <= 0; imm_o <= 0;			
					bit1_o <= instruction_i[31]; bit2_o <= 0;				
					enable_o <= 1;
				end
				252: begin $display("Bit Permute Doubleword");
					opcode_o <= instruction_i[0:5];
					xOpcode_o <= instruction_i[21:30];
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0; imm_o <= 0;			
					bit1_o <= 0; bit2_o <= 0;				
					enable_o <= 1;
				end
				24: begin $display("Shift Left Word");
					opcode_o <= instruction_i[0:5];
					xOpcode_o <= instruction_i[21:30];
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0; imm_o <= 0;			
					bit1_o <= instruction_i[31]; bit2_o <= 0;				
					enable_o <= 1;
				end
				536: begin $display("Shift Right Word");
					opcode_o <= instruction_i[0:5];
					xOpcode_o <= instruction_i[21:30];
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0; imm_o <= 0;			
					bit1_o <= instruction_i[31]; bit2_o <= 0;				
					enable_o <= 1;
				end
				824: begin $display("Shift Right Algebraic Word Immediate");
					opcode_o <= instruction_i[0:5];
					xOpcode_o <= instruction_i[21:30];
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0; imm_o <= 0;			
					bit1_o <= instruction_i[31]; bit2_o <= 0;				
					enable_o <= 1;
				end
				792: begin $display("Shift Right Algebraic Word");
					opcode_o <= instruction_i[0:5];
					xOpcode_o <= instruction_i[21:30];
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0; imm_o <= 0;			
					bit1_o <= instruction_i[31]; bit2_o <= 0;				
					enable_o <= 1;
				end
				27: begin $display("Shift Left Doubleword");
					opcode_o <= instruction_i[0:5];
					xOpcode_o <= instruction_i[21:30];
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0; imm_o <= 0;			
					bit1_o <= instruction_i[31]; bit2_o <= 0;				
					enable_o <= 1;
				end
				539: begin $display("Shift Right Doubleword");
					opcode_o <= instruction_i[0:5];
					xOpcode_o <= instruction_i[21:30];
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0; imm_o <= 0;			
					bit1_o <= instruction_i[31]; bit2_o <= 0;				
					enable_o <= 1;
				end
				794: begin $display("Shift Right Algebraic Doubleword");
					opcode_o <= instruction_i[0:5];
					xOpcode_o <= instruction_i[21:30];
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0; imm_o <= 0;			
					bit1_o <= instruction_i[31]; bit2_o <= 0;				
					enable_o <= 1;
				end
				282: begin $display("Convert Declets To Binary Coded Decimal");
					opcode_o <= instruction_i[0:5];
					xOpcode_o <= instruction_i[21:30];
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= 0; 
					reg2ValOrZero_o <= 0; imm_o <= 0;			
					bit1_o <= 0; bit2_o <= 0;				
					enable_o <= 1;
				end
				314: begin $display("Convert Binary Coded Decimal To Declets");
					opcode_o <= instruction_i[0:5];
					xOpcode_o <= instruction_i[21:30];
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= 0; 
					reg2ValOrZero_o <= 0; imm_o <= 0;			
					bit1_o <= 0; bit2_o <= 0;				
					enable_o <= 1;
				end
				51: begin $display("Move From VSR Doubleword");
					opcode_o <= instruction_i[0:5];
					xOpcode_o <= instruction_i[21:30];
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= 0; 
					reg2ValOrZero_o <= 0; imm_o <= 0;			
					bit1_o <= instruction_i[31]; bit2_o <= 0;				
					enable_o <= 1;
				end
				307: begin $display("Move From VSR Lower Doubleword");
					opcode_o <= instruction_i[0:5];
					xOpcode_o <= instruction_i[21:30];
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= 0; 
					reg2ValOrZero_o <= 0; imm_o <= 0;			
					bit1_o <= instruction_i[31]; bit2_o <= 0;				
					enable_o <= 1;
				end
				115: begin $display("Move From VSR Lower Doubleword");
					opcode_o <= instruction_i[0:5];
					xOpcode_o <= instruction_i[21:30];
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= 0; 
					reg2ValOrZero_o <= 0; imm_o <= 0;			
					bit1_o <= instruction_i[31]; bit2_o <= 0;				
					enable_o <= 1;
				end
				179: begin $display("Move To VSR Doubleword");
					opcode_o <= instruction_i[0:5];
					xOpcode_o <= instruction_i[21:30];
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= 0; 
					reg2ValOrZero_o <= 0; imm_o <= 0;			
					bit1_o <= instruction_i[31]; bit2_o <= 0;				
					enable_o <= 1;
				end
				211: begin $display("Move To VSR Word Algebraic");
					opcode_o <= instruction_i[0:5];
					xOpcode_o <= instruction_i[21:30];
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= 0; 
					reg2ValOrZero_o <= 0; imm_o <= 0;			
					bit1_o <= instruction_i[31]; bit2_o <= 0;				
					enable_o <= 1;
				end
				243: begin $display("Move To VSR Word and Zero");
					opcode_o <= instruction_i[0:5];
					xOpcode_o <= instruction_i[21:30];
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= 0; 
					reg2ValOrZero_o <= 0; imm_o <= 0;			
					bit1_o <= instruction_i[31]; bit2_o <= 0;				
					enable_o <= 1;
				end
				435: begin $display("Move To VSR Double Doubleword");
					opcode_o <= instruction_i[0:5];
					xOpcode_o <= instruction_i[21:30];
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0; imm_o <= 0;			
					bit1_o <= instruction_i[31]; bit2_o <= 0;				
					enable_o <= 1;
				end
				403: begin $display("Move To VSR Word & Splat");
					opcode_o <= instruction_i[0:5];
					xOpcode_o <= instruction_i[21:30];
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0; imm_o <= 0;			
					bit1_o <= instruction_i[31]; bit2_o <= 0;				
					enable_o <= 1;
				end
				576: begin $display("Move to CR from XER Extended");
					opcode_o <= instruction_i[0:5];
					xOpcode_o <= instruction_i[21:30];
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0; imm_o <= 0;			
					bit1_o <= instruction_i[31]; bit2_o <= 0;				
					enable_o <= 1;
				end
				128: begin $display("Set Boolean");
					opcode_o <= instruction_i[0:5];
					xOpcode_o <= instruction_i[21:30];
					reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15]; reg3_o <= instruction_i[16:20]; 
					reg2ValOrZero_o <= 0; imm_o <= 0;			
					bit1_o <= instruction_i[31]; bit2_o <= 0;				
					enable_o <= 1;
				end
				//Floating point instructions. Begin with "Load Floating-Point Single Indexed"
			endcase
		end
	end
	else
		enable_o <= 0;
end
endmodule
