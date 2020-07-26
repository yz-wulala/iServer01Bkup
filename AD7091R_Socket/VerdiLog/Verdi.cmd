sidCmdLineBehaviorAnalysisOpt -incr -clockSkew 0 -loopUnroll 0 -bboxEmptyModule 0  -cellModel 0 -bboxIgnoreProtected 0 
verdiWindowResize -win $_Verdi_1 "0" "31" "1920" "971"
debImport "-f" "AD7091R_Socket.v" "AD7091R_Socket_tb.v" "-top" \
          "AD7091R_Socket_tb"
debLoadSimResult /home/stu02/project/AD7091R_Socket/AD7091R_Socket_tb.fsdb
wvCreateWindow
verdiDockWidgetMaximize -dock windowDock_nWave_2
wvGetSignalOpen -win $_nWave2
wvGetSignalSetScope -win $_nWave2 "/AD7091R_Socket_tb"
wvSetPosition -win $_nWave2 {("G1" 1)}
wvSetPosition -win $_nWave2 {("G1" 1)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/AD7091R_Socket_tb/test_data\[11:0\]} \
}
wvAddSignal -win $_nWave2 -group {"G2" \
}
wvSelectSignal -win $_nWave2 {( "G1" 1 )} 
wvSetPosition -win $_nWave2 {("G1" 1)}
wvGetSignalSetScope -win $_nWave2 "/AD7091R_Socket_tb/X0"
wvSetPosition -win $_nWave2 {("G1" 16)}
wvSetPosition -win $_nWave2 {("G1" 16)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/AD7091R_Socket_tb/test_data\[11:0\]} \
{/AD7091R_Socket_tb/X0/adc_data\[11:0\]} \
{/AD7091R_Socket_tb/X0/adc_data_o\[11:0\]} \
{/AD7091R_Socket_tb/X0/adc_rdy} \
{/AD7091R_Socket_tb/X0/clk} \
{/AD7091R_Socket_tb/X0/cnt\[5:0\]} \
{/AD7091R_Socket_tb/X0/cnt_full} \
{/AD7091R_Socket_tb/X0/convst_n_o} \
{/AD7091R_Socket_tb/X0/cs_n_o} \
{/AD7091R_Socket_tb/X0/en} \
{/AD7091R_Socket_tb/X0/next_state\[2:0\]} \
{/AD7091R_Socket_tb/X0/rd_en} \
{/AD7091R_Socket_tb/X0/rst_n} \
{/AD7091R_Socket_tb/X0/sclk_o} \
{/AD7091R_Socket_tb/X0/sdo_i} \
{/AD7091R_Socket_tb/X0/state\[2:0\]} \
}
wvAddSignal -win $_nWave2 -group {"G2" \
}
wvSelectSignal -win $_nWave2 {( "G1" 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 )} 
wvSetPosition -win $_nWave2 {("G1" 16)}
wvGetSignalClose -win $_nWave2
wvSelectGroup -win $_nWave2 {G2}
wvSelectSignal -win $_nWave2 {( "G1" 10 )} 
wvSelectSignal -win $_nWave2 {( "G1" 11 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G2" 0)}
wvSetPosition -win $_nWave2 {("G1" 15)}
wvSelectSignal -win $_nWave2 {( "G1" 15 )} 
wvSetPosition -win $_nWave2 {("G1" 14)}
wvSetPosition -win $_nWave2 {("G1" 13)}
wvSetPosition -win $_nWave2 {("G1" 12)}
wvSetPosition -win $_nWave2 {("G1" 11)}
wvSetPosition -win $_nWave2 {("G1" 10)}
wvSetPosition -win $_nWave2 {("G1" 9)}
wvSetPosition -win $_nWave2 {("G1" 8)}
wvSetPosition -win $_nWave2 {("G1" 7)}
wvMoveSelected -win $_nWave2
wvSetPosition -win $_nWave2 {("G1" 7)}
wvSetPosition -win $_nWave2 {("G1" 8)}
wvZoomAll -win $_nWave2
wvZoom -win $_nWave2 93.679361 545.945946
wvSelectSignal -win $_nWave2 {( "G1" 6 )} 
wvSetRadix -win $_nWave2 -1Com
wvSetCursor -win $_nWave2 213.135523 -snap {("G2" 0)}
wvSetRadix -win $_nWave2 -2Com
wvSelectSignal -win $_nWave2 {( "G1" 6 )} 
wvSetRadix -win $_nWave2 -format UDec
wvSetCursor -win $_nWave2 191.744536 -snap {("G2" 0)}
wvSetRadix -win $_nWave2 -Unsigned
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
debExit
