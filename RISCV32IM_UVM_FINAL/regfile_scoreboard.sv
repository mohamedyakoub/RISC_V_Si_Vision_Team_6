`uvm_analysis_imp_decl(_exp)
`uvm_analysis_imp_decl(_act)
class regfile_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(regfile_scoreboard)

    int no_trans,correct,incorrect;
    uvm_analysis_imp_exp#(reg_file_sequence_item,regfile_scoreboard) exp_ap;
    uvm_analysis_imp_act#(reg_file_sequence_item,regfile_scoreboard) act_ap;
    reg_file_sequence_item actual[$:1],expected[$:1];
    

    function new(string name="scoreboard", uvm_component parent=null);
        super.new(name, parent);
        exp_ap=new("exp_ap",this);
	act_ap=new("act_ap",this);
    endfunction

    function  void build_phase(uvm_phase phase);
    super.build_phase(phase);
    endfunction

	// caputring the expected from the refrence model
    virtual function  write_exp(reg_file_sequence_item item);
        
        expected.push_back(item);
        
    endfunction
	// caputring the actual from the monitor
    virtual function  write_act(reg_file_sequence_item item);
        
        actual.push_back(item);
        no_trans=no_trans+1;
        
    endfunction

    //runphase
    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        forever begin
        	//Wait until the refrence model and the monitor sends the data 
            wait(actual.size()>0 && expected.size()>0);
            //Comparing the data
            if(actual[0].rdata_a_o == expected[0].rdata_a_o && actual[0].rdata_b_o == expected[0].rdata_b_o) begin
                
                correct=correct+1;
            end
            else begin
                `uvm_info("REGF_Scoreboard", "Transaction is incorrect", UVM_MEDIUM)
                `uvm_info("REGF_Scoreboard", $sformatf("Expected: %0h, Actual: %0h", expected[0].rdata_a_o, actual[0].rdata_a_o), UVM_HIGH)
                incorrect=incorrect+1;
            end
            actual.pop_front();
            expected.pop_front();
        end
    endtask 
     function void report_phase(uvm_phase  phase);
        super.report_phase(phase);
	`uvm_info("report_phase","*************REGF_Scoreboard**************************",UVM_LOW)
        `uvm_info("report_phase", $sformatf("total number of transactions: %0d",no_trans),UVM_LOW)
        `uvm_info("report_phase", $sformatf("total succesful transactions: %0d",correct),UVM_LOW)
        `uvm_info("report_phase", $sformatf("total failled transactions: %0d",incorrect),UVM_LOW) 
	`uvm_info("report_phase","******************************************************",UVM_LOW) 
  endfunction
endclass



