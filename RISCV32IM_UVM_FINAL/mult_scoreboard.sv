`uvm_analysis_imp_decl(_multexp)
`uvm_analysis_imp_decl(_multact)
class  mult_scoreboard extends uvm_scoreboard;
	`uvm_component_utils(mult_scoreboard)

    	int no_trans,correct,incorrect;
    	uvm_analysis_imp_multexp#(mult_seq_item,mult_scoreboard) exp_ap;
    	uvm_analysis_imp_multact#(mult_seq_item,mult_scoreboard) act_ap;
    	mult_seq_item actual[$:1],expected[$:1];
    

    	function new(string name="mult_scoreboard", uvm_component parent=null);
        	super.new(name, parent);
        	exp_ap=new("exp_ap",this);
	    	act_ap=new("act_ap",this);
    	endfunction

    	function  void build_phase(uvm_phase phase);
    	super.build_phase(phase);
    	endfunction

    	virtual function  write_multexp(mult_seq_item item);
        	
        	expected.push_back(item);
        	
    	endfunction

    	virtual function  write_multact(mult_seq_item item);
        	
        	actual.push_back(item);
        	no_trans=no_trans+1;
        	
    	endfunction

    	//runphase
    	virtual task run_phase(uvm_phase phase);
        	super.run_phase(phase);
        	forever begin
            		wait(actual.size()>0 && expected.size()>0);
            		if(actual[0].result_o == expected[0].result_o) begin
                		
                		correct=correct+1;
				`uvm_info("mult_scoreboard_correct", $sformatf("in expected : a : %0h, b: %0h ,operator_i: %0h ,short_signed_i : %0h", expected[0].op_a_i, expected[0].op_b_i,expected[0].operator_i,expected[0].short_signed_i), UVM_HIGH)
				
            		end
            		else begin
                		`uvm_info("mult_scoreboard_incorrect", "Transaction is incorrect", UVM_MEDIUM)
                		`uvm_info("mult_scoreboard_incorrect", $sformatf("Expected: %h, Actual: %h", expected[0].result_o, actual[0].result_o), UVM_LOW)
                		incorrect=incorrect+1;
				`uvm_info("mult_scoreboard_incorrect", $sformatf("in expected : a : %h, b: %h ,operator_i: %h ,short_signed_i : %h", expected[0].op_a_i, expected[0].op_b_i,expected[0].operator_i,expected[0].short_signed_i), UVM_LOW)

            		end
            		actual.pop_front();
   	 		expected.pop_front();
        	end
    	endtask 
	function void report_phase(uvm_phase  phase);
        super.report_phase(phase);
        `uvm_info("report_phase","*************mult_scoreboard**************************",UVM_LOW)
        `uvm_info("report_phase", $sformatf("total number of transactions: %0d",no_trans),UVM_LOW)
        `uvm_info("report_phase", $sformatf("total succesful transactions: %0d",correct),UVM_LOW)
        `uvm_info("report_phase", $sformatf("total failled transactions: %0d",incorrect),UVM_LOW) 
	`uvm_info("report_phase","******************************************************",UVM_LOW) 
  	endfunction
    
endclass



