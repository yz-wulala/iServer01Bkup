verdiWindowResize -win $_Verdi_1 "0" "31" "1920" "971"
debImport "+v2k" "+incdir+./top+./stim+./code" "FM25Q08A_debug.fsdb"
wvCreateWindow
wvSetPosition -win $_nWave2 {("G1" 0)}
wvOpenFile -win $_nWave2 {/home/stu02/project/FM25Q08A/FM25Q08A_debug.fsdb}
wvGetSignalOpen -win $_nWave2
wvGetSignalSetScope -win $_nWave2 "/Testbench"
wvSetPosition -win $_nWave2 {("G1" 8)}
wvSetPosition -win $_nWave2 {("G1" 8)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/Testbench/CLK} \
{/Testbench/CS} \
{/Testbench/DI_DQ0} \
{/Testbench/DO_DQ1} \
{/Testbench/HOLD_DQ3} \
{/Testbench/VCC\[31:0\]} \
{/Testbench/WP_DQ2} \
{/Testbench/clock_active} \
}
wvAddSignal -win $_nWave2 -group {"G2" \
}
wvSelectSignal -win $_nWave2 {( "G1" 1 2 3 4 5 6 7 8 )} 
wvSetPosition -win $_nWave2 {("G1" 8)}
wvGetSignalClose -win $_nWave2
wvZoomAll -win $_nWave2
verdiDockWidgetMaximize -dock windowDock_nWave_2
wvSelectGroup -win $_nWave2 {G2}
wvSelectSignal -win $_nWave2 {( "G1" 8 )} 
wvSelectGroup -win $_nWave2 {G2}
wvSelectGroup -win $_nWave2 {G1}
wvGetSignalOpen -win $_nWave2
wvGetSignalSetScope -win $_nWave2 "/Testbench"
wvGetSignalSetScope -win $_nWave2 "/Testbench"
wvGetSignalSetScope -win $_nWave2 "/Testbench/DUT"
wvSelectSignal -win $_nWave2 {( "G1" 8 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G2" 0)}
wvSetPosition -win $_nWave2 {("G1" 7)}
wvZoomAll -win $_nWave2
wvZoom -win $_nWave2 99163954.658266 100865528.713412
wvZoom -win $_nWave2 99967505.225787 100050301.717553
wvZoom -win $_nWave2 100000251.935562 100024114.679913
wvZoomAll -win $_nWave2
wvZoom -win $_nWave2 148887729.825328 151156495.232190
wvZoom -win $_nWave2 150008666.944598 150075187.202940
wvZoom -win $_nWave2 150024228.452222 150033938.833040
wvZoomAll -win $_nWave2
wvZoom -win $_nWave2 98502231.414598 100960060.605365
wvZoom -win $_nWave2 99991034.998018 100024766.902071
wvZoom -win $_nWave2 100000125.567287 100023651.623888
wvZoomAll -win $_nWave2
wvZoom -win $_nWave2 148887729.825328 150872899.556332
wvZoom -win $_nWave2 150006013.210888 150061741.618807
wvZoom -win $_nWave2 150024751.583769 150033720.971943
debExit
