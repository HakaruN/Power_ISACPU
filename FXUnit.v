`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//Fixed point unit
//NOTE: By time an instruction has arived here, immediate values have already been extended and shifted
//and all vereg2orZeroes have been resolved
//
//General purpose registers are found in the register file (FX, FP). Fixed function registers are to be kept as part of the relevent execution unit
//as these likely require a zero cycle writeback latency. The exception is when the register is shared between units (condition register)
//
//This functional unit has a 2 cycle latency. The first cycle performs the arithmatic operation and the second cycle parses the result in a 
//writeback-able format. It finds carries and concatenates the first cycles output 128b register (required for 64b multiplication) down to 64 bits to be writen back
//////////////////////////////////////////////////////////////////////////////////
module FXUnit #(
parameter opcodeWidth = 6, parameter xOpCodeWidth = 10, parameter immWith = 24, parameter regWidth = 5, parameter numRegs = 2**regWidth, parameter formatIndexRange = 5,
parameter A = 1, parameter B = 2, parameter D = 3, parameter DQ = 4, parameter DS = 5, parameter DX = 6, parameter I = 7, parameter M = 8,
parameter MD = 9, parameter MDS = 10, parameter SC = 11, parameter VA = 12, parameter VC = 13, parameter VX = 14, parameter X = 15, parameter XFL = 16,
parameter XFX = 17, parameter XL = 18, parameter XO = 19, parameter XS = 20, parameter XX2 = 21, parameter XX3 = 22, parameter XX4 = 23, parameter Z22 = 24,
parameter Z23 = 25, parameter INVALID = 0,
parameter FXUnitCode = 0, parameter FPUnitCode = 1, parameter LdStUnitCode = 2, parameter BranchUnitCode = 3, parameter TrapUnitCode = 4,//functional unit code/ID used for dispatch
parameter arithmatic = 0, parameter compare = 1
)(
	//command
	input wire clock_i,
	input wire reset_i,
	input wire enable_i,
	//data in
	//input wire is64Bit_i,
	input wire [0:2] functionalUnitCode_i,
	input wire [0:63] operand1_i, operand2_i, operand3_i,
	input wire [0:regWidth-1] reg1Address_i, //reg2Address_i, reg3Address_i,
	input wire [0:immWith-1] imm_i,
	input wire bit1_i, bit2_i,
	//input wire operand1Writeback_i, operand2Writeback_i, operand3Writeback_i,
	input wire [0:63] instructionAddress_i,
	input wire [0:opcodeWidth-1] opCode_i,
	input wire [0:xOpCodeWidth-1] xOpCode_i,
	input wire [0:formatIndexRange-1] instructionFormat_i,
	//outputs
	output reg [0:2] functionalUnitCode_o,
	output reg reg1WritebackEnable_o, //reg2WritebackEnable_o,//reg2 enable condition reg writeEnable
	output reg [0:regWidth-1] reg1WritebackAddress_o, reg2WritebackAddress_o,//reg2 address is used to write back the condition reg bits
	output reg [0:63] reg1WritebackVal_o, //reg2WritebackVal_o,//reg2 val is overflow/underflow bits
	output reg [0:3] CR0_o,//condition register output
	output reg setSO_o,//sets the sumary overflow in the FX_XER
	output reg OV_o,//the value of the OV bit in the FX_XER
	output reg CA_o//the value of the CA bit in the FX_XER
	);
	
	reg [0:128] intermediateResult;
	reg [0:63] CIA1;
	reg [0:3] CRBits;
	reg [0:4] reg1WBAddress, reg2WBAddress;//tells the reg file what physical reg's to write back to
	reg reg1IsWriteback;//reg2IsWriteback;
	reg isCarrying, isRecord, isOVEnabled;//control flags indicating what status bits can be updated
	reg stage1Enabled;
	reg [0:2] functionType;
	
	always @(posedge clock_i)
	begin
		if(enable_i == 1 && reset_i == 0 && functionalUnitCode_i == FXUnitCode)
		begin
			stage1Enabled <= 1;
			CIA1 <= instructionAddress_i;
			if(instructionFormat_i == D)
			begin
				case(opCode_i)
					14: begin intermediateResult <= $signed(operand2_i + imm_i); reg1WBAddress <= reg1Address_i; isCarrying <= 0; isRecord <= 0; isOVEnabled <= 0; reg1IsWriteback <= 1; functionType <= arithmatic; end//Add Immediate - 16b signed add
					15: begin intermediateResult <= $signed(operand2_i + imm_i); reg1WBAddress <= reg1Address_i; isCarrying <= 0; isRecord <= 0; isOVEnabled <= 0; reg1IsWriteback <= 1; functionType <= arithmatic; end//Add Immediate Shifted
					12: begin intermediateResult <= $signed(operand2_i + imm_i); reg1WBAddress <= reg1Address_i; isCarrying <= 1; isRecord <= 0; isOVEnabled <= 0; reg1IsWriteback <= 1; functionType <= arithmatic; end//Add Immediate Carrying
					13: begin intermediateResult <= $signed(operand2_i + imm_i); reg1WBAddress <= reg1Address_i; isCarrying <= 1; isRecord <= 1; isOVEnabled <= 0; reg1IsWriteback <= 1; functionType <= arithmatic; end//Add Immediate Carrying and Record
					8: begin intermediateResult <= $signed(operand2_i - imm_i); reg1WBAddress <= reg1Address_i; isCarrying <= 1; isRecord <= 0; isOVEnabled <= 0; reg1IsWriteback <= 1; functionType <= arithmatic; end//Subtract Immediate Carrying
					7: begin intermediateResult <= $signed(operand2_i * $signed(imm_i)); reg1WBAddress <= reg1Address_i; isCarrying <= 1; isRecord <= 0; isOVEnabled <= 0; reg1IsWriteback <= 1; functionType <= arithmatic; end//Multiply Low Immediate
					11: begin reg1IsWriteback <= 0; isCarrying <= 0; isOVEnabled <= 0; isRecord <= 1; functionType <= compare; 
						if(bit1_i) begin
							if(operand2_i < $signed(imm_i))
								CRBits <= 4'b1000;
							else if(operand2_i > $signed(imm_i))
								CRBits <= 4'b0100;
							else
								CRBits <= 4'b0010;
						end
						else
						begin
							if($signed(operand2_i[32:63]) < $signed(imm_i))
								CRBits <= 4'b1000;
							else if($signed(operand2_i[32:63]) > $signed(imm_i))
								CRBits <= 4'b0100;
							else
								CRBits <= 4'b0010;
						end						
					end//compare immediate
					3: begin
					end//Trap word immediate	
					2: begin
					end//Trap dobubleword immediate	
					28: begin intermediateResult <= operand1_i & {48'b0, imm_i}; reg1WBAddress <= operand2_i; isCarrying <= 0; isRecord <= 1; isOVEnabled <= 0; reg1IsWriteback <= 1; functionType <= arithmatic; end//AND immediate
					29: begin intermediateResult <= operand1_i & {32'b0, imm_i, 16'b0}; reg1WBAddress <= operand2_i; isCarrying <= 0; isRecord <= 1; isOVEnabled <= 0; reg1IsWriteback <= 1; functionType <= arithmatic; end//AND immediate shifted
					24: begin intermediateResult <= operand1_i | {48'b0, imm_i}; reg1WBAddress <= operand2_i; isCarrying <= 0; isRecord <= 1; isOVEnabled <= 0; reg1IsWriteback <= 1; functionType <= arithmatic; end//OR immediate
					25: begin intermediateResult <= operand1_i | {32'b0, imm_i, 16'b0}; reg1WBAddress <= operand2_i; isCarrying <= 0; isRecord <= 1; isOVEnabled <= 0; reg1IsWriteback <= 1; functionType <= arithmatic; end//OR immediate shifted
					26: begin intermediateResult <= operand1_i ^ {48'b0, imm_i}; reg1WBAddress <= operand2_i; isCarrying <= 0; isRecord <= 1; isOVEnabled <= 0; reg1IsWriteback <= 1; functionType <= arithmatic; end//XOR immediate
					27: begin intermediateResult <= operand1_i ^ {32'b0, imm_i, 16'b0}; reg1WBAddress <= operand2_i; isCarrying <= 0; isRecord <= 1; isOVEnabled <= 0; reg1IsWriteback <= 1; functionType <= arithmatic; end//XOR immediate shifted
				endcase
			end
			else if(instructionFormat_i == XO && opCode_i == 31)
			begin
				case(xOpCode_i)
					266: begin intermediateResult <= $signed(operand2_i + operand3_i); reg1WBAddress <= operand1_i; isCarrying <= 0; isRecord <= bit2_i; isOVEnabled <= bit1_i; reg1IsWriteback <= 1; functionType <= arithmatic; end//add
					40: begin intermediateResult <= $signed(operand2_i - operand3_i); reg1WBAddress <= operand1_i; isCarrying <= 0; isRecord <= bit2_i; isOVEnabled <= bit1_i; reg1IsWriteback <= 1; functionType <= arithmatic; end//subtract from
					10: begin intermediateResult <= $signed(operand2_i + operand3_i); reg1WBAddress <= operand1_i; isCarrying <= 1; isRecord <= bit2_i; isOVEnabled <= bit1_i; reg1IsWriteback <= 1; functionType <= arithmatic; end//add carrying
					40: begin intermediateResult <= $signed(operand2_i - operand3_i); reg1WBAddress <= operand1_i; isCarrying <= 1; isRecord <= bit2_i; isOVEnabled <= bit1_i; reg1IsWriteback <= 1; functionType <= arithmatic; end//subtract from carrying
					//128: begin intermediateResult <= $signed(operand2_i + operand3_i); reg1WBAddress <= operand1_i; isCarrying <= 1; isRecord <= bit2_i; isOVEnabled <= bit1_i; reg1IsWriteback <= 1; functionType <= arithmatic; end//add extended
					//136: begin intermediateResult <= $signed(operand2_i - operand3_i); reg1WBAddress <= operand1_i; isCarrying <= 1; isRecord <= bit2_i; isOVEnabled <= bit1_i; reg1IsWriteback <= 1; functionType <= arithmatic; end//subtract from extended
					//234: begin intermediateResult <= $signed(operand2_i + operand3_i) - 1; reg1WBAddress <= operand1_i; isCarrying <= 1; isRecord <= bit2_i; isOVEnabled <= bit1_i; reg1IsWriteback <= 1; functionType <= arithmatic; end//add extended
					//232: begin intermediateResult <= $signed(operand2_i - operand3_i) - 1; reg1WBAddress <= operand1_i; isCarrying <= 1; isRecord <= bit2_i; isOVEnabled <= bit1_i; reg1IsWriteback <= 1; functionType <= arithmatic; end//subtract from extended
				endcase
			end
		end		
		else
			stage1Enabled <= 0;
	end
	
	//stage 2 outputs the results
	always @(posedge clock_i)
	begin
		functionalUnitCode_o <= FXUnitCode;
		if(stage1Enabled == 1)
		begin
			reg1WritebackEnable_o <= reg1IsWriteback;// reg2WritebackEnable_o <= reg2IsWriteback;//set the writeback enables
			reg1WritebackAddress_o <= reg1WBAddress; reg2WritebackAddress_o <= reg2WBAddress;
			reg1WritebackVal_o <= intermediateResult[64:127]; //reg2WritebackVal_o <= 
			
			if(isOVEnabled)//if OV is enabled, then set OV bit if any of the top intemermediate bits are set
				OV_o <= 1 && intermediateResult[0:63];
				
			if(isRecord)//if record, update the CR bits
				CR0_o <= CRBits;
				
			if(isCarrying)//if isCarrying is set, set the carried out bit to here
				CA_o <= intermediateResult[63];			
		end
		else
		begin
			reg1WritebackEnable_o <= 0; //reg2WritebackEnable_o <= 0;
		end
	end

endmodule
