debImport "-f" "tb.filelist" "-sv" "+v2k"
verdiDockWidgetDisplay -dock widgetDock_WelcomePage
verdiDockWidgetHide -dock widgetDock_WelcomePage
nsMsgSelect -range {0 0-0}
nsMsgAction -tab cmpl -index {0 0}
nsMsgSelect -range {0 0-0}
srcDeselectAll -win $_nTrace1
srcSelect -word -line 71 -pos 7 -win $_nTrace1
srcAction -pos 71 7 2 -win $_nTrace1 -name "clk" -ctrlKey off
srcHBSelect "tb" -win $_nTrace1
srcSetScope -win $_nTrace1 "tb" -delim "."
srcHBSelect "tb.x_soc" -win $_nTrace1
srcSetScope -win $_nTrace1 "tb.x_soc" -delim "."
srcHBSelect "tb" -win $_nTrace1
srcSetScope -win $_nTrace1 "tb" -delim "."
nsMsgSwitchTab -tab general
srcHBSelect "tb.x_soc.x_cpu_sub_system_ahb" -win $_nTrace1
srcSetScope -win $_nTrace1 "tb.x_soc.x_cpu_sub_system_ahb" -delim "."
srcHBSelect "tb.x_soc.x_cpu_sub_system_ahb.x_ck802" -win $_nTrace1
srcSetScope -win $_nTrace1 "tb.x_soc.x_cpu_sub_system_ahb.x_ck802" -delim "."
srcHBSelect "tb" -win $_nTrace1
srcSetScope -win $_nTrace1 "tb" -delim "."
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -win $_nTrace1 -range {397 398 4 3 1 4}
srcDeselectAll -win $_nTrace1
srcHBSelect "tb.x_soc.x_cpu_sub_system_ahb.x_ck802.x_nm_tcipif_top" -win \
           $_nTrace1
srcSetScope -win $_nTrace1 \
           "tb.x_soc.x_cpu_sub_system_ahb.x_ck802.x_nm_tcipif_top" -delim "."
srcHBSelect \
           "tb.x_soc.x_cpu_sub_system_ahb.x_ck802.x_nm_tcipif_top.x_nm_tcipif_dbus" \
           -win $_nTrace1
srcSetScope -win $_nTrace1 \
           "tb.x_soc.x_cpu_sub_system_ahb.x_ck802.x_nm_tcipif_top.x_nm_tcipif_dbus" \
           -delim "."
srcDeselectAll -win $_nTrace1
srcSelect -signal "tcipif_bmu_dbus_trans_cmplt" -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "tcipif_bmu_dbus_trans_cmplt" -win $_nTrace1
srcAction -pos 44774 1 20 -win $_nTrace1 -name "tcipif_bmu_dbus_trans_cmplt" \
          -ctrlKey off
srcDeselectAll -win $_nTrace1
srcSelect -signal "cpurst_b" -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "IIOOOIOOOOOO" -win $_nTrace1
srcCopySignalFullPath -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "IIOOOIOIIIII\[31:0\]" -win $_nTrace1
srcCopySignalFullPath -win $_nTrace1
srcHBSelect "tb.x_soc.x_cpu_sub_system_ahb.x_ck802.x_nm_core_top" -win $_nTrace1
srcSetScope -win $_nTrace1 "tb.x_soc.x_cpu_sub_system_ahb.x_ck802.x_nm_core_top" \
           -delim "."
srcHBSelect "tb.x_soc.x_cpu_sub_system_ahb.x_ck802.x_nm_core_top.x_nm_core" -win \
           $_nTrace1
srcSetScope -win $_nTrace1 \
           "tb.x_soc.x_cpu_sub_system_ahb.x_ck802.x_nm_core_top.x_nm_core" \
           -delim "."
srcHBSelect \
           "tb.x_soc.x_cpu_sub_system_ahb.x_ck802.x_nm_core_top.x_nm_core.x_nm_cp0_top" \
           -win $_nTrace1
srcSetScope -win $_nTrace1 \
           "tb.x_soc.x_cpu_sub_system_ahb.x_ck802.x_nm_core_top.x_nm_core.x_nm_cp0_top" \
           -delim "."
srcHBSelect \
           "tb.x_soc.x_cpu_sub_system_ahb.x_ck802.x_nm_core_top.x_nm_core.x_nm_cp0_top.x_nm_cp0_lpmd" \
           -win $_nTrace1
srcSetScope -win $_nTrace1 \
           "tb.x_soc.x_cpu_sub_system_ahb.x_ck802.x_nm_core_top.x_nm_core.x_nm_cp0_top.x_nm_cp0_lpmd" \
           -delim "."
srcDeselectAll -win $_nTrace1
srcGotoLine -win $_nTrace1 6341
srcDeselectAll -win $_nTrace1
srcSelect -signal "had_yy_xx_dbg" -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "IIOOOOIOOIOOOOOOI\[1:0\]" -win $_nTrace1
srcCopySignalFullPath -win $_nTrace1
debExit
