class inst_seq extends uvm_sequence #(instr_seq_item);
    `uvm_object_utils(inst_seq)    
    instr_seq_item req,rsp;
    instr_seq_item q [$:2];
    bit [31:0]  inst_mem [int];
   
    int i,inst_num;
    ins_cfg cfg;

    function new(string name="inst_seq");
        super.new(name);
    endfunction

    virtual task pre_body();
        `uvm_info("Seq", "Starting pre body ", UVM_MEDIUM)
        cfg=ins_cfg::type_id::create("cfg");

        if(!uvm_config_db#(ins_cfg)::get(m_sequencer, "", "ins_seq_cfg", cfg))
            `uvm_fatal("NOCFG", "No configuration object found");
        
        inst_num = cfg.inst_num;
        `uvm_info("Seq", "Finished pre body ", UVM_MEDIUM)

    endtask
    
	virtual task fill_mem();
		rsp = instr_seq_item::type_id::create("rsp");
		//Filling the instrucion memory based on some constraints
		`uvm_info("Seq", "Starting fill seq", UVM_MEDIUM)
	    for(int i=0;i<inst_num; i=i+4) begin	       			
		    assert(rsp.randomize with {  //!(opcode inside {7'b1100111}); 	//     exclude Branch,jump and jump and link
			    if(opcode==7'b1101111) {imm20%4==0; }  
			    if(opcode==7'b1100111) {rs1==0; imm12%4==0; }                   
			    if(opcode==7'b1100011) {rs1==0; imm12%4==0; } 
			    generate_raw_hazard==0; generate_waw_hazard==0; generate_war_hazard==0; // Make the hazard appear less than usual
		    }); 
		    inst_mem[i] = rsp.instr_rdata_i;
	    end
		`uvm_info("Seq", "finished fill seq", UVM_MEDIUM)
	endtask
	
    virtual task body();
        `uvm_info("Seq", "Starting sequence", UVM_MEDIUM)
        req = instr_seq_item::type_id::create("req");
        fill_mem();
        rsp = instr_seq_item::type_id::create("rsp");
	//The system wont stop until an address out of range is requested
	i=0;
        while(i<inst_num)begin
	    //Reciving the request from the driver
            start_item(req);
            finish_item(req);
            get_response(req);
	    //Sending the response based on the request
            start_item(rsp);
            rsp.copy(req);
            if (inst_mem.exists(req.instr_addr_o)) begin
                rsp.instr_rdata_i = inst_mem[req.instr_addr_o];
            end else begin
                assert(rsp.randomize with {  //!(opcode inside {7'b1100011,7'b1101111,7'b1100111}); 	//     exclude Branch,jump and jump and link
			    if(opcode==7'b1101111) {imm20%4==0; }  
			    if(opcode==7'b1100111) {rs1==0; imm12%4==0; }                   
			    if(opcode==7'b1100011) {rs1==0; imm12%4==0; }  
			    generate_raw_hazard==0; generate_waw_hazard==0; generate_war_hazard==0; // Make the hazard appear less than usual
		    }); 
		    
            end
             
            finish_item(rsp);
	i+=4;	
        end
        

        `uvm_info("Seq", "Finishing sequence", UVM_MEDIUM)
        
    endtask
endclass


