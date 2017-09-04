module serialOut (
	input rst, 
	input [7:0] parallelDataIn, 
	input load, 
	input dataClk, 
	output reg serialDataOut);
	
	logic [8:0] temp;
	
	//parallel to serial 
	always_ff @(posedge dataClk or posedge load or posedge rst) begin
		if (rst) begin
			temp <= 9'b111111111;
			serialDataOut <= 1;
		end else if (load) begin
			temp <= {1'b0, parallelDataIn};
			serialDataOut <= 1;
		end else begin 
			serialDataOut <= temp[8];
			temp <= {temp[7:0], 1'b1};
		end
	end 

	
endmodule 

	