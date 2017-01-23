module	reg_file(input logic clk, reset, LD_REG,
						input logic [4:0] DR, SR1, SR2, // ?
						input logic [31:0] data_in, data_in2,
						output logic [31:0] sr1_out, sr2_out);

logic ld_i0, ld_i1, ld_i2, ld_f0, ld_f1, ld_f2, ld_t0, ld_t1, ld_t2; 
logic [31:0] ze, se, i0, i1, i2, f0, f1, f2, t0, t1, t2, lo, hi;	

// zero and sentinel reg
reg_32 reg_ze(.*, .load(1'b1), .data_in(32'b0), .data_out(ze));
reg_32 reg_se(.*, .load(1'b1), .data_in(32'b10000000000000000000000000000000), .data_out(se));
// i0-i2
reg_32 reg_i0(.*, .load(ld_i0), .data_in(data_in), .data_out(i0));
//reg_32 reg_i1(.*, .load(ld_i1), .data_in(data_in), .data_out(i1));
//reg_32 reg_i0(.*, .load(1'b1), .data_in(32'b00000000000000000000000000000010), .data_out(i0));
reg_32 reg_i1(.*, .load(1'b1), .data_in(32'b00000000000000000000000000000011), .data_out(i1));
reg_32 reg_i2(.*, .load(ld_i2), .data_in(data_in), .data_out(i2));
// f0-f2
reg_32 reg_f0(.*, .load(ld_f0), .data_in(data_in), .data_out(f0));
reg_32 reg_f1(.*, .load(ld_f1), .data_in(data_in), .data_out(f1));
reg_32 reg_f2(.*, .load(ld_f2), .data_in(data_in), .data_out(f2));
// t0-t2
reg_32 reg_t0(.*, .load(ld_t0), .data_in(data_in), .data_out(t0));
reg_32 reg_t1(.*, .load(ld_t1), .data_in(data_in), .data_out(t1));
reg_32 reg_t2(.*, .load(ld_t2), .data_in(data_in), .data_out(t2));
// function reg
reg_32 reg_lo(.*, .load(LD_REG), .data_in(data_in), .data_out(lo));
reg_32 reg_hi(.*, .load(LD_REG), .data_in(data_in2), .data_out(hi));

always_comb
	begin
		ld_i0 = 1'b0;
		ld_i1 = 1'b0;
		ld_i2 = 1'b0;
		ld_f0 = 1'b0;
		ld_f1 = 1'b0;
		ld_f2 = 1'b0;
		ld_t0 = 1'b0;
		ld_t1 = 1'b0;
		ld_t2 = 1'b0;
		sr1_out = 32'b0;
		sr2_out = 32'b0;
		if (LD_REG) 
			case(DR)
				5'b00010: ld_i0 = 1'b1;
				5'b00011: ld_i1 = 1'b1;
				5'b00100: ld_i2 = 1'b1;
				5'b00101: ld_f0 = 1'b1;
				5'b00110: ld_f1 = 1'b1;
				5'b00111: ld_f2 = 1'b1;
				5'b01110: ld_t0 = 1'b1;
				5'b01111: ld_t1 = 1'b1;
				5'b10000: ld_t2 = 1'b1;
				default: ;
			endcase
			
		case(SR1)
			5'b00000: sr1_out = ze;
			5'b00001: sr1_out = se;
			5'b00010: sr1_out = i0;
			5'b00011: sr1_out = i1;
			5'b00100: sr1_out = i2;
			5'b00101: sr1_out = f0;
			5'b00110: sr1_out = f1;
			5'b00111: sr1_out = f2;
			5'b01110: sr1_out = t0;
			5'b01111: sr1_out = t1;
			5'b10000: sr1_out = t2;
			5'b10001: sr1_out = lo;
			5'b10010: sr1_out = hi;
			default: ;
		endcase
		
		case(SR2)
			5'b00000: sr2_out = ze;
			5'b00001: sr2_out = se;
			5'b00010: sr2_out = i0;
			5'b00011: sr2_out = i1;
			5'b00100: sr2_out = i2;
			5'b00101: sr2_out = f0;
			5'b00110: sr2_out = f1;
			5'b00111: sr2_out = f2;
			5'b01110: sr2_out = t0;
			5'b01111: sr2_out = t1;
			5'b10000: sr2_out = t2;
			5'b10001: sr2_out = lo;
			5'b10010: sr2_out = hi;
			default: ;
		endcase
	end	
	


endmodule 
