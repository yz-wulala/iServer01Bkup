debImport "vg_dump.fsdb"
wvCreateWindow
wvSetPosition -win $_nWave2 {("G1" 0)}
wvOpenFile -win $_nWave2 {/home/stu02/project/my_soc/smartL/workdir/vg_dump.fsdb}
verdiWindowResize -win $_Verdi_1 -3 "31" "1920" "971"
wvGetSignalOpen -win $_nWave2
wvGetSignalSetScope -win $_nWave2 "/intr_priority_test"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc/x_ahb_fifo"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc/x_ahb_fifo/x_ahb_fifo_entry0"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc/x_ahb_fifo"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc/x_ahb"
wvSetPosition -win $_nWave2 {("G1" 19)}
wvSetPosition -win $_nWave2 {("G1" 19)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/tb/x_soc/x_ahb/busy_s1} \
{/tb/x_soc/x_ahb/busy_s2} \
{/tb/x_soc/x_ahb/busy_s3} \
{/tb/x_soc/x_ahb/busy_s4} \
{/tb/x_soc/x_ahb/busy_s5} \
{/tb/x_soc/x_ahb/hready_s1} \
{/tb/x_soc/x_ahb/hready_s2} \
{/tb/x_soc/x_ahb/hready_s3} \
{/tb/x_soc/x_ahb/hready_s4} \
{/tb/x_soc/x_ahb/hready_s5} \
{/tb/x_soc/x_ahb/hsel_s1} \
{/tb/x_soc/x_ahb/hsel_s2} \
{/tb/x_soc/x_ahb/hsel_s3} \
{/tb/x_soc/x_ahb/hsel_s4} \
{/tb/x_soc/x_ahb/hsel_s5} \
{/tb/x_soc/x_ahb/htrans_s1\[1:0\]} \
{/tb/x_soc/x_ahb/htrans_s2\[1:0\]} \
{/tb/x_soc/x_ahb/htrans_s3\[1:0\]} \
{/tb/x_soc/x_ahb/htrans_s5\[1:0\]} \
}
wvAddSignal -win $_nWave2 -group {"G2" \
}
wvSelectSignal -win $_nWave2 {( "G1" 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 \
           18 19 )} 
wvSetPosition -win $_nWave2 {("G1" 19)}
wvGetSignalClose -win $_nWave2
wvZoomAll -win $_nWave2
wvScrollUp -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvZoom -win $_nWave2 308999.248120 401333.342973
wvZoom -win $_nWave2 332550.049641 335647.433968
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
verdiDockWidgetMaximize -dock windowDock_nWave_2
wvSetCursor -win $_nWave2 329774.227192 -snap {("G2" 0)}
wvGetSignalOpen -win $_nWave2
wvGetSignalSetScope -win $_nWave2 "/intr_priority_test"
wvGetSignalSetScope -win $_nWave2 "/tb"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc/x_ahb_fifo"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc/x_ahb"
wvSetPosition -win $_nWave2 {("G1" 23)}
wvSetPosition -win $_nWave2 {("G1" 23)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/tb/x_soc/x_ahb/busy_s1} \
{/tb/x_soc/x_ahb/busy_s2} \
{/tb/x_soc/x_ahb/busy_s3} \
{/tb/x_soc/x_ahb/busy_s4} \
{/tb/x_soc/x_ahb/busy_s5} \
{/tb/x_soc/x_ahb/hready_s1} \
{/tb/x_soc/x_ahb/hready_s2} \
{/tb/x_soc/x_ahb/hready_s3} \
{/tb/x_soc/x_ahb/hready_s4} \
{/tb/x_soc/x_ahb/hready_s5} \
{/tb/x_soc/x_ahb/hsel_s1} \
{/tb/x_soc/x_ahb/hsel_s2} \
{/tb/x_soc/x_ahb/hsel_s3} \
{/tb/x_soc/x_ahb/hsel_s4} \
{/tb/x_soc/x_ahb/hsel_s5} \
{/tb/x_soc/x_ahb/htrans_s1\[1:0\]} \
{/tb/x_soc/x_ahb/htrans_s2\[1:0\]} \
{/tb/x_soc/x_ahb/htrans_s3\[1:0\]} \
{/tb/x_soc/x_ahb/htrans_s5\[1:0\]} \
{/tb/x_soc/x_ahb/hsize_s1\[2:0\]} \
{/tb/x_soc/x_ahb/hsize_s2\[2:0\]} \
{/tb/x_soc/x_ahb/hsize_s3\[2:0\]} \
{/tb/x_soc/x_ahb/hsize_s5\[2:0\]} \
}
wvAddSignal -win $_nWave2 -group {"G2" \
}
wvSelectSignal -win $_nWave2 {( "G1" 20 21 22 23 )} 
wvSetPosition -win $_nWave2 {("G1" 23)}
wvGetSignalClose -win $_nWave2
wvGetSignalOpen -win $_nWave2
wvGetSignalSetScope -win $_nWave2 "/intr_priority_test"
wvGetSignalSetScope -win $_nWave2 "/tb"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc/x_ahb"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc/x_ahb_fifo"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc/x_ahb"
wvSetPosition -win $_nWave2 {("G1" 24)}
wvSetPosition -win $_nWave2 {("G1" 24)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/tb/x_soc/x_ahb/busy_s1} \
{/tb/x_soc/x_ahb/busy_s2} \
{/tb/x_soc/x_ahb/busy_s3} \
{/tb/x_soc/x_ahb/busy_s4} \
{/tb/x_soc/x_ahb/busy_s5} \
{/tb/x_soc/x_ahb/hready_s1} \
{/tb/x_soc/x_ahb/hready_s2} \
{/tb/x_soc/x_ahb/hready_s3} \
{/tb/x_soc/x_ahb/hready_s4} \
{/tb/x_soc/x_ahb/hready_s5} \
{/tb/x_soc/x_ahb/hsel_s1} \
{/tb/x_soc/x_ahb/hsel_s2} \
{/tb/x_soc/x_ahb/hsel_s3} \
{/tb/x_soc/x_ahb/hsel_s4} \
{/tb/x_soc/x_ahb/hsel_s5} \
{/tb/x_soc/x_ahb/htrans_s1\[1:0\]} \
{/tb/x_soc/x_ahb/htrans_s2\[1:0\]} \
{/tb/x_soc/x_ahb/htrans_s3\[1:0\]} \
{/tb/x_soc/x_ahb/htrans_s5\[1:0\]} \
{/tb/x_soc/x_ahb/hsize_s1\[2:0\]} \
{/tb/x_soc/x_ahb/hsize_s2\[2:0\]} \
{/tb/x_soc/x_ahb/hsize_s3\[2:0\]} \
{/tb/x_soc/x_ahb/hsize_s5\[2:0\]} \
{/tb/x_soc/x_ahb/biu_pad_hwrite} \
}
wvAddSignal -win $_nWave2 -group {"G2" \
}
wvSelectSignal -win $_nWave2 {( "G1" 24 )} 
wvSetPosition -win $_nWave2 {("G1" 24)}
wvGetSignalClose -win $_nWave2
wvGetSignalOpen -win $_nWave2
wvGetSignalSetScope -win $_nWave2 "/intr_priority_test"
wvGetSignalSetScope -win $_nWave2 "/tb"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc/x_ahb"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc/x_ahb_fifo"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc/x_ahb"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc"
wvSetPosition -win $_nWave2 {("G1" 25)}
wvSetPosition -win $_nWave2 {("G1" 25)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/tb/x_soc/x_ahb/busy_s1} \
{/tb/x_soc/x_ahb/busy_s2} \
{/tb/x_soc/x_ahb/busy_s3} \
{/tb/x_soc/x_ahb/busy_s4} \
{/tb/x_soc/x_ahb/busy_s5} \
{/tb/x_soc/x_ahb/hready_s1} \
{/tb/x_soc/x_ahb/hready_s2} \
{/tb/x_soc/x_ahb/hready_s3} \
{/tb/x_soc/x_ahb/hready_s4} \
{/tb/x_soc/x_ahb/hready_s5} \
{/tb/x_soc/x_ahb/hsel_s1} \
{/tb/x_soc/x_ahb/hsel_s2} \
{/tb/x_soc/x_ahb/hsel_s3} \
{/tb/x_soc/x_ahb/hsel_s4} \
{/tb/x_soc/x_ahb/hsel_s5} \
{/tb/x_soc/x_ahb/htrans_s1\[1:0\]} \
{/tb/x_soc/x_ahb/htrans_s2\[1:0\]} \
{/tb/x_soc/x_ahb/htrans_s3\[1:0\]} \
{/tb/x_soc/x_ahb/htrans_s5\[1:0\]} \
{/tb/x_soc/x_ahb/hsize_s1\[2:0\]} \
{/tb/x_soc/x_ahb/hsize_s2\[2:0\]} \
{/tb/x_soc/x_ahb/hsize_s3\[2:0\]} \
{/tb/x_soc/x_ahb/hsize_s5\[2:0\]} \
{/tb/x_soc/x_ahb/biu_pad_hwrite} \
{/tb/x_soc/cpu_clk} \
}
wvAddSignal -win $_nWave2 -group {"G2" \
}
wvSelectSignal -win $_nWave2 {( "G1" 25 )} 
wvSetPosition -win $_nWave2 {("G1" 25)}
wvGetSignalClose -win $_nWave2
wvZoomAll -win $_nWave2
wvZoom -win $_nWave2 1047672.006940 1072355.378832
wvSetCursor -win $_nWave2 1060263.524585 -snap {("G1" 1)}
wvSetCursor -win $_nWave2 1063846.824958 -snap {("G1" 1)}
wvGetSignalOpen -win $_nWave2
wvGetSignalSetScope -win $_nWave2 "/intr_priority_test"
wvGetSignalSetScope -win $_nWave2 "/tb"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc/x_ahb"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc/x_ahb_fifo"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc/x_ahb"
wvSetPosition -win $_nWave2 {("G1" 29)}
wvSetPosition -win $_nWave2 {("G1" 29)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/tb/x_soc/x_ahb/busy_s1} \
{/tb/x_soc/x_ahb/busy_s2} \
{/tb/x_soc/x_ahb/busy_s3} \
{/tb/x_soc/x_ahb/busy_s4} \
{/tb/x_soc/x_ahb/busy_s5} \
{/tb/x_soc/x_ahb/hready_s1} \
{/tb/x_soc/x_ahb/hready_s2} \
{/tb/x_soc/x_ahb/hready_s3} \
{/tb/x_soc/x_ahb/hready_s4} \
{/tb/x_soc/x_ahb/hready_s5} \
{/tb/x_soc/x_ahb/hsel_s1} \
{/tb/x_soc/x_ahb/hsel_s2} \
{/tb/x_soc/x_ahb/hsel_s3} \
{/tb/x_soc/x_ahb/hsel_s4} \
{/tb/x_soc/x_ahb/hsel_s5} \
{/tb/x_soc/x_ahb/htrans_s1\[1:0\]} \
{/tb/x_soc/x_ahb/htrans_s2\[1:0\]} \
{/tb/x_soc/x_ahb/htrans_s3\[1:0\]} \
{/tb/x_soc/x_ahb/htrans_s5\[1:0\]} \
{/tb/x_soc/x_ahb/hsize_s1\[2:0\]} \
{/tb/x_soc/x_ahb/hsize_s2\[2:0\]} \
{/tb/x_soc/x_ahb/hsize_s3\[2:0\]} \
{/tb/x_soc/x_ahb/hsize_s5\[2:0\]} \
{/tb/x_soc/x_ahb/biu_pad_hwrite} \
{/tb/x_soc/cpu_clk} \
{/tb/x_soc/x_ahb/haddr_s1\[31:0\]} \
{/tb/x_soc/x_ahb/haddr_s2\[31:0\]} \
{/tb/x_soc/x_ahb/haddr_s3\[31:0\]} \
{/tb/x_soc/x_ahb/haddr_s5\[31:0\]} \
}
wvAddSignal -win $_nWave2 -group {"G2" \
}
wvSelectSignal -win $_nWave2 {( "G1" 26 27 28 29 )} 
wvSetPosition -win $_nWave2 {("G1" 29)}
wvGetSignalClose -win $_nWave2
wvZoom -win $_nWave2 1061348.507965 1062119.417208
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvGetSignalOpen -win $_nWave2
wvGetSignalSetScope -win $_nWave2 "/intr_priority_test"
wvGetSignalSetScope -win $_nWave2 "/tb"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc/x_ahb"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc/x_ahb_fifo"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc/x_ahb"
wvSetPosition -win $_nWave2 {("G1" 34)}
wvSetPosition -win $_nWave2 {("G1" 34)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/tb/x_soc/x_ahb/busy_s1} \
{/tb/x_soc/x_ahb/busy_s2} \
{/tb/x_soc/x_ahb/busy_s3} \
{/tb/x_soc/x_ahb/busy_s4} \
{/tb/x_soc/x_ahb/busy_s5} \
{/tb/x_soc/x_ahb/hready_s1} \
{/tb/x_soc/x_ahb/hready_s2} \
{/tb/x_soc/x_ahb/hready_s3} \
{/tb/x_soc/x_ahb/hready_s4} \
{/tb/x_soc/x_ahb/hready_s5} \
{/tb/x_soc/x_ahb/hsel_s1} \
{/tb/x_soc/x_ahb/hsel_s2} \
{/tb/x_soc/x_ahb/hsel_s3} \
{/tb/x_soc/x_ahb/hsel_s4} \
{/tb/x_soc/x_ahb/hsel_s5} \
{/tb/x_soc/x_ahb/htrans_s1\[1:0\]} \
{/tb/x_soc/x_ahb/htrans_s2\[1:0\]} \
{/tb/x_soc/x_ahb/htrans_s3\[1:0\]} \
{/tb/x_soc/x_ahb/htrans_s5\[1:0\]} \
{/tb/x_soc/x_ahb/hsize_s1\[2:0\]} \
{/tb/x_soc/x_ahb/hsize_s2\[2:0\]} \
{/tb/x_soc/x_ahb/hsize_s3\[2:0\]} \
{/tb/x_soc/x_ahb/hsize_s5\[2:0\]} \
{/tb/x_soc/x_ahb/biu_pad_hwrite} \
{/tb/x_soc/cpu_clk} \
{/tb/x_soc/x_ahb/haddr_s1\[31:0\]} \
{/tb/x_soc/x_ahb/haddr_s2\[31:0\]} \
{/tb/x_soc/x_ahb/haddr_s3\[31:0\]} \
{/tb/x_soc/x_ahb/haddr_s5\[31:0\]} \
{/tb/x_soc/x_ahb/hresp_s1\[1:0\]} \
{/tb/x_soc/x_ahb/hresp_s2\[1:0\]} \
{/tb/x_soc/x_ahb/hresp_s3\[1:0\]} \
{/tb/x_soc/x_ahb/hresp_s4\[1:0\]} \
{/tb/x_soc/x_ahb/hresp_s5\[1:0\]} \
}
wvAddSignal -win $_nWave2 -group {"G2" \
}
wvSelectSignal -win $_nWave2 {( "G1" 30 31 32 33 34 )} 
wvSetPosition -win $_nWave2 {("G1" 34)}
wvGetSignalClose -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 1049178.263166 1065614.815135
wvGetSignalOpen -win $_nWave2
wvGetSignalSetScope -win $_nWave2 "/intr_priority_test"
wvGetSignalSetScope -win $_nWave2 "/tb"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc/x_ahb"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc/x_ahb_fifo"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc/x_ahb"
wvSetPosition -win $_nWave2 {("G1" 42)}
wvSetPosition -win $_nWave2 {("G1" 42)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/tb/x_soc/x_ahb/busy_s1} \
{/tb/x_soc/x_ahb/busy_s2} \
{/tb/x_soc/x_ahb/busy_s3} \
{/tb/x_soc/x_ahb/busy_s4} \
{/tb/x_soc/x_ahb/busy_s5} \
{/tb/x_soc/x_ahb/hready_s1} \
{/tb/x_soc/x_ahb/hready_s2} \
{/tb/x_soc/x_ahb/hready_s3} \
{/tb/x_soc/x_ahb/hready_s4} \
{/tb/x_soc/x_ahb/hready_s5} \
{/tb/x_soc/x_ahb/hsel_s1} \
{/tb/x_soc/x_ahb/hsel_s2} \
{/tb/x_soc/x_ahb/hsel_s3} \
{/tb/x_soc/x_ahb/hsel_s4} \
{/tb/x_soc/x_ahb/hsel_s5} \
{/tb/x_soc/x_ahb/htrans_s1\[1:0\]} \
{/tb/x_soc/x_ahb/htrans_s2\[1:0\]} \
{/tb/x_soc/x_ahb/htrans_s3\[1:0\]} \
{/tb/x_soc/x_ahb/htrans_s5\[1:0\]} \
{/tb/x_soc/x_ahb/hsize_s1\[2:0\]} \
{/tb/x_soc/x_ahb/hsize_s2\[2:0\]} \
{/tb/x_soc/x_ahb/hsize_s3\[2:0\]} \
{/tb/x_soc/x_ahb/hsize_s5\[2:0\]} \
{/tb/x_soc/x_ahb/biu_pad_hwrite} \
{/tb/x_soc/cpu_clk} \
{/tb/x_soc/x_ahb/haddr_s1\[31:0\]} \
{/tb/x_soc/x_ahb/haddr_s2\[31:0\]} \
{/tb/x_soc/x_ahb/haddr_s3\[31:0\]} \
{/tb/x_soc/x_ahb/haddr_s5\[31:0\]} \
{/tb/x_soc/x_ahb/hresp_s1\[1:0\]} \
{/tb/x_soc/x_ahb/hresp_s2\[1:0\]} \
{/tb/x_soc/x_ahb/hresp_s3\[1:0\]} \
{/tb/x_soc/x_ahb/hresp_s4\[1:0\]} \
{/tb/x_soc/x_ahb/hresp_s5\[1:0\]} \
{/tb/x_soc/x_ahb/hwdata_s1\[31:0\]} \
{/tb/x_soc/x_ahb/hwdata_s2\[31:0\]} \
{/tb/x_soc/x_ahb/hwdata_s3\[31:0\]} \
{/tb/x_soc/x_ahb/hwdata_s5\[31:0\]} \
{/tb/x_soc/x_ahb/hwrite_s1} \
{/tb/x_soc/x_ahb/hwrite_s2} \
{/tb/x_soc/x_ahb/hwrite_s3} \
{/tb/x_soc/x_ahb/hwrite_s5} \
}
wvAddSignal -win $_nWave2 -group {"G2" \
}
wvSelectSignal -win $_nWave2 {( "G1" 35 36 37 38 39 40 41 42 )} 
wvSetPosition -win $_nWave2 {("G1" 42)}
wvGetSignalClose -win $_nWave2
wvZoom -win $_nWave2 1063694.523927 1064340.958591
wvScrollUp -win $_nWave2 4
wvGetSignalOpen -win $_nWave2
wvGetSignalSetScope -win $_nWave2 "/intr_priority_test"
wvGetSignalSetScope -win $_nWave2 "/tb"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc/x_ahb"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc/x_ahb_fifo"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc/x_ahb"
wvGetSignalClose -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G1" 6 )} 
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 1112555.719926 1119260.438249
wvSelectSignal -win $_nWave2 {( "G1" 12 )} 
wvSelectSignal -win $_nWave2 {( "G1" 12 13 14 15 )} 
wvSelectSignal -win $_nWave2 {( "G1" 12 13 14 15 17 )} 
wvSelectSignal -win $_nWave2 {( "G1" 12 13 14 15 17 18 )} 
wvSelectSignal -win $_nWave2 {( "G1" 12 13 14 15 17 18 19 )} 
wvSelectSignal -win $_nWave2 {( "G1" 12 13 14 15 17 18 19 22 )} 
wvSelectSignal -win $_nWave2 {( "G1" 12 13 14 15 17 18 19 21 22 )} 
wvSelectSignal -win $_nWave2 {( "G1" 12 13 14 15 17 18 19 21 22 23 )} 
wvSelectSignal -win $_nWave2 {( "G1" 12 13 14 15 17 18 19 21 22 23 27 )} 
wvSelectSignal -win $_nWave2 {( "G1" 12 13 14 15 17 18 19 21 22 23 27 28 )} 
wvSelectSignal -win $_nWave2 {( "G1" 12 13 14 15 17 18 19 21 22 23 27 28 29 )} \
           
wvSelectSignal -win $_nWave2 {( "G1" 12 13 14 15 17 18 19 21 22 23 27 28 29 31 \
           )} 
wvSelectSignal -win $_nWave2 {( "G1" 12 13 14 15 17 18 19 21 22 23 27 28 29 31 \
           32 )} 
wvSelectSignal -win $_nWave2 {( "G1" 12 13 14 15 17 18 19 21 22 23 27 28 29 31 \
           32 33 )} 
wvSelectSignal -win $_nWave2 {( "G1" 12 13 14 15 17 18 19 21 22 23 27 28 29 31 \
           32 33 34 )} 
wvSelectSignal -win $_nWave2 {( "G1" 12 13 14 15 17 18 19 21 22 23 27 28 29 31 \
           32 33 34 36 )} 
wvSelectSignal -win $_nWave2 {( "G1" 12 13 14 15 17 18 19 21 22 23 27 28 29 31 \
           32 33 34 36 37 )} 
wvSelectSignal -win $_nWave2 {( "G1" 12 13 14 15 17 18 19 21 22 23 27 28 29 31 \
           32 33 34 36 37 38 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G1" 22)}
wvSelectSignal -win $_nWave2 {( "G1" 7 )} 
wvSelectSignal -win $_nWave2 {( "G1" 7 8 9 10 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G1" 18)}
wvSelectSignal -win $_nWave2 {( "G1" 2 )} 
wvSelectSignal -win $_nWave2 {( "G1" 2 3 4 5 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G1" 14)}
wvPaste -win $_nWave2
wvSetPosition -win $_nWave2 {("G1" 14)}
wvSetPosition -win $_nWave2 {("G1" 18)}
wvSetCursor -win $_nWave2 1115182.396849 -snap {("G2" 0)}
wvSetCursor -win $_nWave2 1115190.762062 -snap {("G1" 18)}
wvSetCursor -win $_nWave2 1115303.692439 -snap {("G1" 16)}
wvSelectSignal -win $_nWave2 {( "G1" 16 )} 
wvSelectSignal -win $_nWave2 {( "G1" 16 17 18 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G1" 15)}
wvZoomAll -win $_nWave2
wvZoom -win $_nWave2 1088607.361198 1134952.058640
wvZoom -win $_nWave2 1115003.311768 1117692.055911
