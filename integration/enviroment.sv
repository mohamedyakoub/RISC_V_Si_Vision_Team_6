//virtual-sequencer
//https://www.chipverify.com/uvm/uvm-virtual-sequencer
class enviroment extends uvm_env;
  
   instruction_agent  agnt_instr;
   data_agent         agnt_data;
   ALU_agent          agnt_alu;
   reg_file_agent     agnt_regfile;
   virtual_sequencer  virt_seqr;
   riscv_scoreboard   scb;
  //coverage          cov;
  
  `uvm_component_utils(enviroment)
  
  function new(string name, uvm_component parent);
    super.new(name,parent);
  endfunction:new
 
  //////////////////BUILD PHASE////////////////////
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    agnt_instr   = instruction_agent::type_id::create("agnt_instr",this);
    agnt_data    = data_agent::type_id::create("agnt_data",this);
    agnt_alu     = ALU_agent::type_id::create("agnt_alu",this);
    agnt_regfile = reg_file_agent::type_id::create("agnt_regfile",this);
    virt_seqr    = virtual_sequencer::type_id::create("virt_seqr",this);

    scb          = riscv_scoreboard::type_id::create("scb",this);

  //cov=coverage::type_id::create("cov",this);
  endfunction: build_phase
  
  //////////////CONNECT PHASE///////////////////////
  function void connect_phase(uvm_phase phase);
  agnt_instr.agent_item_port.connect(scb.inst_mon_export);  // agnt_instr
  agnt_data.agnt_data_mon_port.connect(scb.data_mon_export);
  agnt_alu.agent_mult_mon_port.connect(scb.mul_mon_export);
  agnt_alu.agent_alu_div_mon_port.connect(scb.alu_mon_export);
  agnt_regfile.agent_RegFile_mon_port.connect(scb.rf_mon_export);
  
    virt_seqr.seqr_I = agnt_instr.sequencer;
    virt_seqr.seqr_D = agnt_data.seqr;
  //agnt.alu_mon.item_collected_port.connect(cov.cov_export);
  endfunction: connect_phase
    
 endclass:enviroment
    
    