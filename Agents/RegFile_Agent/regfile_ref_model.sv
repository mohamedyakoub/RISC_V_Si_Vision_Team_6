class regfile_ref_model extends uvm_subscriber #(reg_file_sequence_item);
    `uvm_component_utils(regfile_ref_model)

    uvm_analysis_port #(regfile_ref_model) rf_m_port;
    reg_file_sequence_item item;
    bit [31:0] regfile [0:31]; // 32 registers of 32 bits each
    function new(string name = "regfile_ref_model", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        rf_m_port = new("rf_m_port", this);
    endfunction: build_phase
    
    virtual function  write(reg_file_sequence_item tr);
        `uvm_info("RegF_M", "Packet recieved", UVM_HIGH)
            item = reg_file_sequence_item::type_id::create("item");
			item.rdata_a_o=regfile[tr.raddr_a_i];
			item.rdata_b_o=regfile[tr.raddr_b_i];
			if (tr.we_a_i) begin
				reg_file[tr.waddr_a_i] = tr.wdata_a_i;
			end 
			if (tr.we_b_i) begin
				reg_file[tr.waddr_b_i] = tr.wdata_b_i;
			end 
        rf_m_port.write(item);
    endfunction

    

endclass