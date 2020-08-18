;# make_altera_rv.do

clear
transcript off
echo "************************************************"
echo "*** Altera support script for Riviera-Pro    ***"
echo "*** Used with Vendor Source VHDL files       ***"
echo "*** Amos Zaslavsky (C) www.amos.eguru-il.com ***"
echo "************************************************\n"
echo getting installation place of Qaurtus from environment
set quartus_dir $env(QUARTUS_ROOTDIR)
echo saving current directory
set current_dir [pwd]
echo going to the aldec root dir (2 above the tcl_library)
cd $tcl_library/../../vlib
echo making an altera directory
file mkdir altera
echo making a vhdl directory
file mkdir altera/vhdl
echo removing read only attribute from library.cfg file
set file_root_ini "$tcl_library/../../vlib/library.cfg"
file attributes $file_root_ini -readonly 0

########################################################## lpm
;# creating lpm library under the altera dir
vlib {$aldec/../altera/vhdl/lpm}
;# mapping the logical name lpm to physical directory
vmap lpm {$aldec/../altera/vhdl/lpm}
;# compiling component packages to library lpm
#vcom   -work lpm $quartus_dir/eda/sim_lib/220pack.vhd
vcom   -work lpm $quartus_dir/19.1/modelsim_ase/altera/vhdl/src/220model/220pack.vhd

;# compiling the individual lpm entities & architectures
#vcom -93   -work lpm $quartus_dir/eda/sim_lib/220model.vhd
vcom -93   -work lpm $quartus_dir/19.1/modelsim_ase/altera/vhdl/src/220model/220model.vhd

########################################################## altera_mf
;# creating altera_mf library under the altera dir
vlib {$aldec/../altera/vhdl/altera_mf}
;# mapping the logical name altera_mf to physical directory
vmap altera_mf {$aldec/../altera/vhdl/altera_mf}
;# compiling component packages to library altera_mf
#vcom   -work altera_mf $quartus_dir/eda/sim_lib/altera_mf_components.vhd
vcom   -work altera_mf $quartus_dir/19.1/modelsim_ase/altera/vhdl/src/altera_mf/altera_mf_components.vhd

;# compiling the individual altera_mf entities & architectures
#vcom -93   -work altera_mf $quartus_dir/eda/sim_lib/altera_mf.vhd
vcom -93   -work altera_mf $quartus_dir/19.1/modelsim_ase/altera/vhdl/src/altera_mf/altera_mf.vhd

########################################################## altera
;# creating altera_mf library under the altera dir
vlib {$aldec/../altera/vhdl/altera}
;# mapping the logical name altera_mf to physical directory
vmap altera {$aldec/../altera/vhdl/altera}
;# compiling component packages to library altera_mf
#vcom   -work altera $quartus_dir/eda/sim_lib/altera_primitives_components.vhd
vcom   -work altera $quartus_dir/19.1/modelsim_ase/altera/vhdl/src/altera/altera_primitives_components.vhd

;# compiling the individual altera_mf entities & architectures
#vcom   -work altera $quartus_dir/eda/sim_lib/altera_primitives.vhd
vcom   -work altera $quartus_dir/19.1/modelsim_ase/altera/vhdl/src/altera/altera_primitives.vhd

;# compiling component packages to library altera_mf
#vcom   -work altera $quartus_dir/eda/sim_lib/altera_europa_support_lib.vhd
vcom   -work altera $quartus_dir/19.1/modelsim_ase/altera/vhdl/src/altera/altera_europa_support_lib.vhd

echo making the library.cfg readonly again
file attributes $file_root_ini -readonly 1
echo return to original directory
cd $current_dir
echo "end of script !"
