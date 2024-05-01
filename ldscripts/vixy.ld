# CA65 configuration script for NROM 16K
# Based on Damian Yerrick's original script
# The original copyright information is reproduced at the bottom
# of this linker script.

MEMORY 
{
    # RAM
    ZEROPAGE:   start = 0, size=$100, file="";
    STACK:      start = $100, size=$100, file="";
    OAM:        start = $200, size=$100, file="";
    RAM:        start = $300, size=$500, file="";
    # ROM
    HEADER:     start = 0, size=$10, fill=yes, fillval=$FF;

    PRG:       start = $C000, size = $4000, type = ro, file = %O, fill=yes, fillval=$00;
    CHR:     start = $0000, size = $2000, type = ro, file = %O, fill=yes, fillval=$00;
}

SEGMENTS 
{
    ZEROPAGE:   load = ZEROPAGE, type=zp;
    RAM:        load = RAM, type=bss, define = yes, align = $100;

    HEADER:     load = HEADER;

    PRGROM:     load = PRG, type = ro, align = $100, optional = yes;
    VECTORS:    load = PRG, type = ro, start = $fffa;

    CHRROM:     load = CHR, type = ro, align = $100, optional = yes;
}

# Copyright 2010 Damian Yerrick
#
# Copying and distribution of this file, with or without
# modification, are permitted in any medium without royalty
# provided the copyright notice and this notice are preserved.
# This file is offered as-is, without any warranty.
#
