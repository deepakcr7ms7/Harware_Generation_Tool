module part3_mac(clk, reset, a, b, valid_in, f, valid_out);
 input clk, reset, valid_in;
 input signed [9:0] a, b;
 output logic signed [19:0] f;
 output logic valid_out;
 logic signed [9:0] a1, b1;
 logic en_ab,en_f;
 logic signed [19:0]total;
 logic signed [19:0]c; //input
 logic signed [19:0]c1; //output

 assign en_ab=valid_in;	
 always_ff @(posedge clk)
 begin
	
	en_f<=en_ab;
	valid_out<=en_f;
 end
 
 //this reg a and b
 always_ff @(posedge clk) 
 begin
	if (reset == 1 ) 
	begin
		a1<=0;
		b1<=0;
		
	end
	else if (en_ab==1)
		begin
			a1<=a;
			b1<=b;
		end

 end

 //pipelining reg
 always_ff @(posedge clk) 
 begin
	if (reset == 1 ) 
	begin
		c1<=0;
		
	end
	else 
	begin
		c1<=c;
		
	end

 end

 


	

always_ff@(posedge clk)
 begin	
	if(reset==1)
	begin
	f<=0;
	end
	
	else if(en_f==1)
	begin
		f<=total;
	end
	
	


 end
 always_comb
 begin
	c=a1*b1;
        
	total=c1+f; //this f is prev f

	if(total>524287)
	begin
	total=524287;
	end
	else if(total<-524288) 
	begin
	total=-524288;
	end
	else
	begin
		total=total;
	end

	
 end
 endmodule


 
 

module tb_part3();

   logic clk, reset, valid_in, valid_out;
   logic signed [9:0] a, b;
   logic signed [19:0] f;

   logic signed [9:0] testData[2999:0]; //  input data array	

   part2_mac dut(.clk(clk), .reset(reset), .a(a), .b(b), .valid_in(valid_in), .f(f), .valid_out(valid_out));

   initial clk = 0;
   always #5 clk = ~clk;
   integer i;
   
   integer fd=$fopen("output_part2.txt","w"); // file for writing output
   
   initial $readmemh("input_data_part2.txt", testData); // read from inputData file
   
  
   always @(posedge clk)
   	$fdisplay(fd,"%d",f);
  
   	initial 
   	begin
   	reset = 1;
      	{a, b} = {10'b0,10'b0};
      	valid_in = 0;
      	@(posedge clk);
      	#1; // After 1 posedge
      	reset = 0; a = 0; b = 0; valid_in = 0;
		@(posedge clk);
		#1;
		$display("a :%d |b :%d | valid_in :%d |Valid_out :%d| f :%d ",a,b,valid_in,valid_out,f);
		$display("--------------------------------------------------------------------------");
		@(posedge clk);
		#1;
		$display("a :%d |b :%d | valid_in :%d |Valid_out :%d| f :%d ",a,b,valid_in,valid_out,f);
		$display("--------------------------------------------------------------------------");
	
   	for(i=0;i<999;i=i+1)
	        begin               // test against the test data
		@(posedge clk);
		#1;
		   a=testData[3*i][9:0];
		   b=testData[(3*i)+1][9:0];
		   valid_in=testData[(3*i)+2][1:0];
	        #1;
		$display("a :%d |b :%d | valid_in :%d |Valid_out :%d| f :%d ",a,b,valid_in,valid_out,f);
		$display("--------------------------------------------------------------------------");
	end
	@(posedge clk);
	$fclose(fd);
	$finish;
   	
 
		
		
		
		
		

		
end
endmodule
	
 
 
