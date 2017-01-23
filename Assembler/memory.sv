`include "SLC3PP_2.sv"
import SLC3PP_2::*;

module test_memory ( input 			clk,
					 input          reset, 
                     inout  [31:0]  I_O,
                     input  [31:0]  A,
                     input          CE,
                                    OE,
                                    WE );
												
   parameter size = 256;
	 
   logic [31:0] mem_array [size-1:0];
   logic [31:0] mem_out;
   logic [31:0] I_O_wire;
	 
   assign mem_out = mem_array[A[7:0]];  
	 
   always_comb
   begin
      I_O_wire = 32'bZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ;

      if (~CE && ~OE && WE) begin
            I_O_wire[31:0] = mem_out[31:0];
		end
   end
	  
   always_ff @ (posedge clk or posedge reset) begin
		if(reset) begin
mem_array[0] <= opANDi(i0,i0,16'b0000000000000000);
mem_array[1] <= opANDi(i1,i1,16'b0000000000000000);
mem_array[2] <= opLDF(f0,16'b0000000000010110);
mem_array[3] <= opLDF(f1,16'b0000000000010110);
mem_array[4] <= opADD(i2,i0,i1);
mem_array[5] <= opOUT(f2);
mem_array[6] <= opPSE(16'hffff);
mem_array[7] <= opDIVF(f0,f1);
mem_array[8] <= opMVLO(f2);
mem_array[9] <= opOUT(f2);
mem_array[10] <= opPSE(16'hffff);
mem_array[11] <= opRND(i0,f0);
mem_array[12] <= opOUT(i0);
mem_array[13] <= opPSE(16'hffff);
mem_array[14] <= opLDF(f0,16'b0000000000001100);
mem_array[15] <= opLDF(f1,16'b0000000000001100);
mem_array[16] <= opCMPF(f0,f1);
mem_array[17] <= opIF(2'b01,16'b0000000000000001);
mem_array[18] <= opPSE(16'hffff);
mem_array[19] <= opLD(i0,16'b0000000000001001);
mem_array[20] <= opLD(i1,16'b0000000000001001);
mem_array[21] <= opDIV(i0,i1);
mem_array[22] <= opMVHI(i2);
mem_array[23] <= opOUT(i2);
mem_array[24] <= opPSE(16'hffff);
mem_array[25] <= 32'b01000011111101000110100110111010;
mem_array[26] <= 32'b01000010111110101010111000010100;
mem_array[27] <= 32'b00111111010000000000000000000000;
mem_array[28] <= 32'b00111111000000000000000000000000;
mem_array[29] <= 32'b00000000000000000000000000000111;
mem_array[30] <= 32'b00000000000000000000000000000010;
        for (integer i = 31; i <= size - 1; i = i + 1)
            begin
            mem_array[i] <= 32'h0;
            end
        end
        else if (~CE && ~WE && A[15:8]==8'b00000000) begin
            mem_array[A[7:0]][31:0] <= I_O[31:0];
        end

    end

    assign I_O = I_O_wire;

endmodule
