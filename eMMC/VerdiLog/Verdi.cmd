verdiWindowResize -win $_Verdi_1 "0" "31" "1920" "971"
debImport "eMMC_Socket_tb.fsdb"
wvCreateWindow
wvSetPosition -win $_nWave2 {("G1" 0)}
wvOpenFile -win $_nWave2 {/home/stu02/project/eMMC/eMMC_Socket_tb.fsdb}
verdiDockWidgetMaximize -dock windowDock_nWave_2
wvGetSignalOpen -win $_nWave2
wvGetSignalSetScope -win $_nWave2 "/eMMC_Socket_tb"
wvGetSignalSetScope -win $_nWave2 "/eMMC_Socket_tb/X0"
wvSetPosition -win $_nWave2 {("G1" 28)}
wvSetPosition -win $_nWave2 {("G1" 28)}
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
{/eMMC_Socket_tb/X0/en_crc} \
{/eMMC_Socket_tb/X0/io_cmd} \
{/eMMC_Socket_tb/X0/long_resp} \
{/eMMC_Socket_tb/X0/mclk} \
{/eMMC_Socket_tb/X0/next_state\[3:0\]} \
{/eMMC_Socket_tb/X0/no_resp} \
{/eMMC_Socket_tb/X0/o_clk} \
{/eMMC_Socket_tb/X0/recv_cnt\[7:0\]} \
{/eMMC_Socket_tb/X0/recv_end} \
{/eMMC_Socket_tb/X0/recv_end_delay} \
{/eMMC_Socket_tb/X0/resp_reg\[135:0\]} \
{/eMMC_Socket_tb/X0/resp_reg_out\[135:0\]} \
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
           18 19 20 21 22 23 24 25 26 27 28 )} 
wvSetPosition -win $_nWave2 {("G1" 28)}
wvGetSignalClose -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvSetCursor -win $_nWave2 1501.066830 -snap {("G2" 0)}
wvSetCursor -win $_nWave2 1518.405886 -snap {("G2" 0)}
wvSelectGroup -win $_nWave2 {G2}
wvZoom -win $_nWave2 1709.135500 2707.369712
wvSelectSignal -win $_nWave2 {( "G1" 18 )} 
wvSelectSignal -win $_nWave2 {( "G1" 18 )} 
wvSetRadix -win $_nWave2 -format UDec
wvSelectGroup -win $_nWave2 {G2}
wvSetCursor -win $_nWave2 1748.917979 -snap {("G1" 18)}
wvSetCursor -win $_nWave2 1731.168873 -snap {("G1" 18)}
wvSetCursor -win $_nWave2 1731.168873 -snap {("G1" 14)}
wvSetCursor -win $_nWave2 1750.142055 -snap {("G1" 14)}
wvSetCursor -win $_nWave2 1731.780911 -snap {("G1" 14)}
