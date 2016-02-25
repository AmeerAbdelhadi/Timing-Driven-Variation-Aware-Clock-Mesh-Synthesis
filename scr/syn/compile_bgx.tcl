#####################################################################################
## Name    : compile_bgx.tcl                                                       ##
## Synopsis: Compile Script for Cadence BuildGates                                 ## 
## Author  : Ameer Abdel-hadi                                                      ##
## Email   : ameer.abdelhadi@gmail.com                                             ##
##                                                                                 ##
## Command line:                                                                   ##
## (bgx_shell -f compile_bgx.tcl > out/${TOPLVL}.bgx.log) >& out/${TOPLVL}.bgx.err ##
#####################################################################################


global env

# Set global variables
set my_toplvl	$env(TOPLVL)
set my_syndir	$env(SYNDIR)
set my_osulib	$env(OSULIB)
set my_frqmhz	$env(FRQMHZ)
set my_outdir	"out"
set my_rtldir	"rtl"

# All verilog files, separated by spaces s.t.: {./s27.v ./aaa.v ./bbb.v}
set my_verilog_files   [file join  $my_syndir $my_rtldir "$my_toplvl.v"]

# The name of the clock pin. If no clock-pin, exists, pick anything
set my_clock_pin          blif_clk_net

# Target frequency in MHz for optimization
# set my_frqmhz     1000

# Delay of input signals (Clock-to-Q, Package etc.)
set my_input_delay_ns     -9999

# Reserved time for output signals (Holdtime etc.)
set my_output_delay_ns    -9999

############################################
## No changes necessary beyond this point ##
############################################

## Read technology library tlf file
read_tlf $my_osulib/files/gscl45nm.tlf

## Read/compile verilog files
read_verilog $my_verilog_files

## Set parameters
set_global target_technology gscl45nm
set_global fix_multiport_nets true
set_global hdl_verilog_out_unconnected_style full
set_global hdl_write_multi_line_port_maps false

## Build design
do_build_generic -module $my_toplvl

# Set current model/timing model
set_current_module $my_toplvl
set_top_timing_module $my_toplvl

## Set clock period
set period [expr 1000.0/$my_frqmhz]
set_clock vclk -period $period
if {[get_names [find -inputs $my_clock_pin]] == $my_clock_pin} {
    set_clock_root -clock vclk $my_clock_pin
}

set_false_path -from [get_ports {blif_reset_net}]

## Set ports delay
set_input_delay -clock vclk $my_input_delay_ns [get_names [find -inputs -no_clocks *]]
set_external_delay -clock vclk $my_output_delay_ns [get_names [find -outputs *]]

## Set driving cell type
set_drive_cell -cell INVX8 [get_names [find -inputs *]]

# Disable this command to skip flattening
do_dissolve_hierarchy -hierarchical

#setDontUse BUFX2 true
#setDontUse BUFX4 true

# Optimize design
do_optimize -priority time -force -effort high -dont_downsize -dont_buffer -target_slack -0.022 
##do_optimize -flatten on -priority time -force -effort high -dont_downsize -dont_buffer -target_slack 0 
##do_optimize -flatten on -priority time -force -effort high -dont_downsize -dont_buffer -target_slack 0 
##do_optimize -flatten on -priority time -force -effort high -dont_downsize -dont_buffer -target_slack 0 
##do_optimize -flatten on -priority time -force -effort high -dont_downsize -dont_buffer -target_slack 0 

# Write verilog file
write_verilog -hier [file join $my_syndir $my_outdir "$my_toplvl.bgx.vh"]

# Write SDC file
write_sdc [file join $my_syndir $my_outdir "$my_toplvl.bgx.sdc"]

# Write reports
report_timing > [file join $my_syndir $my_outdir "$my_toplvl.bgx.timing.0.rep"]
report_area   > [file join $my_syndir $my_outdir "$my_toplvl.bgx.cell.rep"]
report_power  > [file join $my_syndir $my_outdir "$my_toplvl.bgx.power.rep"]

exit
