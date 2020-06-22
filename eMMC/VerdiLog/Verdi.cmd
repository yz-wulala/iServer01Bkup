sidCmdLineBehaviorAnalysisOpt -incr -clockSkew 0 -loopUnroll 0 -bboxEmptyModule 0  -cellModel 0 -bboxIgnoreProtected 0 
verdiWindowResize -win $_Verdi_1 "0" "31" "1920" "971"
debImport "-f" "crc7.v" "eMMC_Socket.v" "eMMC_Socket_tb.v" "-top" \
          "eMMC_Socket_tb"
debLoadSimResult /home/stu02/project/eMMC/eMMC_Socket_tb.fsdb
wvCreateWindow
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
wvSelectSignal -win $_nWave2 {( "G1" 12 )} 
wvSelectSignal -win $_nWave2 {( "G1" 12 )} 
wvSetCursor -win $_nWave2 3.715512 -snap {("G1" 12)}
srcActiveTrace "eMMC_Socket_tb.X0.io_cmd" -win $_nTrace1 -TraceByDConWave \
           -TraceTime 0 -TraceValue 1
nsMsgSelect -range {0 1-1}
nsMsgAction -tab trace -index {0 1}
nsMsgSwitchTab -tab general
nsMsgSwitchTab -tab cmpl
verdiDockWidgetHide -dock widgetDock_<Message>
verdiDockWidgetSetCurTab -dock windowDock_nWave_2
wvSelectSignal -win $_nWave2 {( "G1" 15 )} 
wvSelectSignal -win $_nWave2 {( "G1" 22 )} 
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
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
wvSetCursor -win $_nWave2 1099.791539 -snap {("G1" 11)}
wvSetCursor -win $_nWave2 837.228694 -snap {("G1" 10)}
wvSetCursor -win $_nWave2 673.746168 -snap {("G1" 10)}
wvSetCursor -win $_nWave2 1332.630288 -snap {("G1" 10)}
srcActiveTrace "eMMC_Socket_tb.X0.data_crc" -win $_nTrace1 -TraceByDConWave \
           -TraceTime 1320 -TraceValue 1
verdiDockWidgetSetCurTab -dock windowDock_nWave_2
wvSelectSignal -win $_nWave2 {( "G1" 8 )} 
wvSetCursor -win $_nWave2 455.769467 -snap {("G1" 8)}
wvSetCursor -win $_nWave2 1134.469651 -snap {("G1" 8)}
srcActiveTrace "eMMC_Socket_tb.X0.crc7\[6:0\]" -win $_nTrace1 -TraceByDConWave \
           -TraceTime 1110 -TraceValue 1111001
nsMsgSelect -range {2-2}
nsMsgSelect -range {0 1-1}
nsMsgAction -tab trace -index {0 1}
debExit
