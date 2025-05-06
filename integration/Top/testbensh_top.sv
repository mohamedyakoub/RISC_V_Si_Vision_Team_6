module testbensh_top;
    paramter CLK_PERIOD = 10ns;  
    
    // Clock generation
    bit clk_tb;
    logic rst_n_tb;

    // Clock generation
    always #(CLK_PERIOD/2) clk_tb=~clk_tb;

    // Interfaces instantiation
    data_if     data_intf     (clk_tb);
    ins_if      inst_intf     (clk_tb);  
    alu_div_if  alu_div_intf  (clk_tb);
    mult_if     mult_intf     (clk_tb); 
    reg_file_if reg_file_intf (clk_tb); 

    cv32e40p_top DUT (
        // Clock and Reset
        .clk_i          (clk_tb),
        .rst_ni         (rst_n_tb),

        .pulp_clock_en_i(1'b0),  // PULP clock enable (only used if COREV_CLUSTER = 1)
        .scan_cg_en_i   (1'b0),  // Enable all clock gates for testing

        // Core ID, Cluster ID, debug mode halt address and boot address are considered more or less static
        .boot_addr_i            (),
        .mtvec_addr_i           (),
        .dm_halt_addr_i         (),
        .hart_id_i              (),
        .dm_exception_addr_i    (),

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
        .irq_i      (),  // CLINT interrupts + CLINT extension interrupts
        .irq_ack_o  (),
        .irq_id_o   (),

        // Debug Interface
        .debug_req_i        (),
        .debug_havereset_o  (),
        .debug_running_o    (),
        .debug_halted_o     (),

        // CPU Control Signals
        .fetch_enable_i     (),
        .core_sleep_o       ()  
    );

    bind testbensh_top.DUT mult_bind    u_mult_bind(.if(mult_intf));
    bind testbensh_top.DUT aluNdiv_bind u_aluNdiv_bind(.if(alu_div_intf));
    bind testbensh_top.DUT reg_bind     u_reg_bind(.if(reg_file_intf));



    // bind testbensh_top.DUT.core_i.ex_stage_i.multi mult_if mult_intf (
    //   .rst_n(rst_n),
    //   .ex_ready_i(ex_ready_i),
    //   .enable_i(enable_i),
    //   .operator_i(operator_i),
    //   .short_signed_i(short_signed_i),
    //   .op_a_i(op_a_i),
    //   .op_b_i(op_b_i),
    //   .result_o(result_o),
    //   .ready_o(ready_o)

    //   );
    // bind testbensh_top.DUT.core_i.ex_stage_i.alu_i  alu_div_if  alu_div_intf(

    //     .rst_n(rst_n),
    //     .ex_ready_i(ex_ready_i),
    //     .enable_i(enable_i), 
    //     .operator_i(operator_i),
    //     .operand_a_i(operand_a_i), 
    //     .operand_b_i(operand_b_i),
    //     .result_o(result_o), 
    //     .comparison_result_o(comparison_result_o), 
    //     .ready_o(ready_o) 
    //   );

    // bind testbensh_top.DUT.core_i.id_stage_i.register_file_i reg_file_if reg_file_intf(

    //   .rst_n(rst_n), 
    //   .raddr_a_i(raddr_a_i), 
    //   .rdata_a_o(rdata_a_o),
    //   .raddr_b_i(raddr_b_i),
    //   .rdata_b_o(rdata_b_o),
    //   .raddr_c_i(raddr_c_i),
    //   .rdata_c_o(rdata_c_o),
    //   .waddr_a_i(waddr_a_i),
    //   .wdata_a_i(wdata_a_i),
    //   .we_a_i(we_a_i),  
    //   .waddr_b_i(waddr_b_i),
    //   .wdata_b_i(wdata_b_i),
    //   .we_b_i(we_b_i) 

    //   );

  initial begin
    uvm_config_db#(virtual ins_if)::set(uvm_root::get(),"*","vif",inst_intf);
    uvm_config_db#(virtual data_if)::set(uvm_root::get(),"*","vif",data_intf);
    uvm_config_db#(virtual alu_div_if)::set(uvm_root::get(),"*","vif",alu_div_intf);
    uvm_config_db#(virtual mult_if)::set(uvm_root::get(),"*","vif",alu_div_intf);
    uvm_config_db#(virtual reg_file_if)::set(uvm_root::get(),"*","vif",reg_file_intf);



    $dumpfile("dump.vcd"); $dumpvars;
  end
   
  initial begin
    run_test("risc_test");
  end

endmodule