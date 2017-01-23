module jump_if (input clk,
			 input reset,
			 input execute,
			 input [1:0] co,
			 input [1:0] cond,
			 output jmp);

	always_ff @ (posedge clk or posedge reset) begin
		if (reset) jmp <= 1'b0;
		else if (execute) begin
			if (co[1]~^cond[1] & co[0]~^cond[0]) jmp <= 1'b1;
			else jmp <= 1'b0;
		end
	end
endmodule