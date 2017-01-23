module int_div (
    input clk,
    input reset,
    input execute,
    input [31:0] dividend,
    input [31:0] divisor,
    output logic [31:0] quotient,
    output logic [31:0] remainder,
    output logic ready
    );
    
    logic sign, sign_rem, active, rem_add;
    logic [4:0] cycle;
    logic [31:0] divisor_temp;
    logic [63:0] result;
    logic setup;
    logic status; //0: compare divisor with dividend; 1: add result and shift divisor
    
    assign ready = active;
    
    always_ff @ (posedge clk) begin
        if (reset) begin
            active <= 1'b0;
            sign <= 1'b0;
            cycle <= 5'b0;
            divisor_temp <= 32'b0;
            result <= 64'b0;
            status <= 1'b0;
            setup <= 1'b0;
        end
        
        else begin
            if (execute) begin
                sign <= dividend[31] ^ divisor[31];
					 sign_rem <= dividend[31];
                if (dividend[31] == 1'b0) 
                    result <= {32'b0, dividend[30:0]};
                else
                    result <= {32'b0, ~dividend[30:0]} + 64'b1;
                if (divisor[31] == 1'b0) divisor_temp <= divisor;
                else divisor_temp <= ~divisor + 32'b1;
                setup <= 1'b1;
            end
            
            else if (setup) begin
                result <= {result[62:0], 1'b0};
                cycle <= 5'b11111;
                setup <= 1'b0;
                status <= 1'b0;
                rem_add <= 1'b0;
					 active <= 1'b1;
            end
                   
            else if (active) begin
                if (status == 1'b0) begin
                    if (rem_add == 1'b0) begin
                        result[63:32] <= result[63:32] - divisor_temp;
							end
                    else begin
                        result[63:32] <= result[63:32] + divisor_temp;
							end
                    status <= 1'b1;
                end
                else if (status == 1'b1) begin
                    if (result[63] == 1'b1) begin
                        result <= {result[62:0], 1'b0};
                        rem_add <= 1'b1;
                    end
                    else begin
                        result <= {result[62:0], 1'b1};
                        rem_add <= 1'b0;
                    end
                    if (cycle == 5'b0) active <= 1'b0;
                    status <= 1'b0;
                    cycle <= cycle - 1'b1;
                end               
            end
            
            else begin
                if (sign) quotient <= ~result[31:0] + 32'b1;
                else quotient <= result[31:0];
                if (sign_rem) begin
					     if (result[63] == 1'b0) begin
							   if (result[63:33] == 31'b0) remainder <= 32'b0;
								else remainder <= {1'b0, result[63:33]} - divisor_temp;
						  end
					     else remainder <= {1'b1, result[63:33]};
					 end
                else begin
					     if (result[63] == 1'b1) remainder <= {1'b1, result[63:33]} + divisor_temp;
                    else remainder <= {1'b0, result[63:33]};
				    end
            end
        end         
    end
endmodule
