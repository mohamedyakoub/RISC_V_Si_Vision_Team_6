class ALU_coverage extends  uvm_component;
	`uvm_component_utils (ALU_coverage)
       uvm_analysis_export #(alu_div_seq_item) cov_export; 
	   uvm_tlm_analysis_fifo #(alu_div_seq_item) cov_fifo;
       alu_div_seq_item seq_item_cov;
       
  
       localparam max_neg = {32'h80000000};
       localparam neg_one = {32'hFFFF_FFFF};
       // a -----> divisor -1 
       // b -----> dividend max_neg

    covergroup cg_alu;
         option.comment = "ALU_DIV";

        // Coverpoints for A max values unsigned
        cp_A_Unsigned: coverpoint unsigned'(seq_item_cov.operand_a_i) {
             option.comment = "oprand_A Max values";
                bins zeros  = {0};
                bins min    = {32'b10000000000000000000000000000000};
                bins max    = {32'b01111111111111111111111111111111};
                bins ones   = {32'b11111111111111111111111111111111};
                bins one    = {32'b00000000000000000000000000000001};
        }
        // Coverpoints for A  values signed
        cp_A_signed: coverpoint signed'(seq_item_cov.operand_a_i) {
             option.comment = "oprand_A sign of value";
                bins neg    = {[$:-1]};
                bins zeros  = {0};
                bins pos    = {[1:$]};
        }
        // Coverpoints for B max values unsigned
        cp_B_Unsigned: coverpoint unsigned'(seq_item_cov.operand_b_i) {
                    option.comment = "oprand_B Max values";
            bins zeros  = {0};
            bins min    = {32'b10000000000000000000000000000000};
            bins max    = {32'b01111111111111111111111111111111};
            bins ones   = {32'b11111111111111111111111111111111};
            bins one    = {32'b00000000000000000000000000000001};
        }
        // Coverpoints for B  values signed
        cp_B_signed: coverpoint signed'(seq_item_cov.operand_b_i) {
             option.comment = "oprand_B sign of value";
                bins neg    = {[$:-1]};
                bins zeros  = {0};
                bins pos    = {[1:$]};
        }

        // Coverpoints for ALU_OUT max values unsigned
        cp_ALU_OUT_Unsigned: coverpoint unsigned'(seq_item_cov.result_o) {
                    option.comment = "ALU_OUT Max values";
            bins zeros  = {0};
            bins min    = {32'b10000000000000000000000000000000};
            bins max    = {32'b01111111111111111111111111111111};
            bins ones   = {32'b11111111111111111111111111111111};
            bins one    = {32'b00000000000000000000000000000001};
        }
        // Coverpoints for ALU_OUT  values signed

        cp_ALU_OUT_signed: coverpoint signed'(seq_item_cov.result_o) {
                    option.comment  = "ALU_OUT sign of value";
                         bins neg   = {[$:-1]};
                         bins zeros = {0};
                         bins pos   = {[1:$]};
        }

        // Coverpoints for comparison_result  values 
        cp_comparison_result: coverpoint seq_item_cov.comparison_result_o {
                    option.comment      = "Branch_decisions";
                         bins Taken     = {1};
                         bins NO_Taken  = {0};
        }


        // Coverpoints for operations
        cp_operations: coverpoint seq_item_cov.operator_i  {
                    option.comment      = "ALU_Operations";
                // Arthmatics
                bins    ADD  = {ALU_ADD};
                bins    SUB  = {ALU_SUB};
                 // logics
                bins    XOR  = {ALU_XOR};
                bins    OR   = {ALU_OR} ;
                bins    AND  = {ALU_AND};
                 // Shifts
                bins    SRA  = {ALU_SRA};
                bins    SRL  = {ALU_SRL};
                bins    SLL  = {ALU_SLL} ;
                // Comparisons
                bins    LTS  = {ALU_LTS};
                bins    LTU  = {ALU_LTU};
                bins    GES  = {ALU_GES};
                bins    GEU  = {ALU_GEU};
                bins    EQ   = {ALU_EQ} ;
                bins    NE   = {ALU_NE} ;
                // Set Lower Than operations
                bins    SLTS = {ALU_SLTS};
                bins    SLTU = {ALU_SLTU};
                // div/rem
                bins    DIVU = {ALU_DIVU};
                bins    DIV  = {ALU_DIV} ;
                bins    REMU = {ALU_REMU};
                bins    REM  = {ALU_REM} ;        
        }

        // Cross coverage for special cases
        special_cases: coverpoint seq_item_cov.operator_i {
          bins same_operands = {ALU_AND, ALU_OR, ALU_XOR, ALU_ADD, ALU_SUB} iff (seq_item_cov.operand_a_i == seq_item_cov.operand_b_i);
          bins zero_operand_a = {ALU_AND, ALU_OR, ALU_XOR, ALU_ADD, ALU_SUB} iff (seq_item_cov.operand_a_i == 0);
          bins zero_operand_b = {ALU_AND, ALU_OR, ALU_XOR, ALU_ADD, ALU_SUB} iff (seq_item_cov.operand_b_i == 0);
        }

         // Coverpoints for Divide_by_zero
        cp_Divide_by_zero: coverpoint seq_item_cov.operand_a_i iff (seq_item_cov.operator_i == ALU_DIVU || seq_item_cov.operator_i == ALU_DIV)  {

            option.comment      = "Divide_by_zero";
        	bins    happened  = {0};
       
        }


        // Coverpoints for Divide_over_flow
        cp_Divide_over_flow: coverpoint (seq_item_cov.operand_a_i == neg_one) iff (seq_item_cov.operator_i == ALU_DIV)  {

        	bins    happened  = {1} iff (seq_item_cov.operand_b_i == max_neg) ;
       
        }

            // Coverpoints for Reminder_by_zero
        cp_Reminder_by_zero: coverpoint seq_item_cov.operand_a_i iff (seq_item_cov.operator_i == ALU_REMU || seq_item_cov.operator_i == ALU_REM)  {

        	bins    happened  = {0};
     
        }

          // Coverpoints for Divide_over_flow
        cp_Reminder_over_flow: coverpoint (seq_item_cov.operand_a_i == neg_one) iff (seq_item_cov.operator_i == ALU_REM)  {

        	bins    happened  = {1} iff (seq_item_cov.operand_b_i == max_neg) ;
       
        }
       
        // Crosscoverage for  A_signed with B_signed 
        cross_A_B   :         cross cp_A_signed, cp_B_signed;

        // Crosscoverage for  A_signed with B_signed with operations
        cross_A_B_op:         cross  cp_operations,cp_A_signed, cp_B_signed{
				              
				//  branch is direct not random                                                
                              	ignore_bins branch_blt  = binsof(cp_operations.LTS);
                                ignore_bins branch_bltu = binsof(cp_operations.LTU);
                                ignore_bins branch_bge  = binsof(cp_operations.GES);
                                ignore_bins branch_bgeu = binsof(cp_operations.GEU);
                                ignore_bins branch_beq  = binsof(cp_operations.EQ);
                                ignore_bins branch_bne  = binsof(cp_operations.NE);
				
			      }
    endgroup
			
			
       function new(string name = "ALU_coverage", uvm_component parent = null);
          super.new (name, parent);
          cg_alu = new();
       endfunction
	   
	   
       function void build_phase (uvm_phase phase);
          super.build_phase (phase);
          cov_export = new("cov_export", this);
          cov_fifo = new("cov_fifo", this);
       endfunction
	   
        function void connect_phase (uvm_phase phase);
           super.connect_phase (phase);
           cov_export.connect (cov_fifo.analysis_export);
        endfunction
		
        task run_phase (uvm_phase phase);
            super.run_phase(phase);
            forever begin
                cov_fifo.get (seq_item_cov); 
		cg_alu.sample();
            end
        endtask
        
	        // Report coverage at end of simulation
  function void report_phase(uvm_phase phase);
	super.report_phase(phase);
	`uvm_info("report_phase","*************alu_div_coverage**************************",UVM_MEDIUM)
        `uvm_info("report_phase", $sformatf("ALU_DIV  Coverage: %0.2f%%", cg_alu.get_coverage()), UVM_MEDIUM)
	`uvm_info("report_phase","******************************************************",UVM_MEDIUM) 
   
  endfunction
endclass : ALU_coverage





