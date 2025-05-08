class regfile_ref_model extends uvm_subscriber #(reg_file_sequence_item);
    `uvm_component_utils(regfile_ref_model)

    uvm_analysis_port #(reg_file_sequence_item) rf_m_port;
    reg_file_sequence_item item,tr;
    bit [31:0] regfile [0:31]; // 32 registers of 32 bits each
    function new(string name = "regfile_ref_model", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        rf_m_port = new("rf_m_port", this);
    endfunction: build_phase
    
     function void write(reg_file_sequence_item t);
        `uvm_info("RegF_M", "Packet recieved", UVM_HIGH)
            item = reg_file_sequence_item::type_id::create("item");
			
			item.rdata_a_o=regfile[t.raddr_a_i];
			item.rdata_b_o=regfile[t.raddr_b_i];
			if (t.we_a_i) begin
				regfile[t.waddr_a_i] = t.wdata_a_i;
				`uvm_info("REGF_Model", $sformatf("Addr: %0h, Data: %0h", t.waddr_a_i, t.wdata_a_i), UVM_HIGH)
			end 
			if (t.we_b_i) begin
				regfile[t.waddr_b_i] = t.wdata_b_i;
				`uvm_info("REGF_Model", $sformatf("Addr: %0h, Data: %0h", t.waddr_b_i, t.wdata_b_i), UVM_HIGH)
			end 
	
	
        rf_m_port.write(item);
    endfunction

    

endclass
