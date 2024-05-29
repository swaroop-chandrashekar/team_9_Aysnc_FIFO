/********************************************************************************************

Filename:	async_fifo_scoreboard.sv   

Description:	Scoreboard for async fifo testbench 

Version:	1.0

*********************************************************************************************/ 


import uvm_pkg::*;
`include "uvm_macros.svh"
import fifo_pkg::*;

`uvm_analysis_imp_decl(_port_a)
`uvm_analysis_imp_decl(_port_b)

int empty_count;

class async_fifo_sb extends uvm_scoreboard;

`uvm_component_utils(async_fifo_sb)
 uvm_analysis_imp_port_a#(transaction_write,async_fifo_sb) write_port;
 uvm_analysis_imp_port_b#(transaction_read,async_fifo_sb) read_port; 

transaction_write write_q[$];
transaction_read read_q[$]; 
transaction_write txw;
transaction_read txr; 
  
function new(string name,uvm_component parent);
	super.new(name,parent);
endfunction  
               
function void build_phase(uvm_phase phase);
	super.build_phase(phase);
	write_port= new("write_port",this);
	read_port= new("read_port",this);  
endfunction

function void connect_phase(uvm_phase phase);
	super.connect_phase(phase);
endfunction 
 
function void write_port_a(transaction_write txw); 
	write_q.push_back(txw);
	//$display ("\t Scoreboard wData = %0h", txw.wData);
endfunction

function void write_port_b(transaction_read txr);

logic [11:0] popped_wData;
empty_count = write_q.size;
  
	if (write_q.size() > 0) 
	begin
    		popped_wData = write_q.pop_front().wData;
 
    		if (popped_wData == txr.rData)
		begin
			$display("\t\t");
			`uvm_info(get_type_name(), $sformatf("***************Scoreboard - Data Match successful---------Expected Transaction=%0h-----Received Transactions=%0h****************\n", popped_wData, txr.rData), UVM_MEDIUM)
			$display("********************************************************END_OF_TRANSACTION******************************************************************************************************************\n\n\n");
		end
      			//`uvm_info("ASYNC_FIFO_SCOREBOARD", $sformatf("PASSED Expected Data: %0h --- DUT Read Data: %0h", popped_wData, txr.rData), UVM_MEDIUM)
    		else
      			`uvm_error("ASYNC_FIFO_SCOREBOARD", $sformatf("ERROR Expected Data: %0h Does not match DUT Read Data: %0h", txr.rData, popped_wData))
  	end     
endfunction


task compare_flags(); 

	if (write_q.size > 4096) 
	begin
        	`uvm_info("SCOREBOARD", "FIFO IS FULL", UVM_MEDIUM);
  	end 
    	if (empty_count == 1) 
	begin
    		`uvm_info("SCOREBOARD", "FIFO IS EMPTY", UVM_MEDIUM);
    	end
  
endtask
    



task run_phase(uvm_phase phase);
	super.run_phase(phase);
        /*fork
		forever 
			begin
            			write_port.get(txw);
	    			write_port_a(txw);
           			 `uvm_info("WRITE SB", "write data" , UVM_LOW)
			end
		forever
			begin
	    			read_port.get(txr);
            			write_port_b(txr);
           			`uvm_info("READ SB", "write data" , UVM_LOW)
				
			end 
	join*/
endtask
  
endclass:async_fifo_sb
