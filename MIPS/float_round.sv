module left_shift (input [54:0] A,  input [7:0] shift, output logic [54:0] out); 

  assign out = A << shift;
endmodule


module float_round( input clk,
			 input reset,
			 input execute,
			 input [31:0] in,
			 output logic [31:0] out,
			 output logic ready);
			 
    logic [54:0] result, shift_out;
	 logic [7:0] exp_diff;
	 logic sign, active, exception;
	 
	 assign ready = active;
	 
	 left_shift shift_55(.A(result), .shift(exp_diff), .out(shift_out));

    always_ff @ (posedge clk) begin
	     if (reset) begin
			   sign <= 1'b0;
				exp_diff <= 8'b0;
				active <= 1'b0;
				exception <= 1'b0;
				result <= 54'b0;
		  end
		  
		  else begin
		      if (execute) begin
				    sign <= in[31];
					 exp_diff <= in[30:23] - 8'b01111111;
					 result <= {31'b0, 1'b1, in[22:0]};
				    active <= 1'b1;
					 exception <= 1'b0;
				end
				
				else if (active) begin
					 if (exp_diff[7] == 1'b0 && exp_diff > 8'b00011110) begin // exp > 30
						  if (sign ==1'b0) out <= 32'b01111111111111111111111111111111;
						  else out <= 32'b10000000000000000000000000000000;
						  exception <= 1'b1;
					 end
					 else if (exp_diff == 8'b11111111) begin // exp = -1
						  if (sign == 1'b0) out <= 32'b00000000000000000000000000000001;
						  else out <= 32'b11111111111111111111111111111111;
						  exception <= 1'b1;
					 end
					 else if (exp_diff[7] == 1'b1) begin // exp <= -2
						  out <= 32'b00000000000000000000000000000000;
						  exception <= 1'b1;
					 end
					 else begin
					     exception <= 1'b0;
					 end
					 active <= 1'b0;
				end

				else begin
				    if (exception == 1'b1) out <= out;
					 else begin
					     if (result[22] == 1'b0) begin // round down towards zero
						      if (sign == 1'b0) out <= shift_out[54:23];
								else out <= ~shift_out[54:23] + 32'b1;
						  end
						  else begin
						      if (sign == 1'b0) out <= shift_out[54:23] + 32'b1;
								else out <= ~shift_out[54:23];
						  end
					 end
				end
		  end
    end

endmodule