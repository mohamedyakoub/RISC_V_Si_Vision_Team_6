`uvm_analysis_imp_decl( _data_mon_export )
`uvm_analysis_imp_decl( _inst_mon_export )
`uvm_analysis_imp_decl( _alu_mon_export )
`uvm_analysis_imp_decl( _mul_mon_export )
`uvm_analysis_imp_decl( _rf_mon_out_export )
`uvm_analysis_imp_decl( _rf_mon_in_export )


class scoreboard extends uvm_component;
  //---------------------------------------
  // factory registeration 
  //---------------------------------------
  `uvm_component_utils(scoreboard)
   //---------------------------------------
  // analysis ports
  //---------------------------------------
  uvm_analysis_imp_data_mon_export #(data_seq_item, scoreboard)  data_mon_export;
  uvm_analysis_imp_inst_mon_export #(inst_seq_item, scoreboard) inst_mon_export;
  uvm_analysis_imp_alu_mon_export #(alu_div_seq_item, scoreboard) alu_mon_export;
  uvm_analysis_imp_mul_mon_export #(mult_seq_item, scoreboard) mul_mon_export;
  uvm_analysis_imp_rf_mon_out_export #(RegFile_seq_item, scoreboard) rf_mon_out_export;
  uvm_analysis_imp_rf_mon_in_export #(RegFile_seq_item, scoreboard) rf_mon_in_export;
  //---------------------------------------
  // queues to store seq_item from monitors 
  //---------------------------------------
  data_seq_item data_qu[$];
  inst_seq_item inst_qu[$];
  alu_div_seq_item alu_div_qu[$];
  mult_seq_item mult_qu[$];
  RegFile_seq_item rf_in_qu[$] , rf_in_qu[$];
  //---------------------------------------
  //  structs 
  //---------------------------------------
  typedef struct packed  { 
    logic [31:0] op_a, op_b,result;
    instr_type do_inst;
  }alu_ex;
  //---------------------------------------
  //  seq_item from monitors && variables for stages
  //---------------------------------------
  inst_seq_item inst_seq;
  // decode stage
  logic [4:0] rs1, rs2, rd_e; logic [31:0] rs1_data, rs2_data,pc; logic [31:0] imm_d;
  logic [2:0] funct3;logic [6:0] funct7;logic[6:0] opcode;
  // execute stage
    
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
    inst_seq_item = new("inst_seq_item",this);
    alu_mon_export = new("alu_mon_export ",this);
    mul_mon_export= new("mul_mon_export ",this);
    rf_mon_out_export= new("rf_mon_out_export ",this);
    rf_mon_in_export = new("rf_mon_in_export",this);
       
  endfunction
  //---------------------------------------
  // write tasks - recives the items from monitors and pushes into queues
  //---------------------------------------
  function void write_data_mon_export (data_seq_item data_item);
    // if store pop an element from the struct queue and compare to the data recieved
    //if load wait until write flag from the rf then compare data out of memory to data received at the reg file 
    //qu_in.push_back(t_in);
    `uvm_info("scoreboard",{"Get new input item: ", data_item.convert2string()}, UVM_HIGH)
  endfunction 
  
  function void write_inst_mon_export (inst_seq_item inst _item);
    //qu_out.push_back(t_out);
    inst_seq = inst_item;
    `uvm_info("scoreboard",{"Get new inst item: ", inst_item.convert2string()}, UVM_HIGH)
    //in decode stage extract data and save them to the alu struct ,calculate the result , push the struct to a queu
    // write the result to the local register file also the save the data and address of the result in a queue of struct
    // if the instruction is load wait untill get a flag from the memory then write the data to the local rf
    //if it is store calculate the address and get the data from the regester file, push to a struct
    decode();
    execute();
    `uvm_info("scoreboard",{"Get new inst item: ", inst_item.convert2string()}, UVM_HIGH)
  endfunction 
  
  function void write_alu_mon_export (alu_div_seq_item alu _item);
    // pop an element from the queue of the struct then compare result, 2 operands
    //qu_out.push_back(t_out); 
    
  endfunction 
  
  function void write_mul_mon_export (mult_seq_item mult _item);
    // pop an element from the queue of the struct then compare result, 2 operands
    //qu_out.push_back(t_out);
    
  endfunction 
  
  function void write_rf_mon_in_export (RegFile_seq_item rf_in_item);
    // pop an element from the queue of the struct then compare address and data 
    //qu_out.push_back(t_out);
    
  endfunction 
  
  function void write_rf_mon_out_export (RegFile_seq_item rf_out_item);
    // pop an element from the queue of the struct then compare address and data 
    //qu_out.push_back(t_out);
    
  endfunction 
  endfunction 
  
  //---------------------------------------
  // run phase
  //---------------------------------------
  virtual task run_phase(uvm_phase phase);
    
    forever begin
      
    end
  endtask
  //---------------------------------------
  // DECODE
  //---------------------------------------
  task decode()
  //inst.Get_type();
  opcode<=inst_seq.instr_rdata_i[6:0];
  pc<=inst_seq.instr_addr_o;
  case(inst_seq.opcode)
    R_TYPE:
      begin
        rs1<=inst_seq.instr_rdata_i[19:15]; //not sure in all of the cases
        rs2<=inst_seq.instr_rdata_i[24:20]; //not sure in all of the cases
        rs1_data<=reg_file[inst_seq.instr_rdata_i[19:15]];
        rs2_data<=reg_file[inst_seq.instr_rdata_i[24:20]];
        rd_e<=inst_seq.instr_rdata_i[11:7];
        funct3<=inst_seq.instr_rdata_i[14:12];
        funct7<=inst_seq.instr_rdata_i[31:25];
        imm_d<=0;
      end
    I_TYPE_0:
      begin
        rs1<=inst_seq.instr_rdata_i[19:15];
        rs1_data<=reg_file[inst_seq.instr_rdata_i[19:15]];
        rd_e<=inst_seq.instr_rdata_i[11:7];
        funct3<=inst_seq.instr_rdata_i[14:12];
        funct7<=0;
        imm_d<={{20{inst_seq.instr_rdata_i[31]}},inst_seq.instr_rdata_i[31:20]} ;
      end
    I_TYPE_1:
      begin
        rs1<=inst_seq.instr_rdata_i[19:15];
        rs1_data<=reg_file[inst_seq.instr_rdata_i[19:15]];
        rd_e<=inst_seq.instr_rdata_i[11:7];
        funct3<=inst_seq.instr_rdata_i[14:12];
        funct7<=0;
        imm_d<={{20{inst_seq.instr_rdata_i[31]}} ,inst_seq.instr_rdata_i[31:20]} ;
      end
    I_TYPE_2:
      begin
        rs1<=inst_seq.instr_rdata_i[19:15];
        rs1_data<=reg_file[inst_seq.instr_rdata_i[19:15]];
        rd_e<=inst_seq.instr_rdata_i[11:7];
        funct3<=inst_seq.instr_rdata_i[14:12];
        funct7<=0;
        imm_d<={{20{inst_seq.instr_rdata_i[31]}} ,inst_seq.instr_rdata_i[31:20]} ;
      end
    S_TYPE:
      begin
        rs1<=inst_seq.instr_rdata_i[19:15];
        rs2<=inst_seq.instr_rdata_i[24:20];
        rs1_data<=reg_file[inst_seq.instr_rdata_i[19:15]];
        rs2_data<=reg_file[inst_seq.instr_rdata_i[24:20]];
        funct3<=inst_seq.instr_rdata_i[14:12];
        funct7<=0;
        imm_d<={ {20{inst_seq.instr_rdata_i[31]}},inst_seq.instr_rdata_i[31:25], inst_seq.instr_rdata_i[11:7] };
      end
    B_TYPE:
      begin
        rs1<=inst_seq.instr_rdata_i[19:15];
        rs2<=inst_seq.instr_rdata_i[24:20];
        rs1_data<=reg_file[inst_seq.instr_rdata_i[19:15]];
        rs2_data<=reg_file[inst_seq.instr_rdata_i[24:20]];
        funct3<=inst_seq.instr_rdata_i[14:12];
        funct7<=0;
        imm_d[0]<=0;
        imm_d[11]<=inst_seq.instr_rdata_i[7];
        imm_d[4:1]<=inst_seq.instr_rdata_i[11:8];
        imm_d[10:5]<=inst_seq.instr_rdata_i[30:25];
        imm_d[12]<=inst_seq.instr_rdata_i[31];
      end
    U_TYPE_0:
      begin
        rd_e<=inst_seq.instr_rdata_i[11:7];
        funct3<=0;
        funct7<=0;
        imm_d<={ {12{inst_seq.instr_rdata_i[31]}}, inst_seq.instr_rdata_i[31:12] };
      end
    U_TYPE_1:
      begin
        rd_e<=inst_seq.instr_rdata_i[11:7];
        funct3<=0;
        funct7<=0;
        imm_d<={ {12{inst_seq.instr_rdata_i[31]}}, inst_seq.instr_rdata_i[31:12] };
      end
    J_TYPE:
      begin
        rd_e<=inst_seq.instr_rdata_i[11:7];
        funct3<=0;
        funct7<=0;
        imm_d<={ inst_seq.instr_rdata_i[31],inst_seq.instr_rdata_i[19:12],inst_seq.instr_rdata_i[20],inst_seq.instr_rdata_i[30:21],1'b0 };
      end
  endcase
  endtask
//---------------------------------------
// EXECUTE     
//---------------------------------------
  
  
  
endclass
  
  
