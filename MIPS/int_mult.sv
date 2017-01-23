module int_mult( input clk,
			 input reset,
			 input execute,
			 input [15:0] val1,
			 input [15:0] val2,
			 output logic [31:0] out,
			 output logic ready); 
			 
logic sign, active, add;
logic [15:0] A, B, S;
logic [4:0] cycle;
assign ready = active;

always_ff @ (posedge clk) begin
	if (reset) begin
		sign <= 0;
		active <= 0;
		add <= 0;
		cycle <= 0;
		out <= 32'b0;
		S <= 16'b0;
	end
	else begin
		if (execute) begin
			cycle <= 5'b0;
			sign <= val1[15] ^ val2[15];
			A <= 16'b0;
			if (val1[15] == 1'b0) B[15:0] <= val1;
			else B[15:0] <= ~val1+16'b1;
			if (val2[15] == 1'b0) S <= val2;
			else S <= ~val2+1'b1;
			active <= 1'b1;
			add <= 1'b0;
		end	
		else if (active) begin
			if (add == 1'b0) begin
				if (B[0] == 1'b1) A <= A+S;
				add <= 1'b1;
			end
			else begin
				B <= {A[0], B[15:1]};
				A <= {1'b0, A[15:1]};
				if (cycle == 5'b11111) active <= 0;
				add <= 1'b0;
			end
			cycle <= cycle+5'b00001;
		end
		else begin
			if (sign == 1'b0) out <= {A, B};
			else out <= ~{A, B}+32'b1;
		end
	end	
end
endmodule


