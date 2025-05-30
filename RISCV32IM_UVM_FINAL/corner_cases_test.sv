class corner_cases_test extends base_test;
`uvm_component_utils(corner_cases_test)

    function new(string name="corner_cases_test", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        set_type_override_by_type(inst_seq::get_type(),corner_cases_seq::get_type());
	inst_num=9000;
        super.build_phase(phase);
    endfunction


endclass
