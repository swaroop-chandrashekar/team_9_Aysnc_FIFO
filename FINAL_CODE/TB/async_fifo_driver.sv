/********************************************************************************************

Filename:	async_fifo_driver.sv   

Description:	Driver class for async fifo testbench 

Version:	1.0

*********************************************************************************************/

/*****************************WRITE_DRIVER***************************************************/

import uvm_pkg::*;
`include "uvm_macros.svh"
import async_fifo_pkg::*;


class write_driver extends uvm_driver#(transaction_write);
`uvm_component_utils(write_driver)

virtual async_fifo_if wr_drv_if;
transaction_write txw;
int trans_count_write;

function new (string name = "write_driver", uvm_component parent);
	super.new(name, parent);
	`uvm_info("\t\t**************","************WRITE_DRIVER_CLASS********************************", UVM_LOW);	
endfunction

function void build_phase (uvm_phase phase);
	super.build_phase(phase);
	`uvm_info("ENTER WRITE_DRIVER_CLASS", "Build Phase",UVM_HIGH)
	if(!(uvm_config_db #(virtual async_fifo_if)::get (this, "*", "vif", wr_drv_if))) 
		`uvm_error("WRITE_DRIVER_CLASS", "FAILED to get wr_drv_if from config DB")
endfunction

function void connect_phase (uvm_phase phase);
	super.connect_phase(phase);
endfunction

task drive_write(transaction_write txw);
	@(posedge wr_drv_if.wclk);
  	this.wr_drv_if.winc = txw.winc;
        this.wr_drv_if.wData = txw.wData;	
endtask

task run_phase (uvm_phase phase);
	super.run_phase(phase);
	`uvm_info("DRIVER_CLASS", "Inside Run Phase",UVM_LOW)
	this.wr_drv_if.wData <=0;
	this.wr_drv_if.winc <=0;

	repeat(10) @(posedge wr_drv_if.wclk);
  		
  	for (integer i = 0; i < trans_count_write ; i++) 
	begin 
		txw=transaction_write::type_id::create("txw");
		seq_item_port.get_next_item(txw);
            	wait(wr_drv_if.wFull ==0);
            	drive_write(txw);
            	seq_item_port.item_done();

	end
	@(posedge wr_drv_if.wclk);
	this.wr_drv_if.winc =0;   	
endtask

endclass:write_driver

/*****************************READ_DRIVER***************************************************/


class read_driver extends uvm_driver#(transaction_read);
`uvm_component_utils(read_driver)

virtual async_fifo_if rd_drv_if;
transaction_read txr;
int trans_count_read;

function new (string name = "read_driver", uvm_component parent);
	super.new(name, parent);
	`uvm_info("\t\t***************","***********READ_DRIVER_CLASS********************************", UVM_LOW);
endfunction

function void build_phase (uvm_phase phase);
	super.build_phase(phase);
	`uvm_info("READ_DRIVER_CLASS", "Build Phase",UVM_HIGH);
	if(!(uvm_config_db #(virtual async_fifo_if)::get (this, "*", "vif", rd_drv_if))) 
		`uvm_error("READ_DRIVER_CLASS", "FAILED to get rd_drv_if from config DB")
endfunction

function void connect_phase (uvm_phase phase);
	super.connect_phase(phase);
endfunction

task drive_read(transaction_read txr);
 	 @(posedge rd_drv_if.rclk);
  	this.rd_drv_if.rinc = txr.rinc;	
endtask

task run_phase (uvm_phase phase);
	super.run_phase(phase);
	`uvm_info("DRIVER_CLASS", "Inside Run Phase",UVM_LOW)
	this.rd_drv_if.rinc <=0;

        repeat(10) @(posedge rd_drv_if.rclk);
			
        for (integer j = 0; j < trans_count_read; j++) 
	begin
        	txr=transaction_read::type_id::create("txr");
		seq_item_port.get_next_item(txr);
            	wait(rd_drv_if.rEmpty==0);
            	drive_read(txr);
            	seq_item_port.item_done();
	end
	
	@(posedge rd_drv_if.rclk);
	this.rd_drv_if.rinc =0;
    	
endtask


endclass:read_driver



