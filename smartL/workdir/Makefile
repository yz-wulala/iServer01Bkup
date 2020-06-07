# ****************************************************************************
# *                                                                          *
# * C-Sky Microsystems Confidential                                          *
# * -------------------------------                                          *
# * This file and all its contents are properties of C-Sky Microsystems. The *
# * information contained herein is confidential and proprietary and is not  *
# * to be disclosed outside of C-Sky Microsystems except under a             *
# * Non-Disclosure Agreement (NDA).                                          *
# *                                                                          *
# ****************************************************************************
#FILE NAME      : Makefile
#AUTHOR         : 
#FUNCTION       : the Makefile compile the test patterns  
#	          The flow of compilation:
#	        *.[c|asm]-> *.o->*.elf-> *.hex-> *.pat
#-------------------------------------------------------------------------
#
#-------------------------------------------------------------------
# the compiler toolset setting
#TOOL_PATH = /home/zhaok/toolchain/3.10.6
TOOL_EXTENSION	= ${TOOL_PATH}/bin/csky-abiv2-elf-
CC    = ${TOOL_EXTENSION}gcc
AS    = ${TOOL_EXTENSION}as
LINK  = ${TOOL_EXTENSION}ld
OBJDUMP = ${TOOL_EXTENSION}objdump
OBJCOPY = ${TOOL_EXTENSION}objcopy
CONVERT		=../tools/Srec2vmem

SSRC = $(wildcard *.S)
sSRC = $(wildcard *.s)
CSRC = $(wildcard *.c)

OBJECTS = $(SSRC:%.S=%.o) $(sSRC:%.s=%.o) $(CSRC:%.c=%.o)

#INCDIR = -I/tools/cskytools/csky-abiv2-elf-tools-x86_64-20130312/csky-abiv2-elf/include -I.

#DEFSYM = $(shell echo ${CPU} | sed 's/\(ck[0-9]\{3\}\).*/\1/')
DEFSYM = $(shell echo ${CPU} | sed 's/\(ck[0-9]\{3\}[s]*\).*/\1/')
CPU_F = $(shell echo ${CPU} | sed '/f/p')

#CFLAGS = -mno-high-registers -m${ENDIAN_MODE} -mcpu=${CPU} -Dstrcmp=__strcmp_fast -Dstrcpy=__strcpy_fast
#CFLAGS +=-D${DEFSYM} -Wa,--defsym=${DEFSYM}=1

ifeq ($(findstring f, ${CPU_F}), f)
  CFLAGS = -mno-high-registers -mhard-float -mfdivdu -m${ENDIAN_MODE} -mcpu=${CPU}
else
  CFLAGS = -mno-high-registers -m${ENDIAN_MODE} -mcpu=${CPU}
endif

CFLAGS +=-D${DEFSYM} -Wa,--defsym=${DEFSYM}=1
CFLAGS +=-mno-required-printf
ifeq ($(findstring yes, ${SIZE}), yes)
  CFLAGS += -Os
else
  CFLAGS += -O2
endif

LINKFLAGS = -mcpu=${CPU} -mstm -m${ENDIAN_MODE} -Tlinker.lcf -nostartfiles
ifeq ($(findstring f, ${CPU_F}), f)
  LINKFLAGS += -mhard-float
else
endif
ifeq ($(findstring ck802, ${CPU}), ck802)
  LINKLIBS  = -L${TOOL_PATH}/csky-abiv2-elf/lib/ck802
  LINKLIBS += -L${TOOL_PATH}/lib/gcc/csky-abiv2-elf/6.3.0/ck802
else
  ifeq ($(findstring ck801, ${CPU}), ck801)
    LINKLIBS  = -L${TOOL_PATH}/csky-abiv2-elf/lib/ck801
    LINKLIBS += -L${TOOL_PATH}/lib/gcc/csky-abiv2-elf/6.3.0/ck801
  else
    ifeq ($(findstring f, ${CPU_F}), f)
      LINKLIBS  = -L${TOOL_PATH}/csky-abiv2-elf/lib/ck803/hard-fp
      LINKLIBS += -L${TOOL_PATH}/lib/gcc/csky-elfabiv2/6.3.0/ck803/hard-fp
    else
      LINKLIBS  = -L${TOOL_PATH}/csky-abiv2-elf/lib/ck803
      LINKLIBS += -L${TOOL_PATH}/lib/gcc/csky-elfabiv2/6.3.0/ck803
    endif
  endif
endif

LINKLIBS += -lc -lgcc

OBJDUMPFLAGS = -S

HEXFLAGS	= -O srec

%.o : %.c
	${CC} -c ${CFLAGS} -o $@ $<

%.o : %.s
	${CC} -c ${CFLAGS} -o $@ $<

%.o : %.S
	${CC} -c ${CFLAGS} -o $@ $<

${FILE}.elf : ${OBJECTS} linker.lcf
	${CC} ${LINKFLAGS} ${LINKLIBS} ${OBJECTS} -o $@ -lm

${FILE}.obj : ${FILE}.elf
	${OBJDUMP} ${OBJDUMPFLAGS} $< > $@

INST_HEX = ${FILE}_inst.hex
DATA_HEX = ${FILE}_data.hex

${FILE}.hex : ${FILE}.elf
#	${OBJCOPY} ${HEXFLAGS} $< ${INST_HEX} -j .text -j .rodata -j .data
#	${OBJCOPY} ${HEXFLAGS} $< ${DATA_HEX} -j .data -j .bss
	${OBJCOPY} ${HEXFLAGS} $< ${INST_HEX} -j .text*
	${OBJCOPY} ${HEXFLAGS} $< ${DATA_HEX} -j .data -j .rodata -j .bss
	${OBJCOPY} ${HEXFLAGS} $< $@ 

INST_PAT = inst.pat
DATA_PAT = data.pat
FILE_PAT = case.pat

%.pat	: %.hex
	rm -f *.pat
	${CONVERT} ${INST_HEX} ${INST_PAT}
	${CONVERT} ${DATA_HEX} ${DATA_PAT}
	${CONVERT} ${FILE}.hex ${FILE_PAT}


#--------------------------------------------------------------------
# target setting
.PHONY :all
all : ${FILE}.pat ${FILE}.hex ${FILE}.elf ${FILE}.obj

#---------------------------------------------------------------------
# clean some medium code and .pat
.PHONY :clean 
clean:
	rm -rf *.o *.pat *.elf *.obj *.hex

