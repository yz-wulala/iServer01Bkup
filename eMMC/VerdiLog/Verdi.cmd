sidCmdLineBehaviorAnalysisOpt -incr -clockSkew 0 -loopUnroll 0 -bboxEmptyModule 0  -cellModel 0 -bboxIgnoreProtected 0 
verdiWindowResize -win $_Verdi_1 "0" "31" "1920" "971"
debImport "-f" "crc7.v" "eMMC_Socket.v" "eMMC_Socket_tb.v" "-top" \
          "eMMC_Socket_tb"
debLoadSimResult /home/stu02/project/eMMC/eMMC_Socket_tb.fsdb
wvCreateWindow
wvGetSignalOpen -win $_nWave2
wvGetSignalSetScope -win $_nWave2 "/eMMC_Socket_tb"
srcHBSelect "eMMC_Socket_tb.TRI" -win $_nTrace1
srcHBSelect "eMMC_Socket_tb.X0" -win $_nTrace1
srcHBSelect "eMMC_Socket_tb.X0" -win $_nTrace1
srcDeselectAll -win $_nTrace1
wvGetSignalOpen -win $_nWave2
wvSetPosition -win $_nWave2 {("G1" 9)}
wvSetPosition -win $_nWave2 {("G1" 9)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/eMMC_Socket_tb/cmd} \
{/eMMC_Socket_tb/cmd_argument_tb\[31:0\]} \
{/eMMC_Socket_tb/cmd_i_tb} \
{/eMMC_Socket_tb/cmd_index_tb\[5:0\]} \
{/eMMC_Socket_tb/cmd_o_tb} \
{/eMMC_Socket_tb/cmd_oe_tb} \
{/eMMC_Socket_tb/mclk_tb} \
{/eMMC_Socket_tb/rstn_tb} \
{/eMMC_Socket_tb/send_cmd_tb} \
}
wvAddSignal -win $_nWave2 -group {"G2" \
}
wvSelectSignal -win $_nWave2 {( "G1" 1 2 3 4 5 6 7 8 9 )} 
wvSetPosition -win $_nWave2 {("G1" 9)}
wvGetSignalClose -win $_nWave2
wvZoomAll -win $_nWave2
wvZoomAll -win $_nWave2
wvSelectGroup -win $_nWave2 {G2}
wvZoom -win $_nWave2 12.385040 2124.034335
wvGetSignalOpen -win $_nWave2
wvGetSignalSetScope -win $_nWave2 "/eMMC_Socket_tb"
wvGetSignalSetScope -win $_nWave2 "/eMMC_Socket_tb"
wvGetSignalSetScope -win $_nWave2 "/eMMC_Socket_tb/X0"
wvGetSignalSetScope -win $_nWave2 "/eMMC_Socket_tb/X0/X_TX_CRC"
wvSetPosition -win $_nWave2 {("G1" 11)}
wvSetPosition -win $_nWave2 {("G1" 11)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/eMMC_Socket_tb/cmd} \
{/eMMC_Socket_tb/cmd_argument_tb\[31:0\]} \
{/eMMC_Socket_tb/cmd_i_tb} \
{/eMMC_Socket_tb/cmd_index_tb\[5:0\]} \
{/eMMC_Socket_tb/cmd_o_tb} \
{/eMMC_Socket_tb/cmd_oe_tb} \
{/eMMC_Socket_tb/mclk_tb} \
{/eMMC_Socket_tb/rstn_tb} \
{/eMMC_Socket_tb/send_cmd_tb} \
{/eMMC_Socket_tb/X0/X_TX_CRC/crc7\[6:0\]} \
{/eMMC_Socket_tb/X0/X_TX_CRC/data_in} \
}
wvAddSignal -win $_nWave2 -group {"G2" \
}
wvSelectSignal -win $_nWave2 {( "G1" 10 11 )} 
wvSetPosition -win $_nWave2 {("G1" 11)}
wvGetSignalClose -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvGetSignalOpen -win $_nWave2
wvGetSignalSetScope -win $_nWave2 "/eMMC_Socket_tb"
wvGetSignalSetScope -win $_nWave2 "/eMMC_Socket_tb/X0"
wvGetSignalSetScope -win $_nWave2 "/eMMC_Socket_tb/X0/X_TX_CRC"
wvGetSignalSetScope -win $_nWave2 "/eMMC_Socket_tb/X0"
wvSetPosition -win $_nWave2 {("G1" 21)}
wvSetPosition -win $_nWave2 {("G1" 21)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/eMMC_Socket_tb/cmd} \
{/eMMC_Socket_tb/cmd_argument_tb\[31:0\]} \
{/eMMC_Socket_tb/cmd_i_tb} \
{/eMMC_Socket_tb/cmd_index_tb\[5:0\]} \
{/eMMC_Socket_tb/cmd_o_tb} \
{/eMMC_Socket_tb/cmd_oe_tb} \
{/eMMC_Socket_tb/mclk_tb} \
{/eMMC_Socket_tb/rstn_tb} \
{/eMMC_Socket_tb/send_cmd_tb} \
{/eMMC_Socket_tb/X0/X_TX_CRC/crc7\[6:0\]} \
{/eMMC_Socket_tb/X0/X_TX_CRC/data_in} \
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
}
wvAddSignal -win $_nWave2 -group {"G2" \
}
wvSelectSignal -win $_nWave2 {( "G1" 12 13 14 15 16 17 18 19 20 21 )} 
wvSetPosition -win $_nWave2 {("G1" 21)}
wvGetSignalClose -win $_nWave2
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
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
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomAll -win $_nWave2
wvZoom -win $_nWave2 5467.995095 5635.193133
wvZoomAll -win $_nWave2
debExit
