#######################################################
#                                                     #
#  Encounter Command Logging File                     #
#  Created on Sat Sep  5 23:18:11                     #
#                                                     #
#######################################################
loadConfig /hp/ameer/cgs/scr/syn/encounter.mesh.tcl
setClockMeshMode -noUsage
setCTSMode -noSetDPinAsSync -noSetIoPinAsSync -noRouteClkNet -useCTSRouteGuide -topPreferredLayer 4 -bottomPreferredLayer 3 -noUseLefACLimit -preferredExtraSpace 1 -postOpt -noOptAddBuffer -moveGate -useHVRC -fixedLeafInst -fixedNonLeafInst -noVerbose -noHTMLReport -noAddClockRootProp -noUseSingleDelim -noFence -noUseLibMaxFanout -noUseLibMaxCap
getClockMeshMode -quiet
setClockMeshMode -noUsage -preRouteAnalysis UltraSim -postRouteAnalysis UltraSim
setFillerMode -reset -corePrefix FILLER -createRows 1 -doDRC 1 -fillBoundary 1 -deleteFixed 1 -ecoMode 0
setNanoRouteMode -quiet droutePostRouteWidenWireRule NA
setPlaceMode -reset
setPlaceMode -congMediumEffort -timingDriven -modulePlan -noCongOpt -noClkGateAware -noPowerDriven -ignoreScan -reorderScan -ignoreSpare -assignIOPins -noiofixed -checkPinLayerForAccess {  {1}  } -noPreserveRouting -keepAffectedRouting -noCheckRoute
setScanReorderMode -reset
setScanReorderMode -noSkip
setStreamOutMode -specifyViaName %t_VIA%u -SEvianames OFF -virtualConnection ON
setTieHiLoMode -reset
setTrialRouteMode -noHighEffort -noFloorPlanMode -detour -noHandlePreroute -noAutoSkipTracks -noHandlePartition -noHandlePartitionComplex -noUseM1 -noKeepExistingRoute -noIgnoreAbutted2TermNet -pinGuide -noHonorPin -noSelNet -noSelNetOnly -noSelMarkedNet -noSelMarkedNetOnly -noIgnoreObstruct -noPKS -noUpdateRemainTrks -useDEFTrack -noPrintWiresOnRTBlk -noUsePagedArray -obstruct4 -noGuide -noBlockageCostMultiple -noMaxDetourRatio -noPtnBdryExt -noPtnBdryShr
setClockMeshSpecVar -mesh mymesh allowGating 0
setClockMeshSpecVar -mesh mymesh -chain bottomPreferLayer {}
setClockMeshSpecVar -mesh mymesh -chain driveCell {}
setClockMeshSpecVar -mesh mymesh -chain enabled 0
setClockMeshSpecVar -mesh mymesh -chain ndr {}
setClockMeshSpecVar -mesh mymesh -chain numLevel 0
setClockMeshSpecVar -mesh mymesh -chain preferredExtraSpace 0
setClockMeshSpecVar -mesh mymesh -chain targetLocs {}
setClockMeshSpecVar -mesh mymesh -chain topPreferLayer {}
setClockMeshSpecVar -mesh mymesh defaultTrigger rising
setClockMeshSpecVar -mesh mymesh drivePoint Center
setClockMeshSpecVar -mesh mymesh drivePointLocX {}
setClockMeshSpecVar -mesh mymesh drivePointLocY {}
setClockMeshSpecVar -mesh mymesh hTreePattern {}
setClockMeshSpecVar -mesh mymesh -localTree bottomPreferLayer {}
setClockMeshSpecVar -mesh mymesh -localTree driveCells {}
setClockMeshSpecVar -mesh mymesh -localTree enabled 0
setClockMeshSpecVar -mesh mymesh -localTree ndr {}
setClockMeshSpecVar -mesh mymesh -localTree numCluster 0
setClockMeshSpecVar -mesh mymesh -localTree preferredExtraSpace 0
setClockMeshSpecVar -mesh mymesh -localTree rootPos ClusterCenter
setClockMeshSpecVar -mesh mymesh -localTree topPreferLayer {}
setClockMeshSpecVar -mesh mymesh maxBufferTrans 0
setClockMeshSpecVar -mesh mymesh maxDelay {}
setClockMeshSpecVar -mesh mymesh maxLeafTrans 0
setClockMeshSpecVar -mesh mymesh maxPower 0
setClockMeshSpecVar -mesh mymesh maxSkew 0
setClockMeshSpecVar -mesh mymesh meshModule {}
setClockMeshSpecVar -mesh mymesh meshType {}
setClockMeshSpecVar -mesh mymesh minDelay 0
setClockMeshSpecVar -mesh mymesh numStage 0
setClockMeshSpecVar -mesh mymesh period 0
setClockMeshSpecVar -mesh mymesh rootPin {}
setClockMeshSpecVar -mesh mymesh rootTrans 0
setClockMeshSpecVar -mesh mymesh routePattern Trunk
setClockMeshSpecVar -mesh mymesh supplyVoltage 1
setClockMeshSpecVar -mesh mymesh trunkDriveDist StrictAttach
setClockMeshSpecVar -mesh mymesh trunkOrient {}
setClockMeshSpecVar -mesh mymesh trunkPlacement UniformPitch
setClockMeshSpecVar -mesh mymesh useMeshModule 0
setClockMeshSpecVar meshNames mymesh
specifyClockMesh -tcl
specifyClockMesh -file clk_work_02.spec
specifyClockMesh -tcl
synthesizeClockMesh -topChain -globalMesh -localTree -unfix
zoomBox 21.267 56.898 54.490 27.773
selectWire 22.5500 37.5975 52.8100 38.5975 5 clk_mesh_drive_L01_N0
deselectAll
zoomBox 21.853 57.191 62.539 22.066
zoomBox 30.195 53.825 70.736 23.822
selectWire 36.9900 23.5275 37.9900 53.3025 4 clk_mesh_drive_L01_N0
deselectAll
selectWire 35.0900 23.5275 36.0900 53.3025 4 clk_mesh_drive_L01_N0
deselectAll
selectWire 22.5500 37.5975 52.8100 38.5975 5 clk_mesh_drive_L01_N0
deselectAll
selectWire 49.5300 23.5275 50.5300 53.3025 4 clk_mesh_drive_L01_N0
deselectAll
analyzeClockMesh -force
createSaveDir s838_1_mesh
analyzeClockMesh -force
zoomBox 25.073 56.020 48.636 28.652
selectWire 22.5500 37.5975 52.8100 38.5975 5 clk_mesh_drive_L01_N0
setExtractRCMode -detail -specialNet
extractrc
routeClockMesh -cpu 1
analyzeClockMesh -force
setExtractRCMode -detail -specialNet
extractrc
analyzeClockMesh -force
createSaveDir s838_1_mesh
analyzeClockMesh -force
analyzeClockMesh -force
analyzeClockMesh -force
analyzeClockMesh -force
help snet
help sroute
help snet
help snet
help sroute
setExtractRCMode -detail -specialNet
setExtractRCMode -detail
setExtractRCMode -detail -specialNet
extractrc
setExtractRCMode -detail
extractrc
setExtractRCMode -detail -specialNet
analyzeClockMesh -force
setExtractRCMode -detail -specialNet
extractrc
analyzeClockMesh -force
trimClockMesh -trimWireEnds -layers {metal1 metal2 metal3 metal4 metal5 metal6 metal7 metal8 metal9 metal10}
analyzeClockMesh -force
setClockMeshMode -noUsage
setCTSMode -noSetDPinAsSync -noSetIoPinAsSync -noRouteClkNet -useCTSRouteGuide -topPreferredLayer 4 -bottomPreferredLayer 3 -noUseLefACLimit -preferredExtraSpace 1 -postOpt -noOptAddBuffer -moveGate -useHVRC -fixedLeafInst -fixedNonLeafInst -noVerbose -noHTMLReport -noAddClockRootProp -noUseSingleDelim -noFence -noUseLibMaxFanout -noUseLibMaxCap
setClockMeshMode -reset
setFillerMode -reset -corePrefix FILLER -createRows 1 -doDRC 1 -fillBoundary 1 -deleteFixed 1 -ecoMode 0
setPlaceMode -reset
setPlaceMode -congMediumEffort -timingDriven -modulePlan -noCongOpt -noClkGateAware -noPowerDriven -ignoreScan -reorderScan -ignoreSpare -assignIOPins -noiofixed -checkPinLayerForAccess {  {1}  } -noPreserveRouting -keepAffectedRouting -noCheckRoute
setScanReorderMode -reset
setScanReorderMode -noSkip
setStreamOutMode -specifyViaName %t_VIA%u -SEvianames OFF -virtualConnection ON
setTieHiLoMode -reset
setTrialRouteMode -noHighEffort -noFloorPlanMode -detour -noHandlePreroute -noAutoSkipTracks -noHandlePartition -noHandlePartitionComplex -noUseM1 -noKeepExistingRoute -noIgnoreAbutted2TermNet -pinGuide -noHonorPin -noSelNet -noSelNetOnly -noSelMarkedNet -noSelMarkedNetOnly -noIgnoreObstruct -noPKS -noUpdateRemainTrks -useDEFTrack -noPrintWiresOnRTBlk -noUsePagedArray -obstruct4 -noGuide -noBlockageCostMultiple -noMaxDetourRatio -noPtnBdryExt -noPtnBdryShr
setExtractRCMode -detail -specialNet
extractrc
analyzeClockMesh -force
setClockMeshMode -noUsage
setCTSMode -noSetDPinAsSync -noSetIoPinAsSync -noRouteClkNet -useCTSRouteGuide -topPreferredLayer 4 -bottomPreferredLayer 3 -noUseLefACLimit -preferredExtraSpace 1 -postOpt -noOptAddBuffer -moveGate -useHVRC -fixedLeafInst -fixedNonLeafInst -noVerbose -noHTMLReport -noAddClockRootProp -noUseSingleDelim -noFence -noUseLibMaxFanout -noUseLibMaxCap
getClockMeshMode -quiet
setClockMeshMode -noUsage -preRouteAnalysis UltraSim -postRouteAnalysis UltraSim
setFillerMode -reset -corePrefix FILLER -createRows 1 -doDRC 1 -fillBoundary 1 -deleteFixed 1 -ecoMode 0
setPlaceMode -reset
setPlaceMode -congMediumEffort -timingDriven -modulePlan -noCongOpt -noClkGateAware -noPowerDriven -ignoreScan -reorderScan -ignoreSpare -assignIOPins -noiofixed -checkPinLayerForAccess {  {1}  } -noPreserveRouting -keepAffectedRouting -noCheckRoute
setScanReorderMode -reset
setScanReorderMode -noSkip
setStreamOutMode -specifyViaName %t_VIA%u -SEvianames OFF -virtualConnection ON
setTieHiLoMode -reset
setTrialRouteMode -noHighEffort -noFloorPlanMode -detour -noHandlePreroute -noAutoSkipTracks -noHandlePartition -noHandlePartitionComplex -noUseM1 -noKeepExistingRoute -noIgnoreAbutted2TermNet -pinGuide -noHonorPin -noSelNet -noSelNetOnly -noSelMarkedNet -noSelMarkedNetOnly -noIgnoreObstruct -noPKS -noUpdateRemainTrks -useDEFTrack -noPrintWiresOnRTBlk -noUsePagedArray -obstruct4 -noGuide -noBlockageCostMultiple -noMaxDetourRatio -noPtnBdryExt -noPtnBdryShr
analyzeClockMesh -force
setClockMeshMode -noUsage
setCTSMode -noSetDPinAsSync -noSetIoPinAsSync -noRouteClkNet -useCTSRouteGuide -topPreferredLayer 4 -bottomPreferredLayer 3 -noUseLefACLimit -preferredExtraSpace 1 -postOpt -noOptAddBuffer -moveGate -useHVRC -fixedLeafInst -fixedNonLeafInst -noVerbose -noHTMLReport -noAddClockRootProp -noUseSingleDelim -noFence -noUseLibMaxFanout -noUseLibMaxCap
setClockMeshMode -reset
setFillerMode -reset -corePrefix FILLER -createRows 1 -doDRC 1 -fillBoundary 1 -deleteFixed 1 -ecoMode 0
setPlaceMode -reset
setPlaceMode -congMediumEffort -timingDriven -modulePlan -noCongOpt -noClkGateAware -noPowerDriven -ignoreScan -reorderScan -ignoreSpare -assignIOPins -noiofixed -checkPinLayerForAccess {  {1}  } -noPreserveRouting -keepAffectedRouting -noCheckRoute
setScanReorderMode -reset
setScanReorderMode -noSkip
setStreamOutMode -specifyViaName %t_VIA%u -SEvianames OFF -virtualConnection ON
setTieHiLoMode -reset
setTrialRouteMode -noHighEffort -noFloorPlanMode -detour -noHandlePreroute -noAutoSkipTracks -noHandlePartition -noHandlePartitionComplex -noUseM1 -noKeepExistingRoute -noIgnoreAbutted2TermNet -pinGuide -noHonorPin -noSelNet -noSelNetOnly -noSelMarkedNet -noSelMarkedNetOnly -noIgnoreObstruct -noPKS -noUpdateRemainTrks -useDEFTrack -noPrintWiresOnRTBlk -noUsePagedArray -obstruct4 -noGuide -noBlockageCostMultiple -noMaxDetourRatio -noPtnBdryExt -noPtnBdryShr
analyzeClockMesh -force
createSaveDir s838_1_mesh
analyzeClockMesh -force
reportClockMesh -structure -connectivity -delay -power -out s838_1_mesh/s838_1_mesh.rpt -macromodel s838_1_mesh/s838_1_mesh.mmodel -latency s838_1_mesh/s838_1_mesh.latency
createSaveDir s838_1_mesh
analyzeClockMesh -force
reportClockMesh -structure -connectivity -delay -power -out s838_1_mesh/s838_1_mesh.rpt -macromodel s838_1_mesh/s838_1_mesh.mmodel -latency s838_1_mesh/s838_1_mesh.latency
setClockMeshMode -noUsage
setCTSMode -noSetDPinAsSync -noSetIoPinAsSync -noRouteClkNet -useCTSRouteGuide -topPreferredLayer 4 -bottomPreferredLayer 3 -noUseLefACLimit -preferredExtraSpace 1 -postOpt -noOptAddBuffer -moveGate -useHVRC -fixedLeafInst -fixedNonLeafInst -noVerbose -noHTMLReport -noAddClockRootProp -noUseSingleDelim -noFence -noUseLibMaxFanout -noUseLibMaxCap
getClockMeshMode -quiet
setClockMeshMode -noUsage -preRouteAnalysis UltraSim -postRouteAnalysis UltraSim
setFillerMode -reset -corePrefix FILLER -createRows 1 -doDRC 1 -fillBoundary 1 -deleteFixed 1 -ecoMode 0
setPlaceMode -reset
setPlaceMode -congMediumEffort -timingDriven -modulePlan -noCongOpt -noClkGateAware -noPowerDriven -ignoreScan -reorderScan -ignoreSpare -assignIOPins -noiofixed -checkPinLayerForAccess {  {1}  } -noPreserveRouting -keepAffectedRouting -noCheckRoute
setScanReorderMode -reset
setScanReorderMode -noSkip
setStreamOutMode -specifyViaName %t_VIA%u -SEvianames OFF -virtualConnection ON
setTieHiLoMode -reset
setTrialRouteMode -noHighEffort -noFloorPlanMode -detour -noHandlePreroute -noAutoSkipTracks -noHandlePartition -noHandlePartitionComplex -noUseM1 -noKeepExistingRoute -noIgnoreAbutted2TermNet -pinGuide -noHonorPin -noSelNet -noSelNetOnly -noSelMarkedNet -noSelMarkedNetOnly -noIgnoreObstruct -noPKS -noUpdateRemainTrks -useDEFTrack -noPrintWiresOnRTBlk -noUsePagedArray -obstruct4 -noGuide -noBlockageCostMultiple -noMaxDetourRatio -noPtnBdryExt -noPtnBdryShr
setCTSMode -noSetDPinAsSync -noSetIoPinAsSync -noRouteClkNet -useCTSRouteGuide -topPreferredLayer 4 -bottomPreferredLayer 3 -noUseLefACLimit -preferredExtraSpace 1 -postOpt -noOptAddBuffer -moveGate -useHVRC -fixedLeafInst -fixedNonLeafInst -noVerbose -noHTMLReport -noAddClockRootProp -noUseSingleDelim -noFence -noUseLibMaxFanout -noUseLibMaxCap
getClockMeshMode -quiet
setClockMeshMode -noUsage
setFillerMode -reset -corePrefix FILLER -createRows 1 -doDRC 1 -fillBoundary 1 -deleteFixed 1 -ecoMode 0
setPlaceMode -reset
setPlaceMode -congMediumEffort -timingDriven -modulePlan -noCongOpt -noClkGateAware -noPowerDriven -ignoreScan -reorderScan -ignoreSpare -assignIOPins -noiofixed -checkPinLayerForAccess {  {1}  } -noPreserveRouting -keepAffectedRouting -noCheckRoute
setScanReorderMode -reset
setScanReorderMode -noSkip
setStreamOutMode -specifyViaName %t_VIA%u -SEvianames OFF -virtualConnection ON
setTieHiLoMode -reset
setTrialRouteMode -noHighEffort -noFloorPlanMode -detour -noHandlePreroute -noAutoSkipTracks -noHandlePartition -noHandlePartitionComplex -noUseM1 -noKeepExistingRoute -noIgnoreAbutted2TermNet -pinGuide -noHonorPin -noSelNet -noSelNetOnly -noSelMarkedNet -noSelMarkedNetOnly -noIgnoreObstruct -noPKS -noUpdateRemainTrks -useDEFTrack -noPrintWiresOnRTBlk -noUsePagedArray -obstruct4 -noGuide -noBlockageCostMultiple -noMaxDetourRatio -noPtnBdryExt -noPtnBdryShr
setCTSMode -noSetDPinAsSync -noSetIoPinAsSync -noRouteClkNet -useCTSRouteGuide -topPreferredLayer 4 -bottomPreferredLayer 3 -noUseLefACLimit -preferredExtraSpace 1 -postOpt -noOptAddBuffer -moveGate -useHVRC -fixedLeafInst -fixedNonLeafInst -noVerbose -noHTMLReport -noAddClockRootProp -noUseSingleDelim -noFence -noUseLibMaxFanout -noUseLibMaxCap
getClockMeshMode -quiet
setClockMeshMode -noUsage
setFillerMode -reset -corePrefix FILLER -createRows 1 -doDRC 1 -fillBoundary 1 -deleteFixed 1 -ecoMode 0
setPlaceMode -reset
setPlaceMode -congMediumEffort -timingDriven -modulePlan -noCongOpt -noClkGateAware -noPowerDriven -ignoreScan -reorderScan -ignoreSpare -assignIOPins -noiofixed -checkPinLayerForAccess {  {1}  } -noPreserveRouting -keepAffectedRouting -noCheckRoute
setScanReorderMode -reset
setScanReorderMode -noSkip
setStreamOutMode -specifyViaName %t_VIA%u -SEvianames OFF -virtualConnection ON
setTieHiLoMode -reset
setTrialRouteMode -noHighEffort -noFloorPlanMode -detour -noHandlePreroute -noAutoSkipTracks -noHandlePartition -noHandlePartitionComplex -noUseM1 -noKeepExistingRoute -noIgnoreAbutted2TermNet -pinGuide -noHonorPin -noSelNet -noSelNetOnly -noSelMarkedNet -noSelMarkedNetOnly -noIgnoreObstruct -noPKS -noUpdateRemainTrks -useDEFTrack -noPrintWiresOnRTBlk -noUsePagedArray -obstruct4 -noGuide -noBlockageCostMultiple -noMaxDetourRatio -noPtnBdryExt -noPtnBdryShr
analyzeClockMesh -force
analyzeClockMesh -force
analyzeClockMesh -force
analyzeClockMesh -help
help analyzeClockMesh
analyzeClockMesh -force -invalidate
analyzeClockMesh -force
setClockMeshMode -noUsage
setCTSMode -noSetDPinAsSync -noSetIoPinAsSync -noRouteClkNet -useCTSRouteGuide -topPreferredLayer 4 -bottomPreferredLayer 3 -noUseLefACLimit -preferredExtraSpace 1 -postOpt -noOptAddBuffer -moveGate -useHVRC -fixedLeafInst -fixedNonLeafInst -noVerbose -noHTMLReport -noAddClockRootProp -noUseSingleDelim -noFence -noUseLibMaxFanout -noUseLibMaxCap
getClockMeshMode -quiet
setClockMeshMode -noUsage -preRouteAnalysis SignalStorm -postRouteAnalysis SignalStorm
setFillerMode -reset -corePrefix FILLER -createRows 1 -doDRC 1 -fillBoundary 1 -deleteFixed 1 -ecoMode 0
setPlaceMode -reset
setPlaceMode -congMediumEffort -timingDriven -modulePlan -noCongOpt -noClkGateAware -noPowerDriven -ignoreScan -reorderScan -ignoreSpare -assignIOPins -noiofixed -checkPinLayerForAccess {  {1}  } -noPreserveRouting -keepAffectedRouting -noCheckRoute
setScanReorderMode -reset
setScanReorderMode -noSkip
setStreamOutMode -specifyViaName %t_VIA%u -SEvianames OFF -virtualConnection ON
setTieHiLoMode -reset
setTrialRouteMode -noHighEffort -noFloorPlanMode -detour -noHandlePreroute -noAutoSkipTracks -noHandlePartition -noHandlePartitionComplex -noUseM1 -noKeepExistingRoute -noIgnoreAbutted2TermNet -pinGuide -noHonorPin -noSelNet -noSelNetOnly -noSelMarkedNet -noSelMarkedNetOnly -noIgnoreObstruct -noPKS -noUpdateRemainTrks -useDEFTrack -noPrintWiresOnRTBlk -noUsePagedArray -obstruct4 -noGuide -noBlockageCostMultiple -noMaxDetourRatio -noPtnBdryExt -noPtnBdryShr
setCTSMode -noSetDPinAsSync -noSetIoPinAsSync -noRouteClkNet -useCTSRouteGuide -topPreferredLayer 4 -bottomPreferredLayer 3 -noUseLefACLimit -preferredExtraSpace 1 -postOpt -noOptAddBuffer -moveGate -useHVRC -fixedLeafInst -fixedNonLeafInst -noVerbose -noHTMLReport -noAddClockRootProp -noUseSingleDelim -noFence -noUseLibMaxFanout -noUseLibMaxCap
getClockMeshMode -quiet
setClockMeshMode -noUsage -preRouteAnalysis UltraSim -postRouteAnalysis UltraSim
setFillerMode -reset -corePrefix FILLER -createRows 1 -doDRC 1 -fillBoundary 1 -deleteFixed 1 -ecoMode 0
setPlaceMode -reset
setPlaceMode -congMediumEffort -timingDriven -modulePlan -noCongOpt -noClkGateAware -noPowerDriven -ignoreScan -reorderScan -ignoreSpare -assignIOPins -noiofixed -checkPinLayerForAccess {  {1}  } -noPreserveRouting -keepAffectedRouting -noCheckRoute
setScanReorderMode -reset
setScanReorderMode -noSkip
setStreamOutMode -specifyViaName %t_VIA%u -SEvianames OFF -virtualConnection ON
setTieHiLoMode -reset
setTrialRouteMode -noHighEffort -noFloorPlanMode -detour -noHandlePreroute -noAutoSkipTracks -noHandlePartition -noHandlePartitionComplex -noUseM1 -noKeepExistingRoute -noIgnoreAbutted2TermNet -pinGuide -noHonorPin -noSelNet -noSelNetOnly -noSelMarkedNet -noSelMarkedNetOnly -noIgnoreObstruct -noPKS -noUpdateRemainTrks -useDEFTrack -noPrintWiresOnRTBlk -noUsePagedArray -obstruct4 -noGuide -noBlockageCostMultiple -noMaxDetourRatio -noPtnBdryExt -noPtnBdryShr
setCTSMode -noSetDPinAsSync -noSetIoPinAsSync -noRouteClkNet -useCTSRouteGuide -topPreferredLayer 4 -bottomPreferredLayer 3 -noUseLefACLimit -preferredExtraSpace 1 -postOpt -noOptAddBuffer -moveGate -useHVRC -fixedLeafInst -fixedNonLeafInst -noVerbose -noHTMLReport -noAddClockRootProp -noUseSingleDelim -noFence -noUseLibMaxFanout -noUseLibMaxCap
getClockMeshMode -quiet
setClockMeshMode -noUsage
setFillerMode -reset -corePrefix FILLER -createRows 1 -doDRC 1 -fillBoundary 1 -deleteFixed 1 -ecoMode 0
setPlaceMode -reset
setPlaceMode -congMediumEffort -timingDriven -modulePlan -noCongOpt -noClkGateAware -noPowerDriven -ignoreScan -reorderScan -ignoreSpare -assignIOPins -noiofixed -checkPinLayerForAccess {  {1}  } -noPreserveRouting -keepAffectedRouting -noCheckRoute
setScanReorderMode -reset
setScanReorderMode -noSkip
setStreamOutMode -specifyViaName %t_VIA%u -SEvianames OFF -virtualConnection ON
setTieHiLoMode -reset
setTrialRouteMode -noHighEffort -noFloorPlanMode -detour -noHandlePreroute -noAutoSkipTracks -noHandlePartition -noHandlePartitionComplex -noUseM1 -noKeepExistingRoute -noIgnoreAbutted2TermNet -pinGuide -noHonorPin -noSelNet -noSelNetOnly -noSelMarkedNet -noSelMarkedNetOnly -noIgnoreObstruct -noPKS -noUpdateRemainTrks -useDEFTrack -noPrintWiresOnRTBlk -noUsePagedArray -obstruct4 -noGuide -noBlockageCostMultiple -noMaxDetourRatio -noPtnBdryExt -noPtnBdryShr
analyzeClockMesh -force
setClockMeshMode -noUsage
setCTSMode -noSetDPinAsSync -noSetIoPinAsSync -noRouteClkNet -useCTSRouteGuide -topPreferredLayer 4 -bottomPreferredLayer 3 -noUseLefACLimit -preferredExtraSpace 1 -postOpt -noOptAddBuffer -moveGate -useHVRC -fixedLeafInst -fixedNonLeafInst -noVerbose -noHTMLReport -noAddClockRootProp -noUseSingleDelim -noFence -noUseLibMaxFanout -noUseLibMaxCap
getClockMeshMode -quiet
setClockMeshMode -noUsage -preRouteAnalysis SignalStorm -postRouteAnalysis SignalStorm
setFillerMode -reset -corePrefix FILLER -createRows 1 -doDRC 1 -fillBoundary 1 -deleteFixed 1 -ecoMode 0
setPlaceMode -reset
setPlaceMode -congMediumEffort -timingDriven -modulePlan -noCongOpt -noClkGateAware -noPowerDriven -ignoreScan -reorderScan -ignoreSpare -assignIOPins -noiofixed -checkPinLayerForAccess {  {1}  } -noPreserveRouting -keepAffectedRouting -noCheckRoute
setScanReorderMode -reset
setScanReorderMode -noSkip
setStreamOutMode -specifyViaName %t_VIA%u -SEvianames OFF -virtualConnection ON
setTieHiLoMode -reset
setTrialRouteMode -noHighEffort -noFloorPlanMode -detour -noHandlePreroute -noAutoSkipTracks -noHandlePartition -noHandlePartitionComplex -noUseM1 -noKeepExistingRoute -noIgnoreAbutted2TermNet -pinGuide -noHonorPin -noSelNet -noSelNetOnly -noSelMarkedNet -noSelMarkedNetOnly -noIgnoreObstruct -noPKS -noUpdateRemainTrks -useDEFTrack -noPrintWiresOnRTBlk -noUsePagedArray -obstruct4 -noGuide -noBlockageCostMultiple -noMaxDetourRatio -noPtnBdryExt -noPtnBdryShr
analyzeClockMesh -force
help setDelayCalMode
setClockMeshMode -noUsage
