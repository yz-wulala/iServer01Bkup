verdiWindowResize -win $_Verdi_1 "0" "31" "1920" "971"
debImport "test.fsdb"
wvCreateWindow
wvSetPosition -win $_nWave2 {("G1" 0)}
wvOpenFile -win $_nWave2 {/home/stu02/project/N25Qx/test.fsdb}
verdiDockWidgetMaximize -dock windowDock_nWave_2
wvGetSignalOpen -win $_nWave2
wvGetSignalSetScope -win $_nWave2 "/test"
wvSetPosition -win $_nWave2 {("G1" 4)}
wvSetPosition -win $_nWave2 {("G1" 4)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/test/csn} \
{/test/din} \
{/test/dout} \
{/test/sclk} \
}
wvAddSignal -win $_nWave2 -group {"G2" \
}
wvSelectSignal -win $_nWave2 {( "G1" 1 2 3 4 )} 
wvSetPosition -win $_nWave2 {("G1" 4)}
wvGetSignalSetScope -win $_nWave2 "/test/X_0"
wvSetPosition -win $_nWave2 {("G1" 5)}
wvSetPosition -win $_nWave2 {("G1" 5)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/test/csn} \
{/test/din} \
{/test/dout} \
{/test/sclk} \
{/test/X_0/data\[7:0\]} \
}
wvAddSignal -win $_nWave2 -group {"G2" \
}
wvSelectSignal -win $_nWave2 {( "G1" 5 )} 
wvSetPosition -win $_nWave2 {("G1" 5)}
wvGetSignalClose -win $_nWave2
wvZoomAll -win $_nWave2
wvZoomAll -win $_nWave2
wvSetCursor -win $_nWave2 370136433.018983 -snap {("G2" 0)}
wvSelectSignal -win $_nWave2 {( "G1" 4 )} 
wvSetCursor -win $_nWave2 1323722550.887936 -snap {("G2" 0)}
wvZoom -win $_nWave2 1317820603.208818 1372624403.086344
wvSetCursor -win $_nWave2 1357622995.525664 -snap {("G1" 3)}
