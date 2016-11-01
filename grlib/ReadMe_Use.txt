current_a: Without active regfile for saed90nm
current_b: With active regfile for saed90nm
For both 32 and 90nm libraries, instructions on what to uncomment for different regfile settings
have been added to the regfile_3p.vhd in techmap/maps.



1) Copy everything from one of the GRLIB folders to your grlib folder, overwriting existing files.
2) Go to leon3-asic or leon3-minimal, created from the GRLIB templates (check GRLIB path in script of template for your GRLIB)
3) Double check paths within the Makefile
4) make comp_saed90_sim
5) make vsim
6) make soft (Just needed once, if at all)
7) make vsim-launch




Old:
Make sure to use the GRLIB 1.3.7, copy the original from /lscratch/hlange/grlib-gpl-1.3.7-b4144.
Make a fresh copy of the grlib or use a copy of the grlib that hasn't been modified in any other files, other than the new ones.

1) Copy everything from /grlib_clk_pad_active/ to your grlib folder, overwriting existing files.

The following steps should now be consistent (I hope):

2) Go to leon3-asic or leon3-minimal.
3) Double check paths within the Makefile
4) make comp_saed90_sim
5) make scripts
6) Edit make.vsim
	a) For the asic design, move the following under ..../allmem.vhd:
	b) For the minimal design, paste the following under ..../allmem.vhd:
	
	vcom -quiet  -93  -work techmap ../../lib/techmap/saed90nm/clkgen_saed90.vhd
	vcom -quiet  -93  -work techmap ../../lib/techmap/saed90nm/pads_saed90.vhd
	vcom -quiet  -93  -work techmap ../../lib/techmap/saed90nm/saed90nm_ram.vhd
	vcom -quiet  -93  -work techmap ../../lib/techmap/saed90nm/saed90nm_syncram.vhd
	vcom -quiet  -93  -work techmap ../../lib/techmap/saed90nm/saed90nm_syncram_dp.vhd
	vcom -quiet  -93  -work techmap ../../lib/techmap/saed90nm/saed90nm_regfile_3p.vhd


	If there is an error concerning the .....version.vhd, make distclean and try it with make vsim > then editing make.vsim > make vsim again

7) make soft (Just needed once)
8) make vsim-launch



DC_Scripts are included as well. They should be working, but paths may need to be changed.







	