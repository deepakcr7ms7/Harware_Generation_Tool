
// Peter Milder, 8/10/21
// Testbench for ESE 507 Project 2 Part 1

// This testbench does the following:
//    - opens file random_in_f_p1.hex and random_in_x_p1.hex (input values to simulate) and stores
//      their values in arrays
//    - opens expected_out_p1.hex (expected output values) and stores its values in an array
//    - on each clock cycle, randomly picks values for valid and ready control signals
//    - uses these random control values to decide when to give new input and receive output
//    - automatically check expected output is correct

module tbench1();

    parameter  NUMITS     = 100000, N = 12, M = 5;
    localparam NUMXVALS   = N*NUMITS;
    localparam NUMFVALS   = M*NUMITS;
    localparam NUMOUTVALS = (N-M+1)*NUMITS;

    logic clk, x_valid, f_valid, x_ready, f_ready, y_valid, y_ready, reset;
    logic signed [9:0] x_data, f_data;
    logic signed [22:0] y_data;

    initial clk=0;
    always #5 clk = ~clk;

    // Instantiate DUT
    conv_12_5 dut (.clk(clk), .reset(reset),
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
    logic signed [9:0] invals_x[NUMXVALS-1:0], invals_f[NUMFVALS-1:0];
    initial $readmemh("random_in_x_p1.hex", invals_x);
    initial $readmemh("random_in_f_p1.hex", invals_f);

    // Store the expected values in another array
    logic signed [22:0] expectedOut[NUMOUTVALS-1:0];
    initial $readmemh("expected_out_p1.hex", expectedOut);

    logic [31:0] x_count;

    // If our random bit rb is set to 1, and if x_count is within the range of our test vector (invals),
    // we will set x_valid to 1.
    always @* begin
        if ((x_count>=0) && (x_count<NUMXVALS) && (rb==1'b1))
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

    logic [31:0] f_count;
    always @* begin
        if ((f_count>=0) && (f_count<NUMFVALS) && (rb2==1'b1))
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


    ////////////////////////////////////////////////////////////////////////////////////////
    // code to receive the output values


    // we will use another random bit (rb3) to determine if we can assert y_ready.
    logic [31:0] y_count;
    always @* begin
        if ((y_count >= 0) && (y_count < NUMOUTVALS) && (rb3==1'b1))
            y_ready = 1;
        else
            y_ready = 0;
    end

    integer errors=0;

    always @(posedge clk) begin
        if (y_ready && y_valid) begin
            if (y_data !== expectedOut[y_count]) begin
                $display("ERROR:   y[%d] = %d    expected output = %d", y_count, y_data, expectedOut[y_count]);
                $stop;
                errors = errors+1;
            end
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

        $display("Starting simulation. This may take a few seconds.");

        wait(y_count==NUMOUTVALS);

        $display("\n------------- simulation finished ------------------");
        $display("Simulated ", NUMITS, " iterations; ", NUMOUTVALS, " outputs");
        if (errors > 0)
            $display("Detected ", errors, " errors");
        else
            $display("No errors detected");
        $display("----------------------------------------------------\n");


        $finish;
    end


    // This is just here to keep the testbench from running forever in case of error.
    // In other words, if your system never produces the expected outputs, this code will stop
    // the simulation after NUMITS*200 clock cycles.
    initial begin
        repeat(NUMITS*200) begin
            @(posedge clk);
        end

        $display("Warning: Output not produced within", NUMITS*200, " clock cycles; stopping simulation so it doesn't run forever");
        $display("So far simulated ", y_count, " outputs");
        $stop;
    end

endmodule
