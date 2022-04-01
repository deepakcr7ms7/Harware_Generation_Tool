// ESE 507 Project 3 Handout Code
// You may not redistribute this code

// Getting started:
// The main() function contains the code to read the parameters.
// For Parts 1 and 2, your code should be in the genLayer() function. Please
// also look at this function to see an example for how to create the ROMs.
//
// For Part 3, your code should be in the genAllLayers() function.

#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <cstdlib>
#include <cstring>
#include <assert.h>
#include <math.h>
#include <array>
#include <memory>
using namespace std;

// Function prototypes
void printUsage();
void genLayer(int N, int M, int T, int P, vector<int>& constvector, string modName, ofstream &os);
void genAllLayers(int N, int M1, int M2, int M3, int T, int A, vector<int>& constVector, string modName, ofstream &os);
void readConstants(ifstream &constStream, vector<int>& constvector);
void genROM(vector<int>& constVector, int bits, string modName, ofstream &os);




int main(int argc, char* argv[]) {

    // If the user runs the program without enough parameters, print a helpful message
    // and quit.
    if (argc < 6) {
        printUsage();
        return 1;
    }

    int mode = atoi(argv[1]);

    ifstream const_file;
    ofstream os;
    vector<int> constVector;

    //----------------------------------------------------------------------
    // Look here for Part 1 and 2
    if (((mode == 1) && (argc == 6)) || ((mode == 2) && (argc==7)) ) {

        // Modes 1 and 2: Generate one layer

        // --------------- read parameters, etc. ---------------
        int N = atoi(argv[2]);
        int M = atoi(argv[3]);
        int T = atoi(argv[4]);

        int P;

        if (mode == 1) {
            P = 1;
            const_file.open(argv[5]);

            if (const_file.is_open() != true) {
                cout << "ERROR reading constant file " << argv[5] << endl;
                return 1;
            } 
        }
        else {
            P = atoi(argv[5]);
            const_file.open(argv[6]);

            if (const_file.is_open() != true) {
                cout << "ERROR reading constant file " << argv[6] << endl;
                return 1;
            }
        }

        // Read the constants out of the provided file and place them in the constVector vector
        readConstants(const_file, constVector);

        string out_file = "conv_" + to_string(N) + "_" + to_string(M) + "_" + to_string(T) + "_" + to_string(P) + ".sv";

        os.open(out_file);
        if (os.is_open() != true) {
            cout << "ERROR opening " << out_file << " for write." << endl;
            return 1;
        }
        // -------------------------------------------------------------

        // call the genLayer function you will write to generate this layer
        string modName = "conv_" + to_string(N) + "_" + to_string(M) + "_" + to_string(T) + "_" + to_string(P);
        genLayer(N, M, T, P, constVector, modName, os); 

    }
    //--------------------------------------------------------------------


    // ----------------------------------------------------------------
    // Look here for Part 3
    else if ((mode == 3) && (argc == 9)) {

        // Mode 3: Generate three layer with given dimensions and interconnect them

        // --------------- read parameters, etc. ---------------
        int N  = atoi(argv[2]);
        int M1 = atoi(argv[3]);
        int M2 = atoi(argv[4]);
        int M3 = atoi(argv[5]);
        int T  = atoi(argv[6]);
        int A  = atoi(argv[7]);
        const_file.open(argv[8]);
        if (const_file.is_open() != true) {
            cout << "ERROR reading constant file " << argv[8] << endl;
            return 1;
        }
        readConstants(const_file, constVector);

        string out_file = "net_" + to_string(N) + "_" + to_string(M1) + "_" + to_string(M2) + "_" + to_string(M3) + "_" + to_string(T) + "_" + to_string(A) + ".sv";

        os.open(out_file);
        if (os.is_open() != true) {
            cout << "ERROR opening " << out_file << " for write." << endl;
            return 1;
        }
        // -------------------------------------------------------------

        string mod_name = "net_" + to_string(N) + "_" + to_string(M1) + "_" + to_string(M2) + "_" + to_string(M3) + "_" + to_string(T) + "_" + to_string(A);

        // call the genAllLayers function
        genAllLayers(N, M1, M2, M3, T, A, constVector, mod_name, os);

    }
    //-------------------------------------------------------

    else {
        printUsage();
        return 1;
    }

    // close the output stream
    os.close();

}

// Read values from the constant file into the vector
void readConstants(ifstream &constStream, vector<int>& constvector) {
    string constLineString;
    while(getline(constStream, constLineString)) {
        int val = atoi(constLineString.c_str());
        constvector.push_back(val);
    }
}

// Generate a ROM based on values constVector.
// Values should each be "bits" number of bits.
void genROM(vector<int>& constVector, int bits, string modName, ofstream &os) {

        int numWords = constVector.size();
        int addrBits = ceil(log2(numWords));
        
  
        os << "module " << modName << "(clk, addr, z);" << endl;
        os << "   input clk;" << endl;
        os << "   input [" << addrBits-1 << ":0] addr;" << endl;
        os << "   output logic signed [" << bits-1 << ":0] z;" << endl;
        os << "   always_ff @(posedge clk) begin" << endl;
        os << "      case(addr)" << endl;
        int i=0;
        for (vector<int>::iterator it = constVector.begin(); it < constVector.end(); it++, i++) {
            if (*it < 0)
                os << "        " << i << ": z <= -" << bits << "'d" << abs(*it) << ";" << endl;
            else
                os << "        " << i << ": z <= "  << bits << "'d" << *it      << ";" << endl;
        }
        os << "      endcase" << endl << "   end" << endl << "endmodule" << endl << endl;
}

// Parts 1 and 2
// Here is where you add your code to produce one convolution
void genLayer(int N, int M, int T, int P, vector<int>& constVector, string modName, ofstream &os) {
    if (P == 1) {
        os << "module " << modName << "(clk, reset, x_data, x_valid, x_ready, y_data, y_valid, y_ready);" << endl;
        os << "   // your stuff here!" << endl;
        os << " parameter X =" << N << " ; " << endl;
        os << " parameter F =" << M << "; " << endl;
        os << " input clk, reset, x_valid, y_ready;" << endl;
        os << " input signed [" << T - 1 << ":0]  x_data; " << endl;
        os << " logic signed [" << T - 1 << ":0]  data_x;" << endl;
        os << " logic signed [" << T - 1 << ":0]  data_f;" << endl;
        os << " output logic x_ready, y_valid; " << endl;
        os << " output logic signed[" << T - 1 << ":0] y_data; " << endl;
        os << " logic[$clog2(X) - 1:0] addr_x, counterx, countery; " << endl;
        os << " logic[$clog2(F) - 1:0] addr_f, counterf;" << endl;
        os << " logic overflow_county;" << endl;
        os << " logic overflow_countf;" << endl;

        os << " logic wr_en_x ,clear, en_acc, clear_accumulator; " << endl;


        os << " parameter[3:0] init = 0, upload_x = 1, pipeline = 2, start_math = 3, start_mult = 4, output_result = 5, wait_s = 6, nothing = 8,start_math2 = 7; //states in my fsm" << endl;
        os << " logic[3:0] present_state, next_state; " << endl;

        os << "///////////////////////////////////////////////////////// Data Path///////////////////////////////////////////////////////////////////////////	 " << endl;

        os << " memory #" << "(" << T << ", X) x(clk, x_data, data_x, addr_x, wr_en_x);            // X Memory Instantiation" << endl;
        os << " " << modName + "_f_rom" << " r" << "(clk,addr_f,data_f);" << endl;

        os << " mac m2(clk, en_acc, clear_accumulator, data_x, data_f, y_data);	     //Mac Module Instantiation	" << endl;


        os << "//////////////////////////////////////////////////////////////////// Control Path(FSM) ///////////////////////////////////////////////////////" << endl;

        os << " assign wr_en_x = x_valid & x_ready;" << endl;
        os << " assign clear_accumulator = (y_valid & y_ready) | clear; " << endl;



        os << " always_comb // This comb block will update the flags " << endl;
        os << " begin" << endl;
        os << "  if (present_state == init) begin " << endl;
        os << "  addr_x = counterx; " << endl;
        os << "  addr_f = counterf;" << endl;
        os << "  x_ready = 1; " << endl;
        os << "  y_valid = 0;" << endl;
        os << "  en_acc = 0; " << endl;
        os << "  clear = 1; " << endl;
        os << " end " << endl;

        os << " else if (present_state == upload_x) begin" << endl;
        os << "    addr_x = counterx; " << endl;
        os << "    addr_f = counterf;" << endl;
        os << "    x_ready = 1;" << endl;
        os << "    y_valid = 0; " << endl;
        os << "    en_acc = 0;" << endl;
        os << "    clear = 0;" << endl;
        os << " end " << endl;
        os << " else if (present_state == start_mult) begin" << endl;
        os << "    addr_x = counterx; " << endl;
        os << "    addr_f = counterf;" << endl;
        os << "    x_ready = 0; " << endl;
        os << "    y_valid = 0; " << endl;
        os << "    en_acc = 1; " << endl;
        os << "    clear = 0; " << endl;
        os << " end " << endl;
        os << " else if (present_state == pipeline) begin" << endl;
        os << "    addr_x = counterx; " << endl;
        os << "    addr_f = counterf;" << endl;
        os << "    x_ready = 0; " << endl;
        os << "    y_valid = 0; " << endl;
        os << "    en_acc = 1; " << endl;
        os << "    clear = 0; " << endl;
        os << " end " << endl;

        os << " else if (present_state == output_result) begin " << endl;
        os << "    addr_x = counterx; " << endl;
        os << "    addr_f = counterf;" << endl;
        os << "    x_ready = 0; " << endl;
        os << "    y_valid = 1; " << endl;
        os << "    en_acc = 0; " << endl;
        os << "    clear = 0; " << endl;
        os << " end " << endl;
        os << " else if (present_state == wait_s) begin" << endl;
        os << "    addr_x = counterx; " << endl;
        os << "    addr_f = counterf;" << endl;
        os << "    x_ready = 0; " << endl;
        os << "    y_valid = 1;" << endl;
        os << "    en_acc = 0;" << endl;
        os << "    clear = 0; " << endl;
        os << " end " << endl;
        os << " else begin " << endl;
        os << "    addr_x = counterx;" << endl;
        os << "    addr_f = counterf;" << endl;
        os << "    x_ready = 0; " << endl;
        os << "    y_valid = 0;" << endl;
        os << "    en_acc = 0;" << endl;
        os << "    clear = 0;" << endl;
        os << " end " << endl;
        os << " end " << endl;


        os << " always_comb  // This comb block deals with state trasitions" << endl;
        os << " begin " << endl;

        os << "    if (present_state == init)" << endl;
        os << "        next_state = upload_x;" << endl;

        os << "    else if (present_state == upload_x && x_valid == 1 && counterx == X - 1 )" << endl;
        os << "        next_state = start_math;" << endl;
        os << "    else if (present_state == upload_x)" << endl;

        os << "        next_state = upload_x;" << endl;

        os << "    else if (present_state == start_math)" << endl;
        os << "        next_state = start_math2;" << endl;

        os << "    else if (present_state == start_math2)" << endl;
        os << "        next_state = start_mult;" << endl;


        os << "    else if (present_state == start_mult && overflow_countf == 1)" << endl;
        os << "        next_state = pipeline;" << endl;

        os << "    else if (present_state == start_mult)" << endl;
        os << "        next_state = start_mult;" << endl;

        os << "    else if (present_state == pipeline)" << endl;
        os << "        next_state = output_result;" << endl;


        os << "    else if (present_state == output_result && y_ready == 1 && overflow_county == 1)" << endl;
        os << "        next_state = init;" << endl;

        os << "    else if (present_state == output_result && y_ready == 1)" << endl;
        os << "        next_state = start_math;" << endl;

        os << "    else if (present_state == output_result && y_ready == 0)" << endl;
        os << "        next_state = wait_s;" << endl;

        os << "    else if (present_state == wait_s && y_ready == 1 && overflow_county == 1)" << endl;
        os << "        next_state = init;" << endl;

        os << "    else if (present_state == wait_s && y_ready == 1)" << endl;
        os << "        next_state = start_math;" << endl;

        os << "    else if (present_state == wait_s && y_ready == 0)" << endl;
        os << "        next_state = wait_s;" << endl;

        os << "    else" << endl;
        os << "        next_state = nothing;" << endl;
        os << " end" << endl;


        os << " " << endl;

        os << " always_ff @(posedge clk) begin //This block deals with counters " << endl;
        os << " if (reset == 1)" << endl;
        os << " begin " << endl;
        os << "    present_state <= init;" << endl;
        os << "    counterx <= 0; " << endl;
        os << "    counterf <= 0;" << endl;
        os << "    countery <= 0;" << endl;
        os << "    overflow_county <= 0;" << endl;
        os << "overflow_countf<=0;" << endl;

        os << " end " << endl;
        os << " else" << endl;
        os << " begin" << endl;
        os << "    present_state <= next_state;" << endl;

        os << "//Counters" << endl;

        os << " if (x_valid == 1 && x_ready == 1)" << endl;
        os << "    counterx <= counterx + 1; " << endl;

        os << " if (next_state == start_math)" << endl;
        os << " begin" << endl;
        os << "    overflow_countf<=0;" << endl;
        os << "    counterf <= 0;" << endl;
        os << "    counterx <= countery;" << endl;
        os << " end" << endl;
        os << " else if (next_state == start_mult && counterf==F-1)" << endl;
        os << " begin" << endl;
        os << "overflow_countf<=1;" << endl;
        os << "    counterx <= counterx + 1; " << endl;
        os << "    counterf <= counterf + 1;" << endl;
        os << " end " << endl;

        os << " else if (next_state == start_mult || next_state==start_math2)" << endl;
        os << " begin" << endl;
        os << "    counterx <= counterx + 1; " << endl;
        os << "    counterf <= counterf + 1;" << endl;
        os << " end " << endl;

        os << " else if (next_state == output_result && countery == X - F)" << endl;
        os << " begin " << endl;
        os << "    overflow_county <= 1; " << endl;
        os << "    countery <= countery + 1;" << endl;
        os << " end " << endl;

        os << " else if (next_state == output_result)" << endl;
        os << "    countery <= countery + 1; " << endl;

        os << " else if (next_state == init)" << endl;
        os << " begin " << endl;
        os << "    counterx <= 0; " << endl;
        os << "    counterf <= 0; " << endl;
        os << "    countery <= 0; " << endl;
        os << "    overflow_county <= 0;" << endl;
        os << "overflow_countf<=0;" << endl;

        os << " end " << endl;
        os << " end " << endl;

        os << " end " << endl;

        os << "endmodule" << endl;
        os << " " << endl;






        os << "module mac(clk, en_acc, clear_acc, data_x, data_f, y_data);" << endl;

        os << " input clk, clear_acc, en_acc;" << endl;
        os << " input signed[" << T - 1 << ":0] data_x, data_f;" << endl;
        os << " output logic signed[" << T - 1 << ":0] y_data; " << endl;
        os << " logic signed [" << T << ":0]  mult; " << endl;
        os << " logic signed[" << T - 1 << ":0] p_in, p_out;" << endl;

        os << " logic signed[" << T << ":0]accumulate;" << endl;

        os << " logic signed[" << T - 1 << ":0] y, sum;" << endl;

        os << "logic signed [" << T - 1 << ":0]  overflow = (1<<" << (T - 1) << ") - 1 ;" << endl;
        os << "logic signed [" << T - 1 << ":0] underflow = (1<<" << (T - 1) << ");" << endl;
        os << " " << endl;
        os << " always_ff @(posedge clk) begin" << endl;

        os << "    if (clear_acc == 1) begin                // Pipeline registor" << endl;
        os << "        p_out <= 0;" << endl;
        os << "    end" << endl;
        os << "    else" << endl;
        os << "        p_out <= p_in;" << endl;
        os << "    end" << endl;
        os << " " << endl;

        os << " always_ff @(posedge clk) begin" << endl;
        os << "    if (clear_acc == 1) begin" << endl;
        os << "        y <= 0;" << endl;
        os << "    end" << endl;
        os << "    else if (en_acc == 1)" << endl;
        os << "    begin" << endl;

        os << "        y <= sum;" << endl;

        os << "    end" << endl;
        os << "    end" << endl;
        os << " " << endl;

        os << " always_comb begin" << endl;

        os << " mult = data_x * data_f;" << endl;

        os << "    if (mult < underflow)" << endl;
        os << "        p_in = underflow;" << endl;
        os << "    else if (mult > overflow)" << endl;
        os << "        p_in = overflow;" << endl;
        os << "    else" << endl;
        os << "        p_in = mult;" << endl;
        os << " " << endl;
        os << "end" << endl;
        os << " always_comb begin" << endl;
        os << " accumulate = p_out + y; " << endl;
        os << " " << endl;
        os << " if (accumulate < underflow) " << endl;
        os << "    sum = underflow; " << endl;
        os << "    else if (accumulate > overflow) " << endl;
        os << "    sum = overflow; " << endl;
        os << " else " << endl;
        os << "    sum = accumulate ;" << endl;


        os << " end" << endl;
        os << " " << endl;
        os << " " << endl;
        os << "//RELU Block" << endl;

        os << " always_comb" << endl;
        os << "begin" << endl;
        os << "    if (y < 0)begin" << endl;
        os << "        y_data = 0;" << endl;
        os << "    end" << endl;
        os << "    else" << endl;
        os << "    begin" << endl;
        os << "        y_data = y;" << endl;
        os << "    end" << endl;
        os << " " << endl;
        os << "    end" << endl;

        os << " " << endl;
        os << " endmodule " << endl;

      

        os << "//==================================================MEMORY  MODULE=====================================================" << endl;

        os << "module memory(clk, data_in, data_out, addr, wr_en);" << endl;
        os << " parameter WIDTH = 16, SIZE = 64;" << endl;
        os << "localparam LOGSIZE = $clog2(SIZE); " << endl;
        os << " input[WIDTH - 1:0] data_in;" << endl;
        os << "output logic[WIDTH - 1:0] data_out; " << endl;
        os << "input[LOGSIZE - 1:0] addr; " << endl;
        os << "input clk, wr_en; " << endl;
        os << "logic[SIZE - 1:0][WIDTH - 1:0] mem; " << endl;
        os << "always_ff @(posedge clk) begin" << endl;
        os << "  data_out <= mem[addr];" << endl;
        os << "if (wr_en) " << endl;
        os << "mem[addr] <= data_in;" << endl;
        os << " end " << endl;
        os << "endmodule " << endl;
    }
    else
    {

    os << "module " << modName << "(clk, reset, x_data, x_valid, x_ready, y_data, y_valid, y_ready);" << endl;
    os << "   // your stuff here!" << endl;
    os << " parameter X =" << N << " ; " << endl;
    os << " parameter F =" << M << "; " << endl;
    os << " input clk, reset, x_valid, y_ready;" << endl;
    os << " input signed [" << T - 1 << ":0]  x_data; " << endl;
    os << " logic signed [" << T - 1 << ":0]  data_x[X-F:0];" << endl;
    os << " logic signed [" << T - 1 << ":0]  data_f;" << endl;
    os << " output logic x_ready, y_valid; " << endl;
    os << " logic signed [" << T - 1 << ":0]  data_out ["<<P<<":0]; " << endl;
    os << " output logic signed[" << T - 1 << ":0] y_data; " << endl;
    os << " logic[$clog2(X) - 1:0] addr_memx [X-F:0];" << endl;
    os << " logic[$clog2(X) - 1:0] counterx, countery; " << endl;
    os << " logic[$clog2(F) - 1:0] addr_f, counterf;" << endl;
    os << " logic overflow_county;" << endl;
    os << " logic overflow_countf;" << endl;
    os << " logic [X-F:0]  wr_en_x;" << endl;
    os << " logic clear ,en_acc, clear_accumulator; " << endl;


    os << " parameter[3:0] init = 0, upload_x = 1, pipeline = 2, start_math = 3, start_mult = 4, output_result = 5, wait_s = 6, nothing = 7,start_math2 = 7; //states in my fsm" << endl;
    os << " logic[3:0] present_state, next_state; " << endl;

    os << "///////////////////////////////////////////////////////// Data Path///////////////////////////////////////////////////////////////////////////	 " << endl;
    os << "integer  j, k; " << endl;
    os << "genvar i; " << endl;
    os << " ///////////////////////////////////////// Memories and MAC ///////////////////////////////////////////////////////////// " << endl;
        os << " generate " << endl;
        os << "     for (i = 0; i <"<< P <<"; i = i + 1)begin " << endl;
    os << "         memory #" << "(" << T << ", X) x(clk, x_data, data_x[i], addr_memx[i], wr_en_x[i]);            // X Memory Instantiation" << endl;
  

    os << "         mac m2(clk, en_acc, clear_accumulator, data_x[i], data_f, data_out[i]);	     //Mac Module Instantiation	" << endl;
    os << " end" << endl;
        os << " endgenerate" << endl;

    os << " " << modName + "_f_rom" << " r" << "(clk,addr_f,data_f);" << endl;
    os << "//////////////////////////////////////////////////////////////////// Control Path(FSM) ///////////////////////////////////////////////////////" << endl;

    
    os << " assign clear_accumulator = (y_valid & y_ready) | clear; " << endl;

    os << " //////////////// Asserting X Memory Write Enable //////////////////////////////////////////////////////////////////////// " << endl;


        os << " always_comb begin" << endl;
        os << " for (k = 0; k < "<< P <<"; k = k + 1) begin" << endl;
        os << " if (x_valid && x_ready && counterx >= k && counterx < k + F)" << endl;
        os << "        wr_en_x[k] = 1;" << endl;
        os << " else" << endl;
        os << "        wr_en_x[k] = 0;" << endl;
        os << "  end" << endl;
        os << "end" << endl;




    os << " always_comb // This comb block will update the flags " << endl;
    os << " begin" << endl;
    os << "  if (present_state == init) begin " << endl;
    os << "  addr_f = counterf;" << endl;
    os << "  x_ready = 1; " << endl;
    os << "  y_valid = 0;" << endl;
    os << "  en_acc = 0; " << endl;
    os << "  clear = 1; " << endl;
    os << " end " << endl;

    os << " else if (present_state == upload_x) begin" << endl;
    os << "    addr_f = counterf;" << endl;
    os << "    x_ready = 1;" << endl;
    os << "    y_valid = 0; " << endl;
    os << "    en_acc = 0;" << endl;
    os << "    clear = 0;" << endl;
    os << " end " << endl;
    os << " else if (present_state == start_mult) begin" << endl;
    os << "    addr_f = counterf;" << endl;
    os << "    x_ready = 0; " << endl;
    os << "    y_valid = 0; " << endl;
    os << "    en_acc = 1; " << endl;
    os << "    clear = 0; " << endl;
    os << " end " << endl;
    os << " else if (present_state == pipeline) begin" << endl;
    os << "    addr_f = counterf;" << endl;
    os << "    x_ready = 0; " << endl;
    os << "    y_valid = 0; " << endl;
    os << "    en_acc = 1; " << endl;
    os << "    clear = 0; " << endl;
    os << " end " << endl;

    os << " else if (present_state == output_result) begin " << endl;
    os << "    addr_f = counterf;" << endl;
    os << "    x_ready = 0; " << endl;
    os << "    y_valid = 1; " << endl;
    os << "    en_acc = 0; " << endl;
    os << "    clear = 0; " << endl;
    os << " end " << endl;
    os << " else if (present_state == wait_s) begin" << endl;
    os << "    addr_f = counterf;" << endl;
    os << "    x_ready = 0; " << endl;
    os << "    y_valid = 1;" << endl;
    os << "    en_acc = 0;" << endl;
    os << "    clear = 0; " << endl;
    os << " end " << endl;
    os << " else begin " << endl;
    os << "    addr_f = counterf;" << endl;
    os << "    x_ready = 0; " << endl;
    os << "    y_valid = 0;" << endl;
    os << "    en_acc = 0;" << endl;
    os << "    clear = 0;" << endl;
    os << " end " << endl;
    os << " end " << endl;



    os << " always_comb  // This comb block deals with state trasitions" << endl;
    os << " begin " << endl;

    os << "    if (present_state == init)" << endl;
    os << "        next_state = upload_x;" << endl;

    os << "    else if (present_state == upload_x && x_valid == 1 && counterx ==  F )" << endl;
    os << "        next_state = start_math;" << endl;
    os << "    else if (present_state == upload_x)" << endl;

    os << "        next_state = upload_x;" << endl;

    os << "    else if (present_state == start_math)" << endl;
    os << "        next_state = start_math2;" << endl;

    os << "    else if (present_state == start_math2)" << endl;
    os << "        next_state = start_mult;" << endl;


    os << "    else if (present_state == start_mult && overflow_countf == 1)" << endl;
    os << "        next_state = pipeline;" << endl;

    os << "    else if (present_state == start_mult)" << endl;
    os << "        next_state = start_mult;" << endl;

    os << "    else if (present_state == pipeline)" << endl;
    os << "        next_state = output_result;" << endl;


    os << "    else if (present_state == output_result && y_ready == 1 && overflow_county == 1)" << endl;
    os << "        next_state = init;" << endl;

    os << "    else if (present_state == output_result && y_ready == 1)" << endl;
    os << "        next_state = start_math;" << endl;

    os << "    else if (present_state == output_result && y_ready == 0)" << endl;
    os << "        next_state = wait_s;" << endl;

    os << "    else if (present_state == wait_s && y_ready == 1 && overflow_county == 1)" << endl;
    os << "        next_state = init;" << endl;

    os << "    else if (present_state == wait_s && y_ready == 1)" << endl;
    os << "        next_state = start_math;" << endl;

    os << "    else if (present_state == wait_s && y_ready == 0)" << endl;
    os << "        next_state = wait_s;" << endl;

    os << "    else" << endl;
    os << "        next_state = nothing;" << endl;
    os << " end" << endl;


    os << " " << endl;
    os << " ////////////////////////////This will Adrresing Of X memory/////////////////////////////////////////////////" << endl;
        os << "always_comb" << endl;
        os << "   begin" << endl;
        os << " " << endl;
        os << "     for (integer j = 0; j <"<< P<<"; j = j + 1) begin" << endl;
        os << "         addr_memx[j] = 0;" << endl;
        os << "         if (x_ready && counterx >= j && counterx < j + F)" << endl;
        os << "             addr_memx[j] = counterx - j;" << endl;
        os << "         else if (next_state == start_math || next_state == start_mult)" << endl;
        os << "             addr_memx[j] = counterf;" << endl;
        os << "         end" << endl;
        os << "     end" << endl;
        os << " " << endl;
        os << "///////////////////////////////////////////////////////This will Load output values from every mac unit to y_data//////////////////////////////" << endl;
        os << "always_comb begin" << endl;
        os << "if (overflow_county)" << endl;
        os << "    y_data = data_out["<<P<<"];" << endl;
        os << "else" << endl;
        os << "    y_data = data_out[countery - 1];" << endl;
        os << "end" << endl;

    os << " always_ff @(posedge clk) begin //This block deals with counters " << endl;
    os << " if (reset == 1)" << endl;
    os << " begin " << endl;
    os << "    present_state <= init;" << endl;
    os << "    counterx <= 0; " << endl;
    os << "    counterf <= 0;" << endl;
    os << "    countery <= 0;" << endl;
    os << "    overflow_county <= 0;" << endl;
    os << "overflow_countf<=0;" << endl;

    os << " end " << endl;
    os << " else" << endl;
    os << " begin" << endl;
    os << "    present_state <= next_state;" << endl;

    os << "//Counters" << endl;

    os << " if (x_valid == 1 && x_ready == 1)" << endl;
    os << "    counterx <= counterx + 1; " << endl;

    os << " if (next_state == start_math)" << endl;
    os << " begin" << endl;
    os << "    overflow_countf<=0;" << endl;
    os << "    counterf <= 0;" << endl;
    os << "    counterx <= countery;" << endl;
    os << " end" << endl;
    os << " else if (next_state == start_mult && counterf==F-1)" << endl;
    os << " begin" << endl;
    os << "overflow_countf<=1;" << endl;
    os << "    counterx <= counterx + 1; " << endl;
    os << "    counterf <= counterf + 1;" << endl;
    os << " end " << endl;

    os << " else if (next_state == start_mult || next_state==start_math2)" << endl;
    os << " begin" << endl;
    os << "    counterx <= counterx + 1; " << endl;
    os << "    counterf <= counterf + 1;" << endl;
    os << " end " << endl;

    os << " else if (next_state == output_result && countery == X - F)" << endl;
    os << " begin " << endl;
    os << "    overflow_county <= 1; " << endl;
    os << "    countery <= countery + 1;" << endl;
    os << " end " << endl;

    os << " else if (next_state == output_result)" << endl;
    os << "    countery <= countery + 1; " << endl;

    os << " else if (next_state == init)" << endl;
    os << " begin " << endl;
    os << "    counterx <= 0; " << endl;
    os << "    counterf <= 0; " << endl;
    os << "    countery <= 0; " << endl;
    os << "    overflow_county <= 0;" << endl;
    os << "overflow_countf<=0;" << endl;

    os << " end " << endl;
    os << " end " << endl;

    os << " end " << endl;

    os << "endmodule" << endl;
    os << " " << endl;






    os << "module mac(clk, en_acc, clear_acc, data_x, data_f, y_data);" << endl;

    os << " input clk, clear_acc, en_acc;" << endl;
    os << " input signed[" << T - 1 << ":0] data_x, data_f;" << endl;
    os << " output logic signed[" << T - 1 << ":0] y_data; " << endl;
    os << " logic signed [" << T << ":0]  mult; " << endl;
    os << " logic signed[" << T - 1 << ":0] p_in, p_out;" << endl;

    os << " logic signed[" << T << ":0]accumulate;" << endl;

    os << " logic signed[" << T - 1 << ":0] y, sum;" << endl;

    os << " logic signed[" << T - 1 << ":0]  overflow = (1<<" << (T - 1) << ") - 1 ;" << endl;
    os << " logic signed [" << T - 1 << ":0] underflow = (1<<" << (T - 1) << ");" << endl;
    os << " " << endl;
    os << " always_ff @(posedge clk) begin" << endl;

    os << "    if (clear_acc == 1) begin                // Pipeline registor" << endl;
    os << "        p_out <= 0;" << endl;
    os << "    end" << endl;
    os << "    else" << endl;
    os << "        p_out <= p_in;" << endl;
    os << "    end" << endl;
    os << " " << endl;

    os << " always_ff @(posedge clk) begin" << endl;
    os << "    if (clear_acc == 1) begin" << endl;
    os << "        y <= 0;" << endl;
    os << "    end" << endl;
    os << "    else if (en_acc == 1)" << endl;
    os << "    begin" << endl;

    os << "        y <= sum;" << endl;

    os << "    end" << endl;
    os << "    end" << endl;
    os << " " << endl;

    os << " always_comb begin" << endl;

    os << " mult = data_x * data_f;" << endl;

    os << "    if (mult < underflow)" << endl;
    os << "        p_in = underflow;" << endl;
    os << "    else if (mult > overflow)" << endl;
    os << "        p_in = overflow;" << endl;
    os << "    else" << endl;
    os << "        p_in = mult;" << endl;
    os << " " << endl;
    os << "end" << endl;
    os << " always_comb begin" << endl;
    os << " accumulate = p_out + y; " << endl;
    os << " " << endl;
    os << " if (accumulate < underflow) " << endl;
    os << "    sum = underflow; " << endl;
    os << "    else if (accumulate > overflow) " << endl;
    os << "    sum = overflow; " << endl;
    os << " else " << endl;
    os << "    sum = accumulate ;" << endl;


    os << " end" << endl;
    os << " " << endl;
    os << " " << endl;
    os << "//RELU Block" << endl;

    os << " always_comb" << endl;
    os << "begin" << endl;
    os << "    if (y < 0)begin" << endl;
    os << "        y_data = 0;" << endl;
    os << "    end" << endl;
    os << "    else" << endl;
    os << "    begin" << endl;
    os << "        y_data = y;" << endl;
    os << "    end" << endl;
    os << " " << endl;
    os << "    end" << endl;

    os << " " << endl;
    os << " endmodule " << endl;



    os << "//==================================================MEMORY  MODULE=====================================================" << endl;

    os << "module memory(clk, data_in, data_out, addr, wr_en);" << endl;
    os << " parameter WIDTH = 16, SIZE = 64;" << endl;
    os << "localparam LOGSIZE = $clog2(SIZE); " << endl;
    os << " input[WIDTH - 1:0] data_in;" << endl;
    os << "output logic[WIDTH - 1:0] data_out; " << endl;
    os << "input[LOGSIZE - 1:0] addr; " << endl;
    os << "input clk, wr_en; " << endl;
    os << "logic[SIZE - 1:0][WIDTH - 1:0] mem; " << endl;
    os << "always_ff @(posedge clk) begin" << endl;
    os << "  data_out <= mem[addr];" << endl;
    os << "if (wr_en) " << endl;
    os << "mem[addr] <= data_in;" << endl;
    os << " end " << endl;
    os << "endmodule " << endl;

    }

    // You will need to generate ROM(s) with values from the pre-stored constant values.
    // Here is code that demonstrates how to do this for the simple case where you want to put all of
    // the filter values f into one ROM.

    // Check there are enough values in the constant file.
    if (M > constVector.size()) {
        cout << "ERROR: constVector does not contain enough data for the requested design" << endl;
        cout << "The design parameters requested require " << M << " numbers, but the provided data only have " << constVector.size() << " constants" << endl;
        assert(false);
    }

    // Generate a ROM for f with constants in constVector, T bits, and the given name
    string romModName = modName + "_f_rom";
    genROM(constVector, T, romModName, os);

}


// Part 3: Generate a hardware system with three convolutions interconnected.
// Layer 1: Input length: N,  filter length: M1, output length: L1 = N-M1+1
// Layer 2: Input length: L1, filter length: M2, output length: L2 = L1-M2+1
// Layer 3: Input length: M2, filter length: M3, output length: L3 = L2-M3+1
// T is the number of bits
// A is the number of multipliers your overall design may use.
// Your goal is to build the highest-throughput design that uses A or fewer multipliers
// constVector holds all the constants for your system (all three layers, in order)
void genAllLayers(int N, int M1, int M2, int M3, int T, int A, vector<int>& constVector, string modName, ofstream &os) {

    // Here you will write code to figure out the best values to use for P1, P2, and P3, given
    // mult_budget. 
    int P1 = 1; // replace this with your optimized value
    int P2 = 1; // replace this with your optimized value
    int P3 = 1; // replace this with your optimized value

    // output top-level module
    os << "module " << modName << "();" << endl;
    os << "   // this module should instantiate three convolution modules and wire them together" << endl;
    os << "endmodule" << endl << endl;



    // -------------------------------------------------------------------------
    // Split up constVector for the three layers.

    // The first layer's values are entries 0 to M1-1.
    int start = 0;
    int stop = M1;
    vector<int> constVector1(&constVector[start], &constVector[stop]);

    // The filter values f for layer 2 will have length M2.
    start = stop;
    stop = start+M2;
    vector<int> constVector2(&constVector[start], &constVector[stop]);

    // The filter values f for layer 2 will have length M3.
    start = stop;
    stop = start+M3;
    vector<int> constVector3(&constVector[start], &constVector[stop]);

    if (stop > constVector.size()) {
        cout << "ERROR: constVector does not contain enough data for the requested design" << endl;
        cout << "The design parameters requested require " << stop << " numbers, but the provided data only have " << constVector.size() << " constants" << endl;
        assert(false);
    }
    // --------------------------------------------------------------------------


    // generate the three layer modules
    string subModName1 = "layer1_" + to_string(N) + "_" + to_string(M1) + "_" + to_string(T) + "_" + to_string(P1);
    genLayer(N, M1, T, P1, constVector1, subModName1, os);
    int L1 = N-M1+1;

    string subModName2 = "layer2_" + to_string(L1) + "_" + to_string(M2) + "_" + to_string(T) + "_" + to_string(P2);
    genLayer(L1, M2, T, P2, constVector2, subModName2, os);

    int L2 = L1-M2+1;
    string subModName3 = "layer3_" + to_string(L2) + "_" + to_string(M2) + "_" + to_string(T) + "_" + to_string(P3);
    genLayer(L2, M3, T, P3, constVector3, subModName3, os);

    // You will need to add code in the module at the top of this function to stitch together insantiations of these three modules

}



void printUsage() {
    cout << "Usage: ./gen MODE ARGS" << endl << endl;

    cout << "   Mode 1: Produce one convolution module (Part 1)" << endl;
    cout << "      ./gen 1 N M T const_file" << endl;

    cout << "   Mode 2: Produce one convolution module with parallelism (Part 2)" << endl;
    cout << "      ./gen 2 N M T P const_file" << endl;

    cout << "   Mode 3: Produce a system with three interconnected convolution modules (Part 3)" << endl;
    cout << "      Arguments: N, M1, M2, M3, T, B, const_file" << endl;
    cout << "      See project description for explanation of parameters." << endl;
    cout << "              e.g.: ./gen 3 16 4 5 6 15 16 const.txt" << endl << endl;

    cout << "      See project description for explanation of parameters." << endl << endl;

}
