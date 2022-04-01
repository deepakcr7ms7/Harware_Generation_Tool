module conv_16_6_16_1(clk, reset, x_data, x_valid, x_ready, y_data, y_valid, y_ready);
   // your stuff here!

 parameter X =16 ; 
 parameter F =6; 
 input clk, reset, x_valid, y_ready;
 input signed [15:0]  x_data; 
 logic signed [15:0]  data_x; 
 logic signed [15:0]  data_f;
 output logic x_ready, y_valid; 
 logic signed [15:0]  data_y; 
 output logic signed[15:0] y_data; 
 logic[$clog2(X) - 1:0] addr_x;
 logic[$clog2(X) - 1:0] addr_y;
 logic mac;
 logic[$clog2(F) - 1:0] addr_f;
 logic write_complete, mac_complete;
 logic [2:0] state, next_state;                                              // FSM Transition Variables
 logic data_displayed;
 logic  hold_s3;
 logic clear_acc,en_acc;


 memory #(16,X) x(clk, x_data, data_x, addr_x, wr_en_x);            // Matrix Memory Instantiation
 conv_16_6_16_1_f_rom r(clk,addr_f,data_f);// Vector Memory Instantiation
 memory #(16,X) y(clk, data_y, y_data, addr_y, wr_en_y);           // Output Data Memory Instantiation
 
 mac m2(clk, en_acc, clear_acc, data_x, data_f, data_y);           // MAC Module Instantiation
 always_ff @(posedge clk) begin
    if(reset==1)                                                              // Reset Signal & Initial State Assignment
      state<=0;                                                               
    else begin
      state<=next_state;                                                      // State Transition Assignment 
    end
  end
always_comb begin 
      if(state == 0) begin                  // State 0: Wait for Valid Data and Valid Data Signal
        if(x_valid == 1)
          next_state = 1;                 
        else 
          next_state = 0;
        end

      else if(state == 1) begin                  // State 1: Fetch Input Data (Vector X)
        if(write_complete == 1)
          next_state = 2;
        else 
          next_state = 1;
      end

      else if(state == 2) begin                  // State 2:  Multiplication and Accumulation
        if(mac_complete ==1) 
          next_state = 3; 
        else 
          next_state = 2; 
      end
      
      else if(state == 3) begin                  // State 3: Wait for Master Ready Signal and Display Output  
        if(data_displayed == 1) 
          next_state = 0; 
        else if(hold_s3==0)
          next_state = 3;
       end

      else next_state = 0;                 // Wait for Instruction from Testbench
    end

  assign x_ready =  ((state==1)&(write_complete==0));               // Assert when system is ready for data input 
  assign y_valid =  ( state==3);               // Assert when system is ready for data input 
  assign hold_s3=y_ready;  
  assign data_displayed = ((state ==3)&(addr_y ==X-F));               // Assert once output is displayed
  assign write_complete = ((state ==1) & (addr_x ==X-1));             // Assert once input is taken in
  
  assign en_acc=(state==2);
  assign wr_en_x=((state ==1)  &(addr_x < X));       // Asserting Vector Memory Write Enable  
  assign wr_en_y=(state==2);      // Asserting Output Memory Write Enable  check




  always_ff @(posedge clk) 
  begin
    if(state==0) begin                  // State 0 Operations: Initialize Address Pointers  
      addr_x <= 0; addr_f <= 0; addr_y <=0;              
      mac_complete <=0;
	clear_acc<=0;
     	 
    end  

    else if (state == 1) begin          // State 1 Operations: Shift Matrix and Vector Pointers
      if(x_valid == 1)begin
        if(addr_x < X) 
          addr_x <= addr_x + 1; 
        else begin
          addr_x <=0;
        end
      end
      end

      else if (state == 2) begin         // State 2 Operations: Matrix-Vector Multiply and Accumulate 
      if(addr_y<(X-F+1))
	begin
        
        if(addr_f<F-1) begin
	  addr_x<=addr_x+1;
          addr_f<=addr_f+1;
	end
        else begin
          addr_y <= addr_y+1; 
	  addr_x<=addr_y;
	  addr_f<=0;		
        end
      end 
      else begin 
        mac_complete <=1;             // Assert when State 2 is complete 
	addr_y <= 0;
	clear_acc<=0;
		      
      end
    end

    else if (state == 3) begin        // State 3 Operations: Send Multiplied & Accumulated Values
      if (addr_y<X-F+1 && hold_s3==1)
	begin 
	addr_y<=addr_y+1;
 	
     end
		
end
end
 endmodule
 
module mac(clk, en_acc, clear_acc, data_x, data_f, data_y);
 input clk, clear_acc, en_acc;
 input signed[15:0] data_x, data_f;
 output logic signed[15:0] data_y; 
 logic signed[16:0] mult; 
 logic signed[15:0] p_in, p_out;
 logic signed[16:0]accumulate;
 logic signed[15:0] y,sum;
 logic signed[15:0]  overflow = (1<<19) - 1 ;
 logic signed [15:0] underflow = (1<<19);
 
 always_ff @(posedge clk) begin
    if (clear_acc == 1) begin                // Pipeline registor
        p_out <= 0;
    end
    else
        p_out <= p_in;
    end
 
 always_ff @(posedge clk) begin
    if (clear_acc == 1) begin
        y <= 0;
    end
    else if (en_acc == 1)
    begin
        y <= sum;
    end
    end
 
 always_comb begin
 mult = data_x * data_f;
    if (mult < underflow)
        p_in = underflow;
    else if (mult > overflow)
        p_in = overflow;
    else
        p_in = mult;
 
end
 always_comb begin
 accumulate = p_out + y; 
 
 if (accumulate < underflow) 
    sum = underflow; 
    else if (accumulate > overflow) 
    sum = overflow; 
 else 
    sum = accumulate ;
 end
 
 
//RELU Block
 always_comb
begin
    if (y < 0)begin
        data_y = 0;
    end
    else
    begin
        data_y = y;
    end
 
    end
 
 endmodule 
//==================================================MEMORY  MODULE=====================================================
module memory(clk, data_in, data_out, addr, wr_en);
 parameter WIDTH = 16, SIZE = 64;
localparam LOGSIZE = $clog2(SIZE); 
 input[WIDTH - 1:0] data_in;
output logic[WIDTH - 1:0] data_out; 
input[LOGSIZE - 1:0] addr; 
input clk, wr_en; 
logic[SIZE - 1:0][WIDTH - 1:0] mem; 
always_ff @(posedge clk) begin
  data_out <= mem[addr];
if (wr_en) 
mem[addr] <= data_in;
 end 
endmodule 
module conv_16_6_16_1_f_rom(clk, addr, z);
   input clk;
   input [2:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= -16'd245;
        1: z <= -16'd12;
        2: z <= -16'd57;
        3: z <= -16'd210;
        4: z <= 16'd153;
	5: z <= -16'd250;
      endcase
   end
endmodule








