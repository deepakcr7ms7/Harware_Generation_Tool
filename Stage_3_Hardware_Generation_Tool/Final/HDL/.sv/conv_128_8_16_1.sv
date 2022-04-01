module conv_128_8_16_1(clk, reset, x_data, x_valid, x_ready, y_data, y_valid, y_ready);
   // your stuff here!
 parameter X =128 ; 
 parameter F =8; 
 input clk, reset, x_valid, y_ready;
 input signed [15:0]  x_data; 
 logic signed [15:0]  data_x;
 logic signed [15:0]  data_f;
 output logic x_ready, y_valid; 
 output logic signed[15:0] y_data; 
 logic[$clog2(X) - 1:0] addr_x, counterx, countery; 
 logic[$clog2(F) - 1:0] addr_f, counterf;
 logic overflow_county;
 logic overflow_countf;
 logic wr_en_x ,clear, en_acc, clear_accumulator; 
 parameter[3:0] init = 0, upload_x = 1, pipeline = 2, start_math = 3, start_mult = 4, output_result = 5, wait_s = 6, nothing = 8,start_math2 = 7; //states in my fsm
 logic[3:0] present_state, next_state; 
///////////////////////////////////////////////////////// Data Path///////////////////////////////////////////////////////////////////////////	 
 memory #(16, X) x(clk, x_data, data_x, addr_x, wr_en_x);            // X Memory Instantiation
 conv_128_8_16_1_f_rom r(clk,addr_f,data_f);
 mac m2(clk, en_acc, clear_accumulator, data_x, data_f, y_data);	     //Mac Module Instantiation	
//////////////////////////////////////////////////////////////////// Control Path(FSM) ///////////////////////////////////////////////////////
 assign wr_en_x = x_valid & x_ready;
 assign clear_accumulator = (y_valid & y_ready) | clear; 
 always_comb // This comb block will update the flags 
 begin
  if (present_state == init) begin 
  addr_x = counterx; 
  addr_f = counterf;
  x_ready = 1; 
  y_valid = 0;
  en_acc = 0; 
  clear = 1; 
 end 
 else if (present_state == upload_x) begin
    addr_x = counterx; 
    addr_f = counterf;
    x_ready = 1;
    y_valid = 0; 
    en_acc = 0;
    clear = 0;
 end 
 else if (present_state == start_mult) begin
    addr_x = counterx; 
    addr_f = counterf;
    x_ready = 0; 
    y_valid = 0; 
    en_acc = 1; 
    clear = 0; 
 end 
 else if (present_state == pipeline) begin
    addr_x = counterx; 
    addr_f = counterf;
    x_ready = 0; 
    y_valid = 0; 
    en_acc = 1; 
    clear = 0; 
 end 
 else if (present_state == output_result) begin 
    addr_x = counterx; 
    addr_f = counterf;
    x_ready = 0; 
    y_valid = 1; 
    en_acc = 0; 
    clear = 0; 
 end 
 else if (present_state == wait_s) begin
    addr_x = counterx; 
    addr_f = counterf;
    x_ready = 0; 
    y_valid = 1;
    en_acc = 0;
    clear = 0; 
 end 
 else begin 
    addr_x = counterx;
    addr_f = counterf;
    x_ready = 0; 
    y_valid = 0;
    en_acc = 0;
    clear = 0;
 end 
 end 
 always_comb  // This comb block deals with state trasitions
 begin 
    if (present_state == init)
        next_state = upload_x;
    else if (present_state == upload_x && x_valid == 1 && counterx == X - 1 )
        next_state = start_math;
    else if (present_state == upload_x)
        next_state = upload_x;
    else if (present_state == start_math)
        next_state = start_math2;
    else if (present_state == start_math2)
        next_state = start_mult;
    else if (present_state == start_mult && overflow_countf == 1)
        next_state = pipeline;
    else if (present_state == start_mult)
        next_state = start_mult;
    else if (present_state == pipeline)
        next_state = output_result;
    else if (present_state == output_result && y_ready == 1 && overflow_county == 1)
        next_state = init;
    else if (present_state == output_result && y_ready == 1)
        next_state = start_math;
    else if (present_state == output_result && y_ready == 0)
        next_state = wait_s;
    else if (present_state == wait_s && y_ready == 1 && overflow_county == 1)
        next_state = init;
    else if (present_state == wait_s && y_ready == 1)
        next_state = start_math;
    else if (present_state == wait_s && y_ready == 0)
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
overflow_countf<=0;
 end 
 else
 begin
    present_state <= next_state;
//Counters
 if (x_valid == 1 && x_ready == 1)
    counterx <= counterx + 1; 
 if (next_state == start_math)
 begin
    overflow_countf<=0;
    counterf <= 0;
    counterx <= countery;
 end
 else if (next_state == start_mult && counterf==F-1)
 begin
overflow_countf<=1;
    counterx <= counterx + 1; 
    counterf <= counterf + 1;
 end 
 else if (next_state == start_mult || next_state==start_math2)
 begin
    counterx <= counterx + 1; 
    counterf <= counterf + 1;
 end 
 else if (next_state == output_result && countery == X - F)
 begin 
    overflow_county <= 1; 
    countery <= countery + 1;
 end 
 else if (next_state == output_result)
    countery <= countery + 1; 
 else if (next_state == init)
 begin 
    counterx <= 0; 
    counterf <= 0; 
    countery <= 0; 
    overflow_county <= 0;
overflow_countf<=0;
 end 
 end 
 end 
endmodule
 
module mac(clk, en_acc, clear_acc, data_x, data_f, y_data);
 input clk, clear_acc, en_acc;
 input signed[15:0] data_x, data_f;
 output logic signed[15:0] y_data; 
 logic signed [16:0]  mult; 
 logic signed[15:0] p_in, p_out;
 logic signed[16:0]accumulate;
 logic signed[15:0] y, sum;
logic signed [15:0]  overflow = (1<<15) - 1 ;
logic signed [15:0] underflow = (1<<15);
 
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
        y_data = 0;
    end
    else
    begin
        y_data = y;
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
module conv_128_8_16_1_f_rom(clk, addr, z);
   input clk;
   input [2:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= 16'd95;
        1: z <= 16'd191;
        2: z <= 16'd158;
        3: z <= -16'd47;
        4: z <= -16'd234;
        5: z <= -16'd41;
        6: z <= 16'd10;
        7: z <= 16'd82;
      endcase
   end
endmodule

