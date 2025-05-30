class debug_seqr extends uvm_sequencer#(debug_seq_item);
	// Factory registeration
	`uvm_component_utils(debug_seqr) 

 	// Constructor
  	function new(string name = "debug_seqr", uvm_component parent);
    		super.new(name,parent);
  	endfunction
endclass : debug_seqr
// --------- EOF -----------
