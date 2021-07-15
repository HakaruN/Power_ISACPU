`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//NOTE: Reg unit is inadequetly tested, testing needs to ensure RAW hazards are avoided
//////////////////////////////////////////////////////////////////////////////////
module RegisterUnit #(parameter instructionWidth = 32, parameter addressSize = 64,
parameter opcodeWidth = 6, parameter xOpCodeWidth = 10, parameter immWith = 16, parameter regWidth = 5, parameter numRegs = 2**regWidth, parameter formatIndexRange = 5,
parameter regImm = 0, parameter regRead = 1, parameter regWrite = 2, parameter regReadWrite = 3,//indicates if a registers use is immediate, read, write or both
parameter A = 1, parameter B = 2, parameter D = 3, parameter DQ = 4, parameter DS = 5, parameter DX = 6, parameter I = 7, parameter M = 8,
parameter MD = 9, parameter MDS = 10, parameter SC = 11, parameter VA = 12, parameter VC = 13, parameter VX = 14, parameter X = 15, parameter XFL = 16,
parameter XFX = 17, parameter XL = 18, parameter XO = 19, parameter XS = 20, parameter XX2 = 21, parameter XX3 = 22, parameter XX4 = 23, parameter Z22 = 24,
parameter Z23 = 25, parameter INVALID = 0 )(
	//command in
	input wire clock_i,
	input wire reset_i,
	//data in (reg read)
	input wire enable_i,
	input wire [0:immWith-1] imm_i,
	input wire [0:regWidth-1] reg1_i, reg2_i, reg3_i,
	input wire bit1_i, bit2_i,
	input wire immEnable_i, reg1Enable_i, reg2Enable_i, reg3Enable_i, bit1Enable_i, bit2Enable_i,
	input wire [0:1] reg1Use_i, reg2Use_i, reg3Use_i,
	input wire reg3IsImmediate_i,
	input wire reg2ValOrZero_i,
	input wire [0:addressSize-1] instructionAddress_i,
	input wire [0:opcodeWidth-1] opCode_i,
	input wire [0:xOpCodeWidth-1] xOpcode_i,
	input wire xOpCodeEnabled_i,
	input wire [0:1] functionalUnitCode_i,
	input wire [0:formatIndexRange-1] instructionFormat_i,
	//data in (reg writeback)
	input wire [0:addressSize-1] reg1WritebackData_i, reg2WritebackData_i,
	input wire reg1isWriteback_i, reg2isWriteback_i,
	input wire [0:regWidth-1] reg1WritebackAddress_i, reg2WritebackAddress_i,
	//command out
	output reg stall_o,
	//data out (reg read)
	output reg enable_o,
	output reg [0:63] operand1_o, operand2_o, operand3_o,
	output reg [0:regWidth-1] reg1Address_o, reg2Address_o, reg3Address_o,
	output reg [0:immWith-1] imm_o,
	output reg immEnable_o,
	output reg bit1_o, bit2_o,
	output reg operand1Enable_o, operand2Enable_o, operand3Enable_o, bit1Enable_o, bit2Enable_o,
	output reg operand1Writeback_o, operand2Writeback_o, operand3Writeback_o,
	output reg [0:63] instructionAddress_o,
	output reg [0:opcodeWidth-1] opCode_o,
	output reg [0:xOpCodeWidth-1] xOpCode_o,
	output reg xOpCodeEnabled_o,
	output reg [0:1] functionalUnitCode_o,
	output reg [0:formatIndexRange-1] instructionFormat_o
	);
	integer i;
	//an entry for each register, if a register is pendint writeback it's entry is set to 1. If an entry is set to 1 it cannot be read and must be stalled
	reg isRegPendingWriteback [0:31];
	//reg file
	reg [0:63] regFile [0:numRegs-1];
	
	always @(posedge clock_i)//negedge of clock reads
	begin
		if(reset_i == 1)
		begin
			stall_o <= 0;
			for(i = 0; i < numRegs; i = i + 1)//reset all registers to not pending a writeback
			begin
				isRegPendingWriteback[i] <= 0;
				regFile[i] <= 0;
			end
			$display("Resetting reg file");
		end
		//perform reg reads
		else if(enable_i == 1)
		begin
			$display("Reg read");
			$display("Reading reg's %d, %d, %d", reg1_i, reg2_i, reg3_i);
			$display("isPending writeback: %d, %d, %d", isRegPendingWriteback[reg1_i], isRegPendingWriteback[reg2_i], isRegPendingWriteback[reg3_i]);
			$display("reg's use: %d, %d, %d (regImm = 0, regRead = 1, regWrite = 2, regReadWrite = 3)",reg1Use_i, reg2Use_i, reg3Use_i);
				
			//if any registers are pending a writeback, we must stall and can't enable the outputs until the registers are available to read from
			if(isRegPendingWriteback[reg1_i] == 1 || isRegPendingWriteback[reg2_i] == 1 || isRegPendingWriteback[reg3_i] == 1)
			begin
				enable_o <= 0;
				stall_o <= 1;
				$display("Reg pending writeback collision");
			end
			else
			begin
				enable_o <= 1;
				stall_o <= 0;			
			
				if(bit1Enable_i)//output bits
				begin
					bit1_o <= bit1_i; bit1Enable_o <= 1;
				end
				else
					bit1Enable_o <= 0;
					
				if(bit2Enable_i)
				begin
					bit2_o <= bit2_i; bit2Enable_o <= 1;
				end
				else
					bit2Enable_o <= 0;
					
				//pass through instruction data
				opCode_o <= opCode_i;
				xOpCode_o <= xOpcode_i;
				xOpCodeEnabled_o <= xOpCodeEnabled_i;
				instructionFormat_o <= instructionFormat_i;
				instructionAddress_o <= instructionAddress_i;
				functionalUnitCode_o <= functionalUnitCode_i;
				//pass through imm value
				if(immEnable_i == 1)
				begin
					imm_o <= imm_i;
					immEnable_o <= 1;
				end
				else
					immEnable_o <= 0;
				
				//resolve register reads
				//Imm = 0, Read = 1, Write = 2, Read/Write = 3
				if(reg1Enable_i == 1)
				begin
					case(reg1Use_i)
						0:begin operand1_o <= reg1_i; operand1Enable_o <= 1; operand1Writeback_o <= 0; end//reg = imm
						1:begin operand1_o <= regFile[reg1_i]; operand1Enable_o <= 1; operand1Writeback_o <= 0; end//reg = read
						2:begin operand1_o <= reg1_i; operand1Enable_o <= 1; operand1Writeback_o <= 1; reg1Address_o <= reg1_i; isRegPendingWriteback[reg1_i] <= 1; end//reg = write
						3:begin operand1_o <= regFile[reg1_i]; operand1Enable_o <= 1; operand1Writeback_o <= 1; reg1Address_o <= reg1_i; isRegPendingWriteback[reg1_i] <= 1; end//reg = read/write
					endcase
					operand1Enable_o <= 1;
				end
				else
				begin
					operand1Enable_o <= 0;
				end
					
				if(reg2Enable_i == 1)
				begin
					$display("Reg 2 enabled");
					if(reg2ValOrZero_i == 1)
					begin
						$display("reg2ValorZero = 1");
						if(reg2_i == 0)//reg2 val or zero == 1 and reg2 == 0
						begin
							$display("Reg 2 is zero");
							operand2_o <= 0;	
								case(reg2Use_i)
									0:begin operand2_o <=0; operand2Enable_o <= 1; operand2Writeback_o <= 0; end//reg = imm
									1:begin operand2_o <= 0; operand2Enable_o <= 1; operand2Writeback_o <= 0; end//reg = read
									2:begin operand2_o <= 0; operand2Enable_o <= 1; operand2Writeback_o <= 1; reg2Address_o <= reg2_i; isRegPendingWriteback[reg2_i] <= 1; end//reg = write
									3:begin operand2_o <= 0; operand2Enable_o <= 1; operand2Writeback_o <= 1; reg2Address_o <= reg2_i; isRegPendingWriteback[reg2_i] <= 1; end//reg = read/write
								endcase						
						end
						else//reg2 val or zero == 1 and reg2 != 0
						begin
							$display("Reg 2 is not zero");
							case(reg2Use_i)
								0:begin operand2_o <= reg2_i; operand2Enable_o <= 1; operand2Writeback_o <= 0; end//reg = imm
								1:begin operand2_o <= regFile[reg2_i]; operand2Enable_o <= 1; operand2Writeback_o <= 0; end//reg = read
								2:begin operand2_o <= reg2_i; operand2Enable_o <= 1; operand2Writeback_o <= 1; reg2Address_o <= reg2_i; isRegPendingWriteback[reg2_i] <= 1; end//reg = write
								3:begin operand2_o <= regFile[reg2_i]; operand2Enable_o <= 1; operand2Writeback_o <= 1; reg2Address_o <= reg2_i; isRegPendingWriteback[reg2_i] <= 1; end//reg = read/write
							endcase						
						end
					end
					else
					begin//reg2 val or zero == 0
						$display("reg2ValorZero = 0");
						case(reg2Use_i)
							0:begin operand2_o <= reg2_i; operand2Enable_o <= 1; operand2Writeback_o <= 0; end//reg = imm
							1:begin operand2_o <= regFile[reg2_i]; operand2Enable_o <= 1; operand2Writeback_o <= 0; end//reg = read
							2:begin operand2_o <= reg2_i; operand2Enable_o <= 1; operand2Writeback_o <= 1; reg2Address_o <= reg2_i; isRegPendingWriteback[reg2_i] <= 1; end//reg = write
							3:begin operand2_o <= regFile[reg2_i]; operand2Enable_o <= 1; operand2Writeback_o <= 1; reg2Address_o <= reg2_i; isRegPendingWriteback[reg2_i] <= 1; end//reg = read/write
						endcase
					end
					operand2Enable_o <= 1;
				end
				else
				begin
					operand2Enable_o <= 0;
					$display("reg2 disabled");
				end
				
				if(reg3Enable_i == 1)
				begin
					if(reg3IsImmediate_i == 1)
					begin
						case(reg3Use_i)
							0:begin operand3_o <= reg3_i; operand3Enable_o <= 1; operand3Writeback_o <= 0; end//reg = imm
							1:begin operand3_o <= reg3_i; operand3Enable_o <= 1; operand3Writeback_o <= 0; end//reg = read
							2:begin operand3_o <= reg3_i; operand3Enable_o <= 1; operand3Writeback_o <= 1; reg3Address_o <= reg3_i; isRegPendingWriteback[reg3_i] <= 1; end//reg = write
							3:begin operand3_o <= reg3_i; operand3Enable_o <= 1; operand3Writeback_o <= 1; reg3Address_o <= reg3_i; isRegPendingWriteback[reg3_i] <= 1; end//reg = read/write
						endcase
					end
					else
					begin
						case(reg3Use_i)
							0:begin operand3_o <= reg3_i; operand3Enable_o <= 1; operand3Writeback_o <= 0; end//reg = imm
							1:begin operand3_o <= regFile[reg3_i]; operand3Enable_o <= 1; operand3Writeback_o <= 0; end//reg = read
							2:begin operand3_o <= reg3_i; operand3Enable_o <= 1; operand3Writeback_o <= 1; reg3Address_o <= reg3_i; isRegPendingWriteback[reg3_i] <= 1; end//reg = write
							3:begin operand3_o <= regFile[reg3_i]; operand3Enable_o <= 1; operand3Writeback_o <= 1; reg3Address_o <= reg3_i; isRegPendingWriteback[reg3_i] <= 1; end//reg = read/write
						endcase

					end
					operand3Enable_o <= 1;
				end
				else
					operand3Enable_o <= 0;
				end
		end
		else
			enable_o <= 0;
			
		if(reset_i == 0)
		begin		
			//perform reg writebacks
			if(reg1isWriteback_i == 1)
			begin
				$display("reg 1 writeback. Writing %d to reg %d", reg1WritebackData_i, reg1WritebackAddress_i);
				regFile[reg1WritebackAddress_i] <= reg1WritebackData_i;
				isRegPendingWriteback[reg1WritebackAddress_i] <= 0;//reset the iswritebackpending flag for the register
			end
			
			if(reg2isWriteback_i == 1)
			begin
				$display("reg 2 writeback. Writing %d to reg %d", reg2WritebackData_i, reg2WritebackAddress_i);
				regFile[reg2WritebackAddress_i] <= reg2WritebackData_i;
				isRegPendingWriteback[reg2WritebackAddress_i] <= 0;
			end
		end
	end
	
	
endmodule
