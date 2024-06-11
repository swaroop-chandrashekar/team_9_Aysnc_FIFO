/********************************************************************************************

Filename:	async_fifo_read_agent.sv   

Description:	Read agent for async fifo testbench 

Version:	1.0

*********************************************************************************************/ 

import uvm_pkg::*;
`include "uvm_macros.svh"
import async_fifo_pkg::*;

class read_agent extends uvm_agent;
`uvm_component_utils(read_agent)

read_sequencer rd_seqr;
read_driver rd_drv;
read_monitor rd_mon;

function new (string name = "read_agent", uvm_component parent);
	super.new(name, parent);
	`uvm_info("ENTER READ_AGENT_CLASS", "Inside constructor",UVM_LOW);
endfunction

function void build_phase(uvm_phase phase);
	super.build_phase(phase);
	rd_seqr = read_sequencer::type_id::create("rd_seqr", this);
	rd_drv = read_driver::type_id::create("rd_drv", this);
	rd_mon = read_monitor::type_id::create("rd_mon", this);
endfunction

function void connect_phase(uvm_phase phase);
	super.connect_phase(phase);
	rd_drv.seq_item_port.connect(rd_seqr.seq_item_export);
endfunction

task run_phase(uvm_phase phase);
	super.run_phase(phase);
endtask

endclass:read_agent
