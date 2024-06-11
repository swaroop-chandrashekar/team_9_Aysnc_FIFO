/********************************************************************************************
Filename:	async_fifo_top.sv   
Description:	Top for async fifo testbench 
Version:	1.0
*********************************************************************************************/ 


import uvm_pkg::*;
`include "uvm_macros.svh"
`include "async_fifo_interface.sv"
`ifdef BASE_TEST
	`include "async_fifo_test1.sv"
`else
	`include "async_fifo_test2.sv"
`endif

module tb_top;

bit rclk,wclk,rrst,wrst;
  	
//always #4 wclk = ~wclk;
//always #10 rclk = ~rclk;

always #4 wclk = ~wclk;
always #10 rclk = ~rclk;
 
// Instantiate async_fifo_if interface instance DUV_IF with clock & RESET as input
async_fifo_if DUV_IF (wclk,rclk,wrst,rrst);
 
// Instantiate rtl ASYNC_FIFO and pass the interface instance as argument
ASYNC_FIFO DUT (.wData(DUV_IF.wData),
	      	.wFull(DUV_IF.wFull),
	      	.wHalf_full(DUV_IF.wHalf_full),
            	.rEmpty(DUV_IF.rEmpty),
	    	.rHalf_empty(DUV_IF.rHalf_empty),
            	.winc(DUV_IF.winc),
            	.rinc(DUV_IF.rinc),
            	.wclk(DUV_IF.wclk),
            	.rclk(DUV_IF.rclk),
            	.rrst(DUV_IF.rrst),
            	.wrst(DUV_IF.wrst),
            	.rData(DUV_IF.rData)
		);
  
initial 
begin
	uvm_config_db#(virtual async_fifo_if)::set(null, "*","vif", DUV_IF);
	`uvm_info("tb_top","uvm_config_db set for uvm_tb_top", UVM_LOW);
end

//start test
initial 
begin
        // call run_test
	`ifdef BASE_TEST
		run_test("fifo_base_test");	
	`else
	 	run_test("fifo_random_test");
	`endif
	
end


initial 
begin
	wclk=0;
	rclk=0;
	wrst =0;
	rrst=0;
	DUV_IF.rinc=0;
	DUV_IF.winc=0;
	#1;
	rrst =1;
	wrst=1;
end


initial 
begin

	assert (!DUV_IF.rinc) else
  		`uvm_error("ASSERTION", "Read increment is active at the beginning of simulation");
  
	assert (!DUV_IF.winc) else
 		 `uvm_error("ASSERTION", "Write increment is active at the beginning of simulation");

	assert (wclk === 0 || wclk === 1) else
 		 `uvm_error("ASSERTION", "Write clock has unexpected value");

	assert (rclk === 0 || rclk === 1) else
 		 `uvm_error("ASSERTION", "Read clock has unexpected value");

	assert (!wrst || (wclk && DUV_IF.wData)) else
  		`uvm_error("ASSERTION", "Unexpected sequencing of write events");

	assert (!rrst || (rclk && DUV_IF.rData)) else
 		 `uvm_error("ASSERTION", "Unexpected sequencing of read events");

	while (!wclk) 
	begin
    		#1;
		assert (!DUV_IF.wFull) else
    			`uvm_error("ASSERTION", "Write FIFO is full at the beginning of simulation");
	end
 	while (!rclk) 
	begin
    		#1;
		assert (DUV_IF.rEmpty) else
  		`uvm_error("ASSERTION", "Read FIFO is not empty at the beginning of simulation");
	end

end

//Coverage

`include "async_fifo_coverage.sv"
FIFO_coverage fifo_coverage_inst;
  
initial 
begin
	fifo_coverage_inst = new();
    	forever 
	begin 
		@(posedge wclk or posedge rclk)
      		fifo_coverage_inst.sample();
    	end
end 


endmodule:tb_top
