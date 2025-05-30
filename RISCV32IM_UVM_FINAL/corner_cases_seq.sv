class corner_cases_seq extends inst_seq;
    `uvm_object_utils(corner_cases_seq)

    function new(string name="corner_cases_seq");
        super.new(name);
    endfunction

     task automatic fill_mem();
        `uvm_info("Seq", "Starting fill_inst_mem in corner", UVM_MEDIUM)
         rsp = instr_seq_item::type_id::create("rsp");
         
	     assert(rsp.randomize with { opcode==7'b0000011;
	                                    funct3== 3'b10;
	                                    rs1== 5'b00;
	                                    rd==1;
	                                    imm12 ==12'h4;}); //max positive in reg 1

	        inst_mem[0] = rsp.instr_rdata_i;
	     assert(rsp.randomize with { opcode==7'b0000011;
	                                    funct3== 3'b10;
	                                    rs1== 5'b00;
	                                    rd==2;
	                                    imm12 ==12'h8;}); //max negative in reg 2

	        inst_mem[4] = rsp.instr_rdata_i;
	      assert(rsp.randomize with { opcode==7'b0000011;
	                                    funct3== 3'b10;
	                                    rs1== 5'b00;
	                                    rd==3;
	                                    imm12 ==12'd12;}); //-1 in reg 3

	        inst_mem[8] = rsp.instr_rdata_i;
	        assert(rsp.randomize with { opcode==7'b0000011;
	                                    funct3== 3'b10;
	                                    rs1== 5'b00;
	                                    rd==1;
	                                    imm12 ==12'h4;}); //max positive in reg 1

	        inst_mem[12] = rsp.instr_rdata_i;
	     assert(rsp.randomize with { opcode==7'b0000011;
	                                    funct3== 3'b10;
	                                    rs1== 5'b00;
	                                    rd==2;
	                                    imm12 ==12'h8;}); //max negative in reg 2

	        inst_mem[16] = rsp.instr_rdata_i;
	      assert(rsp.randomize with { opcode==7'b0000011;
	                                    funct3== 3'b10;
	                                    rs1== 5'b00;
	                                    rd==3;
	                                    imm12 ==12'd12;}); //-1 in reg 3

	        inst_mem[20] = rsp.instr_rdata_i;
	     
        for(int i=24;i<32*4; i=i+4) begin
            assert(rsp.randomize with { opcode==7'b0000011;
                                        funct3== 3'b10;
                                        rs1== 5'b00;
					!(rd inside {5'd0,5'd1,5'd2,5'd3});
                                        imm12 inside{12'h0,12'h4,12'h8,12'd12};});

            inst_mem[i] = rsp.instr_rdata_i;
        end 
	    assert(rsp.randomize with {  (opcode ==7'b110011);
					rd inside {5'd29,5'd30,5'd28,5'd31};
					funct3 ==3'h4; 
					funct7==7'h1;                                 				
					rs1 ==2;
					rs2 ==3;   
										
					});
                                        // if(opcode==7'b1100011 && funct3 inside{ 2'h04,2'h05,2'h6,2'h7}) 
                                        // {rs1 dist {R_TYPE := 25, I_TYPE_0 := 25 , I_TYPE_1 := 10, I_TYPE_2 := 5,
                                        // S_TYPE := 10, B_TYPE := 10 , U_TYPE_0 := 5 , U_TYPE_1 := 5 , J_TYPE := 5 };  }});
            inst_mem[32*4] = rsp.instr_rdata_i;
    assert(rsp.randomize with {  (opcode ==7'b110011);
					funct3 ==3'h6; 
					funct7==7'h1;                                 				
					rs1 ==2;
					rs2 ==3;   
					rd inside {5'd29,5'd30,5'd28,5'd31};					
					});
                                        // if(opcode==7'b1100011 && funct3 inside{ 2'h04,2'h05,2'h6,2'h7}) 
                                        // {rs1 dist {R_TYPE := 25, I_TYPE_0 := 25 , I_TYPE_1 := 10, I_TYPE_2 := 5,
                                        // S_TYPE := 10, B_TYPE := 10 , U_TYPE_0 := 5 , U_TYPE_1 := 5 , J_TYPE := 5 };  }});
            inst_mem[33*4] = rsp.instr_rdata_i;
    assert(rsp.randomize with {  (opcode ==7'b110011);
					funct3 ==3'h0; 
					funct7==7'h1;                                 				
					rs1 ==1;
					rs2 ==1;   
					rd inside {5'd29,5'd30,5'd28,5'd31};					
					});
                                        // if(opcode==7'b1100011 && funct3 inside{ 2'h04,2'h05,2'h6,2'h7}) 
                                        // {rs1 dist {R_TYPE := 25, I_TYPE_0 := 25 , I_TYPE_1 := 10, I_TYPE_2 := 5,
                                        // S_TYPE := 10, B_TYPE := 10 , U_TYPE_0 := 5 , U_TYPE_1 := 5 , J_TYPE := 5 };  }});
            inst_mem[34*4] = rsp.instr_rdata_i;
        for(int i=35*4;i<500*4; i=i+4) begin
            assert(rsp.randomize with {  !(opcode inside {7'b1100011,7'b1101111,7'b1100111,7'b0000011});
                                        rd inside {5'd29,5'd30,5'd28,5'd31};
					if(opcode==7'b110011) {
						  
						  rs1 dist {0:/40 , 1:/40, 2:/40, 3:/40, [4:$]:/20};
						  rs2 dist {0:/40 , 1:/40, 2:/40, 3:/40, [4:$]:/20};   }
										
					});
                                        
            inst_mem[i] = rsp.instr_rdata_i;
        end
	for(int i=500*4;i<1000*4; i=i+4) begin
            assert(rsp.randomize with {  !(opcode inside {7'b1100011,7'b1101111,7'b1100111,7'b0000011});
                                      
					if(opcode==7'b110011) {
						  rs1 dist {2:/40, 3:/40};
						  rs2 dist {2:/40, 3:/40}; 
					 	  rd inside {5'd29,5'd30,5'd28,5'd31};  }
										
					});
                                        // if(opcode==7'b1100011 && funct3 inside{ 2'h04,2'h05,2'h6,2'h7}) 
                                        // {rs1 dist {R_TYPE := 25, I_TYPE_0 := 25 , I_TYPE_1 := 10, I_TYPE_2 := 5,
                                        // S_TYPE := 10, B_TYPE := 10 , U_TYPE_0 := 5 , U_TYPE_1 := 5 , J_TYPE := 5 };  }});
            inst_mem[i] = rsp.instr_rdata_i;
        end
	for(int i=1000*4;i<1500*4; i=i+4) begin
            assert(rsp.randomize with {  !(opcode inside {7'b1100011,7'b1101111,7'b1100111,7'b0000011});
                                        
					if(opcode==7'b110011) {
						  rs1 dist {2:/40, 1:/40};
						  rs2 dist {2:/40, 1:/40};   
						  rd inside {5'd29,5'd30,5'd28,5'd31};}
										
					});
                                        // if(opcode==7'b1100011 && funct3 inside{ 2'h04,2'h05,2'h6,2'h7}) 
                                        // {rs1 dist {R_TYPE := 25, I_TYPE_0 := 25 , I_TYPE_1 := 10, I_TYPE_2 := 5,
                                        // S_TYPE := 10, B_TYPE := 10 , U_TYPE_0 := 5 , U_TYPE_1 := 5 , J_TYPE := 5 };  }});
            inst_mem[i] = rsp.instr_rdata_i;
        end
	
	for(int i=1500*4;i<inst_num; i=i+4) begin
		    assert(rsp.randomize with {  !(opcode inside {7'b1100011,7'b1101111,7'b1100111,7'b0000011});
		                                
						if(opcode==7'b110011) {
							  rs1 dist {0:/40 , 1:/40, 2:/40, 3:/40, [4:$]:/20};
							  rs2 dist {0:/40 , 1:/40, 2:/40, 3:/40, [4:$]:/20};
							  rd inside {5'd29,5'd30,5'd28,5'd31};   }
											
						});
		                                
		    inst_mem[i] = rsp.instr_rdata_i;
	end
        `uvm_info("Seq", "Finished fill_inst_mem", UVM_MEDIUM)
    endtask //automatic

   
endclass

