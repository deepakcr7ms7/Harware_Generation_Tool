module part1_mac(clk, reset, a, b, valid_in, f, valid_out);
 input clk, reset, valid_in;
 input signed [9:0] a, b;
 output logic signed [19:0] f;
 output logic valid_out;
 logic signed [9:0] a1, b1;
 //logic signed [19:0] f1;
 logic en_ab,en_f;
 logic signed [19:0]mul;
 logic signed [19:0]total;

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
	mul=a1*b1;
	total=mul+f; //this f is prev f
	
 end
 endmodule
	
 
 