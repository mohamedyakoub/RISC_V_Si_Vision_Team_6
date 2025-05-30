interface config_if(input logic clk);
	
	logic rst_ni;
	logic pulp_clock_en_i;
	logic scan_cg_en_i;
	logic [31:0] boot_addr_i;
    	logic [31:0] mtvec_addr_i;
	logic [31:0] hart_id_i;
	logic fetch_enable_i;
	logic core_sleep_o;

endinterface : config_if
// --------- EOF -----------
