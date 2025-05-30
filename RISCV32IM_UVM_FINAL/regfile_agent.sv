class reg_file_agent extends uvm_agent;
	
	`uvm_component_utils(reg_file_agent)
  
  	uvm_analysis_port #(reg_file_sequence_item)     agent_RegFile_mon_port;

	reg_file_monitor mon;
        regfile_ref_model ref_model;
        regfile_scoreboard scoreboard;
	regfile_cov	   cov;
	function new(string name = "reg_file_agent", uvm_component parent);
		super.new(name, parent);

		agent_RegFile_mon_port =  new("agent_RegFile_mon_port", this);

	endfunction: new
  

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		mon = reg_file_monitor::type_id::create("mon", this);
        	ref_model = regfile_ref_model::type_id::create("ref_model", this);
        	scoreboard = regfile_scoreboard::type_id::create("scoreboard", this);
		cov = regfile_cov::type_id::create("cov", this);
	endfunction: build_phase

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		
		//Connecting the monitor port to the other ports
		//Connecting it to the agent and the outside 
		mon.mon_port.connect(agent_RegFile_mon_port);
		//Connecting it to the refrence model to calculate the expected
		mon.mon_port.connect(ref_model.analysis_export);
		mon.mon_port.connect(cov.analysis_export);
		//Connecting it to the scoreboard to send the actual
		mon.mon_port.connect(scoreboard.act_ap);
        	//if scoreboard is used here we should connect here
         	ref_model.rf_m_port.connect(scoreboard.exp_ap);

	endfunction: connect_phase
  
  
endclass: reg_file_agent
