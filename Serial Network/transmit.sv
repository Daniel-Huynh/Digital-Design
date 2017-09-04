module transmit (
	input clk, //16x clock
	input rst, 
	input load, 
	input [7:0] parallelDataIn,
	input transmitEnable,
	output charSent,
	output serialDataOut);
	
	wire incr, goHigh, goLow, dataClk, reset;
	reg enable, autoReset;
	assign reset = rst | autoReset;
	always_comb begin
		if (transmitEnable & !charSent) begin
			enable = 1'b1;
			autoReset = 1'b0;
		end
		else if (!transmitEnable & charSent) begin
			enable = 1'b0;
			autoReset = 1'b1;
		end
		else begin
			enable = 1'b0;
			autoReset = 1'b0;
		end
	end
	
	BSC bitSamplingCounter (.clk, .rst(reset), .enable, .out(), .startBit(), .middleBit(goHigh), .endBit(incr));
	BIC bitIDcounter (.clk, .rst(reset), .enable, .incr, .out(), .done(charSent));
	assign goLow = incr;
	SRcontrol clkGen (.rst(reset), .goHigh, .goLow, .dataClk);
	serialOut dataOut (.rst(reset), .parallelDataIn, .load, .dataClk, .serialDataOut);
	
endmodule

module transmit_testbench();
	logic clk, rst, load;
	logic [7:0] parallelDataIn;
	logic transmitEnable, charSent, serialDataOut;
	
	transmit dut (.clk, .rst, .load, .parallelDataIn, .transmitEnable, .charSent, .serialDataOut);
	
	//Set up the clock
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end
	
	// Try all combinations of inputs.
	initial begin 
		// Explicit reset & first transmission
		rst <= 1; load <= 0; transmitEnable <= 0; parallelDataIn <= 8'b00000000; @(posedge clk);
		rst <= 0; load <= 1; transmitEnable <= 1; parallelDataIn <= 8'b10101010; @(posedge clk);
		rst <= 0; load <= 0; transmitEnable <= 1; parallelDataIn <= 8'b00001111; repeat(9) @(posedge dut.dataClk);
		// second transmission
		@(posedge charSent);
		rst <= 0; load <= 0; transmitEnable <= 0; parallelDataIn <= 8'b00000000; repeat(16) @(posedge clk);
		rst <= 0; load <= 1; transmitEnable <= 1; parallelDataIn <= 8'b01010101; @(posedge clk);
		rst <= 0; load <= 0; transmitEnable <= 1; parallelDataIn <= 8'b00001111; @(posedge clk);
		@(posedge charSent);
		repeat(50) @(posedge clk);
		$stop;
	end
	
endmodule
