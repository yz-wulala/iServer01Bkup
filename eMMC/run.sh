#! /usr/bin/bash
rm eMMC_Socket_tb.fsdb

vcs -R -full64 \
    -P $VERDI_LIB/novas.tab $VERDI_LIB/pli.a \
    crc7.v eMMC_Socket.v eMMC_Socket_tb.v
    

#Verdi eMMC_Socket_tb.fsdb
Verdi eMMC_Socket_tb.fsdb
