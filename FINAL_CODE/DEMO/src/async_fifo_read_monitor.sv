/********************************************************************************************

Filename:	async_fifo_read_monitor.sv   

Description:	Read monitor for async fifo testbench 

Version:	1.0

*********************************************************************************************/ 

import uvm_pkg::*;
`include "uvm_macros.svh"
import async_fifo_pkg::*;

class read_monitor extends uvm_monitor;
`uvm_component_utils(read_monitor) 
 
virtual async_fifo_if rd_mon_if;
transaction_read txr;
bit write_complete_flag;

uvm_analysis_port#(transaction_read) rd_mon_port;

int trans_count_read;
int r_count;

function new (string name = "read_monitor", uvm_component parent);
	super.new(name, parent);
	`uvm_info("READ_MONITOR_CLASS", "Inside constructor",UVM_LOW)
endfunction

function void build_phase(uvm_phase phase);
	super.build_phase(phase);
	rd_mon_port = new("rd_mon_port", this);
     	if (!uvm_config_db#(virtual async_fifo_if)::get(this, "", "vif", rd_mon_if)) 
	begin
       		`uvm_error("build_phase", "No virtual interface specified for this read_monitor instance")
     	end
endfunction

function void connect_phase(uvm_phase phase);
	super.connect_phase(phase);
endfunction 
 

task run_phase(uvm_phase phase);
	super.run_phase(phase);
		fork 
			begin : read_monitor
				forever @(negedge rd_mon_if.rclk)
				begin
        				mon_read();
    				end
			end
			begin
				wait (r_count == trans_count_read);
                  	end
		join_any
		
endtask
 
       
task mon_read();
     
transaction_read txr;

	if (rd_mon_if.rinc==1 /*&& rd_mon_if.rEmpty==0*/)
	begin
		txr=transaction_read::type_id::create("txr"); 
		fork
			begin
				@(negedge rd_mon_if.rclk);
				txr.rData       =   rd_mon_if.rData;
			        txr.rEmpty      =   rd_mon_if.rEmpty;
				txr.rHalf_empty	=   rd_mon_if.rHalf_empty;
              			$display ("\t \t");
				`uvm_info(get_type_name(), $sformatf(" \t Report: ASYNC FIFO Read Monitor RINC=%0d, \t RDATA=%0d \t rEmpty=%0d, rHalf_empty=%0d, \t R_COUNT=%0d  ", txr.rinc, txr.rData, txr.rEmpty, txr.rHalf_empty, r_count+1), UVM_LOW)
   				rd_mon_port.write(txr);
				r_count= r_count +1;
			end
		join_none	
  	end

endtask

endclass:read_monitor
