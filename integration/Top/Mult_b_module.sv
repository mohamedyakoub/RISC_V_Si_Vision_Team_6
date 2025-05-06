module mult_bind(
    mult_if if
);
    cv32e40p_top DUT;

    assign if.rst_n             = DUT.core_i.ex_stage_i.multi.rst_n ;
    assign if.ex_ready_i        = DUT.core_i.ex_stage_i.multi.ex_ready_i ;
    assign if.enable_i          = DUT.core_i.ex_stage_i.multi.enable_i ;
    assign if.operator_i        = DUT.core_i.ex_stage_i.multi.operator_i ;
    assign if.short_signed_i    = DUT.core_i.ex_stage_i.multi.short_signed_i ;
    assign if.op_a_i            = DUT.core_i.ex_stage_i.multi.op_a_i ;
    assign if.op_b_i            = DUT.core_i.ex_stage_i.multi.op_b_i ;
    assign if.result_o          = DUT.core_i.ex_stage_i.multi.result_o ;
    assign if.ready_o           = DUT.core_i.ex_stage_i.multi.ready_o ;
endmodule