class reg_file_monitor extends uvm_monitor;
	`uvm_component_utils(reg_file_monitor)

	virtual reg_file_if mon_if;
	reg_file_sequence_item tr;
  
	uvm_analysis_port #(reg_file_sequence_item) mon_port;
  
	function new(string name = "reg_file_monitor", uvm_component parent);
		super.new(name, parent);
	endfunction
 
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
    
		mon_port = new("mon_port", this);
    
		if(!(uvm_config_db #(virtual reg_file_if)::get(this, "", "vif", mon_if))) begin
			`uvm_fatal("MONITOR_IN_CLASS", "Failed to get  mon_in_if from config DB!")
		end
	endfunction: build_phase
  
 
	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
	endfunction: connect_phase
  
	task run_phase (uvm_phase phase);
		super.run_phase(phase);
		forever begin
			@(posedge mon_if.clk iff mon_if.rst_n) ;
			tr = reg_file_sequence_item::type_id::create("tr");
			tr.raddr_a_i = mon_if.raddr_a_i;
			tr.raddr_b_i = mon_if.raddr_b_i;
			tr.rdata_a_o = mon_if.rdata_a_o;
			tr.rdata_b_o = mon_if.rdata_b_o,;
			if (mon_if.we_a_i) begin
				tr.waddr_a_i = mon_if.waddr_a_i;
				tr.wdata_a_i = mon_if.wdata_a_i;
			end 
			if (mon_if.we_b_i) begin	
				tr.waddr_b_i = mon_if.waddr_b_i;
				tr.wdata_b_i = mon_if.wdata_b_i;
			end 
			//send the transaction to scoreboard and coverage collector
			mon_port.write(tr);
		end 
        
	endtask: run_phase
  
  
endclass: reg_file_monitor