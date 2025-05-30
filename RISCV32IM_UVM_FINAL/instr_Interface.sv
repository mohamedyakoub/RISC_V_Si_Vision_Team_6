interface ins_if(input logic clk);
    // Instruction interface signals
    logic        instr_req_o;
    logic [31:0] instr_addr_o;
    logic        instr_gnt_i;
    logic [31:0] instr_rdata_i;
    logic        instr_rvalid_i;


    // Internal signals for decoding
    logic [4:0] rs1, rs2, rd;
    logic [6:0] opcode;
    /*// Define a clocking block for synchronous access
   clocking cb_drive @(negedge clk);
       default input  #1 output #1	; // 1 step delay for inputs, 1 step delay for outputs

        input  instr_req_o, instr_addr_o;
        output  instr_rdata_i,instr_gnt_i,instr_rvalid_i ;
    endclocking 
   
    clocking cb_mon @(posedge clk);
        default input  #1;
        input  instr_rdata_i,instr_gnt_i,instr_rvalid_i,instr_req_o,instr_addr_o ;
    endclocking  */

    // Extract the opcode field from the instruction
    assign opcode = instr_rdata_i[6:0];

    // Instruction format detection based on opcode
    logic is_R_type, is_I_type, is_S_type, is_B_type, is_U_type, is_J_type;

    assign is_R_type = (opcode == 7'b0110011);                                 // R-type (e.g., ADD, SUB)
    assign is_I_type = (opcode == 7'b0010011) ||                               // I-type arithmetic (e.g., ADDI)
                       (opcode == 7'b0000011) ||                               // I-type load (e.g., LW)
                       (opcode == 7'b1100111);                                 // I-type jump (e.g., JALR)
    assign is_S_type = (opcode == 7'b0100011);                                 // S-type (e.g., SW)
    assign is_B_type = (opcode == 7'b1100011);                                 // B-type (e.g., BEQ)
    assign is_U_type = (opcode == 7'b0110111) || (opcode == 7'b0010111);       // U-type (e.g., LUI, AUIPC)
    assign is_J_type = (opcode == 7'b1101111);                                 // J-type (e.g., JAL)

    // Conditionally extract register fields based on instruction type
    assign rd  = (is_R_type || is_I_type || is_U_type || is_J_type) ? instr_rdata_i[11:7]  : 5'd0;
    assign rs1 = (is_R_type || is_I_type || is_S_type || is_B_type) ? instr_rdata_i[19:15] : 5'd0;
    assign rs2 = (is_R_type || is_S_type || is_B_type)              ? instr_rdata_i[24:20] : 5'd0;

    // ---------------------- RAW Hazard ----------------------
    // Read-After-Write hazard: current rs1/rs2 depends on previous rd
    property RAW_hazard;
        @(posedge clk )
         instr_rvalid_i && $past(instr_rvalid_i) &&
        ((rs1 == $past(rd) && rs1 != 0) || (rs2 == $past(rd) && rs2 != 0));
    endproperty

   // assert property (RAW_hazard) begin end else begin end  ;
        

    raw_hazard_c: cover property (RAW_hazard);

    // ---------------------- WAW Hazard ----------------------
    // Write-After-Write hazard: current rd equals previous rd
    property WAW_hazard;
        @(posedge clk)
        instr_rvalid_i && $past(instr_rvalid_i) &&
        (rd == $past(rd) && rd != 0);
    endproperty

    //assert property (WAW_hazard) begin end else begin end  ;
       

    waw_hazard_c: cover property (WAW_hazard);

    // ---------------------- WAR Hazard ----------------------
    // Write-After-Read hazard: current rd overwrites a previously read register
    property WAR_hazard;
        @(posedge clk)
        instr_rvalid_i && $past(instr_rvalid_i) &&
        ((rd == $past(rs1) || rd == $past(rs2)) && rd != 0);
    endproperty

    //assert property (WAR_hazard) begin end else begin end ;
        

    war_hazard_c: cover property (WAR_hazard);

endinterface

