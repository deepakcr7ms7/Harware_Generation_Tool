// ESE-507 Project 2, Fall 2021
// This simple testbench is provided to help you in testing Project 2, Part 2.
// This testbench is not sufficient to test the full correctness of your system, it's just
// a relatively small test to help you get started.

module check_timing();

   logic clk, x_valid, f_valid, x_ready, f_ready, y_valid, y_ready, reset;
   logic signed [9:0]  x_data, f_data;
   logic signed [25:0] y_data;
   
   initial clk=0;
   always #5 clk = ~clk;
   

   conv_112_49 dut (.clk(clk), .reset(reset), 
                    .x_data(x_data), .x_valid(x_valid), .x_ready(x_ready),
                    .f_data(f_data), .f_valid(f_valid), .f_ready(f_ready),
                    .y_data(y_data), .y_valid(y_valid), .y_ready(y_ready));



   //////////////////////////////////////////////////////////////////////////////////////////////////
   // code to feed some test inputs
  
   // rb, rb2, and rb3 represent random bits. Each clock cycle, we will randomize the value of these bits.
   // We will use rb to determine when to let our testbench send new x data. (When rb==0, we will not send valid data)
   // We will use rb2 to determine when to let our testbench send new f data. (When rb2==0, we will not send valid data)
   // We will use rb3 to determine when to let our testbench receive new y data. (When rb3==0, we will not receive results)
   logic rb, rb2, rb3;
   integer ignore;
   always begin
      @(posedge clk);
      #1;
      ignore = std::randomize(rb, rb2, rb3); // randomize rb
   end

   // Put our test data into these arrays. These are the values we will feed as input into the system.
   // We will do two tests; each will take 112 values for x and 49 values for f.
   logic [9:0] invals_x[0:223];
   logic [9:0] invals_f[0:97];

   // Generate some test values
   integer z;
   initial begin
      for (z=0; z<224; z=z+1)
         invals_x[z] = z-128;
      for (z=0; z<98; z=z+1)
         invals_f[z] = z-64;
   end

   logic signed [22:0] expectedOut[0:2*(112-49+1)-1] = '{213640, 211680, 209720, 207760, 205800, 203840, 
      201880, 199920, 197960, 196000, 194040, 192080, 190120, 188160, 186200, 184240, 182280, 180320, 
      178360, 176400, 174440, 172480, 170520, 168560, 166600, 164640, 162680, 160720, 158760, 156800, 
      154840, 152880, 150920, 148960, 147000, 145040, 143080, 141120, 139160, 137200, 135240, 133280, 
      131320, 129360, 127400, 125440, 123480, 121520, 119560, 117600, 115640, 113680, 111720, 109760, 
      107800, 105840, 103880, 101920, 99960, 98000, 96040, 94080, 92120, 90160, 13328, 13769, 14210, 
      14651, 15092, 15533, 15974, 16415, 16856, 17297, 17738, 18179, 18620, 19061, 19502, 19943, 20384, 
      20825, 21266, 21707, 22148, 22589, 23030, 23471, 23912, 24353, 24794, 25235, 25676, 26117, 26558, 
      26999, 27440, 27881, 28322, 28763, 29204, 29645, 30086, 30527, 30968, 31409, 31850, 32291, 32732, 
      33173, 33614, 34055, 34496, 34937, 35378, 35819, 36260, 36701, 37142, 37583, 38024, 38465, 38906, 
      39347, 39788, 40229, 40670, 41111};


   logic [15:0] x_count;

   /////////////////////////
   // Setting values for input x

   // If our random bit rb is set to 1, and if x_count is within the range of our test vector (invals),
   // we will set x_valid to 1.
   always @* begin
      if ((x_count>=0) && (x_count<2*112) && (rb==1'b1)) 
         x_valid=1;
      else
         x_valid=0;
   end

   // If x_valid is set to 1, we will put data on x_data.
   // If x_valid is 0, we will put an X on the data_in to test that your system does not 
   // process the invalid input.
   always @* begin
      if (x_valid == 1)
         x_data = invals_x[x_count];
      else
         x_data = 'x;
   end

   // If we set x_valid and x_ready asserted on this clock edge, we will increment x_count just after
   // this clock edge.
   always @(posedge clk) begin
      if (x_valid && x_ready)
         x_count <= #1 x_count+1;
   end


   ////////////////////////
   // Setting values for input f

   // Same logic but with f_count and f_data
   
   logic [15:0] f_count;
   always @* begin
      if ((f_count>=0) && (f_count<2*49) && (rb2==1'b1)) 
         f_valid=1;
      else
         f_valid=0;
   end
   always @* begin
      if (f_valid == 1)
         f_data = invals_f[f_count];
      else
         f_data = 'x;
   end
   always @(posedge clk) begin
      if (f_valid && f_ready)
         f_count <= #1 f_count+1;
   end


   /////////////////////////////
   // code to receive the output values

   // we will use another random bit (rb3) to determine if we can assert y_ready.
   logic [15:0] y_count;
   always @* begin
      if ((y_count >= 0) && (y_count < 2*(112-49+1)) && (rb3==1'b1))
         y_ready = 1;
      else
         y_ready = 0;
   end

   always @(posedge clk) begin
      if (y_ready && y_valid) begin
         if (y_data !== expectedOut[y_count]) 
            $display("ERROR:   y[%d] = %d    expected output = %d", y_count, y_data, expectedOut[y_count]);
         else
            $display("SUCCESS: y[%d] = %d", y_count, y_data);
         y_count = y_count+1; 
      end 
   end

   ////////////////////////////////////////////////////////////////////////////////

   initial begin
      x_count=0; f_count=0; y_count=0;

      // Before first clock edge, initialize
      y_ready = 0; 
      reset = 0;
   
      // reset
      @(posedge clk); #1; reset = 1; 
      @(posedge clk); #1; reset = 0; 

      // wait until the outputs have come out, then finish.
      wait(y_count==2*(112-49+1));

      // Now we're done!
      
      // Just as a test: wait another 100 cycles and make sure the DUT doesn't assert m_valid again.
      // It shouldn't, because the system finished the inputs it was given, so it should be waiting
      // for new input data.
      repeat(100) begin
         @(posedge clk);
         if (y_valid == 1)
            $display("ERROR: DUT asserted y_valid incorrectly");
      end
      
      $finish;
   end


   // This is just here to keep the testbench from running forever in case of error.
   // In other words, if your system never produces three outputs, this code will stop 
   // the simulation after 1000 clock cycles.
   initial begin
      repeat(100000) begin
         @(posedge clk);
      end
      $display("Warning: Output not produced within 100000 clock cycles; stopping simulation so it doens't run forever");
      $stop;
   end

endmodule
