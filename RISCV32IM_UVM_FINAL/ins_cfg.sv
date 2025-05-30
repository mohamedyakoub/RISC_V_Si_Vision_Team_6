class ins_cfg  extends uvm_object;

   `uvm_object_utils(ins_cfg)
   
   int inst_num=50000;
   
   function new(string name="ins_cfg");
	super.new(name);
   endfunction

endclass
