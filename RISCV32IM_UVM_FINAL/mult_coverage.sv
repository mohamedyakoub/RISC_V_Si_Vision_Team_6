class mult_coverage extends uvm_component;
	`uvm_component_utils(mult_coverage)
	//Analysis Implementation port
	uvm_analysis_imp #(mult_seq_item, mult_coverage) mult_cov_port;
	mult_seq_item tr;
  
	//COVER GROUP
	covergroup cg;
		//-------------------------------------------//
		//               Coverpoints                 // 
		//-------------------------------------------//
		operator_i : coverpoint tr.operator_i { bins en_values[] = {MUL_MAC32, MUL_H}; }  //0,6
		
		short_signed_i: coverpoint tr.short_signed_i 
		{ 
			bins mulh = {3};
			bins mulhsu = {1};
			bins mulhu = {0};
			 
		}  
		
		/*sign_cp: coverpoint {tr.op_a_i[31], tr.op_b_i[31], tr.result_o[31]}
		{
        		// Signed multiplication sign rules:        	                
        		bins pos_pos_pos = {3'b000}; // - pos × pos → pos
        		bins pos_neg_neg = {3'b011}; // - pos × neg → neg
        		bins neg_pos_neg = {3'b101}; // - neg × pos → neg
        		bins neg_neg_pos = {3'b110}; // - neg × neg → pos
        		// Illegal sign combinations (should never occur)
        		//illegal_bins illegal = {3'b001, 3'b010, 3'b100, 3'b111};
    		}*/
		
		op_a_i: coverpoint tr.op_a_i 
		{
    			// Single-value bins
    			bins zero      = {32'h0};
    			bins one       = {32'h1};
    			bins max_neg     = {32'hFFFFFFFF};  // -1
    			bins min_neg     = {32'h80000000};  // -2^31
    			bins max_pos     = {32'h7FFFFFFF};  // (2^31)-1
    
    			// Range bins 
    			bins pos_range = {[32'h2 : 32'h7FFF_FFFE]};  // 2 to (2^31)-2
    
    			// Negative numbers 
    			bins neg_range = {[32'h8000_0001 : 32'hFFFF_FFFE]}; // (-2^31)+1 to -2
    
		}

		op_b_i: coverpoint tr.op_b_i 
		{
    			// Single-value bins
    			bins zero      = {32'h0};
    			bins one       = {32'h1};
    			bins max_neg     = {32'hFFFFFFFF};  // -1
    			bins min_neg     = {32'h80000000};  // -2^31
    			bins max_pos     = {32'h7FFFFFFF};  // (2^31)-1
    
    			// Range bins 
    			bins pos_range = {[32'h2 : 32'h7FFF_FFFE]};  // 2 to (2^31)-2
    
    			// Negative numbers 
    			bins neg_range = {[32'h8000_0001 : 32'hFFFF_FFFE]}; // (-2^31)+1 to -2
		}
		
		result_o: coverpoint tr.result_o 
		{
    			// Single-value bins
    			bins zero      = {32'h0};
    			bins one       = {32'h1};
    			bins max_neg     = {32'hFFFFFFFF};  // -1
    			bins min_neg     = {32'h80000000};  // -2^31
    			bins max_pos     = {32'h7FFFFFFF};  // (2^31)-1
    
    			// Range bins
    			bins pos_range = {[32'h2 : 32'h7FFF_FFFE]};  // 2 to (2^31)-2
    
    			// Negative numbers 
    			bins neg_range = {[32'h8000_0001 : 32'hFFFF_FFFE]}; // (-2^31)+1 to -2
        	}
		
		//-------------------------------------------//
		//               Cross Coverage              // 
		//-------------------------------------------//
		
		opcode: cross operator_i, short_signed_i 
		{
			bins mul_opcode = binsof(operator_i) intersect {MUL_MAC32};			
			bins mulh_opcode = binsof(short_signed_i) intersect {3} && binsof(operator_i) intersect {MUL_H};
			bins mulhsu_opcode = binsof(short_signed_i) intersect {1} && binsof(operator_i) intersect {MUL_H};
			bins mulhu_opcode = binsof(short_signed_i) intersect {0} && binsof(operator_i) intersect {MUL_H};
			
		}
		

		op_a_x_op_b: cross op_a_i, op_b_i
		{			
			bins pos_x_neg = binsof(op_a_i.neg_range) && binsof(op_b_i.pos_range)||binsof(op_a_i.pos_range) && binsof(op_b_i.neg_range);
			bins pos_x_pos = binsof(op_a_i.pos_range) && binsof(op_b_i.pos_range);

			bins neg_x_neg = binsof(op_a_i.neg_range) && binsof(op_b_i.neg_range); //intersect {[32'h8000_0001 : 32'hFFFF_FFFE]}; 
			
			ignore_bins ignored_a_max_neg = binsof(op_a_i.max_neg);
			ignore_bins ignored_a_min_neg = binsof(op_a_i.min_neg);
			ignore_bins ignored_a_max_pos = binsof(op_a_i.max_pos);
			ignore_bins ignored_a_zero = binsof(op_a_i.zero);
			ignore_bins ignored_a_one = binsof(op_a_i.one);
			
			ignore_bins ignored_b_max_neg = binsof(op_b_i.max_neg);
			ignore_bins ignored_b_min_neg = binsof(op_b_i.min_neg);
			ignore_bins ignored_b_max_pos = binsof(op_b_i.max_pos);
			ignore_bins ignored_b_zero = binsof(op_b_i.zero);
			ignore_bins ignored_b_one = binsof(op_b_i.one);
		
			//bins max_neg     = {32'hFFFFFFFF};  // -1
    			//bins min_neg     = {32'h80000000};  // -2^31
    			//bins max_pos     = {32'h7FFFFFFF};  
			
		}
		
		opcode_x_op_a_x_op_b: cross opcode ,op_a_x_op_b;
				
		//op_a_x_opcode: cross opcode, op_a_i;

		//op_b_x_opcode: cross opcode, op_b_i;
		
		//result_x_opcode: cross opcode, result_o; 

		
	endgroup	
  
	function new(string name="mult_coverage",uvm_component parent);
		super.new(name,parent);
		mult_cov_port = new("mult_cov_port",this);
		cg = new();//create an instance of cover group
	endfunction
  
  
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		tr = mult_seq_item::type_id::create("tr");
	endfunction
  
	function void write(mult_seq_item t);
		tr = t;
         //sampling of the covergroup
		cg.sample();
	endfunction
  
endclass:mult_coverage
