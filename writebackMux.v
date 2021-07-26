`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
module WritebackMux #(
parameter FXUnitCode = 0, parameter FPUnitCode = 1, parameter LdStUnitCode = 2, parameter BranchUnitCode = 3, parameter TrapUnitCode = 4//functional unit code/ID used for dispatch
)(
		//command
		input wire clock_i,
		input wire reset_i,
		//FX unit in
		input wire [0:1] FXFunctionalUnitCode_i,
		input wire FXRegWritebackEnable_i, FXCondRegUpdateEnable_i,
		input wire [0:regWidth-1] FXReg1WritebackAddress_i, FXCondRegBits_i,
		input wire [0:addressSize-1] FXReg1WritebackValue_i, FXOverFlowUnderFlow_i,
		//LS unit in
		input wire [0:1] LSFunctionalUnitCode_i,
		input wire LSReg1WritebackEnable_i, LSReg2WritebackEnable_i,
		input wire [0:regWidth-1] LSReg1WritebackAddress_i, LSReg2WritebackAddress_i,
		input wire [0:addressSize-1] LSReg1WritebackValue_i, LSReg2WritebackValue_i,
		//TODO: FP unit
		//outputs
		output reg [0:1] functionalUnitCode_o,
		output reg reg1WritebackEnable_o, reg2WritebackEnable_o,//reg2 enable condition reg writeEnable
		output reg [0:5] reg1WritebackAddress_o, reg2WritebackAddress_o,//reg2 address is used to write back the condition reg bits
		output reg [0:63] reg1WritebackVal_o, reg2WritebackVal_o//reg2 val is overflow/underflow bits	
	);
	
	always @(posedge clock_i)
	begin
		if(reset_i == 1)
		begin
			reg1WritebackEnable_o <= 0; reg2WritebackEnable_o <= 0;
		end
		else
		begin
			if(FXOutputEnable_i == 1)
			begin
				functionalUnitCode_o <= FXUnitCode;
				reg1WritebackEnable_o <= FXRegWritebackEnable_i; reg2WritebackEnable_o <= FXCondRegUpdateEnable_i;
				reg1WritebackAddress_o <= FXReg1WritebackAddress_i; reg2WritebackAddress_o <= FXCondRegBits_i;
				reg1WritebackVal_o <= FXReg1WritebackValue_i; reg2WritebackVal_o <= FXOverFlowUnderFlow_i;
			end
			else if(LSOutputEnable_i == 1)
			begin
				functionalUnitCode_o <= LdStUnitCode;
				reg1WritebackEnable_o <= LSReg1WritebackEnable_i; reg2WritebackEnable_o <= LSReg2WritebackEnable_i;
				reg1WritebackAddress_o <= LSReg1WritebackAddress_i; reg2WritebackAddress_o <= LSReg2WritebackAddress_i;
				reg1WritebackVal_o <= LSReg1WritebackValue_i; reg2WritebackVal_o <= LSReg2WritebackValue_i;
			end
			else
			begin
				reg1WritebackEnable_o <= 0; reg2WritebackEnable_o <= 0;
			end
		end
	end


endmodule
