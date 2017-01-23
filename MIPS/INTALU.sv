module BIGALU(input logic clk, reset,
				  input logic [31:0] A, B,
				  input logic [1:0] ALUK,
				  input logic [3:0] ALUMUX,
				  input logic INT_EXE,
				  output logic INTMULT_READY,
				  output logic INTDIV_READY,
			     output logic [31:0] out1, out2);

logic [31:0] ALU_OUT, MULT_OUT, QUO_OUT, REM_OUT;

assign out2 = REM_OUT;

ALU ALU(.A(A), .B(B), .ALUK(ALUK), .out(ALU_OUT));				  
int_mult multiply(.*, .execute(INT_EXE), .val1(A[15:0]), .val2(B[15:0]), .out(MULT_OUT), .ready(INTMULT_READY));
int_div division(.*, .execute(INT_EXE), .dividend(A), .divisor(B), .quotient(QUO_OUT), .remainder(REM_OUT), .ready(INTDIV_READY));
mux16_1 BIGALUMUX(.inA(ALU_OUT), .inB(MULT_OUT), .inC(QUO_OUT), .inD(A), .inE(32'b0), .inF(32'b0), .inG(32'b0), .inH(32'b0), .inI(32'b0), .inJ(32'b0), .inK(32'b0), .inL(32'b0), .inM(32'b0), .inN(32'b0), .inO(32'b0), .inP(32'b0), .control(ALUMUX), .out(out1));

endmodule
