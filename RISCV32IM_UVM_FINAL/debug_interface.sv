interface debug_if(input logic clk);
	
    	logic debug_req_i;
	logic [31:0] dm_halt_addr_i;
	logic [31:0] dm_exception_addr_i; 
        logic debug_havereset_o;
        logic debug_running_o;
        logic debug_halted_o;
 
endinterface : debug_if
// --------- EOF -----------
