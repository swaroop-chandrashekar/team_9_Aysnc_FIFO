/********************************************************************************************
Filename:	async_fifo_seq_random.sv   
Description:	Random sequence for async fifo testbench 
Version:	1.0
*********************************************************************************************/  

/*****************************Write_sequence*************************************************/
 


import uvm_pkg::*;
`include "uvm_macros.svh"
 import async_fifo_pkg::*;

class write_sequence_random extends uvm_sequence#(transaction_write);
  `uvm_object_utils(write_sequence_random)

int tx_count_write=1000;
transaction_write txw;
    
function new(string name = "write_sequence_full");
       super.new(name);
       `uvm_info("WRITE_SEQUENCE_CLASS", "Inside constructor",UVM_LOW)
endfunction

task body();
        `uvm_info("WRITE_SEQUENCE_CLASS", "Inside body task",UVM_LOW)
  	for (int i = 0; i < tx_count_write; i++) 
	begin
		txw = transaction_write::type_id::create("txw");
		start_item(txw);
    		if (!(txw.randomize()));
			//`uvm_error("TX_GENERATION_FAILED", "Failed to randomize transaction_write")
		finish_item(txw);
    	end
	
endtask

endclass:write_sequence_random

/*****************************Read_sequence*************************************************/


class read_sequence_random extends uvm_sequence#(transaction_read);
  
`uvm_object_utils(read_sequence_random)

int tx_count_read=1000;
transaction_read txr;
    
function new(string name = "read_sequence_random");
	super.new(name);
       `uvm_info("READ_SEQUENCE_CLASS", "Inside constructor",UVM_LOW)
endfunction

task body();

        `uvm_info("READ_SEQUENCE_CLASS", "Inside body task",UVM_LOW)
	for (int i = 0; i < tx_count_read; i++) 
	begin
		txr = transaction_read::type_id::create("txr");
		start_item(txr);
          	if(!(txr.randomize()));	
			//`uvm_fatal("TX_GENERATION_FAILED", "Failed to randomize transaction_read")
		finish_item(txr);
	end	
endtask

endclass:read_sequence_random
