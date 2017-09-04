module SRcontrol (
	input rst,
	input goHigh,
	input goLow,
	output reg dataClk);
	
	initial 
		dataClk <= 0;
	
	always @*  // NOTE: Ignore latch warning, intended behavior
		if (rst | goLow) 
			dataClk <= 0;
		else if (goHigh) 
			dataClk <= 1;
	
endmodule


module SRcontrol_testbench();
	logic rst;
	logic goHigh;
	logic goLow;
	logic dataClk;
	
	SRcontrol dut (.rst, .goHigh, .goLow, .dataClk);

	// Try all combinations of inputs.
	initial begin 
		goHigh <= 0; goLow <= 0; rst <= 1; #5;
		goHigh <= 0; goLow <= 0; rst <= 0; #5;
		goHigh <= 1; goLow <= 0; #5;
		goHigh <= 0; goLow <= 1; #5;
		goHigh <= 1; goLow <= 1; #5;
	end
	
endmodule
