// virtual-sequence
// https://www.chipverify.com/uvm/uvm-virtual-sequence
class base_test extends uvm_test;
	`uvm_component_utils(cv32e40p_test)

	enviroment env;
	virtual_seq vseq;

	
	function new(string name = "cv32e40p_test", uvm_component parent);
		super.new(name, parent);
	endfunction: new

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		env  = enviroment::type_id::create("env", this);
		
	endfunction: build_phase


	  task run_phase (uvm_phase phase);
		super.run_phase(phase);
		
		vseq = virtual_seq::type_id::create("vseq", this);
		phase.raise_objection(this);
			vseq.start(env.agnt.seqr);
		phase.drop_objection(this);

	  endtask: run_phase

endclass: base_test


