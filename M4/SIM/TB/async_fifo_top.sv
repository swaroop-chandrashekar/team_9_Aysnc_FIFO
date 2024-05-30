/********************************************************************************************
Filename:	async_fifo_top.sv   
Description:	Top for async fifo testbench 
Version:	1.0
*********************************************************************************************/ 


import uvm_pkg::*;
`include "uvm_macros.svh"
`include "async_fifo_interface.sv"
//`include "async_fifo_test1.sv"
//`include "async_fifo_test2.sv"
`include "async_fifo_test3.sv"

module tb_top;

bit rclk,wclk,rrst,wrst;
  	
always #4 wclk = ~wclk;
always #10 rclk = ~rclk;

//always #15 wclk = ~wclk;
//always #10 rclk = ~rclk;
 
// Instantiate async_fifo_if interface instance DUV_IF with clock & RESET as input
async_fifo_if DUV_IF (wclk,rclk,wrst,rrst);
 
// Instantiate rtl ASYNC_FIFO and pass the interface instance as argument
ASYNC_FIFO DUT (.wData(DUV_IF.wData),
	      .wFull(DUV_IF.wFull),
            .rEmpty(DUV_IF.rEmpty),
            .winc(DUV_IF.winc),
            .rinc(DUV_IF.rinc),
            .wclk(DUV_IF.wclk),
            .rclk(DUV_IF.rclk),
            .rrst(DUV_IF.rrst),
            .wrst(DUV_IF.wrst),
            .rData(DUV_IF.rData));
  
initial 
begin
	uvm_config_db#(virtual async_fifo_if)::set(null, "*","vif", DUV_IF);
	`uvm_info("tb_top","uvm_config_db set for uvm_tb_top", UVM_LOW);
end

initial 
begin
        // call run_test	
	//run_test("fifo_base_test");
	 //run_test("fifo_full_test");
	run_test("fifo_random_test");
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
