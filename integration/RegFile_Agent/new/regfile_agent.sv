class reg_file_agent extends uvm_agent;
	
	`uvm_component_utils(reg_file_agent)
  
	reg_file_monitor mon;

  
	function new(string name = "reg_file_agent", uvm_component parent);
		super.new(name, parent);
	endfunction: new
  

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		mon = reg_file_monitor::type_id::create("mon", this);
	endfunction: build_phase

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
	endfunction: connect_phase
  
  
	task run_phase (uvm_phase phase);
		super.run_phase(phase); 
	endtask: run_phase
  
endclass: reg_file_agent