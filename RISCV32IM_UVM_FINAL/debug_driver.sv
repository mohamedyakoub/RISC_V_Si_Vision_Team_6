class debug_driver extends uvm_driver#(debug_seq_item);
	//Factor registeration
    	`uvm_component_utils(debug_driver)
    	
	//Virtual interface decleration
	virtual debug_if vif;
    	
	debug_seq_item drv_item;
	
	//Constructor
    	function new(string name="debug_driver", uvm_component parent=null);
        	super.new(name, parent);
    	endfunction

	// Build phase
    	virtual function void build_phase(uvm_phase phase);
        	super.build_phase(phase);
        	`uvm_info("Debug Driver", "Building driver", UVM_MEDIUM)
        	if(!(uvm_config_db#(virtual debug_if)::get(null, "", "vif", vif)))
            		`uvm_fatal("NOVIF", "No virtual interface found");
        	`uvm_info("Debug Driver", "Finished building driver", UVM_MEDIUM)
    	endfunction
	
	// Run phase
    	virtual task run_phase(uvm_phase phase);
        	super.run_phase(phase);
        	`uvm_info("Debug Driver", "Running driver", UVM_MEDIUM)
        	reset();
        	forever begin
			seq_item_port.get_next_item(drv_item);
			drive(drv_item);
                	seq_item_port.item_done (drv_item);
	
        	end
    	endtask

	// Reset the driver signals with the default values
    	task reset();
        	`uvm_info("Debug Driver", "Resetting driver", UVM_MEDIUM)
        	@(posedge vif.clk);
        	vif.debug_req_i <= 1'b0;
		vif.dm_halt_addr_i <= 1'b0;
		vif.dm_exception_addr_i <= 1'b0; 
        	`uvm_info("Driver", "Finished resetting driver", UVM_MEDIUM)
    	endtask
	task drive(debug_seq_item item);
		@(posedge vif.clk);
		vif.debug_req_i <= item.debug_req_i;
		vif.dm_halt_addr_i <= item.dm_halt_addr_i;
		vif.dm_exception_addr_i <= item.dm_exception_addr_i;
	endtask
endclass : debug_driver
// --------- EOF -----------
