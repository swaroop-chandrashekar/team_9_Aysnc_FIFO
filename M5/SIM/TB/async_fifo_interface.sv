/********************************************************************************************

Filename:	async_fifo_interface.sv   

Description:	Interface for async fifo testbench 

Version:	1.0

*********************************************************************************************/



interface async_fifo_if(input logic wclk,rclk,wrst,rrst);
logic [11:0] wData;
logic winc;
logic rinc;
    
logic [11:0] rData;
logic rEmpty;
logic wFull;

// clocking block
clocking monw_cs@(posedge wclk);
	default input #1 output #1;
  	input winc,wrst,wData,wFull;
endclocking

// clocking block
clocking monr_cs@(posedge rclk);
	default input #0 output #1;
  	input rinc, rrst,rData,rEmpty;
endclocking

   
endinterface

