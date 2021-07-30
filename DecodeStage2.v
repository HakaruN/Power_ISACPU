`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//Takes the outputs of the parallel decoders and multiplexes the instruction to a single bus
//////////////////////////////////////////////////////////////////////////////////
module DecodeStage2 #(parameter opcodeWidth = 6, parameter regWidth = 5, parameter addressSize = 64,
	parameter DImmWidth = 16, parameter DQimmWidth = 12, parameter DSimmWidth = 14, parameter MDimmWidth = 6, parameter immWidth = 24,
	parameter XxoOpcodeWidth = 10, parameter XoOpCodeWidth = 9,
	//instrcution format
	parameter formatIndexRange = 5,
	parameter A = 1, parameter B = 2, parameter D = 3, parameter DQ = 4, parameter DS = 5, parameter DX = 6, parameter I = 7, parameter M = 8,
	parameter MD = 9, parameter MDS = 10, parameter SC = 11, parameter VA = 12, parameter VC = 13, parameter VX = 14, parameter X = 15, parameter XFL = 16,
	parameter XFX = 17, parameter XL = 18, parameter XO = 19, parameter XS = 20, parameter XX2 = 21, parameter XX3 = 22, parameter XX4 = 23, parameter Z22 = 24,
	parameter Z23 = 25, parameter INVALID = 0)(
	//command
	input wire clock_i,
	input wire [0:addressSize-1] instructionAddress_i,
	input wire [0:opcodeWidth-1] opcode_i,
	//D input
	input wire dEnable_i,
	input wire [0:regWidth-1] dReg1_i, dReg2_i,
	input wire [0:1] dreg1Use_i, dreg2Use_i,
	input wire [0:DImmWidth-1] dImm_i,
	input wire dimmFormat2_i,
	input wire dReg2ValOrZero_i,
	input wire [0:2] dfunctionalUnitCode_i,
	input wire [0:1] dImmShiftUpBytes_i,
	//DQ input
	input wire dQEnable_i,
	input wire [0:regWidth-1] dQReg1_i, dQReg2_i,
	input wire [0:1] dQreg1Use_i, dQreg2Use_i,
	input wire [0:DQimmWidth-1] dQImm_i,
	input wire [0:2] dQfunctionalUnitCode_i,
	input wire dQBit_i,
	//DS input
	input wire dSEnable_i,
	input wire [0:regWidth-1] dSReg1_i, dSReg2_i,
	input wire [0:DSimmWidth-1] dSImm_i,
	input wire [0:2] dSfunctionalUnitCode_i,
	input wire dSReg2ValOrZero_i,
	//X input
	input wire xEnable_i,
	input wire [0:regWidth-1] xReg1_i, xReg2_i, xReg3_i,
	input wire xBit1_i,
	input wire xReg2ValOrZero_i,
	input wire [0:2] xfunctionalUnitCode_i,
	input wire [0:XxoOpcodeWidth-1] xXopcode_i,
	//MD input
	input wire mDEnable_i,
	input wire [0:regWidth-1] mDReg1_i, mDReg2_i, mDReg3_i,
	input wire [0:MDimmWidth-1] mDImm_i,
	input wire [0:2] mDfunctionalUnitCode_i,
	input wire mDBit1_i, mDBit2_i,
	//XO input
	input wire xOEnable_i,
	input wire [0:regWidth-1] xOReg1_i, xOReg2_i, xOReg3_i,
	input wire [0:XoOpCodeWidth-1] xOopcode_i,
	input wire [0:2] xOfunctionalUnitCode_i,
	input wire xOit1_i, xOBit2_i,	
	//outputs 
	output reg enable_o,
	output reg [0:immWidth-1] imm_o,//use DImmWidth as the width as this is the largest imm format posible in this ISA version
	output reg immEnable_o,
	output reg [0:regWidth-1] reg1_o, reg2_o, reg3_o,
	output reg [0:1] reg1Use_o, reg2Use_o, reg3Use_o,
	output reg reg1Enable_o, reg2Enable_o, reg3Enable_o,
	output reg reg3IsImmediate_o,
	output reg bit1_o, bit2_o,
	output reg bit1Enable_o, bit2Enable_o,
	output reg reg2ValOrZero,
	output reg [0:63] instructionAddress_o,
	output reg [0:opcodeWidth-1]opcode_o,
	output reg [0:XxoOpcodeWidth-1]xOpcode_o,
	output reg xOpcodeEnable_o,
	output reg [0:2] functionalUnitCode_o,
	output reg [0:formatIndexRange-1] instructionFormat_o
    );

	always @(posedge clock_i)
	begin
		opcode_o <= opcode_i;
		instructionAddress_o <= instructionAddress_i;
		if(dEnable_i == 1)
		begin
			$display("Muxing D instruction");
			//control
			enable_o <= 1;
			instructionFormat_o <= D;
			xOpcodeEnable_o <= 0;
			//reg
			reg1_o <= dReg1_i; reg2_o <= dReg2_i;
			reg1Enable_o <= 1; reg2Enable_o <= 1; reg3Enable_o <= 0;
			reg2ValOrZero <= dReg2ValOrZero_i; reg3IsImmediate_o <= 0;
			functionalUnitCode_o <= dfunctionalUnitCode_i;
			reg1Use_o <= dreg1Use_i; reg2Use_o <= dreg2Use_i; reg3Use_o<= 0;
			//imm
			immEnable_o <= 1;
			if(dimmFormat2_i == 1)
			begin
				case(dImmShiftUpBytes_i)
					0:imm_o <= $signed({dImm_i});
					1:imm_o <= $signed({dImm_i, 8'h00});
					2:imm_o <= $signed({dImm_i, 16'h0000});
					3:imm_o <= $signed({dImm_i, 32'h0000_0000});
				endcase
			end
			else
			begin
				case(dImmShiftUpBytes_i)
					0:imm_o <= {dImm_i};
					1:imm_o <= {dImm_i, 8'h00};
					2:imm_o <= {dImm_i, 16'h0000};
					3:imm_o <= {dImm_i, 32'h0000_0000};
				endcase
			end
			//bits
			bit1Enable_o <= 0; bit2Enable_o <= 0;
		end
		
		else if(dQEnable_i == 1)//All dq instructions are implicitly reg2ValOrZero=1 and imm shift up 4 bits
		begin
			$display("Muxing DQ instruction");
			//control
			enable_o <= 1;
			instructionFormat_o <= DQ;
			xOpcodeEnable_o <= 0;
			//reg
			reg1_o <= dQReg1_i; reg2_o <= dQReg2_i;
			reg1Use_o <= dQreg1Use_i; reg2Use_o <= dQreg2Use_i; reg3Use_o<= 0;
			reg1Enable_o <= 1; reg2Enable_o <= 1; reg3Enable_o <= 0;
			reg2ValOrZero <= 1; reg3IsImmediate_o <= 0;
			//imm
			immEnable_o <= 1;
			imm_o <= $signed({dQImm_i, 4'b0000});
			//bits
			bit1_o <= dQBit_i;
			bit1Enable_o <= 1; bit2Enable_o <= 0;	
			//functional unit code
			functionalUnitCode_o <= dQfunctionalUnitCode_i;
		end
		
		else if(dSEnable_i == 1)
		begin
			$display("Muxing DS instruction");
			//control
			enable_o <= 1;
			instructionFormat_o <= DS;
			xOpcodeEnable_o <= 0;
			//reg
			reg1_o <= dSReg1_i; reg2_o <= dSReg2_i;
			reg1Enable_o <= 1; reg2Enable_o <= 1; reg3Enable_o <= 0;
			reg2ValOrZero <= dSReg2ValOrZero_i; reg3IsImmediate_o <= 0;
			//imm
			immEnable_o <= 1;
			imm_o <= $signed({dSImm_i, 2'b00});
			//bits
			bit1_o <= dQBit_i;
			bit1Enable_o <= 1; bit2Enable_o <= 0;		
			//functional unit code
			functionalUnitCode_o <= dSfunctionalUnitCode_i;			
		end
		
		else if(xEnable_i == 1)
		begin
			$display("Muxing X instruction");	
			//control
			enable_o <= 1;
			instructionFormat_o <= X;			
			xOpcodeEnable_o <= 1;
			xOpcode_o <= xXopcode_i;
			//reg
			reg1_o <= xReg1_i; reg2_o <= xReg2_i; reg3_o <= xReg3_i;
			reg1Enable_o <= 1; reg2Enable_o <= 1; reg3Enable_o <= 1;
			reg2ValOrZero <= xReg2ValOrZero_i; reg3IsImmediate_o <= 0;
			//imm
			immEnable_o <= 0;
			//bits
			bit1_o <= xBit1_i;
			bit1Enable_o <= 1; bit2Enable_o <= 0;	
			//functional unit code
			functionalUnitCode_o <= xfunctionalUnitCode_i;					
		end
		
		else if(mDEnable_i == 1)
		begin
			$display("Muxing MD instruction");
			//control
			enable_o <= 1;
			instructionFormat_o <= MD;			
			xOpcodeEnable_o <= 0;
			//reg
			reg1_o <= mDReg1_i; reg2_o <= mDReg2_i; reg3_o <= mDReg3_i;
			reg1Enable_o <= 1; reg2Enable_o <= 1; reg3Enable_o <= 1;
			reg2ValOrZero <= xReg2ValOrZero_i; reg3IsImmediate_o <= 1;
			//imm
			immEnable_o <= 1;
			imm_o <= mDImm_i;
			//bits
			bit1_o <= mDBit1_i; bit2_o <= mDBit2_i;
			bit1Enable_o <= 1; bit2Enable_o <= 1;	
			//functional unit code
			functionalUnitCode_o <= mDfunctionalUnitCode_i;	
		end
		
		else if(xOEnable_i == 1)
		begin
			$display("Muxing XO instruction");	
			//control
			enable_o <= 1;
			instructionFormat_o <= XO;			
			xOpcodeEnable_o <= 1;
			xOpcode_o <= xOopcode_i;
			//reg
			reg1_o <= xOReg1_i; reg2_o <= xOReg2_i; reg3_o <= xOReg3_i;
			reg1Enable_o <= 1; reg2Enable_o <= 1; reg3Enable_o <= 1;
			reg2ValOrZero <= 0; reg3IsImmediate_o <= 0;
			//imm
			immEnable_o <= 0;
			//bits
			bit1_o <= xOit1_i; bit2_o <= xOBit2_i;
			bit1Enable_o <= 1; bit2Enable_o <= 1;	
			//functional unit code
			functionalUnitCode_o <= xOfunctionalUnitCode_i;	
		end
	end

endmodule
