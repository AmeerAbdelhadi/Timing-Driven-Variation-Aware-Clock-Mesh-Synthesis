##########################################################
## Name    : compile_dc.tcl                             ##
## Synopsis: Compile Script for Synopsys DesignCompiler ## 
## Author  : Ameer Abdel-hadi                           ##
## Email   : ameer.abdelhadi@gmail.com                  ##
##                                                      ##
## Command line:                                        ##
## dc_shell-t -f compile_dc.tcl                         ##
##########################################################

global env

# Set global variables

# Top-level Module
set my_toplvl	$env(TOPLVL)

set my_syndir	$env(SYNDIR)

set my_virlib	$env(VIRLIB)

# Target frequency in MHz for optimization
set my_frqmhz	$env(FRQMHZ)

set my_outdir	"out"
set my_rtldir	"rtl"


# All verilog files, separated by spaces: [list FILE1.v FILE2.v]
set my_verilog_files   [file join  $my_syndir $my_rtldir "$my_toplvl.v"]

# The name of the clock pin. If no clock-pin exists, pick anything
set my_clock_pin blif_clk_net

# Delay of input signals (Clock-to-Q, Package etc.)
set my_input_delay_ns 0.01

# Reserved time for output signals (Holdtime etc.) 
set my_output_delay_ns 0.01


###########################
#set VIRSYN "$my_virlib/logic_synth"
set VIRSYN [format "%s%s"  [getenv "VIRLIB"] "/logic_synth"]

set search_path [concat  $search_path $VIRSYN]
#set alib_library_analysis_path $VIRSYN
set SYNOPSYS "/tools/synopsys89/syn"
set TECH        cp65npksdst
set company    "Virage Logic"
set designer   "Ameer Abdel-hadi"
set plot_command "lpr -Pbp" 

set target_library "cp65npksdst_tt1p2v25c.db"
set symbol_library "$my_virlib/symbol/cp65npksdst.sdb"
set synthetic_library "dw01.sldb dw02.sldb dw03.sldb dw04.sldb dw05.sldb dw06.sldb dw_foundation.sldb"

# Specifies the list of design files and libraries used during linking.
set link_library [concat * $target_library $synthetic_library]

# Maps a design library to a UNIX directory.
define_design_lib WORK -path ./WORK

# Instructs the Verilog writer in dc_shell to write out all of the unconnected instance pins.
set verilogout_show_unconnected_pins "true"

# Declares three-state nets as Verilog "wire" instead of "tri".
set verilogout_no_tri  true

# Controls the way in which the write -format command write out internal bused nets by parsing
# the names of the nets. When writing out Verilog files, set verilogout_single_bit to false.
set hdlout_internal_busses   true

# Specifies the pattern used to infer individual bits into a port bus.
set bus_inference_style  {%s[%d]}

# Don't output vectored ports in the Verilog output. All vectors are written as single bits.
set verilogout_single_bit  true

# Naming style of an individual port member, net member, or cell instance member.
set bus_naming_style "%s_%d"

#Sets  the DC Ultra optimization mode and checks out the DC Ultra license
#set_ultra_optimization true
# Forces the command to acquire the DC Ultra license.
#set_ultra_optimization -force

# Analyzes HDL files and stores the intermediate format for the HDL description.
analyze -f verilog $my_verilog_files

# Builds a design from the intermediate format of a Verilog module.
elaborate $my_toplvl

# Sets the working design in dc_shell.
current_design $my_toplvl

#Resolves design references.
link

# Removes multi-instantiated hierarchy by creating a unique design for each instance.
uniquify

set my_period [expr 1000 / $my_frqmhz]

set find_clock [ find port [list $my_clock_pin] ]
if {  $find_clock != [list] } {
   set clk_name $my_clock_pin
   create_clock -period $my_period $clk_name
} else {
   set clk_name vclk
   create_clock -period $my_period -name $clk_name
}

#set_driving_cell  -lib_cell INVX1  [all_inputs]
set_input_delay $my_input_delay_ns -clock $clk_name [remove_from_collection [all_inputs] $my_clock_pin]
set_output_delay $my_output_delay_ns -clock $clk_name [all_outputs]

# Performs logic-level and gate-level synthesis and optimization.
# Collapses all levels of hierarchy in a design, except dont_touch attribute set.
compile -ungroup_all -map_effort medium
# Specifies to attempt only incremental improvements to the gate structure.
compile -incremental_mapping -map_effort medium

compile_ultra

compile_ultra -incremental


# Checks the current design for consistency.
check_design
# Displays a summary of all of the optimization and design rule constraints with violations.
report_constraint -all_violators

# Write verilog file
write -f verilog -output [file join $my_syndir $my_outdir "$my_toplvl.dc.vh"]

# Write SDC file
write_sdc [file join $my_syndir $my_outdir "$my_toplvl.dc.sdc"]

# Write DDC file
# for synopsys56 use: write -f db -hier -output [file join $my_syndir $my_outdir "$my_toplvl.dc.db"] -xg_force_db
setOptMode write -f ddc -hier -output [file join $my_syndir $my_outdir "$my_toplvl.dc.ddc"]

# Write reports
redirect [file join $my_syndir $my_outdir "$my_toplvl.dc.timing.0.rep"	] { report_timing }
redirect [file join $my_syndir $my_outdir "$my_toplvl.dc.cell.rep"	] { report_cell   }
redirect [file join $my_syndir $my_outdir "$my_toplvl.dc.power.rep"	] { report_power  }

quit
