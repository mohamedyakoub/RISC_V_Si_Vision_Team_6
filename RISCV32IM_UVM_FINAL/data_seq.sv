class data_seq extends uvm_sequence #(data_seq_item);
    `uvm_object_utils(data_seq)    
    data_seq_item req,rsp;
    data_seq_item q [$:2];
    bit [7:0] data_mem [int];
     data_agent_cfg cfg;
    //[31:0] data_mem [32];

    // variable for the memory size
    int data_mem_size;

    function new(string name="data_seq");
        super.new(name);
    endfunction

    virtual task pre_body();
        `uvm_info("Seq", "Starting pre body ", UVM_MEDIUM)
        cfg=data_agent_cfg::type_id::create("cfg");

        if(!uvm_config_db#(data_agent_cfg)::get(get_sequencer(), "", "data_agt_cfg", cfg))
            `uvm_fatal("NOCFG", "No configuration object found");
        
        data_mem_size = cfg.data_mem_size;
        `uvm_info("Seq", "Finished pre body ", UVM_MEDIUM)

    endtask

    virtual task body();

        `uvm_info("Seq", "Starting sequence", UVM_MEDIUM)
    	req = data_seq_item::type_id::create("req");
        rsp = data_seq_item::type_id::create("rsp");
	`uvm_info("Seq", "after create", UVM_MEDIUM)
        // Load the memory with some important values
        {data_mem[3],data_mem[2],data_mem[1],data_mem[0]} = 32'b0;               // zero
        {data_mem[7],data_mem[6],data_mem[5],data_mem[4]} = 32'b01111111_11111111_11111111_11111111;//{1'b0,{31{1'b1}}};     // max positive
        {data_mem[11],data_mem[10],data_mem[9],data_mem[8]} = {1'b1,{31{1'b0}}};   // max positive
	{data_mem[15],data_mem[14],data_mem[13],data_mem[12]} = {32{1'b1}};   // -1
	`uvm_info("Seq", "Before randomize", UVM_MEDIUM)
	//Load the Rest of the memory
        for(int i=16;i<data_mem_size; i=i+4) begin
            assert(rsp.randomize);
	
            {data_mem[i],data_mem[i+1],data_mem[i+2],data_mem[i+3]}= rsp.data_rdata_i;
        end

        forever begin
	    //Get the request
            start_item(req);
            finish_item(req);
	    get_response(req);
            `uvm_info("Seq", "start ", UVM_MEDIUM)
            //Start the response
            start_item(rsp);
            rsp.copy(req);
            rsp.data_rdata_i = 0;

			//Realliging the memory *Note an important step* 
            if(req.data_we_o) begin
               foreach(req.data_be_o[i]) begin
                   if(req.data_be_o[i]) begin
                       data_mem[req.data_addr_o+i] = req.data_wdata_o>>(i*8);
                   end
               end

            end

/*else begin
  // Example: manually force a response for a specific address
  if (req.data_addr_o == 32'h100) begin
    rsp.data_rdata_i = 32'h00FFAABB;
    `uvm_info("Seq", "Manual data sent: 0x00FFAABB", UVM_MEDIUM)
  end else begin
    foreach (req.data_be_o[i]) begin
      if (req.data_be_o[i]) begin
        rsp.data_rdata_i |= (data_mem[req.data_addr_o + i] << (i * 8));
      end
    end
  end
end */

            else begin

             //rsp.data_rdata_i = 32'h00FFAABB;
		        if (data_mem.exists(req.data_addr_o)) begin
		        foreach(req.data_be_o[i]) begin
		            if(req.data_be_o[i]) begin
		                rsp.data_rdata_i |= {24'b0,data_mem[req.data_addr_o+i]}<<(i*8);
		            end
		        end 
			end
			else	rsp.data_rdata_i = 32'h00FFAABB;
            end
            //Sending the response
            finish_item(rsp);
            


        end
        

        `uvm_info("Seq", "Finishing sequence", UVM_MEDIUM)
        
    endtask
endclass

