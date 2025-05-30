class base_test extends uvm_test;
	`uvm_component_utils(base_test)
	int inst_num=25000;
	enviroment env;

	virtual_seq vseq;
	instr_agent_config inst_agt_cfg;
	ins_cfg	ins_seq_cfg;
	data_agent_cfg data_agt_cfg;

	function new(string name = "base_test", uvm_component parent);
		super.new(name, parent);
	endfunction: new

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		vseq = virtual_seq::type_id::create("vseq", this);
		env  = enviroment::type_id::create("env", this);
		inst_agt_cfg = instr_agent_config::type_id::create("inst_agt_cfg", this);
		ins_seq_cfg = ins_cfg::type_id::create("ins_seq_cfg", this);
		data_agt_cfg = data_agent_cfg::type_id::create("data_agt_cfg", this);
		ins_seq_cfg.inst_num=inst_num;
		uvm_config_db#(instr_agent_config)::set(this,"env*","inst_agt_cfg",inst_agt_cfg);
		uvm_config_db#(ins_cfg)::set(this,"env*","ins_seq_cfg",ins_seq_cfg);
		uvm_config_db#(data_agent_cfg)::set(this,"env*","data_agt_cfg",data_agt_cfg);
	endfunction: build_phase


	  task run_phase (uvm_phase phase);
		super.run_phase(phase);
		
		
		phase.raise_objection(this);
			vseq.start(env.virt_seqr);
		phase.drop_objection(this);

	  endtask: run_phase

endclass: base_test



