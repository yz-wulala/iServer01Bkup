#! /usr/bin/bash

vcs -R -full64 \
    +v2k \
    -Mupdate \
    -sverilog \
    -debug_pp \
    +memcbk  \
    -P $VERDI_LIB/novas.tab $VERDI_LIB/pli.a \
    s25fl256s.v test.v