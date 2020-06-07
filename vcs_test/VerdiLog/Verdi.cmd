verdiWindowResize -win $_Verdi_1 "0" "31" "1920" "971"
debImport "cnter_tb.fsdb"
wvCreateWindow
wvSetPosition -win $_nWave2 {("G1" 0)}
wvOpenFile -win $_nWave2 {/home/stu02/project/vcs_test/cnter_tb.fsdb}
wvGetSignalOpen -win $_nWave2
wvGetSignalSetScope -win $_nWave2 "/cnter_tb"
wvGetSignalSetScope -win $_nWave2 "/cnter_tb/I0"
wvSetPosition -win $_nWave2 {("G1" 3)}
wvSetPosition -win $_nWave2 {("G1" 3)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/cnter_tb/I0/clk} \
{/cnter_tb/I0/ctr\[3:0\]} \
{/cnter_tb/I0/rst_n} \
}
wvAddSignal -win $_nWave2 -group {"G2" \
}
wvSelectSignal -win $_nWave2 {( "G1" 1 2 3 )} 
wvSetPosition -win $_nWave2 {("G1" 3)}
wvGetSignalClose -win $_nWave2
wvSelectGroup -win $_nWave2 {G2}
wvSetPosition -win $_nWave2 {("G1" 0)}
wvCollapseGroup -win $_nWave2 "G1"
wvSelectGroup -win $_nWave2 {G2}
wvSelectGroup -win $_nWave2 {G1}
wvExpandGroup -win $_nWave2 "G1"
wvSelectGroup -win $_nWave2 {G1}
wvSelectGroup -win $_nWave2 {G2}
wvSelectGroup -win $_nWave2 {G2}
wvSelectSignal -win $_nWave2 {( "G1" 1 )} 
wvSelectSignal -win $_nWave2 {( "G1" 1 )} 
wvSetCursor -win $_nWave2 1.604540 -snap {("G1" 1)}
wvSetCursor -win $_nWave2 5.379927 -snap {("G1" 1)}
wvSetCursor -win $_nWave2 15.195935 -snap {("G1" 1)}
verdiDockWidgetSetCurTab -dock widgetDock_<Decl._Tree>
verdiDockWidgetSetCurTab -dock widgetDock_<Inst._Tree>
wvCreateWindow
wvCloseWindow -win $_nWave3
debExit
