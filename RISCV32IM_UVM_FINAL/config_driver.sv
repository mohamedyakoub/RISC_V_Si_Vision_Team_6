class config_driver extends uvm_driver#(config_seq_item);
	//Factor registeration
    	`uvm_component_utils(config_driver)
    	
	//Virtual interface decleration
	virtual config_if vif;
    	
	config_seq_item drv_item;
	
	//Constructor
    	function new(string name="config_driver", uvm_component parent=null);
        	super.new(name, parent);
    	endfunction

	// Build phase
    	virtual function void build_phase(uvm_phase phase);
        	super.build_phase(phase);
        	`uvm_info("Config Driver", "Building driver", UVM_MEDIUM)
        	if(!(uvm_config_db#(virtual config_if)::get(null, "", "vif", vif)))
            		`uvm_fatal("NOVIF", "No virtual interface found");
        	`uvm_info("Config Driver", "Finished building driver", UVM_MEDIUM)
    	endfunction
	
	// Run phase
    	virtual task run_phase(uvm_phase phase);
        	super.run_phase(phase);
        	`uvm_info("Config Driver", "Running driver", UVM_MEDIUM)
        	reset();
        	forever begin
			seq_item_port.get_next_item(drv_item);
			drive(drv_item);
			seq_item_port.item_done (drv_item);
	
        	end
    	endtask

	// Reset the driver signals with the default values
    	task reset();
        	`uvm_info("Config Driver", "Resetting driver", UVM_MEDIUM)
        	
		vif.rst_ni 		<= 1'b0;
        	vif.pulp_clock_en_i 	<= 1'b0;
		vif.scan_cg_en_i 	<= 1'b0;
		vif.boot_addr_i 	<= 1'b0;
		vif.mtvec_addr_i 	<= 1'b0;
		vif.hart_id_i 		<= 1'b0;
		vif.fetch_enable_i 	<= 1'b0;
		repeat(5) @(posedge vif.clk);
 		vif.rst_ni 		<= 1'b1;
		vif.fetch_enable_i	<=1;
        	`uvm_info("Driver", "Finished resetting driver", UVM_MEDIUM)
    	endtask

	// Drive trask to be used with the sequencer usage
	task drive(config_seq_item item);
		@(posedge vif.clk);
        	vif.pulp_clock_en_i 	<= 1'b0;
		vif.scan_cg_en_i 	<= 1'b0;
		vif.boot_addr_i 	<= 1'b0;
		vif.mtvec_addr_i 	<= 1'b0;
		vif.hart_id_i 		<= 1'b0;
		vif.fetch_enable_i 	<= 1'b1;
	endtask
endclass : config_driver
// --------- EOF -----------
