class interrupt_seqr extends uvm_sequencer#(interrupt_seq_item);
	// Factory registeration
	`uvm_component_utils(interrupt_seqr) 

 	// Constructor
  	function new(string name = "interrupt_seqr", uvm_component parent);
    		super.new(name,parent);
  	endfunction
endclass : interrupt_seqr
// --------- EOF -----------
