`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//When a pipeline stage stalls, this unit recives a stall signal from the stage and stalls the relevent pipeline stages
//NOTE: This pipeline stage operates on the negative edge of the clock becasue if a stage is to stall, it will stall on the rising edge,
//provide the stall signal and before the next rising edge; this unit will have recived the stall and taken action.
//////////////////////////////////////////////////////////////////////////////////
module StallUnit(
    input clock_i,
    input reset_i
    );

	always @(negedge clock_i)
	begin
		
	end

endmodule
