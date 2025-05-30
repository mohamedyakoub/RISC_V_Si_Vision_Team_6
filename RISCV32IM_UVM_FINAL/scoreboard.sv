`uvm_analysis_imp_decl( _data_mon_export )
`uvm_analysis_imp_decl( _inst_mon_export )
`uvm_analysis_imp_decl( _rf_mon_export )
class scoreboard extends uvm_component;
  //---------------------------------------
  // factory registeration 
  //---------------------------------------
  `uvm_component_utils(scoreboard)
   //---------------------------------------
  // analysis ports
  //---------------------------------------
  uvm_analysis_imp_data_mon_export #(data_seq_item, scoreboard)  data_mon_export;
  uvm_analysis_imp_inst_mon_export #(instr_seq_item, scoreboard) inst_mon_export;
  uvm_analysis_imp_rf_mon_export #(reg_file_sequence_item, scoreboard) rf_mon_export;
  //---------------------------------------
  // Internal Regfile to save each instruction result
  //---------------------------------------
  bit [31:0] expected_value_RegFile[0:31];
  //---------------------------------------
  // TLM FIFOs to store the transactions
  //--------------------------------------- 
 
  instr_seq_item inst_q[$],inst_item_old,inst_item;
  int count_dependent_inst = 2; // to count the instructions that depends on load 
  byte load_cycle;
  //---------------------------------------
  //  structs to save the expected results
  //---------------------------------------
  typedef struct packed  { 
    logic [31:0] rd_data;
    logic [4:0] rd_addr;
    int count;
  }expctd_rf_data;
  
  typedef struct packed  { 
    logic [31:0] addr;
    logic [31:0] data;
    bit [3:0] byte_enable; // enables the byte to be read/write
    instr_type inst_type;
    bit[1:0] offset;
    logic[4:0] rd; // register to be written
    bit add_cycle; // if the instruction is half word or word and the address is not aligned
  }expctd_mem_data;
  
  
  //---------------------------------------
  // queues to store the expected values to be used in comparison with the reg file and data memory 
  //---------------------------------------
  expctd_mem_data store_mem_qu[$], written_store_mem_qu[$] ,load_mem_qu[$]; 
  expctd_rf_data expected_data_to_rf_qu[$] , expected_load_to_rf_qu[$], written_data_to_rf_qu[$], written_load_data_to_rf_qu[$] ;
  //---------------------------------------
  // queue to save the data loaded from the memory to the internal reg file 
  //---------------------------------------
  
  
  //---------------------------------------
  //  save the expected address for the branch and jump instructions 
  //---------------------------------------
  bit check_pc ,serve_load, misaligned_load;
  logic[31:0] expected_pc;
  //---------------------------------------
  // correct and incorrect counters for load - execution - store
  //---------------------------------------
  	int num_inst,num_crr_load, num_incrr_load;
 	int num_crr_ex, num_incrr_ex;
	int num_crr_store, num_incrr_store;
	int num_branch_nd_jump;
  //---------------------------------------
  // constructor
  //---------------------------------------
  function new(string name="scoreboard",uvm_component parent);
    super.new(name,parent);
  endfunction
  //--------------------------------------- 
  // build phase
  //---------------------------------------
  
  function void build_phase(uvm_phase phase);
	super.build_phase(phase);
    data_mon_export = new("data_mon_export",this);
    inst_mon_export = new("inst_mon_export",this);
    rf_mon_export = new("rf_mon_export",this); 
    
  endfunction
  //---------------------------------------
  // write tasks - recives the items from monitors and pushes into queues
  //---------------------------------------
  function void write_inst_mon_export (instr_seq_item inst_item);
    
    inst_q.push_back(inst_item);
    num_inst++;
    `uvm_info("scoreboard",$sformatf("Get: addr 0x%0x\tinst 0x%0x,inst_type %0s",inst_item.instr_addr_o,inst_item.instr_rdata_i,inst_item.inst_type), UVM_HIGH)
    //extract data ,calculate the result
    // write the result to the local register file also the save the data and address of the result in a queue of struct
    // if the instruction is load wait untill get a flag from the memory then write the data to the local rf
    //if it is store calculate the address and get the data from the regester file, push to a struct
  endfunction 
  
  function void write_rf_mon_export (reg_file_sequence_item rf_item);
    if (rf_item.we_a_i ) begin
      expctd_rf_data load_data;
      load_data.rd_addr = rf_item.waddr_a_i;
      load_data.rd_data = rf_item.wdata_a_i;
      `uvm_info("scoreboard",$sformatf("Load from memory to RegFile : Address: 0x%0h\tData: 0x%0h ",rf_item.waddr_a_i,rf_item.wdata_a_i), UVM_HIGH)
       written_load_data_to_rf_qu.push_back(load_data);
      
    end
    if (rf_item.we_b_i) begin
      expctd_rf_data result;
      result.rd_addr = rf_item.waddr_b_i;
      result.rd_data = rf_item.wdata_b_i;
      `uvm_info("scoreboard",$sformatf("Results from execution to RegFile : Address: 0x%0h\tData: 0x%0h ",rf_item.waddr_b_i,rf_item.wdata_b_i), UVM_HIGH)
       written_data_to_rf_qu.push_back(result);
      
    end 
  endfunction
  
  function void write_data_mon_export (data_seq_item data_item);
    if (data_item.data_we_o) begin
      expctd_mem_data store_data;
      store_data.byte_enable = data_item.data_be_o;
      store_data.addr = data_item.data_addr_o ;
      store_data.data = data_item.data_wdata_o ;
      `uvm_info("scoreboard",$sformatf("MEMORY : store data written to memory\t Memory : Address 0x%0h\tData 0x%0h\t Bytes %b  ",store_data.addr,store_data.data,store_data.byte_enable), UVM_HIGH)
      written_store_mem_qu.push_back(store_data);   
    end
    else if (data_item.data_we_o == 0 ) begin
      expctd_mem_data load_data;
      load_data.byte_enable = data_item.data_be_o;
      load_data.addr = data_item.data_addr_o ;
      load_data.data = data_item.data_rdata_i ;
      `uvm_info("scoreboard",$sformatf("MEMORY : load data from memory\t Memory : Address 0x%0h\tData 0x%0h\t Bytes %b  ",load_data.addr,load_data.data,load_data.byte_enable), UVM_HIGH)
      load_mem_qu.push_back(load_data);
    end 
  endfunction
  //---------------------------------------
  // run phase
  //---------------------------------------
  //byte load_cycle;
  virtual task run_phase(uvm_phase phase);  
    super.run_phase(phase);
          
    forever begin
      wait(inst_q.size()>0);
      inst_item = inst_q.pop_front();
          
      execute(inst_item);
      if (inst_item.opcode == S_TYPE)
	      compare_store();
      else if (inst_item.opcode == I_TYPE_1) begin 
	     compare_load (); 	
      end       
      else if ( (inst_item.opcode != I_TYPE_1) && (inst_item.opcode != S_TYPE) && (inst_item.opcode != B_TYPE)) 
		 compare_arithmatic ();
      
      end
  endtask
  //---------------------------------------
  // EXECUTE     
  //---------------------------------------
  task execute(input instr_seq_item inst_item);
    logic [31:0] rd_data, extend_imm, rs1_data, rs2_data;
    int count = 0 ;
    `uvm_info("scoreboard",$sformatf("/*******************EXECUTION  : instruction %0s ********************/",inst_item.inst_type), UVM_HIGH)
    get_operands(inst_item, rs1_data, rs2_data, extend_imm);
    get_expected(inst_item.opcode,inst_item.inst_type, rs1_data, rs2_data, extend_imm , inst_item.instr_addr_o,rd_data,inst_item.rd,count);
    if (inst_item.opcode != I_TYPE_1)
       save_results(inst_item.opcode, rd_data, inst_item.rd,count);	
    //check pc claculated 
    if (inst_item.opcode == B_TYPE || inst_item.opcode == J_TYPE || inst_item.inst_type == JALR) begin  
    	num_branch_nd_jump++; 
    	verify_pc();
    end
  endtask
  //---------------------------------------
  // get_operands data     
  //---------------------------------------     
  task automatic get_operands(input instr_seq_item inst_item , output bit[31:0] rs1_data ,rs2_data,extend_imm);
      extend_imm = inst_item.Extend();
      
      if ( (inst_item.opcode !=  U_TYPE_0) && (inst_item.opcode !=  U_TYPE_1) && (inst_item.opcode != J_TYPE) ) begin
        rs1_data = expected_value_RegFile[inst_item.rs1];
        if ( (inst_item.opcode !=  I_TYPE_0) && (inst_item.opcode !=  I_TYPE_1) && (inst_item.opcode != I_TYPE_2) )
          rs2_data = expected_value_RegFile[inst_item.rs2];
      end
       `uvm_info("scoreboard",$sformatf("Get_op:inst %0s RS1 0x%0h\t0x%0h , RS2 0x%0h\t0x%0h , RD 0x%0h  extend_imm 0x%0h ",inst_item.inst_type,inst_item.rs1,rs1_data,inst_item.rs2,rs2_data,inst_item.rd,extend_imm), UVM_HIGH)
      
  endtask
  
  //---------------------------------------
  // get_expected result     
  //--------------------------------------- 
  //int count;  // to count number of cycles for multiplication and division        
  task automatic get_expected(input bit[6:0] opcode,instr_type inst_type ,logic[31:0] rs1_data ,rs2_data,extend_imm, addr,output  logic[31:0]rd_data,input logic[4:0] rd,output int count);
  	logic signed [63:0] product;
  	logic signed [63:0] a_ext;
  	logic signed [63:0] b_ext;
  	count = 0;
    case (inst_type)
      ADD: rd_data = rs1_data + rs2_data;
      
      SUB: rd_data = rs1_data - rs2_data;
      
      OR: rd_data = rs1_data | rs2_data;
        
      AND: rd_data = rs1_data & rs2_data;
        
      XOR: rd_data = rs1_data ^ rs2_data;
      
      SLT: rd_data = ( signed'(rs1_data) < signed'(rs2_data) ) ? 1 : 0;
        
      SLTU: rd_data = ( rs1_data < rs2_data ) ? 1 : 0;
      
      SLL: rd_data = rs1_data << rs2_data[4:0];
        
      SRL: rd_data = rs1_data >> rs2_data[4:0];
        
      SRA: rd_data = signed'(signed'(rs1_data) >>> rs2_data[4:0]);
          
      ADDI: rd_data = rs1_data + extend_imm;
          
      ORI: rd_data = rs1_data | extend_imm;
        
      ANDI: rd_data = rs1_data & extend_imm;
      
      XORI: rd_data = rs1_data ^ extend_imm;
          
      SLTI: rd_data = ( signed'(rs1_data) < signed'(extend_imm) ) ? 1 : 0;
        
      SLTIU: rd_data = ( rs1_data < extend_imm ) ? 1 : 0;
      
      SLLI: rd_data = rs1_data << extend_imm[4:0];
        
      SRLI: rd_data = rs1_data >> extend_imm[4:0];
        
      SRAI: rd_data = signed'(signed'(rs1_data) >>> extend_imm[4:0]);
      
      AUIPC: rd_data = addr + extend_imm;
        
      LUI:   rd_data = extend_imm ;
      
  	  MUL:begin 
			 product = signed'(rs1_data) * signed'(rs2_data);
			 rd_data = product[31:0];
      end
	
      MULH:begin 
			a_ext = {{32{rs1_data[31]}}, rs1_data};
			b_ext = {{32{rs2_data[31]}}, rs2_data};
			product = a_ext*b_ext;	
			rd_data = product[63:32];
			
			count=4;
			`uvm_info("scoreboard", $sformatf("MULH: RS1 = %h , RS2 = %h , RD1 = %h ",rs1_data,rs2_data,rd_data), UVM_HIGH) 
      end
      
      MULSU:begin 
			a_ext = {{32{rs1_data[31]}}, rs1_data};
			b_ext = {32'b0, rs2_data};
			product = a_ext*b_ext;	
			rd_data = product[63:32];
			count=4;
      end
	
      MULU:begin 
			a_ext = {32'b0, rs1_data};
			b_ext = {32'b0, rs2_data};
			product = a_ext*b_ext;	
			rd_data = product[63:32];
			count=4;
			`uvm_info("scoreboard", $sformatf("MULU DEBUG: rs1 = %0d, rs2 = %0d, product = %0d, rd_data = %0d", rs1_data, rs2_data, product, rd_data), UVM_HIGH) 
			
      end
      
     DIV: begin
      	if(signed'(rs1_data)==32'h80000000 & signed'(rs2_data)==32'hffff_ffff )
			rd_data=rs1_data;
	    else      
	    	rd_data=signed'(rs1_data) / signed'(rs2_data) ;
      	if(rs2_data==0) begin
      		rd_data=32'hffff_ffff;
      		count=34;
  		end
	//counts the number of cycles the excution will take based on the number of one's if the number is negative
      	if(signed'(rs2_data)<0) begin
      		count=1;
		  	foreach(rs2_data[i]) begin 
		  		if(rs2_data[i]==1)
		  			count++;
		  		else break;
      		end
      	end   
	//counts the number of cycles the excution will take based on the number of zeros if the number is positive
        else begin  	
		  	count=2;
		  	foreach(rs2_data[i]) begin 
		  		if(rs2_data[i]==0)
		  			count++;
		  		else break;
		  	end
      	end
      	
	  end
	  DIVU: begin
      	// first check if we divide by 0 
      	rd_data=rs1_data / rs2_data ;
      	if(rs2_data==0) begin
      		rd_data=32'hffff_ffff;
      		count=34;
  		end
	//counts the number of cycles the excution will take based on the number of zeros if the number is positive
        else begin  	
		  	count=2;
		  	foreach(rs2_data[i]) begin 
		  		if(rs2_data[i]==0)
		  			count++;
		  		else break;
		  	end
      	end
      	
	  end
	  REM: begin
      	
      	if(signed'(rs1_data)==32'h80000000 & signed'(rs2_data)==32'hffff_ffff )
			rd_data=0;
		else      	
			rd_data=signed'(rs1_data) % signed'(rs2_data) ;
      	if(rs2_data==0) begin
      		rd_data=rs1_data;
      		count=34;
  		end
      	if(signed'(rs2_data)<0) begin
		  	count=1;
		  	foreach(rs2_data[i]) begin 
		  		if(rs2_data[i]==1)
		  			count++;
		  		else break;
		  	end
      	end   
        else begin  	
		  	count=2;
		  	foreach(rs2_data[i]) begin 
		  		if(rs2_data[i]==0)
		  			count++;
		  		else break;
		  	end
      	end
      	
	  end
	  REMU: begin
      	
      	rd_data=rs1_data % rs2_data ;
      	if(rs2_data==0) begin
      		rd_data=rs1_data;
      		count=34;
  		end
      	
      	else begin  	
		  	count=2;
		  	foreach(rs2_data[i]) begin 
		  		if(rs2_data[i]==0)
		  			count++;
		  		else break;
		  	end
		end
      end 
      	
      	
      LB, LH, LW, LBU, LHU, SB , SH , SW  : begin
        logic[31:0] mem_addr;
        mem_addr = extend_imm + rs1_data;	
        fork   
            `uvm_info("scoreboard", $sformatf("inst %0s Mem_Addr: imm 0x%0h,\trs1 0x%0h mem[0x%0h] ",inst_type,extend_imm,rs1_data,rs1_data+extend_imm), UVM_HIGH)
            load_store_handling(inst_type,mem_addr,rs2_data,rd_data,rd,count);		
        join_any
      end
      BEQ  : check_pc = (rs1_data == rs2_data ) ? 1'b1 : 1'b0 ;
      BNE  : check_pc = (rs1_data != rs2_data ) ? 1'b1 : 1'b0 ;
      BLT  : check_pc = ( signed'(rs1_data) < signed'(rs2_data) ) ? 1'b1 : 1'b0 ;
      BGE  : check_pc = ( signed'(rs1_data) >= signed'(rs2_data) ) ? 1'b1 : 1'b0 ;
      BLTU : check_pc = (rs1_data < rs2_data ) ? 1'b1 : 1'b0 ;
      BGEU : check_pc = (rs1_data >= rs2_data ) ? 1'b1 : 1'b0 ; 
      JAL  , JALR : begin 
			check_pc = 1'b1;
			rd_data = addr + 4;
      end 
      default : rd_data = 32'bx;
        
    endcase
    if (opcode == B_TYPE || inst_type == JAL)   expected_pc = addr+ extend_imm;
    if (inst_type == JALR ) expected_pc = extend_imm+ rs1_data ;
    expected_pc = (expected_pc[1:0] == 2'b0) ? expected_pc : {expected_pc[31:2],2'b0} + 4;
    `uvm_info("scoreboard", $sformatf("%0s DEBUG: rs1 = %0d, rs2 = %0d, count = %0d, rd_data = %0d", inst_type,rs1_data, rs2_data, count, rd_data), UVM_HIGH)
    `uvm_info("scoreboard", $sformatf("\t\t\tIn excution %0s rd_data 0x%0h rs1_data 0x%0h  rs2_data 0x%0h",inst_type,rd_data,rs1_data,rs2_data), UVM_HIGH)
    
  endtask
  //---------------------------------------
  // verify_pc    
  //--------------------------------------- 
  task automatic verify_pc();
   
    instr_seq_item next_inst_item;
    
    int count_inst = 0 ;
    if (check_pc == 0 )
	`uvm_info("scoreboard","BRANCH : EXPECTED BRANCH NOT TAKEN", UVM_HIGH)
    else begin 
		while (count_inst < 5) begin 
		   wait (inst_q.size()>0);
	  	   next_inst_item=inst_q.pop_front();
	  	   if(next_inst_item.instr_addr_o == (expected_pc )) begin //(expected_pc -4)
				 check_pc = 0; //lower the flag
			     `uvm_info("scoreboard",$sformatf("Pass : Branch is taken flush %0d instructions , next address = %0d ",count_inst, expected_pc), UVM_HIGH)
			      inst_q.push_front(next_inst_item);
			 	 return ;
		   end 
		   count_inst++ ;            
		end 
		`uvm_error("scoreboard","Fail: Time out, branch expected to be taken")
    end 
     
  endtask
  //---------------------------------------
  // save results    
  //---------------------------------------   
	       
  task  save_results(input bit [6:0] opcode , logic[31:0] rd_data ,logic[4:0] rd , input int count);
    if( (opcode !=  B_TYPE ) && (opcode !=  S_TYPE ) ) begin
      expctd_rf_data result;
      expected_value_RegFile[rd] = rd_data; 
     
      result.rd_data = rd_data;
      result.rd_addr = rd;
      result.count = count;
      `uvm_info("scoreboard",$sformatf("in Save results opcode is %0b\tdata to write : %0d\t\trd is %0d",opcode,rd_data,rd), UVM_HIGH)
      
      if (opcode == I_TYPE_1) begin
        expected_load_to_rf_qu.push_back(result); //load queue
       
      end
      else
        expected_data_to_rf_qu.push_back(result);
    end
  endtask
  //---------------------------------------
  // compare tasks   
  //---------------------------------------
  //------------load compare------------------  
  task compare_load ();
     expctd_rf_data expected_load , written_load;
     wait (expected_load_to_rf_qu.size > 0 && written_load_data_to_rf_qu.size > 0);
     while (expected_load_to_rf_qu[0].count >= 0) begin
          written_load =  written_load_data_to_rf_qu.pop_front(); //discard element
          expected_load_to_rf_qu[0].count--;
     end 
     expected_load = expected_load_to_rf_qu.pop_front();
     if ( (expected_load.rd_addr == written_load.rd_addr) && (expected_load.rd_data == written_load.rd_data) ) begin
          `uvm_info("scoreboard",$sformatf("Pass : Load from memory to RegFile : Address: 0x%0h\tData: 0x%0h, Expected: Address: %0h\tData: 0x%0h ", written_load.rd_addr,written_load.rd_data,expected_load.rd_addr,expected_load.rd_data), UVM_HIGH)
		  num_crr_load++;
     end 
     else begin
          `uvm_error("scoreboard",$sformatf("Fail : Load from memory to regfile fails\t RegFile : Address: 0x%0h\tData: 0x%0h, Expected: Address: 0x%0h\tData: 0x%0h ",written_load.rd_addr,written_load.rd_data,expected_load.rd_addr,expected_load.rd_data)) 
		  num_incrr_load++;
     end     
  endtask 
               
 //------------store compare------------------
     task compare_store();   
        
          expctd_mem_data expected_store, written_store ;
          wait (written_store_mem_qu.size > 0 &&  store_mem_qu.size > 0);
          expected_store = store_mem_qu.pop_front();
          written_store = written_store_mem_qu.pop_front();
          if ( (expected_store.byte_enable == written_store.byte_enable ) &&
               (expected_store.addr == written_store.addr ) && 
              (expected_store.data == written_store.data) )   
          begin
            `uvm_info("scoreboard",$sformatf("Pass : store data written to memory\t Memory : Address: 0x%0h\tData 0x%0h\t Bytes %b Expected: 0x%0h\tData 0x%0h\t Bytes %b  ",written_store.addr,written_store.data,written_store.byte_enable,expected_store.addr,expected_store.data,expected_store.byte_enable), UVM_HIGH)
	    	num_crr_store++;
          end
          else begin
            `uvm_error("scoreboard",$sformatf("Fail : data written to memory\t Memory : Address: 0x%0h\tData 0x%0h\t Bytes %b Expected: 0x%0h\tData 0x%0h\t Bytes %b  ",written_store.addr,written_store.data,written_store.byte_enable,expected_store.addr,expected_store.data,expected_store.byte_enable))
	   	 	num_incrr_store++;
          end   
    endtask
 //------------arithmatic compare------------------   

    task compare_arithmatic();
          expctd_rf_data expected_result, written_result;
          wait (expected_data_to_rf_qu.size  > 0 && written_data_to_rf_qu.size > 0); 
            
          while (expected_data_to_rf_qu[0].count > 0) begin
            written_result = written_data_to_rf_qu.pop_front();
	    	`uvm_info("scoreboard",$sformatf("#################### pop from regfile ######################"), UVM_HIGH)          
	    	wait (written_data_to_rf_qu.size > 0);
            expected_data_to_rf_qu[0].count--;
          end 
          
	 	  expected_result = expected_data_to_rf_qu.pop_front();
          written_result = written_data_to_rf_qu.pop_front();
          
          if ( (expected_result.rd_addr == written_result.rd_addr) && (expected_result.rd_data == written_result.rd_data) ) begin
            `uvm_info("scoreboard",$sformatf("Pass : Expected results written to regfile : Address: 0x%0h\tData: 0x%0h, Expected: Address: %0h\tData: 0x%0h ", written_result.rd_addr,written_result.rd_data,expected_result.rd_addr,expected_result.rd_data), UVM_HIGH)
	   		num_crr_ex++;
          end 
          else begin
            `uvm_error("scoreboard",$sformatf("Fail : Expected results written to regfile\t RegFile : Address: 0x%0h\tData: 0x%0h, Expected: Address: 0x%0h\tData: 0x%0h ",written_result.rd_addr,written_result.rd_data,expected_result.rd_addr,expected_result.rd_data))
	   		num_incrr_ex++;
	  end
    endtask 
            
        
        
  //---------------------------------------
  // load_store_handling    
  //---------------------------------------
  task automatic load_store_handling(input instr_type inst_type ,logic[31:0]mem_addr ,rs2_data,output logic[31:0] rd_data,input logic[4:0] rd,output int count);
    
    logic [31:0] addr[1:0];
    bit[3:0] byte_enable[1:0];
    bit[1:0] offset;
    bit add_cycle;
    
    offset = mem_addr % 4;
    count = 0;
    
    //...........get byte_enable.................
    // byte instructions
    
    if (inst_type == LB || inst_type == SB || inst_type == LBU)  begin
      byte_enable[0] = 1'b1<<offset; 
      
    end 
    // half byte instructions
    else if (inst_type == LH || inst_type == LHU || inst_type == SH ) begin
      if (mem_addr[1:0] != 2'b11)
        byte_enable[0] = 2'b11<<offset;///////////
      else begin 
        add_cycle = 1'b1;
	count = 1;
        byte_enable[0] = 4'b1000 ;
        byte_enable[1] = 4'b0001 ;
      end
    end
    // word instructions
    else if (inst_type == LW || inst_type == SW ) begin
      if (mem_addr[1:0] == 2'b00)
        byte_enable[0] = 4'b1111;
      else begin 
        add_cycle = 1'b1;
		count = 1;
        byte_enable[0] = 4'b1111 << offset ;////////////
        byte_enable[1] = 4'b1111 >> (4- offset) ;
      end
    end
    
    ////...........calculate data for each memory accessing .................
    // store instructions
    if (inst_type == SB || inst_type == SH || inst_type == SW) begin
      logic [31:0] temp_data;
      temp_data = 32'b0;
      addr[0] = mem_addr;
      addr[1] = add_cycle ? {mem_addr[31:2], 2'b00} + 4: 32'b0;
      temp_data = (rs2_data << (8*offset) )| (rs2_data >> (8* (4- offset) ) ); //circular shift
      rs2_data = temp_data ;
      for (int i = 0 ; i <= add_cycle; i++)begin
        expctd_mem_data store_data;
        store_data.data = rs2_data;
        store_data.addr = addr[i];
        store_data.byte_enable = byte_enable[i];
		`uvm_info("scoreboard",$sformatf("$$$$$$$$$$$$$$$$$ store_data in excution %0s is addr 0x%0h data 0x%0h byte_en  %0b",inst_type,store_data.data,store_data.addr,store_data.byte_enable), UVM_HIGH)
       
        store_mem_qu.push_back(store_data);
        rd_data= 32'bx;
      end
    end
    // load instructions
    else begin
      logic[31:0] temp_data[1:0];
      serve_load = 1;
       
      for (int i = 0 ; i <= add_cycle; i++)begin
	  expctd_mem_data load_data;
          wait (load_mem_qu.size() > 0 );
          load_data = load_mem_qu.pop_front();
          if ((load_data.addr != addr[i]) || (load_data.byte_enable != byte_enable[i]) )
            `uvm_error("scoreboard",$sformatf("Fail: load incorrect memory access : address: %0d\t byte_enable: %0b\t Expected: address: %0d\tbyte_enable: %0b ",load_data.addr,load_data.byte_enable,addr[i],byte_enable[i]))
          else begin
	   
            if( i == 0)
              temp_data[i] = load_data.data >>(8*offset);
            else if( i == 1)
              temp_data[i] = load_data.data << (8*(4-offset)) ;
	    `uvm_info("scoreboard",$sformatf("SERVE LOAD: correct memory access : address: 0x%0h\t byte_enable: %b\t temp_data[%0d]: 0x%0x load_data: 0x%0x ",load_data.addr,load_data.byte_enable,i,temp_data[i],load_data.data),UVM_HIGH)
          end      
      end 
      case(inst_type) 
        LB : rd_data = {{24{temp_data[0][7]}},temp_data[0][7:0]};
        LBU : rd_data = {24'b0,temp_data[0][7:0]};
        LH , LHU : begin 
          if (add_cycle) 
            rd_data = temp_data[1] ^ temp_data[0];
          else 
            rd_data[15:0] = temp_data[0][15:0];
          if(inst_type == LH )
            rd_data[31:16] = {16{rd_data[15]}};
          else
            rd_data[31:16] = 16'b0;
        end
        LW: begin 
          if (add_cycle)
            rd_data = temp_data[1] ^ temp_data[0];/////////////
          else
            rd_data = temp_data[0];
        end 
      endcase
      save_results(I_TYPE_1, rd_data, rd,count); 
      serve_load = 0;  
    end
  endtask 
  function void report_phase(uvm_phase  phase);
        super.report_phase(phase);
        `uvm_info("report_phase","**************************   scoreboard   **************************",UVM_LOW)
		`uvm_info("report_phase","************************** Total **************************",UVM_LOW)
        `uvm_info("report_phase", $sformatf("total transactions: %0d",num_inst),UVM_LOW)
		`uvm_info("report_phase","************************** Jump and branch **************************",UVM_LOW)
        `uvm_info("report_phase", $sformatf("total jump and branches: %0d",num_branch_nd_jump),UVM_LOW)
		`uvm_info("report_phase","************************** Check for load **************************",UVM_LOW)
        `uvm_info("report_phase", $sformatf("total succesful transactions: %0d",num_crr_load),UVM_LOW)
        `uvm_info("report_phase", $sformatf("total failled transactions: %0d",num_incrr_load),UVM_LOW) 
		`uvm_info("report_phase","******************************************************",UVM_LOW)
		`uvm_info("report_phase","************************** Check for execute **************************",UVM_LOW)
        `uvm_info("report_phase", $sformatf("total succesful transactions: %0d",num_crr_ex),UVM_LOW)
        `uvm_info("report_phase", $sformatf("total failled transactions: %0d",num_incrr_ex),UVM_LOW)
		`uvm_info("report_phase","******************************************************",UVM_LOW) 
		`uvm_info("report_phase","************************** Check for store **************************",UVM_LOW)
        `uvm_info("report_phase", $sformatf("total succesful transactions: %0d",num_crr_store),UVM_LOW)
        `uvm_info("report_phase", $sformatf("total failled transactions: %0d",num_incrr_store),UVM_LOW) 
		`uvm_info("report_phase","*********************************************************************",UVM_LOW) 
 
  endfunction   
endclass
