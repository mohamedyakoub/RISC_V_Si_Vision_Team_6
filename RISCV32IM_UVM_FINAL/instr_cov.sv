class instruction_coverage extends uvm_subscriber #(instr_seq_item);
  //---------------------------------------
  // factory registeration 
  //---------------------------------------
  
  `uvm_component_utils(instruction_coverage)
  instr_seq_item instr ;
  real instr_coverage  ;
  
  //---------------------------------------
  // constructor
  //---------------------------------------
  function new(string name="coverage_collector",uvm_component parent);
    super.new(name,parent);
    instr_cov = new; 	        // Create an instance of the covergroup
  endfunction
  
  //---------------------------------------
  // coverage groups
  //--------------------------------------- 
  covergroup instr_cov;
    // Instruction type coverage
   cp_type: coverpoint instr.inst_type {
      // R-Type
      bins r_arithmetic = {ADD, SUB};
      bins r_logical    = {AND, OR, XOR};
      bins r_shift      = {SLL, SRL, SRA};
      bins r_compare    = {SLT, SLTU};
      bins r_muldiv     = {MUL, MULH, MULSU, MULU, DIV, DIVU, REM, REMU};
      // I-Type
      bins i_arithmetic = {ADDI};
      bins i_logical    = {ANDI, ORI, XORI};
      bins i_shift      = {SLLI, SRLI, SRAI};
      bins i_compare    = {SLTI, SLTIU};
      bins i_load       = {LB, LH, LW, LBU, LHU};
      bins i_jalr       = {JALR};

      // S-Type
      bins s_store      = {SB, SH, SW};

      // B-Type
      bins b_branch     = {BEQ, BNE, BLT, BGE, BLTU, BGEU};

      // U-Type
      bins u_upper      = {LUI, AUIPC};

      // J-Type
      bins j_jump       = {JAL};
	}

    			
    //cov point rs1 , rs2, rd  
    cp_rs1: coverpoint instr.rs1 iff ( ! (instr.opcode inside{U_TYPE_0, U_TYPE_1, J_TYPE}) )
    { bins rs1[] = {[0:31]};
              
    }
    cp_rs2: coverpoint instr.rs2 iff ( ! (instr.opcode inside{I_TYPE_0, I_TYPE_1, I_TYPE_2, U_TYPE_0, U_TYPE_1, J_TYPE}) )
    { bins rs2[] = {[0:31]};
              
    }
    cp_rd: coverpoint instr.rd iff ( ! (instr.opcode inside{S_TYPE, B_TYPE}) )
    { bins rd[] = {[1:31]};
     illegal_bins ILLEGAL_RD = {0};
              
    }
    //cov immediate  imm12 , imm20
    // 12-bit signed immediate coverage (I, S, B types)
   

// General immediate coverage for imm12 (excluding shift instructions)
cp_imm12: coverpoint $signed(instr.imm12) iff (
  instr.opcode inside {I_TYPE_0, I_TYPE_1, I_TYPE_2, S_TYPE, B_TYPE} &&
  !(instr.funct3 inside {srxI, sllI})
) {
  bins zero     = {0};
 // bins neg_one  = {-1}; misaligned address 
  bins pos_mid  = {[500:510]};
  bins neg_mid  = {[-510:-500]};
}


// For shift instructions with immediate (SLLI, SRLI, SRAI)
// These are encoded in imm12 = {funct7[6:0], shamt[4:0]}
cp_imm12_srxI_sllI: coverpoint instr.imm12 iff (
  instr.funct3 inside {srxI, sllI}
) {
  // SRLI or SLLI: funct7 = 7'b0000000
  bins srli_slli [] = {[12'b0000000_00000 : 12'b0000000_11111]};

  // SRAI: funct7 = 7'b0100000
  bins srai []= {[12'b0100000_00000 : 12'b0100000_11111]};
}

cp_imm20: coverpoint $signed(instr.imm20) iff (
  instr.opcode inside {J_TYPE}
) {
  bins zero        = {0};
  //bins positive    = {[1:$]} with (item % 4 == 0);
  //bins negative    = {[$:-1]} with (item % 4 == 0);
  bins div_by_4    = {[-524288:$]} with (item % 4 == 0);
}

cp_imm20_unsigned: coverpoint instr.imm20 iff (
  instr.opcode inside {U_TYPE_0, U_TYPE_1}
) {
  bins zero        = {0};
  //bins positive    = {[1:$]} with (item % 4 == 0);
  bins div_by_4    = {[0:$]} with (item % 4 == 0);
}

   /* // Cross coverage
    cross_type_imm12: cross cp_type, cp_imm12 iff (
      instr.opcode inside {I_TYPE_0, I_TYPE_1, I_TYPE_2}
    );
 
  // Cross coverage for signed imm20 (J-type)
  cross_type_imm20_signed: cross cp_type, cp_imm20 {
    bins jal_zero      = binsof(cp_type.j_jump) && binsof(cp_imm20.zero);
    //bins jal_pos       = binsof(cp_type.j_jump) && binsof(cp_imm20.positive);
    //bins jal_neg       = binsof(cp_type.j_jump) && binsof(cp_imm20.negative);
    bins jal_div4      = binsof(cp_type.j_jump) && binsof(cp_imm20.div_by_4);
  }

  // Cross coverage for unsigned imm20 (U-type)
  cross_type_imm20_unsigned: cross cp_type, cp_imm20_unsigned {
    bins u_zero        = binsof(cp_type.u_upper) && binsof(cp_imm20_unsigned.zero);
    //bins u_pos         = binsof(cp_type.u_upper) && binsof(cp_imm20_unsigned.positive);
    bins u_div4        = binsof(cp_type.u_upper) && binsof(cp_imm20_unsigned.div_by_4);
  }

*/

  endgroup
  
   //---------------------------------------
  // write tasks - recives the items and sample the coverage groups
  //---------------------------------------
  virtual function void write (instr_seq_item t);
     instr = t;
    `uvm_info("instruction_coverage", {"Get new input item: ", instr.convert2string()}, UVM_HIGH)
    instr_cov.sample();
  endfunction 
  //---------------------------------------
  function void extract_phase(uvm_phase phase);
    super.extract_phase(phase);
    instr_coverage = instr_cov.get_coverage();
  endfunction
  //---------------------------------------
  // report phase
  //---------------------------------------
  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info(get_type_name(),$sformatf("Instruction Coverage is %0.1f\t ",instr_coverage),UVM_LOW)
  endfunction
  


endclass
