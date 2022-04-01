
module conv_112_49_opt(clk, reset, x_data,x_valid, x_ready, f_data,f_valid, f_ready, y_data, y_valid, y_ready);
 parameter M = 112;
 parameter N = 49;
 input clk, reset, x_valid, f_valid, y_ready;
 input signed [9:0] x_data, f_data;
 logic signed [9:0] data_f;
 logic signed [9:0] data_x [M-N:0];
 output logic x_ready, f_ready, y_valid;
 output logic signed [25:0] y_data;
 logic signed [25:0] data_out [M-N:0];
 logic [$clog2(M)-1:0] counterx;
 logic [$clog2(N)-1:0] addr_memx [M-N:0];
 logic [$clog2(N)-1:0] addr_f, counterf, countery;
 logic overflow_county;
 logic wr_en_f,clear,en_acc, clear_accumulator;
 logic[M-N:0]  wr_en_x;

 parameter [3:0] init = 0, upload_x = 1, upload_f= 2, start_math = 3, start_mult = 4, output_result = 5, wait_s = 6, upload = 7, nothing = 8;
 logic [3:0] present_state, next_state;

 integer  j, k;
 genvar i;
///////////////////////////////////////// Memories and MAC /////////////////////////////////////////////////////////////
generate
	for(i = 0; i < (M-N+1); i=i+1)begin
		memory #(10, N) x (clk, x_data, data_x[i], addr_memx[i], wr_en_x[i]);
		mac m2(clk,en_acc,clear_accumulator, data_x[i], data_f, data_out[i]);
	end
endgenerate

memory #(10, N) f (clk, f_data, data_f, addr_f, wr_en_f);            // f Memory Instantiation




//////////////////////////////////////////////////////// FSM ////////////////////////////////////////////////////////////////////

assign wr_en_f = f_valid & f_ready;
assign clear_accumulator = clear;



//////////////// Asserting X Memory Write Enable //////////////////////////////////////////////////////////////////////// 


always_comb begin
	for (k = 0; k < M-N+1; k=k+1) begin
		if (x_valid && x_ready && counterx >= k && counterx < k+N)
			wr_en_x[k] = 1;
		else
			wr_en_x[k] = 0;
	end
end





always_comb begin // This comb block will update the flags i.e output of Control Block 
	if (present_state == init) begin
		addr_f = counterf;
		x_ready = 1;
		f_ready = 1;
		y_valid = 0;
		en_acc = 0;
		clear = 1;
	end
	else if (present_state == upload) begin
		addr_f = counterf;
		x_ready = 1;
		f_ready = 1;
		y_valid = 0;
		en_acc = 0;
		clear = 0;
	end
	else if (present_state == upload_x) begin
		addr_f = counterf;
		x_ready = 1;
		f_ready = 0;
		y_valid = 0;
		en_acc = 0;
		clear = 0;
	end
	else if (present_state == upload_f) begin
		addr_f = counterf;
		x_ready = 0;
		f_ready = 1;
		y_valid = 0;
		en_acc = 0;
		clear = 0;
	end
	else if (present_state == start_math) begin
		addr_f = counterf;
		x_ready = 0;
		f_ready = 0;
		y_valid = 0;
		en_acc = 0;
		clear = 0;
	end
	else if (present_state == start_mult) begin
		addr_f = counterf;
		x_ready = 0;
		f_ready = 0;
		y_valid = 0;
		en_acc=1;
		clear = 0;
	end
	else if (present_state == output_result) begin
		addr_f = counterf;
		x_ready = 0;
		f_ready = 0;
		y_valid = 1;
		en_acc = 0;
		clear = 0;
	end
	else if (present_state == wait_s) begin
		addr_f = counterf;
		x_ready = 0;
		f_ready = 0;
		y_valid = 1;
		en_acc = 0;
		clear = 0;
	end
	else begin
		addr_f = counterf;
		x_ready = 0;
		f_ready = 0;
		y_valid = 0;
		en_acc = 0;
		clear = 0;
	end
end

////////////////////////////This will Adrresing Of X memory/////////////////////////////////////////////////
always_comb 
begin

	for (integer j = 0; j < M-N+1; j=j+1) begin
		addr_memx[j] = 0;
		if (x_ready && counterx >= j && counterx < j+N)
			addr_memx[j] = counterx - j;
		else if(next_state == start_math || next_state == start_mult)
			addr_memx[j] = counterf;
	end
end

///////////////////////////////////////////////////////This will Load output values from every mac unit to y_data//////////////////////////////
always_comb begin
	if (overflow_county)
		y_data = data_out[M-N];
	else
		y_data = data_out[countery-1];
end

///////////////////////////////////////////////////////////////////////////////////////////////////////////////
always_comb   // This comb block deals with state trasitions
begin

	if(present_state == init)
		next_state = upload;

	else if(present_state == upload && x_valid == 1 && f_valid == 1 && counterx == M-1 && counterf == N-1)
		next_state = start_math;
	
	else if(present_state == upload && x_valid == 1 && counterx == M-1)
		next_state = upload_f;
	
	else if(present_state == upload && f_valid == 1 && counterf == N-1)
		next_state = upload_x;
	
	else if(present_state == upload)
		next_state = upload;
	
	else if(present_state == upload_x && x_valid == 1 && counterx == M-1)
		next_state = start_math;
	
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
		next_state = output_result;

	else if(present_state == output_result && y_ready == 0)
		next_state = wait_s;

	else if(present_state == wait_s && y_ready == 1 &&  overflow_county == 1)
		next_state = init;

	else if(present_state == wait_s && y_ready == 1)
		next_state = output_result;
	
	else if(present_state == wait_s && y_ready == 0)
		next_state = wait_s;

	else
		next_state = nothing;
end

always_ff @(posedge clk) //This block deals with counters 
begin
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
 	end /// End Else
	end //End always_ff




endmodule





//==================================================MAC  MODULE=====================================================

module mac(clk,en_acc,clear_acc, data_x, data_f, y_data);

 input clk,clear_acc,en_acc;
 input signed [9:0] data_x, data_f;
 output logic signed [25:0] y_data;
 logic signed [25:0] product, sum;
 
  
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
