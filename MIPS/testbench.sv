module testbench();

timeunit 10ns;	// Half clock cycle at 50 MHz
			// This is the amount of time represented by #1 
timeprecision 1ns;

// These signals are internal because the processor will be 
// instantiated as a submodule in testbench.
logic clk = 0;
logic reset, run;
logic [31:0] TESTSIG, TESTSIG2;
logic [31:0] TEST_OUT;

// Instantiating 
// Make sure the module and signal names match with those in your design
slc3pp slc(.*);	

// Toggle the clock
// #1 means wait for a delay of 1 timeunit
always begin : CLOCK_GENERATION
#1 clk = ~clk;
end

initial begin: CLOCK_INITIALIZATION
    clk = 0;
end 

// Testing begins here
// The initial block is not synthesizable
// Everything happens sequentially inside an initial block
// as in a software program
initial begin: TEST_VECTORS
reset = 1;		// Toggle Rest
run = 0;
#4 reset = 0;
#4 run = 1;
TESTSIG = 32'b01000000100010000000000000000000; // 4.25
TESTSIG2 = 32'b01000000100000000000000000000000; // 4.00
#40 run = 0;
#2 reset = 1;
#2 reset = 0;
#2 run = 1;
TESTSIG = 32'b10111110100000000000000000000000; // -0.25
TESTSIG2 = 32'b00111110100000000000000000000000; // 0.25
#40 run = 0;
#2 reset = 1;
#2 reset = 0;
#2 run = 1;
TESTSIG = 32'b10111111111000000000000000000000; // -1.75
TESTSIG2 = 32'b10111110100000000000000000000000; // -0.25
#40 run = 0;
#2 reset = 1;
#2 reset = 0;
#2 run = 1;
TESTSIG = 32'b10111111010000000000000000000000; // -0.75
TESTSIG2 = 32'b0; // 0
#40 run = 0;
end
endmodule
