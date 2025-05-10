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
  //  FIFOs to store the transactions
  //--------------------------------------- 
  instr_seq_item inst_fifo[$];
  //---------------------------------------
  //  structs to save the expected results
  //---------------------------------------
  typedef struct packed  { 
    logic [31:0] rd_data;
    logic [4:0] rd_addr;
  }expctd_rf_data;
  
  typedef struct packed  { 
    logic [31:0] addr;
    logic [31:0] data;
    bit [3:0] byte_enable; // enables the byte to be read/write
  }expctd_mem_data;
  
  //---------------------------------------
  // queues to store the expected values to be used in comparison with the reg file and data memory 
  //---------------------------------------
  expctd_mem_data store_mem_qu[$]; 
  expctd_rf_data expected_data_to_rf_qu[$] , expected_load_to_rf_qu[$] ;
  //---------------------------------------
  // queue to save the data loaded from the memory to the internal reg file 
  //---------------------------------------
  expctd_mem_data load_mem_qu[$]; 
  //---------------------------------------
  //  save the expected address for the branch and jump instructions 
  //---------------------------------------
  bit check_pc ;
  logic[31:0] expected_pc;
  
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
    rf_mon_export = new("rf_mon_export ",this); 
    
  endfunction
  //---------------------------------------
  // write tasks - recives the items from monitors and pushes into queues
  //---------------------------------------
  

  function void write_inst_mon_export (instr_seq_item inst_item);

    inst_fifo.push_back(inst_item);
    `uvm_info("scoreboard",$sformatf("Get: addr 0x%0x\tinst 0x%0x,inst_type %0s",inst_item.instr_addr_o,inst_item.instr_rdata_i,inst_item.inst_type), UVM_HIGH)
    //extract data ,calculate the result
    // write the result to the local register file also the save the data and address of the result in a queue of struct
    // if the instruction is load wait untill get a flag from the memory then write the data to the local rf
    //if it is store calculate the address and get the data from the regester file, push to a struct
  endfunction 
  
  function void write_rf_mon_export (reg_file_sequence_item rf_item);
    
   // pop an element from the queue of the struct then compare address and data 
    if (rf_item.we_a_i) begin
      expctd_rf_data load_data = expected_load_to_rf_qu.pop_front();
      if ( (load_data.rd_addr == rf_item.waddr_a_i) && (load_data.rd_data == rf_item.wdata_a_i) )
        `uvm_info("scoreboard","Pass : Load from memory to regfile", UVM_HIGH)
      else
        `uvm_error("scoreboard",$sformatf("Fail : Load from memory to regfile fails\t RegFile : Address: %0d\tData: %0d, Expected: Address: %0d\tData: %0d ",rf_item.waddr_a_i,rf_item.wdata_a_i,load_data.rd_addr,load_data.rd_data))
      
    end
        
    if (rf_item.we_b_i) begin
      expctd_rf_data result = expected_data_to_rf_qu.pop_front();
      if ( (result.rd_addr == rf_item.waddr_b_i) && (result.rd_data == rf_item.wdata_b_i) )
        `uvm_info("scoreboard","Pass : Expected results written to regfile", UVM_HIGH)
      else
        `uvm_error("scoreboard",$sformatf("Fail : Expected results written to regfile\t RegFile : Address: %0d\tData: %0d, Expected: Address: %0d\tData: %0d ",rf_item.waddr_b_i,rf_item.wdata_b_i,result.rd_addr,result.rd_data))
      
    end
    	
  endfunction
  
  function void write_data_mon_export (data_seq_item data_item); 
      if (data_item.data_we_o) begin
	expctd_mem_data store_data = store_mem_qu.pop_front();
        `uvm_info("scoreboard",{"store data to memory: ", data_item.convert2string()}, UVM_HIGH)
        if ( (data_item.data_be_o == store_data.byte_enable ) && (data_item.data_addr_o == store_data.addr ) && (data_item.data_wdata_o == store_data.data) )
          `uvm_info("scoreboard","Pass : Expected data written to memory", UVM_HIGH) 
         
        else
          `uvm_error("scoreboard",$sformatf("Fail : data written to memory\t Memory : Address %0d\tData %0d\t Bytes %0b, Expected: Address %0d\tData %0d\tBytes %0b",data_item.data_addr_o,data_item.data_wdata_o,data_item.data_be_o,store_data.addr,store_data.data,store_data.byte_enable))
      end
      
      else if (!data_item.data_we_o) begin
	//load_from_mem(data_item);
        expctd_mem_data load_data;
        `uvm_info("scoreboard",{"load data from memory: ", data_item.convert2string()}, UVM_HIGH)
        load_data.addr = data_item.data_addr_o;
        load_data.data = data_item.data_rdata_i;
        load_data.byte_enable = data_item.data_be_o;
        load_mem_qu.push_back(load_data); 
      end
    
  endfunction 
  /*
  //---------------------------------------
  // task load data
  //---------------------------------------
   task load_from_mem(input data_seq_item data_item);
	expctd_mem_data load_data;
        `uvm_info("scoreboard",{"load data from memory: ", data_item.convert2string()}, UVM_HIGH)
        load_data.addr = data_item.data_addr_o;
        load_data.data = data_item.data_rdata_i;
        load_data.byte_enable = data_item.data_be_o;
        load_mem_qu.push_back(load_data);  
   endtask 
   */     
  //---------------------------------------
  // run phase
  //---------------------------------------
  virtual task run_phase(uvm_phase phase);  
    forever begin
      instr_seq_item inst_item ;
      wait(inst_fifo.size()>0);
      inst_item = inst_fifo.pop_front();
      execute(inst_item);  
    end
  endtask
  
//---------------------------------------
// EXECUTE     
//---------------------------------------
  task execute(input instr_seq_item inst_item);
    logic [31:0] rd_data, extend_imm, rs1_data, rs2_data;
    //check pc claculated from the previous instruction
    verify_pc(inst_item.instr_addr_o);
    get_operands(inst_item, rs1_data, rs2_data, extend_imm);   
    get_expected(inst_item.inst_type, rs1_data, rs2_data, extend_imm , inst_item.instr_addr_o,rd_data);
    save_results(inst_item.opcode, rd_data,inst_item.rd);
  endtask
        
  task verify_pc(input logic [31:0] instr_addr_o);
    if (check_pc) begin 
      check_pc = 0; //lower the flag
      if(instr_addr_o == expected_pc )
        `uvm_info("scoreboard","Pass : Expected instruction address", UVM_HIGH)
      else 
        `uvm_error("scoreboard","Fail: next instruction address is false")
    end  
  endtask
//---------------------------------------
// get_operands data     
//---------------------------------------     
  task automatic get_operands(input instr_seq_item inst_item , output logic[31:0] rs1_data ,rs2_data,extend_imm);
      extend_imm = inst_item.Extend();
      if ( (inst_item.opcode !=  U_TYPE_0) && (inst_item.opcode !=  U_TYPE_1) && (inst_item.opcode != J_TYPE) ) begin
        rs1_data = expected_value_RegFile[inst_item.rs1];
        if ( (inst_item.opcode !=  I_TYPE_0) && (inst_item.opcode !=  I_TYPE_1) && (inst_item.opcode != I_TYPE_2) )
          rs2_data = expected_value_RegFile[inst_item.rs2];
      end
  endtask
//---------------------------------------
// get_expected result     
//---------------------------------------          
  task automatic get_expected(input instr_type inst_type ,logic[31:0] rs1_data ,rs2_data,extend_imm, addr,output logic[31:0]rd_data );
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
        
      SRA: rd_data = rs1_data >>> rs2_data[4:0];
          
      ADDI: rd_data = rs1_data + extend_imm;
          
      ORI: rd_data = rs1_data | extend_imm;
        
      ANDI: rd_data = rs1_data & extend_imm;
      
      XORI: rd_data = rs1_data ^ extend_imm;
          
      SLTI: rd_data = ( signed'(rs1_data) < signed'(extend_imm) ) ? 1 : 0;
        
      SLTIU: rd_data = ( rs1_data < extend_imm ) ? 1 : 0;
        
      SLLI: rd_data = rs1_data << extend_imm[4:0];
        
      SRLI: rd_data = rs1_data >> extend_imm[4:0];
        
      SRAI: rd_data = rs1_data >>> extend_imm[4:0];
      
      AUIPC: rd_data = addr + extend_imm;
        
      LUI:   rd_data = extend_imm ;
      //MUL  , MULH , MULSU, MULU , DIV , DIVU, REM , REMU,
      LB, LH, LW, LBU, LHU, SB , SH , SW  : begin
        logic[31:0] mem_addr;
        mem_addr = extend_imm + rs1_data;
        load_store_handling(inst_type,mem_addr,rs2_data,rd_data);
      end
      //BEQ  , BNE  , BLT  , BGE  , BLTU, BGEU,  
   	  //JAL  , JALR 
      default : rd_data = 32'bx;
        
    endcase
  endtask
//---------------------------------------
// load_store_handling    
//--------------------------------------- 
  task automatic load_store_handling(input instr_type inst_type ,logic[31:0]mem_addr ,rs2_data,output logic[31:0] rd_data);
    
    logic [31:0] addr[1:0];
    bit[3:0] byte_enable[1:0];
    bit[1:0] offset;
    bit add_cycle;
    
    offset = mem_addr % 4;
    addr[0] = {mem_addr[31:2], 2'b00};
    addr[1] = mem_addr[0] + 4;
    //...........get byte_enable.................
    // byte instructions
    if (inst_type == LB || inst_type == SB)  
      byte_enable[0] = 1'b1<<offset; ///////////////
    // half byte instructions
    else if (inst_type == LH || inst_type == LHU || inst_type == SH ) begin
      if (mem_addr[1:0] != 2'b11)
        byte_enable[0] = 2'b11<<offset;///////////
      else begin 
        add_cycle = 1'b1;
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
        byte_enable[0] = 4'b1111 << offset ;////////////
        byte_enable[1] = 4'b1111 >> (4- offset) ;
      end
    end
    ////...........calculate data for each memory accessing .................
    // store instructions
    if (inst_type == SB || inst_type == SH || inst_type == SW) begin
      logic [31:0] temp_data[1:0] ;
      temp_data[1] =32'b0;
      case(inst_type)
        SB: temp_data[0] = rs2_data[7:0]; //temp_data[0] = rs2_data[7:0] << (8*offset);
        SH: begin
          if (add_cycle) begin
            //temp_data[0] = {rs2_data[7:0], 24'b0};
            //temp_data[1] = {24'b0,rs2_data[15:8]};
	    temp_data[0] = {12'b0,rs2_data[7:0],rs2_data[15:8]};
          end
          else 
            temp_data[0] = {16'b0,rs2_data[15:0]};
        end
        SW: begin
          if (add_cycle) begin
            temp_data[0] = rs2_data << (8*offset);
            temp_data[1] = rs2_data >> (8*(4-offset));
          end
          else 
            temp_data[0] = rs2_data[31:0];
        end
      endcase
      rs2_data = temp_data[0] ^ temp_data[1];
      for (int i = 0 ; i <= add_cycle; i++)begin
        expctd_mem_data store_data;
        store_data.data = rs2_data;
        store_data.addr = addr[i];
        store_data.byte_enable = byte_enable[i];
        store_mem_qu.push_back(store_data);
        rd_data= 32'bx;
      end
    end
    // load instructions
    else begin
      logic[31:0] temp_data[1:0];
      for (int i = 0 ; i <= add_cycle; i++)begin
	  expctd_mem_data load_data;
          wait (load_mem_qu.size() > 0 );
          load_data = load_mem_qu.pop_front();
          if ((load_data.addr != addr[i]) || (load_data.byte_enable != byte_enable[i]) )
            `uvm_error("scoreboard",$sformatf("Fail: load data from memory : address: %0d\t byte_enable: %0b\t Expected: address: %0d\tbyte_enable: %0b ",load_data.addr,load_data.byte_enable,addr[i],byte_enable[i]))
          else begin
            if( i == 0)
              temp_data[i] = load_data.data >>(8*offset);
            else if( i == 1)
              temp_data[i] = load_data.data << (8*(4-offset)) ;
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
    end
      
  endtask
//---------------------------------------
// save results    
//---------------------------------------          
  task automatic save_results(input bit [6:0] opcode , logic[31:0] rd_data ,logic[4:0] rd);
    if( (opcode !=  B_TYPE ) && (opcode !=  S_TYPE ) ) begin
      expctd_rf_data result;
      expected_value_RegFile[rd] = rd_data; 
      result.rd_data = rd_data;
      result.rd_addr = rd;
      if (opcode == I_TYPE_1) 
        expected_load_to_rf_qu.push_back(result); //load queue
      else
        expected_data_to_rf_qu.push_back(result);
    end
  endtask
      
endclass
  
  
