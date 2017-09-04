module BIC (
	input clk, 
	input rst, 
	input enable, 
	input incr,
	output [3:0] out,
	output done);
	
	logic [3:0] counter;
	
	assign out = counter; 
	assign done = (counter == 4'b1001);
		 
	always_ff @(posedge clk) begin
		if (rst) 
			counter <= 4'b0000;
		else if (enable && counter == 4'b1001)
			counter <= counter;
		else if (incr & enable)
			counter <= counter + 4'b0001;
	end
			
endmodule
