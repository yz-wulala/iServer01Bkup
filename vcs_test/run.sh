#! /usr/bin/bash

vcs -R -full64 \
    -P $VERDI_LIB/novas.tab $VERDI_LIB/pli.a \
    cnter.v cnter_tb.v
