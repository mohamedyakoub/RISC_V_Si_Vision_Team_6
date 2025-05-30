class mult_div_test extends base_test;
	`uvm_component_utils(mult_div_test)

	function new(string name = "mult_div_test", uvm_component parent);
		super.new(name, parent);
	endfunction: new

	function void build_phase(uvm_phase phase);
		set_type_override_by_type(inst_seq::get_type(), mult_inst_seq::get_type());		
		super.build_phase(phase);
	endfunction: build_phase


	  
endclass: mult_div_test



