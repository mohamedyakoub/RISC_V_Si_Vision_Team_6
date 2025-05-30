class interrupt_driver extends uvm_driver#(interrupt_seq_item);
	//Factor registeration
    	`uvm_component_utils(interrupt_driver)
    	
	//Virtual interface decleration
	virtual interrupt_if vif;
    	
	interrupt_seq_item drv_item;
	
	//Constructor
    	function new(string name="interrupt_driver", uvm_component parent=null);
        	super.new(name, parent);
    	endfunction

	// Build phase
    	virtual function void build_phase(uvm_phase phase);
        	super.build_phase(phase);
        	`uvm_info("Interrupt Driver", "Building driver", UVM_MEDIUM)
        	if(!(uvm_config_db#(virtual interrupt_if)::get(null, "", "vif", vif)))
            		`uvm_fatal("NOVIF", "No virtual interface found");
        	`uvm_info("Interrupt Driver", "Finished building driver", UVM_MEDIUM)
    	endfunction
	
	// Run phase
    	virtual task run_phase(uvm_phase phase);
        	super.run_phase(phase);
        	`uvm_info("Interrupt Driver", "Running driver", UVM_MEDIUM)
        	reset();
        	forever begin
			seq_item_port.get_next_item(drv_item);
			drive(drv_item);
			seq_item_port.item_done(drv_item);	
        	end
    	endtask

	// Reset the driver signals with the default values
    	task reset();
        	`uvm_info("Interrupt Driver", "Resetting driver", UVM_MEDIUM)
        	@(posedge vif.clk);
        	vif.irq_i <= 1'b0;
        	`uvm_info("Driver", "Finished resetting driver", UVM_MEDIUM)
    	endtask
	task drive(interrupt_seq_item item);
		@(posedge vif.clk);
		vif.irq_i <= item.irq_i;
	endtask
endclass : interrupt_driver
// --------- EOF -----------
