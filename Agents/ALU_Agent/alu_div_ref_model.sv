class alu_div_ref_model extends uvm_subscriber #(alu_div_seq_item);
 `uvm_component_utils(alu_div_ref_model)
 
 uvm_analysis_port #(alu_div_seq_item) rf_m_port;
 
 function new(string name, uvm_component parent );
  super.new( name , parent );
 endfunction
 
 function void build_phase( uvm_phase phase );
  rf_m_port = new("rf_m_port", this);
 endfunction
 
 function void write( alu_div_seq_item t);
    `uvm_info("ALU_DIV_M", "Packet recieved", UVM_HIGH)
      alu_div_seq_item out_txn;
      $cast(out_txn,t.clone());
      case(t.operator_i)
       ALU_ADD : out_txn.result_o = t.operand_a_i + t.operand_b_i;
       ALU_SUB : out_txn.result_o = t.operand_a_i - t.operand_b_i;

       ALU_XOR : out_txn.result_o = t.operand_a_i ^ t.operand_b_i;
       ALU_OR  : out_txn.result_o = t.operand_a_i | t.operand_b_i;
       ALU_AND : out_txn.result_o = t.operand_a_i & t.operand_b_i;

       ALU_SRA : out_txn.result_o = t.operand_a_i  >>> t.operand_b_i[4:0];
       ALU_SRL : out_txn.result_o = t.operand_a_i  >>  t.operand_b_i[4:0];
       ALU_SLL : out_txn.result_o = t.operand_a_i  <<  t.operand_b_i[4:0];
       ALU_SLTS: out_txn.result_o = ( signed'(t.operand_a_i) < signed'(t.operand_b_i)) ? 1 : 0 ;
       ALU_SLTU: out_txn.result_o = (t.operand_a_i < t.operand_b_i) ? 1 : 0;

       ALU_DIVU: out_txn.result_o = t.operand_a_i  / t.operand_b_i;
       ALU_DIV : out_txn.result_o = signed'(t.operand_a_i) / signed'(t.operand_b_i);
       ALU_REMU: out_txn.result_o = t.operand_a_i  % t.operand_b_i;
       ALU_REM : out_txn.result_o = signed'(t.operand_a_i) % signed'(t.operand_b_i);
       
       default : out_txn.result_o = 32'b0;
      endcase
        `uvm_info("ALU_DIV_M", $sformatf("Expected_result = %0h",out_txn.result_o), UVM_HIGH)
      rf_m_port.write(out_txn);
 endfunction
 
endclass:alu_div_ref_model



    //ALU_ADD   = 7'b0011000,
    //ALU_SUB   = 7'b0011001,
  

    //ALU_XOR = 7'b0101111,
    //ALU_OR  = 7'b0101110,
    //ALU_AND = 7'b0010101,

    // Shifts
    //ALU_SRA = 7'b0100100,
    //ALU_SRL = 7'b0100101,
    //ALU_SLL = 7'b0100111,
    //shift_right_result = shift_op_a_32 >> shift_amt_int[4:0];

    // for branches
    // ALU_LTS = 7'b0000000,
    // ALU_LTU = 7'b0000001,
    // ALU_LES = 7'b0000100,
    // ALU_LEU = 7'b0000101,
    // ALU_GTS = 7'b0001000,
    // ALU_GTU = 7'b0001001,
    // ALU_GES = 7'b0001010,
    // ALU_GEU = 7'b0001011,
    // ALU_EQ  = 7'b0001100,
    // ALU_NE  = 7'b0001101,

    // // Set Lower Than operations
    // //ALU_SLTS  = 7'b0000010,
    // //ALU_SLTU  = 7'b0000011,
    // // div/rem
    // ALU_DIVU = 7'b0110000,  // bit 0 is used for signed mode, bit 1 is used for remdiv
    // ALU_DIV  = 7'b0110001,  // bit 0 is used for signed mode, bit 1 is used for remdiv
    // ALU_REMU = 7'b0110010,  // bit 0 is used for signed mode, bit 1 is used for remdiv
    // ALU_REM  = 7'b0110011,  // bit 0 is used for signed mode, bit 1 is used for remdiv

