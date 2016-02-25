########################################################################
## Name     : sta2xml.tcl                                             ##
## Synopsis : Generates a timing constrains graph from netlist;       ##
##            Integrates with Cadence PrimeTime flow                  ##
## Author   : Ameer Abdelhadi                                         ##
## Email    : ameer.abdelhadi@gmail.com                               ##
##                                                                    ##
## Main function:                                                     ##
##   reg2xml                                                          ##
## Arguments:                                                         ##
##   - regs     : participant registers                               ##
##   - xmlfn    : output xml file name                                ##
##   - netlistfn: netlistfn                                           ##
## Example:                                                           ##
##   reg2xml [all_registers] \                                        ##
##           [file join $my_syndir $my_outdir "$my_toplvl.enc.xml"] \ ##
##           [file join $my_syndir $my_outdir "$my_toplvl.bgx.vh" ]   ##
##                                                                    ##
########################################################################

proc reg2xml {regs xmlfn netlistfn} {

	puts "\nCompute constarins graph from netlist ${netlistfn}...\n"
	puts "Write XML file ${xmlfn}...\n"
	
	set xmlf [open $xmlfn w] 

	buildTimingGraph
	setCteReport

	set corexmax 0
	set coreymax 0
	set corexmin 999999999
	set coreymin 999999999
	
	## define connectivity array: connectivity(reg)
	puts stdout "\nCompute connectivity...\n"
	eval [exec /hp/ameer/cgs//scr/syn/net2grp.pl -net $netlistfn -rc] 
		
	## get chip dimension
	foreach_in_collection reg $regs {
		set regName [query_objects $reg]
		set regCell [get_cell $regName]
		set xmax  [get_property $regCell x_coordinate_max]
		set ymax  [get_property $regCell y_coordinate_max]
		set xmin  [get_property $regCell x_coordinate_min]
		set ymin  [get_property $regCell y_coordinate_min]  	   
		if {$xmax>$corexmax} {set corexmax $xmax}
		if {$ymax>$coreymax} {set coreymax $ymax}
		if {$xmin<$corexmin} {set corexmin $xmin}
		if {$ymin<$coreymin} {set coreymin $ymin}
	}
		
	set regsn [sizeof_collection $regs]
	set regindx 0

	## print grpah (chip) attributes
	puts $xmlf "<graph>"
	puts $xmlf "  <attribute name=\"regsn\" value=\"$regsn\" />"	
	puts $xmlf "  <attribute name=\"polygon\" value=\"$corexmin $coreymin $corexmax $coreymin $corexmax $coreymax $corexmin $coreymax $corexmin $coreymin\" />"
	puts $xmlf "  <attribute name=\"label\" value=\"\($corexmin,$coreymin\)\\n\($corexmax,$coreymax\)\" />"

	## iterate on all registers
	foreach_in_collection  reg1 $regs {
		incr regindx
		
		set reg1Name [query_objects   $reg1]
		set reg1Cell [get_cell    $reg1Name]
		set reg1Clk  [get_pin $reg1Name/CLK]
		
		puts stdout "\n-- current register: $reg1Name ($regindx out of $regsn)\n"
		
		## calculate node (register) attributes
		set xcoor [get_property $reg1Clk x_coordinate		 ]
		set ycoor [get_property $reg1Clk y_coordinate		 ]	 
		set cmaxr [get_property $reg1Clk pin_capacitance_max_rise]
		set cmaxf [get_property $reg1Clk pin_capacitance_max_fall]
		set cminr [get_property $reg1Clk pin_capacitance_min_rise]
		set cminf [get_property $reg1Clk pin_capacitance_min_fall]		
		set xmax  [get_property $reg1Cell x_coordinate_max]
		set xmin  [get_property $reg1Cell x_coordinate_min]
		set ymax  [get_property $reg1Cell y_coordinate_max]
		set ymin  [get_property $reg1Cell y_coordinate_min]
		
		## print node (register) attributes
		puts  $xmlf "  <node id=\"$reg1Name\">"
		puts  $xmlf "    <attribute name=\"cmaxr\" value=\"$cmaxr\" />"
		puts  $xmlf "    <attribute name=\"cmaxf\" value=\"$cmaxf\" />"
		puts  $xmlf "    <attribute name=\"cminr\" value=\"$cminr\" />"
		puts  $xmlf "    <attribute name=\"cminf\" value=\"$cminf\" />"		
		puts  $xmlf "    <attribute name=\"polygon\" value=\"$xmin $ymin $xmax $ymin $xmax $ymax $xmin $ymax $xmin $ymin\" />"
		puts  $xmlf "    <attribute name=\"label\" value=\"$reg1Name\\n\($xmin,$ymin\)\($xmax,$ymax\)\\ncmaxrf=\[$cmaxr,$cmaxf\]\" />"
		puts  $xmlf "  </node>"
		
		## iterate on all connected registers
		foreach reg2 $connectivity($reg1Name) {
		
			set reg2Name $reg2
			set reg2Cell [get_cell    $reg2Name]
			
			## calculate timing		
			set maxTimingCol [report_timing -late  -from $reg1Name/Q -to $reg2Name/D -collection]
			set minTimingCol [report_timing -early -from $reg1Name/Q -to $reg2Name/D -collection]			
			
			if {([sizeof_collection $maxTimingCol] > 0) && ([sizeof_collection $minTimingCol] > 0)} {
				
				## get slack
				set maxSlack [get_property $maxTimingCol slack]
				set minSlack [get_property $minTimingCol slack]				

				## print edge (timing arc) attributes
				puts  $xmlf "  <edge from=\"$reg1Name\" to=\"$reg2Name\">"
				puts  $xmlf "    <attribute name=\"maxsl\" value=\"$maxSlack\" />"
				puts  $xmlf "    <attribute name=\"minsl\" value=\"$minSlack\" />"
				puts  $xmlf "    <attribute name=\"label\" value=\"$maxSlack\\n$minSlack\" />"
				puts  $xmlf "  </edge>"
				
			}
		}
		
	}
	
	puts $xmlf "</graph>"
	flush $xmlf
	close $xmlf
}
