// Virtual sequence
class virtual_seq extends uvm_sequence #(instr_seq_item);
  inst_seq Iseq;
  data_seq Dseq;  
  
  instruction_sequencer seqr_I;
  data_seqr seqr_D;
  `uvm_object_utils(virtual_seq)
  `uvm_declare_p_sequencer(virtual_sequencer)
  
  function new (string name = "virtual_seq");
    super.new(name);
  endfunction
  
  task body();
    `uvm_info(get_type_name(), "virtual_seq: Inside Body", UVM_LOW);
    Iseq = inst_seq::type_id::create("Iseq");
    Dseq = data_seq::type_id::create("Dseq");

    fork  
    Iseq.start(p_sequencer.seqr_I);
    Dseq.start(p_sequencer.seqr_D);
    join_any
    
  endtask
endclass

