/********************************************************************************************
Filename:	async_fifo_write_agent.sv   
Description:	Write agent for async fifo testbench 
Version:	1.0
*********************************************************************************************/ 
 
import uvm_pkg::*;
`include "uvm_macros.svh"
 import fifo_pkg::*;


class write_agent extends uvm_agent;
`uvm_component_utils(write_agent)

write_sequencer wr_seqr;
write_driver wr_drv;
write_monitor wr_mon;

function new (string name = "write_agent", uvm_component parent);
	super.new(name, parent);
	`uvm_info("WRITE_AGENT_CLASS", "Inside constructor",UVM_LOW);
endfunction

function void build_phase(uvm_phase phase);
	super.build_phase(phase);
	wr_seqr = write_sequencer::type_id::create("wr_seqr", this);
	wr_drv = write_driver::type_id::create("wr_drv", this);
	wr_mon = write_monitor::type_id::create("wr_mon", this);

endfunction

function void connect_phase(uvm_phase phase);
	super.connect_phase(phase);
	wr_drv.seq_item_port.connect(wr_seqr.seq_item_export);
endfunction

task run_phase(uvm_phase phase);
	super.run_phase(phase);
endtask

endclass:write_agent
