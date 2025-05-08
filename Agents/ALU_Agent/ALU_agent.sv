class ALU_DIV_agent extends uvm_agent;
  
  `uvm_component_utils(ALU_DIV_agent)

   uvm_analysis_port #(alu_div_seq_item)  agent_alu_div_mon_port;
   
   monitor_alu_div                        alu_div_mon;

   alu_div_ref_model                      ref_model;

   alu_div_scoreboard                     scoreboard;
  
  function new(string name, uvm_component parent);
    super.new(name,parent);

  
    agent_alu_div_mon_port = new("agent_alu_div_mon_port", this);
     
  endfunction: new
  
      //////////////   BUILD PHASE    //////////////////////////////
    function void build_phase(uvm_phase phase);
    super.build_phase(phase);
      
    
      alu_div_mon =  monitor_alu_div::type_id::create("alu_div_mon",this);
      ref_model   =  alu_div_ref_model::type_id::create("ref_model",this);
      scoreboard  =  alu_div_scoreboard::type_id::create("scoreboard",this);

    endfunction:build_phase

      //////////////   CONNECT PHASE   //////////////////////////////
  function void connect_phase(uvm_phase phase);

    alu_div_mon.item_collected_port.connect(agent_alu_div_mon_port);
    alu_div_mon.item_collected_port.connect(ref_model.analysis_export);
    alu_div_mon.item_collected_port.connect(scoreboard.act_ap);
        
    //if scoreboard is used here we should connect here
    ref_model.rf_m_port.connect(scoreboard.exp_ap);
  
  endfunction : connect_phase
  
endclass : ALU_DIV_agent


