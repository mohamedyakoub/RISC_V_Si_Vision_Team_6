class debug_agent extends uvm_agent;
	// Factory registeration
	`uvm_component_utils(debug_agent)
	
	//Components instantiation
	debug_driver drv;
	debug_seqr seqr;

	// Constructor
	function new(string name = "debug_agent", uvm_component parent);
		super.new(name, parent);
	endfunction: new
	
	// Build phase  
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		drv = debug_driver::type_id::create("drv", this);
		seqr = debug_seqr::type_id::create("seqr", this); 
	endfunction: build_phase

	// Connect phase
	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		// Connect the driver with the sequencer
		drv.seq_item_port.connect(seqr.seq_item_export);
	endfunction: connect_phase
endclass: debug_agent
// --------- EOF -----------
