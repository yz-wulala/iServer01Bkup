#! /usr/bin/bash

vcs -R -full64 \
    +v2k \
    -Mupdate \
    -sverilog \
    -debug_pp \
    +memcbk  \
    -P $VERDI_LIB/novas.tab $VERDI_LIB/pli.a \
    N25Qxxx.v test.v