class mult_agent extends uvm_agent;
  
	`uvm_component_utils(mult_agent)
   
  	uvm_analysis_port #(mult_seq_item) agent_mult_mon_port;
	//uvm_analysis_port #(mult_seq_item) agnt_mult_ref_port;
  //---------------------------------------
  // component instances
  //---------------------------------------
	monitor_mult mon; 	
	mult_ref_model ref_model;
	mult_scoreboard   mult_scb;
	mult_coverage	  mult_cov;
  //---------------------------------------
  // constructor
  //---------------------------------------
  	function new (string name, uvm_component parent);
    		super.new(name, parent);
  	endfunction : new

  //---------------------------------------
  // build_phase
  //---------------------------------------
  	function void build_phase(uvm_phase phase);
    		super.build_phase(phase);
    		agent_mult_mon_port = new("agent_mult_mon_port",this);
    		//agnt_mult_ref_port = new("agnt_data_ref_port",this);
    		mon = monitor_mult::type_id::create("mon", this);
		ref_model = mult_ref_model::type_id::create("ref_model", this);
		mult_scb     = mult_scoreboard::type_id::create("mult_scb",this);
		mult_cov     = mult_coverage::type_id::create("mult_cov",this);
  	endfunction : build_phase
  
  //---------------------------------------  
  // connect_phase - connecting the driver and sequencer port
  //---------------------------------------
  	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		mon.item_collected_port.connect(agent_mult_mon_port);
    		mon.item_collected_port.connect(ref_model.analysis_export);
		mon.item_collected_port.connect(mult_scb.act_ap);
		mon.item_collected_port.connect(mult_cov.mult_cov_port);
		ref_model.rf_m_port.connect(mult_scb.exp_ap);
  	endfunction : connect_phase

endclass 

