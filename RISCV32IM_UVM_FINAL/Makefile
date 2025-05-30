seed = 20
UVM_VERBOSITY =	UVM_LOW
Risc_pkg= RI5CY-master/rtl/package/cv32e40p_pkg.sv RI5CY-master/rtl/package/cv32e40p_apu_core_pkg.sv RI5CY-master/rtl/package/cv32e40p_fpu_pkg.sv
Interface= config_interface.sv interrupt_interface.sv debug_interface.sv instr_Interface.sv data_interface.sv alu_div_interface.sv regfile_interface.sv mult_interface.sv

Core= -f RI5CY-master/core.flist.f
Sources = risc_pkg.sv 
Top=testbensh_top.sv
DESIGN_RTL_DIR=RI5CY-master/rtl
Test=load_store_test
# Tests names:   base_test corner_cases_test mult_div_test regfile_test hazard_test branch_test load_store_test
#-------------------
all: compile test 
#------------------
test_all: clean base_test corner_test mult_div_test hazard_test reg_test branch_test load_store_test coverage_merge  all_coverage 
#-------------------------------------------------------------------------------------------------------
compile	:
	vcs -sverilog -ntb_opts uvm-1.2 $(Risc_pkg) $(Core)   $(Interface)  $(Sources) $(Top) -cm line+fsm+tgl+branch+cond -timescale=1ns/1ns +vcs+flush+all -full64 +vc -o base_sim  -q +v2k -debug_access+all -l vcs_out.log 
#-------------------------------------------------------------------------------------------------------
test :
	./base_sim -l base_sim.log +ntb_random_seed=$(seed) +UVM_VERBOSITY=$(UVM_VERBOSITY) +UVM_TESTNAME=$(Test)  -cm line+cond+tgl+fsm+branch   
#-------------------------------------------------------------------------------------------------------
open :
	@echo "Opening with Gedit..."
	gedit *.sv files.f Makefile &
#-------------------------------------------------------------------------------------------------------
load_store_test : 
		vcs -sverilog -ntb_opts uvm-1.2 $(Risc_pkg) $(Core)   $(Interface)  $(Sources) $(Top) -cm line+fsm+tgl+branch+cond -timescale=1ns/1ns +vcs+flush+all -full64 +vc -o load_store_sim -cm_dir ./load_store -q +v2k -debug_access+all -l vcs_out.log 
		./load_store_sim -l load_store_sim.log +ntb_random_seed=1490 +UVM_VERBOSITY=$(UVM_VERBOSITY) +UVM_TESTNAME=load_store_test  -cm line+cond+tgl+fsm+branch 
#-------------------------------------------------------------------------------------------------------
base_test : 
		vcs -sverilog -ntb_opts uvm-1.2 $(Risc_pkg) $(Core)   $(Interface)  $(Sources) $(Top) -cm line+fsm+tgl+branch+cond -timescale=1ns/1ns +vcs+flush+all -full64 +vc -o base_sim -cm_dir ./base -q +v2k -debug_access+all -l vcs_out.log 
		./base_sim -l base_sim.log +ntb_random_seed=1490 +UVM_VERBOSITY=$(UVM_VERBOSITY) +UVM_TESTNAME=base_test  -cm line+cond+tgl+fsm+branch 
#---------
corner_test : 
		vcs -sverilog -ntb_opts uvm-1.2 $(Risc_pkg) $(Core)   $(Interface)  $(Sources) $(Top) -cm line+fsm+tgl+branch+cond -timescale=1ns/1ns +vcs+flush+all -full64 +vc -o corner_sim -cm_dir ./cov_corner -q +v2k -debug_access+all -l vcs_out.log 
		./corner_sim -l corner_sim.log +ntb_random_seed=6619 +UVM_VERBOSITY=$(UVM_VERBOSITY) +UVM_TESTNAME=corner_cases_test  -cm line+cond+tgl+fsm+branch 
#---------
mult_div_test :
		vcs -sverilog -ntb_opts uvm-1.2 $(Risc_pkg) $(Core)   $(Interface)  $(Sources) $(Top) -cm line+fsm+tgl+branch+cond -timescale=1ns/1ns +vcs+flush+all -full64 +vc -o mult_div_sim -cm_dir ./mul_div -q +v2k -debug_access+all -l vcs_out.log 
		./mult_div_sim -l mult_sim.log +ntb_random_seed=4161 +UVM_VERBOSITY=$(UVM_VERBOSITY) +UVM_TESTNAME=mult_div_test  -cm line+cond+tgl+fsm+branch 
#---------
hazard_test : 
		vcs -sverilog -ntb_opts uvm-1.2 $(Risc_pkg) $(Core)   $(Interface)  $(Sources) $(Top) -cm line+fsm+tgl+branch+cond -timescale=1ns/1ns +vcs+flush+all -full64 +vc -o hazard_sim -cm_dir ./hazard -q +v2k -debug_access+all -l vcs_out.log 
		./hazard_sim -l hazard_sim.log +ntb_random_seed=1036820 +UVM_VERBOSITY=$(UVM_VERBOSITY) +UVM_TESTNAME=hazard_test  -cm line+cond+tgl+fsm+branch 
#---------
reg_test : 
		vcs -sverilog -ntb_opts uvm-1.2 $(Risc_pkg) $(Core)   $(Interface)  $(Sources) $(Top) -cm line+fsm+tgl+branch+cond -timescale=1ns/1ns +vcs+flush+all -full64 +vc -o reg_sim -cm_dir ./reg -q +v2k -debug_access+all -l vcs_out.log 
		./reg_sim -l reg_sim.log +ntb_random_seed=459172 +UVM_VERBOSITY=$(UVM_VERBOSITY) +UVM_TESTNAME=regfile_test  -cm line+cond+tgl+fsm+branch 
#---------
branch_test : 
		vcs -sverilog -ntb_opts uvm-1.2 $(Risc_pkg) $(Core)   $(Interface)  $(Sources) $(Top) -cm line+fsm+tgl+branch+cond -timescale=1ns/1ns +vcs+flush+all -full64 +vc -o branch_sim -cm_dir ./branch -q +v2k -debug_access+all -l vcs_out.log 
		./branch_sim -l branch_sim.log +ntb_random_seed=20 +UVM_VERBOSITY=$(UVM_VERBOSITY) +UVM_TESTNAME=branch_test  -cm line+cond+tgl+fsm+branch 
#coverage report for the mergesd
coverage_merge :
	@echo "Running coverage reports..."
	urg  -dir base -dir cov_corner -dir mul_div -dir hazard -dir reg -dir branch -dir load_store -dbname merged_cov_db -format both
#coverage
all_coverage:
	@echo "Running coverage..."
	dve -cov -dir merged_cov_db.vdb   &
#-------------------------------------------------------------------------------------------------------	
#coverage
coverage:
	@echo "Running coverage..."
	dve -cov -dir base_sim.vdb   &
clean  :
	 rm  -rf  *~  csrc  simv*  vc_hdrs.h  ucli.key *.log  novas.* *.fsdb* verdiLog  64* DVEfiles *.vcd *.vdb *.daidir *_sim
