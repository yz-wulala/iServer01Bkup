verdiWindowResize -win $_Verdi_1 "0" "31" "1920" "971"
debImport "eMMC_Socket_tb.fsdb"
wvCreateWindow
wvSetPosition -win $_nWave2 {("G1" 0)}
wvOpenFile -win $_nWave2 {/home/stu02/project/eMMC/eMMC_Socket_tb.fsdb}
wvGetSignalOpen -win $_nWave2
wvGetSignalSetScope -win $_nWave2 "/eMMC_Socket_tb"
wvGetSignalSetScope -win $_nWave2 "/eMMC_Socket_tb/X0"
wvSetPosition -win $_nWave2 {("G1" 23)}
wvSetPosition -win $_nWave2 {("G1" 23)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/eMMC_Socket_tb/X0/cmd\[47:0\]} \
{/eMMC_Socket_tb/X0/cmd_argument\[31:0\]} \
{/eMMC_Socket_tb/X0/cmd_i} \
{/eMMC_Socket_tb/X0/cmd_index\[5:0\]} \
{/eMMC_Socket_tb/X0/cmd_o} \
{/eMMC_Socket_tb/X0/cmd_oe} \
{/eMMC_Socket_tb/X0/cmd_reg\[39:0\]} \
{/eMMC_Socket_tb/X0/crc7\[6:0\]} \
{/eMMC_Socket_tb/X0/cur_state\[3:0\]} \
{/eMMC_Socket_tb/X0/data_crc} \
{/eMMC_Socket_tb/X0/io_cmd} \
{/eMMC_Socket_tb/X0/long_resp} \
{/eMMC_Socket_tb/X0/mclk} \
{/eMMC_Socket_tb/X0/next_state\[3:0\]} \
{/eMMC_Socket_tb/X0/o_clk} \
{/eMMC_Socket_tb/X0/recv_cnt\[7:0\]} \
{/eMMC_Socket_tb/X0/recv_end} \
{/eMMC_Socket_tb/X0/resp_start} \
{/eMMC_Socket_tb/X0/rstn} \
{/eMMC_Socket_tb/X0/rstn_crc} \
{/eMMC_Socket_tb/X0/send_cmd} \
{/eMMC_Socket_tb/X0/send_cnt\[5:0\]} \
{/eMMC_Socket_tb/X0/send_end} \
}
wvAddSignal -win $_nWave2 -group {"G2" \
}
wvSelectSignal -win $_nWave2 {( "G1" 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 \
           18 19 20 21 22 23 )} 
wvSetPosition -win $_nWave2 {("G1" 23)}
wvGetSignalClose -win $_nWave2
verdiDockWidgetMaximize -dock windowDock_nWave_2
wvSetCursor -win $_nWave2 624.825261 -snap {("G2" 0)}
wvZoomOut -win $_nWave2
wvSelectGroup -win $_nWave2 {G2}
wvSelectSignal -win $_nWave2 {( "G1" 21 )} 
wvSelectSignal -win $_nWave2 {( "G1" 5 )} 
wvSelectSignal -win $_nWave2 {( "G1" 6 )} 
wvSetPosition -win $_nWave2 {("G1" 6)}
wvSetPosition -win $_nWave2 {("G1" 7)}
wvSetPosition -win $_nWave2 {("G1" 9)}
wvSetPosition -win $_nWave2 {("G1" 10)}
wvSetPosition -win $_nWave2 {("G1" 13)}
wvSetPosition -win $_nWave2 {("G1" 14)}
wvSetPosition -win $_nWave2 {("G1" 15)}
wvSetPosition -win $_nWave2 {("G1" 16)}
wvSetPosition -win $_nWave2 {("G1" 17)}
wvSetPosition -win $_nWave2 {("G1" 18)}
wvSetPosition -win $_nWave2 {("G1" 19)}
wvSetPosition -win $_nWave2 {("G1" 20)}
wvSetPosition -win $_nWave2 {("G1" 21)}
wvMoveSelected -win $_nWave2
wvSetPosition -win $_nWave2 {("G1" 21)}
wvSetCursor -win $_nWave2 1294.236665 -snap {("G2" 0)}
wvSelectSignal -win $_nWave2 {( "G1" 3 )} 
wvSelectSignal -win $_nWave2 {( "G1" 5 )} 
wvSetPosition -win $_nWave2 {("G1" 5)}
wvSetPosition -win $_nWave2 {("G1" 6)}
wvSetPosition -win $_nWave2 {("G1" 7)}
wvSetPosition -win $_nWave2 {("G1" 8)}
wvSetPosition -win $_nWave2 {("G1" 10)}
wvSetPosition -win $_nWave2 {("G1" 11)}
wvSetPosition -win $_nWave2 {("G1" 13)}
wvSetPosition -win $_nWave2 {("G1" 15)}
wvSetPosition -win $_nWave2 {("G1" 16)}
wvSetPosition -win $_nWave2 {("G1" 17)}
wvSetPosition -win $_nWave2 {("G1" 18)}
wvSetPosition -win $_nWave2 {("G1" 19)}
wvSetPosition -win $_nWave2 {("G1" 20)}
wvSetPosition -win $_nWave2 {("G1" 21)}
wvMoveSelected -win $_nWave2
wvSetPosition -win $_nWave2 {("G1" 21)}
wvSetCursor -win $_nWave2 1177.817290 -snap {("G2" 0)}
wvSetCursor -win $_nWave2 1352.446352 -snap {("G1" 22)}
wvSelectSignal -win $_nWave2 {( "G1" 22 )} 
wvSelectSignal -win $_nWave2 {( "G1" 22 )} 
wvSetRadix -win $_nWave2 -format UDec
wvSetCursor -win $_nWave2 1099.791539 -snap {("G2" 0)}
wvSelectSignal -win $_nWave2 {( "G1" 8 )} 
wvSelectSignal -win $_nWave2 {( "G1" 18 )} 
wvSetPosition -win $_nWave2 {("G1" 18)}
wvSetPosition -win $_nWave2 {("G1" 17)}
wvSetPosition -win $_nWave2 {("G1" 16)}
wvSetPosition -win $_nWave2 {("G1" 15)}
wvSetPosition -win $_nWave2 {("G1" 14)}
wvSetPosition -win $_nWave2 {("G1" 13)}
wvSetPosition -win $_nWave2 {("G1" 12)}
wvSetPosition -win $_nWave2 {("G1" 11)}
wvSetPosition -win $_nWave2 {("G1" 10)}
wvSetPosition -win $_nWave2 {("G1" 9)}
wvSetPosition -win $_nWave2 {("G1" 8)}
wvSetPosition -win $_nWave2 {("G1" 7)}
wvSetPosition -win $_nWave2 {("G1" 6)}
wvMoveSelected -win $_nWave2
wvSetPosition -win $_nWave2 {("G1" 6)}
wvSetPosition -win $_nWave2 {("G1" 7)}
wvSetPosition -win $_nWave2 {("G1" 12)}
wvSelectSignal -win $_nWave2 {( "G1" 12 )} 
wvSetPosition -win $_nWave2 {("G1" 11)}
wvSetPosition -win $_nWave2 {("G1" 10)}
wvSetPosition -win $_nWave2 {("G1" 9)}
wvSetPosition -win $_nWave2 {("G1" 8)}
wvSetPosition -win $_nWave2 {("G1" 7)}
wvMoveSelected -win $_nWave2
wvSetPosition -win $_nWave2 {("G1" 7)}
wvSetPosition -win $_nWave2 {("G1" 8)}
wvSetCursor -win $_nWave2 1013.096260 -snap {("G2" 0)}
wvSetCursor -win $_nWave2 1019.288780 -snap {("G2" 0)}
wvSetCursor -win $_nWave2 992.041692 -snap {("G1" 12)}
