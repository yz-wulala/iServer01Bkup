#! /usr/bin/bash
rm AD7091R_Socket_tb.fsdb

vcs -R -full64 \
    -P $VERDI_LIB/novas.tab $VERDI_LIB/pli.a \
    AD7091R_Socket.v AD7091R_Socket_tb.v
    

#Verdi WLL_FIFO_tb.fsdb
Verdi -f AD7091R_Socket.v AD7091R_Socket_tb.v -ssf AD7091R_Socket_tb.fsdb -top AD7091R_Socket_tb
