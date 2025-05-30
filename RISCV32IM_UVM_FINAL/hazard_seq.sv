class hazard_seq extends inst_seq ;
    
    `uvm_object_utils(hazard_seq)    

    function new(string name="hazard_seq");
        super.new(name);
    endfunction

    
  task automatic fill_mem();
    rsp = instr_seq_item::type_id::create("rsp");
    //Loading the instrucion memory based on some constraints
    `uvm_info("hazard_seq", "Starting fill seq", UVM_MEDIUM)
      for(int i=0;i<inst_num; i=i+4) begin    
            assert(rsp.randomize with {  !(opcode inside {7'b1100011,7'b1101111,7'b1100111}); 	//     exclude Branch,jump and jump and link
            if(opcode==7'b11) {rs1==0; if(funct3 inside {3'h2} )  imm12%4==0;  if(funct3 inside {3'h1,3'h5} )  imm12%4!=3; } // Load is always alligned
            });                            
            inst_mem[i] = rsp.instr_rdata_i;
        end
        `uvm_info("hazard_seq", "finished fill seq", UVM_MEDIUM)
  endtask
  
  
endclass:hazard_seq
