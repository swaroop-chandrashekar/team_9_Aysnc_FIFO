/********************************************************************************************
Filename:	async_fifo_test1.sv   
Description:	Testcase1 for async fifo testbench 
Version:	1.0
*********************************************************************************************/ 

import uvm_pkg::*;
import fifo_pkg::*;
`include "uvm_macros.svh"
`include "async_fifo_env.sv"

class fifo_base_test extends uvm_test;
    
`uvm_component_utils(fifo_base_test)

fifo_env env;
write_sequence w_seq;
read_sequence r_seq;
virtual async_fifo_if vif;

function new(string name = "fifo_base_test", uvm_component parent = null);
	super.new(name, parent);
endfunction

function void build_phase(uvm_phase phase); 
	super.build_phase(phase);
        env = fifo_env::type_id::create("env", this);
        if (!uvm_config_db#(virtual async_fifo_if)::get(this, "", "vif", vif)) begin
        	`uvm_fatal("FIFO/DRV/NOVIF", "No virtual interface specified for this test instance")
        end 

endfunction

function void connect_phase(uvm_phase phase);
	super.connect_phase(phase);
endfunction 

function void end_of_elaboration();
	super.end_of_elaboration();
        uvm_root::get().print_topology();
endfunction

task run_phase(uvm_phase phase );

	env.wr_agent.wr_drv.trans_count_write=300;
        env.rd_agent.rd_drv.trans_count_read=300;

        env.wr_agent.wr_mon.trans_count_write=300;
        env.rd_agent.rd_mon.trans_count_read=300;

        phase.raise_objection(this, "Starting fifo_write_seq in main phase");

        fork
        	begin
                	$display("/t Starting sequence w_seq run_phase");
                	w_seq = write_sequence::type_id::create("w_seq", this);
                	w_seq.start(env.wr_agent.wr_seqr);
            	end
            	begin
                	$display("/t Starting sequence r_seq run_phase");
                	r_seq = read_sequence::type_id::create("r_seq", this);
                	r_seq.start(env.rd_agent.rd_seqr);
            	end
        join
      
        #100ns;	
      	env.scb.compare_flags();
        phase.drop_objection(this , "Finished fifo_seq in main phase");

        //#2000;
        //$finish;
endtask

endclass:fifo_base_test

