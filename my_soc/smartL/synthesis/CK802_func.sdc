

# user define
set overcon 1.0
set margin 0.1
set clockperiod [expr 1000.00/50]
set vclkperiod  [expr 1000.00/25]
set MaxTrans 0.6
set MaxFanout 35
#set DRVGCELL "BUFFD2BWP"
#set LOADPIN "tcbn40lpbwpwcl_ccs/ND2D1BWP/A1"
set DRVGCELL ""
set LOADPIN  ""
##########
create_clock -name CPU_CLK -per [expr $clockperiod] [get_ports pll_core_cpuclk]
set_clock_uncertainty -setup [expr $clockperiod*$margin] [get_clocks CPU_CLK]
create_clock -name JTAG_CLK -per [expr 2*$clockperiod] [get_ports pad_had_jtg_tclk]
set_clock_uncertainty -setup [expr 2*$clockperiod*$margin] [get_clocks JTAG_CLK]

#create_clock -name VCLK -per [expr $clockperiod]
create_clock -name VCLK -per [expr $vclkperiod]
set_clock_uncertainty -setup [expr $vclkperiod*$margin] [get_clocks VCLK]

set_clock_uncertainty -hold 0.1 [all_clocks]
set_clock_transition 0.25 [remove_from_collection [all_clocks] [get_clocks VCLK]]
set_dont_touch_network [all_clocks]

set_max_transition $MaxTrans [current_design]
set_max_fanout $MaxFanout [current_design]

set ALLINSBUTCLK [remove_from_collection [all_inputs] [get_ports "pll_core_cpuclk pad_had_jtg_tclk"]]
############# all input sys clk
set_input_delay  -clock VCLK [expr 0.20 * $clockperiod] $ALLINSBUTCLK
############# all output sys clk
set_output_delay -clock VCLK [expr 0.30 * $vclkperiod] [all_outputs]

set_input_delay -clock JTAG_CLK [expr 0.30 * $clockperiod*2] [get_ports "pad_had_jtg_trst_b"]

############# clk enable in cpuclk domain
#clk_en
set_input_delay  -clock CPU_CLK [expr 0.30 * $clockperiod] [get_ports "clk_en"                      ] 

set_output_delay -clock CPU_CLK [expr 0.20 * $clockperiod] [get_ports dahbl_pad_*                   ]
set_input_delay  -clock CPU_CLK [expr 0.30 * $clockperiod] [get_ports pad_dahbl*                    ]
set_output_delay -clock CPU_CLK [expr 0.20 * $clockperiod] [get_ports iahbl_pad_*                   ]
set_input_delay  -clock CPU_CLK [expr 0.30 * $clockperiod] [get_ports pad_iahbl*                    ]
# constant in 1:1
#set_input_delay  -clock CPU_CLK [expr 0.30 * $clockperiod] [get_ports "iahbl_clk_en"                ] 
# constant in 1:1
#set_input_delay  -clock CPU_CLK [expr 0.30 * $clockperiod] [get_ports "dahbl_clk_en"                ] 

# constant
set_input_delay  -clock CPU_CLK [expr 0.10 * $clockperiod] [get_ports pad_bmu_*base                 ] 
# constant
set_input_delay  -clock CPU_CLK [expr 0.10 * $clockperiod] [get_ports pad_bmu_*mask                 ]

############## ctim
set_input_delay  -clock CPU_CLK [expr 0.30 * $clockperiod] [get_ports "pad_ctim_calib"              ]
###### refclk
#set_input_delay  -clock CPU_CLK [expr 0.30 * $clockperiod] [get_ports "pad_ctim_refclk"            ]

############## had & jtag
set_output_delay -clock JTAG_CLK [expr 0.30 * $clockperiod*2] [get_ports had_pad_*                  ]
set_input_delay  -clock JTAG_CLK [expr 0.30 * $clockperiod*2] [get_ports pad_had_*                  ]
set_output_delay -clock CPU_CLK [expr 0.30 * $clockperiod] [get_ports "had_pad_jtg_tap_on"          ]
set_output_delay -clock CPU_CLK [expr 0.30 * $clockperiod] [get_ports "had_pad_jdb_pm"              ]
set_input_delay  -clock CPU_CLK [expr 0.30 * $clockperiod] [get_ports "pad_had_jdb_req_b"           ]

# constant
set_input_delay  -clock CPU_CLK [expr 0.30 * $clockperiod] [get_ports "pad_sysio_bigend_b"          ] 
set_input_delay  -clock CPU_CLK [expr 0.30 * $clockperiod] [get_ports "pad_sysio_clkratio"          ]

############## intc
set_output_delay -clock CPU_CLK [expr 0.30 * $clockperiod] [get_ports ctim_pad_int_vld*             ]
set_input_delay  -clock CPU_CLK [expr 0.30 * $clockperiod] [get_ports "pad_vic_int_cfg"             ]
set_input_delay  -clock CPU_CLK [expr 0.30 * $clockperiod] [get_ports "pad_vic_int_vld"             ]
# constant
set_input_delay  -clock CPU_CLK [expr 0.30 * $clockperiod] [get_ports "pad_yy_gate_clk_en_b"        ] 

############## bist
#set_output_delay -clock JTAG_CLK [expr 0.30 * $clockperiod*2] [get_ports *_smbist_done*]  
#set_output_delay -clock JTAG_CLK [expr 0.30 * $clockperiod*2] [get_ports *_smbist_fail*]  

############## debug signal
set_output_delay -clock VCLK     [expr 0.01 * $clockperiod] [get_ports cp0_pad_*                    ]

############## DFT scan in/output

set_load [expr [load_of $LOADPIN]*5.0] $ALLINSBUTCLK
set_port_fanout_number 3 $ALLINSBUTCLK
set_driving_cell -lib_cell $DRVGCELL $ALLINSBUTCLK
set_load [expr [load_of $LOADPIN]*5.0] [all_outputs]
set_port_fanout_number 4 [all_outputs]

set_ideal_network [get_ports "pll_core_cpuclk pad_had_jtg_tclk"]
#set_ideal_network [get_pins -of [get_cells -hie "*x_gated_clk_cell"] -filter "@pin_direction==out"]

set_clock_groups -async -group {CPU_CLK} -group {JTAG_CLK}
set_multicycle_path -setup 2 -from [get_clock CPU_CLK] -to [get_clock VCLK] -start
set_multicycle_path -hold  1 -from [get_clock CPU_CLK] -to [get_clock VCLK] -start
set_multicycle_path -setup 2 -from [get_clock VCLK] -to [get_clock CPU_CLK] -end
set_multicycle_path -hold  1 -from [get_clock VCLK] -to [get_clock CPU_CLK] -end
set_multicycle_path -setup 2 -from [get_clock JTAG_CLK] -to [get_clock VCLK] -start
set_multicycle_path -hold  1 -from [get_clock JTAG_CLK] -to [get_clock VCLK] -start
set_multicycle_path -setup 2 -from [get_clock VCLK] -to [get_clock JTAG_CLK] -end
set_multicycle_path -hold  1 -from [get_clock VCLK] -to [get_clock JTAG_CLK] -end


#set_multicycle_path -setup 2 -to [get_ports "rtu_pad_*" -filter "@pin_direction==out"]
#set_multicycle_path -hold  1 -to [get_ports "rtu_pad_*" -filter "@pin_direction==out"]
set_multicycle_path -setup 3 -from pad_yy_test_mode -to [all_clocks]
set_multicycle_path -hold  2 -from pad_yy_test_mode -to [all_clocks]

