class hazard_test extends base_test;
	
	`uvm_component_utils(hazard_test)

	function new(string name = "hazard_test", uvm_component parent);
		super.new(name, parent);
	endfunction: new

	function void build_phase(uvm_phase phase);
		
		inst_seq::type_id::set_type_override(hazard_seq::get_type());

		super.build_phase(phase);
		
	endfunction: build_phase


endclass: hazard_test
