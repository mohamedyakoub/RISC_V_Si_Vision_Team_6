module testbensh_top;
import uvm_pkg::*;
import risc_pkg::*;
    parameter CLK_PERIOD = 10ns;  
    
    // Clock generation
    bit clk_tb;
    logic rst_n_tb;

    // Clock generation
    always #(CLK_PERIOD/2) clk_tb=~clk_tb;

  ins_if      inst_intf     (clk_tb);  
  data_if     data_intf     (clk_tb);
  config_if   config_intf   (clk_tb);
  debug_if    debug_intf    (clk_tb);
  interrupt_if interrupt_intf (clk_tb);
  
  
 
  cv32e40p_top DUT (
        // Clock and Reset
        .clk_i          (clk_tb),
        .rst_ni         (config_intf.rst_ni),

        .pulp_clock_en_i(config_intf.pulp_clock_en_i),  // PULP clock enable (only used if COREV_CLUSTER = 1)
        .scan_cg_en_i   (config_intf.scan_cg_en_i),  // Enable all clock gates for testing

        // Core ID, Cluster ID, debug mode halt address and boot address are considered more or less static
        .boot_addr_i            (config_intf.boot_addr_i),
        .mtvec_addr_i           (config_intf.mtvec_addr_i),
        .dm_halt_addr_i         (debug_intf.dm_halt_addr_i),
        .hart_id_i              (config_intf.hart_id_i),
        .dm_exception_addr_i    (debug_intf.dm_exception_addr_i),

        // Instruction memory interface
        .instr_req_o        (inst_intf.instr_req_o),
        .instr_gnt_i        (inst_intf.instr_gnt_i),
        .instr_rvalid_i     (inst_intf.instr_rvalid_i),
        .instr_addr_o       (inst_intf.instr_addr_o),
        .instr_rdata_i      (inst_intf.instr_rdata_i),

        // Data memory interface
        .data_req_o     (data_intf.data_req_o),
        .data_gnt_i     (data_intf.data_gnt_i),
        .data_rvalid_i  (data_intf.data_rvalid_i),
        .data_we_o      (data_intf.data_we_o),
        .data_be_o      (data_intf.data_be_o),
        .data_addr_o    (data_intf.data_addr_o),
        .data_wdata_o   (data_intf.data_wdata_o),
        .data_rdata_i   (data_intf.data_rdata_i),

        // Interrupt inputs
        .irq_i      (interrupt_intf.irq_i),  // CLINT interrupts + CLINT extension interrupts
        .irq_ack_o  (interrupt_intf.irq_ack_o),
        .irq_id_o   (interrupt_intf.irq_id_o),

        // Debug Interface
        .debug_req_i        (debug_intf.debug_req_i),
        .debug_havereset_o  (debug_intf.debug_havereset_o),
        .debug_running_o    (debug_intf.debug_running_o),
        .debug_halted_o     (debug_intf.debug_halted_o),

        // CPU Control Signals
        .fetch_enable_i     (config_intf.fetch_enable_i),
        .core_sleep_o       (config_intf.core_sleep_o)  
    );


    // Interfaces instantiation
    mult_if     mult_intf     (clk_tb,DUT.core_i.ex_stage_i.mult_i.rst_n ,
    DUT.core_i.ex_stage_i.mult_i.ex_ready_i ,
    DUT.core_i.ex_stage_i.mult_i.enable_i ,
    DUT.core_i.ex_stage_i.mult_i.operator_i ,
    DUT.core_i.ex_stage_i.mult_i.short_signed_i ,
    DUT.core_i.ex_stage_i.mult_i.op_a_i ,
    DUT.core_i.ex_stage_i.mult_i.op_b_i ,
    DUT.core_i.ex_stage_i.mult_i.result_o ,
    DUT.core_i.ex_stage_i.mult_i.ready_o 
);
    
    alu_div_if  alu_div_intf  (clk_tb,DUT.core_i.ex_stage_i.alu_i.rst_n ,
    DUT.core_i.ex_stage_i.alu_i.ex_ready_i ,
    DUT.core_i.ex_stage_i.alu_i.enable_i ,
    DUT.core_i.ex_stage_i.alu_i.operator_i ,
    DUT.core_i.ex_stage_i.alu_i.operand_a_i ,
    DUT.core_i.ex_stage_i.alu_i.operand_b_i ,
    DUT.core_i.ex_stage_i.alu_i.result_o ,
    DUT.core_i.ex_stage_i.alu_i.comparison_result_o ,
    DUT.core_i.ex_stage_i.alu_i.ready_o );
    
    reg_file_if reg_file_intf (clk_tb,DUT.core_i.id_stage_i.register_file_i.rst_n,
    DUT.core_i.id_stage_i.register_file_i.raddr_a_i,
    DUT.core_i.id_stage_i.register_file_i.rdata_a_o,
    DUT.core_i.id_stage_i.register_file_i.raddr_b_i,
    DUT.core_i.id_stage_i.register_file_i.rdata_b_o,
    DUT.core_i.id_stage_i.register_file_i.raddr_c_i,
    DUT.core_i.id_stage_i.register_file_i.rdata_c_o,
    DUT.core_i.id_stage_i.register_file_i.waddr_a_i,
    DUT.core_i.id_stage_i.register_file_i.wdata_a_i,
    DUT.core_i.id_stage_i.register_file_i.we_a_i,
    DUT.core_i.id_stage_i.register_file_i.waddr_b_i,
    DUT.core_i.id_stage_i.register_file_i.wdata_b_i,
    DUT.core_i.id_stage_i.register_file_i.we_b_i); 

    
   

  initial begin
    uvm_config_db#(virtual ins_if)::set(null,"","vif",inst_intf);
    uvm_config_db#(virtual data_if)::set(null,"*","vif",data_intf);
    uvm_config_db#(virtual alu_div_if)::set(null,"*","vif",alu_div_intf);
    uvm_config_db#(virtual mult_if)::set(null,"*","vif",mult_intf);
    uvm_config_db#(virtual reg_file_if)::set(null,"*","vif",reg_file_intf);
    uvm_config_db#(virtual config_if)::set(null,"*","vif",config_intf);
    uvm_config_db#(virtual debug_if)::set(null,"*","vif",debug_intf);
    uvm_config_db#(virtual interrupt_if)::set(null,"*","vif",interrupt_intf);



    $dumpfile("dump.vcd"); $dumpvars;
  end
   
  initial begin
    run_test("");
  end

endmodule
