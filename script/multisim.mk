################################################################################
# multisim.mk - simple support for driving UVVM simulations from makefiles.
# Supported simulators: GHDL, NVC, ModelSim, Questa
# Assumes that UVVM libraries are precompiled!
# Supported platforms:
#	Linux
#	Windows MSYS2-MinGW64 shell (GHDL and NVC only)
#	Windows Command Prompt (with MSYS2 binaries including make itself in path)
# Include in your makefile before compile and simulate steps.
################################################################################
# check for supported simulator

SIM:=$(MAKECMDGOALS)
ifeq ($(filter $(SIM),ghdl nvc modelsim questa clean),)
INDENT:=$(subst ,,	)
all:
	$(info )
	$(info Please specify your chosen simulator after 'make' as follows:)
	$(info make <simulator>)
	$(info )
	$(info Supported options for <simulator>:)
	$(info $(INDENT)ghdl)
	$(info $(INDENT)nvc)
	$(info $(INDENT)questa)
	$(info $(INDENT)modelsim)
	$(info )
	$(error Unspecified or unsupported simulator)
endif

################################################################################
# global definitions

# wave init script, if not already defined
ifeq ($(WAVE_INIT),)
WAVE_INIT=$(REPO_ROOT)/script/vcd2gtkw.sh
endif

GTKW:=$(addsuffix .gtkw,$(basename $(WAVE)))

################################################################################
# MSYS2 definitions

ifeq ($(OS),Windows_NT)
# default location of MSYS2, if not already defined
ifeq ($(MSYS2),)
MSYS2:=C:\msys64
endif
MSYS2_MINGW64:=$(MSYS2)\mingw64
endif

################################################################################
# GHDL definitions

ifeq ($(SIM),ghdl)

# default GHDL installation path, if not already defined
ifeq ($(OS),Windows_NT)
ifeq ($(GHDL_INSTALL_PATH),)
GHDL_INSTALL_PATH:=$(MSYS2_MINGW64)
endif
else
GHDL_INSTALL_PATH:=/usr/local
endif

# precompiled vendor libraries, if not already defined
ifeq ($(GHDL_LIBS),)
GHDL_LIBS:=uvvm xilinx-vivado intel
endif

# GHDL executable
GHDL:=ghdl

#-P$(GHDL_INSTALL_PATH)/lib/ghdl

# GHDL options: analysis, elaboration, run
GHDL_AOPTS:=--std=08 -fsynopsys -Wno-hide -Wno-shared $(addprefix -P$(GHDL_INSTALL_PATH)/lib/ghdl/vendors/,$(GHDL_LIBS))
GHDL_EOPTS:=--std=08 -fsynopsys $(addprefix -P$(GHDL_INSTALL_PATH)/lib/ghdl/vendors/,$(GHDL_LIBS))
GHDL_ROPTS:=--unbuffered --max-stack-alloc=0 $(addprefix --vcd=,$(WAVE))
ifeq ($(VHDL_RELAXED),TRUE)
GHDL_AOPTS:=$(GHDL_AOPTS) -frelaxed
GHDL_EOPTS:=$(GHDL_EOPTS) -frelaxed
endif
ifeq ($(VHDL_SUPPRESS_IEEE_ASSERTS),TRUE)
GHDL_ROPTS:=$(GHDL_ROPTS) --ieee-asserts=disable
endif

# GHDL compilation command
define COMPILE_CMD
$1:
	$(GHDL) -a --work=$1 $(GHDL_AOPTS) $2
endef

# GHDL simulation command
define RUN_CMD
ghdl: $1
	$(GHDL) --elab-run --work=$1 $(GHDL_EOPTS) $2 $(GHDL_ROPTS) $(strip $(addprefix -g,$(subst ;, ,$3)))
ifneq ($(WAVE_LEVELS),)
	$(WAVE_INIT) $(WAVE) $(GTKW) $(WAVE_LEVELS)
endif
ifneq ($(WAVE_VIEW),)
	gtkwave $(WAVE) $(GTKW)
endif
endef

endif

################################################################################
# NVC definitions

ifeq ($(SIM),nvc)

# NVC executable
NVC:=nvc

# NVC options: global, analysis, elaboration, run
NVC_GOPTS:=--std=08
NVC_AOPTS:=
NVC_EOPTS:=
NVC_ROPTS:=$(addprefix --format=vcd --wave=,$(WAVE))
ifeq ($(VHDL_RELAXED),TRUE)
	NVC_AOPTS:=$(NVC_AOPTS) --relaxed
endif
ifeq ($(VHDL_SUPPRESS_IEEE_ASSERTS),TRUE)
	NVC_ROPTS:=$(NVC_ROPTS) --ieee-warnings=off
endif

# NVC compilation command
define COMPILE_CMD
$1:
	$(NVC) $(NVC_GOPTS) --work=$1 -a $(NVC_AOPTS) $2
endef

# NVC simulation command
define RUN_CMD
nvc: $1
	$(NVC) $(NVC_GOPTS) --work=$1 -e $2 $(NVC_EOPTS) $(strip $(addprefix -g,$(subst ;, ,$3)))
	$(NVC) $(NVC_GOPTS) --work=$1 -r $2 $(NVC_ROPTS)
ifneq ($(WAVE_LEVELS),)
	$(WAVE_INIT) $(WAVE) $(GTKW) $(WAVE_LEVELS)
endif
ifneq ($(WAVE_VIEW),)
	gtkwave $(WAVE) $(GTKW)
endif
endef

endif

################################################################################
# ModelSim/Questa definitions

ifneq ($(filter $(SIM),modelsim questa),)

# default path to user compiled libraries, if not already defined
ifeq ($(OS),Windows_NT)
ifeq ($(HOME),)
SIM_LIB_PATH:=/c/work/.simlib
else
SIM_LIB_PATH:=$(shell cygpath $(HOME))/.simlib
endif
else
SIM_LIB_PATH:=~/.simlib
endif

VMAP:=vmap
VCOM:=vcom
VCOMOPTS:=-2008 -explicit -vopt -stats=none
VSIM:=vsim
VSIMTCL:=onfinish exit; run -all; exit
ifeq ($(VHDL_SUPPRESS_IEEE_ASSERTS),TRUE)
VSIMTCL:=set NumericStdNoWarnings 1; $(VSIMTCL)
endif
ifneq ($(WAVE),)
VSIMTCL:=vcd file $(WAVE); vcd add -r *; $(VSIMTCL)
endif
VSIMOPTS:=-t ps -c -onfinish stop -do "$(VSIMTCL)"

modelsim.ini: $(SIM_LIB_PATH)/uvvm/*
	$(foreach L,$?,$(VMAP) $(notdir $L) $L;)

# ModelSim/Questa compilation command
define COMPILE_CMD
$1: | modelsim.ini
	$(VCOM) -work $1 $(VCOMOPTS) $2
endef

# ModelSim/Questa simulation command
define RUN_CMD
modelsim questa: $1
	$(VSIM) -work $1 $(VSIMOPTS) $2 $(strip $(addprefix -g,$(subst ;, ,$3)))
ifneq ($(WAVE_LEVELS),)
	$(WAVE_INIT) $(WAVE) $(GTKW) $(WAVE_LEVELS)
endif
ifneq ($(WAVE_VIEW),)
	gtkwave $(WAVE) $(GTKW)
endif
endef

endif

################################################################################
# functions to call simulator specific commands

# COMPILE: $1 = work library name, $2 = sources
define COMPILE
ifeq ($(WORK),)
WORK:=$1
endif
$(eval $(call COMPILE_CMD,$1,$2))
endef

# RUN: $1 = work library name, $2 = top unit name, $3 = runtime generics
# generics example:
#  MyIntVal=123;MyStrVal="hello"
define RUN
ifeq ($(TOP),)
TOP:=$(RUN_DEP)
endif
$(eval $(call RUN_CMD,$(WORK),$1,$2))
endef

################################################################################
# cleanup (user makefile may add more)

# UVVM
clean::
	rm -f $(wildcard _*.txt)

# waveforms
clean::
	rm -f $(wildcard *.vcd) $(wildcard *.gtkw)

# GHDL
clean::
	rm -f $(TOP) $(TOP).exe $(WORK)-obj08.cf $(wildcard *.o)

# NVC, ModelSim, Questa
clean::
	rm -rf $(WORK)

# ModelSim, Questa
clean::
	rm -f modelsim.ini transcript
