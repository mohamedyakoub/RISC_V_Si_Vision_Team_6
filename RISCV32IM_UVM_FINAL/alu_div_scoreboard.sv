`uvm_analysis_imp_decl(_exp_alu)
`uvm_analysis_imp_decl(_act_alu)
class  alu_div_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(alu_div_scoreboard)

    int no_trans,correct,incorrect;
    uvm_analysis_imp_exp_alu #(alu_div_seq_item,alu_div_scoreboard) exp_ap;
    uvm_analysis_imp_act_alu #(alu_div_seq_item,alu_div_scoreboard) act_ap;
    alu_div_seq_item actual[$:1],expected[$:1];
    

    function new(string name="alu_div_scoreboard", uvm_component parent=null);
        super.new(name, parent);
        exp_ap=new("exp_ap",this);
	    act_ap=new("act_ap",this);
    endfunction

    function  void build_phase(uvm_phase phase);
    super.build_phase(phase);
    endfunction

    virtual function  write_exp_alu(alu_div_seq_item item);
        `uvm_info("alu_div_scoreboard", "Packet received", UVM_HIGH)
        expected.push_back(item);
        
    endfunction

    virtual function  write_act_alu(alu_div_seq_item item);
        `uvm_info("alu_div_scoreboard", "Packet received", UVM_HIGH)
        actual.push_back(item);
        no_trans=no_trans+1;
       
    endfunction

    //runphase
    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        forever begin
            wait(actual.size()>0 && expected.size()>0);
            if(actual[0].result_o == expected[0].result_o) begin
               // `uvm_info("alu_div_scoreboard", "Transaction is correct", UVM_MEDIUM)
		      //  `uvm_info("alu_div_scoreboard", $sformatf("Expected: %h, Actual: %h", expected[0].result_o, actual[0].result_o), UVM_HIGH)
                correct=correct+1;
            end
            else begin
                `uvm_info("alu_div_scoreboard", "Transaction is incorrect", UVM_MEDIUM)
                `uvm_info("alu_div_scoreboard", $sformatf("Expected: %h, Actual: %h", expected[0].result_o, actual[0].result_o), UVM_HIGH)
                incorrect=incorrect+1;
            end
            actual.pop_front();
            expected.pop_front();
        end
    endtask 
        function void report_phase(uvm_phase  phase);
        super.report_phase(phase);
        `uvm_info("report_phase","*************alu_div_scoreboard**************************",UVM_LOW)
	`uvm_info("report_phase", $sformatf("total number of transactions: %0d",no_trans),UVM_LOW)
        `uvm_info("report_phase", $sformatf("total succesful transactions: %0d",correct),UVM_LOW)
        `uvm_info("report_phase", $sformatf("total failled transactions: %0d",incorrect),UVM_LOW) 
	`uvm_info("report_phase","******************************************************",UVM_LOW)  
  endfunction
endclass



