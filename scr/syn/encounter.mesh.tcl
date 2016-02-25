##############################################################################
## Name    : encounter.mesh.tcl                                             ##
## Synopsis: Compile Script for Cadence Encounter with clock mesh synthesis ## 
## Author  : Ameer Abdel-hadi                                               ##
## Email   : ameer.abdelhadi@gmail.com                                      ##
##                                                                          ##
## Command line:                                                            ##
## encounter -config encounter.tcl                                          ##
##############################################################################

global env
set my_toplvl	$env(TOPLVL)
set my_syndir	$env(SYNDIR)
set my_synscr	$env(SYNSCR)
set my_outdir	"/out/"

# Setup design and create floorplan
loadConfig [format "%s%s" $my_synscr "/encounter.conf"]
#commitConfig

# Create Initial Floorplan
floorplan -r 1.0 0.6 20 20 20 20

# Create Power structures
addRing -spacing_bottom 5 -width_left 5 -width_bottom 5 -width_top 5 -spacing_top 5 -layer_bottom metal5 -width_right 5 -around core -center 1 -layer_top metal5 -spacing_right 5 -spacing_left 5 -layer_right metal6 -layer_left metal6 -nets { gnd vdd }

# Place standard cells
amoebaPlace

# Route power nets
sroute -noBlockPins -noPadRings

# Perform trial route and get initial timing results
trialroute
buildTimingGraph
setCteReport
reportTA -nworst  10 -net > [format "%s%s%s%s"  $my_syndir $my_outdir $my_toplvl ".timing.1.trailroute.rep"]


# Run in-place optimization
# to fix setup problems
setIPOMode -mediumEffort -fixDRC -addPortAsNeeded
initECO [format "%s%s%s%s"  $my_syndir $my_outdir $my_toplvl ".ipo1.txt"]
fixSetupViolation
endECO
buildTimingGraph
setCteReport
reportTA -nworst  10 -net > [format "%s%s%s%s"  $my_syndir $my_outdir $my_toplvl ".timing.2.IPO1.rep"]

### Run Clock Tree Synthesis
##
##set cts_spec_file		[format "%s%s%s%s"  $my_syndir $my_outdir $my_toplvl ".cts.spec"]
##set cts_rguide_file		[format "%s%s%s%s"  $my_syndir $my_outdir $my_toplvl ".cts.rguide"]
##set cts_rep_file		[format "%s%s%s%s"  $my_syndir $my_outdir $my_toplvl ".cts.rep"]
##set cts_macro_file		[format "%s%s%s%s"  $my_syndir $my_outdir $my_toplvl ".cts.macro"]
##set cts_skew_rep_file		[format "%s%s%s%s"  $my_syndir $my_outdir $my_toplvl ".cts.skew_post_troute_local.rep"]
##set cts_ptroute_rep_file	[format "%s%s%s%s"  $my_syndir $my_outdir $my_toplvl ".cts.post_troute.rep"]
##
##createClockTreeSpec -output $cts_spec_file -bufFootprint buf -invFootprint inv
##specifyClockTree -clkfile $cts_spec_file
##ckSynthesis -rguide $cts_rguide_file -report $cts_rep_file -macromodel $cts_macro_file -fix_added_buffers
##
### Output Results of CTS
##trialRoute -highEffort -guide $cts_rguide_file
##extractRC
##reportClockTree -postRoute -localSkew -report $cts_skew_rep_file
##reportClockTree -postRoute -report $cts_ptroute_rep_file
##
### Run Post-CTS Timing analysis
##setAnalysisMode -setup -async -skew -autoDetectClockTree
##buildTimingGraph
##setCteReport
##reportTA -nworst  10 -net > [format "%s%s%s%s"  $my_syndir $my_outdir $my_toplvl ".timing.3.CTS.rep"]
##
### Perform post-CTS IPO
##setIPOMode -highEffort -fixDrc -addPortAsNeeded -incrTrialRoute  -restruct -topomap
##initECO [format "%s%s%s%s"  $my_syndir $my_outdir $my_toplvl ".ipo2.txt"]
##setExtractRCMode -default -assumeMetFill
##extractRC
##fixSetupViolation -guide $cts_rguide_file
##
### Fix all remaining violations
##setExtractRCMode -detail -assumeMetFill
##extractRC
##if {[isDRVClean -maxTran -maxCap -maxFanout] != 1} {
##fixDRCViolation -maxTran -maxCap -maxFanout
##}
##
##endECO
##cleanupECO

# Run Post IPO-2 timing analysis
buildTimingGraph
setCteReport
reportTA -nworst  10 -net > [format "%s%s%s%s"  $my_syndir $my_outdir $my_toplvl ".timing.4.IPO2.rep"]

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
reportTA -nworst  10 -net > [format "%s%s%s%s"  $my_syndir $my_outdir $my_toplvl ".timing.5.final.rep"]

### Output GDSII
##set gds2_final_file	[format "%s%s%s%s"  $my_syndir $my_outdir $my_toplvl ".gds2.final"]
##set gds2_map_file [format "%s%s"  $my_synscr "/gds2_encounter.map"]
##
##
##streamOut $gds2_final_file -mapFile $gds2_map_file -stripes 1 -units 1000 -mode ALL
##saveNetlist -excludeLeafCell [format "%s%s%s%s"  $my_syndir $my_outdir $my_toplvl ".final.v"]

# Output DSPF RC Data
rcout -spf [format "%s%s%s%s"  $my_syndir $my_outdir $my_toplvl ".final.dspf"]

### Run DRC and Connection checks
##verifyGeometry               -report [format "%s%s%s%s"  $my_syndir $my_outdir $my_toplvl ".geom.rep"]
##verifyConnectivity -type all -report [format "%s%s%s%s"  $my_syndir $my_outdir $my_toplvl ".conn.rep"]
##
##win

source [format "%s%s"  $my_synscr "/sta2xml.tcl"]

puts "sourcing reg2xml..."
reg2xml [all_registers] [format "%s%s%s%s"  $my_syndir $my_outdir $my_toplvl ".xml"] [format "%s%s%s%s" $my_syndir $my_outdir $my_toplvl ".bgx.vh"]

####exit
