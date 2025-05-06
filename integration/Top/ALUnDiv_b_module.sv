module aluNdiv_bind(
    alu_div_if if
);
    cv32e40p_top DUT;

    assign if.rst_n                 = DUT.core_i.ex_stage_i.alu_i.rst_n ;
    assign if.ex_ready_i            = DUT.core_i.ex_stage_i.alu_i.ex_ready_i ;
    assign if.enable_i              = DUT.core_i.ex_stage_i.alu_i.enable_i ;
    assign if.operator_i            = DUT.core_i.ex_stage_i.alu_i.operator_i ;
    assign if.operand_a_i           = DUT.core_i.ex_stage_i.alu_i.operand_a_i ;
    assign if.operand_b_i           = DUT.core_i.ex_stage_i.alu_i.operand_b_i ;
    assign if.result_o              = DUT.core_i.ex_stage_i.alu_i.result_o ;
    assign if.comparison_result_o   = DUT.core_i.ex_stage_i.alu_i.comparison_result_o ;
    assign if.ready_o               = DUT.core_i.ex_stage_i.alu_i.ready_o ;
endmodule