`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//When a pipeline stage stalls, this unit recives a stall signal from the stage and stalls the relevent pipeline stages
//NOTE: This pipeline stage operates on the negative edge of the clock becasue if a stage is to stall, it will stall on the rising edge,
//provide the stall signal and before the next rising edge; this unit will have recived the stall and taken action.
//////////////////////////////////////////////////////////////////////////////////
module StallUnit(
    input clock_i,
	 //stall inputs
	 input wire fetchCacheMissStall_i,
	 input wire regFileStall_i,
	 //input wire storeStall_i,//
	 
	 //output reg output stall lines
	 output reg fetchFullStall_o,
	 output reg fetchTagQueryStall_o
    );

	always @(negedge clock_i)
	begin
		if(fetchCacheMissStall_i == 1)//check for a stall due to cache miss
		begin
			//$display("Stalling on cache miss");
			fetchTagQueryStall_o <= 1;
		end
		else
		begin
			fetchFullStall_o <= 0;
			fetchTagQueryStall_o <= 0;
		end
		
		if(regFileStall_i == 1)//check to see if the reg file needs to stall the earlier pipeline stages (decode, fetch)
		begin
			fetchFullStall_o <= 1;
		end
		else
		begin
		end
	end

endmodule
