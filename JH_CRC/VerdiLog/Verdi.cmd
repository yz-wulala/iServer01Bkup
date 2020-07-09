sidCmdLineBehaviorAnalysisOpt -incr -clockSkew 0 -loopUnroll 0 -bboxEmptyModule 0  -cellModel 0 -bboxIgnoreProtected 0 
debImport "-f" "crc4.v" "crc4_tb.v" "-top" "crc4_tb"
debLoadSimResult /home/stu02/project/JH_CRC/crc4_tb.fsdb
wvCreateWindow
wvGetSignalOpen -win $_nWave2
wvGetSignalSetScope -win $_nWave2 "/crc4_tb"
wvSetPosition -win $_nWave2 {("G1" 5)}
wvSetPosition -win $_nWave2 {("G1" 5)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/crc4_tb/clk_tb} \
{/crc4_tb/data_reg\[25:0\]} \
{/crc4_tb/i\[7:0\]} \
{/crc4_tb/rstn_tb} \
{/crc4_tb/start_tb} \
}
wvAddSignal -win $_nWave2 -group {"G2" \
}
wvSelectSignal -win $_nWave2 {( "G1" 1 2 3 4 5 )} 
wvSetPosition -win $_nWave2 {("G1" 5)}
wvGetSignalSetScope -win $_nWave2 "/crc4_tb/X_0"
wvSetPosition -win $_nWave2 {("G1" 17)}
wvSetPosition -win $_nWave2 {("G1" 17)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/crc4_tb/clk_tb} \
{/crc4_tb/data_reg\[25:0\]} \
{/crc4_tb/i\[7:0\]} \
{/crc4_tb/rstn_tb} \
{/crc4_tb/start_tb} \
{/crc4_tb/X_0/clear} \
{/crc4_tb/X_0/clk} \
{/crc4_tb/X_0/cnt\[4:0\]} \
{/crc4_tb/X_0/crc4\[3:0\]} \
{/crc4_tb/X_0/crc4_in} \
{/crc4_tb/X_0/data_in\[25:0\]} \
{/crc4_tb/X_0/data_out\[29:0\]} \
{/crc4_tb/X_0/data_reg\[25:0\]} \
{/crc4_tb/X_0/data_reg_nt\[25:0\]} \
{/crc4_tb/X_0/rstn} \
{/crc4_tb/X_0/start} \
{/crc4_tb/X_0/state} \
}
wvAddSignal -win $_nWave2 -group {"G2" \
}
wvSelectSignal -win $_nWave2 {( "G1" 6 7 8 9 10 11 12 13 14 15 16 17 )} 
wvSetPosition -win $_nWave2 {("G1" 17)}
wvGetSignalClose -win $_nWave2
verdiDockWidgetMaximize -dock windowDock_nWave_2
wvZoomAll -win $_nWave2
wvSetCursor -win $_nWave2 1168.214936 -snap {("G2" 0)}
wvSelectGroup -win $_nWave2 {G2}
wvSelectSignal -win $_nWave2 {( "G1" 12 )} 
wvSetPosition -win $_nWave2 {("G1" 12)}
wvExpandBus -win $_nWave2 {("G1" 12)}
wvSetPosition -win $_nWave2 {("G1" 47)}
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
debExit
