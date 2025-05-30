class load_store_test extends base_test;
`uvm_component_utils(load_store_test)

    function new(string name="load_store_test", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
      set_type_override_by_type(inst_seq::get_type(),load_store_seq::get_type());
        super.build_phase(phase);
    endfunction


endclass
