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


// Constraint to generate specific values for wData with given weightages

constraint wData_c {
    wData dist {
      9'h000 := 1,   // Weight of 1
      9'h1FF := 2,   // Weight of 2
      9'h0CD := 1,   // Weight of 1
      9'h001 := 1,   // Weight of 1
      9'h002 := 1,   // Weight of 1
      9'h004 := 1,   // Weight of 1
      9'h008 := 1,   // Weight of 1
      9'h010 := 1,   // Weight of 1
      9'h020 := 1,   // Weight of 1
      9'h040 := 1,   // Weight of 1
      9'h080 := 1    // Weight of 1
    };
  }

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
