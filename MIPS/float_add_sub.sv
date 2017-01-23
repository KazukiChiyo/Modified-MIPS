module denormalize_24 (input [24:0] A,  input [7:0] shift, output logic [24:0] out); 

  assign out = A >> shift;
endmodule


module float_add_sub( input clk,
			 input reset,
			 input select,
			 input execute,
			 input [31:0] A,
			 input [31:0] B,
			 output logic [31:0] out,
			 output logic ready); 

	 logic [24:0] shift_out_A, shift_out_B;
	 logic A_sign, B_sign, out_sign, greater, active; // if A > B greater := 1'b0; else greater := 1'b1
	 logic [24:0] A_frac, B_frac, result; // 0-extented to fit over flow bit and hidden bit
	 logic [22:0] frac_diff;
	 logic [7:0] A_exp, B_exp, exp_diff, out_exp;
	 logic [3:0] status;
	 logic debug;

    denormalize_24 shift_A (.A(A_frac), .shift(exp_diff), .out(shift_out_A));
    denormalize_24 shift_B (.A(B_frac), .shift(exp_diff), .out(shift_out_B));
	 assign ready = active;

	 always_ff @ (posedge clk) begin
	     if (reset) begin
			   A_sign <= 1'b0;
				B_sign <= 1'b0;
				out_sign <= 1'b0;
				A_frac <= 25'b0;
				B_frac <= 25'b0;
				A_exp <= 8'b0;
				B_exp <= 8'b0;
				greater <= 1'b0;
				exp_diff <= 8'b0;
		      status <= 3'b000;
				result <= 25'b0;
				out_exp <= 8'b0;
				frac_diff <= 23'b0;
				active <= 1'b0;
		  end
		  else begin
			  if (execute) begin
					A_sign <= A[31];
					if (select == 1'b0) B_sign <= B[31];
					else B_sign <= ~B[31];
					A_frac <= {1'b0, 1'b1, A[22:0]};
					B_frac <= {1'b0, 1'b1, B[22:0]};
					A_exp <= A[30:23] - 8'b01111111;
					B_exp <= B[30:23] - 8'b01111111;
					greater <= 1'b0;
					exp_diff <= 8'b0;
					status <= 3'b000;
					result <= 24'b0;
					out_exp <= 8'b0;
					frac_diff <= 23'b0;
					active <= 1'b1;
					debug <= 1'b0;
			  end
			  
			  else if (active) begin
				  if (status == 3'b000) begin
						exp_diff <= A_exp - B_exp;
						status <= 3'b001;
				  end
				  
				  else if (status == 3'b001) begin
						if (exp_diff[7] == 1'b1) begin // B > A
							 exp_diff <= ~exp_diff + 8'b1;
							 greater <= 1'b1;
						end
						else greater <= 1'b0;
						status <= 3'b010;
				  end
				  
				  else if (status == 3'b010) begin // set exponents
						if (greater == 1'b0) out_exp <= A_exp;
						else out_exp <= B_exp; 
						status <= 3'b011;
				  end
				  
				  else if (status == 3'b011) begin // allign exponents and determine which fraction part is greater
				  		if (greater == 1'b0) begin // B > A
						    frac_diff <= A_frac[22:0] - shift_out_B[22:0];
							 B_frac <= shift_out_B;
						end
						else begin
						    frac_diff <= shift_out_A[22:0] - B_frac[22:0];
							 A_frac <= shift_out_A;
						end
						status <= 3'b100;
				  end
				  
				  else if (status == 3'b100) begin //add result and determine sign
						if (A_sign == 1'b0 && B_sign == 1'b0) begin
							 result <= A_frac + B_frac;
							 out_sign <= 1'b0;
						end
						else if (A_sign == 1'b0 && B_sign == 1'b1) begin
							 if (frac_diff[22] == 1'b1) begin
								  result <= B_frac - A_frac;
								  out_sign <= 1'b1;
							 end
							 else begin
								  result <= A_frac - B_frac;
								  out_sign <= 1'b0;
							 end
						end
						else if (A_sign == 1'b1 && B_sign == 1'b0) begin
							 if (frac_diff[22] == 1'b1) begin
								  result <= B_frac - A_frac;
								  out_sign <= 1'b0;
							 end
							 else begin
								  result <= A_frac - B_frac;
								  out_sign <= 1'b1;
							 end
						end
						else begin
							 out_sign <= 1'b1;
							 result <= A_frac + B_frac;
						end
						status <= 3'b101;
				  end
				  
				  else if (status == 3'b101) begin // check for fraction overflow
				      if (result == 25'b0 && exp_diff == 8'b0) begin // if the result is zero
						    out_sign <= 1'b0;
							 out_exp <= 8'b0;
							 result <= 25'b0;
						end
						else if (result[24] == 1'b1) begin
							 out_exp <= out_exp + 8'b1 + 8'b01111111;
							 result <= {1'b0, result[24:1]};
						end
						else begin
							 result <= result;
							 out_exp <= out_exp + 8'b01111111;
						end
						active <= 1'b0;
				  end
			  end
			  
			  else begin // send output
				   debug <= 1'b1;
					out <= {out_sign, out_exp, result[22:0]};
			  end
		  end
    end
endmodule