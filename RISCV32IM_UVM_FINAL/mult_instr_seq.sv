class mult_inst_seq extends inst_seq ;
    `uvm_object_utils(mult_inst_seq)    
    

    
  
    function new(string name="mult_inst_seq");
        super.new(name);
    endfunction

    
    
	task automatic fill_mem();
		rsp = instr_seq_item::type_id::create("rsp");
		//Loading the instrucion memory based on some constraints
		`uvm_info("Seq", "Starting fill seq", UVM_MEDIUM)
            
	    	
          for(int i=0;i<100*4; i=i+4) begin
            assert(rsp.randomize with { opcode==7'b0000011;
                                        funct3== 3'b10;
                                        rs1== 5'b00;
                                        imm12%4==0;});

            inst_mem[i] = rsp.instr_rdata_i;
        end   
	for(int i=100*4;i<inst_num; i=i+4) begin			
            
	    assert(rsp.randomize with { opcode == 7'b0110011; 
                                        funct7 == 7'b0000001;
					}); // Multplication and Division
            inst_mem[i] = rsp.instr_rdata_i;
        end
        `uvm_info("Seq", "finished fill seq", UVM_MEDIUM)
	endtask
	
  
        
endclass
