class regfile_test extends base_test;
  `uvm_component_utils(regfile_test)

  function new(string name = "regfile_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    // Override the default instruction sequence with register test sequence
    set_type_override_by_type(inst_seq::get_type(), regfile_test_seq::get_type());

    super.build_phase(phase);
  endfunction

endclass

