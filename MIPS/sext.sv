module sext_16 (input logic [15:0] in,
				output logic [31:0] out);
				
always_comb
begin
	if (in[15]) out = 32'hffff0000+in;
	else out = 32'b0+in;
end
endmodule
