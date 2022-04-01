Part 2:
 
 files:
   code:conv_112_49.sv
   tbenches:part2_simple_tb.sv,part2_random_tb.sv
   Synthesis Report: output_part2.txt
   
 Commands:
 vlog conv_112_49.sv
 vlog part2_simple_tb.sv
 vlog part2_random_tb.sv
 
 simple: vsim check_timing -c -do "run -all"

 Random: vsim tbench2 -c -do "run -all"

 Synthesis: dc_shell -f runsynth.tcl | tee output_part2.txt
