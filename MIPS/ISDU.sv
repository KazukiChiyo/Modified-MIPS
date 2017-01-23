module ISDU (input clk,
				 input reset,
				 input run,
				 input intmult_ready,
				 input intdiv_ready,
				 input fpround_ready,
			    input [5:0] opcode,
			    input [5:0] func,
				 output logic int_exe,
				 output logic [3:0] ALUMUX,
				 output logic [1:0] ALUK, PCMUX, ADDR2MUX,
				 output logic SR2MUX, ADDR1MUX,
				 output logic GATE_PC, GATE_MDR, GATE_ADDER, GATE_ALU,
				 output logic LD_IR, LD_PC, LD_REG, LD_MAR, LD_MDR, MIO_EN);

enum logic [5:0] {halt, decode, add, addi, sub, subi, int_mult1, int_mult2, int_mult3, 
						int_div1, int_div2, int_div3, int_div4, andr, andi, ld1, ld2_w, ld2_r, 
						ld3, mv, mvhi, mvlo, round1, round2, round3} state, next_state;

always_ff @ (posedge clk or posedge reset) begin
	if (reset) state <= halt;
	else state <= next_state;
end

always_comb begin
	next_state = state;
	unique case (state)
		halt:
			if (run) next_state = round1; // changed
		decode: begin
			case (opcode)
				6'b000000: begin
					if (func == 6'b0) next_state = add;
					else if (func == 6'b000001) next_state = sub;
					else if (func == 6'b010000) next_state = int_mult1;
					else if (func == 6'b100001) next_state = int_div1;
					else if (func == 6'b000110) next_state = andr;
				end
				6'b000001: next_state = ld1;
				6'b100000: next_state = addi;
				6'b100001: next_state = subi;
				6'b100010: next_state = andi;
				6'b000010: next_state = mv;
				6'b000011: next_state = mvhi;
				6'b000100: next_state = mvlo;
				6'b000101: next_state = round1;
				6'b111111: next_state = halt;
				default: next_state = halt; // ?
			endcase
		end
		add: 
			next_state = halt; // ?
		addi: 
			next_state = halt; // ?
		sub: 
			next_state = halt; // ?
		subi: 
			next_state = halt; // ?
		andr: 
			next_state = halt; // ?
		andi: 
			next_state = halt; // ?
		int_mult1:
			next_state = int_mult2;
		int_mult2: begin
			if (intmult_ready) next_state = int_mult2;
			else next_state = int_mult3;
		end
		int_mult3: 
			next_state = int_div1;
		int_div1:
			next_state = int_div2;
		int_div2:
			next_state = int_div3;
		int_div3: begin
			if (intdiv_ready)
				next_state = int_div3;
			else
				next_state = int_div4;
		end
		int_div4:
			next_state = halt; // ?
		ld1: 
			next_state = ld2_w;
		ld2_w:
			next_state = ld2_r;
		ld2_r:
			next_state = ld3;
		ld3:
			next_state = halt; // ?
		mv:
			next_state = halt; // ?
		mvhi:
			next_state = halt; // ?
		mvlo:
			next_state = halt; // ?
		round1:
			next_state = round2;
		round2:
			if(fpround_ready)
				next_state = round2;
			else next_state = round3;
		round3:
			next_state = halt;
		default: ;
	endcase
end

always_comb begin
	ALUK = 2'b0;
	int_exe = 1'b0;
	ALUMUX = 4'b0;
	PCMUX = 2'b0;
	ADDR2MUX = 2'b0;
	SR2MUX = 1'b0;
	ADDR1MUX = 1'b0;
	GATE_PC = 1'b0;
	GATE_MDR = 1'b0;
	GATE_ADDER = 1'b0;
	GATE_ALU = 1'b0;
	LD_IR = 1'b0;
	LD_PC = 1'b0;
	LD_REG = 1'b0;
	LD_MAR = 1'b0;
	LD_MDR = 1'b0;
	MIO_EN = 1'b0;
	// ld_cc ???
	case (state)
		halt: ;
		
		add: begin
			SR2MUX = 1'b0;
			ALUMUX = 4'b0;
			ALUK = 2'b0;
			GATE_ALU = 1'b1;
			LD_REG = 1'b1;
		end
		
		addi: begin
			SR2MUX = 1'b1;
			ALUMUX = 4'b0;
			ALUK = 2'b0;
			GATE_ALU = 1'b1;
			LD_REG = 1'b1;
		end
		
		sub: begin
			SR2MUX = 1'b0;
			ALUMUX = 4'b0;
			ALUK = 2'b11;
			GATE_ALU = 1'b1;
			LD_REG = 1'b1;
		end
		
		subi: begin
			SR2MUX = 1'b1;
			ALUMUX = 4'b0;
			ALUK = 2'b11;
			GATE_ALU = 1'b1;
			LD_REG = 1'b1;
		end
		
		andr: begin
			SR2MUX = 1'b0;
			ALUMUX = 4'b0;
			ALUK = 2'b01;
			GATE_ALU = 1'b1;
			LD_REG = 1'b1;
		end
		
		andi: begin
			SR2MUX = 1'b1;
			ALUMUX = 4'b0;
			ALUK = 2'b01;
			GATE_ALU = 1'b1;
			LD_REG = 1'b1;
		end
		
		int_mult1: 
			int_exe = 1'b1;	
		
		int_mult2: 
			int_exe = 1'b0;
		
		int_mult3: begin
			SR2MUX = 1'b0;
			ALUMUX = 4'b0001;
			int_exe = 1'b0;
			GATE_ALU = 1'b1;
			LD_REG = 1'b1;
		end
		
		int_div1: 
			int_exe = 1'b1;
		
		int_div2: 
			int_exe = 1'b0;
		
		int_div3:
			int_exe = 1'b0;
		
		int_div4: begin
			SR2MUX = 1'b0;
			ALUMUX = 4'b0010;
			int_exe = 1'b0;
			GATE_ALU = 1'b1;
			LD_REG = 1'b1;
		end
		
		ld1: begin
			ADDR1MUX = 1'b0;
			ADDR2MUX = 2'b10;
			GATE_ADDER = 1'b1;
			LD_MAR = 1'b1;
		end

		ld2_w: ; // ?

		ld2_r: ; // ?

		ld3: begin
			GATE_MDR = 1'b1;
			LD_REG = 1'b1;
		end
		
		mv: begin
			ALUMUX = 4'b0011;
			GATE_ALU = 1'b1;
			LD_REG = 1'b1;
		end
		
		mvhi: begin
			ALUMUX = 4'b0011;
			GATE_ALU = 1'b1;
			LD_REG = 1'b1;
		end
		
		mvlo: begin
			ALUMUX = 4'b0011;
			GATE_ALU = 1'b1;
			LD_REG = 1'b1;
		end
		
		round1: 
			int_exe = 1'b1;
		round2: 
			int_exe = 1'b0;
		round3:
			int_exe = 1'b0;
		default: ;
	endcase
end

endmodule
