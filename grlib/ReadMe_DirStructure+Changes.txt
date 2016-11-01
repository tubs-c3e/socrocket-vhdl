current_a and current_b are the up to date grlibs.

Their contents need to be copied over to the library in use, currently that is finallib_alpha in outside of the socrocket-core directory. 

current_b has the regfile in use for the 90nm library.
current_a has all regfiles disabled.
Comments have been added, on how to change the /lib/techmap/maps/regfile_3p.vhd for the activation of the different test implementations of the regfiles.

Other changes:
/bin/Makefile - Added saed90nm to ASICLIBS
added /lib/tech/saed90nm/
in /lib/tech/saed90nm/components/vlogsim.txt the Verilogfiles are stated, that have to be compiled via the make_saed90_sim command of the Makefile of the the dcminimal90 design.

changed /lib/techmap/saed32/memory_saed32.vhd to implement the new RAMs.

Of /lib/techmap/saed90nm/ the following .vhds are used:
clkgen_saed90.vhd < Only clkgen active
memory_saed90nm.vhd < All single port, 2p, dp and regfile entity declarations
pads_saed90.vhd < Pads are disabled through gencomp

Search for "saed90" and "gener" instantiation names in /lib/techmap/maps for added features

Gencomp settings in lib/gencomp/gencomp.vhd

All .in and in.h files are for the GUI config tool and have not been tested

Added generic DP ram from the Synopsys implementation in lib/techmap/inferred/memory_inferred.vhd 
Its component declaration is in /lib/techmap/maps/allmem.vhd





















Deprecated, will be revisited soon


grlib_clk_pad_active:
---------------------


Files from the /lscratch/trust/testgrlib

Contains pads and clkgen for saed90nm as well.


Changes and Additions:
/bin/Makefile: Added saed90nm to ASICLIBS (line 8)

/designs/leon3-asic:

-Added folder "snps_common"
	-Added folder "snps_common/constraints"
	-Added folder "snps_common/dc_scripts"
	-Added folder "snps_common/lib"
	-"constraints" contains the constraints from the original snps_common
	-"lib" contains the leon3 wire load from the original snps_common
	-"dc_scripts" contains several dc_scripts. "dc_leon3mp_core_2.tcl" is the changed core dc_script

-Added folder src_1 (I need to add the creation of this folder to the scripts)

-Added "common_setup.tcl" and "dc_setup.tcl"

-Changed config.vhd, so that it works with the saed90nm ram.
-Changed Makefile, currently compiling the 5 RAM files, PLL.v, saed90nm_lvt.v, saed90nm.v, saed90nm_io.v
-Changed systest.c: commented out "greth_test(0x80000d00);", as this just takes unnecessary time.

/designs/leon3-minimal:

-Changed leon3mp.vhd:
	-Changed generic map of leon3s to actually use the config.vhd (line 202 onwards)
	-Changed clkgen a little to use clktech (line 183)
	-Made led(3) signal to use the debug error signal, so that the simulation can halt after finishing the tests (line 309)

-Rest as the leon3-asic design

/lib/tech/saed90nm added:
-dirs.txt: Dirs that should be searched by the grlib within the folder
-/components/vlogsim.txt: References to the Verilog files that need to be compiled

/lib/techmap/clocks:
-Changed "clkgen.in" and "clkgen.in.h": Added support for saed90nm clocks (ToDo: double check this)

/lib/techmap/gencomp:
-Changed "clkgen.in", "clkgen.in.h", "tech.in" and "tech.in.h" (ToDo: double check this)
-Changed gencomp.vhd:
	-Changed number of technologies to 55 (line 40)
	-Added tech saed90nm (line 98)
	-Added "saed90nm => 0," for "has_dpram" (redundant if 0, used for testing - line 150
	-Added "saed90nm => 0," for "padoen_polarity" (redundant if 0, produced errors when 1 - line 206)
	-Added "saed90nm => 1," for "has_pads" (line 212)
	-Added "saed90nm => 0," for "has_ds_pads" (redundant if 0, didn't change anything when set to 1 - line 226) 
	-Added "saed90nm => 0," for "has_clkand"  (redundant if 0, didn't change anything when set to 1 - line 238)
	-Added "saed90nm => 0," for "has_clkmux"  (redundant if 0, Error while loading asic design when set to 1 - line 244)
	-Added "saed90nm => 1," for "has_clkinv" (line 247 - no changes when 0)
	-Added "saed90nm => 1," for "need_extra_sync_reset" (line 271 - no changes when 0)
 	-Added "saed90nm => 0," for "has_tap" (redundant - line 286)
 	-Added "saed90nm => 1," for "has_clkgen" (line 294)
 	-Added saed90nm to tech table (line 392)

/lib/techmap/maps:
-Changed allclkgen.vhd: Added components clkinv_saed90nm, clkand_saed90nm, clkmux_saed90nm, clkgen_saed90nm (line 534 onwards, don't use the MUX)
-Changed allmem.vhd: Added components generic_syncram_dp (line 538-559), saed90nm_syncram, saed90nm_syncram_dp, saed90nm_regfile_3p (line 1422-1471)
-Changed allpads.vhd: Added components saed90nm_inpad, saed90nm_iopad, saed90nm_outpad, saed90nm_toutpad (line 457 to 482) 
-Changed clkand.vhd, clkgen.vhd, clkinv.vhd, clkmux.vhd, clkpad.vhd, inpad.vhd, iopad.vhd, outpad.vhd, toutpad.vhd
 to generate saed90 units when saed90nm is used. Styled like the saed32-tech units.
-Changed regfile_3p.vhd, synram.vhd, syncram_dp.vhd to create saed90 memory units,
 this is according to the /lib/techmap/maps/ files from Leon3-saed90_rev2.4

Added /lib/techmap/maps/saed90nm folder:
-clkgen_saed90.vhd: Designed like clkgen_saed32.vhd, but for the 90nm process.
-pads_saed90.vhd: Designed like the pads_saed32.vhd, but for the 90nm process.
 Many changes (restructuring names and ports) in here to accomondate the modules within saed90nm_io.v
-saed90nm_ram.vhd, saed90nm_regfile_3p.vhd, saed90nm_syncram.vhd & saed90nm_syncram_dp.vhd from Leon3-saed90_rev2.4/designs/snps_common/rtl/ 


###################################################################################################################################################
###################################################################################################################################################
###################################################################################################################################################



grlib_old:
----------

Old design, that was in there before.


