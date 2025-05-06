`timescale 1ns/1ps
import uvm_pkg::*;
`include "uvm_macros.svh"

class reg_file_sequence_item extends uvm_sequence_item ;
	
	`uvm_object_utils(reg_file_sequence_item)
	
	localparam ADDR_WIDTH = 5;
    localparam DATA_WIDTH = 32;
    localparam FPU        = 0;
    localparam ZFINX      = 0;
	
	bit rst_n;
   //logic scan_cg_en_i,
    //Read port R1
    logic [ADDR_WIDTH-1:0] raddr_a_i;
    logic [DATA_WIDTH-1:0] rdata_a_o;

    //Read port R2
    logic [ADDR_WIDTH-1:0] raddr_b_i;
    logic [DATA_WIDTH-1:0] rdata_b_o;

    //Read port R3
    //logic [ADDR_WIDTH-1:0] raddr_c_i;
    //logic [DATA_WIDTH-1:0] rdata_c_o;

    // Write port W1
    logic [ADDR_WIDTH-1:0] waddr_a_i;
    logic [DATA_WIDTH-1:0] wdata_a_i;
    //logic                  we_a_i;

    // Write port W2
    logic [ADDR_WIDTH-1:0] waddr_b_i;
    logic [DATA_WIDTH-1:0] wdata_b_i;
    //logic                  we_b_i;
	
	function new(string name = "reg_file_sequence_item");
		super.new(name);
	endfunction
  
endclass: alu_transaction