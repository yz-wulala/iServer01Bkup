debImport "vg_dump.fsdb"
wvCreateWindow
wvSetPosition -win $_nWave2 {("G1" 0)}
wvOpenFile -win $_nWave2 {/home/stu02/project/smartL/workdir/vg_dump.fsdb}
verdiWindowResize -win $_Verdi_1 -3 "31" "1920" "971"
wvGetSignalOpen -win $_nWave2
wvGetSignalSetScope -win $_nWave2 "/tb"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc"
wvSetPosition -win $_nWave2 {("G1" 1)}
wvSetPosition -win $_nWave2 {("G1" 1)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/tb/x_soc/biu_pad_lpmd_b\[1:0\]} \
}
wvAddSignal -win $_nWave2 -group {"G2" \
}
wvSelectSignal -win $_nWave2 {( "G1" 1 )} 
wvSetPosition -win $_nWave2 {("G1" 1)}
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc/x_apb"
wvSetPosition -win $_nWave2 {("G1" 7)}
wvSetPosition -win $_nWave2 {("G1" 7)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/tb/x_soc/biu_pad_lpmd_b\[1:0\]} \
{/tb/x_soc/x_apb/apb_pmu_psel} \
{/tb/x_soc/x_apb/apb_tim_psel} \
{/tb/x_soc/x_apb/apb_xx_paddr\[31:0\]} \
{/tb/x_soc/x_apb/apb_xx_penable} \
{/tb/x_soc/x_apb/apb_xx_pwdata\[31:0\]} \
{/tb/x_soc/x_apb/apb_xx_pwrite} \
}
wvAddSignal -win $_nWave2 -group {"G2" \
}
wvSelectSignal -win $_nWave2 {( "G1" 2 3 4 5 6 7 )} 
wvSetPosition -win $_nWave2 {("G1" 7)}
wvGetSignalClose -win $_nWave2
wvZoomAll -win $_nWave2
wvZoom -win $_nWave2 528382.668305 539057.065645
wvSelectGroup -win $_nWave2 {G2}
wvZoomAll -win $_nWave2
wvGetSignalOpen -win $_nWave2
wvGetSignalSetScope -win $_nWave2 "/tb"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc/x_apb"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc/x_apb/x_smpu_top"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc/x_apb/x_pmu"
wvSetPosition -win $_nWave2 {("G1" 8)}
wvSetPosition -win $_nWave2 {("G1" 8)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/tb/x_soc/biu_pad_lpmd_b\[1:0\]} \
{/tb/x_soc/x_apb/apb_pmu_psel} \
{/tb/x_soc/x_apb/apb_tim_psel} \
{/tb/x_soc/x_apb/apb_xx_paddr\[31:0\]} \
{/tb/x_soc/x_apb/apb_xx_penable} \
{/tb/x_soc/x_apb/apb_xx_pwdata\[31:0\]} \
{/tb/x_soc/x_apb/apb_xx_pwrite} \
{/tb/x_soc/x_apb/x_pmu/cur_state\[2:0\]} \
}
wvAddSignal -win $_nWave2 -group {"G2" \
}
wvSelectSignal -win $_nWave2 {( "G1" 8 )} 
wvSetPosition -win $_nWave2 {("G1" 8)}
wvGetSignalClose -win $_nWave2
wvZoom -win $_nWave2 529324.526894 541882.641411
wvGetSignalOpen -win $_nWave2
wvGetSignalSetScope -win $_nWave2 "/tb"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc/x_apb"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc/x_apb/x_pmu"
wvSetPosition -win $_nWave2 {("G1" 10)}
wvSetPosition -win $_nWave2 {("G1" 10)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/tb/x_soc/biu_pad_lpmd_b\[1:0\]} \
{/tb/x_soc/x_apb/apb_pmu_psel} \
{/tb/x_soc/x_apb/apb_tim_psel} \
{/tb/x_soc/x_apb/apb_xx_paddr\[31:0\]} \
{/tb/x_soc/x_apb/apb_xx_penable} \
{/tb/x_soc/x_apb/apb_xx_pwdata\[31:0\]} \
{/tb/x_soc/x_apb/apb_xx_pwrite} \
{/tb/x_soc/x_apb/x_pmu/cur_state\[2:0\]} \
{/tb/x_soc/x_apb/x_pmu/gate_en0} \
{/tb/x_soc/x_apb/x_pmu/gate_en1} \
}
wvAddSignal -win $_nWave2 -group {"G2" \
}
wvSelectSignal -win $_nWave2 {( "G1" 9 10 )} 
wvSetPosition -win $_nWave2 {("G1" 10)}
wvGetSignalClose -win $_nWave2
wvGetSignalOpen -win $_nWave2
wvGetSignalSetScope -win $_nWave2 "/tb"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc/x_apb"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc/x_apb/x_pmu"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc/x_apb/x_pmu"
wvSetPosition -win $_nWave2 {("G1" 11)}
wvSetPosition -win $_nWave2 {("G1" 11)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/tb/x_soc/biu_pad_lpmd_b\[1:0\]} \
{/tb/x_soc/x_apb/apb_pmu_psel} \
{/tb/x_soc/x_apb/apb_tim_psel} \
{/tb/x_soc/x_apb/apb_xx_paddr\[31:0\]} \
{/tb/x_soc/x_apb/apb_xx_penable} \
{/tb/x_soc/x_apb/apb_xx_pwdata\[31:0\]} \
{/tb/x_soc/x_apb/apb_xx_pwrite} \
{/tb/x_soc/x_apb/x_pmu/cur_state\[2:0\]} \
{/tb/x_soc/x_apb/x_pmu/gate_en0} \
{/tb/x_soc/x_apb/x_pmu/gate_en1} \
{/tb/x_soc/x_apb/x_pmu/intraw_vld} \
}
wvAddSignal -win $_nWave2 -group {"G2" \
}
wvSelectSignal -win $_nWave2 {( "G1" 11 )} 
wvSetPosition -win $_nWave2 {("G1" 11)}
wvGetSignalClose -win $_nWave2
wvGetSignalOpen -win $_nWave2
wvGetSignalSetScope -win $_nWave2 "/tb"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc/x_apb"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc/x_apb/x_pmu"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc/x_apb/x_pmu"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc/x_apb"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc/x_cpu_sub_system_ahb"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc/x_cpu_sub_system_ahb/x_ck802"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc/x_apb"
wvSetPosition -win $_nWave2 {("G1" 12)}
wvSetPosition -win $_nWave2 {("G1" 12)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/tb/x_soc/biu_pad_lpmd_b\[1:0\]} \
{/tb/x_soc/x_apb/apb_pmu_psel} \
{/tb/x_soc/x_apb/apb_tim_psel} \
{/tb/x_soc/x_apb/apb_xx_paddr\[31:0\]} \
{/tb/x_soc/x_apb/apb_xx_penable} \
{/tb/x_soc/x_apb/apb_xx_pwdata\[31:0\]} \
{/tb/x_soc/x_apb/apb_xx_pwrite} \
{/tb/x_soc/x_apb/x_pmu/cur_state\[2:0\]} \
{/tb/x_soc/x_apb/x_pmu/gate_en0} \
{/tb/x_soc/x_apb/x_pmu/gate_en1} \
{/tb/x_soc/x_apb/x_pmu/intraw_vld} \
{/tb/x_soc/x_apb/pad_vic_int_vld\[31:0\]} \
}
wvAddSignal -win $_nWave2 -group {"G2" \
}
wvSelectSignal -win $_nWave2 {( "G1" 12 )} 
wvSetPosition -win $_nWave2 {("G1" 12)}
wvGetSignalClose -win $_nWave2
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvSelectSignal -win $_nWave2 {( "G1" 12 )} 
wvExpandBus -win $_nWave2 {("G1" 12)}
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
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
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
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
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvSelectSignal -win $_nWave2 {( "G1" 12 )} 
wvSetPosition -win $_nWave2 {("G1" 12)}
wvCollapseBus -win $_nWave2 {("G1" 12)}
wvSetPosition -win $_nWave2 {("G1" 12)}
wvScrollUp -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvGetSignalOpen -win $_nWave2
wvGetSignalSetScope -win $_nWave2 "/tb"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc/x_cpu_sub_system_ahb"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc/x_apb"
wvSetPosition -win $_nWave2 {("G1" 13)}
wvSetPosition -win $_nWave2 {("G1" 13)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/tb/x_soc/biu_pad_lpmd_b\[1:0\]} \
{/tb/x_soc/x_apb/apb_pmu_psel} \
{/tb/x_soc/x_apb/apb_tim_psel} \
{/tb/x_soc/x_apb/apb_xx_paddr\[31:0\]} \
{/tb/x_soc/x_apb/apb_xx_penable} \
{/tb/x_soc/x_apb/apb_xx_pwdata\[31:0\]} \
{/tb/x_soc/x_apb/apb_xx_pwrite} \
{/tb/x_soc/x_apb/x_pmu/cur_state\[2:0\]} \
{/tb/x_soc/x_apb/x_pmu/gate_en0} \
{/tb/x_soc/x_apb/x_pmu/gate_en1} \
{/tb/x_soc/x_apb/x_pmu/intraw_vld} \
{/tb/x_soc/x_apb/pad_vic_int_vld\[31:0\]} \
{/tb/x_soc/x_apb/pad_clk} \
}
wvAddSignal -win $_nWave2 -group {"G2" \
}
wvSelectSignal -win $_nWave2 {( "G1" 13 )} 
wvSetPosition -win $_nWave2 {("G1" 13)}
wvGetSignalClose -win $_nWave2
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 1
wvZoom -win $_nWave2 534459.626352 535164.159093
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvGetSignalOpen -win $_nWave2
wvGetSignalSetScope -win $_nWave2 "/tb"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc/x_apb"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc/x_apb/x_pmu"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc/x_cpu_sub_system_ahb"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc/x_apb"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc/x_err_gen"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc/x_cpu_sub_system_ahb/x_ck802"
wvGetSignalSetSignalFilter -win $_nWave2 "*sys*"
wvSetPosition -win $_nWave2 {("G1" 19)}
wvSetPosition -win $_nWave2 {("G1" 19)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/tb/x_soc/biu_pad_lpmd_b\[1:0\]} \
{/tb/x_soc/x_apb/apb_pmu_psel} \
{/tb/x_soc/x_apb/apb_tim_psel} \
{/tb/x_soc/x_apb/apb_xx_paddr\[31:0\]} \
{/tb/x_soc/x_apb/apb_xx_penable} \
{/tb/x_soc/x_apb/apb_xx_pwdata\[31:0\]} \
{/tb/x_soc/x_apb/apb_xx_pwrite} \
{/tb/x_soc/x_apb/x_pmu/cur_state\[2:0\]} \
{/tb/x_soc/x_apb/x_pmu/gate_en0} \
{/tb/x_soc/x_apb/x_pmu/gate_en1} \
{/tb/x_soc/x_apb/x_pmu/intraw_vld} \
{/tb/x_soc/x_apb/pad_vic_int_vld\[31:0\]} \
{/tb/x_soc/x_apb/pad_clk} \
{/tb/x_soc/x_cpu_sub_system_ahb/x_ck802/pad_sysio_bigend_b} \
{/tb/x_soc/x_cpu_sub_system_ahb/x_ck802/pad_sysio_dbgrq_b} \
{/tb/x_soc/x_cpu_sub_system_ahb/x_ck802/pad_sysio_endian_v2} \
{/tb/x_soc/x_cpu_sub_system_ahb/x_ck802/sysio_had_sdb_req_b} \
{/tb/x_soc/x_cpu_sub_system_ahb/x_ck802/sysio_pad_idlyn_b} \
{/tb/x_soc/x_cpu_sub_system_ahb/x_ck802/sysio_pad_srst} \
}
wvAddSignal -win $_nWave2 -group {"G2" \
}
wvSelectSignal -win $_nWave2 {( "G1" 14 15 16 17 18 19 )} 
wvSetPosition -win $_nWave2 {("G1" 19)}
wvGetSignalClose -win $_nWave2
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
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
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G1" 13)}
wvSetCursor -win $_nWave2 534817.597441 -snap {("G1" 7)}
wvGetSignalOpen -win $_nWave2
wvGetSignalSetScope -win $_nWave2 "/tb"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc/x_apb"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc/x_apb/x_pmu"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc/x_cpu_sub_system_ahb"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc/x_cpu_sub_system_ahb/x_ck802"
wvGetSignalSetSignalFilter -win $_nWave2 "*intrw*"
wvGetSignalSetSignalFilter -win $_nWave2 "*int*"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc/x_cpu_sub_system_ahb"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc/x_cpu_sub_system_ahb/x_ck802"
wvGetSignalSetScope -win $_nWave2 "/tb"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc/x_cpu_sub_system_ahb"
wvGetSignalSetScope -win $_nWave2 \
           "/tb/x_soc/x_cpu_sub_system_ahb/x_iahb_mem_ctrl"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc/x_cpu_sub_system_ahb/x_ck802"
wvSetPosition -win $_nWave2 {("G1" 14)}
wvSetPosition -win $_nWave2 {("G1" 14)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/tb/x_soc/biu_pad_lpmd_b\[1:0\]} \
{/tb/x_soc/x_apb/apb_pmu_psel} \
{/tb/x_soc/x_apb/apb_tim_psel} \
{/tb/x_soc/x_apb/apb_xx_paddr\[31:0\]} \
{/tb/x_soc/x_apb/apb_xx_penable} \
{/tb/x_soc/x_apb/apb_xx_pwdata\[31:0\]} \
{/tb/x_soc/x_apb/apb_xx_pwrite} \
{/tb/x_soc/x_apb/x_pmu/cur_state\[2:0\]} \
{/tb/x_soc/x_apb/x_pmu/gate_en0} \
{/tb/x_soc/x_apb/x_pmu/gate_en1} \
{/tb/x_soc/x_apb/x_pmu/intraw_vld} \
{/tb/x_soc/x_apb/pad_vic_int_vld\[31:0\]} \
{/tb/x_soc/x_apb/pad_clk} \
{/tb/x_soc/x_cpu_sub_system_ahb/x_ck802/had_iu_int_vld} \
}
wvAddSignal -win $_nWave2 -group {"G2" \
}
wvSelectSignal -win $_nWave2 {( "G1" 14 )} 
wvSetPosition -win $_nWave2 {("G1" 14)}
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc/x_cpu_sub_system_ahb"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc/x_cpu_sub_system_ahb/x_ck802"
wvSetPosition -win $_nWave2 {("G1" 16)}
wvSetPosition -win $_nWave2 {("G1" 16)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/tb/x_soc/biu_pad_lpmd_b\[1:0\]} \
{/tb/x_soc/x_apb/apb_pmu_psel} \
{/tb/x_soc/x_apb/apb_tim_psel} \
{/tb/x_soc/x_apb/apb_xx_paddr\[31:0\]} \
{/tb/x_soc/x_apb/apb_xx_penable} \
{/tb/x_soc/x_apb/apb_xx_pwdata\[31:0\]} \
{/tb/x_soc/x_apb/apb_xx_pwrite} \
{/tb/x_soc/x_apb/x_pmu/cur_state\[2:0\]} \
{/tb/x_soc/x_apb/x_pmu/gate_en0} \
{/tb/x_soc/x_apb/x_pmu/gate_en1} \
{/tb/x_soc/x_apb/x_pmu/intraw_vld} \
{/tb/x_soc/x_apb/pad_vic_int_vld\[31:0\]} \
{/tb/x_soc/x_apb/pad_clk} \
{/tb/x_soc/x_cpu_sub_system_ahb/x_ck802/had_iu_int_vld} \
{/tb/x_soc/x_cpu_sub_system_ahb/x_ck802/pad_vic_int_cfg\[31:0\]} \
{/tb/x_soc/x_cpu_sub_system_ahb/x_ck802/pad_vic_int_vld\[31:0\]} \
}
wvAddSignal -win $_nWave2 -group {"G2" \
}
wvSelectSignal -win $_nWave2 {( "G1" 15 16 )} 
wvSetPosition -win $_nWave2 {("G1" 16)}
wvGetSignalClose -win $_nWave2
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvGetSignalOpen -win $_nWave2
wvGetSignalSetScope -win $_nWave2 "/tb"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc/x_cpu_sub_system_ahb"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc/x_cpu_sub_system_ahb/x_ck802"
wvGetSignalSetScope -win $_nWave2 \
           "/tb/x_soc/x_cpu_sub_system_ahb/x_ck802/x_nm_tcipif_top"
wvGetSignalSetScope -win $_nWave2 \
           "/tb/x_soc/x_cpu_sub_system_ahb/x_ck802/x_nm_tcipif_top/x_nm_intc_top"
wvGetSignalSetSignalFilter -win $_nWave2 "*int*"
wvGetSignalSetSignalFilter -win $_nWave2 "*"
wvGetSignalSetScope -win $_nWave2 \
           "/tb/x_soc/x_cpu_sub_system_ahb/x_ck802/x_nm_tcipif_top/x_nm_intc_top/x_nm_intc_arb"
wvSetPosition -win $_nWave2 {("G1" 17)}
wvSetPosition -win $_nWave2 {("G1" 17)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/tb/x_soc/biu_pad_lpmd_b\[1:0\]} \
{/tb/x_soc/x_apb/apb_pmu_psel} \
{/tb/x_soc/x_apb/apb_tim_psel} \
{/tb/x_soc/x_apb/apb_xx_paddr\[31:0\]} \
{/tb/x_soc/x_apb/apb_xx_penable} \
{/tb/x_soc/x_apb/apb_xx_pwdata\[31:0\]} \
{/tb/x_soc/x_apb/apb_xx_pwrite} \
{/tb/x_soc/x_apb/x_pmu/cur_state\[2:0\]} \
{/tb/x_soc/x_apb/x_pmu/gate_en0} \
{/tb/x_soc/x_apb/x_pmu/gate_en1} \
{/tb/x_soc/x_apb/x_pmu/intraw_vld} \
{/tb/x_soc/x_apb/pad_vic_int_vld\[31:0\]} \
{/tb/x_soc/x_apb/pad_clk} \
{/tb/x_soc/x_cpu_sub_system_ahb/x_ck802/had_iu_int_vld} \
{/tb/x_soc/x_cpu_sub_system_ahb/x_ck802/pad_vic_int_cfg\[31:0\]} \
{/tb/x_soc/x_cpu_sub_system_ahb/x_ck802/pad_vic_int_vld\[31:0\]} \
{/tb/x_soc/x_cpu_sub_system_ahb/x_ck802/x_nm_tcipif_top/x_nm_intc_top/x_nm_intc_arb/intraw_vld} \
}
wvAddSignal -win $_nWave2 -group {"G2" \
}
wvSelectSignal -win $_nWave2 {( "G1" 17 )} 
wvSetPosition -win $_nWave2 {("G1" 17)}
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvSetPosition -win $_nWave2 {("G1" 18)}
wvSetPosition -win $_nWave2 {("G1" 18)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/tb/x_soc/biu_pad_lpmd_b\[1:0\]} \
{/tb/x_soc/x_apb/apb_pmu_psel} \
{/tb/x_soc/x_apb/apb_tim_psel} \
{/tb/x_soc/x_apb/apb_xx_paddr\[31:0\]} \
{/tb/x_soc/x_apb/apb_xx_penable} \
{/tb/x_soc/x_apb/apb_xx_pwdata\[31:0\]} \
{/tb/x_soc/x_apb/apb_xx_pwrite} \
{/tb/x_soc/x_apb/x_pmu/cur_state\[2:0\]} \
{/tb/x_soc/x_apb/x_pmu/gate_en0} \
{/tb/x_soc/x_apb/x_pmu/gate_en1} \
{/tb/x_soc/x_apb/x_pmu/intraw_vld} \
{/tb/x_soc/x_apb/pad_vic_int_vld\[31:0\]} \
{/tb/x_soc/x_apb/pad_clk} \
{/tb/x_soc/x_cpu_sub_system_ahb/x_ck802/had_iu_int_vld} \
{/tb/x_soc/x_cpu_sub_system_ahb/x_ck802/pad_vic_int_cfg\[31:0\]} \
{/tb/x_soc/x_cpu_sub_system_ahb/x_ck802/pad_vic_int_vld\[31:0\]} \
{/tb/x_soc/x_cpu_sub_system_ahb/x_ck802/x_nm_tcipif_top/x_nm_intc_top/x_nm_intc_arb/intraw_vld} \
{/tb/x_soc/x_cpu_sub_system_ahb/x_ck802/x_nm_tcipif_top/x_nm_intc_top/x_nm_intc_arb/vic_pad_int_b} \
}
wvAddSignal -win $_nWave2 -group {"G2" \
}
wvSelectSignal -win $_nWave2 {( "G1" 18 )} 
wvSetPosition -win $_nWave2 {("G1" 18)}
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvSetPosition -win $_nWave2 {("G1" 19)}
wvSetPosition -win $_nWave2 {("G1" 19)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/tb/x_soc/biu_pad_lpmd_b\[1:0\]} \
{/tb/x_soc/x_apb/apb_pmu_psel} \
{/tb/x_soc/x_apb/apb_tim_psel} \
{/tb/x_soc/x_apb/apb_xx_paddr\[31:0\]} \
{/tb/x_soc/x_apb/apb_xx_penable} \
{/tb/x_soc/x_apb/apb_xx_pwdata\[31:0\]} \
{/tb/x_soc/x_apb/apb_xx_pwrite} \
{/tb/x_soc/x_apb/x_pmu/cur_state\[2:0\]} \
{/tb/x_soc/x_apb/x_pmu/gate_en0} \
{/tb/x_soc/x_apb/x_pmu/gate_en1} \
{/tb/x_soc/x_apb/x_pmu/intraw_vld} \
{/tb/x_soc/x_apb/pad_vic_int_vld\[31:0\]} \
{/tb/x_soc/x_apb/pad_clk} \
{/tb/x_soc/x_cpu_sub_system_ahb/x_ck802/had_iu_int_vld} \
{/tb/x_soc/x_cpu_sub_system_ahb/x_ck802/pad_vic_int_cfg\[31:0\]} \
{/tb/x_soc/x_cpu_sub_system_ahb/x_ck802/pad_vic_int_vld\[31:0\]} \
{/tb/x_soc/x_cpu_sub_system_ahb/x_ck802/x_nm_tcipif_top/x_nm_intc_top/x_nm_intc_arb/intraw_vld} \
{/tb/x_soc/x_cpu_sub_system_ahb/x_ck802/x_nm_tcipif_top/x_nm_intc_top/x_nm_intc_arb/vic_pad_int_b} \
{/tb/x_soc/x_cpu_sub_system_ahb/x_ck802/x_nm_tcipif_top/x_nm_intc_top/x_nm_intc_arb/intraw_req\[31:0\]} \
}
wvAddSignal -win $_nWave2 -group {"G2" \
}
wvSelectSignal -win $_nWave2 {( "G1" 19 )} 
wvSetPosition -win $_nWave2 {("G1" 19)}
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
debExit
