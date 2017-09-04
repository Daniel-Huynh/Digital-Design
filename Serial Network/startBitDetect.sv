module startBitDetect (
	input clk,
	input rst,
	input serialDataIn,
	input charReceived,
	output reg enable);
	
	enum {noMsg, holdMsg, recMsg} ps, ns;
	
	always_comb begin
		case (ps) 
			noMsg: begin
				enable = 0;
				if (!serialDataIn && !charReceived)
					ns = holdMsg;
				else 
					ns = noMsg;
			end
			holdMsg: begin
				enable = 1;
				ns = recMsg;
			end
			recMsg: begin
				enable = 1;
				if (charReceived) 
					ns = noMsg;
				else 
					ns = recMsg;
			end
		endcase 
	end
	
	always@(posedge clk) 
		if (rst)
			ps <= noMsg;
		else
			ps <= ns;
	
endmodule 