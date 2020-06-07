#Synopsys License
export SNPSLMD_LICENSE_FILE=27011@iServer01
#export SNPSLMD_LICENSE_FILE=27011@localhost
export LM_LICENSE_FILE="/root/synopsys/scl/license/synopsys.lic"

#verdi
alias verdi="/root/synopsys/verdi/Verdi_N-2017.12-SP2/bin/Verdi"
export VERDI_HOME="/root/synopsys/verdi/Verdi_N-2017.12-SP2"
export VERDI_LIB="/root/synopsys/verdi/Verdi_N-2017.12-SP2/share/PLI/VCS/LINUX64"
export LD_LIBRARY_PATH="/root/synopsys/verdi/Verdi_N-2017.12-SP2/share/PLI/lib/LINUX64"$PATH
export PATH="$VERDI_HOME/bin:$VERDI_HOME/platform/LINUX64/bin:$PATH"

# DC
export SYNOPSYS="/home/EDA/Synopsys/syn/L-2016.03-SP1"
export PATH=/home/EDA/Synopsys/syn/L-2016.03-SP1/bin:$PATH
alias dc_shell="/home/EDA/Synopsys/syn/L-2016.03-SP1/bin/dc_shell"
alias design_vision="/home/EDA/Synopsys/syn/L-2016.03-SP1/bin/design_vision"

# ICC
#icc_shell -gui
#start_gui
export PATH=/home/EDA/Synopsys/ICC/L-2016.03-SP1/bin:$PATH
alias icc_shell="/home/EDA/Synopsys/ICC/L-2016.03-SP1/bin/icc_shell"

# MilkyWay
export PATH=/home/EDA/Synopsys/mw/L-2016.03-SP1/bin:$PATH
alias Milkyway="/home/EDA/Synopsys/mw/L-2016.03-SP1/bin/linux64/Milkyway"

#PrimeTime
export PATH=/home/EDA/Synopsys/PT/M-2016.12-SP1/bin:$PATH
alias primetime="/home/EDA/Synopsys/PT/M-2016.12-SP1/bin/primetime"
alias pt_shell="/home/EDA/Synopsys/PT/M-2016.12-SP1/bin/pt_shell"

#vcs_mx
export VCS_ARCH_OVERRIDE=linux
export VCS_HOME="/root/synopsys/vcs-mx/N-2017.12-SP2"
export DVE_HOME="/root/synopsys/vcs-mx/N-2017.12-SP2/gui/dve"
export PATH=/root/synopsys/vcs-mx/N-2017.12-SP2/linux64/bin:$PATH
export fsdb_vcs_a=$VERDI_HOME/share/PLI/VCS/LINUX64/pli.a
export fsdb_vcs_tab=$VERDI_HOME/share/PLI/VCS/LINUX64/verdi.tab
alias vcs="/root/synopsys/vcs-mx/N-2017.12-SP2/bin/vcs"
alias dve="/root/synopsys/vcs-mx/N-2017.12-SP2/gui/dve/bin/dve"

#StarRC
export PATH=/home/EDA/Synopsys/StarRC/M-2016.12-SP2/bin:$PATH
#alias Milkyway="/home/EDA/Synopsys/StarRC/M-2016.12-SP2/bin/Milkyway"

#Library Compiler
export LC_HOME="/home/EDA/Synopsys/lc/M-2016.12"
export PATH=/home/EDA/Synopsys/lc/M-2016.12/bin:$PATH
