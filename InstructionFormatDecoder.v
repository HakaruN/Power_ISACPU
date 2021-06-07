`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
module InstructionFormatDecoder #( parameter instructionWidth = 32, parameter addressSize = 64, parameter formatIndexRange = 5,
parameter A = 1, parameter B = 2, parameter D = 3, parameter DQ = 4, parameter DS = 5, parameter DX = 6, parameter I = 7, parameter M = 8,
parameter MD = 9, parameter MDS = 10, parameter SC = 11, parameter VA = 12, parameter VC = 13, parameter VX = 14, parameter X = 15, parameter XFL = 16,
parameter XFX = 17, parameter XL = 18, parameter XO = 19, parameter XS = 20, parameter XX2 = 21, parameter XX3 = 22, parameter XX4 = 23, parameter Z22 = 24,
parameter Z23 = 25, parameter INVALID = 0,
parameter opcodeWidth = 6, parameter xOpCodeWidth = 10, parameter regWidth = 5, parameter immWidth = 16
)(
	//command
	input wire clock_i,
	input wire enable_i,
	//data in
	input wire [0:opcodeWidth-1] opCode_i,
	input wire [opcodeWidth:instructionWidth-1] payload_i,
	input wire [0:addressSize-1] address_i,
	input wire [0:formatIndexRange-1] instructionFormatClass_i,
	//command out
	output reg enable_o,
	//data out
	output reg [0:opcodeWidth-1] opCode_o,
	output reg [0:xOpCodeWidth-1] xOpCode_o,
	output reg [0:addressSize-1] address_o,
	output reg [0:formatIndexRange-1] instructionFormat_o,
	//decoded outputs
	output reg [0:regWidth-1] reg1_o, reg2_o, reg3_o, reg4_o,//can use up to three registers (so far, may change with more supported instructions)
	output reg [0:immWidth-1] imm_o,	
	output reg bit1_o, bit2_o
	);
	
	always @(posedge clock_i)
	begin
		if(enable_i == 1) 
		begin
			if(instructionFormatClass_i != 0)
			begin
				//pass data through
				enable_o <= 1;
				opCode_o <= opCode_i;
				address_o <= address_i;
				//parse the format
				case(instructionFormatClass_i)
					D: begin
						$display("D format instruction");
						instructionFormat_o <= D;
						reg1_o <=  payload_i[6:10]; reg2_o <=  payload_i[11:15]; imm_o <= payload_i[16:31];
					end
					DS: begin
						$display("DS format instruction");
						instructionFormat_o <= DS;
						reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; imm_o <= payload_i[16:29]; xOpCode_o <= payload_i[30:31];
					end
					DQ: begin
						$display("DQ format instruction");
						instructionFormat_o <= DQ;
						reg1_o <= payload_i[6:10]; reg2_o <= (payload_i[6:10] + 1); reg3_o <= payload_i[11:15]; imm_o <= payload_i[16:27];
					end
					DX: begin
						$display("DX format instruction");
						instructionFormat_o <= DX;
						reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; imm_o <= {payload_i[16:25], payload_i[11:15], payload_i[31]}; xOpCode_o <= payload_i[26:30];
					end
					MD: begin//MD format class contains both MD and MDS formats, these need seperating here
						reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20]; imm_o <= payload_i[21:26]; 
						if(payload_i[27:30] == 9 || payload_i[27:30] == 9)
						begin//MDS
							$display("MDS format instruction");
							instructionFormat_o <= MDS;
							xOpCode_o <= payload_i[27:30];
							bit1_o <= payload_i[31];
						end
						else
						begin//MD
							$display("MD format instruction");
							instructionFormat_o <= MD;
							xOpCode_o <= payload_i[27:29];
							bit1_o <= payload_i[30]; bit2_o <= payload_i[31];
						end
					end				
					//X is seperated into three register sized fields with the XO[21:30] and sometimes bit 31 used
					//XO is seperated into three register fields, bit [21] may be used, XO[22:30] bit [31 may be used]
					//XFX uses 1 register field, 1 10bit imm[11:20], XO[21:30], bit[31] never used
					//XS is seperated into three register sized fields with the XO[21:29] and bit[30]&[31] being used
					X: begin  //everything with opcode of 31. So far X, XO and XFX, Am Z23 instruction are in the X format class
					//XO[21:30] - X, XO[22:30] - XO, XO[21:30] - XFX, XO[21:29] - XS, XO[26:30] - A, XO[23:30] - Z23
						//X and XFX share XO fields [21:30]
						//XO uses [22:30]
						//XS uses [21:29]
						//A uses [26:30]
						//Z23 uses [23:30]
						
						case(payload_i[26:30])//check for A
							15: begin $display("Recived A format isntruction");
								instructionFormat_o <= A; 
								xOpCode_o <= 15; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20]; reg4_o <= payload_i[21:25];
								bit1_o <= payload_i[31];
								enable_o <= 1;
							end
						endcase
						case(payload_i[23:30])//check for z23
							170: begin $display("Recived Z23 format isntruction");
								instructionFormat_o <= Z23; 
								xOpCode_o <= 170; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								imm_o <= payload_i[21:22];
								bit1_o <= payload_i[31];
								enable_o <= 1;
							end
						endcase
						case(payload_i[22:30])//check for XO
							128: begin $display("Recived XO format isntruction");
								instructionFormat_o <= XO; 
								xOpCode_o <= payload_i[22:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[21];		
								enable_o <= 1;								
							end
							266:begin $display("Recived XO format isntruction");
								instructionFormat_o <= XO; 
								xOpCode_o <= payload_i[22:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[21];	
								enable_o <= 1;
							end
							40:begin $display("Recived XO format isntruction");
								instructionFormat_o <= XO; 
								xOpCode_o <= payload_i[22:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[21];	
								enable_o <= 1;
							end
							10:begin $display("Recived XO format isntruction");
								instructionFormat_o <= XO; 
								xOpCode_o <= payload_i[22:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[21];	
								enable_o <= 1;
							end
							8:begin $display("Recived XO format isntruction");
								instructionFormat_o <= XO; 
								xOpCode_o <= payload_i[22:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[21];	
								enable_o <= 1;
							end
							138:begin $display("Recived XO format isntruction");
								instructionFormat_o <= XO; 
								xOpCode_o <= payload_i[22:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[21];	
								enable_o <= 1;
							end
							234:begin $display("Recived XO format isntruction");
								instructionFormat_o <= XO; 
								xOpCode_o <= payload_i[22:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[21];	
								enable_o <= 1;
							end
							136:begin $display("Recived XO format isntruction");
								instructionFormat_o <= XO; 
								xOpCode_o <= payload_i[22:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[21];	
								enable_o <= 1;
							end
							232:begin $display("Recived XO format isntruction");
								instructionFormat_o <= XO; 
								xOpCode_o <= payload_i[22:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[21];	
								enable_o <= 1;
							end
							202:begin $display("Recived XO format isntruction");
								instructionFormat_o <= XO; 
								xOpCode_o <= payload_i[22:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[21];	
								enable_o <= 1;
							end
							200:begin $display("Recived XO format isntruction");
								instructionFormat_o <= XO; 
								xOpCode_o <= payload_i[22:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[21];	
								enable_o <= 1;
							end
							104:begin $display("Recived XO format isntruction");
								instructionFormat_o <= XO; 
								xOpCode_o <= payload_i[22:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[21];	
								enable_o <= 1;
							end
							235:begin $display("Recived XO format isntruction");
								instructionFormat_o <= XO; 
								xOpCode_o <= payload_i[22:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[21];	
								enable_o <= 1;
							end
							75:begin $display("Recived XO format isntruction");
								instructionFormat_o <= XO; 
								xOpCode_o <= payload_i[22:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[21];	
								enable_o <= 1;
							end
							11:begin $display("Recived XO format isntruction");
								instructionFormat_o <= XO; 
								xOpCode_o <= payload_i[22:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[21];	
								enable_o <= 1;
							end
							491:begin $display("Recived XO format isntruction");
								instructionFormat_o <= XO; 
								xOpCode_o <= payload_i[22:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[21];	
								enable_o <= 1;
							end
							459:begin $display("Recived XO format isntruction");
								instructionFormat_o <= XO; 
								xOpCode_o <= payload_i[22:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[21];	
								enable_o <= 1;
							end
							427:begin $display("Recived XO format isntruction");
								instructionFormat_o <= XO; 
								xOpCode_o <= payload_i[22:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[21];	
								enable_o <= 1;
							end
							395:begin $display("Recived XO format isntruction");
								instructionFormat_o <= XO; 
								xOpCode_o <= payload_i[22:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[21];	
								enable_o <= 1;
							end
							233:begin $display("Recived XO format isntruction");
								instructionFormat_o <= XO; 
								xOpCode_o <= payload_i[22:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[21];	
								enable_o <= 1;
							end
							73:begin $display("Recived XO format isntruction");
								instructionFormat_o <= XO; 
								xOpCode_o <= payload_i[22:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[21];	
								enable_o <= 1;
							end
							9:begin $display("Recived XO format isntruction");
								instructionFormat_o <= XO; 
								xOpCode_o <= payload_i[22:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[21];	
								enable_o <= 1;
							end
							489:begin $display("Recived XO format isntruction");
								instructionFormat_o <= XO; 
								xOpCode_o <= payload_i[22:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[21];	
								enable_o <= 1;
							end
							457:begin $display("Recived XO format isntruction");
								instructionFormat_o <= XO; 
								xOpCode_o <= payload_i[22:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[21];	
								enable_o <= 1;
							end
							425:begin $display("Recived XO format isntruction");
								instructionFormat_o <= XO; 
								xOpCode_o <= payload_i[22:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[21];	
								enable_o <= 1;
							end
							393:begin $display("Recived XO format isntruction");
								instructionFormat_o <= XO; 
								xOpCode_o <= payload_i[22:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[21];	
								enable_o <= 1;
							end
							74:begin $display("Recived XO format isntruction");
								instructionFormat_o <= XO; 
								xOpCode_o <= payload_i[22:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[21];	
								enable_o <= 1;
							end
						endcase
						case(payload_i[21:29])//check for XS
							413: begin $display("Recived XS format isntruction, XO: %d", payload_i[21:29]);
								instructionFormat_o <= XO; 
								xOpCode_o <= payload_i[21:29]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[30]; bit2_o <= payload_i[31];
								enable_o <= 1;
							end
							445: begin $display("Recived XS format isntruction, XO: %d", payload_i[21:29]);
								instructionFormat_o <= XO; 
								xOpCode_o <= payload_i[21:29]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[30]; bit2_o <= payload_i[31];
								enable_o <= 1;
							end
						endcase
						case(payload_i[21:30])//check for X and XFX
							//X
							87:begin $display("Recived X format isntruction, XO: %d", payload_i[21:30]);
								instructionFormat_o <= X; 
								xOpCode_o <= payload_i[21:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[31];
								enable_o <= 1;
							end
							119:begin $display("Recived X format isntruction, XO: %d", payload_i[21:30]);
								instructionFormat_o <= X; 
								xOpCode_o <= payload_i[21:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[31];
								enable_o <= 1;
							end
							279:begin $display("Recived X format isntruction, XO: %d", payload_i[21:30]);
								instructionFormat_o <= X; 
								xOpCode_o <= payload_i[21:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[31];
								enable_o <= 1;
							end
							311:begin $display("Recived X format isntruction, XO: %d", payload_i[21:30]);
								instructionFormat_o <= X; 
								xOpCode_o <= payload_i[21:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[31];
								enable_o <= 1;
							end
							343:begin $display("Recived X format isntruction, XO: %d", payload_i[21:30]);
								instructionFormat_o <= X; 
								xOpCode_o <= payload_i[21:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[31];
								enable_o <= 1;
							end
							375:begin $display("Recived X format isntruction, XO: %d", payload_i[21:30]);
								instructionFormat_o <= X; 
								xOpCode_o <= payload_i[21:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[31];
								enable_o <= 1;
							end
							23:begin $display("Recived X format isntruction, XO: %d", payload_i[21:30]);
								instructionFormat_o <= X; 
								xOpCode_o <= payload_i[21:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[31];
								enable_o <= 1;
							end
							55:begin $display("Recived X format isntruction, XO: %d", payload_i[21:30]);
								instructionFormat_o <= X; 
								xOpCode_o <= payload_i[21:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[31];
								enable_o <= 1;
							end
							341:begin $display("Recived X format isntruction, XO: %d", payload_i[21:30]);
								instructionFormat_o <= X; 
								xOpCode_o <= payload_i[21:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[31];
								enable_o <= 1;
							end
							373:begin $display("Recived X format isntruction, XO: %d", payload_i[21:30]);
								instructionFormat_o <= X; 
								xOpCode_o <= payload_i[21:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[31];
								enable_o <= 1;
							end
							21:begin $display("Recived X format isntruction, XO: %d", payload_i[21:30]);
								instructionFormat_o <= X; 
								xOpCode_o <= payload_i[21:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[31];
								enable_o <= 1;
							end
							53:begin $display("Recived X format isntruction, XO: %d", payload_i[21:30]);
								instructionFormat_o <= X; 
								xOpCode_o <= payload_i[21:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[31];
								enable_o <= 1;
							end
							215:begin $display("Recived X format isntruction, XO: %d", payload_i[21:30]);
								instructionFormat_o <= X; 
								xOpCode_o <= payload_i[21:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[31];
								enable_o <= 1;
							end
							247:begin $display("Recived X format isntruction, XO: %d", payload_i[21:30]);
								instructionFormat_o <= X; 
								xOpCode_o <= payload_i[21:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[31];
								enable_o <= 1;
							end
							407:begin $display("Recived X format isntruction, XO: %d", payload_i[21:30]);
								instructionFormat_o <= X; 
								xOpCode_o <= payload_i[21:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[31];
								enable_o <= 1;
							end
							439:begin $display("Recived X format isntruction, XO: %d", payload_i[21:30]);
								instructionFormat_o <= X; 
								xOpCode_o <= payload_i[21:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[31];
								enable_o <= 1;
							end
							151:begin $display("Recived X format isntruction, XO: %d", payload_i[21:30]);
								instructionFormat_o <= X; 
								xOpCode_o <= payload_i[21:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[31];
								enable_o <= 1;
							end
							183:begin $display("Recived X format isntruction, XO: %d", payload_i[21:30]);
								instructionFormat_o <= X; 
								xOpCode_o <= payload_i[21:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[31];
								enable_o <= 1;
							end
							149:begin $display("Recived X format isntruction, XO: %d", payload_i[21:30]);
								instructionFormat_o <= X; 
								xOpCode_o <= payload_i[21:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[31];
								enable_o <= 1;
							end
							181:begin $display("Recived X format isntruction, XO: %d", payload_i[21:30]);
								instructionFormat_o <= X; 
								xOpCode_o <= payload_i[21:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[31];
								enable_o <= 1;
							end
							534:begin $display("Recived X format isntruction, XO: %d", payload_i[21:30]);
								instructionFormat_o <= X; 
								xOpCode_o <= payload_i[21:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[31];
								enable_o <= 1;
							end
							918:begin $display("Recived X format isntruction, XO: %d", payload_i[21:30]);
								instructionFormat_o <= X; 
								xOpCode_o <= payload_i[21:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[31];
								enable_o <= 1;
							end
							790:begin $display("Recived X format isntruction, XO: %d", payload_i[21:30]);
								instructionFormat_o <= X; 
								xOpCode_o <= payload_i[21:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[31];
								enable_o <= 1;
							end
							662:begin $display("Recived X format isntruction, XO: %d", payload_i[21:30]);
								instructionFormat_o <= X; 
								xOpCode_o <= payload_i[21:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[31];
								enable_o <= 1;
							end
							532:begin $display("Recived X format isntruction, XO: %d", payload_i[21:30]);
								instructionFormat_o <= X; 
								xOpCode_o <= payload_i[21:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[31];
								enable_o <= 1;
							end
							660:begin $display("Recived X format isntruction, XO: %d", payload_i[21:30]);
								instructionFormat_o <= X; 
								xOpCode_o <= payload_i[21:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[31];
								enable_o <= 1;
							end
							597:begin $display("Recived X format isntruction, XO: %d", payload_i[21:30]);
								instructionFormat_o <= X; 
								xOpCode_o <= payload_i[21:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[31];
								enable_o <= 1;
							end
							533:begin $display("Recived X format isntruction, XO: %d", payload_i[21:30]);
								instructionFormat_o <= X; 
								xOpCode_o <= payload_i[21:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[31];
								enable_o <= 1;
							end
							725:begin $display("Recived X format isntruction, XO: %d", payload_i[21:30]);
								instructionFormat_o <= X; 
								xOpCode_o <= payload_i[21:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[31];
								enable_o <= 1;
							end
							661:begin $display("Recived X format isntruction, XO: %d", payload_i[21:30]);
								instructionFormat_o <= X; 
								xOpCode_o <= payload_i[21:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[31];
								enable_o <= 1;
							end
							779:begin $display("Recived X format isntruction, XO: %d", payload_i[21:30]);
								instructionFormat_o <= X; 
								xOpCode_o <= payload_i[21:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[31];
								enable_o <= 1;
							end
							267:begin $display("Recived X format isntruction, XO: %d", payload_i[21:30]);
								instructionFormat_o <= X; 
								xOpCode_o <= payload_i[21:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[31];
								enable_o <= 1;
							end
							755:begin $display("Recived X format isntruction, XO: %d", payload_i[21:30]);
								instructionFormat_o <= X; 
								xOpCode_o <= payload_i[21:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[31];
								enable_o <= 1;
							end
							777:begin $display("Recived X format isntruction, XO: %d", payload_i[21:30]);
								instructionFormat_o <= X; 
								xOpCode_o <= payload_i[21:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[31];
								enable_o <= 1;
							end
							265:begin $display("Recived X format isntruction, XO: %d", payload_i[21:30]);
								instructionFormat_o <= X; 
								xOpCode_o <= payload_i[21:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[31];
								enable_o <= 1;
							end
							0:begin $display("Recived X format isntruction, XO: %d", payload_i[21:30]);
								instructionFormat_o <= X; 
								xOpCode_o <= payload_i[21:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[31];
								enable_o <= 1;
							end
							32:begin $display("Recived X format isntruction, XO: %d", payload_i[21:30]);
								instructionFormat_o <= X; 
								xOpCode_o <= payload_i[21:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[31];
								enable_o <= 1;
							end
							192:begin $display("Recived X format isntruction, XO: %d", payload_i[21:30]);
								instructionFormat_o <= X; 
								xOpCode_o <= payload_i[21:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[31];
								enable_o <= 1;
							end
							224:begin $display("Recived X format isntruction, XO: %d", payload_i[21:30]);
								instructionFormat_o <= X; 
								xOpCode_o <= payload_i[21:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[31];
								enable_o <= 1;
							end
							4:begin $display("Recived X format isntruction, XO: %d", payload_i[21:30]);
								instructionFormat_o <= X; 
								xOpCode_o <= payload_i[21:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[31];
								enable_o <= 1;
							end
							68:begin $display("Recived X format isntruction, XO: %d", payload_i[21:30]);
								instructionFormat_o <= X; 
								xOpCode_o <= payload_i[21:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[31];
								enable_o <= 1;
							end
							28:begin $display("Recived X format isntruction, XO: %d", payload_i[21:30]);
								instructionFormat_o <= X; 
								xOpCode_o <= payload_i[21:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[31];
								enable_o <= 1;
							end
							316:begin $display("Recived X format isntruction, XO: %d", payload_i[21:30]);
								instructionFormat_o <= X; 
								xOpCode_o <= payload_i[21:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[31];
								enable_o <= 1;
							end
							476:begin $display("Recived X format isntruction, XO: %d", payload_i[21:30]);
								instructionFormat_o <= X; 
								xOpCode_o <= payload_i[21:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[31];
								enable_o <= 1;
							end
							444:begin $display("Recived X format isntruction, XO: %d", payload_i[21:30]);
								instructionFormat_o <= X; 
								xOpCode_o <= payload_i[21:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[31];
								enable_o <= 1;
							end
							124:begin $display("Recived X format isntruction, XO: %d", payload_i[21:30]);
								instructionFormat_o <= X; 
								xOpCode_o <= payload_i[21:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[31];
								enable_o <= 1;
							end
							60:begin $display("Recived X format isntruction, XO: %d", payload_i[21:30]);
								instructionFormat_o <= X; 
								xOpCode_o <= payload_i[21:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[31];
								enable_o <= 1;
							end
							284:begin $display("Recived X format isntruction, XO: %d", payload_i[21:30]);
								instructionFormat_o <= X; 
								xOpCode_o <= payload_i[21:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[31];
								enable_o <= 1;
							end
							412:begin $display("Recived X format isntruction, XO: %d", payload_i[21:30]);
								instructionFormat_o <= X; 
								xOpCode_o <= payload_i[21:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[31];
								enable_o <= 1;
							end
							954:begin $display("Recived X format isntruction, XO: %d", payload_i[21:30]);
								instructionFormat_o <= X; 
								xOpCode_o <= payload_i[21:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[31];
								enable_o <= 1;
							end
							26:begin $display("Recived X format isntruction, XO: %d", payload_i[21:30]);
								instructionFormat_o <= X; 
								xOpCode_o <= payload_i[21:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[31];
								enable_o <= 1;
							end
							922:begin $display("Recived X format isntruction, XO: %d", payload_i[21:30]);
								instructionFormat_o <= X; 
								xOpCode_o <= payload_i[21:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[31];
								enable_o <= 1;
							end
							538:begin $display("Recived X format isntruction, XO: %d", payload_i[21:30]);
								instructionFormat_o <= X; 
								xOpCode_o <= payload_i[21:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[31];
								enable_o <= 1;
							end
							508:begin $display("Recived X format isntruction, XO: %d", payload_i[21:30]);
								instructionFormat_o <= X; 
								xOpCode_o <= payload_i[21:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[31];
								enable_o <= 1;
							end
							122:begin $display("Recived X format isntruction, XO: %d", payload_i[21:30]);
								instructionFormat_o <= X; 
								xOpCode_o <= payload_i[21:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[31];
								enable_o <= 1;
							end
							378:begin $display("Recived X format isntruction, XO: %d", payload_i[21:30]);
								instructionFormat_o <= X; 
								xOpCode_o <= payload_i[21:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[31];
								enable_o <= 1;
							end
							186:begin $display("Recived X format isntruction, XO: %d", payload_i[21:30]);
								instructionFormat_o <= X; 
								xOpCode_o <= payload_i[21:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[31];
								enable_o <= 1;
							end
							154:begin $display("Recived X format isntruction, XO: %d", payload_i[21:30]);
								instructionFormat_o <= X; 
								xOpCode_o <= payload_i[21:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[31];
								enable_o <= 1;
							end
							986:begin $display("Recived X format isntruction, XO: %d", payload_i[21:30]);
								instructionFormat_o <= X; 
								xOpCode_o <= payload_i[21:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[31];
								enable_o <= 1;
							end
							58:begin $display("Recived X format isntruction, XO: %d", payload_i[21:30]);
								instructionFormat_o <= X; 
								xOpCode_o <= payload_i[21:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[31];
								enable_o <= 1;
							end
							506:begin $display("Recived X format isntruction, XO: %d", payload_i[21:30]);
								instructionFormat_o <= X; 
								xOpCode_o <= payload_i[21:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[31];
								enable_o <= 1;
							end
							570:begin $display("Recived X format isntruction, XO: %d", payload_i[21:30]);
								instructionFormat_o <= X; 
								xOpCode_o <= payload_i[21:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[31];
								enable_o <= 1;
							end
							252:begin $display("Recived X format isntruction, XO: %d", payload_i[21:30]);
								instructionFormat_o <= X; 
								xOpCode_o <= payload_i[21:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[31];
								enable_o <= 1;
							end
							24:begin $display("Recived X format isntruction, XO: %d", payload_i[21:30]);
								instructionFormat_o <= X; 
								xOpCode_o <= payload_i[21:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[31];
								enable_o <= 1;
							end
							536:begin $display("Recived X format isntruction, XO: %d", payload_i[21:30]);
								instructionFormat_o <= X; 
								xOpCode_o <= payload_i[21:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[31];
								enable_o <= 1;
							end
							824:begin $display("Recived X format isntruction, XO: %d", payload_i[21:30]);
								instructionFormat_o <= X; 
								xOpCode_o <= payload_i[21:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[31];
								enable_o <= 1;
							end
							792:begin $display("Recived X format isntruction, XO: %d", payload_i[21:30]);
								instructionFormat_o <= X; 
								xOpCode_o <= payload_i[21:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[31];
								enable_o <= 1;
							end
							27:begin $display("Recived X format isntruction, XO: %d", payload_i[21:30]);
								instructionFormat_o <= X; 
								xOpCode_o <= payload_i[21:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[31];
								enable_o <= 1;
							end
							539:begin $display("Recived X format isntruction, XO: %d", payload_i[21:30]);
								instructionFormat_o <= X; 
								xOpCode_o <= payload_i[21:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[31];
								enable_o <= 1;
							end
							794:begin $display("Recived X format isntruction, XO: %d", payload_i[21:30]);
								instructionFormat_o <= X; 
								xOpCode_o <= payload_i[21:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[31];
								enable_o <= 1;
							end
							282:begin $display("Recived X format isntruction, XO: %d", payload_i[21:30]);
								instructionFormat_o <= X; 
								xOpCode_o <= payload_i[21:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[31];
								enable_o <= 1;
							end
							314:begin $display("Recived X format isntruction, XO: %d", payload_i[21:30]);
								instructionFormat_o <= X; 
								xOpCode_o <= payload_i[21:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[31];
								enable_o <= 1;
							end
							51:begin $display("Recived X format isntruction, XO: %d", payload_i[21:30]);
								instructionFormat_o <= X; 
								xOpCode_o <= payload_i[21:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[31];
								enable_o <= 1;
							end
							307:begin $display("Recived X format isntruction, XO: %d", payload_i[21:30]);
								instructionFormat_o <= X; 
								xOpCode_o <= payload_i[21:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[31];
								enable_o <= 1;
							end
							115:begin $display("Recived X format isntruction, XO: %d", payload_i[21:30]);
								instructionFormat_o <= X; 
								xOpCode_o <= payload_i[21:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[31];
								enable_o <= 1;
							end
							179:begin $display("Recived X format isntruction, XO: %d", payload_i[21:30]);
								instructionFormat_o <= X; 
								xOpCode_o <= payload_i[21:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[31];
								enable_o <= 1;
							end
							211:begin $display("Recived X format isntruction, XO: %d", payload_i[21:30]);
								instructionFormat_o <= X; 
								xOpCode_o <= payload_i[21:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[31];
								enable_o <= 1;
							end
							243:begin $display("Recived X format isntruction, XO: %d", payload_i[21:30]);
								instructionFormat_o <= X; 
								xOpCode_o <= payload_i[21:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[31];
								enable_o <= 1;
							end
							435:begin $display("Recived X format isntruction, XO: %d", payload_i[21:30]);
								instructionFormat_o <= X; 
								xOpCode_o <= payload_i[21:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[31];
								enable_o <= 1;
							end
							403:begin $display("Recived X format isntruction, XO: %d", payload_i[21:30]);
								instructionFormat_o <= X; 
								xOpCode_o <= payload_i[21:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[31];
								enable_o <= 1;
							end
							576:begin $display("Recived X format isntruction, XO: %d", payload_i[21:30]);
								instructionFormat_o <= X; 
								xOpCode_o <= payload_i[21:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[31];
								enable_o <= 1;
							end
							128:begin $display("Recived X format isntruction, XO: %d", payload_i[21:30]);
								instructionFormat_o <= X; 
								xOpCode_o <= payload_i[21:30]; 
								reg1_o <= payload_i[6:10]; reg2_o <= payload_i[11:15]; reg3_o <= payload_i[16:20];
								bit1_o <= payload_i[31];
								enable_o <= 1;
							end
							//XFX
							467:begin $display("Recived XFX format isntruction, XO: %d", payload_i[21:30]);
							instructionFormat_o <= XFX; 
							xOpCode_o <= payload_i[21:30]; 
							reg1_o <= payload_i[6:10]; imm_o <= payload_i[11:20];
							enable_o <= 1;
							end
							339:begin $display("Recived XFX format isntruction, XO: %d", payload_i[21:30]);
							instructionFormat_o <= XFX; 
							xOpCode_o <= payload_i[21:30]; 
							reg1_o <= payload_i[6:10]; imm_o <= payload_i[11:20];
							enable_o <= 1;
							end
							144:begin $display("Recived XFX format isntruction, XO: %d", payload_i[21:30]);
							instructionFormat_o <= XFX; 
							xOpCode_o <= payload_i[21:30]; 
							reg1_o <= payload_i[6:10]; imm_o <= payload_i[11:20];
							enable_o <= 1;
							end
							19:begin $display("Recived XFX format isntruction, XO: %d", payload_i[21:30]);
							instructionFormat_o <= XFX; 
							xOpCode_o <= payload_i[21:30]; 
							reg1_o <= payload_i[6:10]; imm_o <= payload_i[11:20];
							enable_o <= 1;
							end
							default: $display("ERROR: Invalid instruction");
						endcase
						
					end
					//A is split into 5 register fields, bit[31] not always used
					//Z23 uses three registers, one 3 bit field[31:32] (maybe use the imm there), XO[23:30], 1 bit at [31]
					//M is split into 5 register fields, bit [31] always used.
					//VA uses 4 register fields, bits [26:31] are the XO
					
					
					
					
					 
				endcase
			end
			else
			begin
				$display("ERROR: Instruction format is invalid");
				//TODO: Write out error, throw exception
				enable_o <= 0;
			end
		end
		else
			enable_o <= 0;
	end
	



endmodule
