#! /usr/bin/bash
rm WLL_FIFO_tb.fsdb

vcs -R -full64 \
    -P $VERDI_LIB/novas.tab $VERDI_LIB/pli.a \
    WLL_FIFO.v WLL_FIFO_tb.v
    

#Verdi WLL_FIFO_tb.fsdb
Verdi -f WLL_FIFO.v WLL_FIFO_tb.v -ssf WLL_FIFO_tb.fsdb -top WLL_FIFO_tb
