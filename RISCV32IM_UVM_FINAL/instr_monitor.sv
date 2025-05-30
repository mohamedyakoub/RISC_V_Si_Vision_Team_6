class instruction_monitor extends uvm_monitor;
  `uvm_component_utils(instruction_monitor)

  virtual ins_if vif;  // Connect this via uvm_config_db
  uvm_analysis_port #(instr_seq_item) mon_ap;

   instr_seq_item txn, final_txn, inst_qu[$];
  function new(string name, uvm_component parent);
    super.new(name, parent);
    //txn = instr_seq_item::type_id::create("txn");
    mon_ap = new("mon_ap", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual ins_if)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", "Virtual interface not set for instruction_monitor");
  endfunction
  
  task run_phase(uvm_phase phase);
   
     
    forever begin
      txn = instr_seq_item::type_id::create("txn");
       
            @ (posedge vif.clk iff vif.instr_req_o && vif.instr_gnt_i);
       	    
        	txn.instr_addr_o   = vif.instr_addr_o;
                txn.instr_req_o   = vif.instr_req_o;
                txn.instr_gnt_i   = vif.instr_gnt_i;
                
                
                inst_qu.push_back (txn) ;
                
                fork 
                  begin 
		    
                    @ (posedge vif.clk iff vif.instr_rvalid_i);
	            if (inst_qu.size() > 0) begin 
		
                      final_txn = inst_qu.pop_front();
                      final_txn.instr_rdata_i  = vif.instr_rdata_i;
                      final_txn.instr_rvalid_i  = vif.instr_rvalid_i;
	              `uvm_info("INS_MON", $sformatf("Captured addr=0x%08x data=0x%08x,\t%0b\t%0b", final_txn.instr_addr_o,         final_txn.instr_rdata_i,vif.instr_req_o,vif.instr_gnt_i), UVM_HIGH)
	              extract_inst_fields(final_txn ,final_txn);
	              `uvm_info("INS_MON",$sformatf("Collect %0s: Rs1 0x%0x Rs2 0x%0x Rd 0x%0x extend_imm 0x%0x",final_txn.inst_type,final_txn.rs1,final_txn.rs2,final_txn.rd,final_txn.Extend()), UVM_HIGH)
	            mon_ap.write(final_txn);  // Send to scoreboard or coverage collector
                   end 
		 end
                  begin 
		    `uvm_info("INS_MON",$sformatf(".............INST MON : WAITING FOR RES........."), UVM_HIGH)
                    
 		  end
              join_any 
               
                
          
    end
  endtask
  //---------------------------------------
  //  task extract instruction fields
  //---------------------------------------
  task extract_inst_fields (input instr_seq_item txn, output instr_seq_item inst_seq);
     
     $cast(inst_seq,txn.clone());
     inst_seq.opcode=inst_seq.instr_rdata_i[6:0];
     case(inst_seq.opcode)
    R_TYPE:
      begin
        inst_seq.rs1 = inst_seq.instr_rdata_i[19:15]; //not sure in all of the cases
        inst_seq.rs2 = inst_seq.instr_rdata_i[24:20]; //not sure in all of the cases
        inst_seq.rd = inst_seq.instr_rdata_i[11:7];
        inst_seq.funct3 = inst_seq.instr_rdata_i[14:12];
        inst_seq.funct7 = inst_seq.instr_rdata_i[31:25];
      end
   // I−type
    I_TYPE_0,
    I_TYPE_1,
    I_TYPE_2:
      begin
        inst_seq.rs1 = inst_seq.instr_rdata_i[19:15];
        inst_seq.rd = inst_seq.instr_rdata_i[11:7];
        inst_seq.funct3 = inst_seq.instr_rdata_i[14:12];
	inst_seq.imm12=inst_seq.instr_rdata_i[31:20];
        inst_seq.funct7 = 0;
      end
    S_TYPE,
    B_TYPE:
      begin
        inst_seq.rs1 = inst_seq.instr_rdata_i[19:15];
        inst_seq.rs2 = inst_seq.instr_rdata_i[24:20];
        inst_seq.funct3 = inst_seq.instr_rdata_i[14:12];
        inst_seq.funct7 = 0;
      end
    U_TYPE_0,
    U_TYPE_1,
    J_TYPE:
      begin
        inst_seq.rd = inst_seq.instr_rdata_i[11:7];
        inst_seq.funct3 = 0;
        inst_seq.funct7 = 0;
      end
  endcase
    inst_seq.Get_type();
  endtask
  
endclass

