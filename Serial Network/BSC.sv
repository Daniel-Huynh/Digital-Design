module BSC (
	input clk, 
	input rst, 
	input enable,
	output [3:0] out,
	output startBit,
	output middleBit,
	output endBit);
	
	logic [3:0] counter;
	
	assign out = counter; 
	assign startBit = (counter == 4'b0000);
	assign middleBit = (counter == 4'b0111);
	assign endBit = (counter == 4'b1111);
		 
	always_ff @(posedge clk) begin
		if (rst) 
			counter <= 4'b0000;
		else if (enable)
			counter <= counter + 4'b0001;
	end
			
endmodule


module BSC_testbench();
	logic clk, rst, enable;
	logic [3:0] out;
	logic startBit, middleBit, endBit;
	
	BSC dut (.clk, .rst, .enable, .out, .startBit, .middleBit, .endBit);
	
	//Set up the clock
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end

	//Set up the inputs to the design 
	initial begin 
											@(posedge clk);
		rst <= 1; enable <= 0;		@(posedge clk);
		rst <= 0;						@(posedge clk);
					 enable <= 1;		repeat(10) @(posedge clk);
		$stop; //End the simulation
	end
endmodule
