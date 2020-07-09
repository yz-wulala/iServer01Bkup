#! /usr/bin/bash
rm crc4_tb.fsdb

vcs -R -full64 \
    -P $VERDI_LIB/novas.tab $VERDI_LIB/pli.a \
    crc4.v crc4_tb.v
    

#Verdi eMMC_Socket_tb.fsdb
Verdi -f crc4.v crc4_tb.v -ssf crc4_tb.fsdb -top crc4_tb
