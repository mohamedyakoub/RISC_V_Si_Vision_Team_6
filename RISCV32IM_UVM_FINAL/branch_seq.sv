class branch_seq extends inst_seq ;
    
    `uvm_object_utils(branch_seq)    

    function new(string name="branch_seq");
        super.new(name);
    endfunction

    virtual task pre_body();
        `uvm_info("branch_seq", "Starting pre body ", UVM_MEDIUM)
        cfg=ins_cfg::type_id::create("cfg");

        if(!uvm_config_db#(ins_cfg)::get(m_sequencer, "", "ins_seq_cfg", cfg))
            `uvm_fatal("NOCFG", "No configuration object found");
        
        inst_num = cfg.inst_num;
        `uvm_info("branch_seq", "Finished pre body ", UVM_MEDIUM)

    endtask
    
  task fill_mem();
    rsp = instr_seq_item::type_id::create("rsp");
    //Loading the instrucion memory based on some constraints
    `uvm_info("branch_seq", "Starting fill seq", UVM_MEDIUM)
    //beq  bne  blt  bge  bltu  bgeu
         

         // initialize    
        inst_mem[0]   = 32'h00500093; //addi x1, x0, 5   
        inst_mem[4]   = 32'h00a00113; //addi x2, x0, 10 
        inst_mem[8]   = 32'h01700193; //addi x3, x0, 23 
        inst_mem[12]  = 32'h04300213;  //addi x4, x0, 67
        inst_mem[16]  = 32'h09300293;  // addi x5, x0, 147
        inst_mem[20]  = 32'h00c00313;  // addi x6, x0, 12 
        inst_mem[24]  = 32'h05e00393;  //addi x7, x0, 94
        inst_mem[28]  = 32'h03400413;  // addi x8, x0, 52 
        inst_mem[32]  = 32'h00e00493;  //addi x9, x0, 14
        inst_mem[36]  = 32'h01b00513;  // addi x10, x0, 27
        inst_mem[40]  = 32'h02500593;  // addi x11, x0, 37
        inst_mem[44]  = 32'h06400613; //addi x12, x0 , 100     
        inst_mem[48]  = 32'h01e00693; //addi x13, x0 , 30
        inst_mem[52]  = 32'h02800713; //addi x14, x0 , 40
        inst_mem[56]  = 32'h07800793; //addi x15, x0 , 120
        inst_mem[60]  = 32'h05000813; //addi x16, x0 , 80
        inst_mem[64]  = 32'h03c00893; //addi x17, x0 , 60
        inst_mem[68]  = 32'h08200913; //addi x18, x0 , 130
        inst_mem[72]  = 32'h0c800993; //addi x19, x0 , 200
        inst_mem[76]  = 32'h0fa00a13; //addi x20, x0 , 250
        inst_mem[80]  = 32'h0b400a93; //addi x21, x0 , 180
        inst_mem[84]  = 32'h12c00b13; //addi x22, x0 , 300
        inst_mem[88]  = 32'h1f400b93; //addi x23, x0 , 500
        inst_mem[92]  = 32'h0f000c13; //addi x24, x0 , 240
        inst_mem[96]  = 32'h03200c93; //addi x25, x0 , 50
        inst_mem[100] = 32'h9c600d13; //addi x26, x0, 6598
        inst_mem[104] = 32'h67800d93; //addi x27, x0, 9848
        inst_mem[108] = 32'h9f300e13;  //addi x28, x0, 2547 
        inst_mem[112] = 32'h01d00e93; //addi x29, x0, 29
        inst_mem[116] = 32'h00700f13; //addi x30, x0, 7 
        inst_mem[120] = 32'h03d00f93; //addi x31, x0, 61

            inst_mem[124] = 32'h00ea_68b3;   //or x17,x20,x14
            inst_mem[128] = 32'h00ea_78b3;   //and x17,x20,x14
            inst_mem[132] = 32'h00ea_48b3;   //xor x17,x20,x14
                                             //                  50    0 true
            inst_mem[136]  = 32'h000c_9863;   //bne x25, x0 , 16  x25 != x0 singed
            inst_mem[140]  = 32'h0041_00b3;   //add x1,x2,x4
            inst_mem[144]  = 32'h40ea_08b3;   //sub x17,x20,x14
            inst_mem[148] = 32'h40ea_58b3;   //sra x17,x20,x14
            inst_mem[152] = 32'h00ea_18b3;   //sll x17,x20,x14  // target
            inst_mem[156] = 32'h00ea_68b3;   //or x17,x20,x14
            inst_mem[160] = 32'h00ea_78b3;   //and x17,x20,x14
            inst_mem[164] = 32'h00ea_48b3;   //xor x17,x20,x14
                                            //                     10   27  false 
            inst_mem[168] = 32'h00a1_0863;   //beq x2, x10 , 16     x2 == x10 singed edit 
            inst_mem[172] = 32'h00ea_68b3;   //or x17,x20,x14
            inst_mem[176] = 32'h40ea_58b3;   //sra x17,x20,x14 
            inst_mem[180] = 32'h40ea_08b3;   //sub x17,x20,x14
                                            //                     23  94 true 
            inst_mem[184] = 32'h0071_cc63;    //blt x3, x7 , 24     x3 < x7  singed 0x0071c863
            inst_mem[188] = 32'h00ea_48b3;   //xor x17,x20,x14
            inst_mem[192] = 32'h00ea_18b3;   //sll x17,x20,x14
            inst_mem[196] = 32'h00ea_68b3;   //or x17,x20,x14  //target 
            inst_mem[200] = 32'h00ea_78b3;   //and x17,x20,x14 
                                            //                   37    250  false 
            inst_mem[204] = 32'h0145d863;   //bge x11, x20 , 16  x11 >= x20  singed
            inst_mem[208] = 32'h00ea_28b3;   //slt x17,x20,x14
            inst_mem[212] = 32'h00ea_68b3;   //or x17,x20,x14
            inst_mem[216] = 32'h40ea_58b3;   //sra x17,x20,x14
                                            //                     29  2547  true 
            inst_mem[220] = 32'h01ce_e863;   //bltu x29, x28 , 16   x29 < x28  singed
            inst_mem[224] = 32'h00ea_68b3;   //or x17,x20,x14
            inst_mem[228] = 32'h40ea_08b3;   //sub x17,x20,x14
            inst_mem[232] = 32'h028a_0893;   //addi x17,x20,40
                                            //                    10  61  false
            inst_mem[236] = 32'h01f1_7863;   //bgeu x2, x31 , 16  x2 >= x31  singed
            inst_mem[240]  = 32'h0041_00b3;   //add x1,x2,x4
            inst_mem[244] = 32'h00ea_18b3;   //sll x17,x20,x14
            inst_mem[248] = 32'h00ea_68b3;   //or x17,x20,x14
            inst_mem[252] = 32'h00ea_78b3;   //and x17,x20,x14
		
	    inst_mem[256] = 32'h0145d863;   //bge x11, x20 , 16  x11 >= x20  singed
            inst_mem[260] = 32'h00ea_28b3;   //slt x17,x20,x14   //target
            inst_mem[264] = 32'h00ea_68b3;   //or x17,x20,x14
            inst_mem[268] = 32'h40ea_58b3;   //sra x17,x20,x14
            inst_mem[272] = 32'h00ea_68b3;   //or x17,x20,x14
            inst_mem[276] = 32'h40ea_08b3;   //sub x17,x20,x14
            inst_mem[280] = 32'h028a_0893;   //addi x17,x20,40
           
            inst_mem[284] = 32'h010000ef;    // jal x1,16        x1 =  16+284+4 
            inst_mem[288] = 32'h00ea_28b3;   //slt x17,x20,x14   
            inst_mem[292] = 32'h00ea_68b3;   //or x17,x20,x14
            inst_mem[296] = 32'h40ea_58b3;   //sra x17,x20,x14
            inst_mem[300] = 32'h00ea_68b3;   //or x17,x20,x14    //target
            inst_mem[304] = 32'h40ea_08b3;   //sub x17,x20,x14   
            inst_mem[308] = 32'h0140_0113;   //addi x2,x0,16

	    inst_mem[312] = 32'h14c00167;    //jalr x2,332(x0)    //x2 = x0(0) + imm(332) + 4
	    inst_mem[316] = 32'h0041_00b3;   //add x1,x2,x4
            inst_mem[320] = 32'h40ea_08b3;   //sub x17,x20,x14
            inst_mem[324] = 32'h40ea_58b3;   //sra x17,x20,x14
            inst_mem[328] = 32'h00ea_18b3;   //sll x17,x20,x14 
            inst_mem[332] = 32'h00ea_68b3;   //or x17,x20,x14  //target  
            inst_mem[336] = 32'h00ea_78b3;   //and x17,x20,x14  
            inst_mem[340] = 32'h00ea_48b3;   //xor x17,x20,x14 

	    



	    for(int i=344;i<inst_num; i=i+4) begin
		    assert(rsp.randomize with {  !(opcode inside {7'b1100011,7'b1101111,7'b1100111,7'b0000011});
					});
		                                
		    inst_mem[i] = rsp.instr_rdata_i;
	end

        `uvm_info("branch_seq", "finished fill seq", UVM_MEDIUM)
  endtask
  
  
endclass:branch_seq





