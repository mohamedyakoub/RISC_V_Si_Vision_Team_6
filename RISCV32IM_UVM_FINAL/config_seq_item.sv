class config_seq_item extends uvm_sequence_item;
  
	// signals definition
  	logic rst_ni;
	logic pulp_clock_en_i;
	logic scan_cg_en_i;
	logic [31:0] boot_addr_i;
    	logic [31:0] mtvec_addr_i;
	logic [31:0] hart_id_i;
	logic fetch_enable_i;
	logic core_sleep_o;

  	// Utility and Field macros
  	`uvm_object_utils_begin(config_seq_item)
  		`uvm_field_int(rst_ni,UVM_ALL_ON)
  		`uvm_field_int(pulp_clock_en_i,UVM_ALL_ON)
  		`uvm_field_int(scan_cg_en_i,UVM_ALL_ON)
  		`uvm_field_int(boot_addr_i,UVM_ALL_ON)
  		`uvm_field_int(mtvec_addr_i,UVM_ALL_ON)
		`uvm_field_int(hart_id_i,UVM_ALL_ON)
		`uvm_field_int(fetch_enable_i,UVM_ALL_ON)
		`uvm_field_int(core_sleep_o,UVM_ALL_ON)
  	`uvm_object_utils_end

  	// Constructor
  	function new(string name = "config_seq_item");
    		super.new(name);
  	endfunction

	// Printing
  	function string convert2string();
    		return($sformatf("rst_ni : %0b , pulp_clock_en_i : %0b , scan_cg_en_i : %0b ,boot_addr_i : %0h , mtvec_addr_i : %0h,  hart_id_i : %0d,  fetch_enable_i : %0b,  core_sleep_o : %0b",rst_ni,pulp_clock_en_i,scan_cg_en_i,boot_addr_i,mtvec_addr_i,hart_id_i,fetch_enable_i,core_sleep_o));
  	endfunction

endclass
// --------- EOF -----------
