/********************************************************************************************
Filename:	async_fifo_top.sv   
Description:	Top module for ASYNC_FIFO testbench
Version:	1.0

*********************************************************************************************/

  // Include the test.sv 
`include "async_fifo_test.sv"
`include "aysnc_fifo_interface.sv"


module async_fifo_top;
  
bit rclk,wclk,rrst,wrst;
  
always #5 wclk = ~wclk;
always #5 rclk = ~rclk;
  
initial 
begin
	wclk =0;
    	rclk=0;
    	wrst =0;
    	rrst=0;
    	#10
    	rrst =1;
    	wrst=1;
end
  

intf in (wclk,rclk,wrst,rrst);
test t1 (in);

ASYNC_FIFO DUT (.wData(in.wData),
            .wFull(in.wFull),
            .rEmpty(in.rEmpty),
            .winc(in.winc),
            .rinc(in.rinc),
            .wclk(in.wclk),
            .rclk(in.rclk),
            .rrst(in.rrst),
            .wrst(in.wrst),
            .rData(in.rData));
  
  

  
endmodule


