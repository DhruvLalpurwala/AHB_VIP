SEED ?= $(shell bash -c 'echo $$RANDOM')
CURRENT_TIME := $(shell date "+%H_%M")
BASE_SEQ ?= ahb_m_sequence
SEQ ?= ahb_m_sequence
WAVE ?= 0
MEM_FILE := memory_data.txt
NO_OF_TRANS ?= 20
PRELOAD_MEM ?= 0
WRITE ?= 1
BURST_OP ?= 0
SIZE ?= 2
VERBOSITY ?= 200

ARGS = $(override) \
       +NO_OF_TRANS=$(NO_OF_TRANS) \
       $(plusarg) \
       +WRITE=$(WRITE) \
       +BURST_OPERATION=$(BURST_OP) \
       +TRANSFER_SIZE=$(SIZE) \
       +UVM_VERBOSITY=$(VERBOSITY)

ifeq ($(PRELOAD_MEM),1)
   plusarg = +MEM_INIT_FILE=$(MEM_FILE)
endif

ifneq ($(SEQ),$(BASE_SEQ))
    override += +uvm_set_type_override=$(BASE_SEQ),$(SEQ)
endif

##ifeq ($(SEED),random)
  
##else
ACTUAL_SEED := $(SEED)
##endif

 
INC = \
+incdir+../Common/Global_Package \
+incdir+../Common/Package \
+incdir+../Common/HVL_TOP

SRC = \
../Common/Global_Package/ahb_global_pkg.sv \
../Common/Package/ahb_pkg.sv \
../Common/HVL_TOP/ahb_tb.sv
 
TB_TOP= tb
T_name= ahb_test

comp:
	@mkdir -p log
	@echo "//===Compilation Starts===/"
	@echo "ACTUAL SEED : $(ACTUAL_SEED)"
	@echo "SEED : $(SEED)"
	vsimsa -l $(SEQ)_$(ACTUAL_SEED)_$(CURRENT_TIME)_Comp.log -do "\
		vlib work;\
		vmap work work;\
		vlog -dbg -mfcu -uvmver 1800.2-2020 $(INC) $(SRC);\
		quit;\
	"		
	@echo "//===Compilation Completed===//"
	@mv $(SEQ)_$(ACTUAL_SEED)_$(CURRENT_TIME)_Comp.log log
  
sim:comp
	@mkdir -p wave
	@echo "//===Simulation Starts===//"
	vsimsa -l $(SEQ)_$(ACTUAL_SEED)_$(CURRENT_TIME)_Sim.log -do "\
		vsim -sv_seed $(ACTUAL_SEED) +access+r $(ARGS) work.$(TB_TOP);\
		if {$(WAVE)==1} {vcd add wave -r sim:/$(TB_TOP)/*};\
		run -all;\
		quit;\
	" 
	@echo "//===Simulation Ended===//"
	@mv $(SEQ)_$(ACTUAL_SEED)_$(CURRENT_TIME)_Sim.log log
	@echo "ACTUAL SEED : $(ACTUAL_SEED)"
	@echo "SEED : $(SEED)"
 
##wave:sim
##	@echo "//===================Waveform=================//"
##	gtkwave 

clean:
	@rm -rf log work wave

print:
	@echo "//===UVM Simulation Config===//"
	@echo "Seq Name : $(SEQ)"
	@echo "ACTUAL SEED : $(ACTUAL_SEED)"
	@echo "Command   : vsim -sv_seed $(ACTUAL_SEED) +access+r $(ARGS) work.$(TB_TOP)"

full_simulation:sim print

