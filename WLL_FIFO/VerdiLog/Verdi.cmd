sidCmdLineBehaviorAnalysisOpt -incr -clockSkew 0 -loopUnroll 0 -bboxEmptyModule 0  -cellModel 0 -bboxIgnoreProtected 0 
verdiWindowResize -win $_Verdi_1 "0" "31" "1920" "971"
debImport "-f" "WLL_FIFO.v" "WLL_FIFO_tb.v" "-top" "WLL_FIFO_tb"
debLoadSimResult /home/stu02/project/WLL_FIFO/WLL_FIFO_tb.fsdb
wvCreateWindow
verdiDockWidgetMaximize -dock windowDock_nWave_2
wvGetSignalOpen -win $_nWave2
wvGetSignalSetScope -win $_nWave2 "/WLL_FIFO_tb"
wvGetSignalSetScope -win $_nWave2 "/WLL_FIFO_tb/x1"
wvSetPosition -win $_nWave2 {("G1" 13)}
wvSetPosition -win $_nWave2 {("G1" 13)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/WLL_FIFO_tb/x1/clk} \
{/WLL_FIFO_tb/x1/data_in\[7:0\]} \
{/WLL_FIFO_tb/x1/data_out\[7:0\]} \
{/WLL_FIFO_tb/x1/empty} \
{/WLL_FIFO_tb/x1/en} \
{/WLL_FIFO_tb/x1/fifo_counter\[2:0\]} \
{/WLL_FIFO_tb/x1/fifo_reg\[0:3\]} \
{/WLL_FIFO_tb/x1/full} \
{/WLL_FIFO_tb/x1/rd_en} \
{/WLL_FIFO_tb/x1/rd_ptr\[1:0\]} \
{/WLL_FIFO_tb/x1/rst_n} \
{/WLL_FIFO_tb/x1/wr_en} \
{/WLL_FIFO_tb/x1/wr_ptr\[1:0\]} \
}
wvAddSignal -win $_nWave2 -group {"G2" \
}
wvSelectSignal -win $_nWave2 {( "G1" 1 2 3 4 5 6 7 8 9 10 11 12 13 )} 
wvSetPosition -win $_nWave2 {("G1" 13)}
wvGetSignalClose -win $_nWave2
wvSelectGroup -win $_nWave2 {G2}
wvZoomAll -win $_nWave2
wvSetCursor -win $_nWave2 221.039380 -snap {("G2" 0)}
wvSelectSignal -win $_nWave2 {( "G1" 7 )} 
wvSetPosition -win $_nWave2 {("G1" 7)}
wvExpandBus -win $_nWave2 {("G1" 7)}
wvSetPosition -win $_nWave2 {("G1" 17)}
wvSetCursor -win $_nWave2 83.460297 -snap {("G1" 15)}
wvSetCursor -win $_nWave2 68.463525 -snap {("G1" 15)}
wvZoom -win $_nWave2 14.996772 521.626856
wvSetCursor -win $_nWave2 55.880413 -snap {("G1" 0)}
wvSetCursor -win $_nWave2 0.000000
wvSetCursor -win $_nWave2 83.027151 -snap {("G1" 0)}
wvSetCursor -win $_nWave2 74.196285 -snap {("G1" 5)}
wvSetCursor -win $_nWave2 73.263485 -snap {("G1" 12)}
wvSetCursor -win $_nWave2 31.725706
wvSetCursor -win $_nWave2 78.823661
wvSelectSignal -win $_nWave2 {( "G1" 13 )} 
wvSelectSignal -win $_nWave2 {( "G1" 13 14 15 16 )} 
wvSelectSignal -win $_nWave2 {( "G1" 13 )} 
wvSelectSignal -win $_nWave2 {( "G1" 13 16 )} 
wvSearchPrev -win $_nWave2
wvSetSearchMode -win $_nWave2 -posedge
wvSearchNext -win $_nWave2
wvSearchNext -win $_nWave2
wvSearchNext -win $_nWave2
wvSearchNext -win $_nWave2
wvSearchNext -win $_nWave2
wvSearchNext -win $_nWave2
debExit
