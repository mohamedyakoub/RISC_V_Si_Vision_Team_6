class enviroment extends uvm_env;
  
   instruction_agent  agnt_instr;
   data_agent         agnt_data;
   ALU_DIV_agent          agnt_alu;
   mult_agent		agnt_mult;	
   reg_file_agent     agnt_regfile;
   debug_agent        agnt_debug;
   config_agent       agnt_config;
   interrupt_agent    agnt_interrupt;
   virtual_sequencer  virt_seqr;
   scoreboard   scb;
	
  
  
  `uvm_component_utils(enviroment)
  
  function new(string name, uvm_component parent);
    super.new(name,parent);
  endfunction:new
 
  //////////////////BUILD PHASE////////////////////
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    agnt_instr   = instruction_agent::type_id::create("agnt_instr",this);
    agnt_data    = data_agent::type_id::create("agnt_data",this);
    agnt_alu     = ALU_DIV_agent::type_id::create("agnt_alu",this);
    agnt_mult     = mult_agent::type_id::create("agnt_mult",this);
    agnt_regfile = reg_file_agent::type_id::create("agnt_regfile",this);
    agnt_debug = debug_agent::type_id::create("agnt_debug",this);
    agnt_config = config_agent::type_id::create("agnt_config",this);
    agnt_interrupt = interrupt_agent::type_id::create("agnt_interrupt",this);
    virt_seqr    = virtual_sequencer::type_id::create("virt_seqr",this);
	
    scb          = scoreboard::type_id::create("scb",this);

  
  endfunction: build_phase
  
  //////////////CONNECT PHASE///////////////////////
  function void connect_phase(uvm_phase phase);
    agnt_instr.agent_item_port.connect(scb.inst_mon_export);  // agnt_instr
    agnt_data.agnt_data_mon_port.connect(scb.data_mon_export);
    agnt_regfile.agent_RegFile_mon_port.connect(scb.rf_mon_export);
  
    virt_seqr.seqr_I = agnt_instr.sequencer;
    virt_seqr.seqr_D = agnt_data.seqr;
  
  endfunction: connect_phase
    
 endclass:enviroment
    
    
