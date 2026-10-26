# example.mk - an include for makefiles for UVVM examples

ifeq ($(REPO_ROOT),)
REPO_ROOT=$(shell git rev-parse --show-toplevel)
endif
DESIGN_NAME:=$(shell basename `dirname $(shell pwd)`)
DESIGN_PATH:=$(REPO_ROOT)/$(DESIGN_NAME)
WORK:=$(word 3,$(shell head -n 1 compile_order.txt))
SCRIPT_PATH:=$(DESIGN_PATH)/script
DUT_FILES:=$(shell tail -n +2 compile_order.txt)
TB_PATH:=$(DESIGN_PATH)/tb
TOP=$(notdir $(basename $(shell ls $(TB_PATH)/*tb.vhd)))
SRC=\
    $(addprefix $(SCRIPT_PATH)/, $(DUT_FILES)) \
    $(shell ls $(TB_PATH)/*th.vhd ls 2> /dev/null) \
    $(shell ls $(TB_PATH)/*tb.vhd)

VHDL_RELAXED=TRUE
#VHDL_SUPPRESS_IEEE_ASSERTS=TRUE
WAVE=wave.vcd
WAVE_LEVELS=0
WAVE_VIEW=TRUE

include $(REPO_ROOT)/script/multisim.mk
$(eval $(call COMPILE,$(WORK),$(SRC)))
$(eval $(call RUN,$(TOP),))
