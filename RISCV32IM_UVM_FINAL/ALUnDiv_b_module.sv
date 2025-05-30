module aluNdiv_bind(
    alu_div_if a_if
);
    cv32e40p_top DUT;

    assign a_if.rst_n                 = DUT.core_i.ex_stage_i.alu_i.rst_n ;
    assign a_if.ex_ready_i            = DUT.core_i.ex_stage_i.alu_i.ex_ready_i ;
    assign a_if.enable_i              = DUT.core_i.ex_stage_i.alu_i.enable_i ;
    assign a_if.operator_i            = DUT.core_i.ex_stage_i.alu_i.operator_i ;
    assign a_if.operand_a_i           = DUT.core_i.ex_stage_i.alu_i.operand_a_i ;
    assign a_if.operand_b_i           = DUT.core_i.ex_stage_i.alu_i.operand_b_i ;
    assign a_if.result_o              = DUT.core_i.ex_stage_i.alu_i.result_o ;
    assign a_if.comparison_result_o   = DUT.core_i.ex_stage_i.alu_i.comparison_result_o ;
    assign a_if.ready_o               = DUT.core_i.ex_stage_i.alu_i.ready_o ;
endmodule
