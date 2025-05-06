import risc_pkg::* ;

class scoreboard extends uvm_component;
  //---------------------------------------
  // factory registeration 
  //---------------------------------------
  `uvm_component_utils(scoreboard)
   //---------------------------------------
  // Virtual interface to DUT
  virtual riscv_if vif;
  ins_seq_item inst_seq;
  bit [31:0] mem [int]; // This will model our data memory

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
    instr_ap = new("instr_ap", this);
    if (!uvm_config_db#(virtual riscv_if)::get(this, "", "vif", vif))
      `uvm_fatal("SB", "Can't get vif from config DB")
  endfunction
  //---------------------------------------
  // write tasks - recives the items from monitors and pushes into queues
  //---------------------------------------
  function void write_data_mon_export (data_seq_item data_item);
    //qu_in.push_back(t_in);
     if (data_item.data_we_o) begin
    // This is a write transaction: update memory
    mem[data_item.data_addr_o] = data_item.data_wdata_o;
     end
    `uvm_info("scoreboard",{"Get new input item: ", data_item.convert2string()}, UVM_HIGH)
  endfunction 
  
  function void write_inst_mon_export (inst_seq_item inst _item);
    //qu_out.push_back(t_out);
    `uvm_info("scoreboard",{"Get new inst item: ", inst_item.convert2string()}, UVM_HIGH)
  endfunction 
  
  function void write_alu_mon_export (alu_div_seq_item alu _item);
    //qu_out.push_back(t_out);
    
  endfunction 
  
  function void write_mul_mon_export (mult_seq_item mult _item);
    //qu_out.push_back(t_out);
    
  endfunction 
  
  function void write_rf_mon_in_export (RegFile_seq_item rf_in_item);
    //qu_out.push_back(t_out);
    
  endfunction 
  
  function void write_rf_mon_out_export (RegFile_seq_item rf_out_item);
    //qu_out.push_back(t_out);
    
  endfunction 
  
 


  // Handle incoming instruction
  function void inst_write(instr_item inst);
    // Push incoming instruction into the queue
    inst_seq<=inst;
  endfunction
    
    logic [31:0] instr; instr_type ins_type; logic f_valid;
    // decode stage
    logic [4:0] rs1, rs2, rd_d; logic [31:0] rs1_data, rs2_data,pc; logic [31:0] imm_d;  logic D_valid;
    // execute stage alu stage
    logic [4:0]rd_e;logic [31:0] alu_result,imm_e ;[6:0] opcode;[4:0] funct5;logic [2:0] funct3;logic [6:0] funct7; logic E_valid; int x,y;
    // memory stage load/store stage
    logic [31:0] load_data;logic [31:0] store_data;logic [31:0] store_addr;logic [31:0] load_addr;  
    // writeback stage register file stage
    logic [31:0] rf_write_data;logic [4:0] rf_write_addr;logic rf_write_en;logic [31:0] wb_data;logic [4:0] wb_addr;logic wb_en; logic W_valid;


// task fetch(ins_seq_item seq)
//   seq.Get_type();
//   instr=seq.instr_rdata_i;
//   pc= seq.instr_addr_o;
//   inst_type=seq.inst_type
// endtask

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
task execute()
  //imm_e<=imm_d;
  rf_write_addr<=rd_e;
  rf_write_en<=1;
  case(opcode)
  R_TYPE:
             case(funct3)
                add:
                  if( funct7==7'h00) rf_write_data<= rs1_data+rs2_data;
                  else if(funct7==7'h20) rf_write_data<= rs1_data-rs2_data;
                sll: rf_write_data<= rs1_data<<rs2_data[4:0];
                slt: rf_write_data<= (signed'(rs1_data)<signed'(rs2_data))? 1:0;
                sltu: rf_write_data<= (rs1_data<rs2_data)? 1:0;
                Xor: rf_write_data<= rs1_data ^ rs2_data;
                srx: 
                  if( funct7==7'h00) rf_write_data<= rs1_data>>rs2_data[4:0];
               	  else if(funct7==7'h20) rf_write_data<= rs1_data>>>rs2_data[4:0];
                Or: rf_write_data<= rs1_data | rs2_data;
                And: rf_write_data<= rs1_data & rs2_data;

             endcase
  I_TYPE_0:
             case(funct3)
                addi: rf_write_data<= rs1_data+imm_d;
                sllI: rf_write_data<= rs1_data<<imm_d[4:0];
                sltI: rf_write_data<= (signed'(rs1_data)<signed'(imm_d))? 1:0;
                sltIu: rf_write_data<= (rs1_data<imm_d)? 1:0;
                xorI: rf_write_data<= rs1_data^imm_d;
                srxI: 
                      if( imm_e[11:5]==4'h00) rf_write_data<= rs1_data>>imm_d[4:0];
                      else if(imm_e[11:5]==4'h20) rf_write_data<= rs1_data>>>imm_d[4:0];
                orI: rf_write_data<= rs1_data|imm_d;
                AndI: rf_write_data<= rs1_data&imm_d;

             endcase
  U_TYPE_0: rf_write_data<= imm_e<<12;
  U_TYPE_1: rf_write_data<= pc+(imm_e<<12);

  I_TYPE_1: begin
      load_addr = rs1_data + imm_e;
    case (funct3)
      3'b000: rf_write_data = {{24{mem[load_addr][7]}},  mem[load_addr][7:0]};   // lb (sign-extend from 8 bits)
      3'b001: rf_write_data = {{16{mem[load_addr][15]}}, mem[load_addr][15:0]};  // lh (sign-extend from 16 bits)
      3'b010: rf_write_data = mem[load_addr];                                    // lw (full word, no extension)
      3'b100: rf_write_data = {24'b0, mem[load_addr][7:0]};                      // lbu (zero-extend)
      3'b101: rf_write_data = {16'b0, mem[load_addr][15:0]};                     // lhu (zero-extend)
    endcase

      rf_write_data = load_data;
    end

    // S-Type Stores
    S_TYPE: begin
      store_addr = rs1_data + imm_d;
      store_data = rs2_data;
      case (funct3)
        3'b000: mem[store_addr][7:0]   = store_data[7:0];   // sb
        3'b001: mem[store_addr][15:0]  = store_data[15:0];  // sh
        3'b010: mem[store_addr]        = store_data;        // sw
      endcase
      rf_write_en = 0; // stores don't write back to RF
    end

  endcase
endtask

task wb()
    if(rf_write_addr!=0) begin
      reg_file[rf_write_addr]<=rf_write_data;
    end
  
endtask


  // Instruction queue for IF stage (to handle bursty traffic)
  riscv_instr_txn instr_q[$];  // Queue to hold instructions

  // Input from monitor
  uvm_analysis_imp#(riscv_instr_txn, scoreboard) instr_ap; //fetch
  data_ap //excute
  alu_ap //excute
  mul_ap //excute
  reg_file_ap //decode and writeback



  // alu_div agent
  // env 
  // test
  // 


 

  task run_phase(uvm_phase phase);
    forever begin
      @(posedge vif.clk);
      advance_pipeline();
      compare_with_dut();
    end
  endtask


    // Advance pipeline stages
    function void advance_pipeline();
        bit stall = 0;

        // Detect load-use hazard: EX loads, and ID depends on the load (rs1/rs2)
        if ((ex_stage.valid) &&
            (ex_stage.instr[6:0] == 7'b0000011) && // LW opcode
            (ex_stage.rd != 0) &&                   // Not a store (rd != 0)
            id_stage.valid &&
            ((id_stage.rs1 == ex_stage.rd) || (id_stage.rs2 == ex_stage.rd))) begin
            stall = 1;
            `uvm_info("SB", "Stall inserted due to load-use hazard", UVM_MEDIUM)
        end
        
        if (stall) begin
            ex_stage = '{default:0}; // Bubble
            ex_stage.valid = 0;
            // ID and IF frozen
        end else begin
            ex_stage = id_stage;
            ex_stage.valid = id_stage.valid;

            id_stage = if_stage;
            id_stage.valid = if_stage.valid;

            if_stage = '{default:0}; // Ready for next instruction
        end

        // Handle instruction fetch (IF) stage, checking if it can take a new instruction
        if (!if_stage.valid && instr_q.size() > 0) begin
            riscv_instr_txn t = instr_q.pop_front();  // Pop instruction from the queue
            if_stage.instr = t.instr;
            if_stage.rs1   = t.rs1;
            if_stage.rs2   = t.rs2;
            if_stage.rd    = t.rd;
            if_stage.wr_en = t.wr_en;
            if_stage.valid = 1;
        end

        // Forwarding logic for EX stage (handling if we have data forwarding)
        if (ex_stage.valid) begin
            // Forward data from EX to ID stage (if rs1 or rs2 matches EX rd)
            if (id_stage.valid && (id_stage.rs1 == ex_stage.rd)) begin
            id_stage.alu_result = ex_stage.alu_result;
            end
            if (id_stage.valid && (id_stage.rs2 == ex_stage.rd)) begin
            id_stage.alu_result = ex_stage.alu_result;
            end

            // Forwarding from EX to IF (just in case there’s a dependency)
            if (if_stage.valid && (if_stage.rs1 == ex_stage.rd)) begin
            if_stage.alu_result = ex_stage.alu_result;
            end
            if (if_stage.valid && (if_stage.rs2 == ex_stage.rd)) begin
            if_stage.alu_result = ex_stage.alu_result;
            end
        end
    endfunction

  // Compare expected values with DUT
  function void compare_with_dut();
    if (ex_stage.valid) begin
      logic [31:0] dut_alu = vif.ex_alu_result;

      if (ex_stage.alu_result !== dut_alu) begin
        `uvm_error("SB", $sformatf("ALU mismatch: expected %h, got %h",
                                   ex_stage.alu_result, dut_alu))
      end
    end

    if (wb_stage.valid && wb_stage.wr_en && wb_stage.rd != 0) begin
      logic [31:0] dut_rf_write = vif.rf_write_data;

      if (wb_stage.load_data !== dut_rf_write) begin
        `uvm_error("SB", $sformatf("Writeback mismatch: rd=%0d, expected=%h, got=%h",
                                   wb_stage.rd, wb_stage.load_data, dut_rf_write))
      end
    end
  endfunction

endclass
