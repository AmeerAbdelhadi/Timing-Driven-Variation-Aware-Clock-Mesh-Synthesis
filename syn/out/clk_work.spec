RouteTypeDef MYRT1
    Layer   metal4
    Width   1um
    Spacing 1um
End

RouteTypeDef MYRT2
    Layer   metal5
    Width   1um
    Spacing 1um
End

Cutout

ClockMesh mymesh

    Period 1000ps
    RootTrans 100ps
    SupplyVoltage 1V

    MinDelay 0ps
    MaxDelay 100ps
    MaxSkew 100ps
    MaxBufferTrans 100ps
    MaxLeafTrans 100ps
    MaxPower 100mW

    RootPin blif_clk_net

    # LeafPin
    # + U1/A rising
    # ...

    # LeafCellPin
    # + NAND2/A rising
    # ...

    # LoadCellPin
    # + LOADX16/A
    # ...

    DefaultTrigger rising

    UseMeshModule true
    MeshModule clk_mesh_drive

    MeshDrivePoint Root
    RoutePattern Trunk

    MeshType HTreeMesh

    TrunkOrientation Horizontal

    # HTreePattern H

    TrunkPlacement UniformPitch

    TrunkDriveDist StrictAttach

    TopChain
        Enabled false
        # DriveCell <cellname>
        # NonDefaultRule <rulename>
        TopPreferLayer metal4
        BottomPreferLayer metal3
        PreferredExtraSpace 0
    End

    Stage
        NumDriver 1
        # X 1
        DriveCell CLKBUF1
        RouteTypePair MYRT2 MYRT1
        # NonDefaultRule <rulename>
        TopPreferLayer metal4
        BottomPreferLayer metal3
        PreferredExtraSpace 0
        NumTrunk 5
        NumBranch 5
        # TrunkPitch 50um
        # BranchPitch 20um
        # TrunkAttachFrequency 2
        # BranchAttachFrequency 2
        TargetTrunkLocs
    End

    LocalTree
        Enabled true
        RootPos ClusterCenter
        DriveCells
        + CLKBUF1
        # NonDefaultRule <rulename>
        TopPreferLayer metal4
        BottomPreferLayer metal3
        PreferredExtraSpace 0
    End

End

