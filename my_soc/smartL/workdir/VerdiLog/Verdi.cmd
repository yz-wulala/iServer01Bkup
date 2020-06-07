debImport "vg_dump.fsdb"
wvCreateWindow
wvSetPosition -win $_nWave2 {("G1" 0)}
wvOpenFile -win $_nWave2 {/home/stu02/project/my_soc/smartL/workdir/vg_dump.fsdb}
verdiWindowResize -win $_Verdi_1 -3 "31" "1920" "971"
wvGetSignalOpen -win $_nWave2
wvGetSignalSetScope -win $_nWave2 "/ckcpu_lpmd_wait"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc/x_apb"
wvSetPosition -win $_nWave2 {("G1" 7)}
wvSetPosition -win $_nWave2 {("G1" 7)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/tb/x_soc/x_apb/apb_gpio_psel} \
{/tb/x_soc/x_apb/apb_xx_paddr\[31:0\]} \
{/tb/x_soc/x_apb/apb_xx_penable} \
{/tb/x_soc/x_apb/apb_xx_pwdata\[31:0\]} \
{/tb/x_soc/x_apb/apb_xx_pwrite} \
{/tb/x_soc/x_apb/gpio_apb_prdata\[31:0\]} \
{/tb/x_soc/x_apb/gpio_vic_int\[7:0\]} \
}
wvAddSignal -win $_nWave2 -group {"G2" \
}
wvSelectSignal -win $_nWave2 {( "G1" 1 2 3 4 5 6 7 )} 
wvSetPosition -win $_nWave2 {("G1" 7)}
wvGetSignalClose -win $_nWave2
wvGetSignalOpen -win $_nWave2
wvGetSignalSetScope -win $_nWave2 "/ckcpu_lpmd_wait"
wvGetSignalSetScope -win $_nWave2 "/tb"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc/x_apb"
wvGetSignalSetScope -win $_nWave2 "/tb/x_soc/x_cpu_sub_system_ahb"
wvSetPosition -win $_nWave2 {("G1" 8)}
wvSetPosition -win $_nWave2 {("G1" 8)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/tb/x_soc/x_apb/apb_gpio_psel} \
{/tb/x_soc/x_apb/apb_xx_paddr\[31:0\]} \
{/tb/x_soc/x_apb/apb_xx_penable} \
{/tb/x_soc/x_apb/apb_xx_pwdata\[31:0\]} \
{/tb/x_soc/x_apb/apb_xx_pwrite} \
{/tb/x_soc/x_apb/gpio_apb_prdata\[31:0\]} \
{/tb/x_soc/x_apb/gpio_vic_int\[7:0\]} \
{/tb/x_soc/x_cpu_sub_system_ahb/biu_pad_retire_pc\[31:0\]} \
}
wvAddSignal -win $_nWave2 -group {"G2" \
}
wvSelectSignal -win $_nWave2 {( "G1" 8 )} 
wvSetPosition -win $_nWave2 {("G1" 8)}
wvGetSignalClose -win $_nWave2
debExit
