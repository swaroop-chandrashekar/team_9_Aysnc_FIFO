/********************************************************************************************

Filename:	async_fifo_package.sv   

Description:	package for async fifo testbench 

Version:	1.0

*********************************************************************************************/


package fifo_pkg;

`include "async_fifo_seq_item.sv"
`include "async_fifo_seq_base.sv"
`include "async_fifo_seq_full.sv"
`include "async_fifo_seq_random.sv"

`include "async_fifo_sequencer.sv"
`include "async_fifo_driver.sv"
`include "async_fifo_write_monitor.sv"
`include "async_fifo_read_monitor.sv"
`include "async_fifo_write_agent.sv"
`include "async_fifo_read_agent.sv"
`include "async_fifo_scoreboard.sv"

		
endpackage:fifo_pkg
