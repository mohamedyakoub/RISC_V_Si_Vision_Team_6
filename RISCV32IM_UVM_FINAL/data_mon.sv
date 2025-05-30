
   class data_mon extends uvm_monitor;
  
  `uvm_component_utils(data_mon)
  
  //--------------------------------------- 
  // Virtual Interface
  //--------------------------------------- 
  virtual data_if vif;
  
  //---------------------------------------
  // analysis port, to send the transaction to subscribers
  //---------------------------------------
  uvm_analysis_port #(data_seq_item) data_mon_port;
  
  //---------------------------------------
  //sequence_item class
  //---------------------------------------
 	data_seq_item  data_item;
  	data_seq_item  data_item_queue[$];
  //---------------------------------------
  //constructor
  //---------------------------------------
  function new(string name = "data_mon", uvm_component parent);
    super.new(name, parent); 
  endfunction
  
  //--------------------------------------- 
  // build phase
  //---------------------------------------
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual data_if)::get(this, "", "vif", vif))
      `uvm_fatal("NO_VIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
    data_mon_port = new("data_mon_port",this);
  endfunction
  //---------------------------------------
  // run phase
  //---------------------------------------
  virtual task run_phase(uvm_phase phase);
    forever begin
      
	data_item = data_seq_item::type_id::create("data_item"); 
	
      	@(posedge vif.clk iff (vif.data_req_o && vif.data_gnt_i)) ;
        data_item.data_we_o = vif.data_we_o;
        data_item.data_be_o = vif.data_be_o;
        data_item.data_addr_o = vif.data_addr_o;
	data_item.data_wdata_o = vif.data_wdata_o;
        if (data_item.data_we_o) begin
           data_item.data_wdata_o = vif.data_wdata_o;
	   `uvm_info("Data Monitor: ", {"Collect store data item: ", data_item.convert2string()}, UVM_HIGH)  
	   data_mon_port.write(data_item);
        end 
	data_item_queue.push_back(data_item);
	
        fork 
	 get_data();
	 `uvm_info("INS_MON",$sformatf(".............DATA MON : WAITING FOR VALID ........."), UVM_HIGH)
	 
        join_any 
	
    end 
  endtask
  task automatic get_data();
  @(posedge vif.clk iff vif.data_rvalid_i) ;
    	data_item = data_seq_item::type_id::create("data_item");
        data_item = data_item_queue.pop_front();
        if (!data_item.data_we_o) begin
	  
          data_item.data_rdata_i = vif.data_rdata_i;
      	  `uvm_info("Data Monitor: ", {"Collect load data item: ", data_item.convert2string()}, UVM_HIGH)   
          data_mon_port.write(data_item); 
	end 
       // `uvm_info("Data Monitor: ", {"Collect data item: ", data_item.convert2string()}, UVM_HIGH)   
        // data_mon_port.write(data_item);  
         

 
       
  endtask
     
 
endclass   
     

