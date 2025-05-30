// Interfaces
interface data_if(input logic clk);
    logic [31:0] data_addr_o;
    logic        data_req_o;
    logic        data_gnt_i;
    logic        data_we_o;
    logic [3:0]  data_be_o;
    logic [31:0] data_wdata_o;
    logic        data_rvalid_i;
    logic [31:0] data_rdata_i;
	  /* clocking cb_drive @(negedge clk);
       default input  #1 output #1; 
        input  data_addr_o, data_req_o, data_we_o, data_be_o, data_wdata_o;
        output data_gnt_i, data_rvalid_i, data_rdata_i;
    endclocking

 clocking cb_mon @(posedge clk);
        default input  #1;
        input data_gnt_i, data_rvalid_i,data_req_o, data_we_o, data_be_o,data_rdata_i,data_addr_o,data_wdata_o;
    endclocking 
*/
endinterface
