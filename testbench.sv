`timescale 1ns / 1ps

module tb;
  	reg SEL; // 0: Min, 1: Sec
  	reg ADJ; // 0: Normal clock (1Hz), 1: 2Hz
  	reg RESET;
  	reg PAUSE;
    
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
  	stopwatch uut(.SEL(SEL),
                  .ADJ(ADJ),
                  .RESET(RESET),
                  .PAUSE(PAUSE),
                  .clk(clk),
                  .LED(LED));
	
  
  	initial begin
     SEL = 0;
     ADJ = 0;
     RESET = 0;
     PAUSE = 0;
      
      $display("TB tested");
	end
endmodule  