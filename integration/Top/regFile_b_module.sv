module reg_bind(
    reg_file_if if
);
    cv32e40p_top DUT;

    assign if.rst_n         = DUT.core_i.id_stage_i.register_file_i.rst_n;
    assign if.raddr_a_i     = DUT.core_i.id_stage_i.register_file_i.raddr_a_i;
    assign if.rdata_a_o     = DUT.core_i.id_stage_i.register_file_i.rdata_a_o;
    assign if.raddr_b_i     = DUT.core_i.id_stage_i.register_file_i.raddr_b_i;
    assign if.rdata_b_o     = DUT.core_i.id_stage_i.register_file_i.rdata_b_o;
    assign if.raddr_c_i     = DUT.core_i.id_stage_i.register_file_i.raddr_c_i;
    assign if.rdata_c_o     = DUT.core_i.id_stage_i.register_file_i.rdata_c_o;
    assign if.waddr_a_i     = DUT.core_i.id_stage_i.register_file_i.waddr_a_i;
    assign if.wdata_a_i     = DUT.core_i.id_stage_i.register_file_i.wdata_a_i;
    assign if.we_a_i        = DUT.core_i.id_stage_i.register_file_i.we_a_i;
    assign if.waddr_b_i     = DUT.core_i.id_stage_i.register_file_i.waddr_b_i;
    assign if.wdata_b_i     = DUT.core_i.id_stage_i.register_file_i.wdata_b_i;
    assign if.we_b_i        = DUT.core_i.id_stage_i.register_file_i.we_b_i;
endmodule