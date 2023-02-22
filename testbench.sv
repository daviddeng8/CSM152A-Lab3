`timescale 1ns / 1ps

module tb;
  	// reg SEL; // 0: Min, 1: Sec
  	// reg ADJ; // 0: Normal clock (1Hz), 1: 2Hz
  	reg [1:0]	 sw; // sw<0>: SELECT, sw<1>: ADJUST
  	reg RESET;
  	reg PAUSE;
  
  	reg [3:0] an; // anode signals of the 7-segment LED display
    reg [6:0] seg; // cathode patterns of the 7-segment LED display
    
    wire [6:0] LED [3:0]; // 4 digits of a 7-seg display
  
  // make a clock (simulation)
  	reg clk;
  	initial begin
       // File to see waveforms
      	// $dumpfile("dump.vcd");
  		// $dumpvars(1);
      
    	clk = 0;
      
      // REMOVE THIS FOR REAL TESTBENCH!!!
      repeat (200_000_000) begin
        #5 clk = ~ clk; 
      end

    end
	
  	// UNCOMMENT THIS!
  	// always #5 clk = ~ clk; // clk = 100Mhz -> 1/100,000,000*10^9 / 2

  	// Instantiate the Unit Under Test (UUT)
  stopwatch uut(	.sw(sw),
                  	.btnR(RESET),
                  	.btnS(PAUSE),
                  	.clk(clk),
                  	.seg(seg),
  				  	.an(an));
	
  
  	initial begin
      sw[0] = 0;
      sw[1] = 0;
     RESET = 0;
     PAUSE = 0;
      
      $display("TB tested");
	end
endmodule  