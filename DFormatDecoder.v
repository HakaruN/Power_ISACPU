`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//This unit takes in the fetched instruction (in parallel with other decode units) and checks to see if the instruction is a D foramat isntruction
//Supports all D format instructions in the POWER 3.0B ISA
//////////////////////////////////////////////////////////////////////////////////
module DFormatDecoder#(parameter opcodeWidth = 6, parameter regWidth = 5, parameter immWidth = 16, parameter instructionWidth = 32,
parameter signedImm = 1, parameter unsignedImm = 0, parameter regImm = 0, parameter regRead = 1, parameter regWrite = 2, parameter regReadWrite = 3)(
	//command in
	input wire clock_i,
	input wire enable_i,
	//data in
	input wire [0:instructionWidth-1] instruction_i,
	//command out
	output reg stall_o,
	//data out
	output reg [0:regWidth-1] reg1_o, reg2_o,
	output reg [0:1] reg1Use_o, reg2Use_o,//describes the operations to happen to the reg
	output reg reg2ValOrZero_o,//indicates that if the register addr is zero, a zero litteral is to be used not reg zero
	output reg [0:immWidth-1] imm_o,
	output reg immFormat_o,//0 = unsignedImm, 1 = signedImm (sign extended to 64b down the pipe)
	output reg [0:1]shiftImmUpBytes_o,//EG shiftImmUpBytes_o == 2, the extended immediate will be { 32'h0000_0000, immFormat_o, 16'h0000}, if shiftImmUpBytes_o == 4: {immFormat_o, 48'h0000_0000_0000}
	output reg enable_o
	);

always @(posedge clock_i)
begin
	if(enable_i == 1)
	begin
		reg1_o <= instruction_i[6:10]; reg2_o <= instruction_i[11:15];
		imm_o <= instruction_i[16:31];
		case(instruction_i[0:opcodeWidth-1])//switch on the opcode
		//fixed point D format instructions
			34: begin $display("Load Byte and Zero");
				reg2ValOrZero_o <= 1; immFormat_o <= signedImm; shiftImmUpBytes_o <= 0;	
				reg1Use_o <= regWrite; reg2Use_o <= regRead;
				enable_o <= 1; stall_o <= 0;
			end
			35: begin $display("Load Byte and Zero with Update");
				reg2ValOrZero_o <= 0; immFormat_o <= signedImm; shiftImmUpBytes_o <= 0;
				reg1Use_o <= regWrite; reg2Use_o <= regReadWrite;
				enable_o <= 1; stall_o <= 0;
			end
			40: begin $display("Load Halfword and Zero");
				reg2ValOrZero_o <= 1; immFormat_o <= signedImm; shiftImmUpBytes_o <= 0;		
				reg1Use_o <= regWrite; reg2Use_o <= regRead;				
				enable_o <= 1; stall_o <= 0;
			end
			41: begin $display("Load Halfword and Zero with Update");
				reg2ValOrZero_o <= 0; immFormat_o <= signedImm;  shiftImmUpBytes_o <= 0;		
				reg1Use_o <= regWrite; reg2Use_o <= regReadWrite;
				enable_o <= 1; stall_o <= 0;
			end
			42: begin $display("Load Halfword Algebraic");
				reg2ValOrZero_o <= 1; immFormat_o <= signedImm; shiftImmUpBytes_o <= 0;
				reg1Use_o <= regWrite; reg2Use_o <= regRead;	
				enable_o <= 1; stall_o <= 0;
			end
			43: begin $display("Load Halfword Algebraic with Update");
				reg2ValOrZero_o <= 0; immFormat_o <= signedImm; shiftImmUpBytes_o <= 0;
				reg1Use_o <= regWrite; reg2Use_o <= regReadWrite;
				enable_o <= 1; stall_o <= 0;
			end
			32: begin $display("Load Word and Zero");
				reg2ValOrZero_o <= 1; immFormat_o <= signedImm; shiftImmUpBytes_o <= 0;
				reg1Use_o <= regWrite; reg2Use_o <= regRead;	
				enable_o <= 1; stall_o <= 0;
			end
			33: begin $display("Load Word and Zero with Update");
				reg2ValOrZero_o <= 0; immFormat_o <= signedImm; shiftImmUpBytes_o <= 0;
				reg1Use_o <= regWrite; reg2Use_o <= regReadWrite;
				enable_o <= 1; stall_o <= 0;
			end
			38: begin $display("Store Byte");
				reg2ValOrZero_o <= 1; immFormat_o <= signedImm; shiftImmUpBytes_o <= 0;
				reg1Use_o <= regWrite; reg2Use_o <= regRead;
				enable_o <= 1; stall_o <= 0;
			end
			39: begin $display("Store Byte with Update");
				reg2ValOrZero_o <= 0; immFormat_o <= signedImm; shiftImmUpBytes_o <= 0;
				reg1Use_o <= regWrite; reg2Use_o <= regReadWrite;
				enable_o <= 1; stall_o <= 0;
			end
			44: begin $display("Store Halfword");
				reg2ValOrZero_o <= 1; immFormat_o <= signedImm; shiftImmUpBytes_o <= 0;
				reg1Use_o <= regWrite; reg2Use_o <= regRead;
				enable_o <= 1; stall_o <= 0;
			end
			45: begin $display("Store Halfword with Update");
				reg2ValOrZero_o <= 0; immFormat_o <= signedImm; shiftImmUpBytes_o <= 0;
				reg1Use_o <= regWrite; reg2Use_o <= regReadWrite;
				enable_o <= 1; stall_o <= 0;
			end
			36: begin $display("Store Word");
				reg2ValOrZero_o <= 1; immFormat_o <= signedImm; shiftImmUpBytes_o <= 0;
				reg1Use_o <= regWrite; reg2Use_o <= regRead;
				enable_o <= 1; stall_o <= 0;
			end
			37: begin $display("Store Word with Update");
				reg2ValOrZero_o <= 0; immFormat_o <= signedImm; shiftImmUpBytes_o <= 0;
				reg1Use_o <= regWrite; reg2Use_o <= regReadWrite;
				enable_o <= 1; stall_o <= 0;
			end
			46: begin $display("Load Multiple Word");
				reg2ValOrZero_o <= 1; immFormat_o <= signedImm; shiftImmUpBytes_o <= 0;
				reg1Use_o <= regRead; reg2Use_o <= regRead;
				enable_o <= 1; stall_o <= 0;
			end
			47: begin $display("Store Multiple Word");
				reg2ValOrZero_o <= 1; immFormat_o <= signedImm; shiftImmUpBytes_o <= 0;
				reg1Use_o <= regRead; reg2Use_o <= regRead;
				///CANT BE USED IN le MODE! system align-ment error handler is invoked
				enable_o <= 1; stall_o <= 0;
			end
			14: begin $display("Add Immediate");
				reg2ValOrZero_o <= 1; immFormat_o <= signedImm; shiftImmUpBytes_o <= 0;
				reg1Use_o <= regWrite; reg2Use_o <= regRead;
				enable_o <= 1; stall_o <= 0;
			end
			15: begin $display("Add Immediate Shifted");
				reg2ValOrZero_o <= 1; imm_o <= instruction_i[16:31]; immFormat_o <= signedImm; shiftImmUpBytes_o <= 2;
				reg1Use_o <= regWrite; reg2Use_o <= regRead;
				enable_o <= 1; stall_o <= 0;
			end
			12: begin $display("Add Immediate Carrying");
				reg2ValOrZero_o <= 0; immFormat_o <= signedImm; shiftImmUpBytes_o <= 0;
				reg1Use_o <= regWrite; reg2Use_o <= regRead;
				enable_o <= 1; stall_o <= 0;
			end
			13: begin $display("Add Immediate Carrying and Record");
				reg2ValOrZero_o <= 0; immFormat_o <= signedImm; shiftImmUpBytes_o <= 0;
				reg1Use_o <= regWrite; reg2Use_o <= regRead;
				enable_o <= 1; stall_o <= 0;
			end
			8: begin $display("Subtract From Immediate Carrying");
				reg2ValOrZero_o <= 0; immFormat_o <= signedImm; shiftImmUpBytes_o <= 0;
				reg1Use_o <= regWrite; reg2Use_o <= regRead;
				enable_o <= 1; stall_o <= 0;
			end
			7: begin $display("Multiply Low Immediate");
				reg2ValOrZero_o <= 0; immFormat_o <= signedImm; shiftImmUpBytes_o <= 0;
				reg1Use_o <= regWrite; reg2Use_o <= regRead;
				enable_o <= 1; stall_o <= 0;
			end
			11: begin $display("Compare Immediate");
				reg2ValOrZero_o <= 0; immFormat_o <= signedImm; shiftImmUpBytes_o <= 2;
				reg1Use_o <= regImm; reg2Use_o <= regRead;
				enable_o <= 1; stall_o <= 0;
			end
			10: begin $display("Compare Logical Immediate");
				reg2ValOrZero_o <= 0; immFormat_o <= unsignedImm; shiftImmUpBytes_o <= 0;
				reg1Use_o <= regImm; reg2Use_o <= regRead;
				enable_o <= 1; stall_o <= 0;
			end
			3: begin $display("Trap Word Immediate");
				reg2ValOrZero_o <= 0; immFormat_o <= signedImm; shiftImmUpBytes_o <= 0;
				reg1Use_o <= regImm; reg2Use_o <= regRead;
				enable_o <= 1; stall_o <= 0;
			end
			2: begin $display("Trap Doubleword Immediate");
				reg2ValOrZero_o <= 0; immFormat_o <= signedImm; shiftImmUpBytes_o <= 0;
				reg1Use_o <= regImm; reg2Use_o <= regRead;
				enable_o <= 1; stall_o <= 0;
			end
			28: begin $display("AND Immediate");
				reg2ValOrZero_o <= 0; immFormat_o <= unsignedImm; shiftImmUpBytes_o <= 0;
				reg1Use_o <= regRead; reg2Use_o <= regWrite;
				enable_o <= 1; stall_o <= 0;
			end
			29: begin $display("OR Immediate");
				reg2ValOrZero_o <= 0; immFormat_o <= unsignedImm; shiftImmUpBytes_o <= 0;
				reg1Use_o <= regRead; reg2Use_o <= regWrite;
				enable_o <= 1; stall_o <= 0;
			end
			24: begin $display("AND Immediate Shifted");
				reg2ValOrZero_o <= 0; immFormat_o <= unsignedImm; shiftImmUpBytes_o <= 2;
				reg1Use_o <= regRead; reg2Use_o <= regWrite;
				enable_o <= 1; stall_o <= 0;
			end
			25: begin $display("OR Immediate Shifted");
				reg2ValOrZero_o <= 0; immFormat_o <= unsignedImm; shiftImmUpBytes_o <= 2;
				reg1Use_o <= regRead; reg2Use_o <= regWrite;
				enable_o <= 1; stall_o <= 0;
			end
			26: begin $display("XOR Immediat");
				reg2ValOrZero_o <= 0; immFormat_o <= unsignedImm; shiftImmUpBytes_o <= 0;
				reg1Use_o <= regRead; reg2Use_o <= regWrite;
				enable_o <= 1; stall_o <= 0;
			end
			27: begin $display("XOR Immediate Shifted");
				reg2ValOrZero_o <= 0; immFormat_o <= unsignedImm; shiftImmUpBytes_o <= 2;
				reg1Use_o <= regRead; reg2Use_o <= regWrite;
				enable_o <= 1; stall_o <= 0;
			end
		//floating point D format instructions
			48: begin $display("Load Floating-Point Single");
				reg2ValOrZero_o <= 1; immFormat_o <= signedImm; shiftImmUpBytes_o <= 0;
				reg1Use_o <= regWrite; reg2Use_o <= regRead;
				enable_o <= 1; stall_o <= 0;
			end
			49: begin $display("Load Floating-Point Single with Update");
				reg2ValOrZero_o <= 0; immFormat_o <= signedImm; shiftImmUpBytes_o <= 0;
				reg1Use_o <= regWrite; reg2Use_o <= regReadWrite;
				enable_o <= 1; stall_o <= 0;
			end
			50: begin $display("Load Floating-Point Double");
				reg2ValOrZero_o <= 1; immFormat_o <= signedImm; shiftImmUpBytes_o <= 0;
				reg1Use_o <= regWrite; reg2Use_o <= regRead;
				enable_o <= 1; stall_o <= 0;
			end
			51: begin $display("Load Floating-Point Double with Update");
				reg2ValOrZero_o <= 0; immFormat_o <= signedImm; shiftImmUpBytes_o <= 0;
				reg1Use_o <= regWrite; reg2Use_o <= regReadWrite;
				enable_o <= 1; stall_o <= 0;
			end
			
			52	: begin $display("Load Floating-Point Single");
				reg2ValOrZero_o <= 1; immFormat_o <= signedImm; shiftImmUpBytes_o <= 0;
				enable_o <= 1; stall_o <= 0;
			end
			53: begin $display("Store Floating-Point Single with Update");
				reg2ValOrZero_o <= 0; immFormat_o <= signedImm; shiftImmUpBytes_o <= 0;
				enable_o <= 1; stall_o <= 0;
			end
			54: begin $display("Store Floating-Point Double");
				reg2ValOrZero_o <= 1; immFormat_o <= signedImm; shiftImmUpBytes_o <= 0;
				enable_o <= 1; stall_o <= 0;
			end
			55: begin $display("Store Floating-Point Double with Update");
				reg2ValOrZero_o <= 0; immFormat_o <= signedImm; shiftImmUpBytes_o <= 0;
				enable_o <= 1; stall_o <= 0;
			end
			default: begin
				enable_o <= 0;
				reg2ValOrZero_o <= 0;
				immFormat_o <= 0;
				shiftImmUpBytes_o <= 0;			
				stall_o <= 0;
			end
		endcase
	end
	else
	begin
		stall_o <= 0;
		enable_o <= 0;
	end
end


endmodule
