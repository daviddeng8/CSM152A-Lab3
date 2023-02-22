module stopwatch (
// Inputs
	btnS, // PAUSE
	btnR, // RESET
	sw, // sw<0>: SELECT, sw<1>: ADJUST
	clk,
// Outputs
   seg,
	an
);
	input [1:0]	 sw; // sw<0>: SELECT, sw<1>: ADJUST
	input        btnS; // PAUSE
   input        btnR; // RESET
	
  	input 		 clk;
	
	output reg [3:0] an; // anode signals of the 7-segment LED display
   output reg [6:0] seg; // cathode patterns of the 7-segment LED display
  	
  	// Create 4 clocks
  	reg reg_clk = 0; 		// 1Hz
  	reg fast_clk = 0; 		// 2Hz
  	reg display_clk = 0; 	// 50-700 Hz -> 100 Hz
  	reg blink_clk = 0; 		// 5 Hz ( > 1Hz)
  	
    reg[5:0] seconds_counter = 0;
    reg[5:0] minutes_counter = 0;
  
    
  	integer cycles = 0; // 32-bit
  	
  	reg current_clk;

  	
  always @ (posedge clk) // clk = 100 mhz
    begin
		cycles = cycles + 1;
      
      	if (cycles % 100_000 == 0) // 1Hz reg clk
		begin
        	reg_clk = ~reg_clk;
        end
      
      	if (cycles % 50_000_000 == 0) // 2Hz fast clk
 		begin
          	fast_clk = ~fast_clk;
        end
      
      	if (cycles % 20_000_000 == 0) // 5Hz blink clock
 		begin
          	blink_clk = ~blink_clk;
        end
      
      	display_clk = ~display_clk; // 100Hz display clock
      
      if (sw[1] == 0) begin // SELECT 0
      		current_clk <= reg_clk;
    	end
    	else begin  // SELECT 1
      		current_clk <= fast_clk;
    	end
      	
      	// update the time if the current clk given is 0
      	if (current_clk == 1)
        begin
          seconds_counter <= seconds_counter + 1;
          if (seconds_counter == 6'b111011)  // equalling 59
          begin
			seconds_counter <= 0;
            if (minutes_counter == 6'b001100) // equalling 12
            	minutes_counter <= 0;    
            else
              	minutes_counter <= minutes_counter + 1;     
          end
          else begin
            seconds_counter <= seconds_counter + 1;  
          end
                      $strobe("min: %0t || sec: %0t", minutes_counter, seconds_counter);
      $strobe("an: %b || num: %0t", an, LED_BCD);
        end
     
      	if (btnR) begin // If RESET
          seconds_counter <= 6'b000000;
          minutes_counter <= 6'b000000;
        end
      	
    end
	 
	 // Display
	 
	 reg [3:0] LED_BCD;
   reg [1:0] LED_activating_counter = 2'b00; 

    always @(display_clk)
    begin 
      if(btnR==1)
            LED_activating_counter <= 2'b00;
        else
            LED_activating_counter <= LED_activating_counter + 1;
    end 
				 
	 // anode activating signals for 4 LEDs
    // decoder to generate anode signals 
    always @(*)
    begin
        case(LED_activating_counter)
        2'b00: begin
            an = 4'b0111; 
            // activate LED1 and Deactivate LED2, LED3, LED4
            LED_BCD = minutes_counter/10;
            // the first hex-digit of the 16-bit number
             end
        2'b01: begin
            an = 4'b1011; 
            // activate LED2 and Deactivate LED1, LED3, LED4
            LED_BCD = minutes_counter%10;
            // the second hex-digit of the 16-bit number
                end
        2'b10: begin
            an = 4'b1101; 
            // activate LED3 and Deactivate LED2, LED1, LED4
            LED_BCD = seconds_counter/10;
             // the third hex-digit of the 16-bit number
              end
        2'b11: begin
            an = 4'b1110; 
            // activate LED4 and Deactivate LED2, LED3, LED1
            LED_BCD = seconds_counter%10;
             // the fourth hex-digit of the 16-bit number 
               end
        endcase
    end
	 
	 reg[6:0] LED_out;
// Cathode patterns of the 7-segment LED display 
always @(*)
begin
 case(LED_BCD)
 4'b0000: seg = 7'b0000001; // "0"  
 4'b0001: seg = 7'b1001111; // "1" 
 4'b0010: seg = 7'b0010010; // "2" 
 4'b0011: seg = 7'b0000110; // "3" 
 4'b0100: seg = 7'b1001100; // "4" 
 4'b0101: seg = 7'b0100100; // "5" 
 4'b0110: seg = 7'b0100000; // "6" 
 4'b0111: seg = 7'b0001111; // "7" 
 4'b1000: seg = 7'b0000000; // "8"  
 4'b1001: seg = 7'b0000100; // "9" 
 default: seg = 7'b0000001; // "0"
 endcase
end

  
  	
endmodule