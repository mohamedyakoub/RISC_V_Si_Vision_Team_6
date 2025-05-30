class mult_ref_model extends uvm_subscriber #(mult_seq_item);
	
	`uvm_component_utils(mult_ref_model)
 
	uvm_analysis_port #(mult_seq_item) rf_m_port;
 
	function new(string name, uvm_component parent );
		super.new( name , parent );
	endfunction
 
	function void build_phase( uvm_phase phase );
		rf_m_port = new("rf_m_port", this);
		//rf_scb_port = new("rf_scb_port",this);
	endfunction
	
	function void write( mult_seq_item t);
		
		mult_seq_item mul_tr;
		logic signed [63:0] product ;
		logic signed [63:0] a_ext; 
  		logic signed [63:0] b_ext;
		`uvm_info("MULT_M", "Packet recieved", UVM_HIGH)
		$cast(mul_tr,t.clone());
		
		case(t.operator_i)
		
			MUL_MAC32 : begin	// mul     
				
 				product = signed'(t.op_a_i) * signed'(t.op_b_i);
				mul_tr.result_o =  product[31:0];
			end       
       
			MUL_H : begin 
				case (t.short_signed_i)
					2'b11 : begin	//mulh
						
						a_ext = {{32{t.op_a_i[31]}}, t.op_a_i};
						b_ext = {{32{t.op_b_i[31]}}, t.op_b_i};
						product = a_ext*b_ext;								
						mul_tr.result_o = product[63:32];
					end                                                 // mulh
					2'b01 : begin	//mulhsu
						
						a_ext = {{32{t.op_a_i[31]}}, t.op_a_i};
						b_ext = {32'b0, t.op_b_i};
						product = a_ext*b_ext;								
						mul_tr.result_o = product[63:32];
					end     
					2'b00 : begin	//mulhu
						
						a_ext = {32'b0, t.op_a_i};
						b_ext = {32'b0, t.op_b_i};
						product = a_ext*b_ext;								
						mul_tr.result_o = product[63:32];
					end     
                      
					
				endcase
			end
       
			
		endcase
        `uvm_info("MULT_M", $sformatf("Expected_result = %0h",mul_tr.result_o), UVM_HIGH)
		rf_m_port.write(mul_tr);
	endfunction
 
endclass:mult_ref_model 
