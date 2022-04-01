Part 1:
 
 files:
   code:conv_12_5.sv
   tbenches:part1_simple_tb.sv,part1_random_tb.sv
   Synthesis Report: output_part1.txt
   
 Commands:
 vlog conv_12_5.sv
 vlog part1_simple_tb.sv
 vlog part1_random_tb.sv
 
 simple: vsim check_timing -c -do "run -all"

 Random: vsim tbench1 -c -do "run -all"

 Synthesis: dc_shell -f runsynth.tcl | tee output_part1.txt
