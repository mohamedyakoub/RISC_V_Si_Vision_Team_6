class reg_file_agent extends uvm_agent;
	
	`uvm_component_utils(reg_file_agent)
  
  	uvm_analysis_port #(reg_file_sequence_item)     agent_RegFile_mon_port;

	reg_file_monitor mon;

  
	function new(string name = "reg_file_agent", uvm_component parent);
		super.new(name, parent);

		agent_RegFile_mon_port = = new("agent_RegFile_mon_port", this);

	endfunction: new
  

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		mon = reg_file_monitor::type_id::create("mon", this);

	endfunction: build_phase

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);

		mon.mon_port.connect(agent_RegFile_mon_port);

	endfunction: connect_phase
  
  
endclass: reg_file_agent