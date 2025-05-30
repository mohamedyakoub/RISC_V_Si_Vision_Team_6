module mult_bind(
    mult_if m_if
);
    cv32e40p_top DUT;

    assign m_if.rst_n             = DUT.core_i.ex_stage_i.multi.rst_n ;
    assign m_if.ex_ready_i        = DUT.core_i.ex_stage_i.multi.ex_ready_i ;
    assign m_if.enable_i          = DUT.core_i.ex_stage_i.multi.enable_i ;
    assign m_if.operator_i        = DUT.core_i.ex_stage_i.multi.operator_i ;
    assign m_if.short_signed_i    = DUT.core_i.ex_stage_i.multi.short_signed_i ;
    assign m_if.op_a_i            = DUT.core_i.ex_stage_i.multi.op_a_i ;
    assign m_if.op_b_i            = DUT.core_i.ex_stage_i.multi.op_b_i ;
    assign m_if.result_o          = DUT.core_i.ex_stage_i.multi.result_o ;
    assign m_if.ready_o           = DUT.core_i.ex_stage_i.multi.ready_o ;
endmodule
