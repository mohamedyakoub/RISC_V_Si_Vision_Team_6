package risc_pkg;
import cv32e40p_pkg::*;

localparam [6:0] R_TYPE   = 7'b0110011, // R_TYPE Intger : add sub xor or and sll srl sra slt sltu 
                                                 // R_TYPE M      : mul mulh mulsu mulu div divu rem remu 

                     I_TYPE_0 = 7'b0010011, // I_TYPE_0: addi xori ori andi slli srli srai slti sltiu
                     I_TYPE_1 = 7'b0000011, // I_TYPE_1: lb lh lw lbu lhu 
                     I_TYPE_2 = 7'b1100111, // I_TYPE_2: jalr ---> Jump And Link Reg
                     S_TYPE   = 7'b0100011, // S_TYPE  : sb sh sw 
                     B_TYPE   = 7'b1100011, // B_TYPE  : beq bne blt bge bltu bgeu
                     U_TYPE_0 = 7'b0110111, // U_TYPE_0: lui   ---> Load Upper Imm
                     U_TYPE_1 = 7'b0010111, // U_TYPE_1: auipc ---> Add Upper Imm to PC 
                     J_TYPE   = 7'b1101111; // J_TYPE  : jal   ---> Jump And Link

 
	// R_TYPE Intger funct3 :    0x0, 0x1, 0x2, 0x3, 0x4, 0x5, 0x6, 0x7

    localparam [2:0] add = 3'h0, sll = 3'h1, slt = 3'h2, sltu = 3'h3, Xor = 3'h4, srx = 3'h5, Or = 3'h6, And = 3'h7;

    // R_TYPE M funct3       :    0x0, 0x1, 0x2, 0x3, 0x4, 0x5, 0x6, 0x7

     localparam [2:0] mul = 3'h0, mulh = 3'h1, mulsu = 3'h2, mulu = 3'h3, div = 3'h4, divu = 3'h5, rem = 3'h6, remu = 3'h7;

     // I_TYPE_0 funct3      :    0x0, 0x1, 0x2, 0x3, 0x4, 0x5, 0x6, 0x7

    localparam [2:0] addi = 3'h0, sllI = 3'h1, sltI = 3'h2, sltIu = 3'h3, xorI = 3'h4, srxI = 3'h5, orI = 3'h6, AndI = 3'h7;

     // I_TYPE_1 funct3      :    0x0, 0x1, 0x2, 0x4, 0x5

     localparam [2:0] lb = 3'h0, lh = 3'h1, lw = 3'h2, lbu = 3'h4, lhu = 3'h5;

     // S_TYPE  funct3       :    0x0, 0x1, 0x2

     localparam [2:0] sb = 3'h0, sh = 3'h1, sw = 3'h2;

     // B_TYPE  funct3       :    0x0, 0x1, 0x4, 0x5, 0x6, 0x7

     localparam [2:0] beq = 3'h0, bne = 3'h1, blt = 3'h4, bge = 3'h5, bltu = 3'h6, bgeu = 3'h7;

     // INISTRUCTIONS RISC-VIM32
     typedef enum logic [5:0] { MUL  , MULH , MULSU, MULU , DIV , DIVU, REM , REMU,
                                ADD  , SUB  , SLL  , SLT  , SLTU, XOR , SRL , SRA , OR  , AND,
                                ADDI , SLLI , SLTI , SLTIU, XORI, SRLI, SRAI, ORI , ANDI,
                                LB   , LH   , LW   , LBU  , LHU ,
                                SB   , SH   , SW   ,
                                BEQ  , BNE  , BLT  , BGE  , BLTU, BGEU,  
                                JAL  , JALR , AUIPC, LUI  ,
                                RESET, 
                                UNKNOWN} instr_type;
  import uvm_pkg::*;
`include "uvm_macros.svh"

`include "instr_agent_config.sv"
`include "data_agent_cfg.sv"
`include "ins_cfg.sv"

`include "config_seq_item.sv"
`include "interrupt_seq_item.sv"
`include "debug_seq_item.sv"

`include "instr_seq_item.sv"

`include "data_seq_item.sv"
`include "alu_div_seq_item.sv"
`include "mult_seq_item.sv"
`include "RegFile_seq_item.sv"

`include "instr_driver.sv"
`include "data_driver.sv"

`include "config_driver.sv"
`include "interrupt_driver.sv"
`include "debug_driver.sv"

`include "instr_monitor.sv"
`include "data_mon.sv"

`include "monitor_alu_div.sv"
`include "alu_div_ref_model.sv"
`include "alu_div_scoreboard.sv"
`include "mult_ref_model.sv"

`include "monitor_mult.sv"
`include "regfile_monitor.sv"
`include "regfile_ref_model.sv"
`include "regfile_scoreboard.sv"
`include "mult_scoreboard.sv"
`include "regfile_cov.sv"
`include "data_cov.sv"
`include "instr_cov.sv"
`include "ALU_coverage.sv"
`include "mult_coverage.sv" 
`include "instr_sequencer.sv"
`include "data_seqr.sv"

`include "config_seqr.sv"
`include "interrupt_seqr.sv"
`include "debug_seqr.sv"

`include "virtual_seqr.sv"

`include "instr_agent.sv"
`include "data_agent.sv"
`include "mult_agent.sv"

`include "config_agent.sv"
`include "interrupt_agent.sv"
`include "debug_agent.sv"

`include "ALU_agent.sv"
`include "regfile_agent.sv"

`include "instr_seq.sv"
`include "mult_instr_seq.sv"
`include "load_store_seq.sv"
`include "corner_cases_seq.sv"
`include "hazard_seq.sv"
`include "reg_file_seq.sv"
`include "branch_seq.sv"
`include "data_seq.sv"
`include "Virtual_seq.sv"

`include "scoreboard.sv"
//`include "coverage.sv"
`include "enviroment.sv"


`include "risc_test.sv"
`include "corner_cases_test.sv"
`include "mult_div_test.sv"
`include "reg_file_test.sv"
`include "branch_test.sv"
`include "load_store_test.sv"
`include "hazard_test.sv"

//`include "testbensh_top.sv"                           
     


endpackage 
