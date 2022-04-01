
module conv_12_5(clk, reset, x_data,x_valid, x_ready, f_data,f_valid, f_ready, y_data, y_valid, y_ready);
	parameter M = 12;
	parameter N = 5;
 	input clk, reset, x_valid, f_valid, y_ready;
 	input signed [9:0] x_data, f_data;
  	logic signed [9:0] data_x,data_f;
 	output logic x_ready, f_ready, y_valid;
 	output logic signed [22:0] y_data;
   	logic [$clog2(M)-1:0] addr_x, counterx;
   	logic [$clog2(N)-1:0] addr_f, counterf, countery;
	logic overflow_county;
	logic wr_en_x,wr_en_f,clear,en_acc, clear_accumulator;

	parameter [3:0] init = 0, upload_x = 1, upload_f= 2, start_math = 3, start_mult = 4, output_result = 5, wait_s = 6, upload = 7, nothing = 8; //states in my fsm
	logic [3:0] present_state, next_state;

///////////////////////////////////////////////////////// Data Path///////////////////////////////////////////////////////////////////////////	
	
	memory #(10, M) x (clk,x_data, data_x, addr_x, wr_en_x);            // X Memory Instantiation
 	memory #(10, N) f (clk, f_data, data_f, addr_f, wr_en_f);            // f Memory Instantiation
 	mac m2(clk,en_acc,clear_accumulator, data_x, data_f, y_data);	     //Mac Module Instantiation	


//////////////////////////////////////////////////////////////////// Control Path(FSM) ///////////////////////////////////////////////////////
	
	assign wr_en_x = x_valid & x_ready;	//Asserting X Memory Write Enable 
	assign wr_en_f = f_valid & f_ready;     //Asserting f Memory Write Enable 
	assign clear_accumulator = (y_valid & y_ready) | clear; // Clear Accumulator Flag

	
 
	always_comb // This comb block will update the flags i.e output of Control Block 
	begin
		if (present_state == init) begin  
			addr_x = counterx;
			addr_f = counterf;
			x_ready = 1;
			f_ready = 0;
			y_valid = 0;
			en_acc = 0;
			clear = 1;
		end
		else if (present_state == upload) begin
			addr_x = counterx;
			addr_f = counterf;
			x_ready = 1;
			f_ready = 1;
			y_valid = 0;
			en_acc = 0;
			clear = 0;
		end
		else if (present_state == upload_x) begin
			addr_x = counterx;
			addr_f = counterf;
			x_ready = 1;
			f_ready = 0;
			y_valid = 0;
			en_acc = 0;
			clear = 0;
		end
		else if (present_state == start_mult) begin
			addr_x = counterx;
			addr_f = counterf;
			x_ready = 0;
			f_ready = 0;
			y_valid = 0;
			en_acc=1;
			clear = 0;
		end
		else if (present_state == output_result) begin
			addr_x = counterx;
			addr_f = counterf;
			x_ready = 0;
			f_ready = 0;
			y_valid = 1;
			en_acc = 0;
			clear = 0;
		end
	 	else if (present_state == wait_s) begin
			addr_x = counterx;
			addr_f = counterf;
			x_ready = 0;
			f_ready = 0;
			y_valid = 1;
			en_acc = 0;
			clear = 0;
		end
		else begin
			addr_x = counterx;
			addr_f = counterf;
			x_ready = 0;
			f_ready = 0;
			y_valid = 0;
			en_acc = 0;
			clear = 0;
		end
	end

	
	always_comb  // This comb block deals with state trasitions
	begin

	if(present_state == init)
		next_state = upload_x;

	else if(present_state == upload && x_valid == 1 && counterx == M-1 && counterf == N-1)
		next_state = start_math;
	
	else if(present_state == upload && x_valid == 1 && counterx == M-1)
		next_state = upload_f;
	
	else if(present_state == upload && f_valid == 1 && counterf == N-1)
		next_state = upload_x;
	
	else if(present_state == upload)
		next_state = upload;

	else if(present_state == upload_x && x_valid == 1 && counterx == M-1)
		next_state = upload_f;
	
	else if(present_state == upload_x)
		next_state = upload_x;

	else if(present_state == upload_f && f_valid == 1 && counterf == N-1)
		next_state = start_math;
	
	else if(present_state == upload_f)
		next_state = upload_f;

	else if(present_state == start_math)
		next_state = start_mult;

	else if(present_state == start_mult && counterf == N)
		next_state = output_result;
	
	else if(present_state == start_mult)
		next_state = start_mult;

	else if(present_state == output_result && y_ready == 1 &&  overflow_county == 1)
		next_state = init;
	
	else if(present_state == output_result && y_ready == 1)
		next_state = start_math;
	
	else if(present_state == output_result && y_ready == 0)
		next_state = wait_s;

	else if(present_state == wait_s && y_ready == 1 &&  overflow_county == 1)
		next_state = init;
	
	else if(present_state == wait_s && y_ready == 1)
		next_state = start_math;
	
	else if(present_state == wait_s && y_ready == 0)
		next_state = wait_s;

	else
		next_state = nothing;
	end

	always_ff @(posedge clk) begin //This block deals with counters 
	if (reset == 1)
	begin
		present_state <= init;
		counterx <= 0;
		counterf <= 0;
		countery <= 0;
		overflow_county <= 0;
	end
	else 
	begin
		present_state <= next_state;

		//Counters

		if(x_valid == 1 && x_ready == 1)
		counterx <= counterx + 1;
	
		if(f_valid == 1 && f_ready == 1)
		counterf <= counterf +1;


		if(next_state == start_math) 
		begin
			counterf <= 0;
			counterx <= countery;
  		end
	
		else if (next_state == start_mult) 
		begin
			counterx <= counterx + 1;
			counterf <= counterf +1;
		end
	
		else if (next_state == output_result && countery == M-N) 
		begin
			overflow_county <= 1;
			countery <= countery +1;
		end
	
		else if (next_state == output_result)
			countery <= countery +1;
	
		else if (next_state == init) 
			begin
			counterx <= 0;
			counterf <= 0;
			countery <= 0;
			overflow_county <= 0;
			end
 	end

end

endmodule





//==================================================MAC  MODULE=====================================================

module mac(clk,en_acc,clear_acc, data_x, data_f, y_data);

input clk, clear_acc,en_acc;
input signed [9:0] data_x, data_f;
output logic signed [22:0] y_data;
logic signed [22:0] product, sum;

  always_ff @(posedge clk) begin
    if(clear_acc == 1) begin                // Clearing Accumulated Value
      y_data <=0;
    end
    else if(en_acc==1)
	begin

	y_data<=sum;

        end
  end

  always_comb begin
    product = data_x * data_f;           // Multiplication Operation
    sum = product + y_data;              // Accumulation Operation
  end


endmodule


//==================================================MEMORY  MODULE=====================================================

module memory(clk, data_in, data_out, addr, wr_en);
 parameter WIDTH=16, SIZE=64;
 localparam LOGSIZE=$clog2(SIZE);
 input [WIDTH-1:0] data_in;
 output logic [WIDTH-1:0] data_out;
 input [LOGSIZE-1:0] addr;
 input clk, wr_en;
 logic [SIZE-1:0][WIDTH-1:0] mem;
 always_ff @(posedge clk) begin
data_out <= mem[addr];
if (wr_en)
 mem[addr] <= data_in;
 end
endmodule
