class alu_div_ref_model extends uvm_subscriber #(alu_div_seq_item);
 `uvm_component_utils(alu_div_ref_model)
 
 uvm_analysis_port #(alu_div_seq_item) rf_m_port;
 alu_div_seq_item out_txn;
 
 function new(string name, uvm_component parent );
  super.new( name , parent );
 endfunction
 
 function void build_phase( uvm_phase phase );
  rf_m_port = new("rf_m_port", this);
 endfunction
 
 function void write( alu_div_seq_item t);
    //`uvm_info("ALU_DIV_M", "Packet recieved", UVM_HIGH)
       out_txn = alu_div_seq_item::type_id::create("out_txn");;
      $cast(out_txn,t.clone());
      case(t.operator_i)
       ALU_ADD : out_txn.result_o = t.operand_a_i + t.operand_b_i;
       ALU_SUB : out_txn.result_o = t.operand_a_i - t.operand_b_i;

       ALU_XOR : out_txn.result_o = t.operand_a_i ^ t.operand_b_i;
       ALU_OR  : out_txn.result_o = t.operand_a_i | t.operand_b_i;
       ALU_AND : out_txn.result_o = t.operand_a_i & t.operand_b_i;

       ALU_SRA : out_txn.result_o = signed'(signed'(t.operand_a_i)  >>> t.operand_b_i[4:0]);
       ALU_SRL : out_txn.result_o = t.operand_a_i  >>  t.operand_b_i[4:0];
       ALU_SLL : out_txn.result_o = t.operand_a_i  <<  t.operand_b_i[4:0];
       ALU_SLTS: out_txn.result_o = ( signed'(t.operand_a_i) < signed'(t.operand_b_i)) ? 1 : 0 ;
       ALU_SLTU: out_txn.result_o = (t.operand_a_i < t.operand_b_i) ? 1 : 0;
       
       ALU_LTS:  out_txn.result_o = ( signed'(t.operand_a_i) < signed'(t.operand_b_i)) ? 32'hffff_ffff : 0 ;
       ALU_LTU:  out_txn.result_o = (t.operand_a_i < t.operand_b_i) ? 32'hffff_ffff : 0;
       ALU_GES:  out_txn.result_o = ( signed'(t.operand_a_i) >= signed'(t.operand_b_i)) ? 32'hffff_ffff : 0 ;
       ALU_GEU:  out_txn.result_o = (t.operand_a_i >= t.operand_b_i) ? 32'hffff_ffff : 0;
       ALU_EQ :  out_txn.result_o = (t.operand_a_i == t.operand_b_i) ? 32'hffff_ffff : 0;
       ALU_NE :  out_txn.result_o = (t.operand_a_i != t.operand_b_i) ? 32'hffff_ffff : 0;


       ALU_DIVU: out_txn.result_o = unsigned'(t.operand_b_i  / t.operand_a_i);
       ALU_DIV : if(signed'(t.operand_b_i)==32'h80000000 & signed'(t.operand_a_i)==32'hffff_ffff )
	out_txn.result_o=t.operand_b_i;
	else      	out_txn.result_o = signed'(signed'(t.operand_b_i) / signed'(t.operand_a_i));
       ALU_REMU: out_txn.result_o = unsigned'(t.operand_b_i  % t.operand_a_i);
       ALU_REM : if(signed'(t.operand_b_i)==32'h80000000 & signed'(t.operand_a_i)==32'hffff_ffff )
	out_txn.result_o=0;
	else      	out_txn.result_o = signed'(signed'(t.operand_b_i) % signed'(t.operand_a_i));
       
       default : out_txn.result_o = 32'b0;
      endcase

	if ( (t.operator_i == ALU_DIVU || t.operator_i == ALU_DIV) &&  t.operand_a_i == 0 )begin
		out_txn.result_o = 32'hffff_ffff;
	end
	if ( (t.operator_i == ALU_REMU || t.operator_i == ALU_REM) &&  t.operand_a_i == 0 )begin
		out_txn.result_o = t.operand_b_i;
	end
        `uvm_info("ALU_DIV_M", $sformatf("Expected_result = %h A = %0h B = %0h opcode = %0s",out_txn.result_o,t.operand_a_i,t.operand_b_i,t.operator_i.name()), UVM_HIGH)
      rf_m_port.write(out_txn);
 endfunction
 
endclass:alu_div_ref_model


