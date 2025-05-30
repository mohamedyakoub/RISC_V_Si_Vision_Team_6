class interrupt_seq_item extends uvm_sequence_item;
  
	// signals definition
  	logic [31:0] irq_i;
	logic irq_ack_o;
	logic [4:0] irq_id_o; 

  	// Utility and Field macros
  	`uvm_object_utils_begin(interrupt_seq_item)
  		`uvm_field_int(irq_i,UVM_ALL_ON)
  		`uvm_field_int(irq_ack_o,UVM_ALL_ON)
  		`uvm_field_int(irq_id_o,UVM_ALL_ON)
  	`uvm_object_utils_end

  	// Constructor
  	function new(string name = "interrupt_seq_item");
    		super.new(name);
  	endfunction

	// Printing
  	function string convert2string();
    		return($sformatf("irq_i : %0h , irq_ack_o : %0b , irq_id_o : %0d",irq_i,irq_ack_o,irq_id_o));
  	endfunction

endclass
// --------- EOF -----------
