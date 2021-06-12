`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

module RegUnit_test;

	// Inputs
	reg clock;
	reg reset;
	reg enable;
	reg [0:15] imm;
	reg [0:4] reg1;
	reg [0:4] reg2;
	reg [0:4] reg3;
	reg bit1;
	reg bit2;
	reg immEnable;
	reg reg1Enable;
	reg reg2Enable;
	reg reg3Enable;
	reg bit1Enable;
	reg bit2Enable;
	reg [0:1] reg1Use;
	reg [0:1] reg2Use;
	reg [0:1] reg3Use;
	reg reg3IsImmediate;
	reg reg2ValOrZero;
	reg [0:63] instructionAddress;
	reg [0:5] opCode;
	reg [0:9] xOpcode;
	reg xOpCodeEnabled;
	reg [0:4] instructionFormat;
	reg [0:63] reg1WritebackData;
	reg [0:63] reg2WritebackData;
	reg reg1isWriteback;
	reg reg2isWriteback;
	reg [0:4] reg1WritebackAddress;
	reg [0:4] reg2WritebackAddress;

	// Outputs
	wire stall_o;
	wire enable_o;
	wire [0:63] operand1_o;
	wire [0:63] operand2_o;
	wire [0:63] operand3_o;
	wire [0:4] reg1Address_o;
	wire [0:4] reg2Address_o;
	wire [0:4] reg3Address_o;
	wire [0:15] imm_o;
	wire immEnable_o;
	wire bit1_o;
	wire bit2_o;
	wire operand1Enable_o;
	wire operand2Enable_o;
	wire operand3Enable_o;
	wire bit1Enable_o;
	wire bit2Enable_o;
	wire operand1Writeback_o;
	wire operand2Writeback_o;
	wire operand3Writeback_o;
	wire [0:63] instructionAddress_o;
	wire [0:5] opCode_o;
	wire [0:9] xOpCode_o;
	wire xOpCodeEnabled_o;
	wire [0:4] instructionFormat_o;

	// Instantiate the Unit Under Test (UUT)
	RegisterUnit uut (
		//command in
		.clock_i(clock), 
		.reset_i(reset), 
		//reg read in
		.enable_i(enable), 
		.imm_i(imm), 
		.reg1_i(reg1), .reg2_i(reg2), .reg3_i(reg3), 
		.bit1_i(bit1), .bit2_i(bit2), 
		.immEnable_i(immEnable), 
		.reg1Enable_i(reg1Enable), .reg2Enable_i(reg2Enable), 
		.reg3Enable_i(reg3Enable), .bit1Enable_i(bit1Enable), 
		.bit2Enable_i(bit2Enable), .reg1Use_i(reg1Use), 
		.reg2Use_i(reg2Use), .reg3Use_i(reg3Use), 
		.reg3IsImmediate_i(reg3IsImmediate), 
		.reg2ValOrZero_i(reg2ValOrZero), 
		.instructionAddress_i(instructionAddress), 
		.opCode_i(opCode), 
		.xOpcode_i(xOpcode), 
		.xOpCodeEnabled_i(xOpCodeEnabled), 
		.instructionFormat_i(instructionFormat), 
		//reg writeback in
		.reg1WritebackData_i(reg1WritebackData), .reg2WritebackData_i(reg2WritebackData), 
		.reg1isWriteback_i(reg1isWriteback), .reg2isWriteback_i(reg2isWriteback), 
		.reg1WritebackAddress_i(reg1WritebackAddress), .reg2WritebackAddress_i(reg2WritebackAddress),
		//command out
		.stall_o(stall_o), 
		//reg read out
		.enable_o(enable_o), 
		.operand1_o(operand1_o), 
		.operand2_o(operand2_o), 
		.operand3_o(operand3_o), 
		.reg1Address_o(reg1Address_o), 
		.reg2Address_o(reg2Address_o), 
		.reg3Address_o(reg3Address_o), 
		.imm_o(imm_o), 
		.immEnable_o(immEnable_o), 
		.bit1_o(bit1_o), 
		.bit2_o(bit2_o), 
		.operand1Enable_o(operand1Enable_o), 
		.operand2Enable_o(operand2Enable_o), 
		.operand3Enable_o(operand3Enable_o), 
		.bit1Enable_o(bit1Enable_o), 
		.bit2Enable_o(bit2Enable_o), 
		.operand1Writeback_o(operand1Writeback_o), 
		.operand2Writeback_o(operand2Writeback_o), 
		.operand3Writeback_o(operand3Writeback_o), 
		.instructionAddress_o(instructionAddress_o), 
		.opCode_o(opCode_o), 
		.xOpCode_o(xOpCode_o), 
		.xOpCodeEnabled_o(xOpCodeEnabled_o), 
		.instructionFormat_o(instructionFormat_o)
	);

	initial begin
		//command
		clock = 0;
		reset = 0;
		//reg read in
		enable = 0;
		imm = 0;
		reg1 = 0;reg2 = 0;reg3 = 0;
		bit1 = 0;bit2 = 0;
		immEnable = 0;
		reg1Enable = 0;reg2Enable = 0;reg3Enable = 0;
		bit1Enable = 0;bit2Enable = 0;
		reg1Use = 0;reg2Use = 0;reg3Use = 0;
		reg3IsImmediate = 0;
		reg2ValOrZero = 0;
		instructionAddress = 0;
		opCode = 0;
		xOpcode = 0;
		xOpCodeEnabled = 0;
		instructionFormat = 0;
		//reg write in
		reg1WritebackData = 0; reg2WritebackData = 0;
		reg1isWriteback = 0;reg2isWriteback = 0;
		reg1WritebackAddress = 0;reg2WritebackAddress = 0;

		//reset
		reset = 1;
		clock = 1;
		#1;
		reset = 0;
		clock = 0;
		#1;

		//write to some regs
		reg1WritebackAddress = 5; reg2WritebackAddress = 1;//write to reg 5 and 1
		reg1WritebackData = 10; reg2WritebackData = 7;//write 10 and 7 respectivly
		reg1isWriteback = 1; reg2isWriteback = 1;//writeback enables
		clock = 1;
		#1;
		clock = 0;
		#1;
		
		//read the reg that we just wrote and write to some more regs
		//read
		enable = 1;
		reg1 = 5;reg2 = 1;
		reg1Enable = 1;reg2Enable = 1;
		reg1Use = 2;reg2Use = 3;//Imm = 0, Read = 1, Write = 2, Read/Write = 3
		instructionAddress = 1;
		opCode = 25;
		xOpCodeEnabled = 0;
		instructionFormat = 0;
		//write
		reg1WritebackAddress = 2; reg2WritebackAddress = 3;//write to reg 5 and 1
		reg1WritebackData = 5; reg2WritebackData = 6;//write 10 and 7 respectivly
		reg1isWriteback = 1; reg2isWriteback = 1;//writeback enables
		clock = 1;
		#1;
		clock = 0;
		#1;
		reg1isWriteback = 0; reg2isWriteback = 0;
		//attempt to read the regs that are pending writeback, should see a stall and the output low
		enable = 1;
		reg1 = 2;reg2 = 3;
		reg1Enable = 1;reg2Enable = 1;
		reg1Use = 1;reg2Use = 1;//Imm = 0, Read = 1, Write = 2, Read/Write = 3
		instructionAddress = 1;
		opCode = 25;
		xOpCodeEnabled = 0;
		instructionFormat = 0;
		clock = 1;
		#1;
		clock = 0;
		#1;
		//write the data back and check that the writebackpending flags go low.
	end
      
endmodule

