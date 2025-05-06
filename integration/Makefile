#-------------------------------------------------------------------------------------------------------
compile	:
	vcs -sverilog -ntb_opts uvm-1.2 -f files.f -cm line+fsm+tgl+branch+cond -timescale=1ns/1ps +vcs+flush+all -full64  +vc -o base_sim -q +v2k  -fsdb -debug_all -l vcs_out.log
#-------------------------------------------------------------------------------------------------------

clean  :
	 rm  -rf  *~  csrc  simv*  vc_hdrs.h  ucli.key *.log  novas.* *.fsdb* verdiLog  64* DVEfiles *.vcd *.vdb *.daidir *_sim
#-------------------------------------------------------------------------------------------------------
base_test :
	./base_sim base_sim.log +UVM_TESTNAME=logic_test 
#-------------------------------------------------------------------------------------------------------
open :
	@echo "Opening with Gedit..."
	gedit risc_pkg.sv instr_Interface.sv data_interface.sv alu_div_interface.sv mult_interface.sv regfile_interface.sv instr_seq_item.sv data_seq_item.sv alu_div_seq_item.sv mult_seq_item.sv RegFile_seq_item.sv instr_driver.sv data_driver.sv instr_monitor.sv data_mon.sv monitor_alu_div.sv monitor_mult.sv regfile_monitor.sv instr_sequencer.sv data_seqr.sv virtual_seqr.sv instr_agent.sv data_agent.sv ALU_agent.sv regfile_agent.sv instr_seq.sv data_seq.sv Virtual_seq.sv scoreboard.sv coverage.sv enviroment.sv ALUnDiv_b_module.sv Mult_b_module.sv regFile_b_module.sv risc_test.sv testbensh_top.sv Makefile &
	
