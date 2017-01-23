module slc3pp (input logic clk, reset, run,
				   input logic [31:0] TESTSIG, TESTSIG2,
					output logic [31:0] TEST_OUT);
 
logic LD_IR, LD_PC, LD_REG, LD_MAR, LD_MDR, MIO_EN;
logic GATE_PC, GATE_MDR, GATE_ADDER, GATE_ALU;
logic [3:0] ALUMUX;
logic [1:0] ALUK, PCMUX, ADDR2MUX;
logic SR2MUX, ADDR1MUX;
logic [31:0] BIGALU_OUT1, BIGALU_OUT2, G_BUS1, G_BUS2, IR_OUT, PC_IN, PC_OUT, PC_NEW, ADDERMUX_OUT, SR1_OUT, SR2_OUT, IR_OUT16, SR2MUX_OUT, ADDR1MUX_OUT, ADDR2MUX_OUT, MAR_OUT, MDR_IN, MDR_OUT, ADDER_OUT;
logic INTMULT_READY, INTDIV_READY, INT_EXE, FPROUND_READY;	

assign PC_NEW = PC_OUT+32'b1;
assign ADDER_OUT = ADDR1MUX_OUT+ADDR2MUX_OUT;

ISDU	ISDU(.*, .intmult_ready(INTMULT_READY), .intdiv_ready(INTDIV_READY), .fpround_ready(FPROUND_READY), .opcode(IR_OUT[31:26]), .func(IR_OUT[5:0]), .int_exe(INT_EXE));

BIGALU BIGALU(.*, .A(SR1_OUT), .B(SR2MUX_OUT), .ALUK(ALUK), .ALUMUX(ALUMUX), .INT_EXE(INT_EXE), .INTMULT_READY(INTMULT_READY), .INTDIV_READY(INTDIV_READY), .out1(BIGALU_OUT1), .out2(BIGALU_OUT2));

global_bus G_BUS(.pc(PC_OUT), .mdr(MDR_OUT), .adder(ADDER_OUT), .alu1(BIGALU_OUT1), .alu2(BIGALU_OUT2), .g_pc(GATE_PC), .g_mdr(GATE_MDR), .g_adder(GATE_ADDER), .g_alu(GATE_ALU), .g_bus1(G_BUS1), .g_bus2(G_BUS2));

reg_file REG_FILE(.*, .LD_REG(LD_REG), .DR(IR_OUT[25:21]), .SR1(IR_OUT[20:16]), .SR2(IR_OUT[15:11]), .data_in(G_BUS1), .data_in2(G_BUS2), .sr1_out(SR1_OUT), .sr2_out(SR2_OUT));

reg_32 IR(.*, .load(1'b1), .data_in(TESTSIG), .data_out(IR_OUT)); // ?
reg_32 PC(.*, .load(LD_PC), .data_in(PC_IN), .data_out(PC_OUT));
reg_32 MAR(.*, .load(LD_MAR), .data_in(G_BUS1), .data_out(MAR_OUT));
reg_32 MDR(.*, .load(LD_MDR), .data_in(MDR_IN), .data_out(MDR_OUT));

mux4_1 PC_MUX(.inA(PC_NEW), .inB(ADDERMUX_OUT), .inC(G_BUS1), .inD(32'b0), .control(PCMUX), .out(PC_IN));
mux2_1 SR2_MUX(.inA(SR2_OUT), .inB(IR_OUT16), .control(SR2MUX), .out(SR2MUX_OUT));
mux2_1 ADDR1_MUX(.inA(PC_OUT), .inB(SR1_OUT), .control(ADDR1MUX), .out(ADDR1MUX_OUT));
mux4_1 ADDR2_MUX(.inA(32'b0), .inB(32'b0), .inC(IR_OUT16), .inD(32'b0), .control(ADDR2MUX), .out(ADDR2MUX_OUT)); // ?
mux2_1 MDR_MUX(.inA(32'b0), .inB(G_BUS1), .control(MIO_EN), .out(MDR_IN)); // ?

sext_16 SEXT_16(.in(IR_OUT[15:0]), .out(IR_OUT16));

//float_round test(.*, .execute(INT_EXE), .in(TESTSIG), .out(TEST_OUT), .ready(FPROUND_READY));
//float_cmp test(.*, .execute(INT_EXE), .A(TESTSIG), .B(TESTSIG2), .out(TEST_OUT), .ready(FPROUND_READY));
float_add_sub test(.*, .select(1'b0), .execute(INT_EXE), .A(TESTSIG), .B(TESTSIG2), .out(TEST_OUT), .ready(FPROUND_READY));

endmodule
