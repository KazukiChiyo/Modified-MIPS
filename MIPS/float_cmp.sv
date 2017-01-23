module denormalize_23 (input [22:0] A,  input [7:0] shift, output logic [22:0] out); 

  assign out = A >> shift;
endmodule


module float_cmp( input clk,
			 input reset,
			 input execute,
			 input [31:0] A,
			 input [31:0] B,
			 output logic [1:0] out,
			 output logic ready); 

	 logic [22:0] shift_out_A, shift_out_B;
	 logic A_sign, B_sign, greater, active; // if A > B greater := 1'b0; else greater := 1'b1
	 logic [22:0] A_frac, B_frac, frac_diff;
	 logic [7:0] A_exp, B_exp, exp_diff;
	 logic [3:0] status;

    denormalize_23 shift_A (.A(A_frac), .shift(exp_diff), .out(shift_out_A));
    denormalize_23 shift_B (.A(B_frac), .shift(exp_diff), .out(shift_out_B));
	 assign ready = active;

	 always_ff @ (posedge clk) begin
	     if (reset) begin
			   A_sign <= 1'b0;
				B_sign <= 1'b0;
				A_frac <= 23'b0;
				B_frac <= 23'b0;
				A_exp <= 8'b0;
				B_exp <= 8'b0;
				greater <= 1'b0;
				exp_diff <= 8'b0;
		      status <= 3'b000;
				frac_diff <= 23'b0;
				active <= 1'b0;
		  end
		  else begin
			  if (execute) begin
					A_sign <= A[31];
					B_sign <= B[31];
					A_frac <= A[22:0];
					B_frac <= B[22:0];
					A_exp <= A[30:23] - 8'b01111111;
					B_exp <= B[30:23] - 8'b01111111;
					greater <= 1'b0;
					exp_diff <= 8'b0;
					status <= 3'b000;
					frac_diff <= 23'b0;
					active <= 1'b1;
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
				  
				  else if (status == 3'b010) begin // wait for shift
						status <= 3'b011;
				  end
				  
				  else if (status == 3'b011) begin // allign exponents and determine which fraction part is greater
				      if (greater == 1'b1)
						    frac_diff <= A_frac - shift_out_B;
						else
						    frac_diff <= shift_out_A - B_frac;
						active <= 1'b0;
				  end
			end
			
         else begin //add result and determine sign
				 if (A_sign == 1'b0 && B_sign == 1'b0) begin // if A > 0 and B > 0
                 if (frac_diff == 23'b0) out <= 2'b00;
					  else if (frac_diff[22] == 1'b1) out <= 2'b11;
					  else out <= 2'b01;
				 end
				 else if (A_sign == 1'b0 && B_sign == 1'b1) out <= 2'b01; // if A > 0 and B < 0
				 else if (A_sign == 1'b1 && B_sign == 1'b0) out <= 2'b11; // if A < 0 and B > 0
				 else begin // if A < 0 and B < 0
                 if (frac_diff == 23'b0) out <= 2'b00;
					  else if (frac_diff[22] == 1'b1) out <= 2'b01;
					  else out <= 2'b11;
			    end
		   end
      end
    end
endmodule