module receive (
	input clk, //16x clock
	input rst, 
	input serialDataIn,
	output charReceived,
	output [7:0] parallelDataOut);
	
	wire enable, incr, goHigh, goLow, dataClk;
	
	startBitDetect startBit (.clk, .rst, .serialDataIn, .charReceived, .enable);
	
	BSC bitSamplingCounter (.clk, .rst, .enable, .out(), .startBit(), .middleBit(goHigh), .endBit(incr));
	BIC bitIDcounter (.clk, .rst, .enable, .incr, .out(), .done(charReceived));
	assign goLow = incr;
	SRcontrol clkGen (.rst, .goHigh, .goLow, .dataClk);
	parallelOut dataIn (.rst, .serialDataIn, .dataClk, .parallelDataOut);
	
	
endmodule

module receive_testbench();
	logic clk, rst;
	logic serialDataIn;
	logic charReceived;
	logic [7:0] parallelDataOut;
	
	receive dut (.clk, .rst, .serialDataIn, .charReceived, .parallelDataOut);
	
	//Set up the clock
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end
	
	// Try all combinations of inputs.
	initial begin
		// Explicit reset & first transmission
		rst <= 1; serialDataIn <= 1; @(posedge clk);
		rst <= 0; serialDataIn <= 1; repeat(16) @(posedge clk);
		rst <= 0; serialDataIn <= 0; repeat(16) @(posedge clk);
		rst <= 0; serialDataIn <= 1; repeat(16) @(posedge clk);
		rst <= 0; serialDataIn <= 0; repeat(16) @(posedge clk);
		rst <= 0; serialDataIn <= 1; repeat(16) @(posedge clk);
		rst <= 0; serialDataIn <= 0; repeat(16) @(posedge clk);
		rst <= 0; serialDataIn <= 1; repeat(16) @(posedge clk);
		rst <= 0; serialDataIn <= 0; repeat(16) @(posedge clk);
		rst <= 0; serialDataIn <= 1; repeat(16) @(posedge clk);
		rst <= 0; serialDataIn <= 0; repeat (16) @(posedge clk);
//		rst <= 0; serialDataIn <= 1; repeat (20) @(posedge clk);
		// Second transmission
		rst <= 0; serialDataIn <= 1; repeat(16) @(posedge clk);
		rst <= 0; serialDataIn <= 0; repeat(16) @(posedge clk);
		rst <= 0; serialDataIn <= 0; repeat(16) @(posedge clk);
		rst <= 0; serialDataIn <= 1; repeat(16) @(posedge clk);
		rst <= 0; serialDataIn <= 0; repeat(16) @(posedge clk);
		rst <= 0; serialDataIn <= 1; repeat(16) @(posedge clk);
		rst <= 0; serialDataIn <= 0; repeat(16) @(posedge clk);
		rst <= 0; serialDataIn <= 1; repeat(16) @(posedge clk);
		rst <= 0; serialDataIn <= 0; repeat(16) @(posedge clk);
		rst <= 0; serialDataIn <= 1; repeat(16) @(posedge clk);
		rst <= 0; serialDataIn <= 1; repeat (16) @(posedge clk);
		$stop;
	end
	
endmodule
