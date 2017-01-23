module global_bus (input logic [31:0] pc, mdr, adder, alu1, alu2,
						 input logic g_pc, g_mdr, g_adder, g_alu,
						 output logic [31:0] g_bus1, g_bus2);
				   
always_comb
begin
	if (g_pc) begin
		g_bus1 = pc;
		g_bus2 = 32'b0;
	end
	else if (g_mdr) begin
		g_bus1 = mdr;
		g_bus2 = 32'b0;
	end
	else if (g_adder) begin
		g_bus1 = adder;
		g_bus2 = 32'b0;
	end
	else if (g_alu) begin
		g_bus1 = alu1;
		g_bus2 = alu2;
	end 
	else begin
		g_bus1 = 32'b0;
		g_bus2 = 32'b0;
	end
end
endmodule
