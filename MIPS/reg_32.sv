module reg_32 (input  logic clk, reset, load,
               input  logic [31:0]  data_in, 
               output logic [31:0]  data_out);

    always_ff @ (posedge clk)
    	if (load)
		begin
			  data_out <= data_in;
		end
	 	else if (reset) 
		begin
			  data_out <= 32'b0;
		end

endmodule

