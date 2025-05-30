class config_seqr extends uvm_sequencer#(config_seq_item);
	// Factory registeration
	`uvm_component_utils(config_seqr) 

 	// Constructor
  	function new(string name = "config_seqr", uvm_component parent);
    		super.new(name,parent);
  	endfunction
endclass : config_seqr
// --------- EOF -----------
