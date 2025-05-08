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

    virtual function  write_exp(reg_file_sequence_item item);
        `uvm_info("Scoreboard", "Packet received", UVM_HIGH)
        expected.push_back(item);
        //item.print();
    endfunction

    virtual function  write_act(reg_file_sequence_item item);
        `uvm_info("Scoreboard", "Packet received", UVM_HIGH)
        actual.push_back(item);
        no_trans=no_trans+1;
        //item.print();
    endfunction

    //runphase
    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        forever begin
            wait(actual.size()>0 && expected.size()>0);
            if(actual[0].rdata_a_o == expected[0].rdata_a_o && actual[0].rdata_b_o == expected[0].rdata_b_o) begin
                `uvm_info("REGF_Scoreboard", "Transaction is correct", UVM_MEDIUM)
		`uvm_info("REGF_Scoreboard", $sformatf("Expected: %0h, Actual: %0h", expected[0].rdata_a_o, actual[0].rdata_a_o), UVM_HIGH)
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
    
endclass



