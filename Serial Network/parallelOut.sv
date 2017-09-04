module parallelOut (
	input rst, 
	input serialDataIn,
	input dataClk,
	output [7:0] parallelDataOut);
	
	logic [7:0] temp;
	
	//serial to parallel 
	always_ff @(posedge dataClk or posedge rst) begin
		if (rst) begin
			temp <= 8'b00000000;
		end
		else begin
			temp <= {temp[6:0], serialDataIn};
		end
	end

	assign parallelDataOut = temp;
	
endmodule 
