script_mindsgn.py has been changed so that it will also copy the following files automatically:
-systest.c
-vcd.do
-vcd2.do

It also executes "make soft" before "make vsim" so that the changed systest.c is compiled before using it in QuestaSim.

In QuestaSim / Modelsim do the following:
do vcd2.do
run -all
vcd flush (after end of simulation, or just close QuestaSim)

It will create the file vcdtest9.vcd (around 37 MB) 

vcd.do will create the file vcdtest7.vcd (around 3,3 GB)

vcd.do, vcd2.do and systest.c are just for testing purposes at the moment.

Overall:
1) in socrocket-core do
	/core/tools/execute leon3mp sdram hello -s /vhdl/start_mindsgn.py
2) cd vhdl/VHDL/designs/leon3-minimal/
3) vsim testbench
4) in ModelSim / QuestaSim
	do vcd2.do
	run -all
	(vcd flush)


Update Dec 10th 2015:
Found out which is the module that crashes Questasim when trying to add all signal recursively (gpt/timer0)
Added vcd_zedboard.do for ZedBoard design, changed script so that it copies the vcd_zedboard.do file.
