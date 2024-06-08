/********************************************************************************************
Filename:	async_fifo_seq_item.sv   
Description:	seq_item for async fifo testbench 
Version:	1.0
*********************************************************************************************/ 

/*****************************write_seq_item*************************************************/

import uvm_pkg::*;
`include "uvm_macros.svh"

class transaction_write extends uvm_sequence_item;
`uvm_object_utils(transaction_write)

rand bit [8:0] wData;
rand bit winc;
bit wFull;
bit wHalf_full;

function new(string name = "transaction_write");
        super.new(name);
endfunction

endclass:transaction_write

/*****************************Read_seq_item***************************************************/

class transaction_read extends uvm_sequence_item;
`uvm_object_utils(transaction_read)

rand bit rinc;
logic [8:0] rData;
bit rEmpty;
bit rHalf_empty;

function new(string name = "transaction_read");
        super.new(name);
endfunction

endclass:transaction_read
