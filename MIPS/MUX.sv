module  mux2_1(input logic [31:0]inA,
					input logic [31:0]inB,
					input logic control,
					output logic [31:0]out);

	always_comb	
	begin
		if(control == 1'b0)
			out = inA;
		else
			out = inB;
	end
	
endmodule

module	mux4_1 (input logic	[31:0]inA,
					  input logic  [31:0]inB,
					  input logic  [31:0]inC,
					  input logic  [31:0]inD,
					  input logic  [1:0]control,
					  output logic [31:0]out);
					  
	always_comb	
		if(control == 2'b00)
			begin
				out = inA;
			end
		else if(control == 2'b01)
			begin
				out = inB;
			end
		else if(control == 2'b10)
			begin
				out = inC;
			end
		else
			begin
				out = inD;
			end
endmodule

module	mux16_1 (input logic	[31:0]inA,
					   input logic  [31:0]inB,
					   input logic  [31:0]inC,
					   input logic  [31:0]inD,
					   input logic  [31:0]inE,
					   input logic  [31:0]inF,
					   input logic  [31:0]inG,
					   input logic  [31:0]inH,
						input logic  [31:0]inI,
					   input logic  [31:0]inJ,
					   input logic  [31:0]inK,
					   input logic  [31:0]inL,
					   input logic  [31:0]inM,
					   input logic  [31:0]inN,
					   input logic  [31:0]inO,
						input logic  [31:0]inP,
					   input logic  [3:0]control,
					   output logic [31:0]out);
					  
	always_comb	
		unique case (control)
			4'b0000: out = inA;
			4'b0001: out = inB;
			4'b0010: out = inC;
			4'b0011: out = inD;
			4'b0100: out = inE;
			4'b0101: out = inF;
			4'b0110: out = inG;
			4'b0111: out = inH;
			4'b1000: out = inI;
			4'b1001: out = inJ;
			4'b1010: out = inK;
			4'b1011: out = inL;
			4'b1100: out = inM;
			4'b1101: out = inN;
			4'b1110: out = inO;
			4'b1111: out = inP;
		endcase
endmodule

module	mux4_1_3b (input logic	[2:0]inA,
						  input logic  [2:0]inB,
					     input logic  [2:0]inC,
					     input logic  [2:0]inD,
					     input logic  [1:0]control,
					     output logic [2:0]out);
					  
	always_comb	
		if(control == 2'b00)
			begin
				out = inA;
			end
		else if(control == 2'b01)
			begin
				out = inB;
			end
		else if(control == 2'b10)
			begin
				out = inC;
			end
		else
			begin
				out = inD;
			end
endmodule

