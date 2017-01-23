module ALU (input logic [31:0] A, B,
				input logic	[1:0] ALUK,
			   output logic [31:0] out);

always_comb begin
	case (ALUK)
		2'b00: out = A+B;
		2'b01: out = A & B;
		2'b10: out = ~A;
		2'b11: out = A-B;
	endcase
end

endmodule
