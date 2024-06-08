/********************************************************************************************
Filename:	async_fifo_write_monitor.sv   
Description:	Write monitor for async fifo testbench 
Version:	1.0
*********************************************************************************************/ 


import uvm_pkg::*;
`include "uvm_macros.svh"
import async_fifo_pkg::*;


class write_monitor extends uvm_monitor;
`uvm_component_utils(write_monitor) 
 
virtual async_fifo_if vif;
transaction_write txw;

uvm_analysis_port#(transaction_write) wr_mon_port;

int trans_count_write;
int w_count;

function new (string name = "write_monitor", uvm_component parent);
	super.new(name, parent);
	`uvm_info("\t\t*****************","*********WRITE_MONITOR_CLASS********************************", UVM_LOW);	
endfunction

function void build_phase(uvm_phase phase);
	super.build_phase(phase);
	wr_mon_port = new("wr_mon_port", this);

     	if (!uvm_config_db#(virtual async_fifo_if)::get(this, "", "vif", vif)) begin
       		`uvm_error("CONFIG","cannot get() m_cfg from uvm_config_db. Have you set() it?")
     	end
endfunction

function void connect_phase(uvm_phase phase);
	super.connect_phase(phase);
endfunction 
 
task run_phase(uvm_phase phase);

	super.run_phase(phase);
    	fork
        	begin : write_monitor
            		forever @(negedge vif.wclk) 
			begin
                		mon_write();
            		end
        	end

        	begin : write_completion
              		wait (w_count == trans_count_write);
        	end
    	join

endtask
        
task mon_write;
     
	transaction_write txw;

   	if (vif.winc==1 && vif.wFull==0) 
	begin
	
 		txw=transaction_write::type_id::create("txw");  
 		txw.winc = vif.winc;
  		txw.wData = vif.wData;
		txw.wFull = vif.wFull;
		txw.wHalf_full = vif.wHalf_full;
		`uvm_info(get_type_name(), $sformatf(" \t \t Report: ASYNC FIFO WRITE Monitor WINC=%0d, \t WDATA=%0d \t WFULL = %0d \t WHALF_FULL=%0d\t W_COUNT=%0d Transactions", txw.winc, txw.wData, txw.wFull, txw.wHalf_full, w_count+1), UVM_LOW)
   		wr_mon_port.write(txw);
		w_count=w_count +1;		 
	end
	

endtask

endclass:write_monitor
