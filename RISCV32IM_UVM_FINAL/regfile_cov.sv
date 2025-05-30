class regfile_cov extends uvm_subscriber#(reg_file_sequence_item);
    `uvm_component_utils(regfile_cov)
   reg_file_sequence_item tr;
   localparam max_neg ={{1'b1},{31{1'b0}}};
   localparam max_pos ={{1'b0},{31{1'b1}}};
  
   covergroup regfile_CovGrp;

	//Cover that the data read from the register from port a [rs1] has used all these values 
        rdata_a_o_cp : coverpoint tr.rdata_a_o {
            bins MAXNEG = {max_neg};
            bins MAXPOS = {max_pos};
            bins ZERO = {31'b0};
            bins negative[2] = {[max_neg+1:{32{1'b1}}]};
            bins positive[2] = {[1:(max_pos-1)]};
            bins Rest = default;
        }
	//Cover that the data read from the register from port b [rs2] has used all these values 
        rdata_b_o_cp : coverpoint tr.rdata_b_o {
            bins MAXNEG = {max_neg};
            bins MAXPOS = {max_pos};
            bins ZERO = {31'b0};
            bins negative[2] = {[max_neg+1:{32{1'b1}}]};
            bins positive[2] = {[1:max_pos-1]};
            bins Rest = default;
        }
	//Cover that the data on port a [Load port] has crossed these values
        wdata_a_i_cp : coverpoint tr.wdata_a_i {
            bins MAXNEG = {max_neg};
            bins MAXPOS = {max_pos};
            bins ZERO = {31'b0};
            bins negative[2] = {[max_neg+1:{32{1'b1}}]};
            bins positive[2] = {[1:max_pos-1]};
            bins Rest = default;
        }
	//Cover that the data on port b [Result port] has crossed these values
        wdata_b_i_cp : coverpoint tr.wdata_b_i {
            bins MAXNEG = {max_neg};
            bins MAXPOS = {max_pos};
            bins ZERO = {31'b0};
            bins negative[2] = {[max_neg+1:{32{1'b1}}]};
            bins positive[2] = {[1:max_pos-1]};
            bins Rest = default;
        }
	// Cover that all the registers were read and read from port a [rs1]
        raddr_a_i_cp : coverpoint tr.raddr_a_i {
            bins regs[32] = {[0:31]};
	    bins reg_range[4]= {[1:7],[8:15],[16:23],[24:31]};
	}
	// Cover that all the registers were read and read from port b [rs2]
        raddr_b_i_cp : coverpoint tr.raddr_b_i {
            bins regs[32] = {[0:31]};
	    bins reg_range[4]= {[1:7],[8:15],[16:23],[24:31]};
        }
	// Cover that all the registers were used in load instructions
        waddr_a_i_cp : coverpoint tr.waddr_a_i {
            bins regs[31] = {[1:31]};
	    bins reg_range[2]= {[1:31]};
            illegal_bins ILLEGAL = {0};
        }
	// Cover that all the registers were used in Result write back
        waddr_b_i_cp : coverpoint tr.waddr_b_i {
            bins regs[31] = {[1:31]};
	    bins reg_range[3]= {[1:31]};
            illegal_bins ILLEGAL = {0};
        }
	// making sure that ranges of registers used the values in the data coverage
	r_port_a :cross raddr_a_i_cp, rdata_a_o_cp{ignore_bins reg_all= binsof (raddr_a_i_cp.regs) ;} 
        r_port_b :cross raddr_b_i_cp, rdata_b_o_cp {ignore_bins reg_all= binsof (raddr_b_i_cp.regs) ;}
            
        w_port_a :cross waddr_a_i_cp, wdata_a_i_cp {ignore_bins reg_all= binsof (waddr_a_i_cp.regs) ;}
        w_port_b :cross waddr_b_i_cp, wdata_b_i_cp {ignore_bins reg_all= binsof (waddr_b_i_cp.regs) ;}

       endgroup

    function new(string name="regfile_cov", uvm_component parent=null);
        super.new(name, parent);
        regfile_CovGrp=new();
    endfunction
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction
    function void write(T t);
        $cast(tr, t);
        regfile_CovGrp.sample();
    endfunction

endclass
