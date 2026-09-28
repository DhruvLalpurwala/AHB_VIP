seed ?= random
CURRENT_TIME := $(shell date "+%H_%M")
base := ahb_m_sequence
child ?= 
WAVE ?=

ifneq ($(child),)
    override += +uvm_set_type_override=$(base),$(child)
endif
 
INC = \
+incdir+../HVL_TOP \
+incdir+../Package 

SRC = \
../Package/ahb_pkg.sv \
../HVL_TOP/ahb_tb.sv
 
TB_TOP= tb
T_name= ahb_test

comp:
	@mkdir -p log
	@echo "//===Compilation Starts===/"
	vsimsa -l $(T_name)_$(seed)_$(CURRENT_TIME)_Comp.log -do "\
		vlib work;\
		vmap work work;\
		vlog -dbg -mfcu -uvmver 1800.2-2020 $(INC) $(SRC);\
		quit;\
	"		
	@echo "//===Compilation Completed===//"
	@mv $(T_name)_$(seed)_$(CURRENT_TIME)_Comp.log log
  
sim:comp
	@mkdir -p wave
	@echo "//===Simulation Starts===//"
	vsimsa -l $(T_name)_$(seed)_$(CURRENT_TIME)_Sim.log -do "\
		vsim -sv_seed $(seed) +access+r $(override) work.$(TB_TOP);\
		if{$(WAVE) == 1}{\
		vcd add wave -r sim:/$(TB_TOP)/*;}; run -all;\
		quit;\
	" 
	@echo "//===Simulation Ended===//"
	@mv $(T_name)_$(seed)_$(CURRENT_TIME)_Sim.log log
 
##wave:sim
##	@echo "//===================Waveform=================//"
##	gtkwave 

clean:
	@rm -rf log work wave
