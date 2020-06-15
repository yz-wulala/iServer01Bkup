verdiWindowResize -win $_Verdi_1 "0" "31" "1920" "971"
debImport "vg_dump.fsdb"
wvCreateWindow
wvSetPosition -win $_nWave2 {("G1" 0)}
wvOpenFile -win $_nWave2 {/home/stu02/project/my_soc/smartL/workdir/vg_dump.fsdb}
wvGetSignalOpen -win $_nWave2
wvGetSignalSetScope -win $_nWave2 "/ckcpu_lpmd_wait"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc/x_ahb_fifo"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc/x_ahb"
wvSetPosition -win $_nWave2 {("G1" 73)}
wvSetPosition -win $_nWave2 {("G1" 73)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/tb/x_soc/x_ahb/arb_block} \
{/tb/x_soc/x_ahb/biu_pad_haddr\[31:0\]} \
{/tb/x_soc/x_ahb/biu_pad_hburst\[2:0\]} \
{/tb/x_soc/x_ahb/biu_pad_hprot\[3:0\]} \
{/tb/x_soc/x_ahb/biu_pad_hsize\[2:0\]} \
{/tb/x_soc/x_ahb/biu_pad_htrans\[1:0\]} \
{/tb/x_soc/x_ahb/biu_pad_hwdata\[31:0\]} \
{/tb/x_soc/x_ahb/biu_pad_hwrite} \
{/tb/x_soc/x_ahb/busy_s1} \
{/tb/x_soc/x_ahb/busy_s2} \
{/tb/x_soc/x_ahb/busy_s3} \
{/tb/x_soc/x_ahb/busy_s4} \
{/tb/x_soc/x_ahb/busy_s5} \
{/tb/x_soc/x_ahb/haddr_s1\[31:0\]} \
{/tb/x_soc/x_ahb/haddr_s2\[31:0\]} \
{/tb/x_soc/x_ahb/haddr_s3\[31:0\]} \
{/tb/x_soc/x_ahb/haddr_s5\[31:0\]} \
{/tb/x_soc/x_ahb/hburst_s1\[2:0\]} \
{/tb/x_soc/x_ahb/hburst_s2\[2:0\]} \
{/tb/x_soc/x_ahb/hburst_s3\[2:0\]} \
{/tb/x_soc/x_ahb/hburst_s5\[2:0\]} \
{/tb/x_soc/x_ahb/hmastlock} \
{/tb/x_soc/x_ahb/hprot_s1\[3:0\]} \
{/tb/x_soc/x_ahb/hprot_s2\[3:0\]} \
{/tb/x_soc/x_ahb/hprot_s3\[3:0\]} \
{/tb/x_soc/x_ahb/hprot_s5\[3:0\]} \
{/tb/x_soc/x_ahb/hrdata_s1\[31:0\]} \
{/tb/x_soc/x_ahb/hrdata_s2\[31:0\]} \
{/tb/x_soc/x_ahb/hrdata_s3\[31:0\]} \
{/tb/x_soc/x_ahb/hrdata_s4\[31:0\]} \
{/tb/x_soc/x_ahb/hrdata_s5\[31:0\]} \
{/tb/x_soc/x_ahb/hready_s1} \
{/tb/x_soc/x_ahb/hready_s2} \
{/tb/x_soc/x_ahb/hready_s3} \
{/tb/x_soc/x_ahb/hready_s4} \
{/tb/x_soc/x_ahb/hready_s5} \
{/tb/x_soc/x_ahb/hresp_s1\[1:0\]} \
{/tb/x_soc/x_ahb/hresp_s2\[1:0\]} \
{/tb/x_soc/x_ahb/hresp_s3\[1:0\]} \
{/tb/x_soc/x_ahb/hresp_s4\[1:0\]} \
{/tb/x_soc/x_ahb/hresp_s5\[1:0\]} \
{/tb/x_soc/x_ahb/hsel_s1} \
{/tb/x_soc/x_ahb/hsel_s2} \
{/tb/x_soc/x_ahb/hsel_s3} \
{/tb/x_soc/x_ahb/hsel_s4} \
{/tb/x_soc/x_ahb/hsel_s5} \
{/tb/x_soc/x_ahb/hsize_s1\[2:0\]} \
{/tb/x_soc/x_ahb/hsize_s2\[2:0\]} \
{/tb/x_soc/x_ahb/hsize_s3\[2:0\]} \
{/tb/x_soc/x_ahb/hsize_s5\[2:0\]} \
{/tb/x_soc/x_ahb/htrans_s1\[1:0\]} \
{/tb/x_soc/x_ahb/htrans_s2\[1:0\]} \
{/tb/x_soc/x_ahb/htrans_s3\[1:0\]} \
{/tb/x_soc/x_ahb/htrans_s5\[1:0\]} \
{/tb/x_soc/x_ahb/hwdata_s1\[31:0\]} \
{/tb/x_soc/x_ahb/hwdata_s2\[31:0\]} \
{/tb/x_soc/x_ahb/hwdata_s3\[31:0\]} \
{/tb/x_soc/x_ahb/hwdata_s5\[31:0\]} \
{/tb/x_soc/x_ahb/hwrite_s1} \
{/tb/x_soc/x_ahb/hwrite_s2} \
{/tb/x_soc/x_ahb/hwrite_s3} \
{/tb/x_soc/x_ahb/hwrite_s5} \
{/tb/x_soc/x_ahb/pad_biu_hrdata\[31:0\]} \
{/tb/x_soc/x_ahb/pad_biu_hready} \
{/tb/x_soc/x_ahb/pad_biu_hresp\[1:0\]} \
{/tb/x_soc/x_ahb/pad_cpu_rst_b} \
{/tb/x_soc/x_ahb/pll_core_cpuclk} \
{/tb/x_soc/x_ahb/pre_busy_s1} \
{/tb/x_soc/x_ahb/pre_busy_s2} \
{/tb/x_soc/x_ahb/pre_busy_s3} \
{/tb/x_soc/x_ahb/pre_busy_s4} \
{/tb/x_soc/x_ahb/pre_busy_s5} \
{/tb/x_soc/x_ahb/smpu_deny} \
}
wvAddSignal -win $_nWave2 -group {"G2" \
}
wvSelectSignal -win $_nWave2 {( "G1" 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 \
           18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 \
           40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 \
           62 63 64 65 66 67 68 69 70 71 72 73 )} 
wvSetPosition -win $_nWave2 {("G1" 73)}
wvGetSignalClose -win $_nWave2
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvZoomAll -win $_nWave2
wvZoomAll -win $_nWave2
wvZoomAll -win $_nWave2
wvZoomAll -win $_nWave2
wvZoom -win $_nWave2 593375.348122 612820.617723
wvZoom -win $_nWave2 601160.698149 606773.392354
wvSelectSignal -win $_nWave2 {( "G1" 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 \
           18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 \
           40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 \
           62 63 64 65 66 67 68 69 70 71 72 73 )} 
verdiDockWidgetMaximize -dock windowDock_nWave_2
wvSelectSignal -win $_nWave2 {( "G1" 66 )} 
wvSelectGroup -win $_nWave2 {G2}
wvScrollDown -win $_nWave2 0
wvScrollUp -win $_nWave2 9
wvScrollUp -win $_nWave2 10
wvScrollUp -win $_nWave2 19
wvScrollDown -win $_nWave2 0
wvSelectSignal -win $_nWave2 {( "G1" 1 )} 
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G1" 3 )} 
wvZoomAll -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G1" 4 )} 
wvSelectSignal -win $_nWave2 {( "G1" 5 )} 
wvZoom -win $_nWave2 590907.521726 624402.814401
wvZoom -win $_nWave2 601074.621737 606397.275322
wvSelectSignal -win $_nWave2 {( "G1" 6 )} 
wvSelectSignal -win $_nWave2 {( "G1" 7 )} 
wvSelectSignal -win $_nWave2 {( "G1" 8 )} 
wvSelectSignal -win $_nWave2 {( "G1" 10 )} 
wvSelectSignal -win $_nWave2 {( "G1" 9 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G2" 0)}
wvSetPosition -win $_nWave2 {("G1" 72)}
wvSelectSignal -win $_nWave2 {( "G1" 10 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G2" 0)}
wvSetPosition -win $_nWave2 {("G1" 71)}
wvSelectSignal -win $_nWave2 {( "G1" 10 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G2" 0)}
wvSetPosition -win $_nWave2 {("G1" 70)}
wvSelectSignal -win $_nWave2 {( "G1" 10 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G2" 0)}
wvSetPosition -win $_nWave2 {("G1" 69)}
wvSelectSignal -win $_nWave2 {( "G1" 10 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G2" 0)}
wvSetPosition -win $_nWave2 {("G1" 68)}
wvSelectSignal -win $_nWave2 {( "G1" 11 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G2" 0)}
wvSetPosition -win $_nWave2 {("G1" 67)}
wvSelectSignal -win $_nWave2 {( "G1" 11 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G2" 0)}
wvSetPosition -win $_nWave2 {("G1" 66)}
wvSelectSignal -win $_nWave2 {( "G1" 11 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G2" 0)}
wvSetPosition -win $_nWave2 {("G1" 65)}
wvSelectSignal -win $_nWave2 {( "G1" 12 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G2" 0)}
wvSetPosition -win $_nWave2 {("G1" 64)}
wvSelectSignal -win $_nWave2 {( "G1" 12 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G2" 0)}
wvSetPosition -win $_nWave2 {("G1" 63)}
wvSelectSignal -win $_nWave2 {( "G1" 12 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G2" 0)}
wvSetPosition -win $_nWave2 {("G1" 62)}
wvSelectSignal -win $_nWave2 {( "G1" 12 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G2" 0)}
wvSetPosition -win $_nWave2 {("G1" 61)}
wvSelectSignal -win $_nWave2 {( "G1" 13 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G2" 0)}
wvSetPosition -win $_nWave2 {("G1" 60)}
wvSelectSignal -win $_nWave2 {( "G1" 13 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G2" 0)}
wvSetPosition -win $_nWave2 {("G1" 59)}
wvSelectSignal -win $_nWave2 {( "G1" 13 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G2" 0)}
wvSetPosition -win $_nWave2 {("G1" 58)}
wvSelectSignal -win $_nWave2 {( "G1" 14 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G2" 0)}
wvSetPosition -win $_nWave2 {("G1" 57)}
wvSelectSignal -win $_nWave2 {( "G1" 14 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G2" 0)}
wvSetPosition -win $_nWave2 {("G1" 56)}
wvSelectSignal -win $_nWave2 {( "G1" 14 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G2" 0)}
wvSetPosition -win $_nWave2 {("G1" 55)}
wvSelectSignal -win $_nWave2 {( "G1" 14 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G2" 0)}
wvSetPosition -win $_nWave2 {("G1" 54)}
wvSelectSignal -win $_nWave2 {( "G1" 15 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G2" 0)}
wvSetPosition -win $_nWave2 {("G1" 53)}
wvSelectSignal -win $_nWave2 {( "G1" 15 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G2" 0)}
wvSetPosition -win $_nWave2 {("G1" 52)}
wvSelectSignal -win $_nWave2 {( "G1" 15 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G2" 0)}
wvSetPosition -win $_nWave2 {("G1" 51)}
wvSelectSignal -win $_nWave2 {( "G1" 15 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G2" 0)}
wvSetPosition -win $_nWave2 {("G1" 50)}
wvSelectSignal -win $_nWave2 {( "G1" 16 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G2" 0)}
wvSetPosition -win $_nWave2 {("G1" 49)}
wvSelectSignal -win $_nWave2 {( "G1" 16 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G2" 0)}
wvSetPosition -win $_nWave2 {("G1" 48)}
wvSelectSignal -win $_nWave2 {( "G1" 16 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G2" 0)}
wvSetPosition -win $_nWave2 {("G1" 47)}
wvSelectSignal -win $_nWave2 {( "G1" 16 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G2" 0)}
wvSetPosition -win $_nWave2 {("G1" 46)}
wvSelectSignal -win $_nWave2 {( "G1" 17 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G2" 0)}
wvSetPosition -win $_nWave2 {("G1" 45)}
wvSelectSignal -win $_nWave2 {( "G1" 17 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G2" 0)}
wvSetPosition -win $_nWave2 {("G1" 44)}
wvSelectSignal -win $_nWave2 {( "G1" 17 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G2" 0)}
wvSetPosition -win $_nWave2 {("G1" 43)}
wvSelectSignal -win $_nWave2 {( "G1" 16 )} 
wvSelectSignal -win $_nWave2 {( "G1" 17 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G2" 0)}
wvSetPosition -win $_nWave2 {("G1" 42)}
wvSelectSignal -win $_nWave2 {( "G1" 18 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G2" 0)}
wvSetPosition -win $_nWave2 {("G1" 41)}
wvSelectSignal -win $_nWave2 {( "G1" 19 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G2" 0)}
wvSetPosition -win $_nWave2 {("G1" 40)}
wvSelectSignal -win $_nWave2 {( "G1" 18 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G2" 0)}
wvSetPosition -win $_nWave2 {("G1" 39)}
wvSelectSignal -win $_nWave2 {( "G1" 19 )} 
wvSelectSignal -win $_nWave2 {( "G1" 19 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G2" 0)}
wvSetPosition -win $_nWave2 {("G1" 38)}
wvSelectSignal -win $_nWave2 {( "G1" 19 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G2" 0)}
wvSetPosition -win $_nWave2 {("G1" 37)}
wvSelectSignal -win $_nWave2 {( "G1" 19 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G2" 0)}
wvSetPosition -win $_nWave2 {("G1" 36)}
wvSelectSignal -win $_nWave2 {( "G1" 20 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G2" 0)}
wvSetPosition -win $_nWave2 {("G1" 35)}
wvSelectSignal -win $_nWave2 {( "G1" 20 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G2" 0)}
wvSetPosition -win $_nWave2 {("G1" 34)}
wvSelectSignal -win $_nWave2 {( "G1" 20 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G2" 0)}
wvSetPosition -win $_nWave2 {("G1" 33)}
wvSelectSignal -win $_nWave2 {( "G1" 21 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G2" 0)}
wvSetPosition -win $_nWave2 {("G1" 32)}
wvSelectSignal -win $_nWave2 {( "G1" 21 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G2" 0)}
wvSetPosition -win $_nWave2 {("G1" 31)}
wvSelectSignal -win $_nWave2 {( "G1" 27 )} 
wvSelectSignal -win $_nWave2 {( "G1" 28 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G2" 0)}
wvSetPosition -win $_nWave2 {("G1" 30)}
wvSelectSignal -win $_nWave2 {( "G1" 28 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G2" 0)}
wvSetPosition -win $_nWave2 {("G1" 29)}
wvSelectSignal -win $_nWave2 {( "G1" 28 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G2" 0)}
wvSetPosition -win $_nWave2 {("G1" 28)}
wvSelectSignal -win $_nWave2 {( "G1" 26 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G2" 0)}
wvSetPosition -win $_nWave2 {("G1" 27)}
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 784950.662255 812016.570489
wvZoom -win $_nWave2 799953.676564 807732.395070
wvSelectSignal -win $_nWave2 {( "G1" 4 )} 
wvSelectSignal -win $_nWave2 {( "G1" 10 )} 
wvSelectAll -win $_nWave2
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G1" 0)}
wvGetSignalOpen -win $_nWave2
wvGetSignalSetScope -win $_nWave2 "/ckcpu_lpmd_wait"
wvGetSignalSetScope -win $_nWave2 "/tb"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc/x_ahb"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc/x_smem_ctrl"
wvSetPosition -win $_nWave2 {("G1" 61)}
wvSetPosition -win $_nWave2 {("G1" 61)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/tb/x_soc/x_smem_ctrl/ahb_trans_clear} \
{/tb/x_soc/x_smem_ctrl/ahb_trans_valid} \
{/tb/x_soc/x_smem_ctrl/bypass_if_write_byte} \
{/tb/x_soc/x_smem_ctrl/bypass_if_write_hword} \
{/tb/x_soc/x_smem_ctrl/bypass_if_write_word} \
{/tb/x_soc/x_smem_ctrl/haddr\[31:0\]} \
{/tb/x_soc/x_smem_ctrl/haddr_ff\[31:0\]} \
{/tb/x_soc/x_smem_ctrl/haddr_s1\[31:0\]} \
{/tb/x_soc/x_smem_ctrl/hburst_s1\[2:0\]} \
{/tb/x_soc/x_smem_ctrl/hclk} \
{/tb/x_soc/x_smem_ctrl/hprot_s1\[3:0\]} \
{/tb/x_soc/x_smem_ctrl/hrdata\[31:0\]} \
{/tb/x_soc/x_smem_ctrl/hrdata_pre\[31:0\]} \
{/tb/x_soc/x_smem_ctrl/hrdata_raw\[31:0\]} \
{/tb/x_soc/x_smem_ctrl/hrdata_s1\[31:0\]} \
{/tb/x_soc/x_smem_ctrl/hread_ff} \
{/tb/x_soc/x_smem_ctrl/hready} \
{/tb/x_soc/x_smem_ctrl/hready_s1} \
{/tb/x_soc/x_smem_ctrl/hresp\[1:0\]} \
{/tb/x_soc/x_smem_ctrl/hresp_s1\[1:0\]} \
{/tb/x_soc/x_smem_ctrl/hrst_b} \
{/tb/x_soc/x_smem_ctrl/hsel} \
{/tb/x_soc/x_smem_ctrl/hsel_s1} \
{/tb/x_soc/x_smem_ctrl/hsize\[2:0\]} \
{/tb/x_soc/x_smem_ctrl/hsize_ff\[2:0\]} \
{/tb/x_soc/x_smem_ctrl/hsize_s1\[2:0\]} \
{/tb/x_soc/x_smem_ctrl/htrans\[1:0\]} \
{/tb/x_soc/x_smem_ctrl/htrans_s1\[1:0\]} \
{/tb/x_soc/x_smem_ctrl/hwdata\[31:0\]} \
{/tb/x_soc/x_smem_ctrl/hwdata_s1\[31:0\]} \
{/tb/x_soc/x_smem_ctrl/hwrite} \
{/tb/x_soc/x_smem_ctrl/hwrite_ff} \
{/tb/x_soc/x_smem_ctrl/hwrite_s1} \
{/tb/x_soc/x_smem_ctrl/pad_cpu_rst_b} \
{/tb/x_soc/x_smem_ctrl/pll_core_cpuclk} \
{/tb/x_soc/x_smem_ctrl/ram0_addr\[14:0\]} \
{/tb/x_soc/x_smem_ctrl/ram0_din\[7:0\]} \
{/tb/x_soc/x_smem_ctrl/ram0_dout\[7:0\]} \
{/tb/x_soc/x_smem_ctrl/ram1_addr\[14:0\]} \
{/tb/x_soc/x_smem_ctrl/ram1_din\[7:0\]} \
{/tb/x_soc/x_smem_ctrl/ram1_dout\[7:0\]} \
{/tb/x_soc/x_smem_ctrl/ram2_addr\[14:0\]} \
{/tb/x_soc/x_smem_ctrl/ram2_din\[7:0\]} \
{/tb/x_soc/x_smem_ctrl/ram2_dout\[7:0\]} \
{/tb/x_soc/x_smem_ctrl/ram3_addr\[14:0\]} \
{/tb/x_soc/x_smem_ctrl/ram3_din\[7:0\]} \
{/tb/x_soc/x_smem_ctrl/ram3_dout\[7:0\]} \
{/tb/x_soc/x_smem_ctrl/ram_addr\[31:0\]} \
{/tb/x_soc/x_smem_ctrl/ram_clk} \
{/tb/x_soc/x_smem_ctrl/ram_wen\[3:0\]} \
{/tb/x_soc/x_smem_ctrl/ram_wen_byte\[3:0\]} \
{/tb/x_soc/x_smem_ctrl/ram_wen_hword\[3:0\]} \
{/tb/x_soc/x_smem_ctrl/ram_wen_pre\[3:0\]} \
{/tb/x_soc/x_smem_ctrl/ram_wen_word\[3:0\]} \
{/tb/x_soc/x_smem_ctrl/raw_bypass_en} \
{/tb/x_soc/x_smem_ctrl/raw_data_vld} \
{/tb/x_soc/x_smem_ctrl/raw_en} \
{/tb/x_soc/x_smem_ctrl/raw_no_bypass} \
{/tb/x_soc/x_smem_ctrl/rdata_vld} \
{/tb/x_soc/x_smem_ctrl/read_en} \
{/tb/x_soc/x_smem_ctrl/write_en} \
}
wvAddSignal -win $_nWave2 -group {"G2" \
}
wvSelectSignal -win $_nWave2 {( "G1" 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 \
           18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 \
           40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 \
           )} 
wvSetPosition -win $_nWave2 {("G1" 61)}
wvGetSignalClose -win $_nWave2
wvZoomAll -win $_nWave2
wvZoom -win $_nWave2 692025.386406 713512.932651
wvSelectSignal -win $_nWave2 {( "G1" 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 \
           18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 \
           40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 \
           )} 
wvSelectGroup -win $_nWave2 {G2}
wvScrollUp -win $_nWave2 26
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 428486.951583 530236.802917
wvZoom -win $_nWave2 441939.911443 452866.493864
wvZoomAll -win $_nWave2
wvZoom -win $_nWave2 2527.946617 15167.679702
wvSelectSignal -win $_nWave2 {( "G1" 3 )} 
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
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
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
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
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 521218.341592 554861.529345
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
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
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
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
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
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
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 531064.873576 545933.867790
wvSelectSignal -win $_nWave2 {( "G1" 16 )} 
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvZoomAll -win $_nWave2
wvZoom -win $_nWave2 793143.251086 813998.810677
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
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
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvSelectSignal -win $_nWave2 {( "G1" 7 )} 
wvZoom -win $_nWave2 800198.670066 807124.631817
wvZoom -win $_nWave2 801264.864054 802481.528967
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
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
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
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
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 800840.050886 806664.333823
wvZoomAll -win $_nWave2
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvZoom -win $_nWave2 994115.007138 1016234.540037
wvZoom -win $_nWave2 1001090.005719 1008778.980531
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
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
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
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
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvSelectSignal -win $_nWave2 {( "G1" 3 )} 
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 4
wvScrollDown -win $_nWave2 11
wvScrollDown -win $_nWave2 11
wvScrollUp -win $_nWave2 8
wvScrollUp -win $_nWave2 7
wvScrollUp -win $_nWave2 11
wvScrollDown -win $_nWave2 0
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 899001.504763 908012.544147
wvSelectSignal -win $_nWave2 {( "G1" 31 )} 
wvScrollDown -win $_nWave2 2
verdiWindowBeWindow -win $_nWave2
wvResizeWindow -win $_nWave2 318 112 1921 896
wvScrollUp -win $_nWave2 2
wvScrollDown -win $_nWave2 15
wvScrollUp -win $_nWave2 4
wvSelectSignal -win $_nWave2 {( "G1" 11 )} 
wvSelectSignal -win $_nWave2 {( "G1" 24 )} 
wvSelectSignal -win $_nWave2 {( "G1" 27 )} 
wvResizeWindow -win $_nWave2 -3 31 1920 971
wvSetCursor -win $_nWave2 904186.627984 -snap {("G1" 49)}
wvSelectSignal -win $_nWave2 {( "G1" 28 )} 
wvSelectAll -win $_nWave2
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G1" 0)}
wvGetSignalOpen -win $_nWave2
wvGetSignalSetScope -win $_nWave2 "/ckcpu_lpmd_wait"
wvGetSignalSetScope -win $_nWave2 "/tb"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc/x_ahb"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc/x_ahb_fifo"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc/x_smem_ctrl"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc/x_ahb_fifo/x_ahb_fifo_entry0"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc/x_apb"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc/x_apb/x_apb_bridge"
wvSetPosition -win $_nWave2 {("G1" 21)}
wvSetPosition -win $_nWave2 {("G1" 21)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/tb/x_soc/x_apb/x_apb_bridge/apb_harb_hrdata\[31:0\]} \
{/tb/x_soc/x_apb/x_apb_bridge/apb_harb_hready} \
{/tb/x_soc/x_apb/x_apb_bridge/apb_harb_hresp\[1:0\]} \
{/tb/x_soc/x_apb/x_apb_bridge/apb_xx_paddr\[31:0\]} \
{/tb/x_soc/x_apb/x_apb_bridge/apb_xx_penable} \
{/tb/x_soc/x_apb/x_apb_bridge/apb_xx_psel} \
{/tb/x_soc/x_apb/x_apb_bridge/apb_xx_pwdata\[31:0\]} \
{/tb/x_soc/x_apb/x_apb_bridge/apb_xx_pwrite} \
{/tb/x_soc/x_apb/x_apb_bridge/cur_state\[2:0\]} \
{/tb/x_soc/x_apb/x_apb_bridge/enable_latch} \
{/tb/x_soc/x_apb/x_apb_bridge/enable_r_select} \
{/tb/x_soc/x_apb/x_apb_bridge/haddr_latch\[31:0\]} \
{/tb/x_soc/x_apb/x_apb_bridge/harb_apb_hsel} \
{/tb/x_soc/x_apb/x_apb_bridge/harb_xx_haddr\[31:0\]} \
{/tb/x_soc/x_apb/x_apb_bridge/harb_xx_hwdata\[31:0\]} \
{/tb/x_soc/x_apb/x_apb_bridge/harb_xx_hwrite} \
{/tb/x_soc/x_apb/x_apb_bridge/hclk} \
{/tb/x_soc/x_apb/x_apb_bridge/hwrite_latch} \
{/tb/x_soc/x_apb/x_apb_bridge/idle_latch} \
{/tb/x_soc/x_apb/x_apb_bridge/idle_r_select} \
{/tb/x_soc/x_apb/x_apb_bridge/nxt_state\[2:0\]} \
}
wvAddSignal -win $_nWave2 -group {"G2" \
}
wvSelectSignal -win $_nWave2 {( "G1" 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 \
           18 19 20 21 )} 
wvSetPosition -win $_nWave2 {("G1" 21)}
wvGetSignalClose -win $_nWave2
wvZoomAll -win $_nWave2
wvZoom -win $_nWave2 592803.481688 614923.014587
wvZoom -win $_nWave2 603183.597686 604968.538267
wvSearchPrev -win $_nWave2
wvSearchPrev -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 903592.746204 904864.696413
wvSelectGroup -win $_nWave2 {G2}
wvSelectGroup -win $_nWave2 {G2}
wvSelectSignal -win $_nWave2 {( "G1" 19 )} 
wvSelectSignal -win $_nWave2 {( "G1" 20 )} 
wvSelectSignal -win $_nWave2 {( "G1" 9 )} 
wvSelectSignal -win $_nWave2 {( "G1" 5 )} 
wvSelectSignal -win $_nWave2 {( "G1" 6 )} 
wvSelectSignal -win $_nWave2 {( "G1" 1 )} 
wvSelectSignal -win $_nWave2 {( "G1" 2 )} 
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 996642.953755 1008650.700186
wvZoom -win $_nWave2 1003776.047073 1004640.664445
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 523916.936375 561836.135630
wvZoom -win $_nWave2 534673.655220 547666.453475
wvSelectSignal -win $_nWave2 {( "G1" 6 )} 
wvSelectSignal -win $_nWave2 {( "G1" 15 )} 
wvSelectSignal -win $_nWave2 {( "G1" 16 )} 
wvSelectSignal -win $_nWave2 {( "G1" 16 )} 
wvSelectSignal -win $_nWave2 {( "G1" 16 17 18 19 )} 
wvSelectSignal -win $_nWave2 {( "G1" 16 )} 
wvSelectSignal -win $_nWave2 {( "G1" 16 )} 
wvSelectSignal -win $_nWave2 {( "G1" 14 15 16 )} 
wvSetCursor -win $_nWave2 534834.956254 -snap {("G1" 16)}
wvSelectSignal -win $_nWave2 {( "G1" 16 )} 
wvSelectSignal -win $_nWave2 {( "G1" 13 )} 
wvTpfCloseForm -win $_nWave2
wvGetSignalClose -win $_nWave2
wvCloseWindow -win $_nWave2
debExit
