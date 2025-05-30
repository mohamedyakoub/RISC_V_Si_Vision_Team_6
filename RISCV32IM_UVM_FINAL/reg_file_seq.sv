class regfile_test_seq extends inst_seq;
    `uvm_object_utils(regfile_test_seq)

    function new(string name = "regfile_test_seq");
        super.new(name);
    endfunction

    // Fill instruction memory to test writing to and reading from the register file
    virtual task fill_mem();
        rsp = instr_seq_item::type_id::create("rsp");

        `uvm_info("regfile_seq", "Filling instruction memory for regfile test", UVM_MEDIUM)

        // --- Phase 1: Write 0xFFFFFFFF to x1–x31 using ADDI xN, x0, -1 ---
        // Writes -1 (0xFFF in imm12) to each register by using x0 as the base
        for (int i = 0; i < 31; i++) begin
            rsp.constraint_mode(0);  // Disable class-level constraints

            rsp.opcode  = 7'b0010011;  // ADDI
            rsp.funct3  = 3'b000;
            rsp.rs1     = 5'd0;        // x0 (contains 0)
            rsp.rd      = i[4:0] + 1;  // Write to x1..x31
            rsp.imm12   = 12'hFFF;     // -1 in 2’s complement

            rsp.post_randomize();     // Encode into instr_rdata_i
            inst_mem[i*4] = rsp.instr_rdata_i;
        end

        // --- Phase 2: Clear registers by XORing each with itself (result = 0) ---
        for (int i = 0; i < 31; i++) begin
            rsp.constraint_mode(0);  // Disable class-level constraints

            rsp.opcode  = 7'b0110011;  // R-type
            rsp.funct3  = 3'b100;      // XOR
            rsp.funct7  = 7'b0000000;
            rsp.rs1     = i[4:0] + 1;
            rsp.rs2     = i[4:0] + 1;
            rsp.rd      = i[4:0] + 1;

            rsp.post_randomize();
            inst_mem[(i + 31) * 4] = rsp.instr_rdata_i;
        end
	for (int i = 0; i < 31; i++) begin
            rsp.constraint_mode(0);  // Disable class-level constraints

            rsp.opcode  = 7'b0110011;  // R-type
            rsp.funct3  = 3'b100;      // XOR
            rsp.funct7  = 7'b0000000;
            rsp.rs1     = i[4:0] + 1;
            rsp.rs2     = i[4:0] + 1;
            rsp.rd      = i[4:0] + 1;

            rsp.post_randomize();
            inst_mem[(i + 31) * 4] = rsp.instr_rdata_i;
        end

        // --- Phase 3: Fill rest of memory with safe randomized instructions ---
        // Skip branches, jumps, loads, and illegal funct7=1 (M-extension)
        for (int i = 62*4; i < inst_num; i += 4) begin
            rsp.constraint_mode(1);  // Re-enable class-level constraints

            assert(rsp.randomize() with {
                !(opcode inside {7'b1100011, 7'b1101111, 7'b1100111, 7'b0000011});  // exclude branch/jump/load
                imm12 inside {12'h0, 12'h4, 12'h8};  // aligned immediates
                funct7 != 7'b0000001;  // avoid M-extension
            });

            inst_mem[i] = rsp.instr_rdata_i;
        end

        `uvm_info("regfile_seq", "Finished filling instruction memory", UVM_MEDIUM)
    endtask
endclass

