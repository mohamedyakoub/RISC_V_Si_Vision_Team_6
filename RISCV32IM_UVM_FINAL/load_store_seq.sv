class load_store_seq extends inst_seq;
    `uvm_object_utils(load_store_seq)

    function new(string name="load_store_seq");
        super.new(name);
    endfunction

     task automatic fill_mem();
        `uvm_info("Seq", "Starting fill_inst_mem in load_store_seq", UVM_MEDIUM)
         rsp = instr_seq_item::type_id::create("rsp");
        for(int i=0;i<inst_num; i=i+4) begin
          assert(rsp.randomize with {opcode inside{7'b0100011,7'b0000011};});

            inst_mem[i] = rsp.instr_rdata_i;
        end 
        
        `uvm_info("Seq", "Finished fill_inst_mem", UVM_MEDIUM)
    endtask //automatic

   
endclass
