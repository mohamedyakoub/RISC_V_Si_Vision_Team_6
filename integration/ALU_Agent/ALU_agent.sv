class ALU_agent extends uvm_agent;
  
  `uvm_component_utils(ALU_agent)

   uvm_analysis_port #(mult_seq_item)     agent_mult_mon_port;
   uvm_analysis_port #(alu_div_seq_item)  agent_alu_div_mon_port;
   
   monitor_mult                           mult_mon;
   monitor_alu_div                        alu_div_mon;
  
  function new(string name, uvm_component parent);
    super.new(name,parent);

    agent_mult_mon_port    = new("agent_mult_mon_port", this);
    agent_alu_div_mon_port = new("agent_alu_div_mon_port", this);
     
  endfunction: new
  
      //////////////   BUILD PHASE    //////////////////////////////
    function void build_phase(uvm_phase phase);
    super.build_phase(phase);
      
      mult_mon    =  monitor_mult::type_id::create("mult_mon",this);
      alu_div_mon =  monitor_alu_div::type_id::create("alu_div_mon",this);

    endfunction:build_phase

      //////////////   CONNECT PHASE   //////////////////////////////
  function void connect_phase(uvm_phase phase);

    mult_mon.item_collected_port.connect(agent_mult_mon_port);
    alu_div_mon.item_collected_port.connect(agent_alu_div_mon_port);

  endfunction : connect_phase


  
endclass : ALU_agent