class debug_seq_item extends uvm_sequence_item;
  
	// signals definition
  	logic debug_req_i;
	logic [31:0] dm_halt_addr_i;
	logic [31:0] dm_exception_addr_i; 
        logic debug_havereset_o;
        logic debug_running_o;
        logic debug_halted_o;

  	// Utility and Field macros
  	`uvm_object_utils_begin(debug_seq_item)
  		`uvm_field_int(debug_req_i,UVM_ALL_ON)
  		`uvm_field_int(dm_halt_addr_i,UVM_ALL_ON)
  		`uvm_field_int(dm_exception_addr_i,UVM_ALL_ON)
  		`uvm_field_int(debug_havereset_o,UVM_ALL_ON)
  		`uvm_field_int(debug_running_o,UVM_ALL_ON)
		`uvm_field_int(debug_halted_o,UVM_ALL_ON)
  	`uvm_object_utils_end

  	// Constructor
  	function new(string name = "debug_seq_item");
    		super.new(name);
  	endfunction

	// Printing
  	function string convert2string();
    		return($sformatf("d_req : %0b , dm_halt_addr : %0h , dm_exp_addr : %0h ,d_hrst : %0b , d_running : %0b,  d_halted : %0b",debug_req_i,dm_halt_addr_i,dm_exception_addr_i,debug_havereset_o,debug_running_o,debug_halted_o));
  	endfunction

endclass
// --------- EOF -----------
