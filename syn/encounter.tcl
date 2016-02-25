####################################################
## Name    : encounter.tcl                        ##
## Synopsis: Compile Script for Cadence Encounter ## 
## Author  : Ameer Abdel-hadi                     ##
## Email   : ameer.abdelhadi@gmail.com            ##
##                                                ##
## Command line:                                  ##
## encounter -config encounter.tcl                ##
####################################################

global env
set my_toplvl	$env(TOPLVL)
set my_syndir	$env(SYNDIR)
set my_synscr	$env(SYNSCR)
set my_outdir	"out"

# Setup design and create floorplan
set any [file join $my_synscr "encounter.conf"]
puts $any
loadConfig [file join $my_synscr "encounter.conf"]
#commitConfig

# Create Initial Floorplan
floorplan -r 1.0 0.8 20 20 20 20

# Create Power structures
addRing -spacing_bottom 5 -width_left 5 -width_bottom 5 -width_top 5 -spacing_top 5 -layer_bottom metal5 -width_right 5 -around core -center 1 -layer_top metal5 -spacing_right 5 -spacing_left 5 -layer_right metal6 -layer_left metal6 -nets { gnd vdd }

deleteBufferTree
setDontUse BUFX2 true
setDontUse BUFX4 true

# Place standard cells
amoebaPlace

fixSetupViolation
optDesign -preCTS -setup -incr
fixSetupViolation


fixSetupViolation
optDesign -postCTS -setup -incr
fixSetupViolation

# Route power nets
sroute -noBlockPins -noPadRings

# Perform trial route and get initial timing results
trialroute
buildTimingGraph
setCteReport
reportTA -nworst  10 -net > [file join $my_syndir $my_outdir "$my_toplvl.enc.timing.1.trailroute.rep"]

fixSetupViolation
optDesign -postRoute -setup -incr
fixSetupViolation


fixSetupViolation
optDesign -postRoute -setup -incr
fixSetupViolation

# Run in-place optimization
# to fix setup problems
setIPOMode -mediumEffort -fixDRC -addPortAsNeeded
initECO [file join $my_syndir $my_outdir "$my_toplvl.enc.ipo1.txt"]
fixSetupViolation
endECO
buildTimingGraph
setCteReport
reportTA -nworst  10 -net > [file join $my_syndir $my_outdir "$my_toplvl.enc.timing.ipo1.rep"]

# Run Clock Tree Synthesis

set cts_spec_file		[file join $my_syndir $my_outdir "$my_toplvl.enc.cts.spec"]
set cts_rguide_file		[file join $my_syndir $my_outdir "$my_toplvl.enc.cts.rguide"]
set cts_rep_file		[file join $my_syndir $my_outdir "$my_toplvl.enc.cts.rep"]
set cts_macro_file		[file join $my_syndir $my_outdir "$my_toplvl.enc.cts.macro"]
set cts_skew_rep_file		[file join $my_syndir $my_outdir "$my_toplvl.enc.cts.skew_post_troute_local.rep"]
set cts_ptroute_rep_file	[file join $my_syndir $my_outdir "$my_toplvl.enc.cts.post_troute.rep"]

createClockTreeSpec -output $cts_spec_file -bufFootprint buf -invFootprint inv
specifyClockTree -clkfile $cts_spec_file
ckSynthesis -rguide $cts_rguide_file -report $cts_rep_file -macromodel $cts_macro_file -fix_added_buffers

# Output Results of CTS
trialRoute -highEffort -guide $cts_rguide_file
extractRC
reportClockTree -postRoute -localSkew -report $cts_skew_rep_file
reportClockTree -postRoute -report $cts_ptroute_rep_file

fixSetupViolation
optDesign -postCTS -setup -incr
fixSetupViolation


# Run Post-CTS Timing analysis
setAnalysisMode -setup -async -skew -autoDetectClockTree
buildTimingGraph
setCteReport
reportTA -nworst  10 -net > [file join $my_syndir $my_outdir "$my_toplvl.enc.timing.3.cts.rep"]

# Perform post-CTS IPO
setIPOMode -highEffort -fixDrc -addPortAsNeeded -incrTrialRoute  -restruct -topomap
initECO [file join $my_syndir $my_outdir "$my_toplvl.enc.ipo2.txt"]
setExtractRCMode -default -assumeMetFill
extractRC
fixSetupViolation -guide $cts_rguide_file

# Fix all remaining violations
setExtractRCMode -detail -assumeMetFill
extractRC
if {[isDRVClean -maxTran -maxCap -maxFanout] != 1} {
fixDRCViolation -maxTran -maxCap -maxFanout
}

endECO
cleanupECO

# Run Post IPO-2 timing analysis
buildTimingGraph
setCteReport
reportTA -nworst  10 -net > [file join $my_syndir $my_outdir "$my_toplvl.enc.timing.4.ipo2.rep"]

### Add filler cells
##addFiller -cell FILL -prefix FILL -fillBoundary

# Connect all new cells to VDD/GND
globalNetConnect vdd -type tiehi
globalNetConnect vdd -type pgpin -pin vdd -override

globalNetConnect gnd -type tielo
globalNetConnect gnd -type pgpin -pin gnd -override

# Run global Routing
globalDetailRoute

# Get final timing results
setExtractRCMode -detail -noReduce
extractRC
buildTimingGraph
setCteReport
reportTA -nworst  10 -net > [file join $my_syndir $my_outdir "$my_toplvl.enc.timing.5.final.rep"]

### Output GDSII
##set gds2_final_file	[file join $my_syndir $my_outdir "$my_toplvl.enc.gds2.final"]
##set gds2_map_file [file join  $my_synscr "gds2_encounter.map"]
##
##
##streamOut $gds2_final_file -mapFile $gds2_map_file -stripes 1 -units 1000 -mode ALL
##saveNetlist -excludeLeafCell [file join $my_syndir $my_outdir "$my_toplvl.enc.final.v"]

# Output DSPF RC Data
#rcout -spf [file join $my_syndir $my_outdir "$my_toplvl.enc.final.dspf"]

### Run DRC and Connection checks
##verifyGeometry               -report [file join $my_syndir $my_outdir "$my_toplvl.enc.geo.rep"]
##verifyConnectivity -type all -report [file join $my_syndir $my_outdir "$my_toplvl.enc.con.rep"]
##
##win

###### source [file join $my_synscr "sta2xml.tcl"]

###### puts "sourcing reg2xml..."
###### reg2xml [all_registers] [file join $my_syndir $my_outdir "$my_toplvl.enc.xml"] [file join $my_syndir $my_outdir "$my_toplvl.bgx.vh"]

#exit
