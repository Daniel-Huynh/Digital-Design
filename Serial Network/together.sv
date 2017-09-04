module together_testbench();
	logic clk, rst, load;
	logic charReceived;
	logic [7:0] parallelDataOut;
	//transmit
	logic [7:0] parallelDataIn;
	logic transmitEnable, charSent, serialDataOut;

	transmit dutt (.clk, .rst, .load, .parallelDataIn, .transmitEnable, .charSent, .serialDataOut);
	receive dutr (.clk, .rst, .serialDataIn(serialDataOut), .charReceived, .parallelDataOut);

	
	//Set up the clock
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end

	//Set up the inputs to the design 
	initial begin 
		rst <= 1; load <= 0; transmitEnable <= 0; parallelDataIn <= 8'b00000000; @(posedge clk);
		rst <= 0; load <= 1; transmitEnable <= 1; parallelDataIn <= 8'b10101010; @(posedge clk);
		rst <= 0; load <= 0; transmitEnable <= 1; parallelDataIn <= 8'b00001111; repeat(9) @(posedge dutt.dataClk);
		rst <= 0; load <= 0; transmitEnable <= 1; parallelDataIn <= 8'b00001111; repeat(200) @(posedge clk);
		$stop; //End the simulation
	end
	
endmodule
