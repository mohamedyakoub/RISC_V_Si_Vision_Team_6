class data_cov extends uvm_subscriber#(data_seq_item);
    // UVM Factiry registeration
    `uvm_component_utils(data_cov)

    // Local variable decleration
    data_seq_item trans;

    // Cover group decleration
    covergroup data_covGrp;
        cp_data_be : coverpoint trans.data_be_o {
            bins single_byte[] = {1,2,4,8};     // 0001, 0010, 0100, 1000
            bins halfword[] = {4'b0011, 4'b1100,4'b0110}; // 16-bit access
            bins word = {4'b1111};              // 32-bit access
        }
	// Data Address range coverage
	cp_data_addr : coverpoint trans.data_addr_o {
	    bins min_addr = {32'h0000_0000};
	   // bins max_addr = {32'hFFFF_FFFF};
	    bins mid_addr = {[32'h0000_0001 : 32'hFFFE_FFFE]};
	}
	
	// Read and write coverage
        cp_rw : coverpoint trans.data_we_o{
	    bins read  = {0}; // Read transaction
	    bins write = {1}; // Write transaction
	}
	// Byte enables vs write/read
        cross_be_rw : cross cp_data_be, cp_rw;


        // Read and write  with the req signal coverage
        // cross_rw : cross trans.data_req_o, cp_rw;

        // Grant vs. request
        // cross_req_grant : cross trans.data_req_o, trans.data_gnt_i;

        // Read access vs. response valid and Write access vs. response valid
        /* cross_read_write_response : cross trans.data_we_o, trans.data_rvalid_i {
          bins read_response = binsof(data_we_o) intersect {0} && binsof(data_rvalid_i) intersect {1};
          bins write_response = binsof(data_we_o) intersect {1} && binsof(data_rvalid_i) intersect {1};
        } */

    endgroup : data_covGrp

    // Constructor
    function new(string name="data_cov", uvm_component parent=null);
        super.new(name, parent);
        data_covGrp=new();
    endfunction

    // ------- Build phase -------
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction

    /* ------- Sample function -------
        Function description: This function takes sequence item, cast it to to the local transaction and sample it. 
    */
    function void write(T t);
        $cast(trans, t);
        data_covGrp.sample();
    endfunction

endclass
// ------- EOF -------
