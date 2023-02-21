	
module stopwatch (	// Inputs
					SEL, ADJ, RESET, PAUSE, clk,
                    // outputs
                    LED
);
  	input wire SEL; // 0: Min, 1: Sec
  	input wire ADJ; // 0: Normal clock (1Hz), 1: 2Hz
  	input wire RESET;
  	input wire PAUSE;
  	input wire clk;
  	output wire [6:0] LED [3:0]; // 4 digits of a 7-seg display
  
  	initial begin
      $strobe("john wick");
    end

  	
  	// Create 4 clocks
  	reg reg_clk = 0; 		// 1Hz
  	reg fast_clk = 0; 		// 2Hz
  	reg display_clk = 0; 	// 50-700 Hz -> 500 Hz
  	reg blink_clk = 0; 		// 5 Hz ( > 1Hz)
  	
    reg[5:0] seconds_counter = 0;
    reg[5:0] minutes_counter = 0;
  
    
  	integer cycles = 0; // 32-bit
  	
  	reg current_clk = reg_clk;

  	
  	always @ (posedge clk)
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
      
      	if (cycles % 1_000_000 == 0) // 100Hz display clock
        begin
          	display_clk = ~display_clk;
        end
      
      	if (ADJ == 0) begin
      		current_clk <= reg_clk;
    	end
    	else begin
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
          
          
          $strobe("minutes ctr: ", minutes_counter);
          $strobe("seconds ctr: ", seconds_counter);
        end
     
      	if (RESET) begin
          seconds_counter <= 6'b000000;
          minutes_counter <= 6'b000000;
        end
      	
    end
  	
endmodule





module counter(input clk,
               input rst,
               output reg[5:0] seconds_counter,
               output reg[5:0] minutes_counter);
  
  reg[5:0] cur_secs;
  reg[5:0] cur_mins;
  
  // for the seconds
  always @ (posedge clk) begin
    if (rst) 
    begin
      cur_secs <= 6'b000000;
      cur_mins <= 6'b000000;
    end
    else
      cur_secs <= cur_secs + 1;
    if (cur_secs == 6'b111100)  // 60
    begin
      cur_secs = 6'b000000;
      if (cur_mins == 6'b001100) // 12
        cur_mins <= 0;
      else 
      	cur_mins <= cur_mins + 1;
      
    end 
    
    assign seconds_counter = cur_secs;
    assign minutes_counter = cur_mins;
 
    
  end
      
endmodule
    



    
module stopwatch_counter (
  input clk,
  input reset,
  output reg [3:0] seconds_out,
  output reg [3:0] minutes_out
);

reg [3:0] seconds_reg, minutes_reg;
reg [3:0] seconds_next, minutes_next;

// Seconds counter
always @ (posedge clk, posedge reset) begin
  if (reset) begin
    seconds_reg <= 4'b0;
  end else if (seconds_reg == 4'b1001) begin // if seconds count is 9
    seconds_next <= 4'b0;
    minutes_next <= minutes_reg + 4'b0001; // increment minutes
  end else begin
    seconds_next <= seconds_reg + 4'b0001;
  end
end

  
  
// Minutes counter
always @ (posedge clk, posedge reset) begin
  if (reset) begin
    minutes_reg <= 4'b0;
  end else begin
    minutes_reg <= minutes_next;
  end
end

assign seconds_out = seconds_reg;
assign minutes_out = minutes_reg;

endmodule