# Harware_Generation_Tool
• Built a tool that flexibly generates hardware to accelerate the evaluation of multiple layers of
convolution system with a non-linear function called a ReLU after each convolution
• Designed it using digital system design techniques such as control module, data path and FSM
• Enhanced the speed by adding parallelism and pipelining 
• Programmed the tool by C++ for software development and System Verilog to generate the hardware
• Tested the tool by using random testbenches for its speed, area, throughput and energy consumption

Tool is built on 3 Stages
1)Basic MAC(Multiply And Accumulate) Unit
2)Convultion Unit
3)Combining all and produce the hardware using Generator Code(C++)
