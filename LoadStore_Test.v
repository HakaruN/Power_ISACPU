`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////////////////////////

module LoadStore_Test;

	// Inputs
	reg clock_i;
	reg reset_i;
	reg enable_i;
	reg [0:2] functionalUnitCode_i;
	reg [0:63] instructionAddress_i;
	reg [0:5] opCode_i;
	reg [0:9] xOpCode_i;
	reg xOpCodeEnabled_i;
	reg [0:4] instructionFormat_i;
	reg [0:63] operand1_i;
	reg [0:63] operand2_i;
	reg [0:63] operand3_i;
	reg [0:4] reg1Address_i;
	reg [0:4] reg2Address_i;
	reg [0:4] reg3Address_i;
	reg [0:15] imm_i;

	// Outputs
	wire stall_o;
	wire [0:2] functionalUnitCode_o;
	wire reg1WritebackEnable_o;
	wire reg2WritebackEnable_o;
	wire [0:4] reg1WritebackAddress_o;
	wire [0:4] reg2WritebackAddress_o;
	wire [0:63] reg1WritebackVal_o;
	wire [0:63] reg2WritebackVal_o;

	// Instantiate the Unit Under Test (UUT)
	LoadStoreUnit uut (
		.clock_i(clock_i), 
		.reset_i(reset_i), 
		.enable_i(enable_i), 
		.functionalUnitCode_i(functionalUnitCode_i), 
		.instructionAddress_i(instructionAddress_i), 
		.opCode_i(opCode_i), 
		.xOpCode_i(xOpCode_i), 
		.xOpCodeEnabled_i(xOpCodeEnabled_i), 
		.instructionFormat_i(instructionFormat_i), 
		.operand1_i(operand1_i), 
		.operand2_i(operand2_i), 
		.operand3_i(operand3_i), 
		.reg1Address_i(reg1Address_i), 
		.reg2Address_i(reg2Address_i), 
		.reg3Address_i(reg3Address_i), 
		.imm_i(imm_i), 
		.stall_o(stall_o), 
		.functionalUnitCode_o(functionalUnitCode_o), 
		.reg1WritebackEnable_o(reg1WritebackEnable_o), 
		.reg2WritebackEnable_o(reg2WritebackEnable_o), 
		.reg1WritebackAddress_o(reg1WritebackAddress_o), 
		.reg2WritebackAddress_o(reg2WritebackAddress_o), 
		.reg1WritebackVal_o(reg1WritebackVal_o), 
		.reg2WritebackVal_o(reg2WritebackVal_o)
	);

	initial begin
		// Initialize Inputs
		clock_i = 0;
		reset_i = 0;
		enable_i = 0;
		functionalUnitCode_i = 0;
		instructionAddress_i = 0;
		opCode_i = 0;
		xOpCode_i = 0;
		xOpCodeEnabled_i = 0;
		instructionFormat_i = 0;
		operand1_i = 0;
		operand2_i = 0;
		operand3_i = 0;
		reg1Address_i = 0;
		reg2Address_i = 0;
		reg3Address_i = 0;
		imm_i = 0;

		reset_i = 1;
		clock_i = 1;
		#1;
		clock_i = 0;
		reset_i = 0;
		#1;
		
	end
      
endmodule

