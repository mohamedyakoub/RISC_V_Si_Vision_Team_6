class interrupt_agent extends uvm_agent;
	// Factory registeration
	`uvm_component_utils(interrupt_agent)
	
	//Components instantiation
	interrupt_driver drv;
	interrupt_seqr seqr;

	// Constructor
	function new(string name = "interrupt_agent", uvm_component parent);
		super.new(name, parent);
	endfunction: new
	
	// Build phase  
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		drv = interrupt_driver::type_id::create("drv", this);
		seqr = interrupt_seqr::type_id::create("seqr", this); 
	endfunction: build_phase

	// Connect phase
	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		// Connect the driver with the sequencer
		drv.seq_item_port.connect(seqr.seq_item_export);
	endfunction: connect_phase
endclass: interrupt_agent
// --------- EOF -----------
