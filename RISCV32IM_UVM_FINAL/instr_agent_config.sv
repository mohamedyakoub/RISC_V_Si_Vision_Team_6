class instr_agent_config extends uvm_object;

   `uvm_object_utils(instr_agent_config)
   bit is_active=1; // 1=Active
   
   function new(string name="instr_agent_config");
	super.new(name);
   endfunction

endclass
