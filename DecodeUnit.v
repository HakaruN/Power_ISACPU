`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//Decodes the instructions, atm it supports:
//branch, fixed point
//Stage one consists of parallel stage one decoders which all take the fetched instruction and attempt to decode based on their specific format
//Each decoder has unique ouptputs that is specific to the decoder's format.
//Stage two takes in the decoders outputs, applies implicit operations based on the format (sign extention, bit concatinations etc) and multiplexes the output
//to the next pipeline stage
//TODO: Implement a trap handler
//////////////////////////////////////////////////////////////////////////////////
module DecodeUnit#(
//instruction formats
parameter A = 1, parameter B = 2, parameter D = 3, parameter DQ = 4, parameter DS = 5, parameter DX = 6, parameter I = 7, parameter M = 8,
parameter MD = 9, parameter MDS = 10, parameter SC = 11, parameter VA = 12, parameter VC = 13, parameter VX = 14, parameter X = 15, parameter XFL = 16,
parameter XFX = 17, parameter XL = 18, parameter XO = 19, parameter XS = 20, parameter XX2 = 21, parameter XX3 = 22, parameter XX4 = 23, parameter Z22 = 24,
parameter Z23 = 25, parameter INVALID = 0,
//data widths
parameter instructionWidth = 32, parameter addressSize = 64, parameter formatIndexRange = 5,
parameter opcodeWidth = 6, parameter xOpCodeWidth = 10, parameter XoOpCodeWidth = 9, parameter regWidth = 5, parameter immWidth = 24,
parameter DSImmWidth = 14, parameter DImmWith = 16, parameter DQImmWidth = 12, parameter MDImmWidth = 6,
parameter regImm = 0, parameter regRead = 1, parameter regWrite = 2, parameter regReadWrite = 3,//indicates if a registers use is immediate, read, write or both
parameter numStallLines = 6,//should be the number of format specific decoders in the decode unit
parameter FXUnitCode = 0, parameter FPUnitCode = 1, parameter LdStUnitCode = 2, parameter BranchUnitCode = 3, parameter TrapUnitCode = 4//functional unit code/ID used for dispatch
)(
	//command int
	input wire clock_i,
	input wire enable_i,
	//data in
	input wire [0:instructionWidth-1] instruction_i,
	input wire [0:addressSize-1] instructionAddress_i,
	//command out 
	output wire [0:numStallLines-1] stall_o,//a stall line for each format decoder
	//data out
	output wire enable_o,
	output wire [0:immWidth-1] imm_o,
	output wire immEnable_o,
	output wire [0:regWidth-1] reg1_o, reg2_o, reg3_o,
	output wire [0:1] reg1Use_o, reg2Use_o, reg3Use_o,
	output wire reg1Enable_o, reg2Enable_o, reg3Enable_o,
	output wire reg3IsImmediate_o,
	output wire bit1_o, bit2_o,
	output wire bit1Enable_o, bit2Enable_o,
	output wire reg2ValOrZero_o,
	output wire [0:addressSize-1] instructionAddress_o,
	output wire [0:opcodeWidth-1] opCode_o,
	output wire [0:xOpCodeWidth-1] xOpcode_o,
	output wire xOpcodeEnable_o,
	output wire [0:2] functionalUnitCode_o,
	output wire [0:formatIndexRange-1] instructionFormat_o
	);
	
	//instruction bypass buffers
	reg [0:opcodeWidth-1] opcodeBypass;
	reg [0:addressSize-1] addressBypass;
	
	///Stage 1 - parallel decoders:
	wire [0:regWidth-1] DReg1, DReg2;
	wire [0:1] DReg1Use, DReg2Use;
	wire [0:15] DImm;
	wire DReg2ValOrZero;
	wire DImmFormat;//0 = unsignedImm, 1 = signedImm (sign extended to 64b down the pipe)
	wire [0:1] DFshiftImmUpBytes;//EG shiftImmUpBytes_o == 2, the extended immediate will be { 32'h0000_0000, immFormat_o, 16'h0000}, if shiftImmUpBytes_o == 4: {immFormat_o, 48'h0000_0000_0000}
	wire DEnable;	
	wire [0:2] DfunctionalUnitCode;
	//D format instruction decoder
	DFormatDecoder #(.opcodeWidth(opcodeWidth), .regWidth(regWidth), .immWidth(DImmWith), .instructionWidth(instructionWidth),
	.FXUnitCode(FXUnitCode), .FPUnitCode(FPUnitCode), .LdStUnitCode(LdStUnitCode), .BranchUnitCode(BranchUnitCode))
	dFormatDecoder(
	//command
	.clock_i(clock_i),
	.enable_i(enable_i),
	//data in
	.instruction_i(instruction_i),
	//command out
	.stall_o(stall_o[0]),
	//data out
	.reg1_o(DReg1), .reg2_o(DReg2),
	.reg1Use_o(DReg1Use), .reg2Use_o(DReg2Use),
	.reg2ValOrZero_o(DReg2ValOrZero),
	.imm_o(DImm),
	.immFormat_o(DImmFormat),
	.shiftImmUpBytes_o(DFshiftImmUpBytes),
	//functional unit code
	.functionalUnitCode_o(DfunctionalUnitCode),
	//enable
	.enable_o(DEnable)
	);	
	
	wire [0:regWidth-1] DQReg1, DQReg2;
	wire [0:1] DQReg1Use, DQReg2Use;
	wire [0:11] DQImm;
	wire DQBit1;
	wire DQEnable;
	wire [0:2] DQfunctionalUnitCode;
		
	//DQ format instruction decoder
	//All dq instructions are implicitly reg2ValOrZero=1 and imm shift up 4 bits
	DQFormatDecoder#(.opcodeWidth(opcodeWidth), .regWidth(regWidth), .immWidth(DQImmWidth), .instructionWidth(instructionWidth))
	dQFormatDecoder(
	//command
	.clock_i(clock_i),
	.enable_i(enable_i),
	//data in
	.instruction_i(instruction_i),
	//command out
	.stall_o(stall_o[1]),
	//data out
	.reg1_o(DQReg1), .reg2_o(DQReg2),
	.reg1Use_o(DQReg1Use), .reg2Use_o(DQReg2Use),
	.imm_o(DQImm),
	.bit_o(DQBit1),
	//functional unit code
	.functionalUnitCode_o(DQfunctionalUnitCode),
	//enable
	.enable_o(DQEnable)
	);

	wire [0:regWidth-1] DSReg1, DSReg2;
	wire DSReg2ValOrZero;
	wire [0:DSImmWidth-1] DSImm;//Imm is implicitly extended to 16 bits by adding 2 zeroes on the right size
	wire DSEnable;
	wire [0:2] DSfunctionalUnitCode;
	//DS format instruction decoder
	DSFormatDecoder #(.opcodeWidth(opcodeWidth), .regWidth(regWidth), .immWidth(DSImmWidth), .instructionWidth(instructionWidth))
	dSFormatDecoder(
	//command
	.clock_i(clock_i),
	.enable_i(enable_i),
	//data in
	.instruction_i(instruction_i),
	//command out
	.stall_o(stall_o[2]),
	//data out
	.reg1_o(DSReg1), .reg2_o(DSReg2),
	.reg2ValOrZero_o(DSReg2ValOrZero),
	.imm_o(DSImm),
	//functional unit code
	.functionalUnitCode_o(DSfunctionalUnitCode),
	//enable
	.enable_o(DSEnable)
	);
	
	wire [0:9] xOpcode;
	wire [0:regWidth-1] XReg1, XReg2, XReg3;
	wire XReg2ValOrZero;
	wire XBit1;
	wire XEnable;
	wire [0:2] XfunctionalUnitCode;
	//X format instruction decoder
	XFormatDecoder #(.opcodeWidth(opcodeWidth), .xOpCodeWidth(xOpCodeWidth), .regWidth(regWidth), .instructionWidth(instructionWidth))
	xFormatDecoder(
	//command
	.clock_i(clock_i),
	.enable_i(enable_i),
	//data in
	.instruction_i(instruction_i),
	//command out
	.stall_o(stall_o[3]),
	//data out
	.xOpcode_o(xOpcode),
	.reg1_o(XReg1), .reg2_o(XReg2), .reg3_o(XReg3),
	.reg2ValOrZero_o(XReg2ValOrZero),
	.bit1_o(XBit1),
	//functional unit code
	.functionalUnitCode_o(XfunctionalUnitCode),
	//enable
	.enable_o(XEnable)
	);	
	
	//MD
	wire [0:regWidth-1] MDReg1, MDReg2, MDReg3;
	wire [0:5] MDImm;
	wire MDBit1, MDBit2;
	wire MDEnable;
	wire [0:2] mDfunctionalUnitCode;
	MDFormatDecoder #(.opcodeWidth(opcodeWidth), .regWidth(regWidth), .immWidth(6), .instructionWidth(instructionWidth))
	mDFormatDecoder(
	.clock_i(clock_i),
	.enable_i(enable_i),
	//data in
	.instruction_i(instruction_i),
	//command out
	.stall_o(stall_o[4]),
	//data out
	.reg1_o(MDReg1), .reg2_o(MDReg2), .reg3_o(MDReg3),//reg 3 is implicitley an immediate value
	.imm_o(MDImm),
	.bit1_o(MDBit1), .bit2_o(MDBit2),
	//functional unit code
	.functionalUnitCode_o(mDfunctionalUnitCode),
	//enable
	.enable_o(MDEnable)
	);	
	
	//XO
	wire [0:XoOpCodeWidth-1] XOopCode;
	wire [0:regWidth-1] XOReg1, XOReg2, XOReg3;
	wire XOBit1, XOBit2;
	wire XOEnable;
	wire [0:2] XOfunctionalUnitCode;
	XOFormatDecoder #( .opcodeWidth(opcodeWidth), .XoOpCodeWidth(9), .regWidth(regWidth), .instructionWidth(instructionWidth))
	xOFormatDecoder(
	//command
	.clock_i(clock_i),
	.enable_i(enable_i),
	//data in
	.instruction_i(instruction_i),
	//command out
	.stall_o(stall_o[5]),
	//data out
	.reg1_o(XOReg1), .reg2_o(XOReg2), .reg3_o(XOReg3),
	.xOpCode_o(XOopCode),	
	.bit1_o(XOBit1), .bit2_o(XOBit2),
	//functional unit code
	.functionalUnitCode_o(XOfunctionalUnitCode),
	//enable
	.enable_o(XOEnable)
	);

	//Stage 2 - decoder output mux
	DecodeStage2 #(.opcodeWidth(opcodeWidth),.regWidth(regWidth),.addressSize(addressSize),
	.DImmWidth(16),.DQimmWidth(12),.DSimmWidth(14),.MDimmWidth(MDImmWidth),
	.XxoOpcodeWidth(xOpCodeWidth),.XoOpCodeWidth(XoOpCodeWidth),
	//instrcution format
	.formatIndexRange(formatIndexRange),
	.A(A),.B(B),.D(D),.DQ(DQ),.DS(DS),.DX(DX),.I(I),.M(M),.MD(MD),.MDS(MDS),.SC(SC),.VA(VA),.VC(VC),.VX(VX),.X(X),.XFL(XFL),
	.XFX(XFX),.XL(XL),.XO(XO),.XS(XS),.XX2(XX2),.XX3(XX3),.XX4(XX4),.Z22(Z22),.Z23(Z23),.INVALID(INVALID))
	decodeStage2(
	//command
	.clock_i(clock_i),
	.instructionAddress_i(addressBypass),
	.opcode_i(opcodeBypass),
	//D input
	.dEnable_i(DEnable),
	.dReg1_i(DReg1), .dReg2_i(DReg2),
	.dreg1Use_i(DReg1Use), .dreg2Use_i(DReg2Use),
	.dImm_i(DImm),
	.dimmFormat2_i(DImmFormat),
	.dReg2ValOrZero_i(DReg2ValOrZero),
	.dfunctionalUnitCode_i(DfunctionalUnitCode),
	.dImmShiftUpBytes_i(DFshiftImmUpBytes),
	//DQ input
	.dQEnable_i(DQEnable),
	.dQReg1_i(DQReg1), .dQReg2_i(DQReg2),
	.dQreg1Use_i(DQReg1Use), .dQreg2Use_i(DQReg2Use),
	.dQImm_i(DQImm),
	.dQfunctionalUnitCode_i(DQfunctionalUnitCode),
	.dQBit_i(DQBit1),
	//DS input
	.dSEnable_i(DSEnable),
	.dSReg1_i(DSReg1), .dSReg2_i(DSReg2),
	.dSImm_i(DSImm),
	.dSfunctionalUnitCode_i(DSfunctionalUnitCode),
	.dSReg2ValOrZero_i(DSReg2ValOrZero),
	//X input
	.xEnable_i(XEnable),
	.xReg1_i(XReg1), .xReg2_i(XReg2), .xReg3_i(XReg3),
	.xBit1_i(XBit1),
	.xReg2ValOrZero_i(XReg2ValOrZero),
	.xfunctionalUnitCode_i(XfunctionalUnitCode),
	.xXopcode_i(xOpcode),
	//MD input
	.mDEnable_i(MDEnable),
	.mDReg1_i(MDReg1), .mDReg2_i(MDReg2), .mDReg3_i(MDReg3),
	.mDImm_i(MDImm),
	.mDfunctionalUnitCode_i(mDfunctionalUnitCode),
	.mDBit1_i(MDBit1), .mDBit2_i(MDBit2),
	//XO input
	.xOEnable_i(XOEnable),
	.xOReg1_i(XOReg1), .xOReg2_i(XOReg2), .xOReg3_i(XOReg3),
	.xOopcode_i(XOopCode),
	.xOfunctionalUnitCode_i(XOfunctionalUnitCode),
	.xOit1_i(XOBit1), .xOBit2_i(XOBit2),
	//outputs
	.enable_o(enable_o),
	.imm_o(imm_o),
	.immEnable_o(immEnable_i),
	.reg1_o(reg1_o), .reg2_o(reg2_o), .reg3_o(reg3_o),
	.reg1Use_o(reg1Use_o), .reg2Use_o(reg2Use_o), .reg3Use_o(reg3Use_o),
	.reg1Enable_o(reg1Enable_o), .reg2Enable_o(reg2Enable_o), .reg3Enable_o(reg3Enable_o),
	.reg3IsImmediate_o(reg3IsImmediate_o),
	.bit1_o(bit1_o), .bit2_o(bit2_o),
	.bit1Enable_o(bit1Enabled_o), .bit2Enable_o(bit2Enabled_o),
	.reg2ValOrZero(reg2ValOrZero_o),
	.instructionAddress_o(instructionAddress_o),
	.opcode_o(opCode_o),
	.xOpcode_o(xOpcode_o),
	.xOpcodeEnable_o(xOpCodeEnabled_o),
	.functionalUnitCode_o(functionalUnitCode_o),
	.instructionFormat_o(instructionFormat_o)
    );

	 //instruction bypass
	 always @(posedge clock_i)
	 begin
		if(enable_i == 1)
		begin
			opcodeBypass <= instruction_i[0:opcodeWidth-1];
			addressBypass <= instructionAddress_i;
		end
		
	 end
	
endmodule
