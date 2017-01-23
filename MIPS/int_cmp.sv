module int_cmp (
    input clk,
    input reset,
	 input execute,
    input [31:0] A,
    input [31:0] B,
    output logic [1:0] result);
  
	 logic [31:0] A_temp, B_temp;
	 logic [31:0] diff;
	 logic [1:0] status;
	 
	 always_ff @ (posedge clk) begin
		  if (reset) begin
		      A_temp <= 32'b0;
				B_temp <= 32'b0;
				diff <= 32'b0;
				status <= 1'b0;
		  end
	     else if (execute) begin
		      A_temp <= A;
				B_temp <= B;
				diff <= 32'b0;
		      status <= 1'b0;
		  end
		  else if (status == 1'b0) begin
		      diff <= A - B;
		      status <= 1'b1;
		  end
		  else begin
		      if (diff == 32'b0) result <= 2'b00; //if A = B
				else if (diff[31] == 1'b0) result <= 2'b01; //if A > B
				else result <= 2'b11; //if A < B
		  end
	 end
endmodule